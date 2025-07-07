# Covers tests in cty/capsule_test.go

Feature: Capsule Type
  Background:
    Given a Go environment

  Scenario: Capsule with Operations
    Given a capsule type "with ops" for integer type with custom operations:
      | Operation    | Implementation                                  |
      | GoString     | returns "test.WithOpsVal(%#v)" for the value    |
      | TypeGoString | returns "test.WithOps(%s)" for the type         |
      | Equals       | returns true if integer values are equal        |
      | RawEquals    | returns true if integer values are equal        |
    And a capsule value "v" of type "with ops" with integer value 0
    And a capsule value "v2" of type "with ops" with integer value 0
    And a capsule value "v3" of type "with ops" with integer value 1
    When I get the GoString of "v"
    Then the result should be "test.WithOpsVal(0)"
    When I get the TypeGoString of type "with ops"
    Then the result should be "test.WithOps(int)"
    When I check if "v" equals "v2"
    Then the result should be true
    When I check if "v" equals "v3"
    Then the result should be false

  Scenario: Capsule without Operations
    Given a capsule type "without ops" for integer type
    And a capsule value "v" of type "without ops" with integer value 0
    And a capsule value "v2" of type "without ops" with integer value 0
    When I get the GoString of "v"
    Then the result should be "cty.CapsuleVal(cty.Capsule(\"without ops\", reflect.TypeOf(0)), (*int)(0x...))"
    When I get the TypeGoString of type "without ops"
    Then the result should be "cty.Capsule(\"without ops\", reflect.TypeOf(0))"
    When I check if "v" equals "v2"
    Then the result should be false
    When I check if "v" RawEquals "v2"
    Then the result should be false

  Scenario: Capsule Extension Data
    Given a capsule type "with extension data" for integer type with custom operations:
      | Operation     | Implementation                                               |
      | ExtensionData | returns "world" for key "hello", otherwise returns nil       |
    When I get the capsule extension data for key "hello" from type "with extension data"
    Then the result should be "world"
    When I get the capsule extension data for key "nonexistent" from type "with extension data"
    Then the result should be nil
    Given a capsule type "without extension data" for integer type
    When I get the capsule extension data for key "hello" from type "without extension data"
    Then the result should be nil
