# Change Log

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- Initial release of `IdentityCommand.UAP`, wrapping the CyberArk Access Control Policies API.
- `Connect-UAPTenant`: authenticate to the Access Control Policies service, resolving the service url
  from a shared services subdomain via platform discovery, or from a url supplied directly.
- `Get-UAPPolicy`: get a single policy by id, or a filtered list. Filter criteria (`-policyTags`,
  `-identities`, `-targetCategory`, `-status`, `-locationType`) are assembled into the service's
  filter expression; `-filter` takes an expression directly. Results are paginated automatically.
- `New-UAPPolicy`, `Remove-UAPPolicy`: create and delete access policies for cloud consoles, virtual
  machines, databases, Kubernetes clusters and Entra ID groups.
- `Set-UAPPolicy`: update an access policy. The service replaces the policy with the payload sent, so
  the current policy is retrieved and used for whatever is not supplied - only `-policyId` is
  mandatory. The read-only properties of a retrieved policy are dropped rather than echoed back.
- `Test-UAPPolicy`: trigger validation of a cloud console policy.
- Definition builders: `New-UAPPrincipalDefinition`, `New-UAPConditionDefinition`,
  `New-UAPCloudConsoleTargetDefinition`, `New-UAPVirtualMachineTargetDefinition`,
  `New-UAPDatabaseTargetDefinition`, `New-UAPClusterTargetDefinition`,
  `New-UAPGroupTargetDefinition` and `New-UAPVirtualMachineBehaviorDefinition`. Each target builder
  accepts a previous definition, so a policy's targets are built up in a chain.
- `Get-UAPModuleData`: get the module version and session configuration data.
