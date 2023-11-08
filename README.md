# Cisco Anyconnect conectivity keeper for WSL

This script ensures the connectivity on your WSL distro is not lost whenever you connect or disconnect your Cisco Anyconnect client on your Windows host.

## Problem

You are a developer that uses Linux for all your dev work.

You are however given a Windows laptop by your IT department since they don't support Linux.

Your company uses Cisco Anyconnect for their VPN access, so they preinstall it on your Windows laptop and they don't have a Linux version of it.

You decide the next best thing to running Linux on your Windows laptop is to use WSL.

You need to access corporate resources from your WSL that are only available when connected to the VPN (ie: access to Git).

Unfortunately, WSL does not automatically configure its network settings automatically whenever you connect/disconnect to/from the VPN on the Windows host, so each time you connect/disconnect to/from the VPN you'll loose connectivity on the WSL until you manually re-configure networking on the WSL.

This rapidly becomes a PITA

## Solution

Create Windows Scheduler tasks that react to Cisco Anyconnect VPN connect/disconnect events, performing the required actions to ensure that internet connectivity is not lost on WSL.

## Howto

1) On your WSL, copy `set-dns.sh` to your home (ie: `/home/<user>/set-dns.sh`) and make sure it has executable permissions.
2) On your Windows host, open Powershell as Administrator and run `setup.ps1`

Now whenever the VPN is connected, the `OnVPNConnect` scheduled task will run and will:

1) Execute `setup-dns.sh`, which reconfigures `/etc/resolv.conf` to make it use your corporation DNS server as the nameserver.
2) Will adjust the Cisco Anyconnect network adapter metric to a higher value than the WSL network adapter `vEthernet (WSL)`.

Now whenever the VPN is disconnected, the `OnVPNDisconnect` scheduled task will run and will:

1) Execute `setup-dns.sh`, which reconfigures `/etc/resolv.conf` to make it use your default network DNS server as the nameserver.
