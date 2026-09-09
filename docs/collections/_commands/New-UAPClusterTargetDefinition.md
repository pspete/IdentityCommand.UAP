---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# New-UAPClusterTargetDefinition

## SYNOPSIS
Defines a Kubernetes cluster target of a policy

## SYNTAX

```
New-UAPClusterTargetDefinition -roleId <String> -workspaceId <String> -clusterId <String>
 -scope <String> [-namespaceId <String>] [-orgId <String>] [-workspaceType <String>]
 [-region <String>] [-TargetDefinition <PSObject[]>] [<CommonParameters>]
```

## DESCRIPTION
Defines an EKS or AKS cluster target, granting access to a whole cluster or to a single namespace
within it.

A SIA connector for Kubernetes must be installed and configured regardless of the connection method
chosen on the policy.

`-orgId` is required for AWS IAM Identity Center and for Azure; Azure additionally requires
`-workspaceType`, which must be `resource` for AKS clusters.

## EXAMPLES

### Example 1
```
New-UAPClusterTargetDefinition -roleId 'arn:aws:iam::123456789123:role/clusterexamplerole' -workspaceId 123456789123 `
    -clusterId 'arn:aws:eks:us-east-1:123456789123:cluster/example-cluster' -scope cluster -region us-east-1
```

Defines an EKS cluster in a single AWS account

### Example 2
```
New-UAPClusterTargetDefinition -roleId $PermissionSetArn -workspaceId 123456789123 -orgId 123456789123 `
    -clusterId $ClusterArn -scope namespace -namespaceId production -region us-east-1
```

Defines a namespace of an EKS cluster reached through AWS IAM Identity Center

### Example 3
```
New-UAPClusterTargetDefinition -roleId '/providers/Microsoft.Authorization/roleDefinitions/c025889f-8102-4ebf-b32c-fc0c6f0c6bd9' `
    -workspaceId $ClusterResourceId -orgId 25b2c2d5-a7fc-47d0-89e4-8709a1560bfa -workspaceType resource `
    -clusterId $ClusterResourceId -scope cluster
```

Defines an AKS cluster

## PARAMETERS

### -roleId
The identifier of the role granting cluster access - an AWS IAM role ARN or an Azure resource role identifier.

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
The identifier created for the account or cluster in Idira when it was connected.

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

### -clusterId
The unique identifier of the cluster - an EKS cluster ARN or an AKS Azure resource identifier.

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

### -scope
Whether the role grants access to the whole cluster or to a single namespace.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: cluster, namespace

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -namespaceId
The identifier of the Kubernetes namespace. Required when the scope is `namespace`.

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

### -orgId
The AWS management account identifier, or the Azure directory identifier.

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
The scope level at which the Entra tenant was connected. Must be `resource` for AKS clusters.

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

### -region
The AWS region the EKS cluster is in.

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
An existing target definition to add this cluster to.

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
