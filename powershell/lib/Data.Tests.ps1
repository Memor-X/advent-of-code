BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'Is-Digit' {
    It 'Return true if it is a digit' {
        $char = "6"
        Is-Digit $char | Should -Be $true
    }

    It 'Return false if it isnt a digit' {
        $char = "x"
        Is-Digit $char | Should -Be $false
    }

    It 'Return false if string is greater than 1' {
        $char = "69"
        Is-Digit $char | Should -Be $false
    }

    Context "Other Datatypes" {
        It 'Return false on Boolean' {
            $char = $true
            Is-Digit $char | Should -Be $false
        }

        It 'Return false on Integer' {
            $char = 4
            Is-Digit $char | Should -Be $false
        }

        It 'Return false on float' {
            $char = 6.5
            Is-Digit $char | Should -Be $false
        }

        It 'Return false on array' {
            $char = @("4")
            Is-Digit $char | Should -Be $false
        }

        It 'Return false on hash' {
            $char = @{"key" = "4"}
            Is-Digit $char | Should -Be $false
        }
    }
}

Describe 'Hash-To-Array' {
    It 'Convert Hash of size 1' {
        $hash = @{"key1" = "val1"}
        $array = @(Hash-To-Array $hash)
        $array[0] | Should -Be "key1 = val1"
    }

    It 'Convert Hash of size 3' {
        $hash = @{
            "key1" = "val1"
            "key2" = "val2"
            "key3" = "val3"
        }
        $array = Hash-To-Array $hash
        $array[0] | Should -Be "key1 = val1"
        $array[1] | Should -Be "key2 = val2"
        $array[2] | Should -Be "key3 = val3"
    }

    Context "Other Datatypes" {
        Context "Hash with Int" {
            It 'Convert Hash with Int Key' {
                $hash = @{652 = "val1"}
                $array = @(Hash-To-Array $hash)
                $array[0] | Should -Be "652 = val1"
            }

            It 'Convert Hash with Int val' {
                $hash = @{"key1" = 567}
                $array = @(Hash-To-Array $hash)
                $array[0] | Should -Be "key1 = 567"
            }

            It 'Convert Hash with Int key and val' {
                $hash = @{87 = 567}
                $array = @(Hash-To-Array $hash)
                $array[0] | Should -Be "87 = 567"
            }
        }

        Context "Hash with Boolean" {
            It 'Convert Hash with Boolean Key' {
                $hash = @{$true = "val1"}
                $array = @(Hash-To-Array $hash)
                $array[0] | Should -Be "true = val1"
            }

            It 'Convert Hash with Boolean val' {
                $hash = @{"key1" = $true}
                $array = @(Hash-To-Array $hash)
                $array[0] | Should -Be "key1 = true"
            }

            It 'Convert Hash with Boolean key and val' {
                $hash = @{$true = $false}
                $array = @(Hash-To-Array $hash)
                $array[0] | Should -Be "true = false"
            }
        }
    }
}

Describe 'String-To-Int' {
    It 'Convert single character digit to Long Int (Int64)' {
        $val = "1"
        $test = String-To-Int $val
        $test.GetType() | Should -Be "long"
        $test | Should -Be 1
    }
    
    It 'Convert integer string to Long Int (Int64)' {
        $val = "564654"
        $test = String-To-Int $val
        $test.GetType() | Should -Be "long"
        $test | Should -Be 564654
    }

    It 'Fail to convert character' {
        $ErrorActionPreference = 'SilentlyContinue'
        $val = "g"
        {String-To-Int $val }| Should -Throw
        $ErrorActionPreference = 'Continue'
    }
    Context "Other Datatypes" {
        It 'Fail to convert string' {
            $ErrorActionPreference = 'SilentlyContinue'
            $val = "gkjshk"
            {String-To-Int $val } | Should -Throw
            $ErrorActionPreference = 'Continue'
        }

        It 'Fail to convert partial string' {
            $ErrorActionPreference = 'SilentlyContinue'
            $val = "gk564jshk"
            {String-To-Int $val } | Should -Throw
            $ErrorActionPreference = 'Continue'
        }

        It 'convert Integer to Long Int (Int64)' {
            $val = 798789
            $test = String-To-Int $val
            $test.GetType() | Should -Be "long"
            $test | Should -Be 798789
        }

        It 'Fail to convert $false' {
            $ErrorActionPreference = 'SilentlyContinue'
            $val = $false
            {String-To-Int $val } | Should -Throw
            $ErrorActionPreference = 'Continue'
        }

        It 'Fail to convert $true' {
            $ErrorActionPreference = 'SilentlyContinue'
            $val = $true
            {String-To-Int $val } | Should -Throw
            $ErrorActionPreference = 'Continue'
        }

        It 'Fail to convert Float' {
            $ErrorActionPreference = 'SilentlyContinue'
            $val = 51.23
            {String-To-Int $val } | Should -Throw
            $ErrorActionPreference = 'Continue'
        }

        It 'Fail to convert Float String' {
            $ErrorActionPreference = 'SilentlyContinue'
            $val = "51.23"
            {String-To-Int $val } | Should -Throw
            $ErrorActionPreference = 'Continue'
        }
    }
}

