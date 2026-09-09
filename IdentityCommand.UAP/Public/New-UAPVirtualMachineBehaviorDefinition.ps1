# .ExternalHelp IdentityCommand.UAP-help.xml
function New-UAPVirtualMachineBehaviorDefinition {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Function builds a definition object and does not change state')]
    [CmdletBinding()]
    [OutputType('IdCmd.UAP.Definition.VirtualMachineBehavior')]
    param(
        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String]$sshUsername,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String[]]$rdpAssignGroups,

        [parameter(
            Mandatory = $false,
            ValueFromPipelinebyPropertyName = $true
        )]
        [switch]$enableEphemeralUserReconnect
    )

    begin { }#begin

    process {

        $ConnectAs = [ordered]@{ }

        if ($PSBoundParameters.ContainsKey('sshUsername')) {
            $ConnectAs['ssh'] = @{ username = $sshUsername }
        }

        if ($PSBoundParameters.ContainsKey('rdpAssignGroups') -or $PSBoundParameters.ContainsKey('enableEphemeralUserReconnect')) {

            $EphemeralUser = [ordered]@{ }

            if ($PSBoundParameters.ContainsKey('rdpAssignGroups')) { $EphemeralUser['assignGroups'] = @($rdpAssignGroups) }

            $EphemeralUser['enableEphemeralUserReconnect'] = $enableEphemeralUserReconnect.IsPresent

            $ConnectAs['rdp'] = @{ localEphemeralUser = $EphemeralUser }

        }

        [pscustomobject]@{ connectAs = $ConnectAs } | Add-CustomType -Type 'IdCmd.UAP.Definition.VirtualMachineBehavior'

    }#process

    end { }#end

}
