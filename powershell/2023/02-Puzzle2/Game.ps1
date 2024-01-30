########################################
#
# File Name:	Game.ps1
# Date Created:	08/12/2023
# Description:	
#	Advent of Code - Day 2 - Puzzle 2
#
########################################

# file imports
. "$($PSScriptRoot)\..\..\lib\Common.ps1"

# Local Function
function Min-Game($game)
{
    $min = @{
        "red" = 999999
        "blue" = 999999
        "green" = 999999
    }

    foreach($set in $game)
    {
        foreach($color in $set.GetEnumerator())
        {
            if($color.Value -gt 0 -and $color.Value -lt $min.($color.Name))
            {
                $min.($color.Name) = $color.Value
            }
        }
    }

    return $min
}

function Max-Game($game)
{
    $max = @{
        "red" = 0
        "blue" = 0
        "green" = 0
    }

    foreach($set in $game)
    {
        foreach($color in $set.GetEnumerator())
        {
            if($color.Value -gt $max.($color.Name))
            {
                $max.($color.Name) = $color.Value
            }
        }
    }

    return $max
}

Write-Start

Write-Log "Importing Data"
$data = Get-Content "input.txt"

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
$gamePowers = @()

Write-Log "Calculating 'power' for games"
foreach($gameID in $games)
{
    Write-Log "Maxing Game $($gameID)"
    $gameMmax = Max-Game $gameData.$gameID
    #$outputblock = @(
    #    "Red = $($gameMmax.red)"
    #    "Green = $($gameMmax.green)"
    #    "Blue = $($gameMmax.blue)"
    #)
    #Write-Debug (Gen-Block "Game $($gameID) Data" $outputblock)
    
    Write-Log "Calculating Power"
    $power = $gameMmax.red * $gameMmax.green * $gameMmax.blue
    #Write-Debug "Game $($gameID) Power = $($power)"
    $GamePowers += @($power)
}

Write-Log "Summing Game powers"
$gameSum = 0
foreach($val in $GamePowers)
{
    $gameSum += $val
}

Write-Success "AoC Day 2-2 Answer: ${gameSum}"

Write-End
