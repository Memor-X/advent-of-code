########################################
#
# File Name:	Engine.ps1
# Date Created:	30/01/2024
# Description:	
#	Advent of Code - Day 3 - Puzzle 1
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\AdventOfCode.ps1"
. "$($PSScriptRoot)\lib\LocalLib.ps1"

# Global Varible Setting
$global:AoC.puzzle = "3-1"
$global:AoC.testInputMode = $false

$global:logSetting.fileOutput = $true
$global:logSetting.showDebug = $true

Write-Start
$data = Load-Input

# Write-Debug (Gen-Block "Input Data" $data)

Write-Log "Scanning Data"
$parts = @()
for($i = 0; $i -lt $data.Length; $i += 1)
{
    $coord = @(0,0)
    $intStart = $false
    $intEnd = $false

    for($j = 0; $j -lt $data[$i].Length; $j += 1)
    {
        if($intStart -eq $false -and $data[$i][$j] -match "^\d+$")
        {
            $coord[0] = $j
            $intStart = $true
            #Write-Log "$($i):$($j) is number | $($data[$i][$j])"
        }

        if($intStart -eq $true -and $intEnd -eq $false -and ($data[$i][$j] -match "^\d+$") -eq $false)
        {
            $coord[1] = $j-1
            $intEnd = $true
        }

        if($intStart -eq $true -and $intEnd -eq $false -and $j -eq $data[$i].Length-1)
        {
            $coord[1] = $j
            $intEnd = $true
        }

        if($intStart -eq $true -and $intEnd -eq $true)
        {
            $partNumber = $data[$i].substring($coord[0], ($coord[1]-$coord[0])+1)
            Write-Log "Found Number on line $($i+1) = $($partNumber)"

            Write-Log "Getting Boarder Characters"
            $borderStr = ""
            $startStr = $coord[0]-1
            if($startStr -lt 0)
            {
                $startStr = 0
            }

            $endStr = $coord[1]+1
            if($endStr -gt $data[$i].length-1)
            {
                $endStr = $data[$i].length-1
            }

            if($i -gt 0)
            {
                $borderStr += $data[$i-1].substring($startStr, ($endStr-$startStr)+1)
            }
            if($startStr -gt 0)
            {
                $borderStr +=  $data[$i][$startStr]
            }
            if($endStr -lt $data[$i].length-1)
            {
                $borderStr += $data[$i][$endStr]
            }
            if($i -lt $data.length-1)
            {
                $borderStr += $data[$i+1].substring($startStr, ($endStr-$startStr)+1)
            }
            Write-Log "Border Characters = $($borderStr)"

            $borderStr = $borderStr.Replace(".", "")
            Write-Log "Border Characters = $($borderStr)"
            if($borderStr.length -gt 0)
            {
                Write-Success "Part Number Found. Char = $($borderStr)"
                $parts += @([int]$partNumber)
            }

            
            Write-Host "==========================="

            $intEnd = $false
            $intStart = $false
            $coord = @(0,0)
        }
    }
}

Get-Answer $parts
Write-End
