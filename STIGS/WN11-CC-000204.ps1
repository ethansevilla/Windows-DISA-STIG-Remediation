<#
.SYNOPSIS
    This PowerShell script limits enhanced diagnostic data collection for
    Windows Analytics on Windows 11.

.NOTES
    Author          : Ethan Sevilla
    LinkedIn        : https://www.linkedin.com/in/ethan-sevilla-6540b6150/
    GitHub          : https://github.com/ethansevilla
    Date Created    : 2026-08-05
    Last Modified   : 2026-08-05
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000204

.TESTED ON
    Date(s) Tested  : 2026-08-05
    Tested By       : Ethan Sevilla
    Systems Tested  : Windows 11
    PowerShell Ver. : Windows PowerShell 5.1

.USAGE
    Run PowerShell as Administrator.

    Example syntax:
    PS C:\> .\WN11-CC-000204.ps1
#>

$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
$ValueName = "LimitEnhancedDiagnosticDataWindowsAnalytics"
$RequiredValue = 1

# Verify that PowerShell is running as Administrator.
$CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $CurrentPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

try {
    # Create the registry path if it does not exist.
    if (-not (Test-Path -Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
        Write-Host "Created registry path: $RegistryPath"
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
        Write-Host ""
        Write-Host "WN11-CC-000204 remediation completed successfully."
        Write-Host "Registry Path : $RegistryPath"
        Write-Host "Value Name    : $ValueName"
        Write-Host "Value Type    : REG_DWORD"
        Write-Host "Value Data    : $CurrentValue"
        Write-Host "Status        : Compliant"
        exit 0
    }
    else {
        Write-Error "Verification failed. Expected value 1 but found $CurrentValue."
        exit 1
    }
}
catch {
    Write-Error "WN11-CC-000204 remediation failed: $($_.Exception.Message)"
    exit 1
}
