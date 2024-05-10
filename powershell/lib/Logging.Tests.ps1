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

Describe 'Write-Log' {
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
        $logSetting."showLog" = $true
        $logSetting."fileOutput" = $false
        $logSetting."filename" = "test_log.txt"

        Mock New-Item {}
    }

    It 'No log output when log setting is turned off' {
        $logSetting."showLog" = $false
        Write-Log "Hello World"
        $outputBuffer."screen".Length | Should -Be 0
    }

    It 'Will make new log folder if path is missing' {
        Mock Test-Path {
            return $false
        }
        $logSetting."fileOutput" = $true
        Write-Log "Hello World"
        Should -Invoke -CommandName New-Item -Times 1
    }

    Context "Default Paramaters" {
        It 'Plain Log Message' {
            Write-Log "Hello World"
            $outputBuffer."screen"[0].msg | Should -Be "[LOG] 01/01/2000 11:10 | Hello World"
            $outputBuffer."screen"[0].color | Should -Be "DarkGray"
        }

        It 'Plain Log Message Array' {
            Write-Log @("Hello", "World")
            $outputBuffer."screen"[0].msg | Should -Be "[LOG] 01/01/2000 11:10 | Hello"
            $outputBuffer."screen"[0].color | Should -Be "DarkGray"
            $outputBuffer."screen"[1].msg | Should -Be "[LOG] 01/01/2000 11:10 | World"
            $outputBuffer."screen"[1].color | Should -Be "DarkGray"
        }
    }

    Context "Indent Paramater" {
        It 'Message with 1 indent' {
            Write-Log "Hello World" 1
            $outputBuffer."screen"[0].msg | Should -Be "[LOG] 01/01/2000 11:10 | `tHello World"
            $outputBuffer."screen"[0].color | Should -Be "DarkGray"
        }

        It 'Message Array with 1 indent' {
            Write-Log @("Hello", "World") 1
            $outputBuffer."screen"[0].msg | Should -Be "[LOG] 01/01/2000 11:10 | `tHello"
            $outputBuffer."screen"[0].color | Should -Be "DarkGray"
            $outputBuffer."screen"[1].msg | Should -Be "[LOG] 01/01/2000 11:10 | `tWorld"
            $outputBuffer."screen"[1].color | Should -Be "DarkGray"
        }

        It 'Message with 3 indent' {
            Write-Log "Hello World" 3
            $outputBuffer."screen"[0].msg | Should -Be "[LOG] 01/01/2000 11:10 | `t`t`tHello World"
            $outputBuffer."screen"[0].color | Should -Be "DarkGray"
        }

        It 'Message Array with 3 indent' {
            Write-Log @("Hello", "World") 3
            $outputBuffer."screen"[0].msg | Should -Be "[LOG] 01/01/2000 11:10 | `t`t`tHello"
            $outputBuffer."screen"[0].color | Should -Be "DarkGray"
            $outputBuffer."screen"[1].msg | Should -Be "[LOG] 01/01/2000 11:10 | `t`t`tWorld"
            $outputBuffer."screen"[1].color | Should -Be "DarkGray"
        }
    }
    

    Context "Change Color" {
        It 'Blue Log Message' {
            Write-Log "Hello World" -color "Blue"
            $outputBuffer."screen"[0].msg | Should -Be "[LOG] 01/01/2000 11:10 | Hello World"
            $outputBuffer."screen"[0].color | Should -Be "Blue"
        }

        It 'Blue Log Message Array' {
            Write-Log @("Hello", "World") -color "Blue"
            $outputBuffer."screen"[0].msg | Should -Be "[LOG] 01/01/2000 11:10 | Hello"
            $outputBuffer."screen"[0].color | Should -Be "Blue"
            $outputBuffer."screen"[1].msg | Should -Be "[LOG] 01/01/2000 11:10 | World"
            $outputBuffer."screen"[1].color | Should -Be "Blue"
        }
    }

    Context "Changed Key" {
        It '[TEST] Log Message' {
            Write-Log "Hello World" -key "TEST"
            $outputBuffer."screen"[0].msg | Should -Be "[TEST] 01/01/2000 11:10 | Hello World"
            $outputBuffer."screen"[0].color | Should -Be "DarkGray"
        }

        It '[TEST] Blue Log Message Array' {
            Write-Log @("Hello", "World") -key "TEST"
            $outputBuffer."screen"[0].msg | Should -Be "[TEST] 01/01/2000 11:10 | Hello"
            $outputBuffer."screen"[0].color | Should -Be "DarkGray"
            $outputBuffer."screen"[1].msg | Should -Be "[TEST] 01/01/2000 11:10 | World"
            $outputBuffer."screen"[1].color | Should -Be "DarkGray"
        }
    }

    Context "File Output" {    
        It 'Plain Log Message' {
            $logSetting."fileOutput" = $true
            Write-Log "Hello World"
            $outputBuffer.".\_log\test_log.txt"[0] | Should -Be "[LOG] 01/01/2000 11:10 | Hello World"
        }

        It 'Plain Log Message Array' {
            $logSetting."fileOutput" = $true
            Write-Log @("Hello", "World")
            $outputBuffer.".\_log\test_log.txt"[0] | Should -Be "[LOG] 01/01/2000 11:10 | Hello"
            $outputBuffer.".\_log\test_log.txt"[1] | Should -Be "[LOG] 01/01/2000 11:10 | World"
        }
    }

}

