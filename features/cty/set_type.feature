# Original Go Test File: cty/set_type_test.go
# This feature file covers tests related to cty.SetType and its interaction
# with the underlying set.Set implementation, particularly for capsule types.

Feature: cty Set Type Operations and Capsule Handling
  This feature describes how cty.SetVal values are created and behave,
  especially when containing capsule types with custom equality and hashing.
  It also covers the mechanism for using the underlying set.Set for custom operations.

  Scenario: Set operations using AsValueSet and SetValFromValueSet
    # Covers test: TestSetOperations
    Given a cty.SetVal "s1" with string elements ["a", "b", "c"]
    And a cty.SetVal "s2" with string elements ["c", "d", "e"]
    When "s1_raw" is obtained from "s1.AsValueSet()"
    And "s2_raw" is obtained from "s2.AsValueSet()"
    And "s3_raw" is computed as the Union of "s1_raw" and "s2_raw"
    And "s3_cty" is created using "SetValFromValueSet(s3_raw)"
    Then "s3_cty" should be a cty.SetVal of element type String
    And "s3_cty" should have a length of 5
    And "s3_cty" should contain the string element "a"
    And "s3_cty" should contain the string element "b"
    And "s3_cty" should contain the string element "c"
    And "s3_cty" should contain the string element "d"
    And "s3_cty" should contain the string element "e"

  Scenario Outline: Creating a Set of Capsule Types with different CapsuleOps
    # Covers test: TestSetOfCapsuleType
    Given a cty.CapsuleType "<CapsuleTypeName>" for Go type "capsuleStructForSetTests"
    And this capsule type is defined with <CapsuleOpsDefinition>
    And a list of Go "capsuleStructForSetTests" instances:
      | instance_name | struct_field_name_value |
      | "inst_a1"     | "a"                     |
      | "inst_b1"     | "b"                     |
      | "inst_a2"     | "a"                     | # Same field value as inst_a1
      | "inst_c1"     | "c"                     |
      | "ptr_d1"      | "d"                     | # This will be a pointer
      | "ptr_d2"      | "d"                     | # This will be the same pointer as ptr_d1
    When a cty.SetVal is created from these capsule instances using "<CapsuleTypeName>"
    Then the resulting set should contain capsule elements whose underlying "name" fields are <ExpectedNamesInSet> (order irrelevant)
    And the length of the set should be <ExpectedLength>

    Examples:
      | CapsuleTypeName         | CapsuleOpsDefinition                                  | ExpectedNamesInSet | ExpectedLength |
      | "typeWithHash"          | HashKey based on "name", RawEquals based on "name"    | ["a", "b", "c"]    | 3              |
      | "typeWithoutHash"       | No HashKey, RawEquals based on "name"                 | ["a", "b", "c"]    | 3              |
      | "typeWithoutEquals"     | No HashKey, No RawEquals (uses pointer identity)      | ["a", "a", "b", "c", "d"] | 5           | # inst_a1 and inst_a2 are distinct, ptr_d1 and ptr_d2 coalesce

    # Note on Capsule Test Details:
    # - "capsuleStructForSetTests" is a Go struct like: type capsuleTypeForSetTests struct { name string }
    # - For "typeWithoutEquals", ptr_d1 and ptr_d2 refer to the *same* Go pointer instance of capsuleStructForSetTests{name:"d"},
    #   while inst_a1 and inst_a2 are different Go instances that happen to have the same "name" field value.
