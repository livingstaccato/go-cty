# Covers tests in cty/function/stdlib/bytes_test.go

Feature: Standard Library Bytes Functions
  Background:
    Given a Go environment

  Scenario Outline: Get length of a bytes value
    Given a bytes value <inputValue>
    When I get the length of the bytes value
    Then the result should be <expectedLength>
    And no error should occur

    Examples:
      | inputValue    | expectedLength |
      | []            | 0              |
      | ['a']         | 1              |
      | ['a', 'b', 'c'] | 3              |

  Scenario Outline: Slice a bytes value
    Given a bytes value <inputValue>
    And an offset <offset>
    And a length <length>
    When I slice the bytes value with the given offset and length
    Then the resulting bytes value should be <expectedSlice>
    And no error should occur

    Examples:
      | inputValue    | offset | length | expectedSlice |
      | []            | 0      | 0      | []            |
      | ['a']         | 0      | 1      | ['a']         |
      | ['a', 'b', 'c'] | 0      | 2      | ['a', 'b']    |
      | ['a', 'b', 'c'] | 1      | 2      | ['b', 'c']    |
      | ['a', 'b', 'c'] | 0      | 3      | ['a', 'b', 'c'] |
