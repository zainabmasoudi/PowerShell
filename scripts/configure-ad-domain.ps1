<#
Script Name: configure-ad-domain.ps1
Description: This script installs and configures domain controller in DC1.
Author: Zainab 
Date: 2024-12-18
Version: 1.0

Prerequisites:
 - PowerShell running as Administrator
 - Proper network interface and IP configuration
 - Windows server version that supports AD DS features

Usage:
Run this script as Administrator on a clean windows server to install domain controller.
#>
Install-WindowsFeature -name AD-Domain-Services –IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "ho.electric-petrole.ie" `
-DomainNetbiosName "ho" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true

Shutdown /r /t 0