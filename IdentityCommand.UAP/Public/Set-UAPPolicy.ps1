# .ExternalHelp IdentityCommand.UAP-help.xml
function Set-UAPPolicy {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [String]$policyId,

        [parameter(
            Mandatory = $false,
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
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateSet('Cloud Console', 'VM', 'DB', 'Clusters', 'Groups')]
        [String]$targetCategory,

        [parameter(
            Mandatory = $false,
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
            Mandatory = $false,
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
            Mandatory = $false,
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

        $URI = "$($ISPSSSession.tenant_url)/api/policies/$policyId"

        #The service replaces the policy with the payload sent, so the current policy provides
        #whatever the caller did not supply. Its read-only properties are dropped rather than echoed.
        $Existing = Get-UAPPolicy -policyId $policyId | Remove-UAPReadOnlyProperty

        if ($null -eq $Existing) {
            throw "Policy '$policyId' was not found, so there is no policy to update"
        }

        $boundParameters = $PSBoundParameters | Get-Parameter -ParametersToRemove policyId

        #Metadata: the flat properties merge directly against the current policy's metadata
        $Metadata = Merge-Parameter -Template ([ordered]@{
                policyId   = $policyId
                name       = $null
                description = $null
                policyTags = $null
                timeZone   = $null
            }) -BoundParameter $boundParameters -Fallback $Existing.metadata

        $Metadata['policyId'] = $policyId

        #Status travels as an object, and only its status value is writable
        $CurrentStatus = if ($PSBoundParameters.ContainsKey('status')) { $status } else { $Existing.metadata.status.status }
        if (-not [string]::IsNullOrEmpty($CurrentStatus)) {
            $Metadata['status'] = [ordered]@{ status = $CurrentStatus }
        }

        #The timeframe is a nested object, so each end falls back to the current policy's own value
        $TimeFrame = [ordered]@{ }

        foreach ($Bound in @{ Name = 'fromTime'; Value = $fromTime }, @{ Name = 'toTime'; Value = $toTime }) {

            if ($PSBoundParameters.ContainsKey($Bound.Name)) {
                #The service documents the timeframe as yyyy-MM-ddTHH:mm:ss
                $TimeFrame[$Bound.Name] = $Bound.Value.ToString('yyyy-MM-ddTHH:mm:ss')
            } elseif ($null -ne $Existing.metadata.timeFrame.$($Bound.Name)) {
                $TimeFrame[$Bound.Name] = $Existing.metadata.timeFrame.$($Bound.Name)
            }

        }

        if ($TimeFrame.Count -gt 0) {
            $Metadata['timeFrame'] = $TimeFrame
        }

        $Metadata['policyEntitlement'] = Merge-Parameter -Template ([ordered]@{
                targetCategory = $null
                locationType   = $null
                policyType     = $null
            }) -BoundParameter $boundParameters -Fallback $Existing.metadata.policyEntitlement

        #Top level properties merge against the policy itself
        $Policy = Merge-Parameter -Template ([ordered]@{
                principals       = $null
                conditions       = $null
                behavior         = $null
                connectionMethod = $null
            }) -BoundParameter $boundParameters -Fallback $Existing

        $Policy.Insert(0, 'metadata', $Metadata)

        #Targets retrieved from the service are already in their final shape; targets supplied by the
        #caller come from a builder and are shaped here
        $Category = $Metadata['policyEntitlement']['targetCategory']
        $PolicyTargets = if ($PSBoundParameters.ContainsKey('targets')) { $targets } else { $Existing.targets }

        $Policy['targets'] = Resolve-UAPTargetShape -targetCategory $Category -targets $PolicyTargets

        #Drop anything neither supplied nor held by the current policy
        foreach ($Key in @($Policy.Keys)) {
            if ($null -eq $Policy[$Key]) {
                $Policy.Remove($Key)
            }
        }

        foreach ($Key in @($Metadata.Keys)) {
            if ($null -eq $Metadata[$Key]) {
                $Metadata.Remove($Key)
            }
        }

        $body = $Policy | ConvertTo-Json -Depth 12

        if ($PSCmdlet.ShouldProcess($policyId, 'Update Access Policy')) {

            #Send Request
            Invoke-IDRestMethod -Uri $URI -Method PUT -Body $body

        }

    }#process

    end { }#end

}
