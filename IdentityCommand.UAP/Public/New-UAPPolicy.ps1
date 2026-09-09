# .ExternalHelp IdentityCommand.UAP-help.xml
function New-UAPPolicy {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateLength(1, 200)]
        [String]$name,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateLength(1, 200)]
        [String]$description,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateSet('Cloud Console', 'VM', 'DB', 'Clusters', 'Groups')]
        [String]$targetCategory,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateSet('AWS', 'Azure', 'GCP', 'FQDN/IP')]
        [String]$locationType,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateSet('Recurring', 'OnDemand')]
        [String]$policyType,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateCount(1, 20)]
        [String[]]$policyTags,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateLength(1, 50)]
        [String]$timeZone,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [datetime]$fromTime,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [datetime]$toTime,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateSet('Active', 'Suspended')]
        [String]$status,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [psobject[]]$principals,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [psobject]$conditions,

        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [psobject]$targets,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [psobject]$behavior,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateSet('direct', 'proxy')]
        [String]$connectionMethod
    )

    begin { }#begin

    process {

        $URI = "$($ISPSSSession.tenant_url)/api/policies"

        $Metadata = [ordered]@{ name = $name }

        if ($PSBoundParameters.ContainsKey('description')) { $Metadata['description'] = $description }
        if ($PSBoundParameters.ContainsKey('status')) { $Metadata['status'] = @{ status = $status } }
        if ($PSBoundParameters.ContainsKey('policyTags')) { $Metadata['policyTags'] = @($policyTags) }

        if ($PSBoundParameters.ContainsKey('fromTime') -or $PSBoundParameters.ContainsKey('toTime')) {

            $TimeFrame = [ordered]@{ }

            #The service documents the timeframe as yyyy-MM-ddTHH:mm:ss
            if ($PSBoundParameters.ContainsKey('fromTime')) { $TimeFrame['fromTime'] = $fromTime.ToString('yyyy-MM-ddTHH:mm:ss') }
            if ($PSBoundParameters.ContainsKey('toTime')) { $TimeFrame['toTime'] = $toTime.ToString('yyyy-MM-ddTHH:mm:ss') }

            $Metadata['timeFrame'] = $TimeFrame

        }

        if ($PSBoundParameters.ContainsKey('timeZone')) { $Metadata['timeZone'] = $timeZone }

        $Entitlement = [ordered]@{ targetCategory = $targetCategory; locationType = $locationType }
        if ($PSBoundParameters.ContainsKey('policyType')) { $Entitlement['policyType'] = $policyType }

        $Metadata['policyEntitlement'] = $Entitlement

        $Policy = [ordered]@{
            metadata   = $Metadata
            principals = @($principals)
            targets    = $(Resolve-UAPTargetShape -targetCategory $targetCategory -targets $targets)
        }

        if ($PSBoundParameters.ContainsKey('conditions')) { $Policy['conditions'] = $conditions }
        if ($PSBoundParameters.ContainsKey('behavior')) { $Policy['behavior'] = $behavior }
        if ($PSBoundParameters.ContainsKey('connectionMethod')) { $Policy['connectionMethod'] = $connectionMethod }

        $body = $Policy | ConvertTo-Json -Depth 12

        if ($PSCmdlet.ShouldProcess($name, 'Create Access Policy')) {

            #Send Request
            Invoke-IDRestMethod -Uri $URI -Method POST -Body $body

        }

    }#process

    end { }#end

}