Describe 'Write-Warning' {
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
        $logSetting."showLog" = $true
        $logSetting."showWarning" = $true
        $logSetting."fileOutput" = $false
        $logSetting."filename" = "test_log.txt"
    }

    Context 'show Settings' {
        It 'No Warning output when log setting is turned off' {
            $logSetting."showLog" = $false
            Write-Warning "Warning World"
            $outputBuffer."screen".Length | Should -Be 0
        }

        It 'No Warning output when log setting is turned off' {
            $logSetting."showWarning" = $false
            Write-Warning "Warning World"
            $outputBuffer."screen".Length | Should -Be 0
        }
    }

    Context "Default Paramaters" {
        It 'Plain Warning Message' {
            Write-Warning "Warning World"
            $outputBuffer."screen"[0].msg | Should -Be "[WARNING] 01/01/2000 11:10 | Warning World"
            $outputBuffer."screen"[0].color | Should -Be "Yellow"
        }

        It 'Plain Warning Message Array' {
            Write-Warning @("Warning", "World")
            $outputBuffer."screen"[0].msg | Should -Be "[WARNING] 01/01/2000 11:10 | Warning"
            $outputBuffer."screen"[0].color | Should -Be "Yellow"
            $outputBuffer."screen"[1].msg | Should -Be "[WARNING] 01/01/2000 11:10 | World"
            $outputBuffer."screen"[1].color | Should -Be "Yellow"
        }
    }

    Context "Indent Paramater" {
        It 'Warning Message with 1 indent' {
            Write-Warning "Warning World" 1
            $outputBuffer."screen"[0].msg | Should -Be "[WARNING] 01/01/2000 11:10 | `tWarning World"
            $outputBuffer."screen"[0].color | Should -Be "Yellow"
        }

        It 'Warning Message Array with 1 indent' {
            Write-Warning @("Warning", "World") 1
            $outputBuffer."screen"[0].msg | Should -Be "[WARNING] 01/01/2000 11:10 | `tWarning"
            $outputBuffer."screen"[0].color | Should -Be "Yellow"
            $outputBuffer."screen"[1].msg | Should -Be "[WARNING] 01/01/2000 11:10 | `tWorld"
            $outputBuffer."screen"[1].color | Should -Be "Yellow"
        }

        It 'Warning Message with 3 indent' {
            Write-Warning "Warning World" 3
            $outputBuffer."screen"[0].msg | Should -Be "[WARNING] 01/01/2000 11:10 | `t`t`tWarning World"
            $outputBuffer."screen"[0].color | Should -Be "Yellow"
        }

        It 'Warning Message Array with 3 indent' {
            Write-Warning @("Warning", "World") 3
            $outputBuffer."screen"[0].msg | Should -Be "[WARNING] 01/01/2000 11:10 | `t`t`tWarning"
            $outputBuffer."screen"[0].color | Should -Be "Yellow"
            $outputBuffer."screen"[1].msg | Should -Be "[WARNING] 01/01/2000 11:10 | `t`t`tWorld"
            $outputBuffer."screen"[1].color | Should -Be "Yellow"
        }
    }
}

