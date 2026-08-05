.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author          : Ethan Sevilla
    LinkedIn        : linkedin.com/in/ethansevilla/
    GitHub          : github.com/ethansevilla
    Date Created    : 8/5/2026
    Last Modified   : 8/5/2026
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AU-000500

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-AU-000500.ps1 
#>

# Define the registry path and value
$CurrentUser = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $CurrentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator."
    exit 1
}

# STIG Settings
$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application"
$ValueName = "MaxSize"
$RequiredValue = 32768   # KB (32 MB)

try {

    # Create registry path if it doesn't exist
    if (-not (Test-Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
    }

    # Create or update the registry value
    New-ItemProperty `
        -Path $RegistryPath `
        -Name $ValueName `
        -Value $RequiredValue `
        -PropertyType DWord `
        -Force | Out-Null

    # Verify remediation
    $CurrentValue = (Get-ItemProperty -Path $RegistryPath -Name $ValueName).$ValueName

    if ($CurrentValue -ge $RequiredValue) {
        Write-Host ""
        Write-Host "========================================="
        Write-Host " STIG WN11-AU-000500 COMPLIANT"
        Write-Host "========================================="
        Write-Host "Registry Path : $RegistryPath"
        Write-Host "Value Name    : $ValueName"
        Write-Host "Current Value : $CurrentValue KB"
        Write-Host ""
        exit 0
    }
    else {
        throw "Registry value verification failed."
    }

}
catch {
    Write-Error "Remediation failed: $_"
    exit 1
}
