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

Describe 'Set-UAPPolicy' {

    BeforeEach {

        Mock -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -MockWith {
            $null
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

        $Script:response = Set-UAPPolicy -policyId 'p1' -name 'SomePolicy' -targetCategory 'Cloud Console' -locationType AWS -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ roleId = 'r1' })
    }

    Context 'Request' {

        It 'sends request' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -Times 1 -Exactly -Scope It
        }

        It 'sends request to expected endpoint' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $URI -eq 'https://somedomain.uap.cyberark.cloud/api/policies/p1'
            } -Times 1 -Exactly -Scope It
        }

        It 'uses expected method' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $Method -eq 'PUT'
            } -Times 1 -Exactly -Scope It
        }

        It 'sends the policy id in the metadata as well as the path' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Body | ConvertFrom-Json).metadata.policyId -eq 'p1'
            } -Times 1 -Exactly -Scope It
        }

        It 'accepts the policy id from the pipeline by property name' {
            [pscustomobject]@{ policyId = 'p9' } | Set-UAPPolicy -name 'Other' -targetCategory VM -locationType AWS `
                -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ AWS = @{ } })
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $URI -eq 'https://somedomain.uap.cyberark.cloud/api/policies/p9'
            } -Times 1 -Exactly -Scope It
        }

        It 'does not send a request when WhatIf is specified' {
            $null = Set-UAPPolicy -policyId 'p8' -name 'NotUpdated' -targetCategory VM -locationType AWS `
                -principals ([pscustomobject]@{ id = 'i1' }) -targets ([pscustomobject]@{ AWS = @{ } }) -WhatIf
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $URI -match 'p8'
            } -Times 0 -Exactly -Scope It
        }
    }

}
