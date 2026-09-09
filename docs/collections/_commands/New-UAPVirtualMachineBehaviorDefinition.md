---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# New-UAPVirtualMachineBehaviorDefinition

## SYNOPSIS
Defines how policy members connect to a VM target

## SYNTAX

```
New-UAPVirtualMachineBehaviorDefinition [-sshUsername <String>] [-rdpAssignGroups <String[]>]
 [-enableEphemeralUserReconnect] [<CommonParameters>]
```

## DESCRIPTION
Defines the `-behavior` of a VM policy - the profile members assume when they connect to a target.

`-sshUsername` names the local target user, or a personal user template, used for SSH connections.
`-rdpAssignGroups` names the groups the local ephemeral user is assigned to for RDP connections.

## EXAMPLES

### Example 1
```
New-UAPVirtualMachineBehaviorDefinition -sshUsername ec2-user
```

Connects over SSH as a local user

### Example 2
```
New-UAPVirtualMachineBehaviorDefinition -sshUsername ec2-user -rdpAssignGroups Administrators, 'Remote Desktop Users'
```

Adds RDP connections as an ephemeral user in two groups

### Example 3
```
New-UAPVirtualMachineBehaviorDefinition -rdpAssignGroups Administrators -enableEphemeralUserReconnect
```

Allows the ephemeral user to reconnect

## PARAMETERS

### -sshUsername
The local target user, or a personal user template, used for SSH connections.

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

### -rdpAssignGroups
The groups the local ephemeral user is assigned to for RDP connections.

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

### -enableEphemeralUserReconnect
Specify to allow the ephemeral user to reconnect.

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


### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
