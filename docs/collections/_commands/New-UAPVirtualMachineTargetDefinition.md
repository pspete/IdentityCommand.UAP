---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# New-UAPVirtualMachineTargetDefinition

## SYNOPSIS
Defines the virtual machine targets of a policy

## SYNTAX

### AWS (Default)
```
New-UAPVirtualMachineTargetDefinition [-AWS] [-regions <String[]>] [-tags <Hashtable[]>]
 [-vpcIds <String[]>] [-accountIds <String[]>] [-TargetDefinition <PSObject>] [<CommonParameters>]
```

### Azure
```
New-UAPVirtualMachineTargetDefinition [-Azure] [-regions <String[]>] [-tags <Hashtable[]>]
 [-vnetIds <String[]>] [-resourceGroups <String[]>] [-subscriptions <String[]>]
 [-TargetDefinition <PSObject>] [<CommonParameters>]
```

### GCP
```
New-UAPVirtualMachineTargetDefinition [-GCP] [-regions <String[]>] [-labels <Hashtable[]>]
 [-vpcIds <String[]>] [-projects <String[]>] [-TargetDefinition <PSObject>] [<CommonParameters>]
```

### FQDNIP
```
New-UAPVirtualMachineTargetDefinition [-FQDNIP] [-fqdnRules <Hashtable[]>] [-ipRules <Hashtable[]>]
 [-TargetDefinition <PSObject>] [<CommonParameters>]
```

## DESCRIPTION
Defines the VM targets of a policy, for one location at a time.

**Every criterion left empty means "all"** - a definition with no regions matches every region, so
an empty definition matches every VM in that location. Narrow deliberately.

Pass a previous definition to `-TargetDefinition` to add another location to the same targets object.

## EXAMPLES

### Example 1
```
New-UAPVirtualMachineTargetDefinition -AWS -regions us-east-1 -accountIds 123456789012
```

Defines AWS instances in a region of an account

### Example 2
```
New-UAPVirtualMachineTargetDefinition -AWS -tags @{ key = 'Environment'; value = @('Production') }
```

Defines AWS instances carrying a tag

### Example 3
```
$Targets = New-UAPVirtualMachineTargetDefinition -AWS -regions us-east-1
$Targets = New-UAPVirtualMachineTargetDefinition -Azure -subscriptions $SubscriptionId -TargetDefinition $Targets
```

Defines targets in two locations

### Example 4
```
New-UAPVirtualMachineTargetDefinition -FQDNIP -fqdnRules @{ operator = 'SUFFIX'; computernamePattern = 'prod'; domain = 'example.com' }
```

Defines on-premise targets by FQDN rule

## PARAMETERS

### -AWS
Define AWS targets.

```yaml
Type: SwitchParameter
Parameter Sets: AWS
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Azure
Define Azure targets.

```yaml
Type: SwitchParameter
Parameter Sets: Azure
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GCP
Define Google Cloud targets.

```yaml
Type: SwitchParameter
Parameter Sets: GCP
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FQDNIP
Define on-premise targets, matched by FQDN or IP rule.

```yaml
Type: SwitchParameter
Parameter Sets: FQDNIP
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -regions
The region names to include. Leave empty for all regions.

```yaml
Type: String[]
Parameter Sets: AWS, Azure, GCP
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -tags
Key-value pairs matching custom tags on the instances. Leave empty for all tags.

```yaml
Type: Hashtable[]
Parameter Sets: AWS, Azure
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -labels
Key-value pairs matching custom labels on the instances. Leave empty for all labels.

```yaml
Type: Hashtable[]
Parameter Sets: GCP
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -vpcIds
The VPC identifiers to include. Leave empty for all VPCs.

```yaml
Type: String[]
Parameter Sets: AWS, GCP
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -accountIds
The AWS account identifiers to include. Leave empty for all accounts.

```yaml
Type: String[]
Parameter Sets: AWS
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -vnetIds
The Azure VNet identifiers to include. Leave empty for all VNets.

```yaml
Type: String[]
Parameter Sets: Azure
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -resourceGroups
The Azure resource group identifiers to include. Leave empty for all resource groups.

```yaml
Type: String[]
Parameter Sets: Azure
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -subscriptions
The Azure subscription identifiers to include. Leave empty for all subscriptions.

```yaml
Type: String[]
Parameter Sets: Azure
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -projects
The Google Cloud project identifiers to include. Leave empty for all projects.

```yaml
Type: String[]
Parameter Sets: GCP
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -fqdnRules
Rules matching target computer names, each with an `operator` (`WILDCARD`, `EXACTLY`, `CONTAINS`, `PREFIX`, `SUFFIX`), a `computernamePattern` and an optional `domain`.

```yaml
Type: Hashtable[]
Parameter Sets: FQDNIP
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ipRules
Rules matching target IP addresses, each with `ipAddresses`, a `logicalName` and an `operator` (`EXACTLY` or `WILDCARD`).

```yaml
Type: Hashtable[]
Parameter Sets: FQDNIP
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetDefinition
An existing target definition to add this location to.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: 

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
