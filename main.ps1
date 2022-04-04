<#

.SYNOPSIS

    Exclude VMware Tools patches from dynamic patch baselines for VMware ESXi

.DESCRIPTION

    Full description

.PARAMETER <parameter name>



.EXAMPLE



.NOTES



#>

Begin{
    #=== Script parameters
    $vSphereFQDN="vsphere.domain.local"


    #==== No editing beyond this point !! ====
    $ts_start=get-date #-- Save current time for performance measurement

    #-- determine script location and name
    $scriptPath=(get-item (Split-Path -Path $MyInvocation.MyCommand.Definition)).FullName
    $scriptname=(Split-Path -Leaf $MyInvocation.mycommand.path).Split(".")[0]

    #-- load functions
    if (Test-Path -IsValid -Path($scriptpath+"\functions\functions.psm1") ) {
        write-host "Loading functions" -ForegroundColor cyan
        import-module ($scriptpath+"\functions\functions.psm1") -DisableNameChecking -Force:$true #-- the module scans the functions subfolder and loads them as functions
    } else {
        write-verbose "functions module not found."
        exit-script 10
    }
    
    #-- init logging, $log is the log object expected by cmdlets in log-functions.ps1 
    write-host "Initializing logging" -ForegroundColor cyan
    $log=New-LogObject -name $scriptname
    write-logEvent -eventid 11 -message "Script initializing done."
}

END{
    exit-script -exitcode 0
}

Process {
    #-- connect to vSphere server
<#    connect-viserver $vSphereFQDN -ErrorVariable Err1
    if ($err1)
    {
        write-warningEvent -eventid 3 -message "Failed to connect to vCenter service. Error:
        $($err1)"
        exit-script
    }#>
}
