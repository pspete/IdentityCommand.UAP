---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# New-UAPConditionDefinition

## SYNOPSIS
Defines the access conditions of a policy

## SYNTAX

```
New-UAPConditionDefinition [-daysOfTheWeek <Int32[]>] [-fromHour <String>] [-toHour <String>]
 [-maxSessionDuration <Int32>] [-idleTime <Int32>] [-accessApprovalRequired] [-approvers <PSObject[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Defines the `-conditions` of a policy: the access window during which a session can start, how long
a session may last, and whether access requires approval.

`-idleTime` applies to infrastructure (VM and DB) policies.

When `-accessApprovalRequired` is specified the access window must be omitted - the service rejects
a payload carrying both, and this command throws rather than sending one.

## EXAMPLES

### Example 1
```
New-UAPConditionDefinition -daysOfTheWeek 1, 2, 3, 4, 5 -fromHour '08:00:00' -toHour '17:00:00' -maxSessionDuration 1
```

Allows sessions of up to an hour, on weekdays between 08:00 and 17:00

### Example 2
```
New-UAPConditionDefinition -maxSessionDuration 2 -idleTime 10
```

Allows sessions of up to two hours, ending after ten idle minutes

### Example 3
```
New-UAPConditionDefinition -maxSessionDuration 1 -accessApprovalRequired -approvers $Approvers
```

Requires the named approvers to approve access before it is granted

## PARAMETERS

### -daysOfTheWeek
The days access is allowed on, where Sunday is 0 and Saturday is 6.

```yaml
Type: Int32[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -fromHour
The start of the access window.

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

### -toHour
The end of the access window.

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

### -maxSessionDuration
The maximum length of a single session in hours - up to 12 for cloud access, 24 for VM and DB access.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -idleTime
The maximum idle time in minutes before an infrastructure session ends.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -accessApprovalRequired
Specify when access under this policy requires approval before it is granted.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -approvers
Up to five identities responsible for handling access requests, from `New-UAPPrincipalDefinition`. Requests go to the workspace delegates when none are given.

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


### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
