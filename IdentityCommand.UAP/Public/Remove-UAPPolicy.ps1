# .ExternalHelp IdentityCommand.UAP-help.xml
function Remove-UAPPolicy {
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

        $URI = "$($ISPSSSession.tenant_url)/api/policies/$policyId"

        if ($PSCmdlet.ShouldProcess($policyId, 'Delete Access Policy')) {

            #Send Request
            Invoke-IDRestMethod -Uri $URI -Method DELETE

        }

    }#process

    end { }#end

}
