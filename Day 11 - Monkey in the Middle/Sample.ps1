@(
    [PSCustomObject]@{
        # Monkey 0:
        #   Starting items: 79, 98
        #   Operation: new = old * 19
        #   Test: divisible by 23
        #     If true: throw to monkey 2
        #     If false: throw to monkey 3

        Number = 0
        Items = @(79, 98)
        Operation = {
            param (
                $Old
            )
            return ($Old * 19) 
        }
        Test = 23
        Truthy = 2
        Falsy = 3
    }

    [PSCustomObject]@{
        # Monkey 1:
        #   Starting items: 54, 65, 75, 74
        #   Operation: new = old + 6
        #   Test: divisible by 19
        #     If true: throw to monkey 2
        #     If false: throw to monkey 0
        Number = 1
        Items = @(54, 65, 75, 74)
        Operation = {
            param (
                $Old
            )
            return $Old + 6
        }
        Test = 19
        Truthy = 2
        Falsy = 0
    }

    [PSCustomObject]@{
        # Monkey 2:
        #   Starting items: 79, 60, 97
        #   Operation: new = old * old
        #   Test: divisible by 13
        #     If true: throw to monkey 1
        #     If false: throw to monkey 3
        Number = 2
        Items = @(79, 60, 97)
        Operation = {
            param (
                $Old
            )
            return $Old * $Old
        }
        Test = 13
        Truthy = 1
        Falsy = 3
    }

    [PSCustomObject]@{
        # Monkey 3:
        #   Starting items: 74
        #   Operation: new = old + 3
        #   Test: divisible by 17
        #     If true: throw to monkey 0
        #     If false: throw to monkey 1
        Number = 3
        Items = @(74)
        Operation = {
            param (
                 $Old
            )
            return $Old + 3
        }
        Test = 17
        Truthy = 0
        Falsy = 1
    }
)