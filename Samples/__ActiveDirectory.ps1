#region Task1:Reset a User Password
    ##############################
    ##############################
    ######### Task1 ##############
    ##############################
    ##############################

    $user = "labuser01"
    $passwd = Read-Host "Enter new passwd" -AsSecureString
    Set-ADAccountPassword $user -NewPassword $passwd -verbose

    #Set PW to expire at next logon
    Set-ADUser $user -ChangePasswordAtLogon $True -verbose
    Get-ADUser $user -Properties passwordexpired

    Set-ADAccountPassword $user -NewPassword $passwd -reset -passthru | set-aduser -ChangePasswordAtLogon $True


#endregion Task1

#region Task2:Disable/Enable a User Account
    ##############################
    ##############################
    ######### Task2 ##############
    ##############################
    ##############################

    #Demonstrate whatif

    disable-adaccount $user -whatif
    disable-adaccount $user
    get-aduser $user -properties enabled

    enable-adaccount $user -verbose

    #can be piped together, but this adds more risk. ensure filters and returned objects are what you expect before running any actionable cmdlets (set, enable, disable)
    get-aduser -filter "name -like 'labuser*'" -outvariable users

    get-aduser -filter "name -like 'labuser*'" | disable-adaccount -whatif
    get-aduser -filter "name -like 'labuser*'" | disable-adaccount -verbose

    $users | enable-adaccount -verbose

#endregion Task2


#region:Task3: Unlock a user account
    ##############################
    ##############################
    ######### Task3 ##############
    ##############################
    ##############################

    help unlock-adaccount

    #no help, update help
    get-command unlock-adaccount | select-object source -OutVariable module
    update-help -Module $module.source -verbose

    get-aduser $user -Properties LockedOut

    #lock out user intentionally, UI or script

    unlock-adaccount $user -verbose
    get-aduser $user -Properties LockedOut

#endregion Task3

#region:Task4: Delete a User Account
    ##############################
    ##############################
    ######### Task4 ##############
    ##############################
    ##############################

    Remove-ADUser $user -whatif

    get-aduser -filter "enabled -eq 'false'" -property WhenChanged -SearchBase "OU=_NotMachines,DC=automation,DC=ai" | ?{$_.WhenChanged -le (Get-Date).AddDays(-180)} -OutVariable toDelete
    $toDelete
    #No Members, but we'd pipe it to remove
    $toDelete | Remove-ADuser -whatif

#endregion Task4

#region:Task5: Find Emtpy Groups
    ##############################
    ##############################
    ######### Task5 ##############
    ##############################
    ##############################

    get-adgroup -filter * | where {-Not ($_ | get-adgroupmember)} | Select Name

    get-adgroup -filter "members -notlike '*' -AND GroupScope -eq 'Universal'" -SearchBase "OU=_NotMachines,DC=automation,DC=ai" | Select-object Name,Group*
#endregion Task5

#region:Task6: Add Members to a Group
    ##############################
    ##############################
    ######### Task6 ##############
    ##############################
    ##############################

    add-adgroupmember "EmptyGroup1" -Members "labuser03"

#endregion Task



#region:Task7: Enumerate Group Members
    ##############################
    ##############################
    ######### Task7 ##############
    ##############################
    ##############################

    $users = get-aduser -filter "name -like 'labuser*'"
    #Method 1
    Add-ADGroupMember "emptygroup1" -members $users
    Get-ADGroupMember "emptygroup1"
    Remove-ADGroupMember $users -Identity "emptygroup1"

    #Method 2
    Get-ADUser -filter "name -like 'labuser*'" | foreach {Add-ADGroupMember "emptygroup1" -Members $_ -verbose}
    Get-ADGroupMember "emptygroup1"
    Remove-ADGroupMember $users -Identity "emptygroup1"

    Get-ADGroupMember "Group2" -Recursive | Select-Object DistinguishedName
    #show ADUC
    Get-ADGroupMember "Group3" -Recursive | Select-Object DistinguishedName
    #show ADUC

#endregion Task7

#region:Task8: Find Computes by OS
    ##############################
    ##############################
    ######### Task8 ##############
    ##############################
    ##############################

    Get-ADComputer -Filter * -Properties OperatingSystem | Select-Object OperatingSystem -unique | Sort-Object OperatingSystem

    Get-ADComputer -Filter "OperatingSystem -like

    '*Server*'" -properties OperatingSystem,OperatingSystem

    ServicePack | Select Name,Op* | format-list

#endregion Task


#region:Task9: 
    ##############################
    ##############################
    ######### Task ##############
    ##############################
    ##############################

    Get-ADUser -Filter "Enabled -eq 'True' -AND

    PasswordNeverExpires -eq 'False'" -Properties

    PasswordLastSet,PasswordNeverExpires,PasswordExpired |

    Select DistinguishedName,Name,pass*,@{Name="PasswordAge";

    Expression={(Get-Date)-$_.PasswordLastSet}} |sort

    PasswordAge -Descending | ConvertTo-Html -Title

    "Password Age Report" | Out-File c:\Work\pwage.htm
    <#
    custom property called PasswordAge.
    value is a timespan between today and the PasswordLastSet property.
    sorted the results on my new property.
    #>

#endregion Task

#region:Task: Bulk User Creation From CSV
    ##############################
    ##############################
    ######### Task ##############
    ##############################
    ##############################

    $Users = Import-Csv -Path "C:\temp\bulkUserCreate.csv"
    foreach ($User in $Users){
        $Displayname = $User.'Firstname' + " " + $User.'Lastname'
        $UserFirstname = $User.'Firstname'
        $UserLastname = $User.'Lastname'
        $OU = $User.'OU'
        $SAM = $User.'SAM'
        $UPN = $User.'Firstname' + "." + $User.'Lastname' + "@" + $User.'Maildomain'
        $Description = $User.'Description'
        $Password = $User.'Password'

        New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" -Description "$Description" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $false –PasswordNeverExpires $false -verbose
    }

#endregion Task

#Region
    #Set
    Set-ADAccountExpiration -Identity labuser01 -DateTime '12/10/2013 17:00:00'
    Get-ADUser -Identity labuser01 -Properties AccountExpirationDate | Select-Object -Property SamAccountName, AccountExpirationDate

    #Set to never expire
    Set-ADAccountExpiration -Identity labuser01 -DateTime $null

    #Set account to expire on date
    Get-ADUser -Identity labuser01 -Properties AccountExpirationDate | Select-Object -Property SamAccountName, AccountExpirationDate

    #Non-expiring accounts
    search-adaccount -passwordneverexpires

    search-adaccount -accountinactive -timespan 90.00:00:00
    search-adaccount -LockedOut
    search-adaccount -accountDisabled
#end-region
