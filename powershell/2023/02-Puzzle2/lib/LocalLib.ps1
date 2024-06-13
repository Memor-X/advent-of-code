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
# Name:		Min-Game
# Input:	$game <Array>
# Output:	$min <Hash Object>
# Description:	
#	Works out the lowest value of each color among all sets of a game
#
########################################
function Min-Game($game)
{
    $min = @{
        "red" = 999999
        "blue" = 999999
        "green" = 999999
    }

    foreach($set in $game)
    {
        foreach($color in $set.GetEnumerator())
        {
            if($min.($color.Name) -eq $null)
            {
                $min.($color.Name) = 999999
            }
            if($color.Value -gt 0 -and $color.Value -lt $min.($color.Name))
            {
                $min.($color.Name) = $color.Value
            }
        }
    }

    return $min
}

########################################
#
# Name:		Max-Game
# Input:	$game <Array>
# Output:	$max <Hash Object>
# Description:	
#	Works out the highest value of each color among all sets of a game
#
########################################
function Max-Game($game)
{
    $max = @{
        "red" = 0
        "blue" = 0
        "green" = 0
    }

    foreach($set in $game)
    {
        foreach($color in $set.GetEnumerator())
        {
            if($color.Value -gt $max.($color.Name))
            {
                $max.($color.Name) = $color.Value
            }
        }
    }

    return $max
}
