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
# Name:		Total-Game
# Input:	$game <Array>
# Output:	$total <Hash Object>
# Description:	
#	Gets the color totals for all sets in a game
#
########################################
function Total-Game($game)
{
    $total = @{
        "red" = 0
        "blue" = 0
        "green" = 0
    }

    foreach($set in $game)
    {
        foreach($color in $set.GetEnumerator())
        {
            $total.($color.Name) += $color.Value
        }
    }

    return $total
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
