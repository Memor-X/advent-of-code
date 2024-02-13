########################################
#
# File Name:	Scratchcard.ps1
# Date Created:	12/02/2024
# Description:	
#	Advent of Code - Day 4 - Puzzle 2
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\AdventOfCode.ps1"

# Global Varible Setting
$global:AoC.puzzle = "4-2"
$global:AoC.testInputMode = $false

$global:logSetting.fileOutput = $true
$global:logSetting.showDebug = $true
#=======================================

# Local Functions

#=======================================

Write-Start
$cards = Load-Input
$scratchcards = @()
$extraCards = Initalize-Array $cards.length 0
#Write-Host $extraCards

for($i = 0; $i -lt $cards.length; $i += 1)
{
    Write-Log "Splitting Card $($i+1)"
    $card, $numbers = ($cards[$i] -split ':')

    $numbers = $numbers.Replace("  "," ").Trim()
    $card = $card.Trim()

    Write-Log "Splitting Numbers - $($numbers)"
    $winningNumbers, $obtainedNumbers = ($numbers.Split('|'))
    $winningNumbers = $winningNumbers.Trim().Split(' ')
    $obtainedNumbers = $obtainedNumbers.Trim().Split(' ')
    $noMatched = Count-Array-Matches $obtainedNumbers $winningNumbers

    $cardCount = 0
    Write-Log "$($card) has $($noMatched) wins"
    for($copies = 0; $copies -lt $extraCards[$i]+1; $copies += 1)
    {
        #Write-Log "Processing $($card) #$($copies+1)"
        $cardCount += 1
        for($wins = 0; $wins -lt $noMatched; $wins += 1)
        {
            $cardCopyNum = $i+($wins+1)
            if($cardCopyNum -lt $extraCards.length)
            {
                $extraCards[$cardCopyNum] += 1
            }
        }
    }

    Write-Log "Adding $($cardCount) x $($card)'s to Collection"
    $scratchcards += @($cardCount)

    #Write-Debug $card
    #Write-Debug $score
    Write-Log "==================================="
}

Get-Answer $scratchcards 
Write-End
