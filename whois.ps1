<#
whois.ps1
Created by: Chris Wood
Last Updated: Sept 2013

This program is used interate through a domain object container's objects and ping them.
If someone is logged in, it will also return their domain account.

Useful for checking lab usage.

Notes: Probably needs error handling.... :)

#>
Import-Module ActiveDirectory

$lab_number = Read-Host "What lab number? (ie. 372)"

$search = "*L0" + $lab_number + "-*"
$lab_computers = Get-ADComputer -Filter {name -like $search} -SearchBase "OU=UONAME,OU=UONAME,OU=UONAME,OU=UONAME,DC=SUBDOMAIN,DC=DOMAIN,DC=TLD" | Sort Name

foreach ($computer in $lab_computers)
{
	$c = $computer.Name
	$status = gwmi win32_PingStatus -filter "Address = '$c'"

    if ($status.StatusCode -eq 0) { 
    	$user = @(Get-WmiObject -ComputerName $computer.Name -Namespace root\cimv2 -Class Win32_ComputerSystem)[0].UserName;

		if ($user -eq $null)
			{ Write-Host $computer.Name 'up and not in use' -foreground "green" }
		elseif ($user.StartsWith("AD\"))
			{ Write-Host $computer.Name 'up and used by' $user -foreground "red" }
		else
			{ Write-Host $computer.Name 'up and ???:' $user -foreground "magenta" }
		}
    else
    	{ Write-Host $computer.Name 'down' -foreground "red" }
}