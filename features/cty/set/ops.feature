# Original Go Test File: cty/set/ops_test.go
# This feature file covers tests for the internal cty/set.Set data structure operations.
# It uses a specific 'testRules' for integers where Hash(val) = val % 16.

Feature: Internal Set Data Structure Operations
  This feature describes the behavior of the internal Set data structure,
  focusing on its fundamental operations and set theory operations like
  union, intersection, subtraction, and symmetric difference.
  These tests use integer elements with custom hashing rules (val % 16).

  Background:
    Given an internal Set implementation using 'testRules' for integers (hash is value % 16)

  Scenario: Basic Set Operations (Add, Has, Remove, EachValue)
    # Covers test: TestBasicSetOps
    Given an empty integer Set "s"
    Then "s" should be empty
    When 1 is Added to "s"
    Then "s" should contain 1
    And "s" should have 1 element
    When 2 is Added to "s"
    Then "s" should contain 1
    And "s" should contain 2
    And "s" should have 2 elements

    # Test hash collision (1, 17, 33 all hash to 1 with testRules)
    When 17 is Added to "s"
    And 33 is Added to "s"
    Then "s" should contain 1
    And "s" should contain 2
    And "s" should contain 17
    And "s" should contain 33
    And "s" should have 4 elements
    And iterating over "s" using EachValue should yield elements [1, 2, 17, 33] (order may vary before sort)

    When 2 is Removed from "s"
    Then "s" should not contain 2
    And "s" should have 3 elements
    When 17 is Removed from "s"
    Then "s" should not contain 17
    And "s" should have 2 elements (1, 33 remaining in hash bucket 1)
    When 1 is Removed from "s"
    Then "s" should not contain 1
    And "s" should have 1 element (33 remaining in hash bucket 1)
    When 33 is Removed from "s"
    Then "s" should not contain 33
    And "s" should be empty
    And iterating over "s" using EachValue should yield no elements

  Scenario Outline: Set Union Operation
    # Covers test: TestUnion
    Given integer Set "s1" with elements <Set1Elements>
    And integer Set "s2" with elements <Set2Elements>
    When the Union of "s1" and "s2" is computed into "s_union"
    Then "s_union" should contain exactly the elements <ExpectedUnionElements> (order irrelevant)

    Examples:
      | Set1Elements | Set2Elements | ExpectedUnionElements |
      | []           | []           | []                    |
      | [1]          | []           | [1]                   |
      | [1]          | [2]          | [1, 2]                |
      | [1]          | [1]          | [1]                   |
      | [17, 33]     | [1]          | [1, 17, 33]           | # Hash collision check
      | [17, 33]     | [2, 1]       | [1, 2, 17, 33]        |

  Scenario Outline: Set Intersection Operation
    # Covers test: TestIntersection
    Given integer Set "s1" with elements <Set1Elements>
    And integer Set "s2" with elements <Set2Elements>
    When the Intersection of "s1" and "s2" is computed into "s_intersection"
    Then "s_intersection" should contain exactly the elements <ExpectedIntersectionElements> (order irrelevant)

    Examples:
      | Set1Elements | Set2Elements | ExpectedIntersectionElements |
      | []           | []           | []                           |
      | [1]          | []           | []                           |
      | [1]          | [2]          | []                           |
      | [1]          | [1]          | [1]                          |
      | [1, 17]      | [1, 2, 3]    | [1]                          |
      | [3, 2, 1]    | [1, 2, 3]    | [1, 2, 3]                    |
      | [17, 33]     | [1]          | []                           | # Hash collision check

  Scenario Outline: Set Subtraction Operation (s1 - s2)
    # Covers test: TestSubtract
    Given integer Set "s1" with elements <Set1Elements>
    And integer Set "s2" with elements <Set2Elements>
    When Set "s2" is Subtracted from "s1" into "s_diff"
    Then "s_diff" should contain exactly the elements <ExpectedDifferenceElements> (order irrelevant)

    Examples:
      | Set1Elements | Set2Elements | ExpectedDifferenceElements |
      | []           | []           | []                         |
      | [1]          | []           | [1]                        |
      | [1]          | [2]          | [1]                        |
      | [1]          | [1]          | []                         |
      | [1, 17]      | [1, 2, 3]    | [17]                       |
      | [3, 2, 1]    | [1, 2, 3]    | []                         |
      | [17, 33]     | [1]          | [17, 33]                   | # Hash collision check

  Scenario Outline: Set Symmetric Difference Operation
    # Covers test: TestSymmetricDifference
    Given integer Set "s1" with elements <Set1Elements>
    And integer Set "s2" with elements <Set2Elements>
    When the Symmetric Difference of "s1" and "s2" is computed into "s_sym_diff"
    Then "s_sym_diff" should contain exactly the elements <ExpectedSymDiffElements> (order irrelevant)

    Examples:
      | Set1Elements | Set2Elements | ExpectedSymDiffElements |
      | []           | []           | []                      |
      | [1]          | []           | [1]                     |
      | [1]          | [2]          | [1, 2]                  |
      | [1]          | [1]          | []                      |
      | [1, 17]      | [1, 2, 3]    | [2, 3, 17]              |
      | [3, 2, 1]    | [1, 2, 3]    | []                      |
      | [17, 33]     | [1]          | [1, 17, 33]             | # Hash collision check

    # Note on Element List Syntax:
    # - [1, 2, 3] represents a list of integers.
    # - [] represents an empty list.
    # - The "order irrelevant" parenthetical means the Gherkin step should verify set membership, not list order.
    # - "s should be empty" means s.Length() == 0.
    # - "s should have X elements" means s.Length() == X.
