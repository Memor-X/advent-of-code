BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe 'Sum' {
    It 'Summing 1 number returns it' {
        $nums = @(5)
        Sum $nums | Should -Be 5
    }

    It 'Summing 2 numbers' {
        $nums = @(5, 6)
        Sum $nums | Should -Be 11
    }

    It 'Summing 10 numbers' {
        $nums = @(1,2,3,4,5,6,7,8,9,10)
        Sum $nums | Should -Be 55
    }

    It 'Summing 2 string numbers' {
        $nums = @("5", "6")
        Sum $nums | Should -Be 11
    }
}

Describe 'Min' {
    It 'Getting Min from 1 number returns it' {
        $nums = @(5)
        Min $nums | Should -Be 5
    }

    It 'Getting Min from 2 numbers' {
        $nums = @(5, 6)
        Min $nums | Should -Be 5
    }

    It 'Getting Min from 10 numbers' {
        $nums = @(5,6,7,1,2,3,4,8,9,10)
        Min $nums | Should -Be 1
    }

    It 'Getting Min from 2 string numbers' {
        $nums = @("5", "6")
        Min $nums | Should -Be 5
    }
}

Describe 'Max' {
    It 'Getting Max from 1 number returns it' {
        $nums = @(5)
        Max $nums | Should -Be 5
    }

    It 'Getting Max from 2 numbers' {
        $nums = @(5, 6)
        Max $nums | Should -Be 6
    }

    It 'Getting Max from 10 numbers' {
        $nums = @(5,6,8,9,10,7,1,2,3,4)
        Max $nums | Should -Be 10
    }

    It 'Getting Max from 2 string numbers' {
        $nums = @("5", "6")
        Max $nums | Should -Be 6
    }
}