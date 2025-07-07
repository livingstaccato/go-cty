# Original Go Test File: cty/convert/sort_types_test.go
# This feature file covers the test cases for the internal sortTypes function.

Feature: Type Sorting for Conversion Unification
  This feature describes how a list of cty types is sorted. This sorting
  is likely used as part of the type unification process to establish a
  consistent order when determining a common type for conversion.

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
      | [Bool, List(String), String]               | [List(String), String, Bool]               | List(String) and String are neutral, then Bool   | # Arbitrary but consistent for neutral group
      | [String, DynamicType]                      | [String, DynamicType]                      | String precedes DynamicType                      |
      | [DynamicType, String]                      | [String, DynamicType]                      | DynamicType is sorted after String               |

    # Note:
    # - Type lists are represented as [Type1, Type2, ...]
    # - The "neutral" keyword implies that the relative order of those specific types
    #   might be arbitrary but is consistent according to the compareTypes logic.
    #   For example, Bool and Number are neutral to each other, so their relative
    #   order in a sorted list containing both might depend on their initial positions
    #   if the sort is stable, or an arbitrary tie-break if not.
    #   The examples show the output from the Go test, which reflects this.
