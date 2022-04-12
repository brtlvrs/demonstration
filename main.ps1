function main {
    <#

    .SYNOPSIS

        Example code for running full script from an URI.

    .DESCRIPTION

        Example code to run a powershell script with dynamic blocks Begin,Process and End.
        Loading parameters from a JSON file into an P object.
        By wrapping the code into the function main, we can use begin, process and end scriptblocks when calling with Invoke-Expression

        The Process block contains the main code to execute.
        The Begin and en blocks are mainly used for setting up the environment and closing it.

    .EXAMPLE
    Run the following cmdline in a powershell session.
    Invoke-Expression (Invoke-webrequest <URL>).content


    .NOTES



    #>

    Begin{
        #=== Script parameters
        #-- GIT repository parameters for loading the parameters.json
        $scriptGitServer = "https://raw.githubusercontent.com/"
        $scriptGitRepository = "brtlvrs/demonstration/"
        $scriptBranch = "template/"
        $scriptrootURI = $scriptGitServer+$scriptGitRepository+$scriptBranch

        #==== No editing beyond this point !! ====
        $ts_start=get-date #-- Save current time for performance measurement

        #-- trying to load parameters into $P object, preferably json style
        try { $webResult= Invoke-WebRequest ($scriptrootURI+"parameters.json")}
        catch {
            throw "Request failed for loading parameters.json"
        }
        if ($webResult.StatusCode -match "^2\d{2}" ) {
            try {
                $P = (Invoke-WebRequest ($scriptrootURI+"parameters.json")).content | ConvertFrom-Json 
            }
            catch {
                throw "Failed to parse webrequest content into JSON"
            }
        } else {
            throw ("Failed to load parameter.json from repository. Got statuscode "+ $webRequest.statusCode)
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

    }
#-- run main function
main