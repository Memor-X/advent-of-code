########################################
#
# File Name:	Seeds.ps1
# Date Created:	15/02/2024
# Description:	
#	Advent of Code - Day 5 - Puzzle 1
#
########################################

# File Imports
. "$($PSScriptRoot)\..\..\lib\AdventOfCode.ps1"
. "$($PSScriptRoot)\lib\LocalLib.ps1"

# Global Varible Setting
$global:AoC.puzzle = "5-1"
$global:AoC.testInputMode = $false

$global:logSetting.fileOutput = $true
$global:logSetting.showDebug = $true
#=======================================

Write-Start
$data = Load-Input
$locations = @()
$mapping = @{}
$header = $flase
$key = ""

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
        $start = String-To-Int $split[1]
        Write-Log "adding $($start) - $($split[0]), $($split[2])"
        $mapping.$key.$start = @($split[0], $split[2])
    }

    if($line.Contains("map:") -eq $true -and $header -eq $false)
    {
        $key = $line.Replace(" map:","")
        Write-Log("Adding mappings - $($key)")
        $mapping.$key = @{}
        $header = $true
    }
}

#$map = "seed-to-soil"
#$start = 50
#Write-Host $mapping.$map.$start[0]

Write-Log "Collecting Seeds"
$seeds = $data[0].Replace("seeds: ","").Split(" ")
#$seeds = @(2035874278)
Write-Log "Fetching Locations"
foreach($seed in $seeds)
{
    $seedInt = (String-To-Int($seed)) 
    $soil = Mapping-Lookup $mapping."seed-to-soil" $seedInt 
    $fertilizer = Mapping-Lookup $mapping."soil-to-fertilizer" $soil 
    $water = Mapping-Lookup $mapping."fertilizer-to-water" $fertilizer 
    $light = Mapping-Lookup $mapping."water-to-light" $water 
    $temperature = Mapping-Lookup $mapping."light-to-temperature" $light 
    $humidity = Mapping-Lookup $mapping."temperature-to-humidity" $temperature 
    $location = Mapping-Lookup $mapping."humidity-to-location" $humidity

    $debug = @(
        "Seed - $($seed)",
        "Soil - $($soil)",
        "Fertilizer - $($fertilizer)",
        "Water - $($water)",
        "Light - $($light)",
        "Temperature - $($temperature)",
        "Humidity - $($humidity)",
        "Location - $($location)"
    )
    Write-Debug (Gen-Block "Mapping Debug" $debug)

    $locations += @($location)
}

Get-Answer $locations "min"
Write-End
