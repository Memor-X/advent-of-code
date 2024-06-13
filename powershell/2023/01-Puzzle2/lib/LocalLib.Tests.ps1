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
Describe 'Get-Calibration' {
    BeforeEach {
            $global:outputBuffer = @{}
            $outputBuffer."screen" = @()
        }

    It 'Gets calibration from string with letters and numbers' {
        $line = "1abc2"
        $calibration = Get-Calibration $line
        $calibration | Should -Be 12
    }

    It 'Gets calibration from string with letters and numbers and symbols' {
        $line = "a1-bc2"
        $calibration = Get-Calibration $line
        $calibration | Should -Be 12
    }

    It 'Gets calibration from string with just numbers' {
        $line = "12"
        $calibration = Get-Calibration $line
        $calibration | Should -Be 12
    }

    It 'Gets calibration when there is 5 numbers in the string' {
        $line = "1ds1ag6h8dsa7hu"
        $calibration = Get-Calibration $line
        $calibration | Should -Be 17
    }

    It 'Gets calibration from worded number' {
        $line = "hakfourshskadjhdk6jas"
        $calibration = Get-Calibration $line
        $calibration | Should -Be 46
    }

    It 'Gets calibration from 2 worded number' {
        $line = "hakfourshskadjsixhdk6jas"
        $calibration = Get-Calibration $line
        $calibration | Should -Be 46
    }

    It 'Gets calibration from 2 worded number for start and end' {
        $line = "hakfourshs9kadjsixhdk6jasevens"
        $calibration = Get-Calibration $line
        $calibration | Should -Be 47
    }
}