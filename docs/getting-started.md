---
title: Getting Started
subtitle: Install IdentityCommand.UAP and connect to Access Control Policies
---

## Prerequisites

- Requires Powershell Core (recommended), or Windows PowerShell (version 5.1)
- An Idira Identity tenant with the Access Control Policies service enabled
- An Account to Access Idira Identity
- The `IdentityCommand` module.

## Install Options

Install from the PowerShell Gallery:

```powershell
Install-Module -Name IdentityCommand.UAP -Scope CurrentUser
```

Or download the [latest release](https://github.com/pspete/IdentityCommand.UAP/releases), unblock and extract the archive, and copy the `IdentityCommand.UAP` folder into a path listed in `$env:PSModulePath`.

## Authentication

The module requires authentication to the Idira Identity platform using the `IdentityCommand` module.

The `IdentityCommand` module must be installed and available in order to use `IdentityCommand.UAP`.

The `Connect-UAPTenant` command initialises the bearer token used for module operations against the Access Control Policies service.

If an Identity session already exists (established with the `IdentityCommand` module's `New-IDSession` or `New-IDPlatformToken`), it is used as-is:

```powershell
# Resolve the Access Control Policies url automatically from the shared services subdomain
Connect-UAPTenant -tenant_subdomain sometenant

# Or provide the Access Control Policies tenant url directly
Connect-UAPTenant -tenant_url https://sometenant.uap.cyberark.cloud
```

Otherwise, provide a credential and `Connect-UAPTenant` authenticates to Idira Identity for you - the Identity tenant url is discovered from the same subdomain / url:

```powershell
# Interactive user authentication (any MFA challenges are handled by IdentityCommand)
Connect-UAPTenant -tenant_subdomain sometenant -Credential $Credential

# Non-interactive service user authentication via an OAuth platform token
Connect-UAPTenant -tenant_subdomain sometenant -Credential $ServiceUserCredential -PlatformToken
```