Describe 'Write-Error' {
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
        $logSetting."showLog" = $true
        $logSetting."showError" = $true
        $logSetting."fileOutput" = $false
        $logSetting."filename" = "test_log.txt"
    }

    Context 'show Settings' {
        It 'No Error output when log setting is turned off' {
            $logSetting."showLog" = $false
            Write-Error "Error World"
            $outputBuffer."screen".Length | Should -Be 0
        }

        It 'No Error output when log setting is turned off' {
            $logSetting."showError" = $false
            Write-Error "Error World"
            $outputBuffer."screen".Length | Should -Be 0
        }
    }

    Context "Default Paramaters" {
        It 'Plain Error Message' {
            Write-Error "Error World"
            $outputBuffer."screen"[0].msg | Should -Be "[ERROR] 01/01/2000 11:10 | Error World"
            $outputBuffer."screen"[0].color | Should -Be "Red"
        }

        It 'Plain Error Message Array' {
            Write-Error @("Error", "World")
            $outputBuffer."screen"[0].msg | Should -Be "[ERROR] 01/01/2000 11:10 | Error"
            $outputBuffer."screen"[0].color | Should -Be "Red"
            $outputBuffer."screen"[1].msg | Should -Be "[ERROR] 01/01/2000 11:10 | World"
            $outputBuffer."screen"[1].color | Should -Be "Red"
        }
    }

    Context "Indent Paramater" {
        It 'Error Message with 1 indent' {
            Write-Error "Error World" 1
            $outputBuffer."screen"[0].msg | Should -Be "[ERROR] 01/01/2000 11:10 | `tError World"
            $outputBuffer."screen"[0].color | Should -Be "Red"
        }

        It 'Error Message Array with 1 indent' {
            Write-Error @("Error", "World") 1
            $outputBuffer."screen"[0].msg | Should -Be "[ERROR] 01/01/2000 11:10 | `tError"
            $outputBuffer."screen"[0].color | Should -Be "Red"
            $outputBuffer."screen"[1].msg | Should -Be "[ERROR] 01/01/2000 11:10 | `tWorld"
            $outputBuffer."screen"[1].color | Should -Be "Red"
        }

        It 'Error Message with 3 indent' {
            Write-Error "Error World" 3
            $outputBuffer."screen"[0].msg | Should -Be "[ERROR] 01/01/2000 11:10 | `t`t`tError World"
            $outputBuffer."screen"[0].color | Should -Be "Red"
        }

        It 'Error Message Array with 3 indent' {
            Write-Error @("Error", "World") 3
            $outputBuffer."screen"[0].msg | Should -Be "[ERROR] 01/01/2000 11:10 | `t`t`tError"
            $outputBuffer."screen"[0].color | Should -Be "Red"
            $outputBuffer."screen"[1].msg | Should -Be "[ERROR] 01/01/2000 11:10 | `t`t`tWorld"
            $outputBuffer."screen"[1].color | Should -Be "Red"
        }
    }
}

Describe 'Write-Success' {
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
        $logSetting."showLog" = $true
        $logSetting."fileOutput" = $false
        $logSetting."filename" = "test_log.txt"
    }

    Context 'show Settings' {
        It 'No Success output when log setting is turned off' {
            $logSetting."showLog" = $false
            Write-Success "Success World"
            $outputBuffer."screen".Length | Should -Be 0
        }
    }

    Context "Default Paramaters" {
        It 'Plain Success Message' {
            Write-Success "Success World"
            $outputBuffer."screen"[0].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | Success World"
            $outputBuffer."screen"[0].color | Should -Be "Green"
        }

        It 'Plain Success Message Array' {
            Write-Success @("Success", "World")
            $outputBuffer."screen"[0].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | Success"
            $outputBuffer."screen"[0].color | Should -Be "Green"
            $outputBuffer."screen"[1].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | World"
            $outputBuffer."screen"[1].color | Should -Be "Green"
        }
    }

    Context "Indent Paramater" {
        It 'Success Message with 1 indent' {
            Write-Success "Success World" 1
            $outputBuffer."screen"[0].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | `tSuccess World"
            $outputBuffer."screen"[0].color | Should -Be "Green"
        }

        It 'Success Message Array with 1 indent' {
            Write-Success @("Success", "World") 1
            $outputBuffer."screen"[0].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | `tSuccess"
            $outputBuffer."screen"[0].color | Should -Be "Green"
            $outputBuffer."screen"[1].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | `tWorld"
            $outputBuffer."screen"[1].color | Should -Be "Green"
        }

        It 'Success Message with 3 indent' {
            Write-Success "Success World" 3
            $outputBuffer."screen"[0].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | `t`t`tSuccess World"
            $outputBuffer."screen"[0].color | Should -Be "Green"
        }

        It 'Success Message Array with 3 indent' {
            Write-Success @("Success", "World") 3
            $outputBuffer."screen"[0].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | `t`t`tSuccess"
            $outputBuffer."screen"[0].color | Should -Be "Green"
            $outputBuffer."screen"[1].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | `t`t`tWorld"
            $outputBuffer."screen"[1].color | Should -Be "Green"
        }
    }
}

