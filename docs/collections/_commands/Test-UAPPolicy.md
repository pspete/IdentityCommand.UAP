---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# Test-UAPPolicy

## SYNOPSIS
Validates an access policy

## SYNTAX

```
Test-UAPPolicy -policyId <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Triggers validation of an access policy.

Validation is **asynchronous**: a `VALIDATING` response means the check has started, not that it
passed. Fetch the policy with `Get-UAPPolicy -policyId` afterwards and read
`metadata.status.status` for the outcome - `Error` when validation failed, `Warning` when the policy
is valid but some workspaces, resources or roles it names are missing.

Applies to cloud console policies only.

## EXAMPLES

### Example 1
```
Test-UAPPolicy -policyId aws_d880e53b-151e-414b-8f07-9ea55888abc3
```

Triggers validation of the specified policy

### Example 2
```
Test-UAPPolicy -policyId $policyId
(Get-UAPPolicy -policyId $policyId).metadata.status
```

Triggers validation, then reads the resulting status

## PARAMETERS

### -policyId
The unique identifier of the policy to validate.

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
