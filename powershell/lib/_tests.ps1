. "$($PSScriptRoot)\..\lib\Common.ps1"

function Test-Fetch-XMLVal($xmlObj, $path)
{
    
    $fetchedData = Fetch-XMLVal $xmlObj $path
    Write-Log "Fetch-XMLVal with path = ${path} returned `"$($fetchedData)`"" 1
}

Write-Host "Logging.ps1 Test"

Write-Log "Write-Log"
Write-Log "Write-Log with 2 Indents" 2
Write-Log "Write-Log with 1 Indent and White Text" 1 "White"
Write-Log "Write-Log with 1 Indent and Blue Text and TEST as the key" 1 "Blue" "TEST"

Write-Warning "Write-Warning"
Write-Warning "Write-Warning with 1 Indent" 1
Write-Error "Write-Error"
Write-Error "Write-Error with 2 Indent" 2
Write-Success "Write-Success"
Write-Success "Write-Success with 3 Indent" 3
Write-Debug "Write-Debug"
Write-Debug "Write-Debug with 4 Indent" 4

Write-Start
Start-Sleep -Seconds 1.5
Write-End
Gen-Block "Gen Block" @("message 1","message 2","message 3","message 4","message 5")

$logSetting.showWarning = $false
Write-Warning "Write-Warning display showWarning = False (should not appear)"
$logSetting.showWarning = $true
$logSetting.showError = $false
Write-Error "Write-Error display showError = False (should not appear)"
$logSetting.showError = $true
$logSetting.showDebug = $false
Write-Debug "Write-Debug display showDebug = False (should not appear)"
$logSetting.showDebug = $true

$logSetting.showLog = $false
Write-Log "Write-Log display showLog = False (should not appear)"
Write-Warning "Write-Warning display showLog = False (should not appear)"
Write-Error "Write-Error display showLog = False (should not appear)"
Write-Success "Write-Success display showLog = False (should not appear)"
Write-Debug "Write-Debug display showLog = False (should not appear)"
$logSetting.showLog = $true

Write-Host "----------------"
#---------------------------------------------------
Write-Log "Common.ps1 Test"

Write-Log "Run-Command" 1
Run-Command "dir"
Run-Command "ipconfig"

Write-Log "Fetch-XMLVal" 1

# gets repository data
$xmlFile = "$($PSScriptRoot)\_testData\test.xml"
[XML]$xmlFileData = Get-Content $xmlFile

$testPath = "test.testChild1"
Test-Fetch-XMLVal $xmlFileData $testPath

$testPath = "test.general.testChild2"
Test-Fetch-XMLVal $xmlFileData $testPath

$testPath = "test.attrib.testChild1"
Test-Fetch-XMLVal $xmlFileData $testPath

$testPath = "test.attrib.testChild3"
Test-Fetch-XMLVal $xmlFileData $testPath
$fetchedData = Fetch-XMLVal $xmlFileData $testPath
Write-Log "Fetch-XMLVal with path = ${testPath} text value `"$($fetchedData.'#text')`"" 1
Write-Log "Fetch-XMLVal with path = ${testPath} childAttrib1 attribute value `"$($fetchedData.childAttrib1)`"" 1
Write-Log "Fetch-XMLVal with path = ${testPath} childAttrib2 attribute value `"$($fetchedData.childAttrib2)`"" 1


Write-Log "----------------"