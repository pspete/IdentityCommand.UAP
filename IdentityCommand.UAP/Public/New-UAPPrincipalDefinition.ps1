# .ExternalHelp IdentityCommand.UAP-help.xml
function New-UAPPrincipalDefinition {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function builds a definition object and does not change state')]
    [CmdletBinding()]
    [OutputType('IdCmd.UAP.Definition.Principal')]
    param(
        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateLength(1, 40)]
        [String]$id,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateLength(1, 512)]
        [String]$name,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateSet('USER', 'ROLE', 'GROUP')]
        [String]$type,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateLength(1, 256)]
        [String]$sourceDirectoryName,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$sourceDirectoryId,

        [parameter(Mandatory = $false)]
        [psobject[]]$PrincipalDefinition
    )

    begin { }#begin

    process {

        if (($type -ne 'ROLE') -and (-not ($PSBoundParameters.ContainsKey('sourceDirectoryName') -and $PSBoundParameters.ContainsKey('sourceDirectoryId')))) {
            throw 'sourceDirectoryName and sourceDirectoryId are required unless the principal type is ROLE'
        }

        $Principal = $PSBoundParameters | Get-Parameter -ParametersToRemove PrincipalDefinition

        $Output = @($PrincipalDefinition) + @([pscustomobject]$Principal) | Where-Object { $null -ne $_ }

        $Output | Add-CustomType -Type 'IdCmd.UAP.Definition.Principal'

    }#process

    end { }#end

}
