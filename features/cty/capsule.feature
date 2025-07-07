# Original Go Test File: cty/capsule_test.go
# This feature file covers the test cases found in cty/capsule_test.go.

Feature: Capsule Type Behavior
  Tests the functionality of cty Capsule types, including those with
  custom operations (CapsuleOps) and extension data.

  Scenario: Capsule with custom operations
    # Covers test: TestCapsuleWithOps
    # Sub-test: "with ops"
    Given a capsule type "with_ops_capsule" is defined for Go type "int" with custom operations:
      | Operation    | CustomLogic                                   |
      | GoString     | returns "test.WithOpsVal(<value>)"            |
      | TypeGoString | returns "test.WithOps(<go_type_name>)"        |
      | Equals       | compares underlying int values for equality   |
      | RawEquals    | compares underlying int values for equality   |
    And an integer variable "i1" with value 0
    And an integer variable "i2" with value 0
    And an integer variable "i3" with value 1
    When a capsule value "capVal1" is created from "with_ops_capsule" and "i1"
    And a capsule value "capVal2" is created from "with_ops_capsule" and "i2"
    And a capsule value "capVal3" is created from "with_ops_capsule" and "i3"
    Then the GoString representation of "capVal1" should be "test.WithOpsVal(0)"
    And the TypeGoString representation of "with_ops_capsule" should be "test.WithOps(int)"
    And "capVal1" should be Equal to "capVal2"
    And "capVal1" should not be Equal to "capVal3"

  Scenario: Capsule without custom operations
    # Covers test: TestCapsuleWithOps
    # Sub-test: "without ops"
    Given a capsule type "no_ops_capsule" is defined for Go type "int" without custom operations
    And an integer variable "i1_no_ops" with value 0
    And an integer variable "i2_no_ops" with value 0
    When a capsule value "capVal1_no_ops" is created from "no_ops_capsule" and "i1_no_ops"
    And a capsule value "capVal2_no_ops" is created from "no_ops_capsule" and "i2_no_ops"
    Then the GoString representation of "capVal1_no_ops" should be the default cty representation for a capsule of "no_ops_capsule" encapsulating "i1_no_ops"
    And the TypeGoString representation of "no_ops_capsule" should be the default cty type representation for "no_ops_capsule"
    And "capVal1_no_ops" should not be Equal to "capVal2_no_ops"
    And "capVal1_no_ops" should not be RawEqualTo "capVal2_no_ops"

  Scenario: Capsule with extension data
    # Covers test: TestCapsuleExtensionData
    Given a capsule type "ext_data_capsule" for Go type "int" with custom operations providing extension data:
      | Key     | Value   |
      | "hello" | "world" |
    When extension data for key "hello" is retrieved from type "ext_data_capsule"
    Then the result should be the string "world"
    When extension data for key "nonexistent" is retrieved from type "ext_data_capsule"
    Then the result should be nil

  Scenario: Capsule without extension data support
    # Covers test: TestCapsuleExtensionData
    Given a capsule type "no_ext_data_capsule" for Go type "int" is defined without custom operations supporting extension data
    When extension data for key "hello" is retrieved from type "no_ext_data_capsule"
    Then the result should be nil
