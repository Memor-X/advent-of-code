BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')

    $global:fileOutputBuffer = @{}

    Mock Write-Log {}
    Mock Add-Content {
        $file = (Out-String -InputObject $PesterBoundParameters.Path).Trim()
        if($fileOutputBuffer.ContainsKey($file) -eq $false)
        {
            $fileOutputBuffer.$file = @()
        }
        $fileOutputBuffer.$file += @($PesterBoundParameters.Value)
    }
    Mock Set-Content {
        $file = (Out-String -InputObject $PesterBoundParameters.Path).Trim()
        $fileOutputBuffer.$file = @($PesterBoundParameters.Value)
    }
}

Describe 'Run-Command' {
    BeforeEach{
        Mock Invoke-Expression {return $PesterBoundParameters.Command}
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
            }
            return $returnVal
        }
        $global:fileOutputBuffer = @{}
    }
    It 'Check that Log entry was made' {
        Run-Command "dir"
        $fileOutputBuffer['.\_log\commands_01-01-2000.txt'][0] | Should -Be "[11:10] | dir"
    }
    It 'Check that command output is returned' {
        $returnData = Run-Command "dir"
        $returnData | Should -Be "& dir"
    }
}

Describe 'Fetch-XMLVal' {
    BeforeEach{
        [XML]$testXML = '<?xml version="1.0" encoding="UTF-8" ?><test><test1>val1</test1><test2><child>val 2</child></test2><test3><child>child 1</child><child>child 2</child></test3><test4><child1>child named 1</child1><child>child named 2</child></test4><test5 testAttrib="valAttrib">valText</test5></test>'
    }
    It 'Return 1st Level value' {
        $testVal = Fetch-XMLVal $testXML "test.test1"
        $testVal | Should -Be "val1"
    }

    It 'return 2nd Level value' {
        $testVal = Fetch-XMLVal $testXML "test.test2.child"
        $testVal | Should -Be "val 2"
    }

    It 'return 2nd Level value from identical children' {
        $testVal = Fetch-XMLVal $testXML "test.test3.child"
        $testVal[1] | Should -Be "child 2"
    }

    It 'return 2nd Level value from same child name' {
        $testVal = Fetch-XMLVal $testXML "test.test4.child"
        $testVal | Should -Be "child named 2"
    }

    It 'return attribue' {
        $testVal = Fetch-XMLVal $testXML "test.test5"
        $testVal.testAttrib | Should -Be "valAttrib"
    }
}

Describe 'Bulk-Replace' {
    It 'Bulk Replace just 1 value' {
        $string = "[REPLACE1] World"
        $values = @{
            "[REPLACE1]" = "Hello"
        }
        $string = Bulk-Replace $string $values
        $string | Should -Be "Hello World"
    }

    It 'Bulk Replace with 2 values' {
        $string = "[REPLACE1] World [REPLACE2]"
        $values = @{
            "[REPLACE1]" = "Hello"
            "[REPLACE2]" = "Two"
        }
        $string = Bulk-Replace $string $values
        $string | Should -Be "Hello World Two"
    }

    It 'Bulk Replace with 2 identical values' {
        $string = "[REPLACE1] World [REPLACE1]"
        $values = @{
            "[REPLACE1]" = "Echo"
            "[REPLACE2]" = "Two"
        }
        $string = Bulk-Replace $string $values
        $string | Should -Be "Echo World Echo"
    }

    It 'Bulk Replace with 2 no values' {
        $string = "Hello World"
        $values = @{
            "[REPLACE1]" = "Echo"
            "[REPLACE2]" = "Two"
        }
        $string = Bulk-Replace $string $values
        $string | Should -Be "Hello World"
    }
}

Describe 'FirstIndexOfAnyStr'{
    It 'Find match from Array' {
        $string = "one two three four five sex seven eight nine ten eleven twelve thirteen fourteen"
        $values = @(
            "eight",
            "bob",
            "two",
            "twelve"
        )
        $index = FirstIndexOfAnyStr $string $values
        $index | Should -Be 2
    }

    It 'Find no match' {
        $string = "one twso three four five sex seven eighst nine ten eleven twelvse thirteen fourteen"
        $values = @(
            "eight",
            "bob",
            "two",
            "twelve"
        )
        $index = FirstIndexOfAnyStr $string $values
        $index | Should -Be -1
    }
}

