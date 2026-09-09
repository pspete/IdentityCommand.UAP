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

Describe 'New-UAPConditionDefinition' {

    Context 'Definition' {

        It 'defines an access window' {
            $Conditions = New-UAPConditionDefinition -daysOfTheWeek 1, 2 -fromHour '08:00:00' -toHour '17:00:00'
            $Conditions.accessWindow.daysOfTheWeek | Should -Be @(1, 2)
            $Conditions.accessWindow.fromHour | Should -Be '08:00:00'
        }

        It 'defines session limits' {
            $Conditions = New-UAPConditionDefinition -maxSessionDuration 2 -idleTime 10
            $Conditions.maxSessionDuration | Should -Be 2
            $Conditions.idleTime | Should -Be 10
        }

        It 'applies the expected custom type' {
            (New-UAPConditionDefinition -maxSessionDuration 1).PSObject.TypeNames | Should -Contain 'IdCmd.UAP.Definition.Conditions'
        }

        It 'omits the access window when none of its parts are supplied' {
            (New-UAPConditionDefinition -maxSessionDuration 1).PSObject.Properties.Name | Should -Not -Contain 'accessWindow'
        }

        It 'defines access approval' {
            $Conditions = New-UAPConditionDefinition -maxSessionDuration 1 -accessApprovalRequired
            $Conditions.accessApproval.required | Should -BeTrue
        }

        It 'carries the approvers when supplied' {
            $Conditions = New-UAPConditionDefinition -accessApprovalRequired -approvers ([pscustomobject]@{ id = 'a1' })
            $Conditions.accessApproval.approvers[0].id | Should -Be 'a1'
        }

        It 'throws when an access window is combined with access approval' {
            { New-UAPConditionDefinition -daysOfTheWeek 1 -accessApprovalRequired } |
                Should -Throw '*Omit the access window when access approval is required*'
        }

        It 'rejects a day outside the week' {
            { New-UAPConditionDefinition -daysOfTheWeek 7 } | Should -Throw
        }

        It 'rejects a session duration above the documented maximum' {
            { New-UAPConditionDefinition -maxSessionDuration 25 } | Should -Throw
        }

    }

}
