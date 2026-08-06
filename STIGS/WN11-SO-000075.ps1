<#
.SYNOPSIS
    This PowerShell script configures the required U.S. Government legal
    notice text to display before console logon on Windows 11.

.NOTES
    Author          : Ethan Sevilla
    LinkedIn        : https://www.linkedin.com/in/ethan-sevilla-6540b6150/
    GitHub          : https://github.com/ethansevilla
    Date Created    : 2026-08-05
    Last Modified   : 2026-08-05
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-SO-000075

.TESTED ON
    Date(s) Tested  : 2026-08-05
    Tested By       : Ethan Sevilla
    Systems Tested  : Windows 11
    PowerShell Ver. : Windows PowerShell 5.1

.USAGE
    Run PowerShell as Administrator.

    Example syntax:
    PS C:\> .\WN11-SO-000075.ps1
#>

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ValueName = "LegalNoticeText"

$RequiredValue = @"
You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.

By using this IS (which includes any device attached to this IS), you consent to the following conditions:

-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.

-At any time, the USG may inspect and seize data stored on this IS.

-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.

-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.

-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. Such communications and work product are private and confidential. See User Agreement for details.
"@

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

    # Create or update the legal notice text as REG_SZ.
    New-ItemProperty `
        -Path $RegistryPath `
        -Name $ValueName `
        -PropertyType String `
        -Value $RequiredValue `
        -Force | Out-Null

    # Verify the configured value.
    $CurrentValue = Get-ItemPropertyValue `
        -Path $RegistryPath `
        -Name $ValueName

    if ($CurrentValue.Trim() -eq $RequiredValue.Trim()) {
        Write-Host ""
        Write-Host "WN11-SO-000075 remediation completed successfully."
        Write-Host "Registry Path : $RegistryPath"
        Write-Host "Value Name    : $ValueName"
        Write-Host "Value Type    : REG_SZ"
        Write-Host "Status        : Compliant"
        exit 0
    }
    else {
        Write-Error "Verification failed. The configured legal notice text does not match the required value."
        exit 1
    }
}
catch {
    Write-Error "WN11-SO-000075 remediation failed: $($_.Exception.Message)"
    exit 1
}
