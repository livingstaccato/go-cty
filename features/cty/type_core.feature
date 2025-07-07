# Original Go Test File: cty/type_test.go
# This feature file covers core tests for cty.Type methods and properties.

Feature: cty Type Core Functionality
  This feature describes core functionalities of cty.Type objects,
  such as checking for dynamic types, removing optional attributes,
  and generating Go string representations.

  Scenario Outline: Checking if a type contains dynamic types (HasDynamicTypes)
    # Covers test: TestHasDynamicTypes
    Given a cty.Type <TypeToCheck>
    When its `HasDynamicTypes` status is checked
    Then the result should be <ExpectedHasDynamicStatus>

    Examples:
      | TypeToCheck                                  | ExpectedHasDynamicStatus |
      | DynamicType                                  | true                     |
      | List(DynamicType)                            | true                     |
      | Tuple([String, DynamicType])                 | true                     |
      | Object({"a":String, "unknown":DynamicType})  | true                     |
      | List(Object({"a":S, "unknown":DynamicType})) | true                     |
      | Tuple([Object({"a":S, "unknown":DynamicType})])| true                     |
      | String                                       | false                    |
      | List(String)                                 | false                    |
      | Object({"a":String})                         | false                    |

  Scenario Outline: Removing optional attributes deeply from a type (WithoutOptionalAttributesDeep)
    # Covers test: TestWithoutOptionalAttributesDeep
    Given a cty.Type <OriginalType>
    When `WithoutOptionalAttributesDeep` is called on it
    Then the resulting cty.Type should be <ExpectedTypeWithoutOptional>

    Examples:
      | OriginalType                                  | ExpectedTypeWithoutOptional                 |
      | DynamicType                                   | DynamicType                                 |
      | List(DynamicType)                             | List(DynamicType)                           |
      | Tuple([String, DynamicType])                  | Tuple([String, DynamicType])                |
      | Object({"a":S, "unknown":Dyn})                | Object({"a":S, "unknown":Dyn})              | # No optional attrs to remove
      | ObjectWithOpt({"a":S, "unknown":Dyn}, ["a"])  | Object({"a":S, "unknown":Dyn})              |
      | Map(ObjectWithOpt({"a":S, "unknown":Dyn}, ["a"])) | Map(Object({"a":S, "unknown":Dyn}))       |
      | Set(ObjectWithOpt({"a":S, "unknown":Dyn}, ["a"])) | Set(Object({"a":S, "unknown":Dyn}))       |
      | List(ObjectWithOpt({"a":S, "unknown":Dyn}, ["a"]))| List(Object({"a":S, "unknown":Dyn}))      |
      | Tuple([ObjectWithOpt({"a":S,"unknown":Dyn},["a"]), ObjectWithOpt({"b":N},["b"])]) | Tuple([Object({"a":S,"unknown":Dyn}), Object({"b":N})]) |

  Scenario: NilType equality
    # Covers test: TestNilTypeEquals
    Given a zero-value cty.Type instance "type_zero"
    And the cty.NilType constant "const_nil_type"
    When "type_zero" is compared for equality with "const_nil_type"
    Then the result should be true

  Scenario Outline: Go string representation of a cty.Type (GoString)
    # Covers test: TestTypeGoString
    Given a cty.Type <TypeInstance>
    When its `GoString()` representation is obtained
    Then the result should be the string "<ExpectedGoString>"

    Examples:
      | TypeInstance                             | ExpectedGoString                                                     |
      | DynamicType                              | "cty.DynamicPseudoType"                                              |
      | String                                   | "cty.String"                                                         |
      | Number                                   | "cty.Number"                                                         |
      | Bool                                     | "cty.Bool"                                                           |
      | List(String)                             | "cty.List(cty.String)"                                               |
      | List(List(String))                       | "cty.List(cty.List(cty.String))"                                     |
      | Set(Map(String))                         | "cty.Set(cty.Map(cty.String))"                                       |
      | Tuple([String, Bool])                    | "cty.Tuple([]cty.Type{cty.String, cty.Bool})"                        |
      | Object({"foo":Bool})                     | "cty.Object(map[string]cty.Type{\"foo\":cty.Bool})"                  | # Keys sorted
      | ObjectWithOpt({"b":Bool,"f":Str},["b"])   | "cty.ObjectWithOptionalAttrs(map[string]cty.Type{\"b\":cty.Bool, \"f\":cty.String}, []string{\"b\"})" | # Keys and optional attrs sorted

    # Note on Syntax:
    # - Types: String (S), Number (N), Bool (B), DynamicType (Dyn).
    # - List(T), Map(T), Set(T), Tuple([T1,T2]), Object({attr:T}), ObjectWithOpt({attr:T}, [opt_attr]).
    # - Str is used in ObjectWithOpt example for cty.String for brevity.
    # - GoString output includes "cty." package prefix. Attribute maps and optional attribute lists are sorted alphabetically.

  Scenario Outline: List Type introspection (IsListType, ListElementType)
    # Covers methods from cty/list_type.go
    Given a cty.Type <TypeInstance>
    When IsListType() is called on <TypeInstance>
    Then the result should be <IsList>
    When ListElementType() is called on <TypeInstance>
    Then the result should be <ElementType> or null if not a list

    Examples:
      | TypeInstance      | IsList | ElementType |
      | List(String)      | true   | String      |
      | List(Number)      | true   | Number      |
      | List(List(Bool))  | true   | List(Bool)  |
      | Map(String)       | false  | null        |
      | String            | false  | null        |
      | DynamicType       | false  | null        | # IsListType is false for DynamicPseudoType

  Scenario Outline: Map Type introspection (IsMapType, MapElementType)
    # Covers methods from cty/map_type.go
    Given a cty.Type <TypeInstance>
    When IsMapType() is called on <TypeInstance>
    Then the result should be <IsMap>
    When MapElementType() is called on <TypeInstance>
    Then the result should be <ElementType> or null if not a map

    Examples:
      | TypeInstance    | IsMap | ElementType |
      | Map(String)     | true  | String      |
      | Map(Number)     | true  | Number      |
      | Map(Map(Bool))  | true  | Map(Bool)   |
      | List(String)    | false | null        |
      | String          | false | null        |
      | DynamicType     | false | null        | # IsMapType is false for DynamicPseudoType

  Scenario Outline: Type Equality for List and Map Types (Type.Equals)
    # Covers cty.typeList.Equals and cty.typeMap.Equals
    Given a cty.Type LHS <LHSType>
    And a cty.Type RHS <RHSType>
    When <LHSType>.Equals(<RHSType>) is evaluated
    Then the result should be <ExpectedEquality>

    Examples: List Types
      | LHSType           | RHSType           | ExpectedEquality |
      | List(String)      | List(String)      | true             |
      | List(String)      | List(Number)      | false            |
      | List(String)      | Map(String)       | false            |
      | List(List(S))     | List(List(S))     | true             |
      | List(List(S))     | List(List(N))     | false            |
      | List(DynamicType) | List(DynamicType) | true             |
      | List(DynamicType) | List(String)      | false            |

    Examples: Map Types
      | LHSType         | RHSType         | ExpectedEquality |
      | Map(String)     | Map(String)     | true             |
      | Map(String)     | Map(Number)     | false            |
      | Map(String)     | List(String)    | false            |
      | Map(Map(S))     | Map(Map(S))     | true             |
      | Map(Map(S))     | Map(Map(N))     | false            |
      | Map(DynamicType)| Map(DynamicType)| true             |
      | Map(DynamicType)| Map(String)     | false            |
