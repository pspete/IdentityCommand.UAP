---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# New-UAPPrincipalDefinition

## SYNOPSIS
Defines an identity a policy applies to

## SYNTAX

```
New-UAPPrincipalDefinition -id <String> -name <String> -type <String> [-sourceDirectoryName <String>]
 [-sourceDirectoryId <String>] [-PrincipalDefinition <PSObject[]>] [<CommonParameters>]
```

## DESCRIPTION
Defines a principal - a user, group or role - for the `-principals` of a policy.

Pass a previous definition to `-PrincipalDefinition` to add another principal to it, so a policy's
identities are built up in a chain.

`-sourceDirectoryName` and `-sourceDirectoryId` are required for every type except `ROLE`.

## EXAMPLES

### Example 1
```
New-UAPPrincipalDefinition -id c2c7bcc6-9560-44e0-8dff-5be221cd37ee -name 'John@cyberark.cloud.28905' -type USER `
    -sourceDirectoryName 'CyberArk Cloud Directory' -sourceDirectoryId '09B9A9B0-6CE8-465F-AB03-65766D33B05E'
```

Defines a single user

### Example 2
```
$Principals = New-UAPPrincipalDefinition -id $UserId -name $UserName -type USER -sourceDirectoryName $Directory -sourceDirectoryId $DirectoryId
$Principals = New-UAPPrincipalDefinition -id $GroupId -name $GroupName -type GROUP -sourceDirectoryName $Directory -sourceDirectoryId $DirectoryId -PrincipalDefinition $Principals
$Principals = New-UAPPrincipalDefinition -id $RoleId -name 'Administration Role' -type ROLE -PrincipalDefinition $Principals
```

Builds up a user, a group and a role

## PARAMETERS

### -id
The unique identifier of the identity in Idira.

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

### -name
The name of the principal.

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

### -type
The type of principal.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: USER, ROLE, GROUP

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -sourceDirectoryName
The name of the directory service. Required unless the type is `ROLE`.

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

### -sourceDirectoryId
The unique identifier of the directory service. Required unless the type is `ROLE`.

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

### -PrincipalDefinition
An existing principal definition to add this principal to.

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
