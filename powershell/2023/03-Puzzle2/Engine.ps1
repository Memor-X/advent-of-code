########################################
#
# File Name:	Engine.ps1
# Date Created:	02/02/2024
# Description:	
#	Advent of Code - Day 3 - Puzzle 2
#
########################################

# file imports
. "$($PSScriptRoot)\..\..\lib\AdventOfCode.ps1"

# Global Varible Setting
$global:AoC.puzzle = "3-2"
$global:AoC.testInputMode = $false

$global:logSetting.fileOutput = $false
$global:logSetting.showDebug = $false
#---------------------------------------

# Local Function
function Get-Number($string,$startPos)
{
    Write-Log "Building Number from $($string) start at $($startPos+1)"

    $number = $string[$startPos]
    
    Write-Log "Compiling Right Side"
    for($iPlus = $startPos+1; $iPlus -lt $string.Length; $iPlus += 1)
    {
        if(Is-Digit($string[$iPlus]) -eq $true)
        {
            Write-Debug "Appending $($string[$iPlus])"
            $number = "$($number)$($string[$iPlus])"
        }
        else
        {
            $iPlus = $string.Length
        }
    }

    Write-Log "Compiling Left Side"
    for($iMinus = $startPos-1; $iMinus -gt -1; $iMinus -= 1)
    {
        if(Is-Digit($string[$iMinus]) -eq $true)
        {
            Write-Debug "Prepending $($string[$iMinus])"
            $number = "$($string[$iMinus])$($number)"
        }
        else
        {
            $iMinus = -1
        }
    }

    Write-Log "========================"

    [int]$retunVal = [convert]::ToInt32($number, 10)
    return $retunVal
}

#---------------------------------------

Write-Start

$data = Load-Input

Write-Log "Scanning Data"
$parts = @()
$partsDebug = @()
for([int]$i = 0; $i -lt $data.Length; $i += 1)
{
    Write-Log "Scanning Line $($i+1)"
    for([int]$j = 0; $j -lt $data[$i].Length; $j += 1)
    {
        if($data[$i][$j] -eq "*")
        {
            Write-Log "$($i+1):$($j+1) is *"
            
            $numbers = @()
            if($i -gt 0)
            {
                Write-Log "Checking Top Line"
                $checkStr = $data[$i-1].Substring($j-1,3)
                if(Is-Digit($checkStr[1]))
                {
                    Write-Log "Middle Digit"
                    $numbers += @(Get-Number $data[$i-1] $j)
                }
                else
                {
                    Write-Log "Side Digits"
                    if(Is-Digit($checkStr[0])){$numbers += @(Get-Number $data[$i-1] ($j-1))}
                    if(Is-Digit($checkStr[2])){$numbers += @(Get-Number $data[$i-1] ($j+1))}
                }
            }
            
            if($i -lt $data.length-1)
            {
                Write-Log "Checking Bottom Line"
                $checkStr = $data[$i+1].Substring($j-1,3)
                if(Is-Digit($checkStr[1]))
                {
                    Write-Log "Middle Digit"
                    $numbers += @(Get-Number $data[$i+1] $j)
                }
                else
                {
                    Write-Log "Side Digits"
                    if(Is-Digit($checkStr[0])){$numbers += @(Get-Number $data[$i+1] ($j-1))}
                    if(Is-Digit($checkStr[2])){$numbers += @(Get-Number $data[$i+1] ($j+1))}
                }
            }

            if($j -gt 0 -and (Is-Digit($data[$i][$j-1])) -eq $true)
            {
                Write-Log "Checking Left Character"
                $numbers += @(Get-Number $data[$i] ($j-1))
            }

            if($j -lt $data[$i].length-1 -and (Is-Digit($data[$i][$j+1])) -eq $true)
            {
                Write-Log "Checking Right Character"
                $numbers += @(Get-Number $data[$i] ($j+1))
            }
            
            Write-Log (Gen-Block "Numbers" (@("Numbers Found = $($numbers.Count)") + $numbers))

            if($numbers.Count -eq 2)
            {
                Write-Log "Gear Pair Found"
                $parts += @(($numbers[0]*$numbers[1]))
                $partsDebug += @("* Loc [$($i+1),$($j+1)] | $($numbers[0]) x $($numbers[1]) = $($numbers[0]*$numbers[1])")
            }
        }
    }
    Write-Log "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
}


Get-Answer $parts

Write-End
