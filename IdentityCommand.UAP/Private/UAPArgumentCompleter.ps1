#The completer helper functions live in IdentityCommand's Private folder, which the psm1 loads
#into this module's scope.

#region Registration

#Policies are identified by an opaque id, so label the completion with the policy name.
Register-ArgumentCompleter -ParameterName 'policyId' -ScriptBlock (
    Get-ArgumentCompleter -RetrievalCommand 'Get-UAPPolicy' -ValueProperty 'policyId', 'id' -LabelProperty 'name'
) -CommandName @(
    'Get-UAPPolicy'
    'Remove-UAPPolicy'
    'Set-UAPPolicy'
    'Test-UAPPolicy'
)

#Tags are free text, so offer those already in use on the tenant rather than a fixed set.
Register-ArgumentCompleter -ParameterName 'policyTags' -ScriptBlock (
    Get-ArgumentCompleter -RetrievalCommand 'Get-UAPPolicy' -ValueProperty 'policyTags'
) -CommandName @(
    'Get-UAPPolicy'
    'New-UAPPolicy'
    'Set-UAPPolicy'
)

#endregion Registration
