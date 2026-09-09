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

Describe 'New-UAPVirtualMachineTargetDefinition' {

    Context 'Definition' {

        It 'defines AWS targets keyed by location' {
            $Target = New-UAPVirtualMachineTargetDefinition -AWS -regions us-east-1 -accountIds '123456789012'
            $Target.AWS.regions | Should -Be @('us-east-1')
            $Target.AWS.accountIds | Should -Be @('123456789012')
        }

        It 'applies the expected custom type' {
            (New-UAPVirtualMachineTargetDefinition -AWS).PSObject.TypeNames | Should -Contain 'IdCmd.UAP.Definition.VirtualMachineTarget'
        }

        It 'defines Azure targets' {
            $Target = New-UAPVirtualMachineTargetDefinition -Azure -subscriptions 'sub1' -resourceGroups 'rg1'
            $Target.Azure.subscriptions | Should -Be @('sub1')
        }

        It 'defines GCP targets with labels' {
            $Target = New-UAPVirtualMachineTargetDefinition -GCP -projects 'p1' -labels @{ key = 'env'; value = @('prod') }
            $Target.GCP.projects | Should -Be @('p1')
            $Target.GCP.labels.key | Should -Be 'env'
        }

        It 'keys on-premise targets as FQDN/IP' {
            $Target = New-UAPVirtualMachineTargetDefinition -FQDNIP -fqdnRules @{ operator = 'SUFFIX'; computernamePattern = 'prod' }
            $Target.'FQDN/IP'.fqdnRules.operator | Should -Be 'SUFFIX'
        }

        It 'adds a location to an existing definition' {
            $Target = New-UAPVirtualMachineTargetDefinition -AWS -regions us-east-1
            $Target = New-UAPVirtualMachineTargetDefinition -Azure -subscriptions 'sub1' -TargetDefinition $Target
            $Target.AWS.regions | Should -Be @('us-east-1')
            $Target.Azure.subscriptions | Should -Be @('sub1')
        }

        It 'does not carry the location switch into the target body' {
            (New-UAPVirtualMachineTargetDefinition -AWS -regions us-east-1).AWS.Keys | Should -Not -Contain 'AWS'
        }

        It 'does not accept an Azure only parameter with AWS' {
            { New-UAPVirtualMachineTargetDefinition -AWS -subscriptions 'sub1' } | Should -Throw
        }

    }

}
