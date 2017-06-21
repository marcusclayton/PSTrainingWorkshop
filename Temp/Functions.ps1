function Get-UpTime {

    Get-CimInstance -ClassName Win32_OperatingSystem | select -expand LastBootUpTime

}

function Get-FirstProcess {

    Get-Process | Select-Object -Property name -First 1

}

function Get-ServiceList {
    Param(
        [int]$number,
        [string]$name
    )


    if($number){
       Get-Service | Select-Object -Property name -First $number 
    }
    
    if($name){
        Get-Service -Name $name | select name
    }
    
    else{
        "Something happened"
    }

    
}