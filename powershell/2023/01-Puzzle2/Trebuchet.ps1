########################################
#
# File Name:	Trebuchet.ps1
# Date Created:	06/12/2023
# Description:	
#	Advent of Code - Day 1 - Puzzle 2
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\Common.ps1"

# Local Function
function Get-Calibration($str)
{
    $calNum = ""
    $numWords = @{
        "one"   = "1"
        "two"   = "2"
        "three" = "3"
        "four"  = "4"
        "five"  = "5"
        "six"   = "6"
        "seven" = "7"
        "eight" = "8"
        "nine"  = "9"
    }
    $numWordsArr = [array]$numWords.Keys

    Write-Log "Finding First & Last instance of spelled number in '${str}'"
    $numWordFoundFirst = FirstIndexOfAnyStr $str $numWordsArr
    $numWordFoundLast = LastIndexOfAnyStr $str $numWordsArr
    $strFixed = $str
    if($numWordFoundFirst -gt -1)
    {
        $numWord = $numWordsArr[$numWordFoundFirst]
        $strFixed = $strFixed.Insert($strFixed.IndexOf($numWord),$numWords[$numWord])
    }
    if($numWordFoundLast -gt -1)
    {
        $numWord = $numWordsArr[$numWordFoundLast]
        $strFixed = $strFixed.Insert($strFixed.LastIndexOf($numWord),$numWords[$numWord].ToString())
    }

    #Write-Debug "$($str) => $($strFixed)"
    $extractedNum = ($strFixed -replace "[^0-9]" , '').ToString()
    $calNum = "$($extractedNum[0])$($extractedNum.substring($extractedNum.length - 1))"

    #Write-Debug "Extracted No.s = ${extractedNum}"
    #Write-Debug "Calibration No. = ${calNum}"

    return $calNum
}

Write-Start

Write-Log "Importing Data"
$data = Get-Content "input.txt"
#Write-Debug (Gen-Block "Imported Data" $data)

Write-Log "Extracting Number"
$calArr = @()
foreach($line in $data)
{
    $calArr += @([int](Get-Calibration $line.ToLower()))
}
#Write-Debug (Gen-Block "Calibration Data" $calArr)

Write-Log "Summing Calibration Values"
$calSum = 0
foreach($val in $calArr)
{
    $calSum += $val
}

Write-Success "AoC Day 1-2 Answer: ${calSum}"

Write-End