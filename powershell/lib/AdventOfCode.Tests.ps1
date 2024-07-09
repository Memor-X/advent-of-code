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

    It 'Get Calculation <calc> with <desc>, should return <answer>' -TestCases @(
        @{calc = 'sum'; col = @(1,2,3,4,5); answer = 15; desc = "5 numbers"}
        @{calc = 'sum'; col = @(1,2); answer = 3; desc = "2 numbers"}
        @{calc = 'sum'; col = @(1); answer = 1; desc = "1 number"}
        @{calc = 'min'; col = @(3,1,10,4,5); answer = 1; desc = "5 numbers"}
        @{calc = 'min'; col = @(3,5); answer = 3; desc = "2 numbers"}
        @{calc = 'min'; col = @(5); answer = 5; desc = "1 number"}
        @{calc = 'prod'; col = @(1,2,3,4,5); answer = 120; desc = "5 numbers"}
        @{calc = 'prod'; col = @(2,3); answer = 6; desc = "2 numbers"}
        @{calc = 'prod'; col = @(3); answer = 3; desc = "1 number"}
        @{calc = 'prod'; col = @(1,2,0,4,5); answer = 0; desc = "5 numebrs with 0"}
        @{calc = 'prod'; col = @(0,0); answer = 0; desc = "2 0's"}
        @{calc = 'static'; col = @(16); answer = 16; desc = "1 number in array"}
        @{calc = 'static'; col = 16; answer = 16; desc = "1 number as integer"}
        @{calc = 'static'; col = "16"; answer = 16; desc = "1 number as string"}
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