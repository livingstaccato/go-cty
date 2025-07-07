# Covers tests in cty/function/stdlib/number_test.go

Feature: Standard Library Number Functions
  Background:
    Given a Go environment

  Scenario Outline: Get the absolute value of a number
    Given a number <inputValue>
    When I get its absolute value
    Then the result should be <expectedValue>
    And no error should occur

    Examples:
      | inputValue         | expectedValue          |
      | 15                 | 15                     |
      | -15                | 15                     |
      | 0                  | 0                      |
      | PositiveInfinity   | PositiveInfinity       |
      | NegativeInfinity   | PositiveInfinity       |
      | Unknown(Number)    | UnknownNotNull(Number) |
      | Dynamic            | UnknownNotNull(Number) |

  Scenario Outline: Add two numbers
    Given number A is <valueA>
    And number B is <valueB>
    When I add A and B
    Then the result should be <expectedSum>
    And no error should occur

    Examples:
      | valueA          | valueB          | expectedSum            |
      | 1               | 2               | 3                      |
      | 1               | Unknown(Number) | UnknownNotNull(Number) |
      | Unknown(Number) | Unknown(Number) | UnknownNotNull(Number) |
      | 1               | Dynamic         | UnknownNotNull(Number) |
      | Dynamic         | Dynamic         | UnknownNotNull(Number) |

  Scenario Outline: Subtract one number from another
    Given number A is <valueA>
    And number B is <valueB>
    When I subtract B from A
    Then the result should be <expectedDifference>
    And no error should occur

    Examples:
      | valueA          | valueB          | expectedDifference     |
      | 1               | 2               | -1                     |
      | 1               | Unknown(Number) | UnknownNotNull(Number) |
      | Unknown(Number) | Unknown(Number) | UnknownNotNull(Number) |
      | 1               | Dynamic         | UnknownNotNull(Number) |
      | Dynamic         | Dynamic         | UnknownNotNull(Number) |

  Scenario Outline: Multiply two numbers
    Given number A is <valueA>
    And number B is <valueB>
    When I multiply A and B
    Then the result should be <expectedProduct>
    And no error should occur

    Examples:
      | valueA          | valueB          | expectedProduct        |
      | 5               | 2               | 10                     |
      | 1               | Unknown(Number) | UnknownNotNull(Number) |
      | Unknown(Number) | Unknown(Number) | UnknownNotNull(Number) |
      | 1               | Dynamic         | UnknownNotNull(Number) |
      | Dynamic         | Dynamic         | UnknownNotNull(Number) |

  Scenario Outline: Divide one number by another
    Given number A is <valueA>
    And number B is <valueB>
    When I divide A by B
    Then the result should be <expectedQuotient>
    And no error should occur

    Examples:
      | valueA          | valueB           | expectedQuotient       |
      | 5               | 2                | 2.5                    |
      | 5               | 0                | PositiveInfinity       |
      | -5              | 0                | NegativeInfinity       |
      | 1               | PositiveInfinity | 0                      |
      | 1               | NegativeInfinity | 0                      |
      | 1               | Unknown(Number)  | UnknownNotNull(Number) |
      | Unknown(Number) | Unknown(Number)  | UnknownNotNull(Number) |
      | 1               | Dynamic          | UnknownNotNull(Number) |
      | Dynamic         | Dynamic          | UnknownNotNull(Number) |

  Scenario Outline: Calculate modulo of two numbers
    Given number A is <valueA>
    And number B is <valueB>
    When I calculate A modulo B
    Then the result should be <expectedRemainder>
    And no error should occur

    Examples:
      | valueA           | valueB           | expectedRemainder      |
      | 15               | 10               | 5                      |
      | 0                | 0                | 0                      |
      | PositiveInfinity | 1                | PositiveInfinity       |
      | NegativeInfinity | 1                | NegativeInfinity       |
      | 1                | PositiveInfinity | PositiveInfinity       | # This seems like an odd result, but matches test
      | 1                | Unknown(Number)  | UnknownNotNull(Number) |
      | Unknown(Number)  | Unknown(Number)  | UnknownNotNull(Number) |
      | 1                | Dynamic          | UnknownNotNull(Number) |
      | Dynamic          | Dynamic          | UnknownNotNull(Number) |

  Scenario Outline: Negate a number
    Given a number <inputValue>
    When I negate the number
    Then the result should be <expectedValue>
    And no error should occur

    Examples:
      | inputValue      | expectedValue          |
      | 15              | -15                    |
      | Unknown(Number) | UnknownNotNull(Number) |
      | Dynamic         | UnknownNotNull(Number) |

  Scenario Outline: Compare if one number is less than another
    Given number A is <valueA>
    And number B is <valueB>
    When I compare if A is less than B
    Then the result should be <expectedResult>
    And no error should occur

    Examples:
      | valueA          | valueB                       | expectedResult         |
      | 1               | 2                            | True                   |
      | 2               | 1                            | False                  |
      | 2               | 2                            | False                  |
      | 1               | Unknown(Number)              | UnknownNotNull(Bool)   |
      | 1               | Unknown(Num) refined lower 2 | True                   | # Deduced from refinement
      | Unknown(Number) | Unknown(Number)              | UnknownNotNull(Bool)   |
      | 1               | Dynamic                      | UnknownNotNull(Bool)   |
      | Dynamic         | Dynamic                      | UnknownNotNull(Bool)   |

  Scenario Outline: Compare if one number is less than or equal to another
    Given number A is <valueA>
    And number B is <valueB>
    When I compare if A is less than or equal to B
    Then the result should be <expectedResult>
    And no error should occur

    Examples:
      | valueA          | valueB          | expectedResult         |
      | 1               | 2               | True                   |
      | 2               | 1               | False                  |
      | 2               | 2               | True                   |
      | 1               | Unknown(Number) | UnknownNotNull(Bool)   |
      | Unknown(Number) | Unknown(Number) | UnknownNotNull(Bool)   |
      | 1               | Dynamic         | UnknownNotNull(Bool)   |
      | Dynamic         | Dynamic         | UnknownNotNull(Bool)   |

  Scenario Outline: Compare if one number is greater than another
    Given number A is <valueA>
    And number B is <valueB>
    When I compare if A is greater than B
    Then the result should be <expectedResult>
    And no error should occur

    Examples:
      | valueA          | valueB          | expectedResult         |
      | 1               | 2               | False                  |
      | 2               | 1               | True                   |
      | 2               | 2               | False                  |
      | 1               | Unknown(Number) | UnknownNotNull(Bool)   |
      | Unknown(Number) | Unknown(Number) | UnknownNotNull(Bool)   |
      | 1               | Dynamic         | UnknownNotNull(Bool)   |
      | Dynamic         | Dynamic         | UnknownNotNull(Bool)   |

  Scenario Outline: Compare if one number is greater than or equal to another
    Given number A is <valueA>
    And number B is <valueB>
    When I compare if A is greater than or equal to B
    Then the result should be <expectedResult>
    And no error should occur

    Examples:
      | valueA          | valueB          | expectedResult         |
      | 1               | 2               | False                  |
      | 2               | 1               | True                   |
      | 2               | 2               | True                   |
      | 1               | Unknown(Number) | UnknownNotNull(Bool)   |
      | Unknown(Number) | Unknown(Number) | UnknownNotNull(Bool)   |
      | 1               | Dynamic         | UnknownNotNull(Bool)   |
      | Dynamic         | Dynamic         | UnknownNotNull(Bool)   |

  Scenario Outline: Find the minimum of a list of numbers
    Given a list of numbers <inputNumbers>
    When I find the minimum value
    Then the result should be <expectedMinimum>
    And no error should occur

    Examples:
      | inputNumbers                | expectedMinimum        |
      | [0]                         | 0                      |
      | [-12]                       | -12                    |
      | [12]                        | 12                     |
      | [-12, 0, 2]                 | -12                    |
      | [NegativeInfinity, 0]       | NegativeInfinity       |
      | [PositiveInfinity, 0]       | 0                      |
      | [NegativeInfinity]          | NegativeInfinity       |
      | [PositiveInfinity, Unknown(Number)] | UnknownNotNull(Number) |
      | [PositiveInfinity, Dynamic] | UnknownNotNull(Number) |
      | [0 (mark 1), 1]             | 0 (mark 1)             |

  Scenario Outline: Find the maximum of a list of numbers
    Given a list of numbers <inputNumbers>
    When I find the maximum value
    Then the result should be <expectedMaximum>
    And no error should occur

    Examples:
      | inputNumbers                | expectedMaximum        |
      | [0]                         | 0                      |
      | [-12]                       | -12                    |
      | [12]                        | 12                     |
      | [-12, 0, 2]                 | 2                      |
      | [NegativeInfinity, 0]       | 0                      |
      | [PositiveInfinity, 0]       | PositiveInfinity       |
      | [NegativeInfinity]          | NegativeInfinity       |
      | [PositiveInfinity, Unknown(Number)] | UnknownNotNull(Number) |
      | [PositiveInfinity, Dynamic] | UnknownNotNull(Number) |

  Scenario Outline: Truncate a number to its integer part
    Given a number <inputValue>
    When I truncate it to an integer
    Then the result should be <expectedIntegerValue>
    And no error should occur

    Examples:
      | inputValue          | expectedIntegerValue  |
      | 0                   | 0                     |
      | 1                   | 1                     |
      | -1                  | -1                    |
      | 1.3                 | 1                     |
      | -1.7                | -1                    |
      | -1.3                | -1                    |
      | "9...9.7" (60 nines)| "9...9" (60 nines)    |
      | "-9...9.7" (60 nines)| "-9...9" (60 nines)   |

  Scenario Outline: Calculate ceiling of a number
    Given a number <inputValue>
    When I calculate its ceiling
    Then the result should be <expectedCeiling>
    And an error <shouldError> occur

    Examples:
      | inputValue          | expectedCeiling     | shouldError |
      | -1.8                | -1                  | should not  |
      | 1.2                 | 2                   | should not  |
      | PositiveInfinity    | PositiveInfinity    | should not  |
      | NegativeInfinity    | NegativeInfinity    | should not  |
      | "9...98.123" (58 nines) | "9...99" (58 nines) | should not  | # Number was 9...999.123 in test, last two digits were 98.
      | "-9...98.123" (58 nines)| "-9...98" (58 nines)| should not  |

  Scenario Outline: Calculate floor of a number
    Given a number <inputValue>
    When I calculate its floor
    Then the result should be <expectedFloor>
    And an error <shouldError> occur

    Examples:
      | inputValue          | expectedFloor         | shouldError |
      | -1.8                | -2                    | should not  |
      | 1.2                 | 1                     | should not  |
      | PositiveInfinity    | PositiveInfinity      | should not  |
      | NegativeInfinity    | NegativeInfinity      | should not  |
      | "9...9.123" (60 nines)| "9...9" (60 nines)    | should not  |
      | "-9...98.123" (58 nines)| "-9...99" (58 nines)| should not  |

  Scenario Outline: Calculate logarithm of a number with a given base
    Given a number <numberValue>
    And a base <baseValue>
    When I calculate the logarithm of the number with the base
    Then the result should be <expectedLogarithm>
    And an error <shouldError> occur

    Examples:
      | numberValue      | baseValue | expectedLogarithm | shouldError |
      | 1                | 10        | 0                 | should not  |
      | 10               | 10        | 1                 | should not  |
      | 0                | 10        | NegativeInfinity  | should not  |
      | 10               | 0         | -0.0              | should not  | # -0.0 is a float representation

  Scenario Outline: Calculate power of a number
    Given a number <numberValue>
    And a power <powerValue>
    When I calculate the number raised to the power
    Then the result should be <expectedResult>
    And an error <shouldError> occur

    Examples:
      | numberValue | powerValue | expectedResult | shouldError |
      | 1           | 0          | 1              | should not  |
      | 1           | 1          | 1              | should not  |
      | 2           | 0          | 1              | should not  |
      | 2           | 1          | 2              | should not  |
      | 3           | 2          | 9              | should not  |
      | -3          | 2          | 9              | should not  |
      | 2           | -2         | 0.25           | should not  |
      | 0           | 2          | 0              | should not  |

  Scenario Outline: Get the signum of a number
    Given a number <inputValue>
    When I get its signum
    Then the result should be <expectedSignum>
    And an error <shouldError> occur

    Examples:
      | inputValue | expectedSignum | shouldError |
      | 0          | 0              | should not  |
      | 12         | 1              | should not  |
      | -29        | -1             | should not  |

  Scenario Outline: Parse a string into an integer with a given base
    Given a string <stringValue>
    And a base <baseValue>
    When I parse the string as an integer with the base
    Then the result should be <expectedInteger>
    And an error <shouldError> occur

    Examples:
      | stringValue         | baseValue | expectedInteger       | shouldError |
      | "128"               | 10        | 128                   | should not  |
      | "-128"              | 10        | -128                  | should not  |
      | "00128"             | 10        | 128                   | should not  |
      | "-00128"            | 10        | -128                  | should not  |
      | "FF00"              | 16        | 65280                 | should not  |
      | "ff00"              | 16        | 65280                 | should not  |
      | "-FF00"             | 16        | -65280                | should not  |
      | "00FF00"            | 16        | 65280                 | should not  |
      | "-00FF00"           | 16        | -65280                | should not  |
      | "1011111011101111"  | 2         | 48879                 | should not  |
      | "aA"                | 62        | 656                   | should not  |
      | "Aa"                | 62        | 2242                  | should not  |
      | "9...9" (60 nines)  | 10        | "9...9" (60 nines)    | should not  |
      | "FF"                | 10        | UnknownNotNull(Number)| should      |
      | "00FF"              | 10        | UnknownNotNull(Number)| should      |
      | "-00FF"             | 10        | UnknownNotNull(Number)| should      |
      | 2                   | 10        | UnknownNotNull(Number)| should      | # Input not a string
      | "1"                 | 63        | UnknownNotNull(Number)| should      | # Base out of range
      | "1"                 | -1        | UnknownNotNull(Number)| should      | # Base out of range
      | "1"                 | 1         | UnknownNotNull(Number)| should      | # Base out of range
      | "1"                 | 0         | UnknownNotNull(Number)| should      | # Base out of range
      | "1.2"               | 10        | UnknownNotNull(Number)| should      | # Not an integer string
