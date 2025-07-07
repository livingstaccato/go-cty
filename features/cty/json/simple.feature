# Original Go Test File: cty/json/simple_test.go
# This feature file covers tests for the SimpleJSONValue wrapper,
# which facilitates basic JSON marshaling/unmarshaling of cty.Value
# using Go's standard encoding/json package.

Feature: Simple JSON Value Marshaling and Unmarshaling
  This feature describes how cty.Value objects can be marshaled to and
  unmarshaled from JSON strings using the SimpleJSONValue wrapper.
  This wrapper provides a direct JSON representation without cty-specific
  type information for dynamic values.
  **Note:** cty value marks are NOT preserved during this SimpleJSONValue marshaling/unmarshaling process.

  Scenario Outline: Round-trip marshaling and unmarshaling of cty.Value via SimpleJSONValue
    # Covers test: TestSimpleJSONValue
    Given a cty.Value <InputValue> of type <InputCtyType>
    When the value is wrapped in SimpleJSONValue and marshaled to JSON
    Then the resulting JSON string should be "<ExpectedJSONString>"
    When this JSON string is unmarshaled back into a SimpleJSONValue
    Then the unwrapped cty.Value should be <ExpectedUnmarshaledValue> of type <ExpectedUnmarshaledCtyType>

    Examples: Primitive Types
      | InputValue  | InputCtyType | ExpectedJSONString | ExpectedUnmarshaledValue | ExpectedUnmarshaledCtyType |
      | Number(5)   | Number       | "5"                | Number(5)                | Number                     |
      | True        | Bool         | "true"             | True                     | Bool                       |
      | String("h") | String       | "\"h\""            | String("h")              | String                     |
      | Null(Bool)  | Bool         | "null"             | Null(DynamicType)        | DynamicType                | # Type is lost for null

    Examples: Collection Types
      | InputValue             | InputCtyType          | ExpectedJSONString         | ExpectedUnmarshaledValue    | ExpectedUnmarshaledCtyType |
      | Tuple(S("h"), True)    | Tuple(String,Bool)    | "[\"h\",true]"             | Tuple(S("h"), True)         | Tuple(String,Bool)         |
      | List(False, True)      | List(Bool)            | "[false,true]"             | Tuple(False, True)          | Tuple(Bool,Bool)           | # List unmarshals as Tuple
      | Set(False, True)       | Set(Bool)             | "[false,true]"             | Tuple(False, True)          | Tuple(Bool,Bool)           | # Set unmarshals as Tuple (order may vary in JSON but consistent in test)
      | Obj(true=T, greet=S("h"))| Object(true=B,greet=S)| "{\"greet\":\"h\",\"true\":true}" | Obj(true=T, greet=S("h")) | Object(true=B,greet=S)   | # Object keys sorted in JSON
      | Map(true=T, false=F)   | Map(Bool)             | "{\"false\":false,\"true\":true}" | Obj(false=F, true=T)        | Object(false=B,true=B)   | # Map unmarshals as Object, keys sorted

    # Note on Value/Type Syntax:
    # - InputValue: Number(5), True, String("h"), Null(Bool), Tuple(S("h"),True), List(F,T), Set(F,T), Obj(t=T,g=S("h")), Map(t=T,f=F)
    # - InputCtyType: Number, Bool, String, Tuple(String,Bool), List(Bool), Set(Bool), Object(true=B,greet=S), Map(Bool)
    # - ExpectedUnmarshaledValue: Similar to InputValue, but type may change (e.g. Null(DynamicType), Tuple for List/Set)
    # - ExpectedUnmarshaledCtyType: The cty.Type of the ExpectedUnmarshaledValue.
    # - S=String, B=Bool, T=True, F=False. Keys in objects/maps are strings.

  Scenario Outline: Marshaling Unknown or Dynamic cty.Values via SimpleJSONValue
    Given a cty.Value <InputValue> of type <InputCtyType>
    When the value is wrapped in SimpleJSONValue and marshaled to JSON
    Then the resulting JSON string should be "<ExpectedJSONString>"
    # Unmarshaling this specific JSON output might lead to Null(DynamicType) or error

    Examples:
      | InputValue         | InputCtyType | ExpectedJSONString | Description                                  |
      | Unknown(String)    | String       | "null"             | Unknown value marshals as JSON null          |
      | Dynamic            | DynamicType  | "null"             | Unknown DynamicVal marshals as JSON null       |
      | TrueAsDynamic      | DynamicType  | "true"             | Known DynamicVal marshals as its concrete JSON |
      | Null(String).AsDynamic() | DynamicType  | "null"         | Null DynamicVal marshals as JSON null        |

    # Note: The standard json.Marshal used by SimpleJSONValue might error on UnknownVal
    # if it cannot be represented as null. cty's default is to make unknown appear as null.
    # Unmarshaling "null" back via SimpleJSONValue will always result in NullVal(DynamicPseudoType).
