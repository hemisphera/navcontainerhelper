<# 
 .Synopsis
  Get the Event log from a NAV/BC Container as an .evtx file
 .Description
  Get a copy of the current Event Log from a continer and open it in the local event viewer
 .Parameter containerName
  Name of the container for which you want to get the Event log
 .Parameter logName
  Name of the log you want to get (default is Application)
 .Parameter doNotOpen
  Obtain a copy of the event log, but do not open the event log in the event viewer
 .Example
  Get-BcContainerEventLog -containerName bcserver
 .Example
  Get-BcContainerEventLog -containerName bcserver -logname Security -doNotOpen
#>
function Get-BcContainerEventLog {
    [CmdletBinding()]
    Param (
        [string] $containerName = $bcContainerHelperConfig.defaultContainerName,
        [Parameter(Mandatory = $false)]
        [string] $logname = "Application",
        [switch] $doNotOpen
    )

    Process {

        $doNotOpen = $true # wevutil is not supported on PS Core

        Write-Host "Getting event log for $containername"

        Invoke-ScriptInBcContainer -containerName $containerName -ScriptBlock { 
            Param([string]$logname) 
            Get-EventLog -LogName $logname
        } -ArgumentList $logname

    }
}

Set-Alias -Name Get-NavContainerEventLog -Value Get-BcContainerEventLog
Export-ModuleMember -Function Get-BcContainerEventLog -Alias Get-NavContainerEventLog