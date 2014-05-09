<#
who_installed.ps1
Created by: Chris Wood
Last Updated: Jan 2014

This program is used interate through all programs installed by MsiInstaller and
return the username of the user who installed them.

Useful for tracking down who install games or bloatware.

Notes: Probably needs error handling.... :)
       Best to run in PS ISE so you can resize the window too

#>

$computername = Read-Host "Enter Computer Name"

ForEach-Object {Get-WinEvent -ComputerName $computername -ProviderName "MsiInstaller"} | 
Where-Object { $_.message -ilike "*install*"} | 
ft -AutoSize TimeCreated, UserId, Message

$usersid = Read-Host "Enter User SID"
$objSID = New-Object System.Security.Principal.SecurityIdentifier($usersid) 
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount]) 
$objUser.Value