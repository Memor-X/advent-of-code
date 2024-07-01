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
    $keys = $map.Keys | Sort-Object {[int64]$_} -Descending
    $pos = 0
    for($keyIter = 0; $keyIter -lt $keys.length; $keyIter += 1)
    {
        #if($mapKey -gt ($keys[$pos] + (String-To-Int($map[$keys[$pos]][1]))))
        if($mapKey -lt $keys[$pos])
        {
            $pos = $keyIter
        }
        else
        {
            break;
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

function Get-Mapping-Range($map,$mapKey,$range)
{
    $debug = @("key = $($mapKey), range = $($range)")
    $keys = $map.Keys | Sort-Object {[int64]$_}
    $vals = @()
    $vals += @(@{
        "val" = (Mapping-Lookup $map $mapKey)
        "range" = $range
    })

    $debug += @("[OUT OF LOOP] val = $($mapKey) becomes $((Mapping-Lookup $map $mapKey)) | range = $(String-To-Int $range)")
    $mapKeyInt = String-To-Int $mapKey
    $maxMapKey = ($mapKeyInt + (String-To-Int $range))
    $remainingRange = $range
    for($i = 0; $i -lt $keys.Length; $i++)
    {
        $key = (String-To-Int $keys[$i])
        Write-Debug "Range left = $($remainingRange)"
        #if((($mapKeyInt)+(String-To-Int $range)) -ge $keys[$i] -and (($keys[$i] -lt $mapKeyInt) -eq $false))
        #if((($mapKeyInt)+(String-To-Int $range)) -ge $keys[$i])
        #$debug += @("if((($($mapKeyInt) [$($mapKeyInt.GetType())]) + (String-To-Int $($range) [$((String-To-Int $range).GetType())])) -gt $($keys[$i]) [$($keys.GetType())]) -and ($($keys[$i]) [$($keys[$i].GetType())] -gt $($mapKeyInt) [$($mapKeyInt.GetType())]))")
        #if((($mapKeyInt + (String-To-Int $range)) -gt $keys[$i]) -and ($keys[$i] -gt $mapKeyInt))
        $debug += @("if((($($mapKeyInt) [$($mapKeyInt.GetType())]) + (String-To-Int $($range) [$((String-To-Int $range).GetType())])) -gt $($key) [$($keys.GetType())]) -and ($($keys[$i]) [$($key.GetType())] -gt $($mapKeyInt) [$($mapKeyInt.GetType())]))")
        if(($maxMapKey -gt $key) -and ($key -gt $mapKeyInt))
        {
            $rangeToUse = String-To-Int $map.($keys[$i])[1]
            if($i -eq $keys.Length-1)
            {
                $rangeToUse = $maxMapKey - $keys[$i]
            }
            
            #$remainingRange -= String-To-Int $map.($keys[$i])[1]

            #if($remainingRange -gt 0)
            #{
            #    $rangeToUse = $remainingRange
            #}
            $val = (Mapping-Lookup $map ($keys[$i]))
            $vals += @(@{
                "val" = ($val)
                "range" = $rangeToUse
            })
            $debug += @("[IN LOOP $($i)] val = $($keys[$i]) becomes $($val) | range = $($rangeToUse)")
        }
    }

    $vals += @(@{
        "val" = (Mapping-Lookup $map ($mapKeyInt+(String-To-Int $range)))
        "range" = 0
    })
    $debug += @("[AFTER LOOP] val = $($mapKeyInt)+$((String-To-Int $range)) becomes $((Mapping-Lookup $map ($mapKeyInt+(String-To-Int $range)))) | range = $(String-To-Int 0)")

    #Write-Debug (Gen-Block "Get-Mapping-Range Keys" $keys)
    #Write-Debug (Gen-Block "Get-Mapping-Range results" $debug)

    return $vals
}

function Compile-Input-Data($data)
{
    $mapping = @{}

    Write-Log "Compiling mapping object"
    for($i = 1; $i -lt $data.length; $i += 1)
    {
        $line = $data[$i]
        Write-Log "Processling Line $($i+1) - $($line)"

        if($line.Length -lt 1)
        {
            Write-Log "Clearning Header Flag"
            $header = $false
            $key = ""
        }

        if($header -eq $true)
        {
            $split = $line -split " "
            $start = $split[1]
            Write-Log "adding $($start) - $($split[0]), $($split[2])"
            $mapping.$key.$start = @($split[0], $split[2])
        }

        if($line.Contains("map:") -eq $true -and $header -eq $false)
        {
            $key = $line.Replace(" map:","")
            Write-Log("Adding mappings - $($key)")
            $mapping.$key = [ordered]@{}
            $header = $true
        }
    }

    #foreach($mapKey in $mapping.Keys)
    #{
    #    Write-Log "Sorting $($mapKey)"
    #    $mapping.$mapKey = $mapping.$mapKey.GetEnumerator() | Sort-Object -Property Name  
    #}
    $returnMap = $mapping.Clone()
    $smallest = 
    Write-Log "Filling Gaps"
    $mappingKeys = @($mapping.Keys)
    for($i = 0; $i -lt $mappingKeys.Length; $i++)
    {
        $mappingKey = $mappingKeys[$i]
        Write-Log "Filling Gaps in $($mappingKey)"
        $mapStarts = @($mapping.$mappingKey.Keys)
        for($j = 0; $j -lt $mapStarts.Length; $j++)
        {
            $mappingStart = $mapStarts[$j]
            $expectedMapEnd = "$((String-To-Int $mappingStart) + (String-To-Int ($mapping.$mappingKey.$mappingStart)[1]))"
            Write-Log "$($mappingStart) expected end $($expectedMapEnd)"
            if(($returnMap.$mappingKey).Keys.Contains($expectedMapEnd) -eq $false)
            {
                $returnMap.$mappingKey.$expectedMapEnd = @((String-To-Int $expectedMapEnd), 0)
            }

        }

        if(($returnMap.$mappingKey).Keys.Contains("0") -eq $false)
        {
            $returnMap.$mappingKey."0" = @(0, 0)
        }
    }

    return $returnMap
}