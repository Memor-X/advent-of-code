########################################
#
# File Name:	Data.ps1
# Date Created:	08/02/2024
# Description:	
#	Function library for Data Types
#
########################################

# file imports
. "$($PSScriptRoot)\Logging.ps1"

########################################
# Data Type Checking
########################################
Function Is-Digit($char)
{
    return ($char -match "^\d+$")
}

########################################
# Data Convertion
########################################
########################################
#
# Name:		Hash-To-Array
# Input:	$hash <Hash Object>
# Output:	$returnArr <Array>
# Description:	
#	converts a Hash object into an Array of Strings formatted as "key = value"
#
########################################
Function Hash-To-Array($hash)
{
    $returnArr = @()
    foreach($key in $hash.Keys)
    {
        $returnArr += @("$($key) = $($hash[$key])")
    }

    return $returnArr
}

########################################
#
# Name:		String-To-Int
# Input:	$str <String>
# Output:	$retunVal <Intenger>
# Description:	
#	Converts String to Integer
#
########################################
function String-To-Int($str)
{
    [int]$retunVal 
    $retunVal = [convert]::ToInt32($str, 10)
    return $retunVal 
}