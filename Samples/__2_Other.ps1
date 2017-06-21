#Renaming a computer
Rename-Computer -NewName "" -Restart -DomainCredential "" -Verbose


#Restart Computer
#start --> find Power button --> Reason --> Reboot


#Remote Administration, not RDPing into every machine you touch/manage

    Restart-Computer -WhatIf
    #Shut Down
    Stop-Computer -ComputerName <Remote Machine>


Get-NetIPConfiguration
New-NetIPAddress -InterfaceAlias Ethernet -IPAddress 10.0.0.4 -PrefixLength 24 -DefaultGateway 10.0.0.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.0.0.2

Add-Computer -NewName "newHost01" -OUPath "OU=_Machines,DC=automation,DC=ai" -DomainName "automation.ai" -Credential (Get-Credential)


Get-NetAdapterStatistics

#In place of ping
#Ping + Trace Route

#Scenario: "Can I get to an internet/external address Microsoft has set up for testing"
Test-NetConnection

Test-NetConnection 8.8.8.8

#ping will be depracated and aliased to the PS cmdlet
#Connectivity status plus route
Test-NetConnection gizmodo.com -TraceRoute

#In place of telnet
Test-NetConnection smtp.com -port 25

#Unjoin domain and rejoin + Reboot
#No Rigmarole
Test-ComputerSecureChannel -Credential "domain\admin" -Repair

Get-EventLog -LogName System -EntryType Error

#Roles/Features wizard vs
install-windowsfeature file-services -includeallsubfeatures -includemanagementtools 

#Updates
Get-HotFix

#Query OU for server names, piping to get-hotfix for quick on demand auditing

#Snippet
new-isesnippet -force -Title "Password_Prompt" -Description "secure password string" -text "`$Passwd = Read-Host -Message 'Enter the passwd' -asSecureString"
#New window --> Ctrl + J

#DNS
add-dnsserverresourcerecordA -name "Blah" -zoneName "Automation.ai" -allowupdateany -ipv4address "10.4.0.6" -timetolive 01:00:00

#DHCP
#Create Scopes add-dhcp
#Reservation in scope
add-dhcpserverv4reservation -computername host.automation.ai -scopeId 10.4.6.0 -ipaddress 10.4.6.4 -clientID f0-f0-f0-d0-d0-d0 -description "Reservation for John PC"

#File Share
new-smbshare -name SharedFolder -Path C:\SharedFolder -fullaccess Automation\LabAdmin -readaccess automation\labuser01 -verbose

#Comparisons
Compare-Object -ReferenceObject $first -DifferenceObject $second -IncludeEqual -PassThru -OutVariable groupadds

$groupadds.Where({$_.sideindicator -eq '<='}) | %{

 Add-ADGroupMember -Identity "" -Members $_ 
 "added $_ to group Group1" 

}