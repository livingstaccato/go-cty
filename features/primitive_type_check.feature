# Covers tests in cty/primitive_type_test.go

Feature: Primitive Type Check
  Background:
    Given a Go environment

  Scenario Outline: Check if a cty.Type is a primitive type
    Given a cty.Type <type>
    When I check if the type is a primitive type
    Then the result should be <isPrimitive>

    Examples:
      | type               | isPrimitive |
      | String             | True        |
      | Number             | True        |
      | Bool               | True        |
      | Dynamic            | False       |
      | List(String)       | False       |
      | TypeOf(True)       | True        |
      | TypeOf(False)      | True        |
      | TypeOf(Zero)       | True        |
      | TypeOf(PosInfinity)| True        |
      | TypeOf(NegInfinity)| True        |
