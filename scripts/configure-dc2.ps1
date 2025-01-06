<#
Script Name: configure-dc2.ps1
Description: This script configures domain controller, joins Windows Server Core (DC2) as member of DC1.
Author: Zainab 
Date: 2024-12-18
Version: 1.0

Prerequisites:
 - PowerShell running as Administrator
 - Proper network interface and IP configuration
 - Windows server Core version that supports AD DS features

Parameters:
  $SERVERNAME : Name of the first Domain Controller (e.g., DC2).
  $FOREST : Domain forest (e.g., ho.electric-petrole.ie).

Usage:
Run this script as Administrator on a clean windows server Core to set up DC2, and make DC2 as member of DC1.
#>
$SERVERNAME = "DC2"
$FOREST = "ho.electri-petrole.ie"
$DNSNAME = $SERVERNAME + "." + $FOREST

# Set the IP address for the DC
Rename-Computer -NewName $SERVERNAME
Get-NetIPAddress
New-NetIPAddress -InterfaceIndex 9 -IPAddress 192.168.239.21 -PrefixLength 24 -DefaultGateway 192.168.239.2
Set-DnsClientServerAddress -InterfaceIndex 9 -ServerAddresses 192.168.239.20
Restart-Computer

# Join the existing Domain
Add-Computer -DomainName $FOREST -Restart

# Install software
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Add this as a second DC
Install-ADDSDomainController -DomainName $FOREST -InstallDns:$true -Credential (Get-Credential "janus\administrator")

# Configure DHCP
Install-WindowsFeature DHCP -IncludeManagementTools
Add-DhcpServerInDC -DnsName $DNSNAME -IPAddress 192.168.239.21