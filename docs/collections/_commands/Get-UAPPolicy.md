---
external help file: IdentityCommand.UAP-help.xml
Module Name: IdentityCommand.UAP
online version:
schema: 2.0.0
---

# Get-UAPPolicy

## SYNOPSIS
Gets access policies

## SYNTAX

### byFilterCriteria (Default)
```
Get-UAPPolicy [-policyTags <String[]>] [-identities <String[]>] [-targetCategory <String[]>]
 [-status <String[]>] [-locationType <String[]>] [-limit <Int32>] [-sort <String>] [-q <String>]
 [<CommonParameters>]
```

### byQuery
```
Get-UAPPolicy [-filter <String>] [-limit <Int32>] [-sort <String>] [-q <String>] [<CommonParameters>]
```

### byId
```
Get-UAPPolicy -policyId <String> [<CommonParameters>]
```

## DESCRIPTION
Gets access policies - a single policy by identifier, or a filtered list.

**The list returns partial details for each policy.** To see a policy's targets and full
configuration, fetch it by identifier.

Filter criteria are assembled into the service's filter expression: several values for one field
match any of them, and separate fields are combined. `-filter` takes an expression directly for
anything the criteria do not express.

Results are paginated automatically; every page is retrieved and the policies of each are returned.

## EXAMPLES

### Example 1
```
Get-UAPPolicy
```

Gets all access policies

### Example 2
```
Get-UAPPolicy -policyId aws_d880e53b-151e-414b-8f07-9ea55888abc3
```

Gets the full details of the specified policy

### Example 3
```
Get-UAPPolicy -targetCategory VM -status Active
```

Gets the active VM access policies

### Example 4
```
Get-UAPPolicy -policyTags production, critical -locationType AWS, Azure
```

Gets the AWS and Azure policies carrying either tag

### Example 5
```
Get-UAPPolicy -q 'access to production'
```

Searches policy names and descriptions

### Example 6
```
Get-UAPPolicy -targetCategory 'Cloud Console' | Get-UAPPolicy | Where-Object { $_.metadata.status.status -eq 'Error' }
```

Fetches the full details of every cloud console policy and reports those which failed validation

## PARAMETERS

### -policyId
The unique identifier of a single policy to get.

```yaml
Type: String
Parameter Sets: byId
Aliases: id

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -filter
A filter expression, passed to the service as given, for example `(targetCategory eq 'VM')`.

The supported operations are `eq`, `and` and `or` - `identities` supports only `contains`. The filterable fields are `policyTags`, `identities`, `targetCategory`, `status` and `locationType`.

```yaml
Type: String
Parameter Sets: byQuery
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -policyTags
Return policies carrying any of these tags.

```yaml
Type: String[]
Parameter Sets: byFilterCriteria
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -identities
Return policies applying to any of these identities.

```yaml
Type: String[]
Parameter Sets: byFilterCriteria
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -targetCategory
Return policies of any of these target categories.

```yaml
Type: String[]
Parameter Sets: byFilterCriteria
Aliases: 
Accepted values: Cloud Console, VM, DB, Clusters, Groups

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -status
Return policies in any of these statuses.

```yaml
Type: String[]
Parameter Sets: byFilterCriteria
Aliases: 
Accepted values: Active, Suspended, Expired, Validating, Error, Warning

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -locationType
Return policies for any of these locations.

```yaml
Type: String[]
Parameter Sets: byFilterCriteria
Aliases: 
Accepted values: AWS, Azure, GCP, FQDN/IP

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -limit
The maximum number of policies to return per request, up to 50. The service returns 10 when not specified.

```yaml
Type: Int32
Parameter Sets: byQuery, byFilterCriteria
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -sort
The field to sort the results by. The service supports `createdBy` only.

```yaml
Type: String
Parameter Sets: byQuery, byFilterCriteria
Aliases: 
Accepted values: createdBy

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -q
A free text search across policy name and description.

```yaml
Type: String
Parameter Sets: byQuery, byFilterCriteria
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
