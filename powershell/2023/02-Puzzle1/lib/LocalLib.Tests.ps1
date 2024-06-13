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
Describe 'Total-Game' {
    BeforeEach {
            $global:outputBuffer = @{}
            $outputBuffer."screen" = @()
        }
    
    It 'should total up all sets of game' {
        $game = @(
            @{"blue" = 3;"red" = 4},
            @{"blue" = 6;"red" = 1;"green" = 2},
            @{"green" = 2}
        )
        $total = Total-Game $game
        $total.red | Should -Be 5
        $total.green | Should -Be 4
        $total.blue | Should -Be 9
    }

    It 'should zero out color missing' {
        $game = @(
            @{"red" = 4},
            @{"red" = 1;"green" = 2},
            @{"green" = 2}
        )
        $total = Total-Game $game
        $total.red | Should -Be 5
        $total.green | Should -Be 4
        $total.blue | Should -Be 0
    }

    It 'should include any color, not just reg green blue' {
        $game = @(
            @{"blue" = 3;"red" = 4;"black" = 2},
            @{"blue" = 6;"red" = 1;"green" = 2;"yellow" = 1},
            @{"green" = 2;"black" = 10}
        )
        $total = Total-Game $game
        $total.red | Should -Be 5
        $total.green | Should -Be 4
        $total.blue | Should -Be 9
        $total.yellow | Should -Be 1
        $total.black | Should -Be 12
    }
}

Describe 'Max-Game' {
    BeforeEach {
            $global:outputBuffer = @{}
            $outputBuffer."screen" = @()
        }
    
    It 'should return the highest value out of all sets for each color' {
        $game = @(
            @{"blue" = 3;"red" = 4},
            @{"blue" = 6;"red" = 1;"green" = 2},
            @{"green" = 2}
        )
        $max = Max-Game $game
        $max.red | Should -Be 4
        $max.green | Should -Be 2
        $max.blue | Should -Be 6
    }

    It 'should zero out color missing' {
        $game = @(
            @{"red" = 4},
            @{"red" = 1;"green" = 2},
            @{"green" = 2}
        )
        $max = Max-Game $game
        $max.red | Should -Be 4
        $max.green | Should -Be 2
        $max.blue | Should -Be 0
    }

    It 'should include any color, not just reg green blue' {
        $game = @(
            @{"blue" = 3;"red" = 4;"black" = 2},
            @{"blue" = 6;"red" = 1;"green" = 2;"yellow" = 1},
            @{"green" = 2;"black" = 10}
        )
        $max = Max-Game $game
        $max.red | Should -Be 4
        $max.green | Should -Be 2
        $max.blue | Should -Be 6
        $max.yellow | Should -Be 1
        $max.black | Should -Be 10
    }
}