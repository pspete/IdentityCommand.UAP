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

Describe 'New-UAPDatabaseTargetDefinition' {

    Context 'Definition' {

        It 'defines a database instance target' {
            $Target = New-UAPDatabaseTargetDefinition -instanceName 'My-MySQL' -instanceType MySQL -instanceId '197012' `
                -authenticationMethod db_auth -profile @{ roles = @('hr') }
            $Target.instanceName | Should -Be 'My-MySQL'
            $Target.authenticationMethod | Should -Be 'db_auth'
            $Target.profile.roles | Should -Be @('hr')
        }

        It 'applies the expected custom type' {
            $Target = New-UAPDatabaseTargetDefinition -instanceName 'n' -instanceType MySQL -instanceId '1' -authenticationMethod db_auth -profile @{ roles = @('r') }
            $Target.PSObject.TypeNames | Should -Contain 'IdCmd.UAP.Definition.DatabaseTarget'
        }

        It 'rejects an unsupported authentication method' {
            { New-UAPDatabaseTargetDefinition -instanceName 'n' -instanceType MySQL -instanceId '1' -authenticationMethod kerberos -profile @{ } } |
                Should -Throw
        }

        It 'adds an instance to an existing definition' {
            $Targets = New-UAPDatabaseTargetDefinition -instanceName 'n1' -instanceType MySQL -instanceId '1' -authenticationMethod db_auth -profile @{ roles = @('r') }
            $Targets = New-UAPDatabaseTargetDefinition -instanceName 'n2' -instanceType Oracle -instanceId '2' -authenticationMethod oracle_auth -profile @{ roles = @('r') } -TargetDefinition $Targets
            ($Targets | Measure-Object).Count | Should -Be 2
        }

    }

}
