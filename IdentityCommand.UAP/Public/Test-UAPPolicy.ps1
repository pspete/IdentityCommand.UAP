# .ExternalHelp IdentityCommand.UAP-help.xml
function Test-UAPPolicy {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [String]$policyId
    )

    begin { }#begin

    process {

        $URI = "$($ISPSSSession.tenant_url)/api/policies/$policyId/validate"

        if ($PSCmdlet.ShouldProcess($policyId, 'Validate Access Policy')) {

            #Send Request
            Invoke-IDRestMethod -Uri $URI -Method POST

        }

    }#process

    end { }#end

}
