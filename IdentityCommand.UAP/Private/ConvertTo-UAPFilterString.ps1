function ConvertTo-UAPFilterString {
    <#
    .SYNOPSIS
    Assembles an Access Control Policies filter expression.

    .DESCRIPTION
    Formats filter criteria into the expression syntax the Access Control Policies service accepts.
    Values for the same field are combined with `or` inside their own parentheses, and the resulting
    groups are combined with `and`:

        (((policyTags eq 'a') or (policyTags eq 'b')) and (targetCategory eq 'VM'))

    Every field compares with `eq`, apart from `identities`, which supports only `contains`.

    Values are single quoted, as the service documents them. The expression is not url encoded -
    Add-QueryString encodes the query string as a whole.

    .PARAMETER Filter
    A hashtable of field names to the values to match. A field with several values matches any of
    them. Supported fields are policyTags, identities, targetCategory, status and locationType.

    .EXAMPLE
    ConvertTo-UAPFilterString -Filter @{ targetCategory = 'VM' }

    Outputs: (targetCategory eq 'VM')

    .EXAMPLE
    ConvertTo-UAPFilterString -Filter ([ordered]@{ policyTags = @('a', 'b'); targetCategory = 'VM' })

    Outputs: (((policyTags eq 'a') or (policyTags eq 'b')) and (targetCategory eq 'VM'))

    .OUTPUTS
    String
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [parameter(
            Mandatory = $true,
            Position = 0
        )]
        [ValidateNotNull()]
        [System.Collections.IDictionary]$Filter
    )

    $SupportedField = @('policyTags', 'identities', 'targetCategory', 'status', 'locationType')

    #Every field compares with eq; identities is documented as supporting only contains
    $FieldOperator = @{ identities = 'contains' }

    $Groups = [System.Collections.Generic.List[string]]::new()

    foreach ($Field in $Filter.Keys) {

        if ($Field -notin $SupportedField) {
            throw "'$Field' is not a filterable field of the Access Control Policies service. Valid fields are: $($SupportedField -join ', ')"
        }

        $Values = @($Filter[$Field]) | Where-Object { -not [string]::IsNullOrEmpty("$_") }

        if ($Values.Count -eq 0) {
            continue
        }

        $Operator = if ($FieldOperator.ContainsKey($Field)) { $FieldOperator[$Field] } else { 'eq' }

        $Clauses = @($Values | ForEach-Object {
                "($(ConvertTo-FilterClause -Field $Field -Operator $Operator -Value $_ -QuoteValue -QuoteCharacter "'"))"
            })

        $Groups.Add($(if ($Clauses.Count -gt 1) { "($($Clauses -join ' or '))" } else { $Clauses[0] }))

    }

    if ($Groups.Count -eq 0) {
        return
    }

    if ($Groups.Count -eq 1) {
        return $Groups[0]
    }

    "($($Groups -join ' and '))"

}
