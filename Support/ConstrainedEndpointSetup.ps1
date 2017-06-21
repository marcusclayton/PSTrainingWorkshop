#copy constrainedsessionstartupscript.ps1 to C:\Remote on the machine which will be the "target"
#Add the endpoint RunAs account to the local admin group on the system (can have more limited access if already set up)

#On target machine Run
Register-PSSessionConfiguration -Name PowerShell.ConstrainedSession -StartupScript "C:\remoting\ConstrainedSessionStartupScript.ps1" -RunAsCredential 'automation\endpoint' -ShowSecurityDescriptorUI –Force -verbose
#In the UI Descriptor popup, remove admin and interactive, scoping to just the group/users who will use the endpoint
#Give them 'Invoke' access

#On the source machine
#Fails because we do not have interactive rights
Enter-PSSession –Computername ‘ex01’ –Credential ‘automation\labadmin’ –ConfigurationName PowerShell.ConstrainedSession

#work
Invoke-Command –Computername ‘ex01’ –Credential ‘automation\labadmin’ –ConfigurationName PowerShell.ConstrainedSession -ScriptBlock {Get-Command}
Invoke-Command –Computername ‘ex01’ –Credential ‘automation\labadmin’ –ConfigurationName PowerShell.ConstrainedSession -ScriptBlock {Get-SystemReport}

