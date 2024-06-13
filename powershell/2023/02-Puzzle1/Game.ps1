########################################
#
# File Name:	Game.ps1
# Date Created:	07/12/2023
# Description:	
#	Advent of Code - Day 2 - Puzzle 1
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\AdventOfCode.ps1"
. "$($PSScriptRoot)\lib\LocalLib.ps1"

# Global Varible Setting
$global:AoC.puzzle = "2-1"
$global:AoC.testInputMode = $false

$global:logSetting.fileOutput = $true
$global:logSetting.showDebug = $true

Write-Start
$data = Load-Input

Write-Log "Parsing input data"
$gameData = @{}
$setTemplate = @{
    "red" = 0
    "blue" = 0
    "green" = 0
}

foreach($line in $data)
{
    Write-Log "Processing line - $($line)"
    $split = $line -split ":"

    $gameID = $split[0].Replace("Game ","").Trim()
    Write-Log "Adding Game $($gameID)"
    $gameData[$gameID] = @()

    $sets = $split[1] -split ";"
    #Write-Debug (Gen-Block "Game $($gameID) Sets" $sets)
    foreach($set in $sets)
    {
        Write-Log "Processing Set - $($set)"
        $clonedTemplate = $setTemplate.Clone()
        $cubes = $set -split ","
        foreach($cube in $cubes)
        {
            $color = $cube.Trim() -split " "
            $clonedTemplate.($color[1].Trim()) = [int]($color[0].Trim())
        }

        $gameData[$gameID] += @($clonedTemplate)
    }
}

#Write-Host $gameData
#Write-Host $gameData["100"]
#Write-Host $gameData["100"][1]
#Write-Host $gameData["100"][1].green
#Write-Host $gameData["100"][1].blue
#Write-Host $gameData["100"][1].red

$criteria = @{
    "red" = 12
    "green" = 13
    "blue" = 14
}
$games = $gameData.Keys
$matchesGames = @()

Write-Log "Checking Game Data for matches"
foreach($gameID in $games)
{
    Write-Log "Maxing Game $($gameID)"
    $gameMax = Max-Game $gameData.$gameID
    
    if($gameMax.red -le $criteria.red -and $gameMax.blue -le $criteria.blue -and $gameMax.green -le $criteria.green)
    {
        Write-Log "Game $($gameID) Matched"
        Write-Log "Red: $($gameMax.red)"
        Write-Log "Green: $($gameMax.green)"
        Write-Log "Blue: $($gameMax.blue)"

        $matchesGames += @($gameID)
    }
}

Get-Answer $matchesGames
Write-End
