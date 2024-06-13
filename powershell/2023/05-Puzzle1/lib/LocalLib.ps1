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

function Mapping-Lookup($map,$mapKey)
{
    $keys = $map.Keys | Sort-Object
    $pos = 0
    for($keyIter = 0; $keyIter -lt $keys.length; $keyIter += 1)
    {
        if($mapKey -ge ($keys[$pos] + (String-To-Int($map[$keys[$pos]][1]))))
        {
            $pos = $keyIter
        }
        else
        {
            $keyIter = $keys.length
        }
    }

    $mappedVal = $mapKey
    $diff = ((String-To-Int($mapKey)) - (String-To-Int($keys[$pos])))
    if($diff -lt (String-To-Int($map[$keys[$pos]][1])) -and $diff -ge 0)
    {
        $mappedVal = (String-To-Int($map[$keys[$pos]][0])) + ((String-To-Int($mapKey)) - (String-To-Int($keys[$pos])))
    }

    return $mappedVal
}
