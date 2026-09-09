# .ExternalHelp IdentityCommand.UAP-help.xml
function Get-UAPPolicy {
    [CmdletBinding(DefaultParameterSetName = 'byFilterCriteria')]
    param(
        [parameter(
            Mandatory = $true,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byId'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('id')]
        [String]$policyId,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byQuery'
        )]
        [ValidateNotNullOrEmpty()]
        [String]$filter,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byFilterCriteria'
        )]
        [ValidateNotNullOrEmpty()]
        [String[]]$policyTags,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byFilterCriteria'
        )]
        [ValidateNotNullOrEmpty()]
        [String[]]$identities,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byFilterCriteria'
        )]
        [ValidateSet('Cloud Console', 'VM', 'DB', 'Clusters', 'Groups')]
        [String[]]$targetCategory,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byFilterCriteria'
        )]
        [ValidateSet('Active', 'Suspended', 'Expired', 'Validating', 'Error', 'Warning')]
        [String[]]$status,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byFilterCriteria'
        )]
        [ValidateSet('AWS', 'Azure', 'GCP', 'FQDN/IP')]
        [String[]]$locationType,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byQuery'
        )]
        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byFilterCriteria'
        )]
        [ValidateRange(0, 50)]
        [int]$limit,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byQuery'
        )]
        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byFilterCriteria'
        )]
        [ValidateSet('createdBy')]
        [String]$sort,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byQuery'
        )]
        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true,
            ParameterSetName = 'byFilterCriteria'
        )]
        [ValidateLength(1, 200)]
        [String]$q
    )

    begin {

        $FilterField = @('policyTags', 'identities', 'targetCategory', 'status', 'locationType')

    }#begin

    process {

        if ($PSCmdlet.ParameterSetName -eq 'byId') {

            $URI = "$($ISPSSSession.tenant_url)/api/policies/$policyId"

            #Send Request
            Invoke-IDRestMethod -Uri $URI -Method GET

        } else {

            $URI = "$($ISPSSSession.tenant_url)/api/policies"

            $boundParameters = $PSBoundParameters | Get-Parameter -ParametersToRemove $FilterField

            if ($PSCmdlet.ParameterSetName -eq 'byFilterCriteria') {

                $Criteria = [ordered]@{ }

                foreach ($Field in $FilterField) {
                    if ($PSBoundParameters.ContainsKey($Field)) {
                        $Criteria[$Field] = $PSBoundParameters[$Field]
                    }
                }

                if ($Criteria.Count -gt 0) {
                    $boundParameters['filter'] = ConvertTo-UAPFilterString -Filter $Criteria
                }

            }

            $URI = Add-QueryString -URI $URI -Parameter $boundParameters

            #Send Request
            $result = Invoke-IDRestMethod -Uri $URI -Method GET

            if ($null -ne $result) {

                Get-PagedResult -InitialResult $result -URI $URI -Style Cursor -ResultProperty 'results' -CursorRequestKey 'nextToken' -CursorResponseKey 'nextToken'

            }

        }

    }#process

    end { }#end

}
