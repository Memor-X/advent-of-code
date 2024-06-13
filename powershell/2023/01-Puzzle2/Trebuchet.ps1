########################################
#
# File Name:	Trebuchet.ps1
# Date Created:	06/12/2023
# Description:	
#	Advent of Code - Day 1 - Puzzle 2
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\AdventOfCode.ps1"
. "$($PSScriptRoot)\lib\LocalLib.ps1"

# Global Varible Setting
$global:AoC.puzzle = "1-2"
$global:AoC.testInputMode = $false

$global:logSetting.fileOutput = $true
$global:logSetting.showDebug = $true

Write-Start
$data = Load-Input

Write-Log "Extracting Number"
$calArr = @()
foreach($line in $data)
{
    $calArr += @([int](Get-Calibration $line.ToLower()))
}
#Write-Debug (Gen-Block "Calibration Data" $calArr)

Get-Answer $calArr
Write-End