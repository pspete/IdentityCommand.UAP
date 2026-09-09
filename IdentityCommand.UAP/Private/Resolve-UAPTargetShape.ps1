function Resolve-UAPTargetShape {
    <#
    .SYNOPSIS
    Places policy targets in the shape their target category expects.

    .DESCRIPTION
    The service carries targets differently for each target category, so the builders emit plain
    target entries and this helper wraps them once, in one place:

        Cloud Console  { "targets": [ ... ] }
        Clusters       [ ... ]
        Groups         [ ... ]
        DB             { "FQDN/IP": { "instances": [ ... ] } }
        VM             { "AWS": { ... } }   - already shaped by New-UAPVirtualMachineTargetDefinition

    Targets which are already in their final shape are returned unaltered, so a hand-built payload
    passes through untouched.

    .PARAMETER targetCategory
    The policy's target category.

    .PARAMETER targets
    The targets to shape, as returned by the New-UAP*TargetDefinition builders.

    .EXAMPLE
    Resolve-UAPTargetShape -targetCategory 'Cloud Console' -targets $Targets

    .OUTPUTS
    The targets, wrapped as the target category requires.
    #>
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [string]$targetCategory,

        [parameter(Mandatory = $true)]
        [AllowNull()]
        $targets
    )

    switch ($targetCategory) {

        'Cloud Console' {

            #Every documented cloud console example nests the array under a targets property, which
            #the schema does not show. The examples are consistent across create, edit and get.
            if ($targets.PSObject.Properties.Name -contains 'targets') {
                $targets
            } else {
                [ordered]@{ targets = @($targets) }
            }

            break

        }

        'DB' {

            if ($targets.PSObject.Properties.Name -contains 'FQDN/IP') {
                $targets
            } else {
                [ordered]@{ 'FQDN/IP' = [ordered]@{ instances = @($targets) } }
            }

            break

        }

        { $_ -in 'Clusters', 'Groups' } {

            @($targets)
            break

        }

        default {

            #VM targets are keyed by location, and the builder emits that object whole
            $targets

        }

    }

}
