# .ExternalHelp IdentityCommand.UAP-help.xml
function New-UAPDatabaseTargetDefinition {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function builds a definition object and does not change state')]
    [CmdletBinding()]
    [OutputType('IdCmd.UAP.Definition.DatabaseTarget')]
    param(
        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateLength(1, 256)]
        [String]$instanceName,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateLength(1, 32)]
        [String]$instanceType,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateLength(1, 36)]
        [String]$instanceId,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateSet('ldap_auth', 'db_auth', 'oracle_auth', 'mongo_auth', 'sqlserver_auth', 'rds_iam_user_auth')]
        [String]$authenticationMethod,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [hashtable]$profile,

        [parameter(Mandatory = $false)]
        [psobject[]]$TargetDefinition
    )

    begin { }#begin

    process {

        $Target = $PSBoundParameters | Get-Parameter -ParametersToRemove TargetDefinition

        $Output = @($TargetDefinition) + @([pscustomobject]$Target) | Where-Object { $null -ne $_ }

        $Output | Add-CustomType -Type 'IdCmd.UAP.Definition.DatabaseTarget'

    }#process

    end { }#end

}
