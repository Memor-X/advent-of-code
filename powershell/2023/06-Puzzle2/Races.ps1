########################################
#
# File Name:	Races.ps1
# Date Created:	08/07/2024
# Description:	
#	Advent of Code - Day 6 - Puzzle 2
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\AdventOfCode.ps1"
. "$($PSScriptRoot)\lib\LocalLib.ps1"

# Global Varible Setting
$global:AoC.puzzle = "6-2"
$global:AoC.testInputMode = $false

$global:logSetting.fileOutput = $true
$global:logSetting.showDebug = $true
#=======================================

Write-Start
$data = Load-Input
$waysToWin = @()

$raceData = (Build-Race-Data $data)
$waysToWin = Find-Winning-Charges $raceData

Get-Answer $waysToWin "static"
Write-End