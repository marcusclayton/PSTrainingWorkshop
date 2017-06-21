#region: Finding and running basic commands
    #wildcards
    get-command *process*
    #Find source module
    #Get all commands from module
    get-command -Module "Microsoft.PowerShell.Management"
    #Module Exploration
    Get-Module -ListAvailable

#endregion

#region: Using PS Help, syntax, examples, parameters

    ############################################################
    ####################                    ####################
                        ## MOST IMPORTANT ##
    ####################                    ####################
    ############################################################


    #Found commands --> Explore usage
    #Sections: Name, Synopsis, Syntax (Parameter Sets), Description, Related Links/Commands, Remarks, Examples

    #Compare details
    get-help get-item
    get-help get-item -Examples
    get-help get-item -detailed     #More info than standard
    get-help get-item -full         #Full parameter usage details
    get-help get-item -ShowWindow   #Full with UI

    #Updating help: Missing info, new system, new module
    #Online of offline using 'source' (save-help)
    update-help -Module Azure
    update-help -Confirm:$false -Verbose

    help about*                     #One of the best resources to learn new techniques, explore

    #Example: Learned breaking out of loops to a controlled/predictable location

    help about_break -Examples

#endregion

#region: Using console/ISE, editors like VSCode.when? why?
    #components within ISE
        #Script pane, output
        #***** Running someone's code *****
        #single line execution
        #multi-line execution
        #entire script
        #breakpoints/debugging (better in VS Code)

        #scratch pad
        #authoring: scripts, functions,modules

#endregion

#region: Working with Pipeline, exporting, importing, converting data
    #PS Help Defines Pipeline as:
    <#
        A pipeline is a series of commands connected by pipeline operators |
        Each pipeline operator sends the results of the preceding command to the next command.
        You can use pipelines to send the objects that are output by one command
        to be used as input to another command for processing. And you can send the
        output of that command to yet another command. The result is a very powerful
        command chain or "pipeline" that is comprised of a series of simple commands.

        For example,

        Command-1 | Command-2 | Command-3
        "Get List of Processes" | "Filter List of Processes" | "Restart Processes"
    #>
    # Filter objects out of the pipeline
    get-childitem C:\GitRepos\PSTrainingWorkshop\Support\Filtering
    get-childitem C:\GitRepos\PSTrainingWorkshop\Support\Filtering -Recurse | Where-Object -Property Name -like "*.csv"
    get-childitem C:\GitRepos\PSTrainingWorkshop\Support\Filtering -Recurse | Where-Object {$_.name -like '*.csv'}

    #Enumerating objects in the pipeline
    get-childitem C:\GitRepos\PSTrainingWorkshop\Support\Filtering -Recurse | ?{$_.name -like "*.csv"} | select-object fullName

    #Task: Examine commands --> predict their output

    #How Pipeline works (passing data ByValue, ByPropertyName)
    <#
        -- ByValue: Parameters that accept input "by value" can accept piped objects
            that have the same .NET type as their parameter value or objects that can be
            converted to that type.

            For example, the Name parameter of Start-Service accepts pipeline input
            by value. It can accept string objects or objects that can be converted to
            strings.

        -- ByPropertyName: Parameters that accept input "by property name" can accept piped
            objects only when a property of the object has the same name as the parameter.

            For example, the Name parameter of Start-Service can accept objects that have
            a Name property.

            (To list the properties of an object, pipe it to Get-Member.)

        Some parameters can accept objects by value or by property name. These parameters are
        designed to take input from the pipeline easily.
     #>

     #When commands error out due to pipeline issues, PowerShell is good about specifying a "pipeline" error.
     #Exactly what is going wrong can be pinpointed by looking at each commands parameter attributes (byvalue bypropertyName) 
     # OR
     #using Trace-Command
     #Boe Prox: https://blogs.technet.microsoft.com/heyscriptingguy/2014/12/04/trace-your-commands-by-using-trace-command/

        $Names = @(
        'ParameterBinderBase',
        'ParameterBinderController',
        'ParameterBinding',
        'TypeConversion'
        )

        Trace-Command -Name $Names -Expression {'10/10/2014' | Get-Date} -PSHost

        #lines of interest
        #1: Check on the ParameterSetName
        DEBUG: ParameterBinderController Information: 0 :  WriteLine   CurrentParameterSetName = net
        DEBUG: ParameterBinderController Information: 0 :  WriteLine   CurrentParameterSetName = net

        #2: Checks Mandatory Parameters
        DEBUG: ParameterBinding Information: 0 : MANDATORY PARAMETER CHECK on cmdlet [Get-Date]

        #3: Check to see if object is [datetime] object
        DEBUG: ParameterBinding Information: 0 :     Parameter [Date] PIPELINE INPUT ValueFromPipeline NO COERCION

        #4: Check to see if property name is Date and is [datetime]
        DEBUG: ParameterBinding Information: 0 :     Parameter [Date] PIPELINE INPUT ValueFromPipelineByPropertyName NO COERCION
        DEBUG: ParameterBinding Information: 0 :     Parameter [Date] PIPELINE INPUT ValueFromPipelineByPropertyName NO COERCION

        #5: Attempts to convert object to [datetime] object
        DEBUG: ParameterBinding Information: 0 :     Parameter [Date] PIPELINE INPUT ValueFromPipeline WITH COERCION

        #6: Successfull conversion to [datetime] object
        DEBUG: ParameterBinding Information: 0 :             CONVERT SUCCESSFUL using LanguagePrimitives.ConvertTo: [10/10/2014 12:00:00 AM]

        #Failing example
        Trace-Command -Name $Names -Expression {Get-ChildItem | Select -first 1 | Move-Item C:\temp\temp\temp\ –WhatIf} -PSHost
        Trace-Command -Name $Names -Expression {Get-ChildItem | Select -first 1 | Move-Item -destination C:\temp\temp\temp\ –WhatIf} -PSHost

        #This is where positional parameters come into play. 
        #The path specified is binding first to the first parameter in the list (in this case, –Path).
        #That means that the incoming data from Get-ChildItem now has to find a parameter to bind to
        #because Path has been taken, and it ends up failing.
        #We need to specify the –Destination parameter for the destination path for this to properly work:

    #Single Line, or multi-line for readability

    Get-ChildItem -path *.csv -recurse | Where-Object {$_.name -like "*.csv"} | Sort-Object -property name -Descending | Format-Table -property name, length

     Get-ChildItem -path *.csv -recurse |       #Get All CSV's
     Where-Object {$_.name -like "*.csv"} |     #Filter results
     Sort-Object -property name -Descending |   #Sort the list by their name, in descending order
     Format-Table -property name, length        #format the output as a table

