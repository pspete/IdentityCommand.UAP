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

Describe 'New-UAPCloudConsoleTargetDefinition' {

    Context 'Definition' {

        It 'defines an AWS account target' {
            $Target = New-UAPCloudConsoleTargetDefinition -roleId 'arn:aws:iam::123456789123:role/examplerole' -workspaceId '123456789123'
            $Target.roleId | Should -Be 'arn:aws:iam::123456789123:role/examplerole'
            $Target.workspaceId | Should -Be '123456789123'
        }

        It 'applies the expected custom type' {
            (New-UAPCloudConsoleTargetDefinition -roleId 'r' -workspaceId 'w').PSObject.TypeNames |
                Should -Contain 'IdCmd.UAP.Definition.CloudConsoleTarget'
        }

        It 'carries the organization and workspace type when supplied' {
            $Target = New-UAPCloudConsoleTargetDefinition -roleId 'r' -workspaceId 'w' -orgId 'o' -workspaceType subscription
            $Target.orgId | Should -Be 'o'
            $Target.workspaceType | Should -Be 'subscription'
        }

        It 'omits the organization when not supplied' {
            (New-UAPCloudConsoleTargetDefinition -roleId 'r' -workspaceId 'w').PSObject.Properties.Name | Should -Not -Contain 'orgId'
        }

        It 'adds a target to an existing definition' {
            $Targets = New-UAPCloudConsoleTargetDefinition -roleId 'r1' -workspaceId 'w'
            $Targets = New-UAPCloudConsoleTargetDefinition -roleId 'r2' -workspaceId 'w' -TargetDefinition $Targets
            ($Targets | Measure-Object).Count | Should -Be 2
        }

    }

}
