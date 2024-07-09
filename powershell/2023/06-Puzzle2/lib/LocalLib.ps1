########################################
#
# File Name:	LocalLib.ps1
# Date Created:	08/07/2024
# Description:	
#	Local Functions for Unit Testing
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\..\lib\Common.ps1"
#=======================================

# Global Variables

#=======================================

########################################
#
# Name:		Build-Race-Data
# Input:	$inputData <Array>
# Output:	$races <Array>
# Description:	
#	formats the input data into a Hash Object
#
########################################
function Build-Race-Data($inputData)
{
    Write-Log "Building Race Data"
    $cleanedData = $inputData
    $cleanedData[0] = $cleanedData[0].Replace("Time:","").Replace(" ","").Trim()
    $cleanedData[1] = $cleanedData[1].Replace("Distance:","").Replace(" ","").Trim()

    Write-Log "Building  Race"
    $races = @{
        "time" = (String-To-Int $cleanedData[0])
        "record-dist" = (String-To-Int $cleanedData[1])
    }

    return $races
}

########################################
#
# Name:		Find-Winning-Charges
# Input:	$raceData <Array>
# Output:	$winners <Integer>
# Description:	
#	calculates the possible ways to win a race
#
########################################
function Find-Winning-Charges($raceData)
{
    Write-Log "Determing Winning Charge Variations for Time = $($raceData."time") of Record Distance = $($raceData."record-dist")"
    $winners = 0

    $mod = ($raceData."time" + 1) % 2
    $raceTime = ($raceData."time" + 1) - $mod
    $calRaceTime = $raceTime / 2
    $winnerStart = $null

    <#
    $debugData = @(
        "mod = $($mod)",
        "raceTime = $($raceTime)",
        "calRaceTime = $($calRaceTime)"
    )
    Write-Debug @(Gen-Block "Find-Winning-Charges Calcs" $debugData)
    #>

    Write-Log "Calculating winners for half race time = $($calRaceTime)"
    for($i = 1; $i -lt $calRaceTime; $i++)
    {
        $timeLeft = $raceData."time" - $i
        #Write-Debug "timeLeft = $($timeLeft)"
        #Write-Debug "i x timeLeft ($(($i * $timeLeft))) -gt record ($($raceData."record-dist"))"
        if(($i * $timeLeft) -gt $raceData."record-dist")
        {
            $winnerStart = $i
            $i = $raceData."time"
        }
    }
    Write-Log "Winners start at $($winnerStart)"

    if($null -ne $winnerStart)
    {
        $winners = (($calRaceTime - $winnerStart) * 2) + $mod
    }

    return $winners
}