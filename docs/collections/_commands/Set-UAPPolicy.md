---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# Set-UAPPolicy

## SYNOPSIS
Updates an access policy

## SYNTAX

```
Set-UAPPolicy -policyId <String> [-name <String>] [-description <String>] [-targetCategory <String>]
 [-locationType <String>] [-policyType <String>] [-policyTags <String[]>] [-timeZone <String>]
 [-fromTime <DateTime>] [-toTime <DateTime>] [-status <String>] [-principals <PSObject[]>]
 [-conditions <PSObject>] [-targets <PSObject>] [-behavior <PSObject>] [-connectionMethod <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Updates an access policy.

The service replaces the policy with the payload sent, so this command retrieves the current policy
first and uses it for whatever you do not supply - supply only what is changing.

The read-only properties the service adds to a retrieved policy are dropped rather than echoed back:
who created and last updated it, the status code and description behind its status, the display names
it resolved for each target, its delegation classification, and the invalid resources behind an error
status.

Because omitted values fall back to the current policy, a value cannot be cleared by omitting it.

Suspending or reactivating a policy is done here, with `-status`.

## EXAMPLES

### Example 1
```
Set-UAPPolicy -policyId aws_d880e53b-151e-414b-8f07-9ea55888abc3 -status Suspended
```

Suspends a policy, leaving the rest of its configuration as it is

### Example 2
```
Set-UAPPolicy -policyId $policyId -name 'AWS read access' -description 'Read only access for the platform team'
```

Renames a policy and updates its description

### Example 3
```
$Targets = New-UAPCloudConsoleTargetDefinition -roleId $FirstRole -workspaceId $Workspace
$Targets = New-UAPCloudConsoleTargetDefinition -roleId $SecondRole -workspaceId $Workspace -TargetDefinition $Targets

Set-UAPPolicy -policyId $policyId -targets $Targets
```

Replaces the targets of a policy, leaving everything else as it is

### Example 4
```
Get-UAPPolicy -status Active -targetCategory VM | Set-UAPPolicy -status Suspended
```

Suspends every active VM policy

### Example 5
```
Set-UAPPolicy -policyId $policyId -conditions (New-UAPConditionDefinition -maxSessionDuration 4 -idleTime 15)
```

Extends the maximum session duration and idle timeout

## PARAMETERS

### -policyId
The unique identifier of the policy to update.

```yaml
Type: String
Parameter Sets: (All)
Aliases: id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -name
A new name for the policy. The current name is kept when not supplied.

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
The category of target the policy grants access to. The current category is kept when not supplied.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: Cloud Console, VM, DB, Clusters, Groups

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -locationType
The location of the target. The current location is kept when not supplied.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: AWS, Azure, GCP, FQDN/IP

Required: False
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
The identities the policy applies to, from `New-UAPPrincipalDefinition`. The current identities are kept when not supplied.

```yaml
Type: PSObject[]
Parameter Sets: (All)
Aliases: 

Required: False
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
The targets the policy grants access to, from the `New-UAP*TargetDefinition` builder matching the target category. The current targets are kept when not supplied.

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
