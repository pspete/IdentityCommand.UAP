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

Describe 'Test-UAPPolicy' {

    BeforeEach {

        Mock -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -MockWith {
            [pscustomobject]@{ status = 'VALIDATING' }
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

        $Script:response = Test-UAPPolicy -policyId 'p1'
    }

    Context 'Request' {

        It 'sends request' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -Times 1 -Exactly -Scope It
        }

        It 'sends request to expected endpoint' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $URI -eq 'https://somedomain.uap.cyberark.cloud/api/policies/p1/validate'
            } -Times 1 -Exactly -Scope It
        }

        It 'uses expected method' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $Method -eq 'POST'
            } -Times 1 -Exactly -Scope It
        }

        It 'sends request with no body' {
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $null -eq $Body
            } -Times 1 -Exactly -Scope It
        }

        It 'accepts the policy id from the pipeline by property name' {
            [pscustomobject]@{ policyId = 'p9' } | Test-UAPPolicy
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $URI -eq 'https://somedomain.uap.cyberark.cloud/api/policies/p9/validate'
            } -Times 1 -Exactly -Scope It
        }

        It 'does not send a request when WhatIf is specified' {
            $null = Test-UAPPolicy -policyId 'p8' -WhatIf
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $URI -match 'p8'
            } -Times 0 -Exactly -Scope It
        }
    }

    Context 'Response' {

        It 'provides output' {
            $Script:response | Should -Not -BeNullOrEmpty
        }

        It 'reports that validation has started' {
            $Script:response.status | Should -Be 'VALIDATING'
        }
    }

}
