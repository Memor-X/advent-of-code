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
    }
    
    Context "Single Race" {
        BeforeEach {
            $inputData = @(
                "Time:      7",
                "Distance:  9"
            )
            $raceData = (Build-Race-Data $inputData)
        }

        It 'Race 1 exists' {
            $raceData.ContainsKey("race 1") | Should -Be $true
        }
        It 'Race 1 Time should be Integer' {
            $raceData."race 1"."time".GetType() | Should -Be "long"
        }
        It 'Race 1 Time is set to 7' {
            $raceData."race 1"."time" | Should -Be 7
        }
        It 'Race 1 Record Distance should be Integer' {
            $raceData."race 1"."record-dist".GetType() | Should -Be "long"
        }
        It 'Race 1 Record Distance is set to 9' {
            $raceData."race 1"."record-dist" | Should -Be 9
        }
    }

    Context 'Two Races' {
        BeforeEach {
            $inputData = @(
                "Time:      2  16",
                "Distance:  57  542"
            )
            $raceData = (Build-Race-Data $inputData)
        }

        It 'Race <raceno> exists' -TestCases @(
            @{raceno = 1}
            @{raceno = 2}
        ){
            $raceData.ContainsKey("race $($raceno)") | Should -Be $true
        }
        It 'Race <raceno> Time should be Integer' -TestCases @(
            @{raceno = 1}
            @{raceno = 2}
        ){
            $raceData."race $($raceno)"."time".GetType() | Should -Be "long"
        }
        It 'Race <raceno> Time is set to <time>' -TestCases @(
            @{raceno = 1; time = 2}
            @{raceno = 2; time = 16}
        ){
            $raceData."race $($raceno)"."time" | Should -Be $time
        }
        It 'Race <raceno> Record Distance should be Integer' -TestCases @(
            @{raceno = 1}
            @{raceno = 2}
        ){
            $raceData."race $($raceno)"."record-dist".GetType() | Should -Be "long"
        }
        It 'Race <raceno> Record Distance is set to <distance>' -TestCases @(
            @{raceno = 1; distance = 57}
            @{raceno = 2; distance = 542}
        ){
            $raceData."race $($raceno)"."record-dist" | Should -Be $distance
        }
    }
}

Describe 'Find-Charges' {
    BeforeEach {
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
    }

    Context 'Race with time of 5' {
        BeforeEach {
            $inputData = @{
                "time" = 5
                "record-dist" = 12
            }
            $rtnData = (Find-Charges $inputData)
        }

        It 'should have 6 entries' {
            $rtnData.Count | Should -Be 6
        }

        It 'Time <time> matches charge' -TestCases @(
            @{time = 0}
            @{time = 1}
            @{time = 2}
            @{time = 3}
            @{time = 4}
            @{time = 5}
        ){
            $rtnData[$time]."charge" | Should -be $time
        }

        It 'Charge of <charge> should have Time Left of of <remaining>' -TestCases @(
            @{charge = 0; remaining = 5}
            @{charge = 1; remaining = 4}
            @{charge = 2; remaining = 3}
            @{charge = 3; remaining = 2}
            @{charge = 4; remaining = 1}
            @{charge = 5; remaining = 0}
        ){
            $rtnData[$charge]."time-left" | Should -be $remaining
        }

        It 'Charge of <charge> should cover Disntace of <distance>' -TestCases @(
            @{charge = 0; distance = 0}
            @{charge = 1; distance = 4}
            @{charge = 2; distance = 6}
            @{charge = 3; distance = 6}
            @{charge = 4; distance = 4}
            @{charge = 5; distance = 0}
        ){
            $rtnData[$charge]."traveled" | Should -be $distance
        }
    }
}

