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

Describe 'Load-Input' {
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
        $AoC.testInputMode = $false
        $AoC.inputFile_Extra = ""

        mock Get-Content {
            $returnval = @()
            if($AoC.testInputMode -eq $true)
            {
                $returnval = @("test","data")
            }
            elseif($AoC.inputFile_Extra.Length -gt 0)
            {
                $returnval = @("custom","data")
            }
            else
            {
                $returnval = @("real","data")
            }

            return @($returnval)
        }
    }

    It 'Loads Input Data' {
        $data = Load-Input
        $data[0] | Should -Be "real"
    }

    It 'Loads Test Input Data' {
        $AoC.testInputMode = $true
        $data = Load-Input
        $data[0] | Should -Be "test"
    }

    It 'Loads Custom Input Data' {
        $AoC.inputFile_Extra = "my_test_file"
        $data = Load-Input
        $data[0] | Should -Be "custom"
    }

    It 'Loads Test Input Data over Custom Input Data' {
        $AoC.testInputMode = $true
        $AoC.inputFile_Extra = "my_test_file"
        $data = Load-Input
        $data[0] | Should -Be "test"
    }
}

Describe 'Get-Answer'{
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
        $AoC.testInputMode = $false
        $AoC.inputFile_Extra = ""
    }

    It 'Get Calculation <calc>, should return <answer>' -TestCases @(
        @{calc = 'sum'; col = @(1,2,3,4,5); answer = 15}
        @{calc = 'min'; col = @(3,1,10,4,5); answer = 1}
        @{calc = 'prod'; col = @(1,2,3,4,5); answer = 120}
    ){
        Get-Answer $col $calc
        $outputBuffer."screen"[$outputBuffer."screen".length-1].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | AoC Day 0-0 Answer: $($answer)"
    }

    It 'Puzzle Number Updates' {
        $col = @(1,2,3,4,5)
        $AoC.puzzle = "99-69"
        Get-Answer $col
        $outputBuffer."screen"[$outputBuffer."screen".length-1].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | AoC Day 99-69 Answer: 15"
    }
}