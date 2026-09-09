# .ExternalHelp IdentityCommand.UAP-help.xml
function New-UAPVirtualMachineTargetDefinition {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function builds a definition object and does not change state')]
    [CmdletBinding(DefaultParameterSetName = 'AWS')]
    [OutputType('IdCmd.UAP.Definition.VirtualMachineTarget')]
    param(
        [parameter(Mandatory = $true, ParameterSetName = 'AWS')]
        [switch]$AWS,

        [parameter(Mandatory = $true, ParameterSetName = 'Azure')]
        [switch]$Azure,

        [parameter(Mandatory = $true, ParameterSetName = 'GCP')]
        [switch]$GCP,

        [parameter(Mandatory = $true, ParameterSetName = 'FQDNIP')]
        [switch]$FQDNIP,

        [parameter(Mandatory = $false, ParameterSetName = 'AWS')]
        [parameter(Mandatory = $false, ParameterSetName = 'Azure')]
        [parameter(Mandatory = $false, ParameterSetName = 'GCP')]
        [String[]]$regions,

        [parameter(Mandatory = $false, ParameterSetName = 'AWS')]
        [parameter(Mandatory = $false, ParameterSetName = 'Azure')]
        [hashtable[]]$tags,

        [parameter(Mandatory = $false, ParameterSetName = 'GCP')]
        [hashtable[]]$labels,

        [parameter(Mandatory = $false, ParameterSetName = 'AWS')]
        [parameter(Mandatory = $false, ParameterSetName = 'GCP')]
        [String[]]$vpcIds,

        [parameter(Mandatory = $false, ParameterSetName = 'AWS')]
        [String[]]$accountIds,

        [parameter(Mandatory = $false, ParameterSetName = 'Azure')]
        [String[]]$vnetIds,

        [parameter(Mandatory = $false, ParameterSetName = 'Azure')]
        [String[]]$resourceGroups,

        [parameter(Mandatory = $false, ParameterSetName = 'Azure')]
        [String[]]$subscriptions,

        [parameter(Mandatory = $false, ParameterSetName = 'GCP')]
        [String[]]$projects,

        [parameter(Mandatory = $false, ParameterSetName = 'FQDNIP')]
        [hashtable[]]$fqdnRules,

        [parameter(Mandatory = $false, ParameterSetName = 'FQDNIP')]
        [hashtable[]]$ipRules,

        [parameter(Mandatory = $false)]
        [psobject]$TargetDefinition
    )

    begin { }#begin

    process {

        $Location = if ($PSCmdlet.ParameterSetName -eq 'FQDNIP') { 'FQDN/IP' } else { $PSCmdlet.ParameterSetName }

        $Target = $PSBoundParameters | Get-Parameter -ParametersToRemove AWS, Azure, GCP, FQDNIP, TargetDefinition

        #Each location is a property of a single targets object, so an existing definition is
        #carried forward rather than replaced
        $Output = [ordered]@{ }

        if ($PSBoundParameters.ContainsKey('TargetDefinition')) {
            foreach ($Property in $TargetDefinition.PSObject.Properties) {
                $Output[$Property.Name] = $Property.Value
            }
        }

        $Output[$Location] = $Target

        [pscustomobject]$Output | Add-CustomType -Type 'IdCmd.UAP.Definition.VirtualMachineTarget'

    }#process

    end { }#end

}
