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

Describe 'Get-UAPPolicy' {

    BeforeEach {

        Mock -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -MockWith {
            [pscustomobject]@{
                'results'   = @([pscustomobject]@{ metadata = [pscustomobject]@{ policyId = 'p1'; name = 'SomePolicy' } })
                'nextToken' = $null
                'total'     = 1
            }
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

        $Script:response = Get-UAPPolicy
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
                $Method -eq 'GET'
            } -Times 1 -Exactly -Scope It
        }

        It 'requests a single policy by id' {
            $null = Get-UAPPolicy -policyId 'p1'
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                $URI -eq 'https://somedomain.uap.cyberark.cloud/api/policies/p1'
            } -Times 1 -Exactly -Scope It
        }

        It 'passes a supplied filter expression through unaltered' {
            $null = Get-UAPPolicy -filter "(targetCategory eq 'VM')"
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                [uri]::UnescapeDataString($URI) -match "filter=\(targetCategory eq 'VM'\)"
            } -Times 1 -Exactly -Scope It
        }

        It 'builds a filter expression from a single criterion' {
            $null = Get-UAPPolicy -targetCategory VM
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                [uri]::UnescapeDataString($URI) -match "filter=\(targetCategory eq 'VM'\)"
            } -Times 1 -Exactly -Scope It
        }

        It 'combines several values for one field with or' {
            $null = Get-UAPPolicy -locationType AWS, Azure
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                [uri]::UnescapeDataString($URI) -match "\(\(locationType eq 'AWS'\) or \(locationType eq 'Azure'\)\)"
            } -Times 1 -Exactly -Scope It
        }

        It 'combines separate fields with and' {
            $null = Get-UAPPolicy -targetCategory VM -status Active
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                [uri]::UnescapeDataString($URI) -match "\(\(targetCategory eq 'VM'\) and \(status eq 'Active'\)\)"
            } -Times 1 -Exactly -Scope It
        }

        It 'compares identities with contains' {
            $null = Get-UAPPolicy -identities 'identity1234'
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                [uri]::UnescapeDataString($URI) -match "identities contains 'identity1234'"
            } -Times 1 -Exactly -Scope It
        }

        It 'does not send the filter criteria as query parameters of their own' {
            $null = Get-UAPPolicy -targetCategory VM
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($URI -match 'filter=') -and ($URI -notmatch 'targetCategory=')
            } -Times 1 -Exactly -Scope It
        }

        It 'sends paging and search parameters in the query string' {
            $null = Get-UAPPolicy -limit 50 -sort createdBy -q 'access to production'
            Should -Invoke -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -ParameterFilter {
                ($URI -match 'limit=50') -and ($URI -match 'sort=createdBy')
            } -Times 1 -Exactly -Scope It
        }

        It 'rejects a limit above the documented maximum' {
            { Get-UAPPolicy -limit 51 } | Should -Throw
        }

        It 'does not accept a filter expression alongside filter criteria' {
            { Get-UAPPolicy -filter '(a eq 1)' -targetCategory VM } | Should -Throw
        }
    }

    Context 'Response' {

        It 'provides output' {
            $Script:response | Should -Not -BeNullOrEmpty
        }

        It 'outputs the results of the response' {
            $Script:response.metadata.name | Should -Be 'SomePolicy'
        }

        It 'follows the continuation token until it is empty' {
            Mock -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -MockWith {
                [pscustomobject]@{ 'results' = @([pscustomobject]@{ name = 'Second' }); 'nextToken' = $null; 'total' = 2 }
            } -ParameterFilter { $URI -match 'nextToken=' }

            Mock -CommandName Invoke-IDRestMethod -ModuleName $Script:UAPModuleName -MockWith {
                [pscustomobject]@{ 'results' = @([pscustomobject]@{ name = 'First' }); 'nextToken' = 'DS1_10'; 'total' = 2 }
            } -ParameterFilter { $URI -notmatch 'nextToken=' }

            (Get-UAPPolicy | Measure-Object).Count | Should -Be 2
        }
    }

}
