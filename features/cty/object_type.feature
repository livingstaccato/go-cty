# Original Go Test File: cty/object_type_test.go
# This feature file covers tests for cty.ObjectType equality.

Feature: cty Object Type Equality
  This feature describes how cty Object types (typeObject instances)
  are compared for equality using the Equals method.

  Scenario Outline: Comparing two cty Object types for equality
    # Covers test: TestObjectTypeEquals
    Given a cty.ObjectType LHS defined with attributes <LHSAttributes> and optional attributes <LHSOptionalAttributes>
    And a cty.Type RHS defined as <RHSTypeString> with attributes <RHSAttributes> and optional attributes <RHSOptionalAttributes>
    When LHS.Equals(RHS) is checked
    Then the result should be <ExpectedEquality>

    Examples: Basic Object Equality
      | LHSAttributes               | LHSOptionalAttributes | RHSTypeString | RHSAttributes               | RHSOptionalAttributes | ExpectedEquality |
      | {}                          | []                    | ObjectType    | {}                          | []                    | true             |
      | {"name": String}            | []                    | ObjectType    | {"name": String}            | []                    | true             |
      | {"h\u00e9llo": String}     | []                    | ObjectType    | {"he\u0301llo": String}     | []                    | true             | # Unicode normalization for attr names
      | {"person": Obj(name=S)}     | []                    | ObjectType    | {"person": Obj(name=S)}     | []                    | true             | # Nested objects

    Examples: Object Inequality
      | LHSAttributes               | LHSOptionalAttributes | RHSTypeString | RHSAttributes               | RHSOptionalAttributes | ExpectedEquality |
      | {"name": String}            | []                    | ObjectType    | {}                          | []                    | false            | # Different attribute count
      | {"name": String}            | []                    | ObjectType    | {"name": Number}            | []                    | false            | # Different attribute type
      | {"name": String}            | []                    | ObjectType    | {"nombre": String}          | []                    | false            | # Different attribute name
      | {"name": String}            | []                    | ObjectType    | {"name": S, "age": N}       | []                    | false            | # RHS has extra attribute
      | {"person": Obj(name=S)}     | []                    | ObjectType    | {"person": Obj(name=S,age=N)}| []                    | false            | # Nested object differs

    Examples: Objects with Optional Attributes
      | LHSAttributes               | LHSOptionalAttributes | RHSTypeString | RHSAttributes               | RHSOptionalAttributes | ExpectedEquality |
      | {"person": Bool}            | ["person"]            | ObjectWithOpt | {"person": Bool}            | ["person"]            | true             |
      | {"person": Obj(name=S)}     | []                    | ObjectType    | {"person": Bool}            | ["person"]            | false            | # Object vs ObjectWithOpt
      | {"person": Bool}            | ["person"]            | ObjectWithOpt | {"person": Obj(name=S)}     | []                    | false            | # ObjectWithOpt vs Object
      | {"person": Bool}            | ["person"]            | ObjectWithOpt | {"person": Bool}            | []                    | false            | # Different optional attribute sets

    # Note on Syntax:
    # - Attributes are represented as { "attrName": Type, ... }
    # - OptionalAttributes are a list of attribute names, e.g., ["attr1", "attr2"] or [] for none.
    # - Types: String (S), Number (N), Bool (B). Obj(name=S) is shorthand for an Object type.
    # - RHSTypeString indicates if RHS is a plain ObjectType or ObjectWithOptionalAttrs for clarity.
    # - Unicode attribute names like "h\u00e9llo" (precombined) and "he\u0301llo" (combining accent) are tested for normalization.
