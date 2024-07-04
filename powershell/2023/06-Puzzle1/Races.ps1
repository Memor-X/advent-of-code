########################################
#
# File Name:	Races.ps1
# Date Created:	02/07/2024
# Description:	
#	Advent of Code - Day 6 - Puzzle 1
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\AdventOfCode.ps1"
. "$($PSScriptRoot)\lib\LocalLib.ps1"

# Global Varible Setting
$global:AoC.puzzle = "6-1"
$global:AoC.testInputMode = $false

$global:logSetting.fileOutput = $true
$global:logSetting.showDebug = $true
#=======================================

Write-Start
$data = Load-Input
$waysToWin = @()

$raceData = (Build-Race-Data $data)
$raceKeys = @($raceData.Keys)

Write-Debug "Race Count = $($raceKeys.Count)"
for($i = 0; $i -lt $raceKeys.Count; $i++)
{
    $raceKey = $raceKeys[$i]
    $chargeVariations = Find-Charges $raceData[$raceKey]
    $winners = (Find-Winners $chargeVariations $raceData[$raceKey]."record-dist")

    Write-Log "Found $($winners.Count) Winners"
    $waysToWin += @($winners.Count)

    #$debugData = (Hash-to-Array $raceData."$($raceKey)")

    #Write-Debug @(Gen-Block "$($raceKey)" $debugData)
}

Get-Answer $waysToWin "prod"
Write-End