# Original Go Test File: cty/function/stdlib/bool_test.go
# This feature file covers tests for boolean logic functions in the cty standard library.

Feature: Standard Library Boolean Functions
  This feature describes the behavior of standard boolean logic functions
  like Not, And, and Or.

  Scenario Outline: Logical NOT operation
    # Covers test: TestNot
    Given a cty value <Input>
    When the Not function is called with the input
    Then the result should be <ExpectedOutput>
    And the result's marks should be equivalent to the input's marks
    And if the result is an Unknown value, it should be refined as not null

    Examples:
      | Input               | ExpectedOutput      |
      | True                | False               |
      | False               | True                |
      | Unknown(Bool)       | Unknown(Bool)       |
      | Dynamic             | Unknown(Bool)       |
      | True.Mark(1)        | False.Mark(1)       |

  Scenario Outline: Logical AND operation
    # Covers test: TestAnd
    Given a cty value <A>
    And a cty value <B>
    When the And function is called with <A> and <B>
    Then the result should be <ExpectedOutput>
    And if the result is an Unknown value, it should be refined as not null

    Examples:
      | A                 | B                 | ExpectedOutput      | Description (Optional)                     |
      | False             | False             | False               |                                            |
      | False             | True              | False               |                                            |
      | True              | False             | False               |                                            |
      | True              | True              | True                |                                            |
      | True              | Unknown(Bool)     | Unknown(Bool)       | # Result depends on Unknown                |
      | False             | Unknown(Bool)     | False               | # Short-circuit                            |
      | Unknown(Bool)     | Unknown(Bool)     | Unknown(Bool)       |                                            |
      | True              | Dynamic           | Unknown(Bool)       | # Result depends on Dynamic (as Unknown)   |
      | Dynamic           | Dynamic           | Unknown(Bool)       |                                            |
      | False.Mark(1)     | True.Mark(2)      | False.WithMarks(1,2)|                                            |
      | True.Mark(1)      | Unknown(Bool).Mark(2) | Unknown(Bool).WithMarks(1,2) |                                            |

  Scenario Outline: Logical OR operation
    # Covers test: TestOr
    Given a cty value <A>
    And a cty value <B>
    When the Or function is called with <A> and <B>
    Then the result should be <ExpectedOutput>
    And if the result is an Unknown value, it should be refined as not null

    Examples:
      | A                 | B                 | ExpectedOutput      | Description (Optional)                   |
      | False             | False             | False               |                                          |
      | False             | True              | True                |                                          |
      | True              | False             | True                |                                          |
      | True              | True              | True                |                                          |
      | False             | Unknown(Bool)     | Unknown(Bool)       | # Result depends on Unknown              |
      | True              | Unknown(Bool)     | True                | # Short-circuit                          |
      | Unknown(Bool)     | Unknown(Bool)     | Unknown(Bool)       |                                          |
      | False             | Dynamic           | Unknown(Bool)       | # Result depends on Dynamic (as Unknown) |
      | Dynamic           | Dynamic           | Unknown(Bool)       |                                          |
      | True.Mark(1)      | False.Mark(2)     | True.WithMarks(1,2) |                                          |
      | False.Mark(1)     | Unknown(Bool).Mark(2) | Unknown(Bool).WithMarks(1,2) |                                          |

    # Note on Value Syntax:
    # - True, False are cty.True, cty.False
    # - Unknown(Type) is cty.UnknownVal(cty.Type)
    # - Dynamic is cty.DynamicVal
    # - Value.Mark(m) indicates a marked value.
    # - Value.WithMarks(m1,m2) indicates a value with multiple marks (relevant for AND/OR propagation).
