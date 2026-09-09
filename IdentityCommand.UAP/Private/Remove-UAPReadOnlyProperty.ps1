function Remove-UAPReadOnlyProperty {
    <#
    .SYNOPSIS
    Strips the read-only properties from a retrieved access policy.

    .DESCRIPTION
    A policy retrieved with GET carries properties the service populates and marks read-only - who
    created it, the display names resolved for each target, the status code behind its status, and the
    invalid resources behind an error. Set-UAPPolicy re-sends the retrieved policy as the fallback for
    whatever the caller did not supply, so those properties are removed first rather than echoed back.

    The policy's status is kept, since a policy is suspended and reactivated through it; the read-only
    detail alongside it is not.

    .PARAMETER Policy
    The policy as returned by Get-UAPPolicy.

    .EXAMPLE
    $Existing = Get-UAPPolicy -policyId $policyId | Remove-UAPReadOnlyProperty

    .OUTPUTS
    The policy, without its read-only properties.
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function returns a filtered copy of its input and does not change state')]
    [CmdletBinding()]
    param(
        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [psobject]$Policy
    )

    begin {

        #Read-only on the policy itself. delegationClassification is marked read-only by the schema,
        #though the service's own edit examples send it back.
        $PolicyProperty = @('delegationClassification', 'invalidResources')

        #Read-only on the metadata. The examples name the update stamp inconsistently, so both spellings go.
        $MetadataProperty = @('createdBy', 'updatedBy', 'updatedOn')

        #Display names and types the service resolves for each target from the ids given
        $TargetProperty = @(
            'roleName'
            'roleType'
            'rolePackage'
            'workspaceName'
            'clusterName'
            'namespaceName'
            'groupName'
            'groupType'
            'directoryName'
            'description'
        )

        $Strip = {
            param($Object, $Names)

            if ($null -eq $Object) { return $null }

            $Kept = [ordered]@{ }

            foreach ($Property in $Object.PSObject.Properties) {
                if ($Property.Name -notin $Names) {
                    $Kept[$Property.Name] = $Property.Value
                }
            }

            [pscustomobject]$Kept

        }

    }#begin

    process {

        $Clean = & $Strip $Policy $PolicyProperty

        if ($null -ne $Clean.metadata) {

            $Metadata = & $Strip $Clean.metadata $MetadataProperty

            if ($null -ne $Metadata.status) {
                $Metadata.status = [pscustomobject]@{ status = $Metadata.status.status }
            }

            $Clean.metadata = $Metadata

        }

        if ($null -ne $Clean.targets) {

            #Cloud console policies nest their targets, clusters and groups hold a bare array, and
            #VM/DB targets are keyed objects whose entries are not per-target records
            if ($Clean.targets -is [System.Collections.IEnumerable] -and $Clean.targets -isnot [string]) {

                $Clean.targets = @($Clean.targets | ForEach-Object { & $Strip $_ $TargetProperty })

            } elseif ($null -ne $Clean.targets.targets) {

                $Clean.targets = [pscustomobject]@{
                    targets = @($Clean.targets.targets | ForEach-Object { & $Strip $_ $TargetProperty })
                }

            }

        }

        $Clean

    }#process

    end { }#end

}
