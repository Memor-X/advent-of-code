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
Describe 'Compile-Input-Data' {
    BeforeEach {
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
    }

    Context 'Creating 1 mappping' {
        BeforeEach {
            $inputData = @(
                "seeds",
                "",
                "soil-to-fertilizer map:",
                "0 15 37",
                "37 52 2",
                "39 0 15"
            )

            $mapping = Compile-Input-Data $inputData
        }

        It 'only 1 mapping group exists' {
            @($mapping.Keys).Length | Should -Be 1
        }
        It 'mapping is soil-to-fertilizer' {
            $mapping.Contains("soil-to-fertilizer") | Should -Be $true
        }
        It 'soil-to-fertilizer has 4 mappings (3 specified and last one appended)' {
            @($mapping."soil-to-fertilizer".Keys).Length | Should -Be 4
        }
        It 'soil-to-fertilizer mapping has mapped value and range' {
            $mapping."soil-to-fertilizer"."15".Length | Should -Be 2
        }
    }

    Context 'Creates 2 mapppings' {
        BeforeEach {
            $inputData = @(
                "seeds",
                "",
                "soil-to-fertilizer map:",
                "0 15 37",
                "37 52 2",
                "39 0 15",
                "",
                "temperature-to-humidity map:",
                "0 69 1",
                "1 0 69"
            )

            $mapping = Compile-Input-Data $inputData
        }

        It 'only 2 mapping groups exists' {
            @($mapping.Keys).Length | Should -Be 2
        }
        It 'mapping is temperature-to-humidity exists' {
            $mapping.Contains("temperature-to-humidity") | Should -Be $true
        }
        It 'temperature-to-humidity has 3 mappings (2 specified and last one appended)' {
            @($mapping."temperature-to-humidity".Keys).Length | Should -Be 3
        }
        It 'temperature-to-humidity mapping has mapped value and range' {
            $mapping."temperature-to-humidity"."69".Length | Should -Be 2
        }
    }

    Context 'Gap Filling' {
        BeforeEach {
            $inputData = @(
                "seeds",
                "",
                "soil-to-fertilizer map:",
                "39 0 15",
                "0 15 30",
                "37 52 2"
            )

            $mapping = Compile-Input-Data $inputData
        }

        It '5 mappings exists' {
            @($mapping."soil-to-fertilizer".Keys).Length | Should -Be 5
        }
        It 'mapping for 45 exists' {
            $mapping."soil-to-fertilizer".Contains("45") | Should -Be $true
        }
        It 'mapping 45 has mapped value and range' {
            $mapping."soil-to-fertilizer"."45".Length | Should -Be 2
        }
        It 'mapping 45 maps to 45' {
            $mapping."soil-to-fertilizer"."45"[0] | Should -Be 45
        }
    }

    Context '0 mapping' {
        BeforeEach {
            $inputData = @(
                "seeds",
                "",
                "soil-to-fertilizer map:",
                "0 15 37",
                "37 52 2"
            )

            $mapping = Compile-Input-Data $inputData
        }

        It '4 mappings exists. existing 2. end mapping and 0 mapping' {
            @($mapping."soil-to-fertilizer".Keys).Length | Should -Be 4
        }
        It 'mapping for 0 exists' {
            $mapping."soil-to-fertilizer".Contains("0") | Should -Be $true
        }
        It 'mapping 0 has mapped value and range' {
            $mapping."soil-to-fertilizer"."0".Length | Should -Be 2
        }
        It 'mapping  maps to 0' {
            $mapping."soil-to-fertilizer"."0"[0] | Should -Be 0
        }
    }
}

