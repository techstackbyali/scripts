# Read-only Windows Company Portal / Intune Win32 app triage.
# This script does not sync, restart services, remove files, or upload logs.
[CmdletBinding()]
param(
    [ValidatePattern('^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')]
    [string]$AppId,

    [ValidateRange(100, 10000)]
    [int]$TailLines = 1000
)

$ErrorActionPreference = 'Stop'
$logRoot = Join-Path $env:ProgramData 'Microsoft\IntuneManagementExtension\Logs'
$logNames = @(
    'IntuneManagementExtension.log',
    'AppWorkload.log',
    'AppActionProcessor.log'
)

Write-Output 'Company Portal "Download pending" - read-only triage'
Write-Output ('Checked at: {0}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'))
Write-Output 'Scope: Windows Company Portal app installs. IME checks below apply to Win32 apps.'
Write-Output ''

try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    Write-Output ('Windows: {0}, build {1}' -f $os.Caption, $os.BuildNumber)
} catch {
    Write-Output ('Windows version: unavailable ({0})' -f $_.Exception.Message)
}

try {
    $portal = Get-AppxPackage -Name Microsoft.CompanyPortal -ErrorAction Stop
    if ($portal) {
        Write-Output ('Company Portal: installed for the current user, version {0}' -f $portal.Version)
    } else {
        Write-Output 'Company Portal: not found for the current user. Check the account running this script.'
    }
} catch {
    Write-Output ('Company Portal package check: unavailable ({0})' -f $_.Exception.Message)
}

$ime = Get-Service -Name IntuneManagementExtension -ErrorAction SilentlyContinue
if ($ime) {
    Write-Output ('Intune Management Extension: {0}' -f $ime.Status)
    Write-Output 'Expected for a targeted Win32 app: the extension is present and normally running.'
} else {
    Write-Output 'Intune Management Extension: not found. Confirm the app is Win32 and correctly targeted before treating this as a fault.'
}

Write-Output ''
Write-Output ('IME log folder: {0}' -f $logRoot)
if (-not (Test-Path -LiteralPath $logRoot -PathType Container)) {
    Write-Output 'IME log folder not found. Store apps can use a different delivery path.'
} else {
    foreach ($name in $logNames) {
        $path = Join-Path $logRoot $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            Write-Output ('{0}: not found' -f $name)
            continue
        }

        try {
            $file = Get-Item -LiteralPath $path
            Write-Output ('{0}: last written {1:yyyy-MM-dd HH:mm:ss}, {2:N0} bytes' -f $name, $file.LastWriteTime, $file.Length)
            if ($AppId) {
                # Count only recent lines. A zero count is a clue, not proof of failed targeting.
                $recent = @(Get-Content -LiteralPath $path -Tail $TailLines -ErrorAction Stop)
                $hits = @($recent | Where-Object { $_.IndexOf($AppId, [StringComparison]::OrdinalIgnoreCase) -ge 0 })
                Write-Output ('  App ID {0}: {1} matching lines in the last {2} lines' -f $AppId, $hits.Count, $TailLines)
            }
        } catch {
            Write-Output ('{0}: could not read ({1})' -f $name, $_.Exception.Message)
        }
    }
}

Write-Output ''
Write-Output 'Next checks:'
Write-Output '1. In Company Portal, Settings > Sync. Then revisit the app status.'
Write-Output '2. If progress has not changed for two hours, use Restart installation if offered.'
Write-Output '3. In Intune, compare assignment, requirements, dependencies, install status, and error code.'
Write-Output '4. For Win32 apps, inspect AppWorkload.log and AppActionProcessor.log at the attempt time.'
Write-Output '5. If content transfer fails, review current Microsoft Intune network endpoint requirements.'
Write-Output '6. If installation begins and fails, investigate the installer and detection rule instead.'
Write-Output ''
Write-Output 'This script does not identify a single root cause. Do not post raw device logs publicly.'