Describe 'Write-Debug' {
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
        $logSetting."showLog" = $true
        $logSetting."showDebug" = $true
        $logSetting."fileOutput" = $false
        $logSetting."filename" = "test_log.txt"
    }

    Context 'show Settings' {
        It 'No Debug output when log setting is turned off' {
            $logSetting."showLog" = $false
            Write-Debug "Debug World"
            $outputBuffer."screen".Length | Should -Be 0
        }

        It 'No Debug output when log setting is turned off' {
            $logSetting."showDebug" = $false
            Write-Debug "Debug World"
            $outputBuffer."screen".Length | Should -Be 0
        }
    }

    Context "Default Paramaters" {
        It 'Plain Debug Message' {
            Write-Debug "Debug World"
            $outputBuffer."screen"[0].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | Debug World"
            $outputBuffer."screen"[0].color | Should -Be "Cyan"
        }

        It 'Plain Debug Message Array' {
            Write-Debug @("Debug", "World")
            $outputBuffer."screen"[0].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | Debug"
            $outputBuffer."screen"[0].color | Should -Be "Cyan"
            $outputBuffer."screen"[1].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | World"
            $outputBuffer."screen"[1].color | Should -Be "Cyan"
        }
    }

    Context "Indent Paramater" {
        It 'Debug Message with 1 indent' {
            Write-Debug "Debug World" 1
            $outputBuffer."screen"[0].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | `tDebug World"
            $outputBuffer."screen"[0].color | Should -Be "Cyan"
        }

        It 'Debug Message Array with 1 indent' {
            Write-Debug @("Debug", "World") 1
            $outputBuffer."screen"[0].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | `tDebug"
            $outputBuffer."screen"[0].color | Should -Be "Cyan"
            $outputBuffer."screen"[1].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | `tWorld"
            $outputBuffer."screen"[1].color | Should -Be "Cyan"
        }

        It 'Debug Message with 3 indent' {
            Write-Debug "Debug World" 3
            $outputBuffer."screen"[0].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | `t`t`tDebug World"
            $outputBuffer."screen"[0].color | Should -Be "Cyan"
        }

        It 'Debug Message Array with 3 indent' {
            Write-Debug @("Debug", "World") 3
            $outputBuffer."screen"[0].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | `t`t`tDebug"
            $outputBuffer."screen"[0].color | Should -Be "Cyan"
            $outputBuffer."screen"[1].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | `t`t`tWorld"
            $outputBuffer."screen"[1].color | Should -Be "Cyan"
        }
    }
}

Describe 'Write-Hash-Debug' {
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
    }

    It 'Output Debug Meesages for 1 element Hash Object' {
        $hash = @{"key1" = "val1"}
        Write-Hash-Debug $hash
        $outputBuffer."screen"[0].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | ------<Hash Object>------"
        $outputBuffer."screen"[0].color | Should -Be "Cyan"
        $outputBuffer."screen"[1].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | key1 = [String] val1"
        $outputBuffer."screen"[1].color | Should -Be "Cyan"
        $outputBuffer."screen"[2].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | -------------------------"
        $outputBuffer."screen"[2].color | Should -Be "Cyan"
    }

    It 'Output Debug Meesages for 3 element Hash Object' {
        $hash = @{"key1" = "val1"; "key2" = "val2"; "key3" = "val3"}
        Write-Hash-Debug $hash
        $outputBuffer."screen"[0].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | ------<Hash Object>------"
        $outputBuffer."screen"[0].color | Should -Be "Cyan"
        $outputBuffer."screen"[1].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | key1 = [String] val1"
        $outputBuffer."screen"[1].color | Should -Be "Cyan"
        $outputBuffer."screen"[2].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | key2 = [String] val2"
        $outputBuffer."screen"[2].color | Should -Be "Cyan"
        $outputBuffer."screen"[3].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | key3 = [String] val3"
        $outputBuffer."screen"[3].color | Should -Be "Cyan"
        $outputBuffer."screen"[4].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | -------------------------"
        $outputBuffer."screen"[4].color | Should -Be "Cyan"
    }
}

Describe 'Write-Start' {
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
    }

    It 'Outputs Start Lines' {
        Write-Start
        $outputBuffer."screen"[0].msg | Should -Be "[LOG] 01/01/2000 11:10 | Script Start"
        $outputBuffer."screen"[0].color | Should -Be "DarkGray"
        $outputBuffer."screen"[1].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | Start Time = 01/01/2000 11:10:00"
        $outputBuffer."screen"[1].color | Should -Be "Cyan"
    }
}