Describe 'JsonObj-To-Hash' {
    It 'Convert Object with 1 property' {
        $val = ConvertFrom-Json -InputObject '{"prop 1": "val 1"}'
        $test = JsonObj-To-Hash $val
        $test["prop 1"] | Should -Be "val 1"
    }

    It 'Convert Object with 3 property' {
        $val = ConvertFrom-Json -InputObject '{"prop 1": "val 1","prop 2": "val 2","prop 3": "val 3",}'
        $test = JsonObj-To-Hash $val
        $test["prop 1"] | Should -Be "val 1"
        $test["prop 2"] | Should -Be "val 2"
        $test["prop 3"] | Should -Be "val 3"
    }

    Context "Other Datatypes" {
        It 'Convert Object with Int val' {
            $val = ConvertFrom-Json -InputObject '{"prop 1": 1}'
            $test = JsonObj-To-Hash $val
            $test["prop 1"] | Should -Be 1
        }

        It 'Convert Object with Boolean val' {
            $val = ConvertFrom-Json -InputObject '{"prop 1": true}'
            $test = JsonObj-To-Hash $val
            $test["prop 1"] | Should -Be $true
        }

        It 'Convert Object with Float val' {
            $val = ConvertFrom-Json -InputObject '{"prop 1": 1.23}'
            $test = JsonObj-To-Hash $val
            $test["prop 1"] | Should -Be 1.23
        }
    }
}

Describe 'NameValueCollection-To-Array' {
    It 'Convert NameValueCollection of size 1' {
        $col = New-Object -TypeName "System.Collections.Specialized.NameValueCollection";
        $col.Add("key1", "val1");
        $array = @(NameValueCollection-To-Array $col)
        $array[0] | Should -Be "key1 = val1"
    }

    It 'Convert NameValueCollection of size 3' {
        $col = New-Object -TypeName "System.Collections.Specialized.NameValueCollection";
        $col.Add("key1", "val1");
        $col.Add("key2", "val2");
        $col.Add("key3", "val3");
        $array = @(NameValueCollection-To-Array $col)
        $array[0] | Should -Be "key1 = val1"
        $array[1] | Should -Be "key2 = val2"
        $array[2] | Should -Be "key3 = val3"
    }

    Context "Other Datatypes" {
        It 'Convert NameValueCollection of with form array' {
            $col = New-Object -TypeName "System.Collections.Specialized.NameValueCollection";
            $col.Add("key[]", "val1");
            $col.Add("key[]", "val2");
            $array = @(NameValueCollection-To-Array $col)
            $array[0] | Should -Be "key[] = val1"
            $array[1] | Should -Be "key[] = val2"
        }
    
        It 'Convert NameValueCollection of with array val' {
            $col = New-Object -TypeName "System.Collections.Specialized.NameValueCollection";
            $col.Add("key", @("val1","val2"));
            $array = @(NameValueCollection-To-Array $col)
            $array[0] | Should -Be "key = val1 val2"
        }
        
        Context "NameValueCollection with Int" {
            It 'Convert NameValueCollection with Int Key' {
                $col = New-Object -TypeName "System.Collections.Specialized.NameValueCollection";
                $col.Add(652, "val1");
                $array = @(NameValueCollection-To-Array $col)
                $array[0] | Should -Be "652 = val1"
            }

            It 'Convert NameValueCollection with Int val' {
                $col = New-Object -TypeName "System.Collections.Specialized.NameValueCollection";
                $col.Add("key1", 567);
                $array = @(NameValueCollection-To-Array $col)
                $array[0] | Should -Be "key1 = 567"
            }

            It 'Convert NameValueCollection with Int key and val' {
                $col = New-Object -TypeName "System.Collections.Specialized.NameValueCollection";
                $col.Add(87, 567);
                $array = @(NameValueCollection-To-Array $col)
                $array[0] | Should -Be "87 = 567"
            }
        }

        Context "Hash with Boolean" {
            It 'Convert NameValueCollection with Boolean Key' {
                $col = New-Object -TypeName "System.Collections.Specialized.NameValueCollection";
                $col.Add($true, "val1");
                $array = @(NameValueCollection-To-Array $col)
                $array[0] | Should -Be "true = val1"
            }

            It 'Convert NameValueCollection with Boolean val' {
                $col = New-Object -TypeName "System.Collections.Specialized.NameValueCollection";
                $col.Add("key1", $true);
                $array = @(NameValueCollection-To-Array $col)
                $array[0] | Should -Be "key1 = true"
            }

            It 'Convert NameValueCollection with Boolean key and val' {
                $col = New-Object -TypeName "System.Collections.Specialized.NameValueCollection";
                $col.Add($true, $false);
                $array = @(NameValueCollection-To-Array $col)
                $array[0] | Should -Be "true = false"
            }
        }
    }
}


