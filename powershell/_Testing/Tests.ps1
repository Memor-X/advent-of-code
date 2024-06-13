########################################
#
# File Name:	Tests.ps1
# Date Created:	04/03/2024
# Description:	
#	Test Runner for Pester Powershell Unit Tests
#
########################################

# File Arguments
param (
    $suite="*"
)

function Write-Test-Log($str)
{
    Write-Host "$($str)" -Foregroundcolor Magenta
}

Write-Test-Log "Setting Up Pester"
$config = New-PesterConfiguration

$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.OutputPath = "$($PSScriptRoot)\results\coverage.xml"
$config.CodeCoverage.OutputFormat = "CoverageGutters"
$config.CodeCoverage.CoveragePercentTarget = 90

$config.TestResult.Enabled = $true
$config.TestResult.OutputPath = "$($PSScriptRoot)\results\testResults.xml"

$config.Output.Verbosity = "Detailed"

Write-Test-Log "Compiling Suite"
$fullSuiteVals = @(
    "*",
    "all",
    "full"
)
$testSuite = @()
$codeCoverageSuite = @()

if($fullSuiteVals.Contains($suite) -eq $true)
{
    Write-Test-Log "Collecting all Tests for Suite"
    $files = Get-ChildItem -Path ".." -Filter "*.Tests.ps1" -Recurse
    foreach($file in $files)
    {
        Write-Test-Log "`tAdding Test - $($file.FullName)"
        $testSuite += @($file.FullName)
        $codeCoverageSuite += @($file.FullName.Replace(".Tests",""))
    }
}
else
{
    Write-Test-Log "Splitting string for Suite"
    $testSplit = $suite.split("<|>")
    foreach($file in $testSplit)
    {
        if((Test-Path $file -PathType Leaf) -eq $true)
        {
            Write-Test-Log "Adding Single File - $($file)"
            $testSuite += @($file)
            $codeCoverageSuite += @($file.Replace(".Tests",""))
        }
        elseif((Test-Path $file -PathType Container) -eq $true)
        {
            Write-Test-Log "Adding Folder - $($file)"
            $files = Get-ChildItem -Path $file -Filter "*.Tests.ps1" -Recurse
            foreach($subfile in $files)
            {
                Write-Test-Log "`tAdding Test from folder Folder - $($subfile.FullName)"
                $testSuite += @($subfile.FullName)
                $codeCoverageSuite += @($subfile.FullName.Replace(".Tests",""))
            }
        }
        else
        {
            Write-Test-Log "Can not find test file $($file)"
        }
    }
}

$config.Run.Path = $testSuite
$config.CodeCoverage.Path = $codeCoverageSuite

Write-Test-Log ""
Invoke-Pester -Configuration $config