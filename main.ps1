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

    $P = (Invoke-WebRequest ($scriptrootURI+"parameters.ps1")).content

    write-host $P.name
    #-- load functions


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
