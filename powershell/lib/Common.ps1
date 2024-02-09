########################################
#
# File Name:	Common.ps1
# Date Created:	17/01/2023
# Description:	
#	Function library for common used functions
#
########################################

# file imports
. "$($PSScriptRoot)\Logging.ps1"
. "$($PSScriptRoot)\Data.ps1"

########################################
#
# Name:		Run-Command
# Input:	$cmd <String>
#			$logDir <String> [Optional: "."]
# Output:	N/A
# Description:	
#	runs the command specified in $cmd and logs it to a .txt
#
########################################
function Run-Command($cmd,$logDir=".")
{
    $logfile = "${logDir}\_log\commands_$(Get-Date -UFormat "%m-%d-%Y").txt"
    $logEntry = "[$(Get-Date -UFormat "%R")] | ${cmd}"
    Write-Log "Running Command | ${cmd}"
    Append-File $logfile $logEntry
    Invoke-Expression -Command "& ${cmd}"
}

# $XMLFile = "file.xml"
# [XML]$settings = Get-Content $XmlFile
########################################
#
# Name:		Fetch-XMLVal
# Input:	$iniObj <XML Object>
#			$path <String>
# Output:	$val <Various>
# Description:	
#	returns the XML Element specified by the passed dot seperated path
#
########################################
function Fetch-XMLVal($iniObj,$path)
{
    $pathParts = $path.Split(".")
    $val = $iniObj
    foreach($pathPart in $pathParts)
    {
        $val = $val.$pathPart
    }
    Write-Log "${path}: ${val}"
    $val
}

########################################
#
# Name:		Bulk-Replace
# Input:	$string <String>
#			$values <Array>
# Output:	$updatesString <String>
# Description:	
#	does multiple substring replacements based on the key:value pairs passed in $values
#   key = find
#   value = replace
#
########################################
function Bulk-Replace($string,$values)
{
    $updatesString = $string
    Write-Log "-----<Bulk Replacing>-----"
    foreach($val in $values.GetEnumerator())
    {
        Write-Log "Replacing '$($val.Name)' with $($val.Value)"
        $updatesString = $updatesString.Replace($val.Name,$val.Value)
    }
    Write-Log "--------------------------"
    $updatesString
}

########################################
#
# Name:		FirstIndexOfAnyStr
# Input:	$str <String> 
#			$vals <Array>
# Output:	$arrIndex <Integer>
# Description:	
#	looks up which value in an array of strings first appears in a string and returns the array index. 
#   similar to IndexOfAny
#
########################################
function FirstIndexOfAnyStr($str,$vals)
{
    $arrIndex = -1
    $index = $str.Length
    
    $i = 0
    foreach($val in $vals)
    {
        $newIndex = $str.IndexOf($val)
        if($newIndex -gt -1)
        {
            if($newIndex -lt $index)
            {
                $index = $newIndex
                $arrIndex = $i
            }
        }
        $i += 1
    }

    return $arrIndex
}

########################################
#
# Name:		LastIndexOfAnyStr
# Input:	$str <String> 
#			$vals <Array>
# Output:	$arrIndex <Integer>
# Description:	
#	looks up which value in an array of strings appears last in a string and returns the array index
#
########################################
function LastIndexOfAnyStr($str,$vals)
{
    $arrIndex = -1
    $index = -1
    
    $i = 0
    foreach($val in $vals)
    {
        $newIndex = $str.LastIndexOf($val)
        if($newIndex -gt -1)
        {
            if($newIndex -gt $index)
            {
                $index = $newIndex
                $arrIndex = $i
            }
        }
        $i += 1
    }

    return $arrIndex
}

########################################
#
# Name:		Test-Function-Exists
# Input:	$command <String>
# Output:	N/A
# Description:	
#	checks if a function is defined
#
########################################
Function Test-Function-Exists($command, $crash=$true)
{
    # record existing error setting before changing
    $ErrorActionPreference_old = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    try 
    {
        # tried to trigger an error
        if(Get-Command $command)
        {
            Write-Success “'${command}' exists”
        }
    }
    catch
    {
        # if the error was triggered, display error message and exits the script if flagged
        Write-Error “${command} does not exist”
        if($crash -eq $true)
        {
            Exit
        }
    }
    finally
    {
        # restore error setting
        $ErrorActionPreference=$ErrorActionPreference_old
    }
}

