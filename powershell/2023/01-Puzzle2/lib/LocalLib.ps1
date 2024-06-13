########################################
#
# File Name:	LocalLib.ps1
# Date Created:	10/05/2024
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
# Name:		Get-Calibration
# Input:	$str <String>
# Output:	$calNum <Integer>
# Description:	
#	Extracts the Calibration Number
#
########################################
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