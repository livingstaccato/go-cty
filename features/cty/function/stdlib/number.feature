# Original Go Test File: cty/function/stdlib/number_test.go
# This feature file covers tests for numeric functions in the cty standard library.

Feature: Standard Library Numeric Functions
  This feature describes the behavior of various mathematical and
  comparison functions operating on cty Number values.

  Scenario Outline: Absolute value of a number (Absolute)
    # Covers test: TestAbsolute
    Given a cty Number <InputNumber>
    When the Absolute function is called
    Then the result should be the cty Number <ExpectedAbsoluteValue>
    And if the input was Unknown or Dynamic, the result should be refined as NotNull

    Examples:
      | InputNumber        | ExpectedAbsoluteValue |
      | Number(15)         | Number(15)            |
      | Number(-15)        | Number(15)            |
      | Number(0)          | Number(0)             |
      | PositiveInfinity   | PositiveInfinity      |
      | NegativeInfinity   | PositiveInfinity      |
      | Unknown(Number)    | Unknown(Number)       |
      | Dynamic            | Unknown(Number)       |

  Scenario Outline: Arithmetic operations (Add, Subtract, Multiply, Divide, Modulo)
    # Covers test: TestAdd, TestSubtract, TestMultiply, TestDivide, TestModulo
    Given a cty Number <A>
    And a cty Number <B>
    When the <Operation> function is called with <A> and <B>
    Then the result should be the cty Number <ExpectedResult>
    And if inputs were Unknown or Dynamic, the result should be refined as NotNull (unless result is Infinity/Zero for Divide)

    Examples: Add
      | A              | B              | Operation | ExpectedResult   |
      | Number(1)      | Number(2)      | Add       | Number(3)        |
      | Number(1)      | Unknown(Number)| Add       | Unknown(Number)  |
      | Dynamic        | Dynamic        | Add       | Unknown(Number)  |

    Examples: Subtract
      | A              | B              | Operation | ExpectedResult   |
      | Number(1)      | Number(2)      | Subtract  | Number(-1)       |
      | Number(1)      | Unknown(Number)| Subtract  | Unknown(Number)  |

    Examples: Multiply
      | A              | B              | Operation | ExpectedResult   |
      | Number(5)      | Number(2)      | Multiply  | Number(10)       |
      | Number(1)      | Unknown(Number)| Multiply  | Unknown(Number)  |

    Examples: Divide
      | A              | B              | Operation | ExpectedResult   |
      | Number(5)      | Number(2)      | Divide    | Number(2.5)      |
      | Number(5)      | Number(0)      | Divide    | PositiveInfinity |
      | Number(-5)     | Number(0)      | Divide    | NegativeInfinity |
      | Number(1)      | PositiveInfinity| Divide   | Number(0)        |
      | Number(1)      | Unknown(Number)| Divide    | Unknown(Number)  |

    Examples: Modulo
      | A              | B              | Operation | ExpectedResult   |
      | Number(15)     | Number(10)     | Modulo    | Number(5)        |
      | Number(0)      | Number(0)      | Modulo    | Number(0)        | # Result for 0 % 0 can be platform-dependent or NaN; cty returns 0
      | PositiveInfinity| Number(1)      | Modulo    | PositiveInfinity |
      | Number(1)      | Unknown(Number)| Modulo    | Unknown(Number)  |

  Scenario Outline: Negating a number (Negate)
    # Covers test: TestNegate
    Given a cty Number <InputNumber>
    When the Negate function is called
    Then the result should be the cty Number <ExpectedNegatedValue>
    And if the input was Unknown or Dynamic, the result should be refined as NotNull

    Examples:
      | InputNumber     | ExpectedNegatedValue |
      | Number(15)      | Number(-15)          |
      | Number(-15)     | Number(15)           |
      | Unknown(Number) | Unknown(Number)      |
      | Dynamic         | Unknown(Number)      |

  Scenario Outline: Number comparisons (LessThan, LessThanOrEqualTo, GreaterThan, GreaterThanOrEqualTo)
    # Covers test: TestLessThan, TestLessThanOrEqualTo, TestGreaterThan, TestGreaterThanOrEqualTo
    Given a cty Number <A>
    And a cty Number <B>
    When the <Comparison> function is called with <A> and <B>
    Then the result should be the cty Bool <ExpectedResult>
    And if inputs were Unknown or Dynamic, the result should be refined as NotNull (unless deduced from refinements)

    Examples: LessThan
      | A                                   | B                                   | Comparison | ExpectedResult |
      | Number(1)                           | Number(2)                           | LessThan   | True           |
      | Number(2)                           | Number(1)                           | LessThan   | False          |
      | Number(1)                           | Unknown(Number)                     | LessThan   | Unknown(Bool)  |
      | Number(1)                           | Unknown(Number).RefineMinBound(2,true)| LessThan   | True           | # Deduced
      | Dynamic                             | Dynamic                             | LessThan   | Unknown(Bool)  |

    Examples: LessThanOrEqualTo
      | A                 | B                 | Comparison        | ExpectedResult |
      | Number(2)         | Number(2)         | LessThanOrEqualTo | True           |
      | Number(1)         | Unknown(Number)   | LessThanOrEqualTo | Unknown(Bool)  |

    Examples: GreaterThan
      | A                 | B                 | Comparison  | ExpectedResult |
      | Number(2)         | Number(1)         | GreaterThan | True           |
      | Number(1)         | Number(2)         | GreaterThan | False          |
      | Number(1)         | Unknown(Number)   | GreaterThan | Unknown(Bool)  |

    Examples: GreaterThanOrEqualTo
      | A                 | B                 | Comparison           | ExpectedResult |
      | Number(2)         | Number(2)         | GreaterThanOrEqualTo | True           |
      | Number(1)         | Unknown(Number)   | GreaterThanOrEqualTo | Unknown(Bool)  |

  Scenario Outline: Finding Minimum or Maximum of numbers (Min, Max)
    # Covers test: TestMin, TestMax
    Given a list of cty Numbers <InputNumbers>
    When the <MinOrMax> function is called with these numbers
    Then the result should be the cty Number <ExpectedResult>
    And if any input was Unknown or Dynamic, the result may be Unknown(Number) refined as NotNull

    Examples: Min
      | InputNumbers                          | MinOrMax | ExpectedResult   |
      | [Number(0)]                           | Min      | Number(0)        |
      | [Number(-12), Number(0), Number(2)]   | Min      | Number(-12)      |
      | [NegativeInfinity, Number(0)]         | Min      | NegativeInfinity |
      | [PositiveInfinity, Unknown(Number)]   | Min      | Unknown(Number)  |
      | [Number(0).Mark(1), Number(1)]        | Min      | Number(0).Mark(1)|

    Examples: Max
      | InputNumbers                          | MinOrMax | ExpectedResult   |
      | [Number(0)]                           | Max      | Number(0)        |
      | [Number(-12), Number(0), Number(2)]   | Max      | Number(2)        |
      | [NegativeInfinity, Number(0)]         | Max      | Number(0)        |
      | [PositiveInfinity, Unknown(Number)]   | Max      | Unknown(Number)  | # Actually PositiveInfinity if Unknown is not -Inf

  Scenario Outline: Truncating a number to an integer (Int function)
    # Covers test: TestInt
    Given a cty Number <InputNumber>
    When the Int function is called
    Then the result should be the cty Number <ExpectedIntegerValue> (integer part)

    Examples:
      | InputNumber     | ExpectedIntegerValue |
      | Number(0)       | Number(0)            |
      | Number(1.3)     | Number(1)            |
      | Number(-1.7)    | Number(-1)           |
      | Number(BIG_POS_FLOAT_WITH_FRAC) | Number(BIG_POS_INT_PART) |
      | Number(-BIG_POS_FLOAT_WITH_FRAC)| Number(-BIG_POS_INT_PART)|

  Scenario Outline: Ceiling and Floor of a number (Ceil, Floor)
    # Covers test: TestCeil, TestFloor
    Given a cty Number <InputNumber>
    When the <Function> function is called
    Then the result should be the cty Number <ExpectedResult>

    Examples: Ceil
      | InputNumber     | Function | ExpectedResult |
      | Number(-1.8)    | Ceil     | Number(-1)     |
      | Number(1.2)     | Ceil     | Number(2)      |
      | PositiveInfinity| Ceil     | PositiveInfinity|

    Examples: Floor
      | InputNumber     | Function | ExpectedResult |
      | Number(-1.8)    | Floor    | Number(-2)     |
      | Number(1.2)     | Floor    | Number(1)      |
      | PositiveInfinity| Floor    | PositiveInfinity|

  Scenario Outline: Logarithm of a number (Log)
    # Covers test: TestLog
    Given a cty Number <NumberInput>
    And a cty Number base <BaseInput>
    When the Log function is called with number and base
    Then the result should be the cty Number <ExpectedResult>

    Examples:
      | NumberInput | BaseInput  | ExpectedResult   |
      | Number(1)   | Number(10) | Number(0)        |
      | Number(10)  | Number(10) | Number(1)        |
      | Number(0)   | Number(10) | NegativeInfinity |
      | Number(10)  | Number(0)  | Number(-0)       |

  Scenario Outline: Exponentiation (Pow)
    # Covers test: TestPow
    Given a cty Number <NumberInput>
    And a cty Number power <PowerInput>
    When the Pow function is called with number and power
    Then the result should be the cty Number <ExpectedResult>

    Examples:
      | NumberInput | PowerInput | ExpectedResult |
      | Number(1)   | Number(0)  | Number(1)      |
      | Number(3)   | Number(2)  | Number(9)      |
      | Number(-3)  | Number(2)  | Number(9)      |
      | Number(2)   | Number(-2) | Number(0.25)   |

  Scenario Outline: Sign of a number (Signum)
    # Covers test: TestSignum
    Given a cty Number <InputNumber>
    When the Signum function is called
    Then the result should be the cty Number <ExpectedSign> (-1, 0, or 1)

    Examples:
      | InputNumber  | ExpectedSign |
      | Number(0)    | Number(0)    |
      | Number(12)   | Number(1)    |
      | Number(-29)  | Number(-1)   |

  Scenario Outline: Parsing a string to an integer (ParseInt)
    # Covers test: TestParseInt
    Given a cty String <NumberString>
    And a cty Number base <Base>
    When the ParseInt function is called with the string and base
    Then the result should be the cty Number <ExpectedInteger>
    And an error should <ErrorOccur> (otherwise not occur)

    Examples: Valid Inputs
      | NumberString | Base      | ExpectedInteger | ErrorOccur |
      | "128"        | Number(10)| Number(128)     | not occur  |
      | "-128"       | Number(10)| Number(-128)    | not occur  |
      | "FF00"       | Number(16)| Number(65280)   | not occur  |
      | "1011"       | Number(2) | Number(11)      | not occur  |
      | "aA"         | Number(62)| Number(656)     | not occur  |

    Examples: Invalid Inputs
      | NumberString | Base      | ExpectedInteger | ErrorOccur |
      | "FF"         | Number(10)|                 | occur      |
      | Number(2)    | Number(10)|                 | occur      | # First arg not string
      | "1"          | Number(1) |                 | occur      | # Invalid base
      | "1.2"        | Number(10)|                 | occur      | # Not an integer string

    # Note on Value Syntax:
    # - Number(X), String("X"), True, False, Unknown(Type), Dynamic, PositiveInfinity, NegativeInfinity
    # - .Mark(m), .WithMarks(m1,m2) for marked values.
    # - BIG_POS_FLOAT_WITH_FRAC represents a very large float, BIG_POS_INT_PART its integer part.
    # - ErrorOccur: "occur" or "not occur". If "occur", ExpectedResult is ignored.Here's the Gherkin feature file for `cty/function/stdlib/number_test.go`:
