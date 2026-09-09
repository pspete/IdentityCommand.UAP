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

Describe 'ConvertTo-UAPFilterString' {

    InModuleScope 'IdentityCommand.UAP' {

        Context 'Assembly' {

            It 'forms a single clause' {
                ConvertTo-UAPFilterString -Filter @{ targetCategory = 'VM' } | Should -Be "(targetCategory eq 'VM')"
            }

            It 'combines several values for one field with or' {
                ConvertTo-UAPFilterString -Filter @{ locationType = @('AWS', 'Azure') } |
                    Should -Be "((locationType eq 'AWS') or (locationType eq 'Azure'))"
            }

            It 'combines separate fields with and' {
                ConvertTo-UAPFilterString -Filter ([ordered]@{ targetCategory = 'VM'; status = 'Active' }) |
                    Should -Be "((targetCategory eq 'VM') and (status eq 'Active'))"
            }

            It 'compares identities with contains' {
                ConvertTo-UAPFilterString -Filter @{ identities = 'identity1234' } |
                    Should -Be "(identities contains 'identity1234')"
            }

            It 'quotes every value' {
                ConvertTo-UAPFilterString -Filter @{ policyTags = 'plain' } | Should -Be "(policyTags eq 'plain')"
            }

            It 'reproduces the documented filter example' {
                ConvertTo-UAPFilterString -Filter ([ordered]@{
                        policyTags     = @('a', 'b', 'c')
                        identities     = @('identity1234')
                        targetCategory = @('VM')
                        status         = @('suspend', 'active')
                        locationType   = @('Azure', 'GCP')
                    }) |
                    Should -Be "(((policyTags eq 'a') or (policyTags eq 'b') or (policyTags eq 'c')) and (identities contains 'identity1234') and (targetCategory eq 'VM') and ((status eq 'suspend') or (status eq 'active')) and ((locationType eq 'Azure') or (locationType eq 'GCP')))"
            }

            It 'balances its parentheses' {
                $Expression = ConvertTo-UAPFilterString -Filter ([ordered]@{ policyTags = @('a', 'b'); status = 'Active' })
                ($Expression.ToCharArray() | Where-Object { $_ -eq '(' }).Count |
                    Should -Be ($Expression.ToCharArray() | Where-Object { $_ -eq ')' }).Count
            }

            It 'does not url encode the expression' {
                ConvertTo-UAPFilterString -Filter @{ identities = 'user@example.com' } | Should -Not -Match '%'
            }

            It 'returns nothing when no values are given' {
                ConvertTo-UAPFilterString -Filter @{ policyTags = @() } | Should -BeNullOrEmpty
            }

            It 'skips an empty value' {
                ConvertTo-UAPFilterString -Filter ([ordered]@{ policyTags = @('a', ''); status = 'Active' }) |
                    Should -Be "((policyTags eq 'a') and (status eq 'Active'))"
            }

        }

        Context 'Input Validation' {

            It 'throws for a field the service does not filter on' {
                { ConvertTo-UAPFilterString -Filter @{ createdBy = 'someone' } } |
                    Should -Throw '*is not a filterable field of the Access Control Policies service*'
            }

        }

    }

}
