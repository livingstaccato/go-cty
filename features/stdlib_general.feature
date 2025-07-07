# Covers tests in cty/function/stdlib/general_test.go

Feature: Standard Library General Functions
  Background:
    Given a Go environment

  Scenario Outline: Compare two values for equality
    Given value A is <valueA>
    And value B is <valueB>
    When I compare A and B for equality
    Then the result should be <expectedResult>
    And no error should occur

    Examples:
      | valueA          | valueB          | expectedResult         |
      | 1               | 2               | False                  |
      | 2               | 2               | True                   |
      | Null(Number)    | Null(Number)    | True                   |
      | 2               | Null(Number)    | False                  |
      | 1               | Unknown(Number) | UnknownNotNull(Bool)   |
      | Unknown(Number) | Unknown(Number) | UnknownNotNull(Bool)   |
      | 1               | Dynamic         | UnknownNotNull(Bool)   |
      | Dynamic         | Dynamic         | UnknownNotNull(Bool)   |

  Scenario Outline: Coalesce a list of values
    Given a list of values <valuesToCoalesce>
    When I coalesce these values
    Then the result should be <expectedResult>
    And no error should occur

    Examples:
      | valuesToCoalesce                | expectedResult         |
      | [True]                          | True                   |
      | [Null(Bool), True]              | True                   |
      | [Null(Bool), False]             | False                  |
      | [Null(Bool), False, "hello"]    | "false"                | # Coerced to string
      | [True, Unknown(Bool)]           | True                   |
      | [Unknown(Bool), True]           | UnknownNotNull(Bool)   |
      | [Unknown(Bool), "hello"]        | UnknownNotNull(String) |
      | [Dynamic, True]                 | UnknownNotNull(Bool)   |
      | [Dynamic]                       | Dynamic                |
