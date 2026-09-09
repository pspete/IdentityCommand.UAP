# .ExternalHelp IdentityCommand.UAP-help.xml
function New-UAPGroupTargetDefinition {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function builds a definition object and does not change state')]
    [CmdletBinding()]
    [OutputType('IdCmd.UAP.Definition.GroupTarget')]
    param(
        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$groupId,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$directoryId,

        [parameter(Mandatory = $false)]
        [psobject[]]$TargetDefinition
    )

    begin { }#begin

    process {

        $Target = $PSBoundParameters | Get-Parameter -ParametersToRemove TargetDefinition

        $Output = @($TargetDefinition) + @([pscustomobject]$Target) | Where-Object { $null -ne $_ }

        $Output | Add-CustomType -Type 'IdCmd.UAP.Definition.GroupTarget'

    }#process

    end { }#end

}
