# Covers tests in cty/function/stdlib/bool_test.go

Feature: Standard Library Boolean Functions
  Background:
    Given a Go environment

  Scenario Outline: Logical NOT operation
    Given a boolean value <inputValue>
    When I apply the NOT operator
    Then the result should be <expectedValue>
    And no error should occur

    Examples:
      | inputValue         | expectedValue              |
      | True               | False                      |
      | False              | True                       |
      | Unknown(Bool)      | UnknownNotNull(Bool)       |
      | Dynamic            | UnknownNotNull(Bool)       |
      | True (mark 1)      | False (mark 1)             |

  Scenario Outline: Logical AND operation
    Given boolean value A is <valueA>
    And boolean value B is <valueB>
    When I apply the AND operator to A and B
    Then the result should be <expectedValue>
    And no error should occur

    Examples:
      | valueA             | valueB             | expectedValue              |
      | False              | False              | False                      |
      | False              | True               | False                      |
      | True               | False              | False                      |
      | True               | True               | True                       |
      | True               | Unknown(Bool)      | UnknownNotNull(Bool)       |
      | Unknown(Bool)      | Unknown(Bool)      | UnknownNotNull(Bool)       |
      | True               | Dynamic            | UnknownNotNull(Bool)       |
      | Dynamic            | Dynamic            | UnknownNotNull(Bool)       |

  Scenario Outline: Logical OR operation
    Given boolean value A is <valueA>
    And boolean value B is <valueB>
    When I apply the OR operator to A and B
    Then the result should be <expectedValue>
    And no error should occur

    Examples:
      | valueA             | valueB             | expectedValue              |
      | False              | False              | False                      |
      | False              | True               | True                       |
      | True               | False              | True                       |
      | True               | True               | True                       |
      | True               | Unknown(Bool)      | UnknownNotNull(Bool)       |
      | Unknown(Bool)      | Unknown(Bool)      | UnknownNotNull(Bool)       |
      | True               | Dynamic            | UnknownNotNull(Bool)       |
      | Dynamic            | Dynamic            | UnknownNotNull(Bool)       |
