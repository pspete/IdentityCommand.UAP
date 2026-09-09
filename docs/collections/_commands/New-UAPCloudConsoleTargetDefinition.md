---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# New-UAPCloudConsoleTargetDefinition

## SYNOPSIS
Defines a cloud console target of a policy

## SYNTAX

```
New-UAPCloudConsoleTargetDefinition -roleId <String> -workspaceId <String> [-orgId <String>]
 [-workspaceType <String>] [-TargetDefinition <PSObject[]>] [<CommonParameters>]
```

## DESCRIPTION
Defines a cloud console target - a role within an AWS account or organization, an Azure or Entra ID
workspace, or a Google Cloud workspace.

Pass a previous definition to `-TargetDefinition` to add another target to it.

Which fields apply depends on the location: a standalone AWS account needs `roleId` and
`workspaceId`; AWS IAM Identity Center adds `orgId`; Azure and Google Cloud add `orgId` and
`workspaceType`.

## EXAMPLES

### Example 1
```
New-UAPCloudConsoleTargetDefinition -roleId 'arn:aws:iam::123456789123:role/examplerole' -workspaceId 123456789123
```

Defines a role in a standalone AWS account

### Example 2
```
New-UAPCloudConsoleTargetDefinition -roleId 'arn:aws:sso:::permissionSet/ssoins-55555cf0998b940/ps-48b59e1afd27e74e' `
    -workspaceId 123451234000 -orgId 1234567891234
```

Defines an AWS IAM Identity Center permission set

### Example 3
```
New-UAPCloudConsoleTargetDefinition -roleId '/subscriptions/19b70f3f-b121-46bd-a942-7966beb1669d/providers/Microsoft.Authorization/roleDefinitions/8d6517c1-e434-405c-9f3f-e0ae65085d76' `
    -workspaceId 'subscriptions/19b70f3f-b121-46bd-a942-7966beb1669d' -orgId '2ca55f05-abc1-12f3-9f0b-6b3f65b8d100' -workspaceType subscription
```

Defines an Azure subscription role

### Example 4
```
New-UAPCloudConsoleTargetDefinition -roleId 'roles/accessapproval.examplerole' -workspaceId test-123456 -orgId 12345678911 -workspaceType project
```

Defines a Google Cloud project role

## PARAMETERS

### -roleId
The identifier of the role - an AWS IAM role ARN, an Azure role definition or Entra ID role GUID, or a Google Cloud role.

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

### -workspaceId
The identifier given to the workspace when it was onboarded to Idira.

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

### -orgId
The organization or directory identifier. Required for AWS IAM Identity Center, Azure and Google Cloud.

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

### -workspaceType
The level at which the workspace was onboarded, for example `subscription`, `directory`, `project` or `folder`.

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

### -TargetDefinition
An existing target definition to add this target to.

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