Describe 'LastIndexOfAnyStr'{
    It 'Find match from Array' {
        $string = "one two three four five ten eleven twelve sex seven eight nine thirteen fourteen"
        $values = @(
            "eight",
            "bob",
            "two",
            "twelve"
        )
        $index = LastIndexOfAnyStr $string $values
        $index | Should -Be 0
    }

    It 'Find no match' {
        $string = "one twso three four five ten eleven twelvse sex seven eighst nine thirteen fourteen"
        $values = @(
            "eight",
            "bob",
            "two",
            "twelve"
        )
        $index = LastIndexOfAnyStr $string $values
        $index | Should -Be -1
    }
}

Describe 'Find-Bell' {
    It 'Returns Bell Character position' {
        $string = "test$([char]7)string"
        $index = Find-Bell $string
        $index | Should -Be 4
    }

    It 'Returns 1st Bell Character position' {
        $string = "test$([char]7)stri$([char]7)ng"
        $index = Find-Bell $string
        $index | Should -Be 4
    }

    It 'Returns -1 when no bell is found' {
        $string = "test string"
        $index = Find-Bell $string
        $index | Should -Be -1
    }

    It 'Returns 2nd Bell Character position when first is removed' {
        $string = "test$([char]7)stri$([char]7)ng"
        $string = $string.Remove(4,1)
        $index = Find-Bell $string
        $index | Should -Be 8
    }
}

Describe 'Repair-Trim' {
    It 'Does a regular Trim when no specialized characters' {
        $string = " Test "
        $testStr = Repair-Trim $string
        $testStr | Should -Be "Test"
        $testStr.Length | Should -be 4
    }

    Context "Special Characters" {
        It 'Trims <name> Character from String' -TestCases @(
            @{Name = "Bell"; Char = ([char]7)}
        ){
            $string = "$($char)Test$($char)"
            $testStr = Repair-Trim $string
            $testStr | Should -Be "Test"
            $testStr.Length | Should -be 4
        }

        It 'Trims <name> Character from String with touching instances in the String' -TestCases @(
            @{Name = "Bell"; Char = ([char]7)}
        ){
            $string = "$($char)Te$($char)st$($char)"
            $testStr = Repair-Trim $string
            $testStr | Should -Be "Te$($char)st"
            $testStr.Length | Should -be 5
        }

        It 'Trims <name> Character from String with Spaces' -TestCases @(
            @{Name = "Bell"; Char = ([char]7)}
        ){
            $string = "$($char) $($char)Test$($char) "
            $testStr = Repair-Trim $string
            $testStr | Should -Be "Test"
            $testStr.Length | Should -be 4
        }
    }
}

Describe 'Test-Function-Exists'{
    BeforeEach{
        Mock Write-Success {}
        Mock Write-Error {}
    }
    It 'Find Command that exists' {
        Test-Function-Exists "Should" $false
        Should -Invoke -CommandName Write-Success -Times 1
    }

    It 'Unable to find Command' {
        Test-Function-Exists "Shoulds" $false
        Should -Invoke -CommandName Write-Error -Times 1
    }
}

Describe 'Test-Function-Loop'{
    BeforeEach{
        Mock Write-Success {}
        Mock Write-Error {}
    }
    It 'Find All Command that exists' {
        $commands = @(
            "Should",
            "Describe",
            "It"
        )
        Test-Function-Loop $commands $false
        Should -Invoke -CommandName Write-Success -Times 3
    }

    It 'Unable to find 1 Command out of 3' {
        $commands = @(
            "Should",
            "Describes",
            "It"
        )
        Test-Function-Loop $commands $false
        Should -Invoke -CommandName Write-Success -Times 2
        Should -Invoke -CommandName Write-Error -Times 1
    }

    It 'Unable to any Commands' {
        $commands = @(
            "Shoulds",
            "Describes",
            "Its"
        )
        Test-Function-Loop $commands $false
        Should -Invoke -CommandName Write-Error -Times 3
    }
}

