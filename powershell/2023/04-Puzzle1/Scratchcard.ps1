########################################
#
# File Name:	Scratchcard.ps1
# Date Created:	12/02/2024
# Description:	
#	Advent of Code - Day 4 - Puzzle 1
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\AdventOfCode.ps1"

# Global Varible Setting
$global:AoC.puzzle = "4-1"
$global:AoC.testInputMode = $false

$global:logSetting.fileOutput = $true
$global:logSetting.showDebug = $true
#=======================================

# Local Functions
function Count-Array-Matches($collection, $toFind)
{
    $matches = 0
    foreach($val in $toFind)
    {
        if ($collection.Contains($val) -eq $true) 
        {
            $matches += 1
        }
    }
    
    return $matches
}

#=======================================

Write-Start
$cards = Load-Input
$scratchcards = @()

for($i = 0; $i -lt $cards.length; $i += 1)
{
    Write-Log "Splitting Card $($i+1)"
    $card, $numbers = ($cards[$i] -split ':')

    $numbers = $numbers.Replace("  "," ").Trim()
    $card = $card.Trim()
    $score = 0

    Write-Log "Splitting Numbers - $($numbers)"
    $winningNumbers, $obtainedNumbers = ($numbers.Split('|'))
    $winningNumbers = $winningNumbers.Trim().Split(' ')
    $obtainedNumbers = $obtainedNumbers.Trim().Split(' ')
    $noMatched = Count-Array-Matches $obtainedNumbers $winningNumbers

    if($noMatched -gt 0)
    {
        Write-Log "$($card) as $($noMatched) wins. calculating"
        $score = 1
        $noMatched -= 1
        for($j = 0; $j -lt $noMatched; $j += 1)
        {
            $score *= 2
        }

        Write-Log "Adding to Collection"
        $scratchcards += @($score)
    }

    #Write-Debug $card
    #Write-Debug $score
    Write-Log "==================================="
}

Get-Answer $scratchcards 
Write-End
