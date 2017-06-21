function Get-UpTime {

    Get-CimInstance -ClassName Win32_OperatingSystem | select -expand LastBootUpTime

}


function Get-FirstService {

    Get-Service | Select-Object -Property name -First 1

}

function Get-FirstProcess {

    Get-Process | Select-Object -Property name -First 1

}