Describe 'String-to-TimeSpan' {
    Context "Splitting String correctly" {
        It 'Time String as SS' {
            $timespan = String-to-TimeSpan "54"
            $timespan.Seconds | Should -Be 54
        }

        It 'Time String as MM:SS' {
            $timespan = String-to-TimeSpan "15:24"
            $timespan.Seconds | Should -Be 24
            $timespan.Minutes | Should -Be 15
        }

        It 'Time String as HH:MM:SS' {
            $timespan = String-to-TimeSpan "1:12:35"
            $timespan.Seconds | Should -Be 35
            $timespan.Minutes | Should -Be 12
            $timespan.Hours | Should -Be 1
        }

        It 'Time String as DD:HH:MM:SS' {
            $timespan = String-to-TimeSpan "1:03:54:21"
            $timespan.Seconds | Should -Be 21
            $timespan.Minutes | Should -Be 54
            $timespan.Hours | Should -Be 03
            $timespan.Days | Should -Be 1
        }
    }

    Context "Leading 0 Values" {
        It '0 Minutes in MM:SS' {
            $timespan = String-to-TimeSpan "0:01"
            $timespan.Seconds | Should -Be 1
        }
        It '00 Minutes in MM:SS' {
            $timespan = String-to-TimeSpan "00:02"
            $timespan.Seconds | Should -Be 2
        }

        It '0 Hours in HH:MM:SS' {
            $timespan = String-to-TimeSpan "0:01:02"
            $timespan.Seconds | Should -Be 2
            $timespan.Minutes | Should -Be 1
        }
        It '00 Hours in HH:MM:SS' {
            $timespan = String-to-TimeSpan "00:03:04"
            $timespan.Seconds | Should -Be 4
            $timespan.Minutes | Should -Be 3
        }

        It '0 Days in DD:HH:MM:SS' {
            $timespan = String-to-TimeSpan "0:01:02:03"
            $timespan.Seconds | Should -Be 3
            $timespan.Minutes | Should -Be 2
            $timespan.Hours | Should -Be 1
        }
        It '00 Days in DD:HH:MM:SS' {
            $timespan = String-to-TimeSpan "00:04:05:06"
            $timespan.Seconds | Should -Be 6
            $timespan.Minutes | Should -Be 5
            $timespan.Hours | Should -Be 4
        }
        It '000 Days in DD:HH:MM:SS' {
            $timespan = String-to-TimeSpan "000:07:08:09"
            $timespan.Seconds | Should -Be 9
            $timespan.Minutes | Should -Be 8
            $timespan.Hours | Should -Be 7
        }
    }

    Context "Overflowing Values" {
        It 'Seconds Overflow into Minutes' {
            $timespan = String-to-TimeSpan "91"
            $timespan.Seconds | Should -Be 31
            $timespan.Minutes | Should -Be 1
        }

        It 'Minutes Overflow into Hours' {
            $timespan = String-to-TimeSpan "75:10"
            $timespan.Seconds | Should -Be 10
            $timespan.Minutes | Should -Be 15
            $timespan.Hours | Should -Be 1
        }

        It 'Hours Overflow into Days' {
            $timespan = String-to-TimeSpan "28:10:20"
            $timespan.Seconds | Should -Be 20
            $timespan.Minutes | Should -Be 10
            $timespan.Hours | Should -Be 4
            $timespan.Days | Should -Be 1
        }

        It 'Seconds Overflow into Minutes, Hours and Days' {
            $timespan = String-to-TimeSpan "4:01:91510"
            $timespan.Seconds | Should -Be 10
            $timespan.Minutes | Should -Be 26
            $timespan.Hours | Should -Be 5
            $timespan.Days | Should -Be 1
        }
    }
}

Describe 'Timestamp-to-DateTime' {
    It 'Converts Unix Timestamp Integer to 06/05/2024 @ 9:10:20am' {
        $unixTimestamp = 1714986620
        $dateObj = Timestamp-to-DateTime $unixTimestamp
        $dateObj.Year | Should -Be 2024
        $dateObj.Month | Should -Be 5
        $dateObj.Day | Should -Be 6
        $dateObj.Hour | Should -Be 9
        $dateObj.Minute | Should -Be 10
        $dateObj.Second | Should -Be 20
    }
    It 'Converts Unix Timestamp String to 06/05/2024 @ 9:10:20am' {
        $unixTimestamp = "1714986620"
        $dateObj = Timestamp-to-DateTime $unixTimestamp
        $dateObj.Year | Should -Be 2024
        $dateObj.Month | Should -Be 5
        $dateObj.Day | Should -Be 6
        $dateObj.Hour | Should -Be 9
        $dateObj.Minute | Should -Be 10
        $dateObj.Second | Should -Be 20
    }
}