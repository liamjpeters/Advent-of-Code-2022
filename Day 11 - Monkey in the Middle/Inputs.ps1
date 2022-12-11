@(
    [PSCustomObject]@{
        # Monkey 0:
        #   Starting items: 65, 58, 93, 57, 66
        #   Operation: new = old * 7
        #   Test: divisible by 19
        #     If true: throw to monkey 6
        #     If false: throw to monkey 4

        Number = 0
        Items = @(65, 58, 93, 57, 66)
        Operation = {
            param (
                $Old
            )
            return $Old * 7
        }
        Test = 19
        Truthy = 6
        Falsy = 4
    }

    [PSCustomObject]@{
        # Monkey 1:
        #   Starting items: 76, 97, 58, 72, 57, 92, 82
        #   Operation: new = old + 4
        #   Test: divisible by 3
        #     If true: throw to monkey 7
        #     If false: throw to monkey 5
        Number = 1
        Items = @(76, 97, 58, 72, 57, 92, 82)
        Operation = {
            param (
                $Old
            )
            return $Old + 4
        }
        Test = 3
        Truthy = 7
        Falsy = 5
    }

    [PSCustomObject]@{
        # Monkey 2:
        #   Starting items: 90, 89, 96
        #   Operation: new = old * 5
        #   Test: divisible by 13
        #     If true: throw to monkey 5
        #     If false: throw to monkey 1
        Number = 2
        Items = @(90, 89, 96)
        Operation = {
            param (
                $Old
            )
            return $Old * 5
        }
        Test = 13
        Truthy = 5
        Falsy = 1
    }

    [PSCustomObject]@{
        # Monkey 3:
        #   Starting items: 72, 63, 72, 99
        #   Operation: new = old * old
        #   Test: divisible by 17
        #     If true: throw to monkey 0
        #     If false: throw to monkey 4
        Number = 3
        Items = @(72, 63, 72, 99)
        Operation = {
            param (
                $Old
            )
            return $Old * $Old
        }
        Test = 17
        Truthy = 0
        Falsy = 4
    }

    [PSCustomObject]@{
        # Monkey 4:
        #   Starting items: 65
        #   Operation: new = old + 1
        #   Test: divisible by 2
        #     If true: throw to monkey 6
        #     If false: throw to monkey 2
        Number = 4
        Items = @(65)
        Operation = {
            param (
                $Old
            )
            return $Old + 1
        }
        Test = 2
        Truthy = 6
        Falsy = 2
    }

    [PSCustomObject]@{
        # Monkey 5:
        #   Starting items: 97, 71
        #   Operation: new = old + 8
        #   Test: divisible by 11
        #     If true: throw to monkey 7
        #     If false: throw to monkey 3
        Number = 5
        Items = @(97, 71)
        Operation = {
            param (
                $Old
            )
            return $Old + 8
        }
        Test = 11
        Truthy = 7
        Falsy = 3
    }

    [PSCustomObject]@{
        # Monkey 6:
        #   Starting items: 83, 68, 88, 55, 87, 67
        #   Operation: new = old + 2
        #   Test: divisible by 5
        #     If true: throw to monkey 2
        #     If false: throw to monkey 1
        Number = 6
        Items = @(83, 68, 88, 55, 87, 67)
        Operation = {
            param (
                $Old
            )
            return $Old + 2
        }
        Test = 5
        Truthy = 2
        Falsy = 1
    }

    [PSCustomObject]@{
        # Monkey 7:
        #   Starting items: 64, 81, 50, 96, 82, 53, 62, 92
        #   Operation: new = old + 5
        #   Test: divisible by 7
        #     If true: throw to monkey 3
        #     If false: throw to monkey 0
        Number = 7
        Items = @(64, 81, 50, 96, 82, 53, 62, 92)
        Operation = {
            param (
                $Old
            )
            return $Old + 5
        }
        Test = 7
        Truthy = 3
        Falsy = 0
    }

)