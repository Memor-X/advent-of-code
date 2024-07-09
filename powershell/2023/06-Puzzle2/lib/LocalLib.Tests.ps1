BeforeAll {
    # Dyanmic Link to file to test
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')

    # Variables
    $global:outputBuffer = @{}
    $outputBuffer."screen" = @()

    # Function Mocking
    Mock Add-Content {
        $file = (Out-String -InputObject $PesterBoundParameters.Path).Trim()
        if($outputBuffer.ContainsKey($file) -eq $false)
        {
            $outputBuffer.$file = @()
        }
        $outputBuffer.$file += @($PesterBoundParameters.Value)
    }
    Mock Set-Content {
        $file = (Out-String -InputObject $PesterBoundParameters.Path).Trim()
        $outputBuffer.$file = @($PesterBoundParameters.Value)
    }
    Mock Write-Host {
        $outputBuffer."screen" += @(@{
            "msg" = (Out-String -InputObject $PesterBoundParameters.Object).Trim()
            "color" = (Out-String -InputObject $PesterBoundParameters.ForegroundColor).Trim()
        })
    }
    Mock Get-Date {
        $returnVal = ""
        switch($PesterBoundParameters.UFormat)
        {
            "%m-%d-%Y" {
                $returnVal = "01-01-2000"
                break
            }
            "%R"{
                $returnVal = "11:10"
                break
            }
            "%m/%d/%Y %R"{
                $returnVal = "01/01/2000 11:10"
                break
            }
            default {
                $returnVal = New-Object DateTime 2000, 1, 1, 11, 10, 0
                break
            }
        }
        return $returnVal
    }
}

# Tests
Describe 'Build-Race-Data' {
    BeforeEach {
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()

        $inputData = @(
            "Time:      2  16",
            "Distance:  57  542"
        )
        $raceData = (Build-Race-Data $inputData)
    }

    It 'Race should exists' {
        $raceData.ContainsKey("time") | Should -Be $true
    }
    It 'Time should be Integer' {
        $raceData."time".GetType() | Should -Be "long"
    }
    It 'Race Time is set to 216' {
        $raceData."time" | Should -Be 216
    }
    It 'Race Record Distance should be Integer' {
        $raceData."record-dist".GetType() | Should -Be "long"
    }
    It 'Race Record Distance is set to 9' {
        $raceData."record-dist" | Should -Be 57542
    }
}

Describe 'Find-Winning-Charges' {
    BeforeEach {
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
    }

    It 'Race Time <time> with Record Distance of <dist> should have <winners> Winning combinations' -TestCases @(
        @{time = 5; dist = 4; winners = 2}
        @{time = 5; dist = 999; winners = 0}
        @{time = 5; dist = 0; winners = 4}
        @{time = 8; dist = 10; winners = 5}
    ){
        $inputData = @{
            "time" = $time
            "record-dist" = $dist
        }
        $rtnData = (Find-Winning-Charges $inputData)
        $rtnData | Should -be $winners
    }
}