#endregion

#region: Understanding and using PSProviders, PSDrives

    #Providers: HKLM, HKCU, Env, "C", Cert
    <# Description
        Windows PowerShell providers are Microsoft .NET Framework-based programs
        that make the data in a specialized data store available in Windows
        PowerShell so that you can view and manage it.


        The data that a provider exposes appears in a drive, and you access the
        data in a path like you would on a hard disk drive. You can use any of the
        built-in cmdlets that the provider supports to manage the data in the
        provider drive. And, you can use custom cmdlets that are designed
        especially for the data.
    #>

    <# Interacting with providers/drives
        CHILDITEM CMDLETS
            Get-ChildItem

        CONTENT CMDLETS
            Add-Content
            Clear-Content
            Get-Content
            Set-Content

        ITEM CMDLETS
            Clear-Item
            Copy-Item
            Get-Item
            Invoke-Item
            Move-Item
            New-Item
            Remove-Item
            Rename-Item
            Set-Item

        ITEMPROPERTY CMDLETS
            Clear-ItemProperty
            Copy-ItemProperty
            Get-ItemProperty
            Move-ItemProperty
            New-ItemProperty
            Remove-ItemProperty
            Rename-ItemProperty
            Set-ItemProperty

        LOCATION CMDLETS
            Get-Location
            Pop-Location
            Push-Location
            Set-Location

        PATH CMDLETS
            Join-Path
            Convert-Path
            Split-Path
            Resolve-Path
            Test-Path

        PSDRIVE CMDLETS
            Get-PSDrive
            New-PSDrive
            Remove-PSDrive

        PSPROVIDER CMDLETS
            Get-PSProvider
    #>

    <# PSProviders/Drives Example
        get-childitem Cert:\LocalMachine\My
        set-location Cert:\LocalMachine\My
    #>

#endregion

#region: Formatting (Output)
    #basic
    #Advanced
    #redirecting formatted Output
#endregion

#region: WMI/CIM
    #using WMI or CIM?
    # CIM = WMI = CIM
    #CIM provides a common definition of management information for 
    #systems, networks, applications, and services, and it allows for vendor extensions.
    #WMI is the Microsoft implementation of CIM for the Windows platform.
    #The big drawback to the WMI cmdlets is that they use DCOM to access remote machines.
    #DCOM isn’t firewall friendly, can be blocked by networking equipment,
    #and gives some arcane errors when things go wrong.
    #The big difference between the WMI cmdlets and the CIM cmdlets is that
    #the CIM cmdlets use WSMAN (WinRM) to connect to remote machines.
    #In the same way that you can create PowerShell remoting sessions,
    #you can create and manage CIM sessions by using these cmdlets:

    Get-CimSession
    New-CimSession
    New-CimSessionOption
    Remove-CimSession
    #Commands
    Get-CimInstance
    Invoke-CimMethod
    Register-CimIndicationEvent
    Remove-CimInstance
    Set-CimInstance

    Get-WmiObject -Class Win32_OperatingSystem | select LastBootUpTime
    Get-WmiObject -Class Win32_OperatingSystem | select @{N=’LastBootTime’; E={$_.ConvertToDateTime($_.LastBootUpTime)}}

    Get-CimInstance -ClassName Win32_OperatingSystem | select LastBootUpTime

    #Invoking CIM Methods
    #Launch
    Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine='notepad.exe'; CurrentDirectory='C:\temp'}

    #Find and Close
    Get-CimInstance -Class Win32_Process -Filter “Name='notepad.exe'”
    Get-CimInstance -Class Win32_Process -Filter “Name='notepad.exe'” | Invoke-CimMethod -MethodName Terminate
        #Understanding
        #Querying
        #Making Changes
        #Locate and Query WMI Classes to retrieve Management Information
