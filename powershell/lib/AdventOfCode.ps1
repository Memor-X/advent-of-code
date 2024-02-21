########################################
#
# File Name:	AdventOfCode.ps1
# Date Created:	08/02/2024
# Description:	
#	Function library for functions used primarily for Advent of Code
#
########################################

# File Imports
. "$($PSScriptRoot)\Common.ps1"
. "$($PSScriptRoot)\Data.ps1"

# Global Variables
if($global:AoC -eq $null)
{
    $global:AoC = @{
        "puzzle" = "0-0"
        "testInputMode" = $false
        "inputFile_Test" = "input-test.txt"
        "inputFile_Actual" = "input.txt"
        "inputFile_Extra" = ""
    };
}

########################################
#
# Name:		Load-Input
# Input:	N/A
# Output:	$inputData <Array>
# Description:	
#	Imports data based off global variable values allowing to load up test 
#   data or a specified override data, saving the need to keep changing input.txt
#
########################################
function Load-Input()
{
    Write-Log "Importing Data"

    # Setting the actual input file as the default
    $filename = $global:AoC.inputFile_Actual

    # Checks if test mode is flagged
    if($global:AoC.testInputMode -eq $true)
    {
        Write-Log "Test Mode active"
        $filename = $global:AoC.inputFile_Test
    }
    elseif($global:AoC.inputFile_Extra.Length -gt 0)
    {
        # If the override file is specified, use that instead
        Write-Log "Override File specified - $($global:AoC.inputFile_Extra)"
        $filename = $global:AoC.inputFile_Extra
    }

    Write-Log "Loading Data from - $($filename)"
    $inputData = Get-Content $filename
    Write-Debug (Gen-Block "Input Data" $inputData)
    return $inputData
}

########################################
#
# Name:		Get-Answer
# Input:	$collection <Array>
# Output:	Screen Output
# Description:	
#	Calculates and outputs Advent of Code Answer. also outputs the data being 
#   caculated for debugging
#
########################################
function Get-Answer($collection,$calc="sum")
{
    # Saving log settings to restore
    $logSettingRetain = $global:logSetting
    $global:logSetting.showLog = $true
    $global:logSetting.showDebug = $true
    
    Write-Debug (Gen-Block "Values to Calculate" (@("Collection Size = $($collection.Count)") + $collection))

    # Restoring log settings
    $global:logSetting = $logSettingRetain

    # Output data to external file
    Write-File ".\Answer-Data.txt" ($collection -join "`n")

    Write-Log "Calculating Collection - $($calc)"
    $answer = 0
    Switch($calc)
    {
        "sum" {
            $answer = (Sum $collection)
            break
        }
        "min"
        {
            $answer = (Min $collection)
            break
        }
    }
    

    Write-Success "AoC Day $($global:AoC.puzzle) Answer: ${answer}"
}