########################################
#
# Name:		Test-Function-Loop
# Input:	$commands <Array>
# Output:	N/A
# Description:	
#	uses $commands in a loop to call Test-Function-Exists for consistant batch testing
#
########################################
Function Test-Function-Loop($commands, $crash=$true)
{
    foreach($command in $commands)
    {
        Write-Debug "testing ${command}"
        Test-Function-Exists $command $crash
    }
}

########################################
#
# Name:		JsonObj-To-Hash
# Input:	$jsonObj <Object>
# Output:	$returnHash <Hash Object>
# Description:	
#	converts a JSON object into an Hash Object
#
########################################
Function JsonObj-To-Hash($jsonObj)
{
    $returnHash = @{}
    foreach ($property in $jsonObj.PSObject.Properties) 
    {
        $returnHash[$property.Name] = $property.Value
    }
    return $returnHash
}

########################################
#
# Name:		NameValueCollection-To-Array
# Input:	$coll <Object - NameValueCollection>
# Output:	$returnArr <Array>
# Description:	
#	converts a NameValueCollection object into an Array of Strings formatted as "key = value"
#
########################################
Function NameValueCollection-To-Array($coll)
{
    $returnArr = @()

    foreach($key in $coll.Keys)
    {
        # checks if an array and if so loops through all the elements of it
        if($coll.GetValues($key).GetType().BaseType.Name -eq "Array")
        {
            foreach($arrItem in $coll.GetValues($key))
            {
                $returnArr += @("$($key) = $($arrItem)")
            }
        }
        else
        {
            $returnArr += @("$($key) = $($coll.GetValues($key))")
        }
    }

    return $returnArr
}

########################################
#
# Name:		String-to-TimeSpan
# Input:	$timeString <String>
# Output:	$timeSpan <Object - Timespan>
# Description:	
#	converts a : seperated string to be a Timespan Object
#
########################################
Function String-to-TimeSpan($timeString)
{
    # splits the string into time components
    $split = $timeString -split ":"

    # checks how many time components we are working with assuming order will always be Days > Hours > Minuites > Seconds
    switch ($split.Count)
    {
        1 {
            $timespan = New-TimeSpan -Seconds ([int]($split[0]))
            Break
        }
        2 {
            $timespan = New-TimeSpan -Minutes ([int]($split[0])) -Seconds ([int]($split[1]))
            Break
        }
        4 {
            $timespan = New-TimeSpan -Days ([int]($split[0])) -Hours ([int]($split[1])) -Minutes ([int]($split[2])) -Seconds ([int]($split[3]))
            Break
        }
        default {
            $timespan = New-TimeSpan -Hours ([int]($split[0])) -Minutes ([int]($split[1])) -Seconds ([int]($split[2]))
            Break
        }
    }

    return $timeSpan
}

########################################
# File I/O
########################################
########################################
#
# Name:		Create-Path
# Input:	$path <String> 
# Output:	N/A
# Description:	
#	creates the folder path of $path if it doesn't exist
#
########################################
function Create-Path($path)
{
    if((Test-Path -Path $path -PathType Container) -eq $false)
    {
        Write-Log "$path detected to be file, extracting"
        $path = Split-Path -Path $path -Parent
        Write-Log "Extracted Folder - ${path}"
    }


    if((Test-Path -Path $path) -eq $false)
    {
        Write-Warning "${path} does not exist, creating"
        New-Item -ItemType Directory -Force -Path $path
    }
}

########################################
#
# Name:		Append-File
# Input:	$file <String>
#			$str <String>
# Output:	File Output
# Description:	
#	Appends the passed $str to the specified $file
#
########################################
function Append-File($file,$str)
{
    Create-Path $file
    Write-Debug "Appending to ${file} - ${str}"
    Add-Content -Path $file -Value $str
}

########################################
#
# Name:		Write-File
# Input:	$file <String>
#			$str <String>
# Output:	File Output
# Description:	
#	replaces the content of $file with what is passed to $str
#
########################################
function Write-File($file,$str)
{
    Create-Path $file
    Write-Debug "Writing to ${file} - ${str}"
    Set-Content -Path $file -Value $str
}