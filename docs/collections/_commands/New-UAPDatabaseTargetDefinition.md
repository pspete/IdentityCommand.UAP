---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# New-UAPDatabaseTargetDefinition

## SYNOPSIS
Defines a database instance target of a policy

## SYNTAX

```
New-UAPDatabaseTargetDefinition -instanceName <String> -instanceType <String> -instanceId <String>
 -authenticationMethod <String> -profile <Hashtable> [-TargetDefinition <PSObject[]>]
 [<CommonParameters>]
```

## DESCRIPTION
Defines a database instance target and the profile - the permissions - policy members receive on it.

The shape of `-profile` follows the authentication method:

| Method | Profile |
| ------ | ------- |
| `db_auth` | `@{ roles = @(...) }` |
| `ldap_auth` | `@{ assignGroups = @(...) }` |
| `rds_iam_user_auth` | `@{ dbUser = '...' }` |
| `oracle_auth` | `@{ roles = @(...); dbaRole = $true; sysdbaRole = $true; sysoperRole = $true }` |
| `mongo_auth` | `@{ globalBuiltinRoles = @(...); databaseBuiltinRoles = @{ db = @(...) }; databaseCustomRoles = @{ db = @(...) } }` |
| `sqlserver_auth` | `@{ globalBuiltinRoles = @(...); globalCustomRoles = @(...); databaseBuiltinRoles = @{ db = @(...) }; databaseCustomRoles = @{ db = @(...) } }` |

Pass a previous definition to `-TargetDefinition` to add another instance. A policy takes at most
1000 instances.

## EXAMPLES

### Example 1
```
New-UAPDatabaseTargetDefinition -instanceName My-Local-MySQL -instanceType MySQL -instanceId 197012 `
    -authenticationMethod db_auth -profile @{ roles = @('hr', 'MySQL_role') }
```

Defines a MySQL instance with local database authentication

### Example 2
```
New-UAPDatabaseTargetDefinition -instanceName My-IAM-PostgreSQL -instanceType Postgres -instanceId 197015 `
    -authenticationMethod rds_iam_user_auth -profile @{ dbUser = 'postgres' }
```

Defines a PostgreSQL instance using an RDS IAM user

### Example 3
```
$Targets = New-UAPDatabaseTargetDefinition -instanceName my-oracle-db -instanceType Oracle -instanceId 196946 `
    -authenticationMethod oracle_auth -profile @{ roles = @('Oracle_custom_role'); dbaRole = $true; sysdbaRole = $false; sysoperRole = $false }

$Targets = New-UAPDatabaseTargetDefinition -instanceName My-AD-Db2 -instanceType DB2 -instanceId 197019 `
    -authenticationMethod ldap_auth -profile @{ assignGroups = @('AD_Employees_Group') } -TargetDefinition $Targets
```

Defines two instances with different authentication methods

## PARAMETERS

### -instanceName
The name of the database instance.

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

### -instanceType
The database type of the instance, for example `MySQL`, `Postgres`, `Oracle`, `Mongo`, `MSSQL`, `MariaDB` or `DB2`.

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

### -instanceId
The identifier of the database instance.

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

### -authenticationMethod
How policy members authenticate to the instance.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: ldap_auth, db_auth, oracle_auth, mongo_auth, sqlserver_auth, rds_iam_user_auth

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -profile
The permissions policy members receive, shaped to match the authentication method.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TargetDefinition
An existing target definition to add this instance to.

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
