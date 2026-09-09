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

Describe 'New-UAPVirtualMachineBehaviorDefinition' {

    Context 'Definition' {

        It 'defines an ssh username' {
            (New-UAPVirtualMachineBehaviorDefinition -sshUsername 'ec2-user').connectAs.ssh.username | Should -Be 'ec2-user'
        }

        It 'applies the expected custom type' {
            (New-UAPVirtualMachineBehaviorDefinition -sshUsername 'u').PSObject.TypeNames |
                Should -Contain 'IdCmd.UAP.Definition.VirtualMachineBehavior'
        }

        It 'defines rdp ephemeral user groups' {
            $Behavior = New-UAPVirtualMachineBehaviorDefinition -rdpAssignGroups Administrators
            $Behavior.connectAs.rdp.localEphemeralUser.assignGroups | Should -Be @('Administrators')
        }

        It 'defaults ephemeral user reconnect to false' {
            $Behavior = New-UAPVirtualMachineBehaviorDefinition -rdpAssignGroups Administrators
            $Behavior.connectAs.rdp.localEphemeralUser.enableEphemeralUserReconnect | Should -BeFalse
        }

        It 'enables ephemeral user reconnect when specified' {
            $Behavior = New-UAPVirtualMachineBehaviorDefinition -rdpAssignGroups Administrators -enableEphemeralUserReconnect
            $Behavior.connectAs.rdp.localEphemeralUser.enableEphemeralUserReconnect | Should -BeTrue
        }

        It 'omits rdp when no rdp parameters are supplied' {
            (New-UAPVirtualMachineBehaviorDefinition -sshUsername 'u').connectAs.PSObject.Properties.Name | Should -Not -Contain 'rdp'
        }

    }

}
