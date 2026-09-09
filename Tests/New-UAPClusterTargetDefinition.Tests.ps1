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

Describe 'New-UAPClusterTargetDefinition' {

    Context 'Definition' {

        It 'defines an EKS cluster target' {
            $Target = New-UAPClusterTargetDefinition -roleId 'r' -workspaceId 'w' -clusterId 'c' -scope cluster -region us-east-1
            $Target.clusterId | Should -Be 'c'
            $Target.scope | Should -Be 'cluster'
            $Target.region | Should -Be 'us-east-1'
        }

        It 'applies the expected custom type' {
            (New-UAPClusterTargetDefinition -roleId 'r' -workspaceId 'w' -clusterId 'c' -scope cluster).PSObject.TypeNames |
                Should -Contain 'IdCmd.UAP.Definition.ClusterTarget'
        }

        It 'defines a namespace scoped target' {
            $Target = New-UAPClusterTargetDefinition -roleId 'r' -workspaceId 'w' -clusterId 'c' -scope namespace -namespaceId 'production'
            $Target.namespaceId | Should -Be 'production'
        }

        It 'throws when a namespace scope has no namespace id' {
            { New-UAPClusterTargetDefinition -roleId 'r' -workspaceId 'w' -clusterId 'c' -scope namespace } |
                Should -Throw '*namespaceId is required when scope is namespace*'
        }

        It 'rejects an unsupported scope' {
            { New-UAPClusterTargetDefinition -roleId 'r' -workspaceId 'w' -clusterId 'c' -scope pod } | Should -Throw
        }

        It 'adds a target to an existing definition' {
            $Targets = New-UAPClusterTargetDefinition -roleId 'r' -workspaceId 'w' -clusterId 'c1' -scope cluster
            $Targets = New-UAPClusterTargetDefinition -roleId 'r' -workspaceId 'w' -clusterId 'c2' -scope cluster -TargetDefinition $Targets
            ($Targets | Measure-Object).Count | Should -Be 2
        }

    }

}