Describe 'Write-End' {
    BeforeEach{
        $global:outputBuffer = @{}
        $outputBuffer."screen" = @()
        $global:startTime = New-Object DateTime 2000, 1, 1, 11, 00, 0
    }

    It 'Outputs Start Lines' {
        Write-End
        $outputBuffer."screen"[0].msg | Should -Be "[DEBUG] 01/01/2000 11:10 | End Time = 01/01/2000 11:10:00"
        $outputBuffer."screen"[0].color | Should -Be "Cyan"
        $outputBuffer."screen"[1].msg | Should -Be "[SUCCESS] 01/01/2000 11:10 | Script End. Runtime = 600"
        $outputBuffer."screen"[1].color | Should -Be "Green"
    }
}

Describe 'Gen-Block' {
    It 'Generates Black Statement from 1 item array' {
        $msgs = @("test")
        $title = "Block Unit Testing"
        $block = Gen-Block $title $msgs
        $block[0]  | Should -Be "-----<Block Unit Testing>-----"
        $block[1]  | Should -Be "test"
        $block[2]  | Should -Be "------------------------------"
    }

    It 'Generates Black Statement from 3 item array' {
        $msgs = @("test", "hello", "world")
        $title = "Block Unit Testing"
        $block = Gen-Block $title $msgs
        $block[0]  | Should -Be "-----<Block Unit Testing>-----"
        $block[1]  | Should -Be "test"
        $block[2]  | Should -Be "hello"
        $block[3]  | Should -Be "world"
        $block[4]  | Should -Be "------------------------------"
    }

    It 'Header and Footer default to length of 25 for short title' {
        $msgs = @("test")
        $title = "Test"
        $block = Gen-Block $title $msgs
        $block[0].Length  | Should -Be 25
        $block[2].Length  | Should -Be 25
    }
}

Describe 'Gen-Hash-Block' {
    It 'Generates a debugging block with 1 item in hash' {
        $obj = @{"key1" = "val1"}
        $block = @(Gen-Hash-Block $obj)
        $block[0]  | Should -Be "key1 = [String] val1"
    }

    It 'Generates a debugging block with 3 items in hash' {
        $obj = @{
            "key1" = "val1"
            "key2" = "val2"
            "key3" = "val3"
        }
        $block = @(Gen-Hash-Block $obj)
        $block[0]  | Should -Be "key1 = [String] val1"
        $block[1]  | Should -Be "key2 = [String] val2"
        $block[2]  | Should -Be "key3 = [String] val3"
    }

    It 'Generates a debugging block with a child item' {
        $obj = @{
            "key1" = "val1"
            "key2" = @{"child1" = "childval1"}
        }
        $block = @(Gen-Hash-Block $obj)
        $block[0]  | Should -Be "key1 = [String] val1"
        $block[1]  | Should -Be "key2 = [Hash]"
        $block[2]  | Should -Be "`tchild1 = [String] childval1"
    }

    It 'Generates a debugging block with a grandchild item' {
        $obj = @{
            "key1" = "val1"
            "key2" = @{"child1" = @{"grandchild1" = "grandchildval1"}}
        }
        $block = @(Gen-Hash-Block $obj)
        $block[0]  | Should -Be "key1 = [String] val1"
        $block[1]  | Should -Be "key2 = [Hash]"
        $block[2]  | Should -Be "`tchild1 = [Hash]"
        $block[3]  | Should -Be "`t`tgrandchild1 = [String] grandchildval1"
    }

    It 'Generates a debugging block with array' {
        $obj = @{
            "key1" = "val1"
            "key2" = @("child1","child2")
        }
        $block = @(Gen-Hash-Block $obj)
        $block[0]  | Should -Be "key1 = [String] val1"
        $block[1]  | Should -Be "key2 = [Array]"
        $block[2]  | Should -Be "`t[String] child1"
        $block[3]  | Should -Be "`t[String] child2"
    }

    Context "Other Datatypes as val" {
        It 'Int Value' {
            $obj = @{"key1" = 16}
            $block = @(Gen-Hash-Block $obj)
            $block[0]  | Should -Be "key1 = [Int32] 16"
        }
        It 'Float Value' {
            $obj = @{"key1" = 16.58746}
            $block = @(Gen-Hash-Block $obj)
            $block[0]  | Should -Be "key1 = [Double] 16.58746"
        }
        It 'Boolean Float' {
            $obj = @{"key1" = $true}
            $block = @(Gen-Hash-Block $obj)
            $block[0]  | Should -Be "key1 = [Boolean] true"
        }
    }
}