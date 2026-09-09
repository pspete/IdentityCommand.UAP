# .ExternalHelp IdentityCommand.UAP-help.xml
function New-UAPCloudConsoleTargetDefinition {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function builds a definition object and does not change state')]
    [CmdletBinding()]
    [OutputType('IdCmd.UAP.Definition.CloudConsoleTarget')]
    param(
        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$roleId,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$workspaceId,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$orgId,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$workspaceType,

        [parameter(Mandatory = $false)]
        [psobject[]]$TargetDefinition
    )

    begin { }#begin

    process {

        $Target = $PSBoundParameters | Get-Parameter -ParametersToRemove TargetDefinition

        $Output = @($TargetDefinition) + @([pscustomobject]$Target) | Where-Object { $null -ne $_ }

        $Output | Add-CustomType -Type 'IdCmd.UAP.Definition.CloudConsoleTarget'

    }#process

    end { }#end

}
