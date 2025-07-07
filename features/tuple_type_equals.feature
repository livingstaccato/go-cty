# Covers tests in cty/tuple_type_test.go

Feature: Tuple Type Equality
  Background:
    Given a Go environment

  Scenario Outline: Compare two tuple types for equality
    Given a tuple type A: <tupleA>
    And a tuple type B: <tupleB>
    When I check if tuple type A equals tuple type B
    Then the result should be <expectedEquality>

    Examples: Equal Tuple Types
      | tupleA                  | tupleB                  | expectedEquality |
      | Tuple([])               | Tuple([])               | True             |
      | EmptyTuple              | Tuple([])               | True             |
      | Tuple([String])         | Tuple([String])         | True             |
      | Tuple([Tuple([String])]) | Tuple([Tuple([String])]) | True             |

    Examples: Unequal Tuple Types
      | tupleA                  | tupleB                  | expectedEquality |
      | Tuple([String])         | EmptyTuple              | False            |
      | Tuple([String])         | Tuple([Number])         | False            |
      | Tuple([String])         | Tuple([String, Number]) | False            |
      | Tuple([String])         | Tuple([Tuple([String])]) | False            |
