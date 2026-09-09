# IdentityCommand.UAP

**IdentityCommand.UAP** is a PowerShell module that provides a set of easy-to-use commands, allowing you to interact with the **CyberArk Access Control Policies API** from within the PowerShell environment.

| Main Branch              | Latest Build             | CodeFactor                 | Coverage                     | PowerShell Gallery        | License                      |
| ------------------------ | ------------------------ | -------------------------- | ---------------------------- | ------------------------- | ---------------------------- |
| [![appveyor][]][av-site] | [![tests][]][tests-site] | [![codefactor][]][cf-site] | [![codecov][]][codecov-link] | [![psgallery][]][ps-site] | [![license][]][license-link] |

[appveyor]: https://ci.appveyor.com/api/projects/status/q2av77njofnsul92/branch/main?svg=true
[av-site]: https://ci.appveyor.com/project/pspete/IdentityCommand-UAP/branch/main
[psgallery]: https://img.shields.io/powershellgallery/v/IdentityCommand.UAP.svg
[ps-site]: https://www.powershellgallery.com/packages/IdentityCommand.UAP
[tests]: https://img.shields.io/appveyor/tests/pspete/IdentityCommand-UAP.svg
[tests-site]: https://ci.appveyor.com/project/pspete/IdentityCommand-UAP
[downloads]: https://img.shields.io/powershellgallery/dt/IdentityCommand.UAP.svg?color=blue
[cf-site]: https://www.codefactor.io/repository/github/pspete/IdentityCommand.UAP
[codefactor]: https://www.codefactor.io/repository/github/pspete/IdentityCommand.UAP/badge
[codecov]: https://codecov.io/gh/pspete/IdentityCommand.UAP/branch/main/graph/badge.svg
[codecov-link]: https://codecov.io/gh/pspete/IdentityCommand.UAP
[license]: https://img.shields.io/github/license/pspete/IdentityCommand.UAP.svg
[license-link]: https://github.com/pspete/IdentityCommand.UAP/blob/main/LICENSE

## Using the Module

The module requires authentication to the CyberArk Identity platform using the `IdentityCommand` module.

The `IdentityCommand` module must be installed and available in order to use `IdentityCommand.UAP`.

### Access Control Policies Authentication

The `Connect-UAPTenant` command initialises the bearer token used for module operations against the Access Control Policies service.

