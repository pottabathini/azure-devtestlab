[CmdletBinding()]
param
(
    # Enable/Disable Network Level Authentication for a Remote Desktop Host
    [Parameter(Mandatory = $true)]
    [bool] $enabled
)

###################################################################################################
#
# PowerShell configurations
#

# NOTE: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.
#       This is necessary to ensure we capture errors inside the try-catch-finally block.
$ErrorActionPreference = "Stop"

# Ensure we set the working directory to that of the script.
Push-Location $PSScriptRoot

###################################################################################################
#
# Handle all errors in this script.
#

trap
{
    # NOTE: This trap will handle all errors. There should be no need to use a catch below in this
    #       script, unless you want to ignore a specific error.
    $message = $error[0].Exception.Message
    if ($message)
    {
        Write-Host -Object "ERROR: $message" -ForegroundColor Red
    }
    
    # IMPORTANT NOTE: Throwing a terminating error (using $ErrorActionPreference = "Stop") still
    # returns exit code zero from the PowerShell script when using -File. The workaround is to
    # NOT use -File when calling this script and leverage the try-catch-finally block and return
    # a non-zero exit code from the catch block.
    exit -1
}

###################################################################################################
#
# Functions used in this script.
#

function Enable-NLA
{
    [CmdletBinding()]
    param(
    )

    Write-Output 'Enabling NLA.'
    try
    {
        (Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -ComputerName $env:computername -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(1)
        Write-Output 'Successfully enabled NLA.'
    }
    catch
    {
        Write-Output "INFO: Exception while enabling NLA: $($_.Exception.Message)"
    }
}

function Disable-NLA
{
    [CmdletBinding()]
    param(
    )

    Write-Output 'Disabling NLA.'
    try
    {
        (Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -ComputerName $env:computername -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)
        Write-Output 'Successfully disabled NLA.'
    }
    catch
    {
        Write-Output "INFO: Exception while disabling NLA: $($_.Exception.Message)"
    }
}

try {
    Write-Output 'Configuring NLA.'

    if($enabled)
    {
        Enable-NLA
    }
    else {
        Disable-NLA
    }

    Write-Output 'Artifact completed successfully.'
}
finally {
    Pop-Location
}
