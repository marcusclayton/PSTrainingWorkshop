$computers = Get-ADComputer -Filter * #| ?{$_.name -notlike "lab-000" -and $_.name -notlike "lab-009" -and $_.name -notlike "lab-008" -and $_.name -notlike "lab-006"} | Select-Object -ExpandProperty name
$computers | Sort-Object -Property name

foreach ($computer in $computers){

    $CIMThings = Get-CimInstance Win32_OperatingSystem -ComputerName $computer | select version,caption
    $model = Get-CimInstance Win32_ComputerSystem -ComputerName $computer | select -ExpandProperty model 
    
    $info = New-Object -TypeName PSObject @{
        Computer = $computer
        Version = $CIMThings.version
        Caption = $CIMThings.caption
        Model = $model
    }

   

     $info | Format-List   
}

$computers[0]
$computers.ForEach({

    write $_

})

$computers.Where({$_.name -notlike "*00*"}).dnshostname

$computers = Get-ADComputer -Filter "distinguishedname -like '*London*'"

Invoke-Command -ComputerName laptop01,laptop02 -ScriptBlock {

    cmd /c "msiexec "

}




$CIMThings = Get-CimInstance Win32_OperatingSystem -ComputerName $computer | select version,@{L="OSName";e={$_.caption}}
$CIMThings


Get-CimInstance WIN32_ComputerSystem | select DNSHostName,@{l="MemoryGB";e={[math]::Round( ($_.TotalPhysicalMemory/1GB) )}}