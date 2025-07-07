# Original Go Test File: cty/primitive_type_test.go
# This feature file covers tests for identifying cty primitive types.

Feature: cty Primitive Type Identification
  This feature describes how to identify whether a given cty.Type
  is one of the primitive types (String, Number, Bool).

  Scenario Outline: Checking if a cty.Type is a primitive type
    # Covers test: TestTypeIsPrimitiveType
    Given a cty.Type <Type>
    When its `IsPrimitiveType` status is checked
    Then the result should be <IsPrimitive>

    Examples:
      | Type                     | IsPrimitive |
      | String                   | true        |
      | Number                   | true        |
      | Bool                     | true        |
      | DynamicType              | false       |
      | List(String)             | false       |
      | TypeOf(cty.True)         | true        | # Type of True is Bool
      | TypeOf(cty.False)        | true        | # Type of False is Bool
      | TypeOf(cty.Zero)         | true        | # Type of Zero is Number
      | TypeOf(cty.PositiveInfinity) | true    | # Type of PositiveInfinity is Number
      | TypeOf(cty.NegativeInfinity) | true    | # Type of NegativeInfinity is Number

    # Note on Syntax:
    # - String, Number, Bool, DynamicType, List(String) are cty types.
    # - TypeOf(cty.Value) refers to calling .Type() on a cty.Value constant.
