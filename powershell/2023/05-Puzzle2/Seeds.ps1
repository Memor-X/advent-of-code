########################################
#
# File Name:	Seeds.ps1
# Date Created:	21/02/2024
# Description:	
#	Advent of Code - Day 5 - Puzzle 2
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\AdventOfCode.ps1"
. "$($PSScriptRoot)\lib\LocalLib.ps1"

# Global Varible Setting
$global:AoC.puzzle = "5-2"
$global:AoC.testInputMode = $false

$global:logSetting.fileOutput = $true
$global:logSetting.showDebug = $false
#=======================================

Write-Start
$data = Load-Input
$locations = @()
$mapping = @{}
$header = $flase
$key = ""

$mapping = Compile-Input-Data $data

Write-Log "Collecting Seeds"
$seeds = $data[0].Replace("seeds: ","").Split(" ")
$locCol = @()

for($i = 0; $i -lt $seeds.Length; $i = $i + 2)
{
    $start = (String-To-Int $seeds[($i)])
    $range = (String-To-Int $seeds[$i+1])
    $end = $start + $range -1

    Write-Log "Seed Range - $($start) -> $($end)"

    $mapSeeds = $mapping."seed-to-soil".Keys | Sort-Object {[int64]$_}
    for($j = 0; $j -lt $mapSeeds.Length; $j++)
    {
        Write-Debug "mapSeeds[j] = $($mapSeeds[$j])"
        $mapSeedStart = (String-To-Int $mapSeeds[$j])
        $mapSeedEnd = $mapSeedStart + (String-To-Int ($mapping."seed-to-soil"."$($mapSeedStart)")[1])

        $overlap = (Min @($end, $mapSeedEnd)) - (Max @($start, $mapSeedStart))
        if($overlap -ge 0)
        {
            Write-Log "Overlap Found"
            $overlapStart = $mapSeedStart
            if($start -ge $mapSeedStart)
            {
                $overlapStart = $start
            }
            Write-Log "Overlap Start = $($overlapStart)"

            $overlapEnd = $mapSeedEnd
            if($end -le $mapSeedEnd)
            {
                $overlapEnd = $end
            }
            Write-Log "Overlap End = $($overlapEnd)"

            for($k = $overlapStart; $k -lt $overlapEnd; $k += 100000)
            {
                #Write-Log "Seed = $($k)"
                $soil = Mapping-Lookup $mapping."seed-to-soil" $k
                Write-Debug "Soil = $($soil)"

                $fertilizer = Mapping-Lookup $mapping."soil-to-fertilizer" $soil
                Write-Debug "Fertilizer = $($fertilizer)"

                $water = Mapping-Lookup $mapping."fertilizer-to-water" $fertilizer
                Write-Debug "Water = $($water)"

                $light = Mapping-Lookup $mapping."water-to-light" $water
                Write-Debug "Light = $($light)"

                $temperature = Mapping-Lookup $mapping."light-to-temperature" $light
                Write-Debug "Temperature = $($temperature)"

                $humidity = Mapping-Lookup $mapping."temperature-to-humidity" $temperature
                Write-Debug "Humidity = $($humidity)"

                $location = Mapping-Lookup $mapping."humidity-to-location" $humidity
                Write-Debug "Location = $($location)"

                $locCol += @($location)
            }
        }
    }
}



<# $soils = @()

Write-Log "Getting Locations"
for($i = 0; $i -lt $seeds.Length; $i = $i + 2)
{
    $seed = (String-To-Int $seeds[($i)])
    $range = (String-To-Int $seeds[$i+1])
    Write-Log "Seed $($seed) of Range $($range) | $($i) -lt $($seeds.Length)"

    Write-Log "Getting Soils"
    $soils += @(Get-Mapping-Range $mapping."seed-to-soil" $seed $range)
}

$debugBlock = @()
for($i = 0; $i -lt $soils.Length; $i = $i + 1)
{
    $debugBlock += @("$($soils[$i].val)->$($soils[$i].range)")
}
Write-Debug (Gen-Block "seed-to-soil results" $debugBlock)


$mapList = @(
    "soil-to-fertilizer",
    "fertilizer-to-water",
    "water-to-light",
    "light-to-temperature",
    "temperature-to-humidity",
    "humidity-to-location"
)
$valCol = @($soils)

foreach($mapKey in $mapList)
{
    Write-Log "Getting Mapped Value from $($mapKey)"
    $newCol = @()

    for($j = 0; $j -lt $valCol.Length; $j++)
    {
        $newCol += @((Get-Mapping-Range $mapping."$($mapKey)" $valCol[$j].val $valCol[$j].range))
        #Write-Debug "Key = $($valCol[$j].val), $($valCol[$j].range)"
    }

    $valCol = $newCol

    $debugBlock = @()
    for($i = 0; $i -lt $valCol.Length; $i = $i + 1)
    {
        $debugBlock += @("$($valCol[$i].val)->$($valCol[$i].range)")
    }
    Write-Debug (Gen-Block "$($mapKey) results" $debugBlock)

    #foreach($val in $vals)
    #{
    #    $addedVal = @(Get-Mapping-Range $mapping."$($mapKey)" $val.val $val.range)
    #    $replaceVals += $addedVal
    #}
    #$vals = $replaceVals
    #foreach($val in $vals)
    #{
    #    $arrayRep = Hash-To-Array $val
    #    Write-Debug $arrayRep
    #}
    
}

$locCol += @($valCol)

Write-Log "removing Ranges from value collection"
for($i = 0; $i -lt $locCol.Length; $i++)
{
    $locations += @(String-To-Int  $locCol[$i].val)
}

$locations = $locations | Get-Unique #>

Get-Answer $locCol "min"
Write-End