Describe 'Count-Array-Matches'{
    BeforeEach{
        $collection = @("Lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "Lorem", "adipiscing", "elit", "Aliquam", "metus", "Lorem", "nunc", "venenatis", "eu", "fermentum", "at")
    }
    It 'Find 1 match' {
        $toFind = @("sit")
        $matches = Count-Array-Matches $collection $toFind
        $matches | Should -Be 1
    }

    It 'Find 3 matches' {
        $toFind = @("sit", "dolor", "nunc")
        $matches = Count-Array-Matches $collection $toFind
        $matches | Should -Be 3
    }

    It 'Find 0 matches' {
        $toFind = @("hello", "world")
        $matches = Count-Array-Matches $collection $toFind
        $matches | Should -Be 0
    }

    It 'Find 1 match in to find array while match is duplicated in collection array' {
        $toFind = @("Lorem")
        $matches = Count-Array-Matches $collection $toFind
        $matches | Should -Be 1
    }
}

Describe 'Initalize-Array'{
    It 'New Array with no paramaters passed defaulting to 1 null value' {
        $newArray = @(Initalize-Array)
        $newArray.Length | Should -Be 1
        $newArray[0] | Should -Be $null
    }

    It 'New 1-size array' {
        $newArray = @(Initalize-Array 1)
        $newArray.Length | Should -Be 1
    }

    It 'New 2-size array' {
        $newArray = Initalize-Array 2
        $newArray.Length | Should -Be 2
    }

    It 'New 2-size array with hello as default' {
        $newArray = Initalize-Array 2 @("hello")
        $newArray.Length | Should -Be 2
        $newArray[0] | Should -Be "hello"
        $newArray[1] | Should -Be "hello"
    }

    It 'New 10-size array with hello as default' {
        $newArray = Initalize-Array 10 @("hello")
        $newArray.Length | Should -Be 10
        $newArray[0] | Should -Be "hello"
        $newArray[1] | Should -Be "hello"
        $newArray[8] | Should -Be "hello"
        $newArray[9] | Should -Be "hello"
    }

    It 'New 2-size array with defaults "hello" and "world"' {
        $newArray = Initalize-Array 2 @("hello", "world")
        $newArray.Length | Should -Be 2
        $newArray[0] | Should -Be "hello"
        $newArray[1] | Should -Be "world"
    }

    It 'New 10-size array with uneven default array' {
        $newArray = Initalize-Array 10 @("hello","all","worlds")
        $newArray.Length | Should -Be 10
        $newArray[0] | Should -Be "hello"
        $newArray[1] | Should -Be "all"
        $newArray[2] | Should -Be "worlds"
        $newArray[6] | Should -Be "hello"
        $newArray[7] | Should -Be "all"
        $newArray[8] | Should -Be "worlds"
        $newArray[9] | Should -Be "hello"
    }
}

Describe 'Create-Path'{
    BeforeEach{
        Mock New-Item {}
        Mock Split-Path {
            $split = $PesterBoundParameters.Path -Split "/"

            return $split[0..($split.Length-1)] -Join "/"
        }
    }
    It 'New Directory would be created' {
        Create-Path "c:\test\path"
        Should -Invoke -CommandName New-Item -Times 1
    }

    It 'New Directory would be created from file path' {
        Create-Path "c:\test\path\tesfile.txt"
        Should -Invoke -CommandName Split-Path -Times 1
        Should -Invoke -CommandName New-Item -Times 1
    }
}

Describe 'Group-Replace'{
    It 'Change String with Find Array of size 1' {
        $string = "Hello World"
        $findArr = @("Hell")
        $replaceStr = "DING"
        $string = (Group-Replace $string $findArr $replaceStr )
        $string  | Should -Be "DINGo World"
    }

    It 'Change String with Find Array of size 3 with 1 value match' {
        $string = "Hello World"
        $findArr = @("Hell", "Heav", "lol")
        $replaceStr = "DING"
        $string = (Group-Replace $string $findArr $replaceStr )
        $string  | Should -Be "DINGo World"
    }

    It 'String remains the same when theres no match' {
        $string = "Hecko World"
        $findArr = @("Hell")
        $replaceStr = "DING"
        $string = (Group-Replace $string $findArr $replaceStr )
        $string  | Should -Be "Hecko World"
    }

    It 'Change String with Find Array of size 1 with 1 value matched multiple times' {
        $string = "Hello Hell World"
        $findArr = @("Hell")
        $replaceStr = "DING"
        $string = (Group-Replace $string $findArr $replaceStr )
        $string  | Should -Be "DINGo DING World"
    }

    It 'Change String with Find Array of size 3 with 2 single matches' {
        $string = "Hello Heavy World"
        $findArr = @("Hell", "Heav", "lol")
        $replaceStr = "DING"
        $string = (Group-Replace $string $findArr $replaceStr )
        $string  | Should -Be "DINGo DINGy World"
    }

    It 'Change String with Find Array of size 3 with 1 single match and 1 multiple times' {
        $string = "Hello Heavy Hell World"
        $findArr = @("Hell", "Heav", "lol")
        $replaceStr = "DING"
        $string = (Group-Replace $string $findArr $replaceStr)
        $string | Should -Be "DINGo DINGy DING World"
    }
}


Describe 'Get-Version'{
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
    }

    It 'should split into major, minor and bug numbers' {
        $versionStr = "1.2.3"
        $version = Get-Version $versionStr
        $version."major" | Should -Be 1
        $version."minor" | Should -Be 2
        $version."bug" | Should -Be 3
    }

    It 'should split into major, minor and bug numbers with - as delimiter' {
        $versionStr = "1-2-3"
        $delimiter = "-"
        $version = Get-Version $versionStr $delimiter
        $version."major" | Should -Be 1
        $version."minor" | Should -Be 2
        $version."bug" | Should -Be 3
    }

}

