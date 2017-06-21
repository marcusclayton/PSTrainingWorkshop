#Define Custom Proxy functions

Function Get-SystemReport {

    $OS = Get-WMIObject -Class Win32_OperatingSystem

    $CS = Get-WMIObject -Class Win32_ComputerSystem

    $StoppedServices = Get-WmiObject -Class Win32_Service -Filter "StartMode='Auto' AND State!='Running'"

    $Disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType='3'"

    $PerfCounters = (Get-Counter "\processor(_total)\% processor time","\Memory\Available Bytes" |

    Select -Expand CounterSamples)

    [pscustomobject]@{

        Computername = $env:COMPUTERNAME

        OSCaption = $OS.Caption

        OSVersion = $OS.Version

        Model = $CS.Model

        Manufacture = $CS.Manufacturer

        TotalRAMGB = [math]::Round($CS.TotalPhysicalMemory /1GB,2)

        AvailableRAMGB = [math]::Round(($PerfCounters[1].CookedValue / 1GB),2)

        CPU = [math]::Round($PerfCounters[0].CookedValue,2)

        RunningProcesses = (Get-Process).Count

        LastBootUp = $OS.ConvertToDateTime($OS.LastBootUpTime)      

        Drives = $Disk | Select DeviceID, VolumeName,

            @{L='Size';E={[math]::Round($_.Size/1GB,2)}},

            @{L='FreeSpace';E={[math]::Round($_.FreeSpace/1GB,2)}}

        StoppedServices = $StoppedServices | Select Name, DisplayName, State

    }

}

#Proxy functions

[string[]]$proxyFunction = 'Get-SystemReport','Get-Command'

#Cmdlets

ForEach ($Command in (Get-Command)) {

    If (($proxyFunction -notcontains $Command.Name)) {

        $Command.Visibility = 'Private'

    }

}

#Variables

Get-Variable | ForEach {   

    $_.Visibility = 'Private'

}

#Aliases

Get-Alias | ForEach {   

    $_.Visibility = 'Private'

}

$ExecutionContext.SessionState.Applications.Clear()

$ExecutionContext.SessionState.Scripts.Clear()

$ExecutionContext.SessionState.LanguageMode = "NoLanguage"