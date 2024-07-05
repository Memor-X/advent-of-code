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
Describe 'Mapping-Lookup' {
    BeforeEach {
            $global:outputBuffer = @{}
            $outputBuffer."screen" = @()
        }


    Context 'AoC example' {
        BeforeEach {
            $mapping = @{
                "seed-to-soil" = @{
                    98 = @("50", "2")
                    50 = @("52", "48")
                }
                "soil-to-fertilizer" = @{
                    15 = @("0", "37")
                    52 = @("37", "2")
                    0 = @("39", "15")
                }
            }
        }

        It 'Seed <seed> should return Soil <soil>' -TestCases @(
            @{seed = 79; soil = 81}
            @{seed = 14; soil = 14}
            @{seed = 55; soil = 57}
            @{seed = 13; soil = 13}
        ){
            $rtnSoil = Mapping-Lookup $mapping."seed-to-soil" $seed
            $rtnSoil | Should -Be $soil
        }   
        
        It 'Seed <soil> should return Fertilizer <fertilizer>' -TestCases @(
            @{soil = 81; fertilizer = 81}
            @{soil = 14; fertilizer = 53}
            @{soil = 57; fertilizer = 57}
            @{soil = 13; fertilizer = 52}
        ){
            $rtnFert = Mapping-Lookup $mapping."soil-to-fertilizer" $soil
            $rtnFert | Should -Be $fertilizer
        }
    }
}