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

        [switch] $doNotOpen,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("EvtxFile", "InProcess")]
        [string] $OutputType = "EvtxFile"
    )

    Process {

        Write-Host "Getting event log for $containername"

        if ($doNotOpen) {
            Write-Warning "The parameter 'doNotOpen' is not supported and is always treated as '`$true'"
        }

        $Session = New-PSSession -ContainerId (Get-BcContainerId $containerName) -RunAsAdministrator
        try {

            if ($OutputType -ieq "EvtxFile") {
                $Filename = $containerName + ' ' + [DateTime]::Now.ToString("yyyy-MM-dd HH.mm.ss") + ".evtx"
                $ContainerFilename = Invoke-Command -Session $Session -ScriptBlock { 
                    Param([string]$logname)
                    $LocalFilename = "$env:TEMP\$([Guid]::NewGuid()).evtx"
                    $EventSession = New-Object System.Diagnostics.Eventing.Reader.EventLogSession 
                    $EventSession.ExportLog($LogName, "LogName", "*", $LocalFilename)
                    Write-Output $LocalFilename
                } -ArgumentList $logname

                $HostFilename = "$env:TEMP\$Filename"
                Copy-Item -FromSession $Session -Path $ContainerFilename -Destination $HostFilename -Force
                Write-Output $HostFilename
            }

            if ($OutputType -ieq "InProcess") {
                $Result = Invoke-Command -Session $Session -ScriptBlock { 
                    Param([string] $logname) 
                    Get-EventLog -LogName $logname -Newest 1024
                } -ArgumentList $logname
                Write-Output $Result
            }
        }
        finally {
            if ($Session) { Remove-PSSession $Session }
        }
    }
}

Set-Alias -Name Get-NavContainerEventLog -Value Get-BcContainerEventLog
Export-ModuleMember -Function Get-BcContainerEventLog -Alias Get-NavContainerEventLog