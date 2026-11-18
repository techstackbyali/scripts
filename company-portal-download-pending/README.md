# Company Portal app stuck on Download pending

A read-only PowerShell triage helper for software that remains at **Download pending** inside Windows Company Portal. It does not troubleshoot installation of the Company Portal app itself.

## Run

Open PowerShell on the affected device and run the script from the folder where you saved it:

```powershell
.\Get-CompanyPortalDownloadPending.ps1
```

If your Intune administrator provides the app's GUID, narrow the log check:

```powershell
.\Get-CompanyPortalDownloadPending.ps1 -AppId '00000000-0000-0000-0000-000000000000'
```

Replace the example GUID with the actual app ID. The script reads only the last 1,000 lines of each relevant IME log by default. Use `-TailLines 3000` if the attempt is older. It does not change device state, restart services, clear caches, or send data anywhere.

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
- [Troubleshoot Win32 apps and IME logs](https://learn.microsoft.com/en-us/intune/app-management/deployment/troubleshoot-win32)
- [Troubleshoot Intune app installations](https://learn.microsoft.com/en-us/troubleshoot/mem/intune/app-management/troubleshoot-app-install)
- [Intune network endpoints](https://learn.microsoft.com/en-us/intune/fundamentals/endpoints)

This is an independent helper based on published Microsoft guidance. It is not a Microsoft product and does not claim a reproduced tenant test.

