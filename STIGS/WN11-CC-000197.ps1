<#
.SYNOPSIS
    This PowerShell script disables Microsoft consumer experiences on Windows 11
    to remediate STIG WN11-CC-000197.

.NOTES
    Author          : Ethan Sevilla
    LinkedIn        : https://www.linkedin.com/in/ethan-sevilla-6540b6150/
    GitHub          : https://github.com/ethansevilla
    Date Created    : 2026-08-05
    Last Modified   : 2026-08-05
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000197

.TESTED ON
    Date(s) Tested  : 2026-08-05
    Tested By       : Ethan Sevilla
    Systems Tested  : Windows 11
    PowerShell Ver. : Windows PowerShell 5.1

.USAGE
    Run PowerShell as Administrator.

    Example syntax:
    PS C:\> .\WN11-CC-000197.ps1
#>

$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$ValueName = "DisableWindowsConsumerFeatures"
$RequiredValue = 1

# Create the registry path if it does not already exist.
if (-not (Test-Path -Path $RegistryPath)) {
    New-Item -Path $RegistryPath -Force | Out-Null
}

# Create or update the required REG_DWORD value.
New-ItemProperty `
    -Path $RegistryPath `
    -Name $ValueName `
    -PropertyType DWord `
    -Value $RequiredValue `
    -Force | Out-Null

# Verify the configured value.
$CurrentValue = Get-ItemPropertyValue `
    -Path $RegistryPath `
    -Name $ValueName

if ($CurrentValue -eq $RequiredValue) {
    Write-Host "WN11-CC-000197 remediation completed successfully."
    Write-Host "DisableWindowsConsumerFeatures is set to $CurrentValue."
}
else {
    Write-Error "Remediation failed. Expected value: $RequiredValue. Current value: $CurrentValue."
    exit 1
}

