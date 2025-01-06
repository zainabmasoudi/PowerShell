<#
Script Name: configure-dc1.ps1
Description: This script configures domain controller, install DHCP and synchronies time with the local NTP server.
Author: Zainab 
Date: 2024-12-18
Version: 1.0

Prerequisites:
 - PowerShell running as Administrator
 - Proper network interface and IP configuration
 - Windows server version that supports AD DS features

Parameters:
  $SERVERNAME : Name of the first Domain Controller (e.g., DC1).
  $FOREST : Domain forest (e.g., ho.electric-petrole.ie).

Usage:
Run this script as Administrator on a clean windows server to set up DC1, and promote your server to the domian controller.
#>
$SERVERNAME = "DC1"
$FOREST = "ho.electric-petrole.ie"
$DNSNAME = $SERVERNAME + "." + $FOREST

# Set the IP address for the DC
Rename-Computer -NewName $SERVERNAME
Get-NetIPAddress
New-NetIPAddress -InterfaceIndex 16 -IPAddress 192.168.239.20
-PrefixLength 24 -DefaultGateway 192.168.239.2
Restart-Computer

# Configure AD, DNS
Install-ADDSForest -DomainName $FOREST
Install-WindowsFeature DHCP -IncludeManagementTools

# Configure DHCP, add a single scope
Add-DhcpServerInDC -DnsName $DNSNAME -IPAddress 192.168.239.20
Add-DhcpServerv4Scope -Name InfraServers -StartRange 192.168.239.100  -EndRange 192.168.239.200 -SubnetMask 255.255.255.0

# Set time to sync'h with a local NTP server.
w32tm /config /manualpeerlist:192.168.239.20 /syncfromflags:manual /update