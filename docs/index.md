---
title: IdentityCommand.UAP
subtitle: PowerShell for Idira Access Control Policies
hide_hero: true
---

<div class="has-text-centered mb-6">
  <img src="{{ '/UAP/media/images/IdentityCommand.UAP.png' | relative_url }}" alt="IdentityCommand.UAP" width="471">
</div>

**IdentityCommand.UAP** is a PowerShell module that provides a set of easy-to-use commands, allowing you to interact with the **Idira Access Control Policies API** from within the PowerShell environment.

It builds on [IdentityCommand]({{ '/' | relative_url }}) for authentication - see [Getting Started]({{ '/UAP/getting-started/' | relative_url }}) to install and connect, and the [command reference]({{ '/UAP/commands/' | relative_url }}) for every command.

## Access Policies

`Get-UAPPolicy` lists the policies on the tenant. The list carries **partial** details for each policy, so fetch a policy by identifier to see its targets and full configuration:

```powershell
# All policies - partial details
Get-UAPPolicy

# One policy, in full
Get-UAPPolicy -policyId aws_d880e53b-151e-414b-8f07-9ea55888abc3

# Filter criteria are assembled into the service's filter expression
Get-UAPPolicy -targetCategory VM -status Active
Get-UAPPolicy -policyTags production, critical -locationType AWS, Azure

# Or pass an expression directly
Get-UAPPolicy -filter "(targetCategory eq 'VM')"

# Free text search across name and description
Get-UAPPolicy -q 'access to production'
```

## Building a Policy

A policy is assembled from definitions - principals, conditions, and the targets for its category:

```powershell
$Principals = New-UAPPrincipalDefinition -id c2c7bcc6-9560-44e0-8dff-5be221cd37ee `
    -name 'John@cyberark.cloud.28905' -type USER `
    -sourceDirectoryName 'CyberArk Cloud Directory' -sourceDirectoryId '09B9A9B0-6CE8-465F-AB03-65766D33B05E'

$Principals = New-UAPPrincipalDefinition -id $RoleId -name 'Administration Role' -type ROLE -PrincipalDefinition $Principals

$Conditions = New-UAPConditionDefinition -daysOfTheWeek 1, 2, 3, 4, 5 -fromHour '08:00:00' -toHour '17:00:00' -maxSessionDuration 1
```

Each target category has its own builder, and each accepts a previous definition so targets are built up in a chain:

```powershell
# Cloud console - a role in an AWS account
$Targets = New-UAPCloudConsoleTargetDefinition -roleId 'arn:aws:iam::123456789123:role/examplerole' -workspaceId 123456789123

New-UAPPolicy -name 'AWS read access' -targetCategory 'Cloud Console' -locationType AWS `
    -principals $Principals -conditions $Conditions -targets $Targets
```

```powershell
# Virtual machines - locations are added to one targets object
$Targets = New-UAPVirtualMachineTargetDefinition -AWS -regions us-east-1 -accountIds 123456789012
$Targets = New-UAPVirtualMachineTargetDefinition -Azure -subscriptions $SubscriptionId -TargetDefinition $Targets

$Behavior = New-UAPVirtualMachineBehaviorDefinition -sshUsername ec2-user -rdpAssignGroups Administrators

New-UAPPolicy -name 'Production VM access' -targetCategory VM -locationType AWS -policyTags production `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 2 -idleTime 10) `
    -targets $Targets -behavior $Behavior
```

```powershell
# Databases - the profile shape follows the authentication method
$Targets = New-UAPDatabaseTargetDefinition -instanceName My-Local-MySQL -instanceType MySQL -instanceId 197012 `
    -authenticationMethod db_auth -profile @{ roles = @('hr', 'MySQL_role') }

New-UAPPolicy -name 'Database access' -targetCategory DB -locationType 'FQDN/IP' `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 2 -idleTime 10) -targets $Targets
```

```powershell
# Kubernetes clusters
$Targets = New-UAPClusterTargetDefinition -roleId 'arn:aws:iam::123456789123:role/clusterexamplerole' `
    -workspaceId 123456789123 -clusterId 'arn:aws:eks:us-east-1:123456789123:cluster/example-cluster' -scope cluster -region us-east-1

New-UAPPolicy -name 'EKS cluster access' -targetCategory Clusters -locationType AWS -connectionMethod proxy `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 1) -targets $Targets
```

```powershell
# Entra ID group membership
$Targets = New-UAPGroupTargetDefinition -groupId c63819e2-2397-4faa-850f-4abde34e52fb -directoryId 280a06f4-3f9b-4910-8967-053a914e314e

New-UAPPolicy -name 'Entra group membership' -targetCategory Groups -locationType Azure `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 2) -targets $Targets
```

Targets are wrapped in whatever shape the chosen category requires, so pass the builder output as it comes.

## Changing and Removing a Policy

The service replaces a policy with whatever is sent to it, so `Set-UAPPolicy` reads the current policy first and keeps everything you do not supply. Supply only what is changing:

```powershell
# Suspend a policy, leaving the rest of it alone
Set-UAPPolicy -policyId $policyId -status Suspended

# Rename it
Set-UAPPolicy -policyId $policyId -name 'AWS read access'

# Replace just its targets
Set-UAPPolicy -policyId $policyId -targets $Targets

# Suspend every active VM policy
Get-UAPPolicy -status Active -targetCategory VM | Set-UAPPolicy -status Suspended

Remove-UAPPolicy -policyId $policyId
```

The read-only properties the service adds to a retrieved policy - who created it, resolved target display names, the status detail behind its status - are dropped rather than echoed back. Because omitted values fall back to the current policy, a value cannot be cleared by omitting it.

## Validating a Cloud Console Policy

Validation is asynchronous: a `VALIDATING` response means the check started, not that it passed. Read the outcome from the policy afterwards:

```powershell
Test-UAPPolicy -policyId $policyId
(Get-UAPPolicy -policyId $policyId).metadata.status
```
