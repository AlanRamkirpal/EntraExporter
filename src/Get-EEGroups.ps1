<# 
 .Synopsis
  Gets the groups 

 .Description
  GET /users
  https://docs.microsoft.com/en-us/graph/api/group-list

 .Example
  Get-EEGroups
#>

Function Get-EEGroups {
  if((Compare-Object $Type @('Config') -ExcludeDifferent)){
    Invoke-Graph 'groups' -Filter "groupTypes/any(c:c eq 'DynamicMembership')" -QueryParameters @{ expand = 'appRoleAssignments' }
  }
  else {
    Invoke-Graph 'groups' -QueryParameters @{ expand = 'appRoleAssignments' }
  }
}