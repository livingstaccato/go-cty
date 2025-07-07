# Covers tests in cty/set_type_test.go

Feature: Set Type and Operations
  Background:
    Given a Go environment

  Scenario: Set union operation via AsValueSet
    Given a cty.Set value "s1" with string elements ["a", "b", "c"]
    And a cty.Set value "s2" with string elements ["c", "d", "e"]
    When I get the underlying ValueSet "vs1" from "s1"
    And I get the underlying ValueSet "vs2" from "s2"
    And I compute the union of "vs1" and "vs2" into ValueSet "vs3"
    And I create a new cty.Set value "s3" from ValueSet "vs3"
    Then the length of "s3" should be 5
    And "s3" should contain element "a"
    And "s3" should contain element "b"
    And "s3" should contain element "c"
    And "s3" should contain element "d"
    And "s3" should contain element "e"

  Scenario Outline: Creating a set of capsule type values
    Given a capsule type <capsuleTypeDescription> named "ct" for Go type "capsuleTypeForSetTests" with name field
    And a list of Go "capsuleTypeForSetTests" values <capsuleInstances> to create cty.Capsule values
    When I create a cty.Set of type Set("ct") from these capsule values
    Then the sorted names of the encapsulated values in the set should be <expectedNames>

    Examples: Capsule with HashKey and RawEquals
      | capsuleTypeDescription              | capsuleInstances                                           | expectedNames   |
      | "with hash function" with HashKey and RawEquals on name | [{"name":"a"}, {"name":"b"}, {"name":"a"}, {"name":"c"}] | ["a", "b", "c"] |

    Examples: Capsule with RawEquals only
      | capsuleTypeDescription              | capsuleInstances                                           | expectedNames   |
      | "without hash function" with RawEquals on name | [{"name":"a"}, {"name":"b"}, {"name":"a"}, {"name":"c"}] | ["a", "b", "c"] |

    Examples: Capsule with default (pointer equality)
      | capsuleTypeDescription              | capsuleInstances                                                                                                | expectedNames         |
      | "without equals" (default behavior) | [{"name":"a"}, {"name":"b"}, {"name":"d" (ref "d_ref")}, {"name":"a"}, {"name":"c"}, {"name":"d" (ref "d_ref")}] | ["a", "a", "b", "c", "d"] |
