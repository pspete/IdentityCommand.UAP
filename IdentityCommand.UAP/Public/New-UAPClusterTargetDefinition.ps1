# .ExternalHelp IdentityCommand.UAP-help.xml
function New-UAPClusterTargetDefinition {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function builds a definition object and does not change state')]
    [CmdletBinding()]
    [OutputType('IdCmd.UAP.Definition.ClusterTarget')]
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
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$clusterId,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateSet('cluster', 'namespace')]
        [String]$scope,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$namespaceId,

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

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$region,

        [parameter(Mandatory = $false)]
        [psobject[]]$TargetDefinition
    )

    begin { }#begin

    process {

        if (($scope -eq 'namespace') -and (-not $PSBoundParameters.ContainsKey('namespaceId'))) {
            throw 'namespaceId is required when scope is namespace'
        }

        $Target = $PSBoundParameters | Get-Parameter -ParametersToRemove TargetDefinition

        $Output = @($TargetDefinition) + @([pscustomobject]$Target) | Where-Object { $null -ne $_ }

        $Output | Add-CustomType -Type 'IdCmd.UAP.Definition.ClusterTarget'

    }#process

    end { }#end

}
