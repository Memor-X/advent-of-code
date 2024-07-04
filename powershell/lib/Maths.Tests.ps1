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

    Context "Other Datatypes" {
        Context "String" {
            It 'Summing 2 string numbers' {
                $nums = @("5", "6")
                Sum $nums | Should -Be 11
            }
        }
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

    Context "Other Datatypes" {
        Context "String" {
            It 'Getting Min from 2 string numbers' {
                $nums = @("5", "6")
                Min $nums | Should -Be 5
            }
        }
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

    Context "Other Datatypes" {
        Context "String" {
            It 'Getting Max from 2 string numbers' {
                $nums = @("5", "6")
                Max $nums | Should -Be 6
            }
        }
    }
}

Describe 'Product' {
    It 'Proding 1 number returns it' {
        $nums = @(5)
        Product $nums | Should -Be 5
    }

    It 'Proding 2 numbers' {
        $nums = @(5, 6)
        Product $nums | Should -Be 30
    }

    It 'Proding 10 numbers' {
        $nums = @(1,2,3,4,5,6,7,8,9,10)
        Product $nums | Should -Be 3628800
    }

    Context "Prodding with 0 should always be 0" {
        It 'Proding 1 number being 0' {
            $nums = @(0)
            Product $nums | Should -Be 0
        }

        It 'Proding 2 numbers, one being 0' {
            $nums = @(5, 0)
            Product $nums | Should -Be 0
        }

        It 'Proding 10 numbers, one being 0' {
            $nums = $nums = @(1,2,3,4,5,0,7,8,9,10)
            Product $nums | Should -Be 0
        }
    }

    Context "Other Datatypes" {
        Context "String" {
            It 'Proding 2 string numbers' {
                $nums = @("5", "6")
                Product $nums | Should -Be 30
            }

            It 'Proding 5 string numbers' {
                $nums = @("5", "6", "7", "8", "9")
                Product $nums | Should -Be 15120
            }
        }
    }
}