Describe 'Mapping-Lookup' {
    BeforeEach {
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
    }

    Context 'AoC example' {
        BeforeEach {
            $mapping = @{
                "seed-to-soil" = @{
                    "98" = @("50", "2")
                    "50" = @("52", "48")
                }
                "soil-to-fertilizer" = @{
                    15 = @("0", "37")
                    52 = @("37", "2")
                    0 = @("39", "15")
                }
                "fertilizer-to-water" = @{
                    53 = @("49", "8")
                    11 = @("0", "42")
                    0 = @("42", "7")
                    7 = @("57", "4")
                }
                "water-to-light" = @{
                    18 = @("88", "7")
                    25 = @("18", "70")
                }
                "light-to-temperature" = @{
                    77 = @("45", "23")
                    45 = @("81", "19")
                    64 = @("68", "13")
                }
                "temperature-to-humidity" = @{
                    69 = @("0", "1")
                    0 = @("1", "69")
                }
                "humidity-to-location" = @{
                    56 = @("60", "37")
                    93 = @("56", "4")
                }
            }
        }

        It 'Seed <seed> should return Soil <soil>' -TestCases @(
            @{seed = 79; soil = 81}
            @{seed = 14; soil = 14}
            @{seed = 55; soil = 57}
            @{seed = 13; soil = 13}
            @{seed = 82; soil = 84}
        ){
            $rtnSoil = Mapping-Lookup $mapping."seed-to-soil" $seed
            $rtnSoil | Should -Be $soil
        }   
        
        It 'Soil <soil> should return Fertilizer <fertilizer>' -TestCases @(
            @{soil = 81; fertilizer = 81}
            @{soil = 14; fertilizer = 53}
            @{soil = 57; fertilizer = 57}
            @{soil = 13; fertilizer = 52}
        ){
            $rtnFert = Mapping-Lookup $mapping."soil-to-fertilizer" $soil
            $rtnFert | Should -Be $fertilizer
        }

        It 'Fertilizer <fertilizer> should return Water <water>' -TestCases @(
            @{fertilizer = 81; water = 81}
            @{fertilizer = 53; water = 49}
            @{fertilizer = 57; water = 53}
            @{fertilizer = 52; water = 41}
        ){
            $rtnWater = Mapping-Lookup $mapping."fertilizer-to-water" $fertilizer
            $rtnWater | Should -Be $water
        }

        It 'Water <water> should return Light <light>' -TestCases @(
            @{water = 81; light = 74}
            @{water = 49; light = 42}
            @{water = 53; light = 46}
            @{water = 41; light = 34}
        ){
            $rtnLight = Mapping-Lookup $mapping."water-to-light" $water
            $rtnLight | Should -Be $light
        }

        It 'Light <light> should return Temperature <temperature>' -TestCases @(
            @{light = 74; temperature = 78}
            @{light = 42; temperature = 42}
            @{light = 46; temperature = 82}
            @{light = 34; temperature = 34}
        ){
            $rtnTemp = Mapping-Lookup $mapping."light-to-temperature" $light
            $rtnTemp | Should -Be $temperature
        }

        It 'Temperature <temperature> should return Humidity <humidity>' -TestCases @(
            @{temperature = 78; humidity = 78}
            @{temperature = 42; humidity = 43}
            @{temperature = 82; humidity = 82}
            @{temperature = 34; humidity = 35}
        ){
            $rtnHum = Mapping-Lookup $mapping."temperature-to-humidity" $temperature
            $rtnHum | Should -Be $humidity
        }

        It 'Humidity <humidity> should return Location <location>' -TestCases @(
            @{humidity = 78; location = 82}
            @{humidity = 43; location = 43}
            @{humidity = 82; location = 86}
            @{humidity = 35; location = 35}
        ){
            $rtnLoc = Mapping-Lookup $mapping."humidity-to-location" $humidity
            $rtnLoc | Should -Be $location
        }
    }
}

Describe 'Get-Mapping-Range' {
    BeforeEach {
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
    }

    Context 'Gets all mapped values in of fertilizer 6 of range 20' {
        BeforeEach {
            $mapping = @{
                "fertilizer-to-water" = @{
                    0 = @(42, 7)
                    7 = @(57, 4)
                    11 = @(0, 42)
                    53 = @(49, 8)
                }}
            $map = $mapping."fertilizer-to-water"
            $fertilizer = 6
            $range = 20

            $waterVals = Get-Mapping-Range $map $fertilizer $range
        }
            
        It 'Should return 4 values' {
            #$waterVals[3].val | Should -Be "x"
            $waterVals.length | Should -Be 4
        }
        It '<return> should have been returned' -TestCases @(
            @{return = 48}
            @{return = 57}
            @{return = 0}
            @{return = 15}
        ){
            $found = $false
            foreach($val in $waterVals)
            {
                if($val.val -eq $return)
                {
                    $found = $true
                    break
                }
            }
            $found | Should -Be $true
        }
    }

    Context 'Gets all mapped values in of fertilizer 6 of range 0' {
        BeforeEach {
            $mapping = @{
                "fertilizer-to-water" = @{
                    0 = @(42, 7)
                    7 = @(57, 4)
                    11 = @(0, 42)
                    53 = @(49, 8)
                }}
            $map = $mapping."fertilizer-to-water"
            $fertilizer = 6
            $range = 0

            $waterVals = Get-Mapping-Range $map $fertilizer $range
        }
            
        It 'Should return 2 values' {
            $waterVals.length | Should -Be 2
        }
        It 'both should be 48' {
            $waterVals[0].val | Should -Be 48
            $waterVals[0].range | Should -Be 0
            $waterVals[1].val | Should -Be 48
            $waterVals[1].range | Should -Be 0
        }
    }
}