If an Identity session already exists (established with the `IdentityCommand` module's `New-IDSession` or `New-IDPlatformToken`), it is used as-is:

```powershell
# Resolve the Access Control Policies url automatically from the shared services subdomain
Connect-UAPTenant -tenant_subdomain sometenant

# Or provide the Access Control Policies tenant url directly
Connect-UAPTenant -tenant_url https://sometenant.uap.cyberark.cloud
```

Otherwise, provide a credential and `Connect-UAPTenant` authenticates to CyberArk Identity for you - the Identity tenant url is discovered from the same subdomain / url:

```powershell
# Interactive user authentication (any MFA challenges are handled by IdentityCommand)
Connect-UAPTenant -tenant_subdomain sometenant -Credential $Credential

# Non-interactive service user authentication via an OAuth platform token
Connect-UAPTenant -tenant_subdomain sometenant -Credential $ServiceUserCredential -PlatformToken
```

### Access Policies

`Get-UAPPolicy` lists the policies on the tenant. The list carries **partial** details for each policy, so fetch a policy by identifier to see its targets and full configuration:

```powershell
# All policies - partial details
Get-UAPPolicy

# One policy, in full
Get-UAPPolicy -policyId aws_d880e53b-151e-414b-8f07-9ea55888abc3

# Filter criteria are assembled into the service's filter expression
Get-UAPPolicy -targetCategory VM -status Active
Get-UAPPolicy -policyTags production, critical -locationType AWS, Azure

# Or pass an expression directly
Get-UAPPolicy -filter "(targetCategory eq 'VM')"

# Free text search across name and description
Get-UAPPolicy -q 'access to production'
```

### Building a Policy

A policy is assembled from definitions - principals, conditions, and the targets for its category:

```powershell
$Principals = New-UAPPrincipalDefinition -id c2c7bcc6-9560-44e0-8dff-5be221cd37ee `
    -name 'John@cyberark.cloud.28905' -type USER `
    -sourceDirectoryName 'CyberArk Cloud Directory' -sourceDirectoryId '09B9A9B0-6CE8-465F-AB03-65766D33B05E'

$Principals = New-UAPPrincipalDefinition -id $RoleId -name 'Administration Role' -type ROLE -PrincipalDefinition $Principals

$Conditions = New-UAPConditionDefinition -daysOfTheWeek 1, 2, 3, 4, 5 -fromHour '08:00:00' -toHour '17:00:00' -maxSessionDuration 1
```

Each target category has its own builder, and each accepts a previous definition so targets are built up in a chain:

```powershell
# Cloud console - a role in an AWS account
$Targets = New-UAPCloudConsoleTargetDefinition -roleId 'arn:aws:iam::123456789123:role/examplerole' -workspaceId 123456789123

New-UAPPolicy -name 'AWS read access' -targetCategory 'Cloud Console' -locationType AWS `
    -principals $Principals -conditions $Conditions -targets $Targets
```

```powershell
# Virtual machines - locations are added to one targets object
$Targets = New-UAPVirtualMachineTargetDefinition -AWS -regions us-east-1 -accountIds 123456789012
$Targets = New-UAPVirtualMachineTargetDefinition -Azure -subscriptions $SubscriptionId -TargetDefinition $Targets

$Behavior = New-UAPVirtualMachineBehaviorDefinition -sshUsername ec2-user -rdpAssignGroups Administrators

New-UAPPolicy -name 'Production VM access' -targetCategory VM -locationType AWS -policyTags production `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 2 -idleTime 10) `
    -targets $Targets -behavior $Behavior
```

```powershell
# Databases - the profile shape follows the authentication method
$Targets = New-UAPDatabaseTargetDefinition -instanceName My-Local-MySQL -instanceType MySQL -instanceId 197012 `
    -authenticationMethod db_auth -profile @{ roles = @('hr', 'MySQL_role') }

New-UAPPolicy -name 'Database access' -targetCategory DB -locationType 'FQDN/IP' `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 2 -idleTime 10) -targets $Targets
```

```powershell
# Kubernetes clusters
$Targets = New-UAPClusterTargetDefinition -roleId 'arn:aws:iam::123456789123:role/clusterexamplerole' `
    -workspaceId 123456789123 -clusterId 'arn:aws:eks:us-east-1:123456789123:cluster/example-cluster' -scope cluster -region us-east-1

New-UAPPolicy -name 'EKS cluster access' -targetCategory Clusters -locationType AWS -connectionMethod proxy `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 1) -targets $Targets
```

```powershell
# Entra ID group membership
$Targets = New-UAPGroupTargetDefinition -groupId c63819e2-2397-4faa-850f-4abde34e52fb -directoryId 280a06f4-3f9b-4910-8967-053a914e314e

New-UAPPolicy -name 'Entra group membership' -targetCategory Groups -locationType Azure `
    -principals $Principals -conditions (New-UAPConditionDefinition -maxSessionDuration 2) -targets $Targets
```

Targets are wrapped in whatever shape the chosen category requires, so pass the builder output as it comes.

### Changing and Removing a Policy

`Set-UAPPolicy` **replaces** the policy with the payload sent - it is not a partial update, so supply the policy in full, including the parts which are not changing. Suspending a policy is done here too:

```powershell
Set-UAPPolicy -policyId $policyId -name 'AWS read access' -targetCategory 'Cloud Console' -locationType AWS `
    -status Suspended -principals $Principals -conditions $Conditions -targets $Targets

