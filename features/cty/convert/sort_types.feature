# Original Go Test File: cty/convert/sort_types_test.go
# This feature file covers the test cases for the internal sortTypes function.

Feature: Type Sorting for Conversion Unification
  This feature describes how a list of cty types is sorted. This sorting
  is used internally, likely as part of the type unification process, to establish a
  consistent order when determining a common type for conversion.

  The underlying `compareTypes` function defines precedence (e.g., String before Number).
  Types considered "neutral" (e.g., Bool and Number) have a comparison result of 0,
  meaning their relative order in a sorted list containing both might depend on their
  initial positions if the sort is stable, or an otherwise consistent arbitrary tie-break.
  The examples show the output from the Go test, which reflects one such consistent ordering.

  Background:
    Given the cty type sorting mechanism (based on compareTypes)

  Scenario Outline: Sorting a list of cty types
    # Covers test: TestSortTypes
    Given an input list of cty types: <InputTypes>
    When the list is sorted
    Then the resulting order of types should be <ExpectedSortedTypes>

    Examples:
      | InputTypes                                 | ExpectedSortedTypes                        | Description                                      |
      | []                                         | []                                         | Empty list remains empty                         |
      | [String, Number]                           | [String, Number]                           | Already sorted (String precedes Number)          |
      | [Number, String]                           | [String, Number]                           | Number is sorted after String                    |
      | [String, Bool]                             | [String, Bool]                             | Already sorted (String precedes Bool)            |
      | [Bool, String]                             | [String, Bool]                             | Bool is sorted after String                      |
      | [Bool, String, Number]                     | [String, Bool, Number]                     | String, then Bool/Number (neutral)               |
      | [Number, String, Bool]                     | [String, Number, Bool]                     | String, then Number/Bool (neutral)               |
      | [String, String]                           | [String, String]                           | Duplicate types maintain relative order (stable) |
      | [Number, String, Number]                   | [String, Number, Number]                   | Sorts correctly with duplicates                  |
      | [String, List(String)]                     | [String, List(String)]                     | String is neutral with List(String)              |
      | [List(String), String]                     | [List(String), String]                     | List(String) is neutral with String              |
      | [Bool, List(String), String]               | [List(String), String, Bool]               | List(String) and String are neutral, then Bool   | # Example of neutral group ordering
      | [String, DynamicType]                      | [String, DynamicType]                      | String precedes DynamicType                      |
      | [DynamicType, String]                      | [String, DynamicType]                      | DynamicType is sorted after String               |

    # Note on Type Syntax:
    # - Type lists are represented as [Type1, Type2, ...]
