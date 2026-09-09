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

Describe 'New-UAPPrincipalDefinition' {

    Context 'Definition' {

        It 'defines a user principal' {
            $Principal = New-UAPPrincipalDefinition -id 'i1' -name 'user@example' -type USER -sourceDirectoryName 'Some Directory' -sourceDirectoryId 'd1'
            $Principal.id | Should -Be 'i1'
            $Principal.type | Should -Be 'USER'
            $Principal.sourceDirectoryId | Should -Be 'd1'
        }

        It 'applies the expected custom type' {
            $Principal = New-UAPPrincipalDefinition -id 'i1' -name 'n' -type ROLE
            $Principal.PSObject.TypeNames | Should -Contain 'IdCmd.UAP.Definition.Principal'
        }

        It 'allows a role without a source directory' {
            { New-UAPPrincipalDefinition -id 'i1' -name 'Admin Role' -type ROLE } | Should -Not -Throw
        }

        It 'requires a source directory for a <_> principal' -ForEach @('USER', 'GROUP') {
            { New-UAPPrincipalDefinition -id 'i1' -name 'n' -type $_ } | Should -Throw '*sourceDirectoryName and sourceDirectoryId are required*'
        }

        It 'adds a principal to an existing definition' {
            $Principals = New-UAPPrincipalDefinition -id 'i1' -name 'n1' -type ROLE
            $Principals = New-UAPPrincipalDefinition -id 'i2' -name 'n2' -type ROLE -PrincipalDefinition $Principals
            ($Principals | Measure-Object).Count | Should -Be 2
            $Principals[1].id | Should -Be 'i2'
        }

        It 'rejects an unsupported principal type' {
            { New-UAPPrincipalDefinition -id 'i1' -name 'n' -type SERVICE } | Should -Throw
        }

    }

}
