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

    $extractedNum = ($str -replace "[^0-9]" , '').ToString()
    $calNum = "$($extractedNum[0])$($extractedNum.substring($extractedNum.length - 1))"

    return (String-To-Int $calNum)
}