Describe 'Find-Winners' {
    BeforeEach {
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
    }

    Context 'With result from a race with time of 5 and record of 4' {
        BeforeEach {
            $inputData = @(
                @{
                    "charge" = 0
                    "time-left" = 5
                    "traveled" = 0
                }
                @{
                    "charge" = 1
                    "time-left" = 4
                    "traveled" = 4
                }
                @{
                    "charge" = 2
                    "time-left" = 3
                    "traveled" = 6
                }
                @{
                    "charge" = 3
                    "time-left" = 2
                    "traveled" = 6
                }
                @{
                    "charge" = 4
                    "time-left" = 1
                    "traveled" = 4
                }
                @{
                    "charge" = 5
                    "time-left" = 0
                    "traveled" = 0
                }
            )
            $record = 4
            $rtnData = (Find-Winners $inputData $record)
        }

        It 'should have 2 entries' {
            $rtnData.Count | Should -Be 2
        }

        It 'Charge of <charge> should be in collection' -TestCases @(
            @{charge = 2}
            @{charge = 3}
        ){
            $found = $false
            foreach($val in $rtnData)
            {
                if($val."charge" -eq $charge)
                {
                    $found = $true
                    break
                }
            }
            $found | Should -Be $true
        }
    }

    Context 'With result from a race with time of 5 and record of 999' {
        BeforeEach {
            $inputData = @(
                @{
                    "charge" = 0
                    "time-left" = 5
                    "traveled" = 0
                }
                @{
                    "charge" = 1
                    "time-left" = 4
                    "traveled" = 4
                }
                @{
                    "charge" = 2
                    "time-left" = 3
                    "traveled" = 6
                }
                @{
                    "charge" = 3
                    "time-left" = 2
                    "traveled" = 6
                }
                @{
                    "charge" = 4
                    "time-left" = 1
                    "traveled" = 4
                }
                @{
                    "charge" = 5
                    "time-left" = 0
                    "traveled" = 0
                }
            )
            $record = 999
            $rtnData = (Find-Winners $inputData $record)
        }

        It 'should have 0 entries' {
            $rtnData.Count | Should -Be 0
        }
    }

    Context 'With result from a race with time of 5 and record of 0' {
        BeforeEach {
            $inputData = @(
                @{
                    "charge" = 0
                    "time-left" = 5
                    "traveled" = 0
                }
                @{
                    "charge" = 1
                    "time-left" = 4
                    "traveled" = 4
                }
                @{
                    "charge" = 2
                    "time-left" = 3
                    "traveled" = 6
                }
                @{
                    "charge" = 3
                    "time-left" = 2
                    "traveled" = 6
                }
                @{
                    "charge" = 4
                    "time-left" = 1
                    "traveled" = 4
                }
                @{
                    "charge" = 5
                    "time-left" = 0
                    "traveled" = 0
                }
            )
            $record = 0
            $rtnData = (Find-Winners $inputData $record)
        }

        It 'should have 6 entries' {
            $rtnData.Count | Should -Be 4
        }

        It 'Charge of <charge> should be in collection' -TestCases @(
            @{charge = 1}
            @{charge = 2}
            @{charge = 3}
            @{charge = 4}
        ){
            $found = $false
            foreach($val in $rtnData)
            {
                if($val."charge" -eq $charge)
                {
                    $found = $true
                    break
                }
            }
            $found | Should -Be $true
        }
    }

    Context 'With result from a race with time of 5 and record of 4.5' {
        BeforeEach {
            $inputData = @(
                @{
                    "charge" = 0
                    "time-left" = 5
                    "traveled" = 0
                }
                @{
                    "charge" = 1
                    "time-left" = 4
                    "traveled" = 4
                }
                @{
                    "charge" = 2
                    "time-left" = 3
                    "traveled" = 6
                }
                @{
                    "charge" = 3
                    "time-left" = 2
                    "traveled" = 6
                }
                @{
                    "charge" = 4
                    "time-left" = 1
                    "traveled" = 4
                }
                @{
                    "charge" = 5
                    "time-left" = 0
                    "traveled" = 0
                }
            )
            $record = 4.5
            $rtnData = (Find-Winners $inputData $record)
        }

        It 'should have 4 entries' {
            $rtnData.Count | Should -Be 2
        }

        It 'Charge of <charge> should be in collection' -TestCases @(
            @{charge = 2}
            @{charge = 3}
        ){
            $found = $false
            foreach($val in $rtnData)
            {
                if($val."charge" -eq $charge)
                {
                    $found = $true
                    break
                }
            }
            $found | Should -Be $true
        }
    }
}