# Original Go Test File: cty/type_conform_test.go
# This feature file covers tests for cty.Type.TestConformance method.

Feature: cty Type Conformance Testing
  This feature describes how one cty.Type (Given) is tested for conformance
  to another cty.Type (Receiver). Conformance means the Given type can be
  safely used where the Receiver type is expected, without needing conversions
  that might fail or lose information. It's stricter than simple convertibility.

  Scenario Outline: Testing type conformance
    # Covers test: TestTypeTestConformance
    Given a Receiver cty.Type <ReceiverType>
    And a Given cty.Type <GivenType>
    When the conformance of GivenType to ReceiverType is tested
    Then the result should indicate that conformance is <IsConformant>
    And if not conformant, specific path errors should be reported (details omitted for Gherkin brevity)

    Examples: Primitive Types
      | ReceiverType | GivenType   | IsConformant |
      | Number       | Number      | true         |
      | Number       | String      | false        |
      | Number       | DynamicType | true         | # DynamicType can conform to a concrete type
      | DynamicType  | DynamicType | true         |
      | DynamicType  | Number      | false        | # Concrete type cannot conform to DynamicType (it's more specific)

    Examples: List Types
      | ReceiverType    | GivenType           | IsConformant |
      | List(Number)    | List(Number)        | true         |
      | List(Number)    | Map(Number)         | false        | # Different collection kind
      | List(Number)    | List(DynamicType)   | true         | # List of Dynamic can conform to List of Concrete
      | List(Number)    | List(String)        | false        | # Different element type

    Examples: Map Types
      | ReceiverType  | GivenType         | IsConformant |
      | Map(Number)   | Map(Number)       | true         |
      | Map(Number)   | Set(Number)       | false        | # Different collection kind
      | Map(Number)   | Map(DynamicType)  | true         |
      | Map(Number)   | Map(String)       | false        | # Different element type

    Examples: Set Types
      | ReceiverType  | GivenType         | IsConformant |
      | Set(Number)   | Set(Number)       | true         |
      | Set(Number)   | List(Number)      | false        | # Different collection kind
      | Set(Number)   | Set(DynamicType)  | true         |
      | Set(Number)   | Set(String)       | false        | # Different element type

    Examples: Object Types
      | ReceiverType                   | GivenType                      | IsConformant |
      | EmptyObject                    | EmptyObject                    | true         |
      | EmptyObject                    | Object({"name":S})             | false        | # Given has more attributes
      | Object({"name":S})             | EmptyObject                    | false        | # Given is missing attributes
      | Object({"name":S})             | Object({"name":S})             | true         |
      | Object({"name":S})             | Object({"gnome":S})            | false        | # Different attribute names
      | Object({"name":N})             | Object({"name":S})             | false        | # Different attribute type
      | Object({"name":N})             | Object({"name":S,"num":N})     | false        | # Attr type mismatch and extra attr
      | ObjectWithOpt({"name":N},["name"]) | Object({"name":N})          | true         | # Object conforms to ObjectWithOpt if attrs match
      | ObjectWithOpt({"name":N},["name"]) | EmptyObject                 | false        | # Optionality not considered for missing required attrs in conformance

    Examples: Tuple Types
      | ReceiverType        | GivenType           | IsConformant |
      | EmptyTuple          | EmptyTuple          | true         |
      | EmptyTuple          | Tuple([String])     | false        | # Different length
      | Tuple([String])     | EmptyTuple          | false        | # Different length
      | Tuple([String])     | Tuple([String])     | true         |
      | Tuple([String])     | Tuple([Number])     | false        | # Different element type
      | Tuple([S,N])        | Tuple([S,N])        | true         |
      | Tuple([String])     | Tuple([S,N])        | false        | # Different length
      | Tuple([S,N])        | Tuple([String])     | false        | # Different length

    # Note on Type Syntax:
    # - Number, String, Bool, DynamicType, EmptyObject, EmptyTuple are cty types.
    # - List(T), Map(T), Set(T) for collections of type T.
    # - Object({attr:Type, ...}) for object types. S=String, N=Number.
    # - ObjectWithOpt({attr:Type,...}, [optAttr,...]) for objects with optional attributes.
    # - Tuple([Type1, Type2,...]) for tuple types.
    # - IsConformant is true if TestConformance returns nil (no errors).
