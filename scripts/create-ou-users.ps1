<#
Script Name: create-ou-users.ps1
Description: This script creates organization Unit and adds users from the csv file. Checks if the user already exists in Active Directory
if not, it will create the new user. The script also creates a security group for the class group and adds the users to this group.
Author: Zainab 
Date: 2024-12-20
Version: 1.0

Prerequisites:
 - PowerShell running as Administrator
 - CVS file containing user data like (username, password, firstname, lastname, department, ou)
 - Active Directory module for Windows PowerShell installed

Parameters:
  $ADUsers: Path to the CSV file containing user data (e.g., C:\PowerShell\\WT3\CLOD2023.csv).
  $Organisation : Name of the parent organization unit where the new OU will be created (e.g., ho.electric-petrole.ie).
  $Classgroup : Name of the group (e.g., "PGDipCLOD2022")

Usage:
on domain controller (DC1), it will create OU and users based on specific data in CVS file. Make sure CVS file is 
formatted properly and includes username, password, firstname, lastname, department, and OU columns.
#>

#Enter a path to your import CSV file
$ADUsers = Import-csv C:\Powershell\WT3\CLOD2023.csv
# Typo in the domain name!!!!
$Organisation = "DC=ho,DC=electric-petrole,DC=ie"
$Classgroup = "PGDipCLOD2022"

# Add OUs for User and for this specific group
New-ADOrganizationalUnit -Name $Classgroup -Path $Organisation -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Users" -Path "OU=$Classgroup,$Organisation" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Groups" -Path "OU=$Classgroup,$Organisation" -ProtectedFromAccidentalDeletion $false

Add an OU for domain servers
New-ADOrganizationalUnit -Name "Servers" -Path "OU=$Classgroup,$Organisation" -ProtectedFromAccidentalDeletion $false

 Create a group for these users
New-ADGroup -Name $Classgroup -Description "PGDip Cloud 2022" -GroupCategory Security -GroupScope DomainLocal -Path "OU=Groups, OU=$Classgroup,$Organisation"

foreach ($User in $ADUsers)
{

       $Username    = $User.username
       $Password    = $User.password
       $Firstname   = $User.firstname
       $Lastname    = $User.lastname
       $Department  = $User.department
       $OU          = $User.ou

       #Check if the user account already exists in AD
       if (Get-ADUser -F {SamAccountName -eq $Username})
       {
               #If user does exist, output a warning message
               Write-Warning "A user account $Username has already exist in Active Directory."
       }
       else
       {
            #If a user does not exist then create a new user account
            #Account will be created in the OU listed in the $OU variable in the CSV file     
            New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@ho.electric-petrole.ie" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -ChangePasswordAtLogon $True `
            -DisplayName "$Lastname, $Firstname" `
            -Department $Department `
            -Path $OU `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force)

            # Add or change any other parameters
            Set-ADUser -Identity $Username -Description "PGDip Student" -Organization "ATU"

            # Add the user to a primary group
            Add-ADGroupMember -Identity $Classgroup -Members $Username
             
       }
}