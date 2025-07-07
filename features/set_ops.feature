# Covers tests in cty/set/ops_test.go

Feature: Set Operations
  Background:
    Given a Go environment with test set rules

  Scenario: Basic Set Operations (Add, Has, Remove, EachValue)
    Given an empty Set "s" of integers
    Then the internal values of "s" should be an empty map

    When I add the integer 1 to "s"
    Then the internal values of "s" should be {1:[1]}
    And "s" should contain 1

    When I add the integer 2 to "s"
    Then the internal values of "s" should be {1:[1], 2:[2]}
    And "s" should contain 2

    Then "s" should not contain 17
    When I add the integer 17 to "s"
    And I add the integer 33 to "s" # 17 and 33 hash to the same bucket as 1
    Then the internal values of "s" should be {1:[1,17,33], 2:[2]} # Order in bucket list may vary
    And "s" should contain 17
    And "s" should contain 33

    When I iterate over "s" and collect values into "iterated_values"
    Then "iterated_values" (sorted) should be [1, 2, 17, 33]

    When I remove 2 from "s"
    Then the internal values of "s" should be {1:[1,17,33]}

    When I remove 17 from "s"
    Then the internal values of "s" should be {1:[1,33]} # Order in bucket list may vary

    When I remove 1 from "s"
    Then the internal values of "s" should be {1:[33]}

    When I remove 33 from "s"
    Then the internal values of "s" should be an empty map

    When I iterate over "s" and collect values into "empty_iterated_values"
    Then "empty_iterated_values" should be empty

  Scenario Outline: Set Union
    Given Set "s1" with integer values <s1_values>
    And Set "s2" with integer values <s2_values>
    When I compute the union of "s1" and "s2" into "result_set"
    Then the sorted values of "result_set" should be <expected_union>

    Examples:
      | s1_values | s2_values | expected_union   |
      | []        | []        | []               |
      | [1]       | []        | [1]              |
      | [1]       | [2]       | [1,2]            |
      | [1]       | [1]       | [1]              |
      | [17,33]   | [1]       | [1,17,33]        |
      | [17,33]   | [2,1]     | [1,2,17,33]      |

  Scenario Outline: Set Intersection
    Given Set "s1" with integer values <s1_values>
    And Set "s2" with integer values <s2_values>
    When I compute the intersection of "s1" and "s2" into "result_set"
    Then the sorted values of "result_set" should be <expected_intersection>

    Examples:
      | s1_values | s2_values | expected_intersection |
      | []        | []        | []                    |
      | [1]       | []        | []                    |
      | [1]       | [2]       | []                    |
      | [1]       | [1]       | [1]                   |
      | [1,17]    | [1,2,3]   | [1]                   |
      | [3,2,1]   | [1,2,3]   | [1,2,3]               |
      | [17,33]   | [1]       | []                    |
      | [17,33]   | [2,1]     | []                    |

  Scenario Outline: Set Subtraction
    Given Set "s1" with integer values <s1_values>
    And Set "s2" with integer values <s2_values>
    When I subtract "s2" from "s1" into "result_set"
    Then the sorted values of "result_set" should be <expected_difference>

    Examples:
      | s1_values | s2_values | expected_difference |
      | []        | []        | []                  |
      | [1]       | []        | [1]                 |
      | [1]       | [2]       | [1]                 |
      | [1]       | [1]       | []                  |
      | [1,17]    | [1,2,3]   | [17]                |
      | [3,2,1]   | [1,2,3]   | []                  |
      | [17,33]   | [1]       | [17,33]             |
      | [17,33]   | [2,1]     | [17,33]             |

  Scenario Outline: Set Symmetric Difference
    Given Set "s1" with integer values <s1_values>
    And Set "s2" with integer values <s2_values>
    When I compute the symmetric difference of "s1" and "s2" into "result_set"
    Then the sorted values of "result_set" should be <expected_sym_difference>

    Examples:
      | s1_values | s2_values | expected_sym_difference |
      | []        | []        | []                      |
      | [1]       | []        | [1]                     |
      | [1]       | [2]       | [1,2]                   |
      | [1]       | [1]       | []                      |
      | [1,17]    | [1,2,3]   | [2,3,17]                |
      | [3,2,1]   | [1,2,3]   | []                      |
      | [17,33]   | [1]       | [1,17,33]               |
      | [17,33]   | [2,1]     | [1,2,17,33]             |
