########################################
#
# File Name:	Trebuchet.ps1
# Date Created:	06/12/2023
# Description:	
#	Advent of Code - Day 1 - Puzzle 1
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\powershell\Common.ps1"

# Local Function
function Get-Calibration($str)
{
    $calNum = ""

    $extractedNum = ($str -replace "[^0-9]" , '').ToString()
    $calNum = "$($extractedNum[0])$($extractedNum.substring($extractedNum.length - 1))"

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
    $calArr += @([int](Get-Calibration $line))
}
#Write-Debug (Gen-Block "Calibration Data" $calArr)

Write-Log "Summing Calibration Values"
$calSum = 0
foreach($val in $calArr)
{
    $calSum += $val
}

Write-Success "AoC Day 1-1 Answer: ${calSum}"

Write-End