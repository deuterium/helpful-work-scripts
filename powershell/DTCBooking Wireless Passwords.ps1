<#
DTCBooking Wireless Passwords.ps1
Created by: Chris Wood
Last Updated: May 2014

This program is used to generate random passwords for the generic wireless accounts
that are used by the DTC Events department for event attendees and people who rent space
and the accounts.

Program will generate pseudo-random passwords for each account, reset them in AD,
and them email the usernames and passwords to the configured recipients.

Only users that have permission to relevent email in $emailfrom will work.
ie. your own email.

#>

## CONFIGURATION VARIABLES
# people who get the email
$emailrecipients = "sendto@domain.tld", "alsoneedstoknow@domain.tld"
$emailfrom = "sendfrom@domain.tld"

## PROGRAM VARIBLES, DO NOT CHANGE
$accounts = "domain", "accounts", "go", "here"
$dict = "passwords", "removed"
$emailsubject = "Wireless Account Credentials"
$mailserver = "exchange.server.address"
$userpass = @{}
$emailbody = ""
$ErrorActionPreference = "stop"


# generate passwords for user accounts
foreach($a in $accounts)
{
     $b = Get-Random -i $dict
     $c = Get-Random -Minimum 500 -Maximum 599

     $pass = $b + $c
     $userpass[$a] = $pass
}

$emailbody = "The DTC Events wireless account passwords have been reset:"
$emailbody += "`n`n"

# reset passwords in AD
foreach($p in $userpass.GetEnumerator())
{
    $emailbody += "$($p.Key)`t`t$($p.Value)`n"
    $pass = ConvertTo-SecureString -String $p.Value -AsPlainText –Force
    Set-ADAccountPassword -Identity $p.Key -NewPassword $pass –Reset
    #Set-ADAccountPassword -Identity "ADACCOUNT" -Reset -NewPassword (Read-Host -AsSecureString "New Password") #promt for pass
}

$emailbody += "`nThank You,`n"
$emailbody += "ITS - Downtown"
echo $emailbody

# prompt user for email credentials
$prompt = Read-Host "Enter password for $emailfrom`:" -AsSecureString
$creds = New-Object System.Management.Automation.PSCredential($env:USERNAME, $prompt)
try
{
    Send-MailMessage -To $emailrecipients -Subject $emailsubject -Body $emailbody -From $emailfrom -Credential $creds -SmtpServer $mailserver
}
catch
{
    echo "MAIL ERROR: you probably don't have permission to send from `$emailfrom"
    Read-Host "Press ENTER KEY to exit..."
    EXIT
}

echo "`n^^^ ABOVE EMAIL SENT ^^^"
Read-Host "Press ENTER KEYs to exit..."