Remove-UAPPolicy -policyId $policyId
```

### Validating a Cloud Console Policy

Validation is asynchronous: a `VALIDATING` response means the check started, not that it passed. Read the outcome from the policy afterwards:

```powershell
Test-UAPPolicy -policyId $policyId
(Get-UAPPolicy -policyId $policyId).metadata.status
```

## Module Commands

| Command                                   | Description                                         |
| ----------------------------------------- | --------------------------------------------------- |
| `Connect-UAPTenant`                       | Authenticate to the Access Control Policies service |
| `Get-UAPPolicy`                           | Get access policies                                 |
| `New-UAPPolicy`                           | Create an access policy                             |
| `Set-UAPPolicy`                           | Update an access policy                             |
| `Remove-UAPPolicy`                        | Delete an access policy                             |
| `Test-UAPPolicy`                          | Validate an access policy                           |
| `New-UAPPrincipalDefinition`              | Define an identity a policy applies to              |
| `New-UAPConditionDefinition`              | Define the access conditions of a policy            |
| `New-UAPCloudConsoleTargetDefinition`     | Define a cloud console target                       |
| `New-UAPVirtualMachineTargetDefinition`   | Define the virtual machine targets                  |
| `New-UAPDatabaseTargetDefinition`         | Define a database instance target                   |
| `New-UAPClusterTargetDefinition`          | Define a Kubernetes cluster target                  |
| `New-UAPGroupTargetDefinition`            | Define an Entra ID group target                     |
| `New-UAPVirtualMachineBehaviorDefinition` | Define how members connect to a VM target           |
| `Get-UAPModuleData`                       | Get the module version & session configuration data |

## Installation

### Prerequisites

- Requires Powershell Core (recommended), or Windows PowerShell (version 5.1)
- A CyberArk Identity tenant with the Access Control Policies service enabled
- An Account to Access CyberArk Identity

### Install Options

Users can install IdentityCommand.UAP from GitHub or the PowerShell Gallery.

Choose any of the following ways to download the module and install it:

#### Option 1: Install from PowerShell Gallery

This is the easiest and most popular way to install the module:

1. Open a PowerShell prompt

2. Run the following command:

```powershell
Install-Module -Name IdentityCommand.UAP -Scope CurrentUser
```

#### Option 2: Manual Install

The module files can be manually copied to one of your PowerShell module directories.

Use the following command to get the paths to your local PowerShell module folders:

```powershell

$env:PSModulePath.split(';')

```

The module files must be placed in one of the listed directories, in a folder called `IdentityCommand.UAP`.

More: [about_PSModulePath](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_psmodulepath)

The module files are available to download using a variety of methods:

##### PowerShell Gallery

- Download from the module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/IdentityCommand.UAP/):
  - Run the PowerShell command `Save-Module -Name IdentityCommand.UAP -Path C:\temp`
  - Copy the `C:\temp\IdentityCommand.UAP` folder to your "Powershell Modules" directory of choice.

##### IdentityCommand.UAP Release

- [Download the latest GitHub release](https://github.com/pspete/IdentityCommand.UAP/releases/latest)
  - Unblock & Extract the archive
  - Rename the extracted `IdentityCommand.UAP-v#.#.#` folder to `IdentityCommand.UAP`
  - Copy the `IdentityCommand.UAP` folder to your "Powershell Modules" directory of choice.

##### IdentityCommand.UAP Branch

- [Download the `main` branch](https://github.com/pspete/IdentityCommand.UAP/archive/refs/heads/main.zip)
  - Unblock & Extract the archive
  - Copy the `IdentityCommand.UAP` (`\<Archive Root>\IdentityCommand.UAP-main\IdentityCommand.UAP`) folder to your "Powershell Modules" directory of choice.

#### Verification

Validate Install:

```powershell

Get-Module -ListAvailable IdentityCommand.UAP

```

Import the module:

```powershell

Import-Module IdentityCommand.UAP

```

List Module Commands:

```powershell

Get-Command -Module IdentityCommand.UAP

```

Get detailed information on specific commands:

```powershell

Get-Help Connect-UAPTenant -Full

```

## Sponsorship

Please support continued development; consider sponsoring <a href="https://github.com/sponsors/pspete"> @pspete on GitHub Sponsors</a>

## Changelog

All notable changes to this project will be documented in the [Changelog](CHANGELOG.md)

## Author

- **Pete Maan** - [pspete](https://github.com/pspete)

## License

This project is [licensed under the MIT License](LICENSE.md).

## Contributing

Any and all contributions to this project are appreciated.

See the [CONTRIBUTING.md](CONTRIBUTING.md) for a few more details.

## Support

_IdentityCommand.UAP_ is neither developed nor supported by CyberArk; any official support channels offered by the vendor are not appropriate for seeking help with the _IdentityCommand.UAP_ module.

Help and support should be sought by [opening an issue][new-issue].

[new-issue]: https://github.com/pspete/IdentityCommand.UAP/issues/new

Priority support could be considered for <a href="https://github.com/sponsors/pspete">sponsors of @pspete</a>, <a href="mailto:pspete@pspete.dev">contact us</a> to discuss options.
