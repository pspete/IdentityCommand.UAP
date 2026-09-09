# .ExternalHelp IdentityCommand.UAP-help.xml
function New-UAPConditionDefinition {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function builds a definition object and does not change state')]
    [CmdletBinding()]
    [OutputType('IdCmd.UAP.Definition.Conditions')]
    param(
        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateRange(0, 6)]
        [int[]]$daysOfTheWeek,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$fromHour,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$toHour,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateRange(1, 24)]
        [int]$maxSessionDuration,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateRange(1, 120)]
        [int]$idleTime,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [switch]$accessApprovalRequired,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateCount(1, 5)]
        [psobject[]]$approvers
    )

    begin { }#begin

    process {

        $Conditions = [ordered]@{ }

        if ($PSBoundParameters.ContainsKey('daysOfTheWeek') -or $PSBoundParameters.ContainsKey('fromHour') -or $PSBoundParameters.ContainsKey('toHour')) {

            if ($accessApprovalRequired) {
                throw 'Omit the access window when access approval is required - the service rejects a payload carrying both'
            }

            $AccessWindow = [ordered]@{ }

            if ($PSBoundParameters.ContainsKey('daysOfTheWeek')) { $AccessWindow['daysOfTheWeek'] = @($daysOfTheWeek) }
            if ($PSBoundParameters.ContainsKey('fromHour')) { $AccessWindow['fromHour'] = $fromHour }
            if ($PSBoundParameters.ContainsKey('toHour')) { $AccessWindow['toHour'] = $toHour }

            $Conditions['accessWindow'] = $AccessWindow

        }

        if ($PSBoundParameters.ContainsKey('maxSessionDuration')) { $Conditions['maxSessionDuration'] = $maxSessionDuration }
        if ($PSBoundParameters.ContainsKey('idleTime')) { $Conditions['idleTime'] = $idleTime }

        if ($PSBoundParameters.ContainsKey('accessApprovalRequired')) {

            $AccessApproval = [ordered]@{ required = $accessApprovalRequired.IsPresent }

            if ($PSBoundParameters.ContainsKey('approvers')) { $AccessApproval['approvers'] = @($approvers) }

            $Conditions['accessApproval'] = $AccessApproval

        }

        [pscustomobject]$Conditions | Add-CustomType -Type 'IdCmd.UAP.Definition.Conditions'

    }#process

    end { }#end

}
