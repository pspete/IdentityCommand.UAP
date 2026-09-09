---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# New-UAPGroupTargetDefinition

## SYNOPSIS
Defines an Entra ID group target of a policy

## SYNTAX

```
New-UAPGroupTargetDefinition -groupId <String> -directoryId <String> [-TargetDefinition <PSObject[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Defines an Entra ID group that policy members are granted membership of.

Pass a previous definition to `-TargetDefinition` to add another group to it.

## EXAMPLES

### Example 1
```
New-UAPGroupTargetDefinition -groupId c63819e2-2397-4faa-850f-4abde34e52fb -directoryId 280a06f4-3f9b-4910-8967-053a914e314e
```

Defines a single Entra ID group

### Example 2
```
$Targets = New-UAPGroupTargetDefinition -groupId $FirstGroup -directoryId $Directory
$Targets = New-UAPGroupTargetDefinition -groupId $SecondGroup -directoryId $Directory -TargetDefinition $Targets
```

Defines two groups in the same directory

## PARAMETERS

### -groupId
The Entra ID group identifier.

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

### -directoryId
The Entra ID directory identifier.

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

### -TargetDefinition
An existing target definition to add this group to.

```yaml
Type: PSObject[]
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
