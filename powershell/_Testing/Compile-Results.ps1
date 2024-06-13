# File Imports
. "$($PSScriptRoot)\lib\Common.ps1"

$global:logSetting.showDebug = $false

function Get-Suites($resultsNode)
{
    $returnArr = @()

    # loops through Test Suites
    Write-Debug "Test Suites = $($resultsNode.Length)"
    for($i = 0; $i -lt $resultsNode.Length; $i += 1)
    {
        $file = $resultsNode[$i]
        Write-Debug "Processing Test Suite $($i) - $($file.name)"
        $testSuiteHash = @{
            "file" = $file.name.Replace("\","/").Replace(".Tests.ps1",".ps1")
            "test-file" = $file.name.Replace("\","/")
            "executed" = $file.executed
            "result" = $file.result
            "success" = $file.success
            "time" = $file.time
            "test-case-count" = 0
            "test-cases" = @(Get-Test-Results $file.results."test-suite")
        }

        $returnArr += @($testSuiteHash)
    }

    return $returnArr
}

function Get-Test-Results($tests,$type="test-function")
{
    $returnArr = @()
    $tests = @($tests)

    # loops throughs tests collections
    Write-Debug "Tests = $($tests.Length)"
    for($i = 0; $i -lt $tests.Length; $i += 1)
    {
        $test = $tests[$i]
        Write-Debug "Adding Test - $($test.description)"
        $testHash = @{
            "name" = $test.description
            "executed" = $test.executed
            "result" = $test.result
            "type" = $type
            "time" = $test.time
            "asserts" = $test.asserts
            "tests" = @()
        }

        # loops through indivisual test cases
        for($j = 0; $j -lt $test.results.ChildNodes.Count; $j += 1)
        {
            # checks if it is actually a test case, otherwise assuming it's a sub group
            if($test.results.ChildNodes[$j].LocalName -eq "test-case")
            {
                Write-Debug "Adding test-case - $($test.results.ChildNodes[$j].description)"
                $testCaseHash = @{
                    "name" = $test.results.ChildNodes[$j].description.Replace("\","/")
                    "type" = "test-case"
                    "time" = $test.results.ChildNodes[$j].time
                    "asserts" = $test.results.ChildNodes[$j].asserts
                    "success" = $test.results.ChildNodes[$j].success
                    "result" = $test.results.ChildNodes[$j].result
                    "executed" = $test.results.ChildNodes[$j].executed
                }

                $testHash.tests += @($testCaseHash)
            }
            elseif($test.results.ChildNodes[$j].LocalName -eq "test-suite")
            {
                Write-Debug "Adding test-suite - $($test.results.ChildNodes[$j].description)"
                $testHash.tests += @((Get-Test-Results $test.results.ChildNodes[$j] "test-suite"))
            }
        }

        $returnArr += @($testHash)
    }

    return $returnArr
}

function Get-Coverage($coverageXML)
{
    $returnArr = @()
    $compileHash = @{}

    foreach($package in $coverageXML.report.package)
    {
        # looping though all the "classes" to get Method Coverage
        foreach($class in $package.class)
        {
            Write-Debug $class.name
            $correctedSourceName = "$($class.name.Replace("\","/")).ps1"
            $compileHash."$($correctedSourceName)" = @{
                "lines" = @()
                "functions" = @()
            }

            foreach($method in $class.method)
            {
                $functionHash = @{
                    "name" = "$($method.name)"
                    "line no" = $method.line
                }
                
                foreach($counter in $method.counter)
                {
                    $functionHash."$($counter.type.ToLower())s" = @{
                        "covered"=$counter.covered
                        "missed"=$counter.missed
                    }
                }

                $compileHash."$($correctedSourceName)"."functions" += @($functionHash)
            }
        }

        # looping though all the source to get Line coverage seperately to match files in classes loop (using file name as Hash key)
        foreach($sourcefile in $package.sourcefile)
        {
            $correctedSourceName = "$($package.name.Replace("\","/"))/$($sourcefile.name)"
            foreach($line in $sourcefile.line)
            {
                $lineData = @{
                    "line number" = $line.nr
                    "instructions" = @{
                        "missed" = $line.mi
                        "covered" = $line.ci
                    }
                    "branches" = @{
                        "missed" = $line.mb 
                        "covered" = $line.cb 
                    }
                }
                $compileHash."$($correctedSourceName)".lines += @($lineData)
            }
        }
    }

    # converting hash to array to return
    foreach($result in $compileHash.GetEnumerator())
    {
        $returnArr += @(@{
            "name" = $result.Name
            "lines" = $result.Value.lines
            "functions" = $result.Value.functions
        })
    }

    return $returnArr
}

Write-Log "Compiling results for webpage - Test Results"
$testResults = "$($PSScriptRoot)\results\testResults.xml"
[XML]$testResultsXML = Get-Content $testResults

Write-Log "Getting Node Data"
$testResultsNode = Fetch-XMLVal $testResultsXML "test-results"
$environmentNode =  Fetch-XMLVal $testResultsXML "test-results.environment"
$rootTestSuiteNode = Fetch-XMLVal $testResultsXML "test-results.test-suite"
$testResultsNodes = Fetch-XMLVal $testResultsXML "test-results.test-suite.results.test-suite"

Write-Log "Compiling Inital Test Result Object"
$testResultsObj = @{
    "system" = @{
        "program" = $testResultsNode.name
        "runtime" = "$($testResultsNode.date) $($testResultsNode.time)"
        "language" = "Powershell"
        "time" = $rootTestSuiteNode.time
    }
    "test-results-summary" = @{
        "total" = $testResultsNode.total
        "errors" = $testResultsNode.errors
        "failures" = $testResultsNode.failures
        "not-run" = $testResultsNode."not-run"
        "inconclusive" = $testResultsNode.inconclusive
        "ignored" = $testResultsNode.ignored
        "skipped" = $testResultsNode.skipped
        "invalid" = $testResultsNode.invalid
    }
    "environment" = @{
        "machine-name" = $environmentNode."machine-name"
        "os-version" = $environmentNode."os-version"
        "platform" = $environmentNode.platform.Replace("\","/")
        "nunit-version" = $environmentNode."nunit-version"
    }
}

Write-Log "Getting Test Results"
$testResultsObj."test-suites" = @(Get-Suites @($testResultsNodes))
Write-File "$($PSScriptRoot)\results\Compiled-Test_data.js" "var testData = JSON.parse('$(($testResultsObj | ConvertTo-Json -Compress -EscapeHandling 'EscapeHtml' -Depth 100))')"

Write-Log "Compiling results for webpage - Code Coverage"
$coverage = "$($PSScriptRoot)\results\coverage.xml"
[XML]$coverageXML = Get-Content $coverage

# nr = the line number in the source code file
# mi = the number of missed instructions
# ci = covered instructions
# mb = missed branches
# cb = covered branches

Write-Log "Compiling Inital Code Coverage Object"
$coverageObj = @{
    "system" = $testResultsObj.system
    "environment" = $testResultsObj.environment
}

Write-Log "Getting Code Coverage Data"
$coverageObj."test-suites" = @(Get-Coverage $coverageXML)
Write-File "$($PSScriptRoot)\results\Compiled-Coverage_data.js" "var coverageData = JSON.parse('$(($coverageObj | ConvertTo-Json -Compress -EscapeHandling 'EscapeHtml' -Depth 100))')"

