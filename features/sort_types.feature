# Covers tests in cty/convert/sort_types_test.go

Feature: Type Sorting
  Background:
    Given a Go environment

  Scenario Outline: Sort a list of types
    Given a list of types <inputTypes>
    When I sort the list of types
    Then the sorted list should be <expectedSortedTypes>

    Examples:
      | inputTypes                               | expectedSortedTypes                      |
      | []                                       | []                                       |
      | [String, Number]                         | [String, Number]                         |
      | [Number, String]                         | [String, Number]                         |
      | [String, Bool]                           | [String, Bool]                           |
      | [Bool, String]                           | [String, Bool]                           |
      | [Bool, String, Number]                   | [String, Bool, Number]                   |
      | [Number, String, Bool]                   | [String, Number, Bool]                   |
      | [String, String]                         | [String, String]                         |
      | [Number, String, Number]                 | [String, Number, Number]                 |
      | [String, List(String)]                   | [String, List(String)]                   |
      | [List(String), String]                   | [List(String), String]                   |
      | [Bool, List(String), String]             | [List(String), String, Bool]             | # Somewhat arbitrary, but consistent
      | [String, Dynamic]                        | [String, Dynamic]                        |
      | [Dynamic, String]                        | [String, Dynamic]                        |
