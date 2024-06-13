$packageDir = "C:\_Work\_Packages"
$testVer = "1.0.2"
$uiVer = "1.0.1"
$destDir = "$($PSScriptRoot)\_Testing"

Remove-Item -Path $destDir -Recurse -Force
Expand-Archive -Path "$($packageDir)\_testing-$($testVer).zip" -DestinationPath $destDir
Expand-Archive -Path "$($packageDir)\unit-test-display-$($uiVer).zip" -DestinationPath $destDir