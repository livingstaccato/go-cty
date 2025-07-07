# Original Go Test File: cty/json/value_test.go
# This feature file covers tests for the main cty/json.Marshal and cty/json.Unmarshal functions.

Feature: cty.Value JSON Marshaling and Unmarshaling
  This feature describes how cty.Value objects are marshaled to JSON
  and unmarshaled from JSON using a specified cty.Type. This allows
  for type-aware serialization, including handling of cty.DynamicPseudoType
  by embedding type information in the JSON.

  Scenario Outline: Round-trip marshaling and unmarshaling of cty.Value
    # Covers test: TestValueJSONable
    Given a cty.Value <InputValue> of cty type <InputValueType>
    And a target cty.Type <TargetCtyType> for marshaling and unmarshaling
    When the value is marshaled to JSON using the target type
    Then the resulting JSON string should be "<ExpectedJSONString>"
    When this JSON string is unmarshaled back using the target type
    Then the resulting cty.Value should be <ExpectedUnmarshaledValue> of type <ExpectedUnmarshaledCtyType>

    Examples: Primitive Types
      | InputValue    | InputValueType | TargetCtyType | ExpectedJSONString | ExpectedUnmarshaledValue | ExpectedUnmarshaledCtyType |
      | String("h")   | String         | String        | "\"h\""            | String("h")              | String                     |
      | String("")    | String         | String        | "\"\""             | String("")               | String                     |
      | String("15")  | String         | Number        | "15"               | Number(15)               | Number                     | # String to Number
      | String("true")| String         | Bool          | "true"             | True                     | Bool                       | # String to Bool
      | Null(String)  | String         | String        | "null"             | Null(String)             | String                     |
      | Number(2)     | Number         | Number        | "2"                | Number(2)                | Number                     |
      | Number(2.5)   | Number         | Number        | "2.5"              | Number(2.5)              | Number                     |
      | Number(5)     | Number         | String        | "\"5\""            | String("5")              | String                     | # Number to String
      | True          | Bool           | Bool          | "true"             | True                     | Bool                       |
      | True          | Bool           | String        | "\"true\""         | String("true")           | String                     | # Bool to String

    Examples: Collection Types (List, Set, Tuple)
      | InputValue          | InputValueType      | TargetCtyType    | ExpectedJSONString | ExpectedUnmarshaledValue | ExpectedUnmarshaledCtyType |
      | List(True, False)   | List(Bool)          | List(Bool)       | "[true,false]"     | List(True, False)        | List(Bool)                 |
      | EmptyList(Bool)     | List(Bool)          | List(Bool)       | "[]"               | EmptyList(Bool)          | List(Bool)                 |
      | List(True, False)   | List(Bool)          | List(String)     | "[\"true\",\"false\"]" | List(S("t"),S("f"))    | List(String)               |
      | Set(True, False)    | Set(Bool)           | Set(Bool)        | "[false,true]"     | Set(True, False)         | Set(Bool)                  | # Set order in JSON sorted
      | EmptySet(Bool)      | Set(Bool)           | Set(Bool)        | "[]"               | EmptySet(Bool)           | Set(Bool)                  |
      | Tuple(True, Num(5)) | Tuple(Bool,Number)  | Tuple(Bool,Num)  | "[true,5]"         | Tuple(True, Num(5))      | Tuple(Bool,Number)         |
      | EmptyTupleVal       | EmptyTuple          | EmptyTuple       | "[]"               | EmptyTupleVal            | EmptyTuple                 |

    Examples: Map and Object Types
      | InputValue                | InputValueType        | TargetCtyType       | ExpectedJSONString        | ExpectedUnmarshaledValue      | ExpectedUnmarshaledCtyType  |
      | EmptyMap(Bool)            | Map(Bool)             | Map(Bool)           | "{}"                      | EmptyMap(Bool)                | Map(Bool)                   |
      | Map("yes"=T,"no"=F)       | Map(Bool)             | Map(Bool)           | "{\"no\":false,\"yes\":true}"| Map("yes"=T,"no"=F)         | Map(Bool)                   | # Map keys sorted
      | Null(Map(Bool))           | Map(Bool)             | Map(Bool)           | "null"                    | Null(Map(Bool))               | Map(Bool)                   |
      | EmptyObjectVal            | EmptyObject           | EmptyObject         | "{}"                      | EmptyObjectVal                | EmptyObject                 |
      | Obj(b=T,n=Zero)           | Object(b=B,n=N)       | Object(b=B,n=N)     | "{\"bool\":true,\"number\":0}"| Obj(b=T,n=Zero)             | Object(b=B,n=N)             |

    Examples: Capsule Type (e.g., "bytes" type)
      | InputValue                | InputValueType        | TargetCtyType         | ExpectedJSONString | ExpectedUnmarshaledValue    | ExpectedUnmarshaledCtyType |
      | BytesCapsule("hello")     | BytesCapsuleType      | BytesCapsuleType      | "\"aGVsbG8=\""     | BytesCapsule("hello")       | BytesCapsuleType           | # Base64 encoded

    Examples: DynamicPseudoType Target (includes type information)
      | InputValue          | InputValueType      | TargetCtyType    | ExpectedJSONString                      | ExpectedUnmarshaledValue | ExpectedUnmarshaledCtyType |
      | True                | Bool                | DynamicType      | "{\"value\":true,\"type\":\"bool\"}"      | True                     | Bool                       |
      | String("h")         | String              | DynamicType      | "{\"value\":\"h\",\"type\":\"string\"}"   | String("h")              | String                       |
      | Number(5)           | Number              | DynamicType      | "{\"value\":5,\"type\":\"number\"}"       | Number(5)                | Number                       |
      | List(True,False)    | List(Bool)          | DynamicType      | "{\"value\":[true,false],\"type\":[\"list\",\"bool\"]}" | List(True,False)       | List(Bool)                 |
      | List(True,False)    | List(Bool)          | List(DynamicType)| "[{\"value\":true,\"type\":\"bool\"},{\"value\":false,\"type\":\"bool\"}]" | List(True,False) | List(Bool)           |
      | Obj(s=T,d=T)        | Object(s=B,d=B)     | Object(s=B,d=Dyn)| "{\"dynamic\":{\"value\":true,\"type\":\"bool\"},\"static\":true}" | Obj(s=T,d=T) | Object(s=B,d=B)      |
      | Obj(s=T,d=T)        | Object(s=B,d=B)     | DynamicType      | "{\"value\":{\"dynamic\":true,\"static\":true},\"type\":[\"object\",{\"dynamic\":\"bool\",\"static\":\"bool\"}]}" | Obj(s=T,d=T) | Object(s=B,d=B) |

    # Note on Value/Type Syntax:
    # - InputValue/ExpectedUnmarshaledValue: String("h"), Number(5), True(T)/False(F), Null(Type), List(...), Set(...), Tuple(...), Obj(key=Val), EmptyList(Type), etc.
    # - InputValueType/TargetCtyType/ExpectedUnmarshaledCtyType: String(S), Number(N), Bool(B), List(Type), Set(Type), Tuple(Type,...), Object(key=Type,...), DynamicType(Dyn), BytesCapsuleType.
    # - BytesCapsule("hello") represents a cty.CapsuleVal for a "bytes" type containing []byte("hello").
    # - Zero represents cty.NumberIntVal(0).
    # - For capsule types, the unmarshaled value is checked for deep equality of its encapsulated Go value.
