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

Describe 'New-UAPGroupTargetDefinition' {

    Context 'Definition' {

        It 'defines an Entra group target' {
            $Target = New-UAPGroupTargetDefinition -groupId 'g1' -directoryId 'd1'
            $Target.groupId | Should -Be 'g1'
            $Target.directoryId | Should -Be 'd1'
        }

        It 'applies the expected custom type' {
            (New-UAPGroupTargetDefinition -groupId 'g1' -directoryId 'd1').PSObject.TypeNames |
                Should -Contain 'IdCmd.UAP.Definition.GroupTarget'
        }

        It 'adds a target to an existing definition' {
            $Targets = New-UAPGroupTargetDefinition -groupId 'g1' -directoryId 'd1'
            $Targets = New-UAPGroupTargetDefinition -groupId 'g2' -directoryId 'd1' -TargetDefinition $Targets
            ($Targets | Measure-Object).Count | Should -Be 2
        }

    }

}
