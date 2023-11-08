<#
.SYNOPSIS
    Creates Windows Scheduler tasks that react to Cisco Anyconnect VPN connect/disconnect events to ensure internet connectivity is not lost on WSL.

.DESCRIPTION
    Whenever Cisco Anyconnect client *connects* to the VPN it logs a Windows Event:

    - Log: Cisco Secure Client - AnyConnect VPN
    - Source: csc_vpnagent
    - EventID: 2039

    Whenever Cisco Anyconnect client *disconnects* to the VPN it logs a Windows Event:

    - Log: Cisco Secure Client - AnyConnect VPN
    - Source: csc_vpnagent
    - EventID: 2037

    By using the Windows Scheduler we can "subscribe" to those events and trigger custom actions.

    Those actions are geared towards retaining internet connectivity on the WSL distro by ensuring:

    - Appropriate nameserver in /etc/resolv.conf on the WSL distro.
    - Appropriate metric is set for the AnyConnect adapter on the Windows host.

.NOTES
    Author: donhector
#>

#Check for permissions to execute actions
if (-not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
    Write-Host -ForegroundColor Red "Error! This script needs administrator permissions to run."
    exit 1
}

Write-Host -ForegroundColor Cyan "Configuring scheduled tasks..."

# Recreate scheduled tasks to trigger scripts on VPN events
Get-ScheduledTask | Where-Object {$_.TaskName -like "OnVpnConnect"} | Unregister-ScheduledTask -Confirm:$false
Get-ScheduledTask | Where-Object {$_.TaskName -like "OnVpnDisconnect"} | Unregister-ScheduledTask -Confirm:$false
# Get-ScheduledTask | Where-Object {$_.TaskName -like "BackupWSL"} | Unregister-ScheduledTask -Confirm:$false

Register-ScheduledTask -XML $(Get-Content .\tasks\OnVpnConnect.xml -raw) -TaskName OnVpnConnect
Register-ScheduledTask -XML $(Get-Content .\tasks\OnVpnDisconnect.xml -raw) -TaskName OnVpnDisconnect
# Register-ScheduledTask -XML $(Get-Content .\tasks\backupWSL.xml -raw) -TaskName BackupWSL

Write-Host -ForegroundColor Green "`nDone!"
