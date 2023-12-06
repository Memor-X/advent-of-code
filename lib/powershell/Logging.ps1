########################################
#
# File Name:	Logging.ps1
# Date Created:	17/01/2023
# Description:	
#	Function library for logging output
#
########################################

# Global Variables
if($global:logSetting -eq $null)
{
    $global:logSetting = @{
        "showLog" = $true
        "showError" = $true
        "showWarning" = $true
        "showDebug" = $true
    };
}
if($global:startTime -eq $null)
{
    $global:startTime = Get-Date
}


########################################
#
# Name:		Write-Log
# Input:	$msg <Various>
#			$indents <Intenger> [Optional: 0]
#			$color <String> [Optional: "DarkGray"]
#			$key <String> [Optional: "LOG"]
# Output:	Screen Output
# Description:	
#	Outputs text to the screen prefixed with time and $key.
#
########################################
function Write-Log($msg,$indents=0,$color="DarkGray",$key="LOG")
{
    # checks if logging display is enabled (see: $global:logSetting["showLog"])
    if($logSetting.showLog -eq $true)
    {
        # preps message object
        $prefix = "[${key}] $(Get-Date -UFormat "%m/%d/%Y %R")"
        $msgArray = @()

        # checks if $msg is an array and converts it to a 1 element array if so
        if($msg.GetType().BaseType.Name -eq "Array")
        {
            $msgArray = $msg
        }
        else
        {
            $msgArray = @($msg)
        }

        # loops though message object and outputs
        foreach($msgLine in $msgArray)
        {
            Write-Host "${prefix} | $($msgLine.PadLeft($msgLine.Length + $indents,"`t"))" -ForegroundColor $color
        }
    }
}

########################################
#
# Name:		Write-Warning
# Input:	$msg <Various>
#			$indents <Intenger> [Optional: 0]
# Output:	Screen Output (Via Write-Log)
# Description:	
#	Outputs text to the screen formatted as a warning message using preset Write-Log settings.
#
########################################
function Write-Warning($msg,$indents=0)
{
    # checks if warning display is enabled (see: $global:logSetting["showWarning"])
    if($logSetting.showWarning -eq $true)
    {
        Write-Log $msg $indents "Yellow" "WARNING"
    }
}

########################################
#
# Name:		Write-Error
# Input:	$msg <Various>
#			$indents <Intenger> [Optional: 0]
# Output:	Screen Output (Via Write-Log)
# Description:	
#	Outputs text to the screen formatted as an error message using preset Write-Log settings.
#
########################################
function Write-Error($msg,$indents=0)
{
    # checks if error display is enabled (see: $global:logSetting["showError"])
    if($logSetting.showError -eq $true)
    {
        Write-Log $msg $indents "Red" "ERROR"
    }
}

########################################
#
# Name:		Write-Success
# Input:	$msg <Various>
#			$indents <Intenger> [Optional: 0]
# Output:	Screen Output (Via Write-Log)
# Description:	
#	Outputs text to the screen formatted as a success message using preset Write-Log settings.
#
########################################
function Write-Success($msg,$indents=0)
{
    Write-Log $msg $indents "Green" "SUCCESS"
}

########################################
#
# Name:		Write-Debug
# Input:	$msg <Various>
#			$indents <Intenger> [Optional: 0]
# Output:	Screen Output (Via Write-Log)
# Description:	
#	Outputs text to the screen formatted as a debug message using preset Write-Log settings.
#
########################################
function Write-Debug($msg,$indents=0)
{
    # checks if error display is enabled (see: $global:logSetting["showDebug"])
    if($logSetting.showDebug -eq $true)
    {
        Write-Log $msg $indents "Cyan" "DEBUG"
    }
}


########################################
#
# Name:		Write-Start
# Input:	N/A
# Output:	Screen Output
# Description:	
#	Outputs Start Script Success Formatted message while storing the time the start time 
#   (when the function was called)
#
########################################
function Write-Start()
{
    Write-Log "Script Start"

    # stores time function was called
    $startTime = Get-Date
    Write-Debug "Start Time = ${startTime}"
}

########################################
#
# Name:		Write-End
# Input:	N/A
# Output:	Screen Output
# Description:	
#	Outputs End Script Success Formatted message while displaying duration between time Write-Start 
#   was called and Write-End was called
#
########################################
function Write-End()
{
    $endTime = Get-Date
    Write-Debug "End Time = ${endTime}"
    $duration = $endTime - $startTime
    Write-Success "Script End. Runtime = $($duration.TotalSeconds)"
}


########################################
#
# Name:		Gen-Block
# Input:	$title <String>
#			$msgs <Array>
# Output:	$logBlock <Array>
# Description:	
#	ouputs an array of log formatted messages between a title and a footer bar
#
########################################
function Gen-Block($title,$msgs)
{
    # sets up settings for generating the title and footer bar
    $buffer = "-"
    $bufferLength = 25
    $bufferMin = 5*$buffer.Length # buffers will always repeat atleast 5 times on either side
    $headerWrap = "<>"

    $logBlock = @()

    # calculates how big the header will be
    $titleLength = $title.Length
    $headerLength = ($titleLength+($bufferMin*2)+$headerWrap.Length)

    # updates buffer length if the header is longer
    if($headerLength -gt $bufferLength)
    {
        $bufferLength = $headerLength
    }

    # calculates the left right buffer length. if odd, rounds the numbers
    $headerPad = $bufferLength - ($titleLength+$headerWrap.Length)
    $headerPadLeft = 0
    $headerPadRight = 0
    if($headerPad % 2 -eq 0)
    {
        $headerPadLeft = $headerPadRight = $headerPad / 2
    }
    else
    {
        $headerPadLeft = [Math]::Ceiling($headerPad / 2)
        $headerPadRight = [Math]::Floor($headerPad / 2)
    }

    # generates the title log line
    $header = ""
    for($i = 0; $i -lt $headerPadLeft; $i++)
    {
        $header += $buffer
    }
    $header += $headerWrap[0]
    $header += $title
    $header += $headerWrap[1]
    for($i = 0; $i -lt $headerPadRight; $i++)
    {
        $header += $buffer
    }

    # adds in array of messages
    $logBlock += $header
    foreach($msg in $msgs)
    {
        $logBlock += $msg
    }

    # generates footer
    $footer = ""
    for($i = 0; $i -lt $bufferLength; $i++)
    {
        $footer += $buffer
    }
    $logBlock += $footer

    #returns the array
    return $logBlock
}