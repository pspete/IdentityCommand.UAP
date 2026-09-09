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

        #The policy as the service returns it, including the read-only properties a PUT must not echo
        Mock -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -MockWith {
            [pscustomobject]@{
                metadata                 = [pscustomobject]@{
                    policyId          = 'p1'
                    name              = 'Existing Policy'
                    description       = 'Existing description'
                    status            = [pscustomobject]@{ status = 'Active'; statusCode = '200'; statusDescription = 'ok'; link = 'l' }
                    timeFrame         = [pscustomobject]@{ fromTime = '2026-01-01T00:00:00'; toTime = '2026-12-31T00:00:00' }
                    createdBy         = [pscustomobject]@{ user = 'someone'; time = 'then' }
                    updatedOn         = [pscustomobject]@{ user = 'someone'; time = 'then' }
                    policyTags        = @('existing')
                    timeZone          = 'Europe/London'
                    policyEntitlement = [pscustomobject]@{ targetCategory = 'Cloud Console'; locationType = 'AWS'; policyType = 'Recurring' }
                }
                principals               = @([pscustomobject]@{ id = 'i1'; name = 'existing@example'; type = 'USER' })
                conditions               = [pscustomobject]@{ maxSessionDuration = 1 }
                delegationClassification = 'Unrestricted'
                invalidResources         = [pscustomobject]@{ roles = @() }
                targets                  = [pscustomobject]@{
                    targets = @([pscustomobject]@{ roleId = 'r1'; workspaceId = 'w1'; roleName = 'Display Name'; workspaceName = 'dev'; roleType = 0 })
                }
            }
        } -ParameterFilter { $Method -eq 'GET' }

        Mock -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -MockWith { $null } -ParameterFilter { $Method -eq 'PUT' }

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

        $Script:response = Set-UAPPolicy -policyId 'p1' -status Suspended
    }

    Context 'Request' {

        It 'retrieves the current policy before updating it' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'GET') -and ($URI -eq 'https://somedomain.uap.cyberark.cloud/api/policies/p1')
            } -Times 1 -Exactly -Scope It
        }

        It 'sends the update to expected endpoint' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and ($URI -eq 'https://somedomain.uap.cyberark.cloud/api/policies/p1')
            } -Times 1 -Exactly -Scope It
        }

        It 'sends the policy id in the metadata as well as the path' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and (($Body | ConvertFrom-Json).metadata.policyId -eq 'p1')
            } -Times 1 -Exactly -Scope It
        }

        It 'accepts the policy id from the pipeline by property name' {
            [pscustomobject]@{ policyId = 'p9' } | Set-UAPPolicy -status Suspended
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and ($URI -eq 'https://somedomain.uap.cyberark.cloud/api/policies/p9')
            } -Times 1 -Exactly -Scope It
        }

        It 'does not send a request when WhatIf is specified' {
            $null = Set-UAPPolicy -policyId 'p8' -status Suspended -WhatIf
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and ($URI -match 'p8')
            } -Times 0 -Exactly -Scope It
        }

    }

    Context 'Merge With Current Policy' {

        It 'applies the supplied status' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and (($Body | ConvertFrom-Json).metadata.status.status -eq 'Suspended')
            } -Times 1 -Exactly -Scope It
        }

        It 'keeps the <Property> of the current policy when not supplied' -ForEach @(
            @{ Property = 'name'; Expected = 'Existing Policy' }
            @{ Property = 'description'; Expected = 'Existing description' }
            @{ Property = 'timeZone'; Expected = 'Europe/London' }
        ) {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and (($Body | ConvertFrom-Json).metadata.$Property -eq $Expected)
            } -Times 1 -Exactly -Scope It
        }

        It 'keeps the policy tags of the current policy when not supplied' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and (($Body | ConvertFrom-Json).metadata.policyTags -contains 'existing')
            } -Times 1 -Exactly -Scope It
        }

        It 'keeps the entitlement of the current policy when not supplied' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $Entitlement = ($Body | ConvertFrom-Json).metadata.policyEntitlement
                ($Method -eq 'PUT') -and ($Entitlement.targetCategory -eq 'Cloud Console') -and ($Entitlement.locationType -eq 'AWS')
            } -Times 1 -Exactly -Scope It
        }

        It 'keeps both ends of the current timeframe when neither is supplied' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $TimeFrame = ($Body | ConvertFrom-Json).metadata.timeFrame
                ($Method -eq 'PUT') -and ($TimeFrame.fromTime -eq '2026-01-01T00:00:00') -and ($TimeFrame.toTime -eq '2026-12-31T00:00:00')
            } -Times 1 -Exactly -Scope It
        }

        It 'keeps the principals, conditions and targets of the current policy when not supplied' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $Policy = $Body | ConvertFrom-Json
                ($Method -eq 'PUT') -and
                ($Policy.principals.id -eq 'i1') -and
                ($Policy.conditions.maxSessionDuration -eq 1) -and
                ($Policy.targets.targets.roleId -eq 'r1')
            } -Times 1 -Exactly -Scope It
        }

        It 'replaces the name when supplied' {
            $null = Set-UAPPolicy -policyId 'p1' -name 'Renamed'
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and (($Body | ConvertFrom-Json).metadata.name -eq 'Renamed')
            } -Times 1 -Exactly -Scope It
        }

        It 'replaces the description when supplied' {
            $null = Set-UAPPolicy -policyId 'p1' -description 'New description'
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and (($Body | ConvertFrom-Json).metadata.description -eq 'New description')
            } -Times 1 -Exactly -Scope It
        }

        It 'replaces only the supplied end of the timeframe' {
            $null = Set-UAPPolicy -policyId 'p1' -toTime ([datetime]'2027-06-30T00:00:00')
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $TimeFrame = ($Body | ConvertFrom-Json).metadata.timeFrame
                ($Method -eq 'PUT') -and ($TimeFrame.fromTime -eq '2026-01-01T00:00:00') -and ($TimeFrame.toTime -eq '2027-06-30T00:00:00')
            } -Times 1 -Exactly -Scope It
        }

        It 'replaces the targets when supplied, shaping them for the category' {
            $null = Set-UAPPolicy -policyId 'p1' -targets ([pscustomobject]@{ roleId = 'r2'; workspaceId = 'w2' })
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and (($Body | ConvertFrom-Json).targets.targets.roleId -eq 'r2')
            } -Times 1 -Exactly -Scope It
        }

    }

    Context 'Read Only Properties' {

        It 'does not send the read-only <_> of the current policy' -ForEach @('delegationClassification', 'invalidResources') {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and (($Body | ConvertFrom-Json).PSObject.Properties.Name -notcontains $_)
            } -Times 1 -Exactly -Scope It
        }

        It 'does not send the read-only metadata <_> of the current policy' -ForEach @('createdBy', 'updatedOn') {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and (($Body | ConvertFrom-Json).metadata.PSObject.Properties.Name -notcontains $_)
            } -Times 1 -Exactly -Scope It
        }

        It 'sends the status value without its read-only detail' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $StatusNames = ($Body | ConvertFrom-Json).metadata.status.PSObject.Properties.Name
                ($Method -eq 'PUT') -and ($StatusNames -contains 'status') -and ($StatusNames -notcontains 'statusCode')
            } -Times 1 -Exactly -Scope It
        }

        It 'does not send the resolved display names of a target' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($Method -eq 'PUT') -and $(
                    $TargetNames = @(($Body | ConvertFrom-Json).targets.targets)[0].PSObject.Properties.Name
                    ($TargetNames -contains 'roleId') -and
                    ($TargetNames -notcontains 'roleName') -and ($TargetNames -notcontains 'workspaceName')
                )
            } -Times 1 -Exactly -Scope It
        }

    }

}
