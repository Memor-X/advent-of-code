########################################
#
# File Name:	LocalLib.ps1
# Date Created:	02/07/2024
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
#	formats the input data into an array of Hash Objects
#
########################################
function Build-Race-Data($inputData)
{
    Write-Log "Building Race Data"
    $cleanedData = $inputData
    $cleanedData[0] = (Compress-Spaces ($cleanedData[0].Replace("Time:",""))).Trim().Split(" ")
    $cleanedData[1] = (Compress-Spaces ($cleanedData[1].Replace("Distance:",""))).Trim().Split(" ")
    $raceCount = $cleanedData[0].Count

    $races = @{}

    for($i = 0; $i -lt $raceCount; $i++)
    {
        Write-Log "Adding Race $($i+1)"
        $races."race $($i+1)" = @{
            "time" = (String-To-Int $cleanedData[0][$i])
            "record-dist" = (String-To-Int $cleanedData[1][$i])
        }
    }

    return $races
}

########################################
#
# Name:		Find-Charges
# Input:	$raceData <Array>
# Output:	$charges <Array>
# Description:	
#	calculates all the possible ways to do a race
#
########################################
function Find-Charges($raceData)
{
    Write-Log "Determing Charge Variations for Time = $($raceData."time") of Distance = $($raceData."duration")"
    $time = $raceData.time+1
    $charges = Initalize-Array $time

    for($i = 0; $i -lt ($time); $i++)
    {
        $timeleft = $raceData.time - $i
        $traveled = $timeleft * $i
        $addedHash = @{
            "charge" = $i
            "time-left" = $timeleft
            "traveled" = $traveled
        }

        $debugData = (Hash-to-Array $addedHash)
        Write-Debug @(Gen-Block "Charge $($i)" $debugData)

        $charges[$i] = $addedHash
    }

    return $charges
}

########################################
#
# Name:		Find-Winners
# Input:	$raceData <Array>
#			$record <Integer>
# Output:	$winners <Array>
# Description:	
#	checks all the distances of a race and returns an array of the ones that would break the record
#
########################################
function Find-Winners($raceData, $record)
{
    Write-Log "Getting Record Breakers, Record Distance = $($record)"
    $winners = @()

    for($i = 0; $i -lt $raceData.Count; $i++)
    {
        if($raceData[$i]."traveled" -gt $record)
        {
            Write-Log "Adding Charge $($i), Traveled $($raceData[$i]."traveled")"
            $winners += @($raceData[$i])
        }
    }

    return $winners
}