Describe 'Scenario Testing' {

    Context 'Gets all mapped values in of fertilizer 57 of range 13' {
        BeforeEach {
            $inputData = @(
                "seeds",
                "",
                "fertilizer-to-water map:",
                "49 53 8",
                "0 11 42",
                "42 0 7",
                "57 7 4"
            )

            $mapping = Compile-Input-Data $inputData
            $map = $mapping."fertilizer-to-water"
            $fertilizer = 57
            $range = 13

            $waterVals = Get-Mapping-Range $map $fertilizer $range
        }
        
        It 'fertilizer-to-water mapping has 5 mappings' {
            @($mapping."fertilizer-to-water".Keys).Length | Should -Be 5
        }
        It '<key> should map to <mapVal> with Range of <range>' -TestCases @(
            @{key = 0; mapVal = 42; expectedRange = 7}
            @{key = 7; mapVal = 57; expectedRange = 4}
            @{key = 11; mapVal = 0; expectedRange = 42}
            @{key = 53; mapVal = 49; expectedRange = 8}
            @{key = 61; mapVal = 61; expectedRange = 0}
        ){
            (($mapping."fertilizer-to-water")."$($key)")[0] | Should -Be $mapVal
            (($mapping."fertilizer-to-water")."$($key)")[1] | Should -Be $expectedRange
        }
            
        It 'Should return 3 values' {
            #$waterVals[1].val | Should -Be "x"
            $waterVals.length | Should -Be 3
        }
        It '<return> should have been returned' -TestCases @(
            @{return = 53}
            @{return = 61}
            @{return = 70}
        ){
            $found = $false
            foreach($val in $waterVals)
            {
                if($val.val -eq $return)
                {
                    $found = $true
                    break
                }
            }
            $found | Should -Be $true
        }
    }

    Context 'Test Data Answer' {
        BeforeEach {
            $global:outputBuffer = @{}
            $outputBuffer."screen" = @()
            $inputData = @(
                "seeds: 79 14 55 13",
                "",
                "seed-to-soil map:",
                "50 98 2",
                "52 50 48",
                "",
                "soil-to-fertilizer map:",
                "0 15 37",
                "37 52 2",
                "39 0 15",
                "",
                "fertilizer-to-water map:",
                "49 53 8",
                "0 11 42",
                "42 0 7",
                "57 7 4",
                "",
                "water-to-light map:",
                "88 18 7",
                "18 25 70",
                "",
                "light-to-temperature map:",
                "45 77 23",
                "81 45 19",
                "68 64 13",
                "",
                "temperature-to-humidity map:",
                "0 69 1",
                "1 0 69",
                "",
                "humidity-to-location map:",
                "60 56 37",
                "56 93 4"
            )
            $mapping = Compile-Input-Data $inputData
        }

        Context 'Error checking seed-to-soil' {
            It 'mapping seed-to-soil exists' {
                $mapping.Contains("seed-to-soil") | Should -Be $true
            }
            It 'seed-to-soil has 4 mappings' {
                @($mapping."seed-to-soil".Keys).Length | Should -Be 4
            }
            It 'seed-to-soil 50 mapping exists' {
                $mapping."seed-to-soil".Contains("50") | Should -Be $true
            }
            It 'seed-to-soil 50 mapping maps to 52' {
                $mapping."seed-to-soil"."50"[0] | Should -Be 52
            }
            It 'seed-to-soil 98 mapping maps to 50' {
                $mapping."seed-to-soil"."98"[0] | Should -Be 50
            }
            It 'seed-to-soil keys sort correctly. Position <pos> = Seed <seed>' -TestCases @(
                @{pos = 0; seed = 0}
                @{pos = 1; seed = 50}
                @{pos = 2; seed = 98}
                @{pos = 3; seed = 100}
            ){
                $keys = @($mapping."seed-to-soil").Keys | Sort-Object {String-To-Int $_}
                #$keys[$pos].GetType() | Should -Be "Int64"
                $keys[$pos] | Should -Be $seed
            }
            It 'Seed <seed> should return Soil <soil>' -TestCases @(
                @{seed = 50; soil = 52}
                @{seed = 49; soil = 49}
                @{seed = 51; soil = 53}
                @{seed = 52; soil = 54}
                @{seed = 98; soil = 50}
                @{seed = 99; soil = 51}
                @{seed = 79; soil = 81}
                @{seed = 83; soil = 85}
                @{seed = 93; soil = 95}
                @{seed = 55; soil = 57}
                @{seed = 68; soil = 70}
                @{seed = 100; soil = 100}
            ){
                $rtnSoil = Mapping-Lookup $mapping."seed-to-soil" $seed
                $rtnSoil | Should -Be $soil
            }
            It 'seed-to-soil range collected correctly. 79-14 should return 81-14 and 85-0'{
                $seed = 79
                $range = 14
                $ranges = @(Get-Mapping-Range ($mapping."seed-to-soil") $seed $range)
                
                $size = 2
                $rangMapping1 = @{
                    "val" = 81
                    "range" = 14
                }
                $rangMapping2 = @{
                    "val" = 95
                    "range" = 0
                }

                $ranges.Length | Should -Be $size
                $ranges[0].val | Should -Be $rangMapping1.val
                $ranges[0].range | Should -Be $rangMapping1.range
                $ranges[1].val | Should -Be $rangMapping2.val
                $ranges[1].range | Should -Be $rangMapping2.range
            }
            It 'seed-to-soil range collected correctly. 55-13 should return 57-13 and 70-0'{
                $seed = 55
                $range = 13
                $ranges = @(Get-Mapping-Range ($mapping."seed-to-soil") $seed $range)
                
                $size = 2
                $rangMapping1 = @{
                    "val" = 57
                    "range" = 13
                }
                $rangMapping2 = @{
                    "val" = 70
                    "range" = 0
                }

                $ranges.Length | Should -Be $size
                $ranges[0].val | Should -Be $rangMapping1.val
                $ranges[0].range | Should -Be $rangMapping1.range
                $ranges[1].val | Should -Be $rangMapping2.val
                $ranges[1].range | Should -Be $rangMapping2.range
            }
        }
        Context 'Error checking fertilizer-to-water' {
            It 'mapping fertilizer-to-water exists' {
                $mapping.Contains("fertilizer-to-water") | Should -Be $true
            }
            It 'fertilizer-to-water has 5 mappings' {
                @($mapping."fertilizer-to-water".Keys).Length | Should -Be 5
            }
            It 'fertilizer-to-water 53 mapping exists' {
                $mapping."fertilizer-to-water".Contains("53") | Should -Be $true
            }
            It 'fertilizer-to-water 53 mapping maps to 49' {
                $mapping."fertilizer-to-water"."53"[0] | Should -Be 49
            }
            It 'fertilizer-to-water 11 mapping maps to 0' {
                $mapping."fertilizer-to-water"."11"[0] | Should -Be 0
            }
            It 'fertilizer-to-water keys sort correctly. Position <pos> = Fertilizer <fertilizer>' -TestCases @(
                @{pos = 0; fertilizer = 0}
                @{pos = 1; fertilizer = 7}
                @{pos = 2; fertilizer = 11}
                @{pos = 3; fertilizer = 53}
                @{pos = 4; fertilizer = 61}
            ){
                $keys = @($mapping."fertilizer-to-water").Keys | Sort-Object {String-To-Int $_}
                #$keys[$pos].GetType() | Should -Be "Int64"
                $keys[$pos] | Should -Be $fertilizer
            }
            It 'Fertilizer <fertilizer> should return Water <water>' -TestCases @(
                @{fertilizer = 0; water = 42}
                @{fertilizer = 7; water = 57}
                @{fertilizer = 11; water = 0}
                @{fertilizer = 53; water = 49}
                @{fertilizer = 61; water = 61}

            ){
                $rtnWater = Mapping-Lookup $mapping."fertilizer-to-water" $fertilizer
                $rtnWater | Should -Be $water
            }
            It 'Fertilizer <fertilizer> of Range <range> should return Water <water> of Range <waterRange>' -TestCases @(
                @{fertilizer = 81; range = 14; water = 81; waterRange = 14}
                @{fertilizer = 81; range = 14; water = 95; waterRange = 0}
                @{fertilizer = 57; range = 13; water = 53; waterRange = 13}
                @{fertilizer = 57; range = 13; water = 53; waterRange = 13}
                @{fertilizer = 57; range = 13; water = 61; waterRange = 9}
                @{fertilizer = 57; range = 13; water = 70; waterRange = 0}

            ){
                $rangeCheck = @(Get-Mapping-Range ($mapping."fertilizer-to-water") $fertilizer $range)

                $found = -1
                for($i = 0; $i -lt $rangeCheck.Length; $i++)
                {
                    if($rangeCheck[$i].val -eq $water)
                    {
                        $found = $i
                        break
                    }
                }
                $found | Should -Not -Be -1
                $rangeCheck[$found].range | Should -Be $waterRange
            }
        }

        Context 'Error checking water-to-light' {
            It 'mapping water-to-light exists' {
                $mapping.Contains("water-to-light") | Should -Be $true
            }
            It 'water-to-light has 4 mappings' {
                @($mapping."water-to-light".Keys).Length | Should -Be 4
            }
            It 'water-to-light 25 mapping exists' {
                $mapping."water-to-light".Contains("25") | Should -Be $true
            }
            It 'water-to-light 25 mapping maps to 18' {
                $mapping."water-to-light"."25"[0] | Should -Be 18
            }
            It 'water-to-light 18 mapping maps to 88' {
                $mapping."water-to-light"."18"[0] | Should -Be 88
            }
            It 'water-to-light keys sort correctly. Position <pos> = Water <water>' -TestCases @(
                @{pos = 0; water = 0}
                @{pos = 1; water = 18}
                @{pos = 2; water = 25}
                @{pos = 3; water = 95}
            ){
                $keys = @($mapping."water-to-light").Keys | Sort-Object {String-To-Int $_}
                #$keys[$pos].GetType() | Should -Be "Int64"
                $keys[$pos] | Should -Be $water
            }
            It 'Water <water> should return Light <light>' -TestCases @(
                @{water = 18; light = 88}
                @{water = 25; light = 18}
                @{water = 0; light = 0}
                @{water = 17; light = 17}
                @{water = 94; light = 87}
                @{water = 95; light = 95}
                @{water = 57; light = 50}
                @{water = 70; light = 63}
                @{water = 81; light = 74}

            ){
                $rtnLight = Mapping-Lookup $mapping."water-to-light" $water
                $rtnLight | Should -Be $light
            }
        }

        Context 'Test Answer known Map Path' {
            It 'Seed 82 maps to Soil 84' {
                $val = 82
                $mappingGroup = "seed-to-soil"
                $mappedVal = Mapping-Lookup $mapping.$mappingGroup $val
                $mappedVal | Should -Be 84
            }
            It 'Seed 82 maps to Soil 84' {
                $val = 82
                $mappingGroup = "seed-to-soil"
                $mappedVal = Mapping-Lookup $mapping.$mappingGroup $val
                $mappedVal | Should -Be 84
            }
            It 'Soil 84 maps to Fertilizer 84' {
                $val = 84
                $mappingGroup = "soil-to-fertilizer"
                $mappedVal = Mapping-Lookup $mapping.$mappingGroup $val
                $mappedVal | Should -Be 84
            }
            It 'Fertilizer 84 maps to Water 84' {
                $val = 84
                $mappingGroup = "fertilizer-to-water"
                $mappedVal = Mapping-Lookup $mapping.$mappingGroup $val
                $mappedVal | Should -Be 84
            }
            It 'Water 84 maps to Light 77' {
                $val = 84
                $mappingGroup = "water-to-light"
                $mappedVal = Mapping-Lookup $mapping.$mappingGroup $val
                $mappedVal | Should -Be 77
            }
            It 'Light 77 maps to Temperature 45' {
                $val = 77
                $mappingGroup = "light-to-temperature"
                $mappedVal = Mapping-Lookup $mapping.$mappingGroup $val
                $mappedVal | Should -Be 45
            }
            It 'Temperature 45 maps to Humidity 46' {
                $val = 45
                $mappingGroup = "temperature-to-humidity"
                $mappedVal = Mapping-Lookup $mapping.$mappingGroup $val
                $mappedVal | Should -Be 46
            }
            It 'Humidity 46 maps to Location 46' {
                $val = 46
                $mappingGroup = "humidity-to-location"
                $mappedVal = Mapping-Lookup $mapping.$mappingGroup $val
                $mappedVal | Should -Be 46
            }
        }
    }
}