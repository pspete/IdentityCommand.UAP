BeforeAll {
    $Script:UAPModuleName = 'IdentityCommand.UAP'

    #Get Current Directory
    $Here = Split-Path -Parent $PSCommandPath

    #Resolve Path to Module Directory
    $ModulePath = Resolve-Path "$Here\..\$Script:UAPModuleName"

    #Define Path to Module Manifest
    $ManifestPath = Join-Path "$ModulePath" "$Script:UAPModuleName.psd1"

    if ( -not (Get-Module -Name $Script:UAPModuleName -All)) {

        Import-Module -Name "$ManifestPath" -ArgumentList $true -Force -ErrorAction Stop

    }
}

Describe 'New-UAPPolicy' {

    BeforeEach {

        Mock -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -MockWith {
            [pscustomobject]@{ policyId = 'p1' }
        }

        InModuleScope -ModuleName $Script:UAPModuleName {
            $ISPSSSession = [ordered]@{
                tenant_url = 'https://somedomain.uap.cyberark.cloud'
                User       = $null
                TenantId   = 'SomeTenant'
                SessionId  = 'SomeSession'
                WebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
            }
            New-Variable -Name ISPSSSession -Value $ISPSSSession -Scope Script -Force
        }

        $Script:response = New-UAPPolicy -name 'SomePolicy' -targetCategory 'Cloud Console' -locationType AWS -principals ([pscustomobject]@{ id = 'i1'; type = 'USER' }) -targets ([pscustomobject]@{ roleId = 'r1'; workspaceId = 'w1' })
    }

    Context 'Request' {

        It 'sends request' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -Times 1 -Exactly -Scope It
        }

        It 'sends request to expected endpoint' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $URI -eq 'https://somedomain.uap.cyberark.cloud/api/policies'
            } -Times 1 -Exactly -Scope It
        }

        It 'uses expected method' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $Method -eq 'POST'
            } -Times 1 -Exactly -Scope It
        }

        It 'sends the name and entitlement in the metadata' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $Metadata = ($Body | ConvertFrom-Json).metadata
                ($Metadata.name -eq 'SomePolicy') -and
                ($Metadata.policyEntitlement.targetCategory -eq 'Cloud Console') -and
                ($Metadata.policyEntitlement.locationType -eq 'AWS')
            } -Times 1 -Exactly -Scope It
        }

        It 'nests cloud console targets under a targets property' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Body | ConvertFrom-Json).targets.targets[0].roleId -eq 'r1'
            } -Times 1 -Exactly -Scope It
        }

        It 'sends cluster targets as a bare array' {
            $null = New-UAPPolicy -name 'Cluster' -targetCategory Clusters -locationType AWS `
                -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ clusterId = 'c1' })
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Body | ConvertFrom-Json).targets[0].clusterId -eq 'c1'
            } -Times 1 -Exactly -Scope It
        }

        It 'sends group targets as a bare array' {
            $null = New-UAPPolicy -name 'Group' -targetCategory Groups -locationType Azure `
                -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ groupId = 'g1' })
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Body | ConvertFrom-Json).targets[0].groupId -eq 'g1'
            } -Times 1 -Exactly -Scope It
        }

        It 'nests database instances under the location and instances properties' {
            $null = New-UAPPolicy -name 'DB' -targetCategory DB -locationType 'FQDN/IP' `
                -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ instanceId = '1' })
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Body | ConvertFrom-Json).targets.'FQDN/IP'.instances.instanceId -eq '1'
            } -Times 1 -Exactly -Scope It
        }

        It 'sends vm targets keyed by location, as the builder shaped them' {
            $null = New-UAPPolicy -name 'VM' -targetCategory VM -locationType AWS `
                -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ AWS = @{ regions = @('us-east-1') } })
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Body | ConvertFrom-Json).targets.AWS.regions -contains 'us-east-1'
            } -Times 1 -Exactly -Scope It
        }

        It 'renders a timeframe in the documented format' {
            $null = New-UAPPolicy -name 'Timed' -targetCategory VM -locationType AWS `
                -fromTime ([datetime]'2026-07-05T12:34:56') -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ AWS = @{ } })
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Body | ConvertFrom-Json).metadata.timeFrame.fromTime -eq '2026-07-05T12:34:56'
            } -Times 1 -Exactly -Scope It
        }

        It 'wraps a supplied status in a status object' {
            $null = New-UAPPolicy -name 'Suspended' -targetCategory VM -locationType AWS -status Suspended `
                -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ AWS = @{ } })
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Body | ConvertFrom-Json).metadata.status.status -eq 'Suspended'
            } -Times 1 -Exactly -Scope It
        }

        It 'omits conditions, behavior and connectionMethod when not supplied' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $Names = ($Body | ConvertFrom-Json).PSObject.Properties.Name
                ($Names -notcontains 'conditions') -and ($Names -notcontains 'behavior') -and ($Names -notcontains 'connectionMethod')
            } -Times 1 -Exactly -Scope It
        }

        It 'sends the connection method for a cluster policy' {
            $null = New-UAPPolicy -name 'Cluster' -targetCategory Clusters -locationType AWS -connectionMethod proxy `
                -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ clusterId = 'c1' })
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Body | ConvertFrom-Json).connectionMethod -eq 'proxy'
            } -Times 1 -Exactly -Scope It
        }

        It 'rejects an unsupported target category' {
            { New-UAPPolicy -name 'x' -targetCategory Nope -locationType AWS -principals ([pscustomobject]@{ id = 'i' }) -targets ([pscustomobject]@{ }) } |
                Should -Throw
        }

        It 'does not send a request when WhatIf is specified' {
            $null = New-UAPPolicy -name 'NotCreated' -targetCategory VM -locationType AWS `
                -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ AWS = @{ } }) -WhatIf
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $Body -match 'NotCreated'
            } -Times 0 -Exactly -Scope It
        }
    }

    Context 'Response' {

        It 'provides output' {
            $Script:response | Should -Not -BeNullOrEmpty
        }

        It 'outputs the new policy id' {
            $Script:response.policyId | Should -Be 'p1'
        }
    }

}
