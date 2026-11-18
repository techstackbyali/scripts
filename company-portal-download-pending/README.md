# Company Portal app stuck on Download pending

A PowerShell triage and optional retry helper for software that remains at **Download pending** inside Windows Company Portal. It does not troubleshoot installation of the Company Portal app itself.

## Download and run

1. Open [Get-CompanyPortalDownloadPending.ps1](https://github.com/techstackbyali/scripts/blob/main/company-portal-download-pending/Get-CompanyPortalDownloadPending.ps1) on GitHub. Review the code, then use GitHub's **Download raw file** control to save the `.ps1` file on the affected Windows device.
2. Open PowerShell and change to the folder containing the saved file. For example, if it is in Downloads:

   ```powershell
   Set-Location "$env:USERPROFILE\Downloads"
   ```
3. Run the read-only check below. Open PowerShell **as Administrator** only for the optional retry described later.

Run the script from the folder where you saved it:

```powershell
.\Get-CompanyPortalDownloadPending.ps1
```

If your Intune administrator provides the app's GUID, narrow the log check:

```powershell
.\Get-CompanyPortalDownloadPending.ps1 -AppId '00000000-0000-0000-0000-000000000000'
```

Replace the example GUID with the actual app ID. The script reads only the last 1,000 lines of each relevant IME log by default. Use `-TailLines 3000` if the attempt is older. By default it does not change device state or send data anywhere.

If Windows blocks the downloaded script, ask your IT administrator to review and approve it under your organization's PowerShell policy. Do not change or bypass a managed execution policy just to run this tool.

## Try a Win32 app check-in

If a **Win32 app** has been genuinely stalled, there is no active installation you would interrupt, and the IME service is present, open PowerShell **as Administrator** on that device. Preview the action first:

```powershell
.\Get-CompanyPortalDownloadPending.ps1 -RetryWin32 -WhatIf
```

Then run the retry and accept the PowerShell confirmation prompt:

```powershell
.\Get-CompanyPortalDownloadPending.ps1 -RetryWin32
```

This restarts the running `IntuneManagementExtension` service, or starts it if stopped. [Microsoft documents](https://learn.microsoft.com/en-us/intune/device-management/tools/management-extension-windows) that restarting IME initiates a check-in. Reopen Company Portal and check the app. If progress has not changed for two hours, use **Restart installation** in Company Portal if offered. This script cannot click that app-specific control for you. Do not repeatedly restart IME or run this while another app is actively installing.

The retry can help if the pending state reflects a delayed IME check-in. It cannot repair incorrect targeting, requirements, network access, content delivery, installer commands, or detection rules. For a Microsoft Store app, use Company Portal Sync and the reported error instead; the IME service is specific to Win32 app management. The script does not clear caches, re-enroll the device, or bypass security controls.

## Interpret the result

- **Company Portal not found:** Check the Windows account that ran the script. The package check is for the current user.
- **IME not found:** First confirm the app is a Win32 app and is assigned to this user or device. Store apps may follow a different path.
- **IME present but no recent app-ID lines:** Compare the app assignment, requirements and device check-in in Intune. A zero count in a log tail is only a clue.
- **App-ID lines present:** Use the timestamps in `AppWorkload.log` and `AppActionProcessor.log` to distinguish policy, applicability, download and install stages. The script does not infer a root cause from a count alone.

The logs can include user, device and tenant identifiers. Keep them within your organization's approved support process. Never commit raw logs or diagnostic output to a public GitHub repository.

## Supported next steps

Microsoft recommends a manual sync for stalled work-app downloads. Windows Company Portal can offer **Restart installation** after progress has not changed for two hours. If the app still fails, inspect its Intune installation details and, for Win32 apps, IME logs. Do not clear the IME cache, re-enroll the device or disable security controls as an initial step.

## Microsoft references

- [Sync an enrolled Windows device](https://learn.microsoft.com/en-us/intune/user-help/device-actions/sync-device-windows)
- [Restart a stalled Company Portal installation](https://learn.microsoft.com/en-us/intune/app-management/deployment/)
- [Understand IME and initiate a check-in](https://learn.microsoft.com/en-us/intune/device-management/tools/management-extension-windows)
- [Troubleshoot Win32 apps and IME logs](https://learn.microsoft.com/en-us/intune/app-management/deployment/troubleshoot-win32)
- [Troubleshoot Intune app installations](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-management/troubleshoot-app-install)
- [Intune network endpoints](https://learn.microsoft.com/en-us/intune/fundamentals/endpoints)

This is an independent helper based on published Microsoft guidance. It is not a Microsoft product and does not claim a reproduced tenant test.