#endregion

#region: Preparing for scripting
    #variables
    #scripting security
    #create and use alternate credentials
    #execution policy
    #Code Signing
    New-SelfSignedCertificate -CertStoreLocation cert:\currentuser\my `
        -Subject "CN=SelfSigningDemo" `
        -KeyAlgorithm RSA `
        -KeyLength 2048 `
        -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
        -KeyExportPolicy Exportable `
        -KeyUsage DigitalSignature `
        -Type CodeSigningCert `
        -Verbose

    $cert = @(Get-ChildItem cert:\CurrentUser\My -CodeSigning)[0]
    $scriptPath = ""
    Set-AuthenticodeSignature  -FilePath $scriptPath -Certificate $cert -Verbose
    #On remote machine:
    Get-ExecutionPolicy #RemoteSigned by default
    #Test running the unsigned script
    #Test running the signed script
    #Add CER to current user trusted publishers and trust root CAs
    #Test running the script
#endregion

#region: Move from commands/scripts to functions/modules
    #Commands --> Scripts --> Functions
    #Basic scripting constructs
    #Convert a functioning command into a parameterized script
    #Convert script to function
    #Encapsulate a Script into a Function, Turn the script into a Module and add debugging
    #Adding Logic to a script
    try{
        #Long Running memory intensive code
    }
    catch [System.OutOfMemoryException]{
        #Decide what to do when this terminating error arises
    }
    catch{
        #Everything else
        $errMsg = $_.Exception.Message
        $failItem = $_.Exception.ItemName
        Send-MailMessage @Params
        Break
    }
    Finally{
        #Runs every time, regardless of errors
    }

#endregion

#region: Administering Remote Computers
    #Use basic remoting
    #Using remoting sessions
    #Using remoting for delegated administration
        #https://blogs.technet.microsoft.com/heyscriptingguy/2014/04/02/build-constrained-powershell-endpoint-using-configuration-file/
        #https://blogs.technet.microsoft.com/heyscriptingguy/2014/04/03/use-delegated-administration-and-proxy-functions/

    #Enable remoting
    #Remotely managing machines
    #Import a module from a remote machine
    $session = new-pssession -computer "Win2008R2"
    #Test, find module we want
    Invoke-Command -session $s -script { Import-Module ActiveDirectory }
    #Implicit Remoting
    #Prefix, or no prefix
    Import-PSSession -session $session -module ActiveDirectory
    Import-PSSession -session $session -module ActiveDirectory -prefix Pre
    #As long as session is active, commands/module is available
    Get-PreADUser -filter * -searchbase "cn=_NotMachines,dc=automation,dc=ai"
    $session | Remove-PSSession

    #Establish and use connections with several computers
    #create, register and test custom session configurations
#endregion

#region: Jobs

    <#
    Register-ScheduledJob -Name UpdateHelpJob -Credential Domain01\User01 -ScriptBlock {Update-Help} -Trigger (New-JobTrigger -Daily -At "3 AM")
    Id         Name            JobTriggers     Command                                  Enabled
    --         ----            -----------     -------                                  -------
    1          UpdateHelpJob   1               Update-Help                              True

    This command creates a scheduled job that updates help for all modules on the computer every day at 3:00 in the morning.

    The command uses the Register-ScheduledJob cmdlet to create a scheduled job that runs an Update-Help command. The command uses the Credential parameter to run Update-Help by using the credentials
    of a member of the Administrators group on the computer. The value of the Trigger parameter is a New-JobTrigger command that creates a job trigger that starts the job every day at 3:00 AM.

    To run the Register-ScheduledJob command, start Windows PowerShell by using the Run as administrator option. When you run the command, Windows PowerShell prompts you for the password of the user
    specified in the value of the Credential parameter. The credentials are stored with the scheduled job. You are not prompted when the job runs.

    You can use the Get-ScheduledJob cmdlet to view the scheduled job, use the Set-ScheduledJob cmdlet to change it, and use the Unregister-ScheduledJob cmdlet to delete it. You can also view and
    manage the scheduled job in Task Scheduler in the following path: Task Scheduler Library\Microsoft\Windows\PowerShell\ScheduledJobs.
    #>

#engregion