########################################
#
# File Name:	Maths.ps1
# Date Created: 20/02/2024
# Description:	
#	Function library for Mathmatics functions
#
########################################

########################################
#
# Name:		Sum
# Input:	$vals <Array>
# Output:	$sum <Integer>
# Description:	
#	loops though values in the provided array to determine the sum of all values
#
########################################
function Sum($vals)
{
    $sum = 0
    foreach($val in $vals)
    {
        $sum += $val
    }
    return $sum
}

########################################
#
# Name:		Min
# Input:	$vals <Array>
# Output:	$min <Integer>
# Description:	
#	loops though values in the provided array to determine the minimun value
#
########################################
function Min($vals)
{
    $min = $vals[0]
    for($i = 1; $i -lt $vals.length; $i += 1)
    {
        if($vals[$i] -lt $min)
        {
            $min = $vals[$i]
        }
    }
    return $min
}

########################################
#
# Name:		Max
# Input:	$vals <Array>
# Output:	$max <Integer>
# Description:	
#	loops though values in the provided array to determine the maximun value
#
########################################
function Max($vals)
{
    $max = $vals[0]
    for($i = 1; $i -lt $vals.length; $i += 1)
    {
        if($vals[$i] -gt $max)
        {
            $max = $vals[$i]
        }
    }
    return $max
}