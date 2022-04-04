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
    $scriptGitServer = "https://raw.githubusercontent.com/"
    $scriptGitRepository = "brtlvrs/demonstration/"
    $scriptBranch = "template/"
    $scriptrootURI = $scriptGitServer+$scriptGitRepository+$scriptBranch

    if ((Invoke-WebRequest ($scriptrootURI+"parameters.ps1")).StatusCode -ne 200 ) {
        throw "Failed to find parameter.ps1 file on git repo."
    }

    try {$P = Invoke-Expression (Invoke-WebRequest ($scriptrootURI+"parameters.ps1")).content}
    catch { 
        throw "Failed to load parameter.ps1 file."
    }



    #-- load functions
    function exit-script 
    {
        <#
        .DESCRIPTION
            Clean up actions before we exit the script.
            When log object is available, log runtime and exitcode to it.
            Default exit codes are:
            0 = script finished normal (finished_normal parameter was set when function is called)
            99999 = parent script didn't reached end{} and no exitcode was given when exit-script function is called.
            99998 = execution of cleanupcode scriptblock failed.
        .PARAMETER CleanupCode
            [scriptblock] Unique code to invoke when exiting script.
        .PARAMETER finished_normal
            [boolean] To be used in end{} block to notify that script has fully executed.
        .PARAMETER exitcode
            [string] exitcode to past to parent process. When finished_normal is set, exit code will be 0.
            By default it is 99999. When using the function to exit a script due to an error, you can return an exitcode
        #>
        [CmdletBinding()]
        param(
            [string][Parameter( ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]$exitcode="99999",
            [scriptblock]$CleanupCode, #-- (optional) extra code to run before exit script.
            [switch]$finished_normal #-- set in end{} scriptblock of parent script
        )
    
        #-- check why script is called and react apropiatly
        $finished_normal=$finished_normal -or ($exitcode -eq 0)
        if ($finished_normal) {
            $msg= "Hooray.... finished without any bugs....."
            $exitcode=0 #-- script retuns 0
            if ($log) {$log.verbose($msg)} else {Write-Verbose $msg} #-- log to verbose output and/or log file
        } else {
            $msg= "(1) Script ended with errors."
            if ($log) {$log.error($msg)} else {Write-warning $msg}
        }
    
        #-- General cleanup actions
        if ($CleanupCode) {
            try {Invoke-Expression -Command $CleanupCode -ErrorVariable Err1}
            catch {
                $msg="Failed to execute custom cleanupcode, resulted in error $err1"
                $exitcode= 99998
                if ($log) {$log.warning($msg)} else {write-warning $msg}
            }
    
        }
        #-- calculate runtime
        if ($global:ts_start) {
            #-- Output runtime and say greetings
            $ts_end=get-date
            $msg="Runtime script: {0:hh}:{0:mm}:{0:ss}" -f ($ts_end- $ts_start)  
            if ($log) {$log.verbose($msg)} else {Write-host $msg -ForegroundColor cyan}
        } else {
            $msg= "No ts_start variable found, cannot calculate runtime."
            if ($log) {$log.verbose($msg)} else {write-verbose $msg }
        }
        #-- log exit code
        if ($log) {$log.verbose("Exitcode: $exitcode")} else {write-verbose "Exitcode: $exitcode"}
        #-- exit
        exit $exitcode
    }

}

END{
    exit-script -exitcode 0
}

Process {
write-host "Hello $($P.name)"
}
