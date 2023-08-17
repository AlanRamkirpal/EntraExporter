# Azure AD Exporter

The Azure AD Exporter is a PowerShell module that allows you to export your Azure AD and Azure AD B2C configuration settings to local .json files.

This module can be run as a nightly scheduled task or a DevOps component (Azure DevOps, GitHub, Jenkins) and the exported files can be version controlled in Git or SharePoint.

This will provide tenant administrators with a historical view of all the settings in the tenant including the change history over the years.

## Installing the module

```powershell
    Install-Module AzureADExporter
```

## Using the module

### Connecting to your tenant

```powershell
    Connect-AzureADExporter
```

### Exporting objects and settings

To export object and settings use the following command:

```powershell
    Export-AzureAD -Path 'C:\AzureADBackup\'
```

This will export the most common set of objects and settings.

The following objects and settings are not exported by default:

* B2C
* B2B
* Static Groups and group memberships
* Applications
* ServicePrincipals
* Users
* Privileged Identity Management (built in roles, default roles settings, non permanent role assignements)

To export all the objects and settings supported (no filter applied):

```powershell
    Export-AzureAD -Path 'C:\AzureADBackup\' -All
```

The ``-Type`` parameter can be used to select specific objects and settings to export. The default type is "Config":

```powershell
    # export default all users as well as default objects and settings
    Export-AzureAD -Path 'C:\AzureADBackup\' -Type "Config","Users"
    # export applications only
    Export-AzureAD -Path 'C:\AzureADBackup\' -Type "Applications"
     # export B2C specific properties only
    Export-AzureAD -Path 'C:\AzureADBackup\' -Type "B2C"
    # export B2B properties along with AD properties
    Export-AzureAD -Path 'C:\AzureADBackup\' -Type "B2B","Config"
```

The currently valid types are:

* All (all elements)
* Config (default configuration)
* AccessReviews
* ConditionalAccess
* Users
* Groups
* Applications
* ServicePrincipals
* B2C
* B2B
* PIM
* PIMAzure
* PIMAAD
* AppProxy
* Organization
* Domains
* EntitlementManagement
* Policies
* AdministrativeUnits
* SKUs
* Identity
* Roles
* Governance

This list can also be retrieved via:

```powershell
(Get-Command Export-AzureAD | Select-Object -Expand Parameters)['Type'].Attributes.ValidValues
```

Additional filters can be applied:

* To only export user and groups that are not synced from on-premises

```powershell
Export-AzureAD -Path 'C:\AzureADBackup\' -CloudUsersAndGroupsOnly
```

* All groups (by default only dynamic groups are exported)

```powershell
Export-AzureAD -Path 'C:\AzureADBackup\' -AllGroups
```

* All will export all types and remove filters from groups and PIM:

```powershell
Export-AzureAD -Path 'C:\AzureADBackup\' -All
```

> [!NOTE]
> This module exports all settings that are available through the Microsoft Graph API. Azure AD settings and objects that are not yet available in the Graph API are not included.

## Exported settings include

* Users
* Groups
  * Dynamic and Assigned groups (incl. Members and Owners)
  * Group Settings
* External Identities
  * Authorization Policy
  * API Connectors
  * User Flows
* Roles and Administrators
* Administrative Units
* Applications
  * Enterprise Applications
  * App Registrations
  * Claims Mapping Policy
  * Extension Properties
  * Admin Consent Request Policy
  * Permission Grant Policies
  * Token Issuance Policies
  * Token Lifetime Policies
* Identity Governance
  * Entitlement Management
    * Access Packages
    * Catalogs
    * Connected Organizations
  * Access Reviews
  * Privileged Identity Management
    * Azure AD Roles
    * Azure Resources
  * Terms of Use
* Application Proxy
  * Connectors and Connect Groups
  * Agents and Agent Groups
  * Published Resources
* Licenses
* Custom domain names
* Company branding
  * Profile Card Properties
* User settings
* Tenant Properties
  * Technical contacts
* Security
  * Conditional Access Policies
  * Named Locations
  * Authentication Methods Policies
  * Identity Security Defaults Enforcement Policy
  * Permission Grant Policies
* Tenant Policies and Settings
  * Feature Rollout Policies
  * Cross-tenant Access
  * Activity Based Timeout Policies
* Hybrid Authentication
  * Identity Providers
  * Home Realm Discovery Policies

* B2C Settings
  * B2C User Flows
    * Identity Providers
    * User Attribute Assignments
    * API Connector Configuration
    * Languages

## Integrate to Azure DevOps Pipeline

Exporting Azure AD settings to json files makes them useful to integrate with DevOps pipelines.

> **Note**:
> Delegated authentication will require a dedicated agent where the authentication has been pre-configured.

Bellow is an sample of exporting in two steps

1. Export Azure AD to local json files
2. Update a git repository with the files

To export the configuration (replace variables with ``<>`` with the values suited to your situation):

```powershell
$tenantPath = './<tenant export path>'
$tenantId = '<tenant id>'
Write-Host 'git checkout main...'
git config --global core.longpaths true #needed for Windows
git checkout main

Write-Host 'Clean git folder...'
Remove-Item $tenantPath -Force -Recurse

Write-Host 'Installing modules...'
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
Install-Module AzureADExporter -Scope CurrentUser -Force

Write-Host 'Connecting to AzureAD...'
Connect-AzureADExporter -TenantId $tenantId

Write-Host 'Starting backup...'
Export-AzureAD $tenantPath -All
```

To update the git repository with the generated files:

```powershell
Write-Host 'Updating repo...'
git config user.email "<email>"
git config user.name "<name>"
git add -u
git add -A
git commit -m "ADO Update"
git push origin
```

## FAQs

### Error 'Could not find a part of the path' when exported JSON file paths are longer than 260 characters

A workaround to this is to enable long paths via the Windows registry or a GPO setting. Run the following from an elevated PowerShell session and then close PowerShell before trying your export again: 

```powershell
New-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
    -Name "LongPathsEnabled" `
    -Value 1 `
    -PropertyType DWORD `
    -Force
```

Credit: @shaunluttin via https://bigfont.ca/enable-long-paths-in-windows-with-powershell/ and https://docs.microsoft.com/en-us/windows/win32/fileio/maximum-file-path-limitation?tabs=powershell.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
