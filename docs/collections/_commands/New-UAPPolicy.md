---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# New-UAPPolicy

## SYNOPSIS
Creates an access policy

## SYNTAX

```
New-UAPPolicy -name <String> [-description <String>] -targetCategory <String> -locationType <String>
 [-policyType <String>] [-policyTags <String[]>] [-timeZone <String>] [-fromTime <DateTime>]
 [-toTime <DateTime>] [-status <String>] -principals <PSObject[]> [-conditions <PSObject>]
 -targets <PSObject> [-behavior <PSObject>] [-connectionMethod <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates an access policy granting identities access to virtual machines, databases, cloud consoles,
Kubernetes clusters, or membership of Entra ID groups. Returns the new policy's identifier.

Build the policy's parts with the definition commands, then pass them in:

- `New-UAPPrincipalDefinition` - the identities the policy applies to
- `New-UAPConditionDefinition` - the access window, session limits and access approval
- `New-UAPCloudConsoleTargetDefinition`, `New-UAPVirtualMachineTargetDefinition`,
  `New-UAPDatabaseTargetDefinition`, `New-UAPClusterTargetDefinition`,
  `New-UAPGroupTargetDefinition` - the targets, one builder per target category
- `New-UAPVirtualMachineBehaviorDefinition` - how members connect to a VM target

Targets are wrapped in the shape the chosen `-targetCategory` requires, so pass the builder output
as it comes.

## EXAMPLES

### Example 1
```
$Principals = New-UAPPrincipalDefinition -id c2c7bcc6-9560-44e0-8dff-5be221cd37ee -name 'John@cyberark.cloud.28905' -type USER `
    -sourceDirectoryName 'CyberArk Cloud Directory' -sourceDirectoryId '09B9A9B0-6CE8-465F-AB03-65766D33B05E'

$Conditions = New-UAPConditionDefinition -daysOfTheWeek 1, 2, 3, 4, 5 -fromHour '08:00:00' -toHour '17:00:00' -maxSessionDuration 1

$Targets = New-UAPCloudConsoleTargetDefinition -roleId 'arn:aws:iam::123456789123:role/examplerole' -workspaceId '123456789123'

New-UAPPolicy -name 'AWS read access' -targetCategory 'Cloud Console' -locationType AWS `
    -principals $Principals -conditions $Conditions -targets $Targets
```

Creates an AWS cloud console policy

### Example 2
```
$Targets = New-UAPVirtualMachineTargetDefinition -AWS -regions us-east-1 -accountIds 123456789012
$Behavior = New-UAPVirtualMachineBehaviorDefinition -sshUsername ec2-user -rdpAssignGroups Administrators

New-UAPPolicy -name 'Production VM access' -targetCategory VM -locationType AWS -policyTags production `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 2 -idleTime 10) `
    -targets $Targets -behavior $Behavior
```

Creates a VM access policy for AWS instances in a region

### Example 3
```
$Targets = New-UAPDatabaseTargetDefinition -instanceName My-Local-MySQL -instanceType MySQL -instanceId 197012 `
    -authenticationMethod db_auth -profile @{ roles = @('hr', 'MySQL_role') }

New-UAPPolicy -name 'Database access' -targetCategory DB -locationType 'FQDN/IP' `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 2 -idleTime 10) -targets $Targets
```

Creates a database access policy

### Example 4
```
$Targets = New-UAPClusterTargetDefinition -roleId 'arn:aws:iam::123456789123:role/clusterexamplerole' `
    -workspaceId 123456789123 -clusterId 'arn:aws:eks:us-east-1:123456789123:cluster/example-cluster' -scope cluster -region us-east-1

New-UAPPolicy -name 'EKS cluster access' -targetCategory Clusters -locationType AWS -connectionMethod proxy `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 1) -targets $Targets
```

Creates a Kubernetes cluster access policy

### Example 5
```
$Targets = New-UAPGroupTargetDefinition -groupId c63819e2-2397-4faa-850f-4abde34e52fb -directoryId 280a06f4-3f9b-4910-8967-053a914e314e

New-UAPPolicy -name 'Entra group membership' -targetCategory Groups -locationType Azure `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 2) -targets $Targets
```

Creates an Entra ID group assignment policy

## PARAMETERS

### -name
A unique name for the policy.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -description
A short description of the policy, up to 200 characters.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -targetCategory
The category of target the policy grants access to.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: Cloud Console, VM, DB, Clusters, Groups

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -locationType
The location of the target.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: AWS, Azure, GCP, FQDN/IP

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -policyType
Whether the policy is recurring or on-demand. The service defaults to `Recurring`.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: Recurring, OnDemand

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -policyTags
Up to 20 tags used to identify the policy and those similar to it.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -timeZone
The time zone identifier the access window is evaluated in, for example `Europe/London`. The service defaults to GMT.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -fromTime
The date the policy becomes active. Omit both times for an unlimited timeframe.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -toTime
The date the policy expires.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -status
The policy status. Policies are created `Active`; a policy can be moved between `Active` and `Suspended`.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: Active, Suspended

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -principals
The identities the policy applies to, from `New-UAPPrincipalDefinition`.

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -conditions
The access window and session limits, from `New-UAPConditionDefinition`.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -targets
The targets the policy grants access to, from the `New-UAP*TargetDefinition` builder matching the target category.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -behavior
How policy members connect to a VM target, from `New-UAPVirtualMachineBehaviorDefinition`. Required for VM policies.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -connectionMethod
How policy members connect to a cluster target. Applies to `Clusters` policies.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: direct, proxy

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```


### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