Describe 'Append-File'{
    BeforeEach{
        Mock Create-Path {}
        $global:fileOutputBuffer = @{}
    }

    It 'Create File and insert 1 line' {
        Append-File "c:\test\path\tesfile.txt" "Test"
        $fileOutputBuffer['c:\test\path\tesfile.txt'][0] | Should -Be "Test"
    }

    It 'Create File and insert 3 lines using new line characters' {
        Append-File "c:\test\path\tesfile.txt" "Test"
        $fileOutputBuffer['c:\test\path\tesfile.txt'][0] | Should -Be "Test"
    }

    It 'Create File and insert 3 line' {
        Append-File "c:\test\path\tesfile.txt" "Test Line 1"
        Append-File "c:\test\path\tesfile.txt" "Test Line 2"
        Append-File "c:\test\path\tesfile.txt" "Test Line 3"
        $fileOutputBuffer['c:\test\path\tesfile.txt'][0] | Should -Be "Test Line 1"
        $fileOutputBuffer['c:\test\path\tesfile.txt'][1] | Should -Be "Test Line 2"
        $fileOutputBuffer['c:\test\path\tesfile.txt'][2] | Should -Be "Test Line 3"
    }
}

Describe 'Write-File'{
    BeforeEach{
        Mock Create-Path {}
        $global:fileOutputBuffer = @{}
    }

    It 'Create File and insert 1 line' {
        Write-File "c:\test\path\tesfile.txt" "Test"
        $fileOutputBuffer['c:\test\path\tesfile.txt'][0] | Should -Be "Test"
    }

    It 'Create File with only 1 line' {
        Write-File "c:\test\path\tesfile.txt" "Test Line 1"
        Write-File "c:\test\path\tesfile.txt" "Test Line 2"
        Write-File "c:\test\path\tesfile.txt" "Test Line 3"
        $fileOutputBuffer['c:\test\path\tesfile.txt'][0] | Should -Be "Test Line 3"
    }
}