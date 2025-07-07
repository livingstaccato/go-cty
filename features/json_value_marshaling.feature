# Covers tests in cty/json/value_test.go

Feature: Cty Value JSON Marshaling and Unmarshaling with Type Information
  Background:
    Given a Go environment

  Scenario Outline: Marshal cty.Value to JSON and Unmarshal back with specific cty.Type
    Given a cty.Value <ctyValue>
    And a target cty.Type <targetCtyType> for marshaling and unmarshaling
    When I marshal the cty.Value to JSON using the target cty.Type
    Then the JSON string should be <expectedJsonString>
    When I unmarshal this JSON string back to a cty.Value using the target cty.Type
    Then the resulting cty.Value should be <expectedUnmarshaledCtyValue>
    And no error should occur during marshaling or unmarshaling

    Examples: Primitives
      | ctyValue     | targetCtyType | expectedJsonString | expectedUnmarshaledCtyValue |
      | "hello"      | String        | "\"hello\""        | "hello"                     |
      | ""           | String        | "\"\""             | ""                          |
      | "15"         | Number        | "15"               | Number(15)                  | # String to Number
      | "true"       | Bool          | "true"             | True                        | # String to Bool
      | "1"          | Bool          | "true"             | True                        | # String "1" to Bool
      | Null(String) | String        | "null"             | Null(String)                |
      | Number(2)    | Number        | "2"                | Number(2)                   |
      | Number(2.5)  | Number        | "2.5"              | Number(2.5)                 |
      | Number(5)    | String        | "\"5\""            | "5"                         | # Number to String
      | True         | Bool          | "true"             | True                        |
      | False        | Bool          | "false"            | False                       |
      | True         | String        | "\"true\""         | "true"                      | # Bool to String

    Examples: Lists
      | ctyValue          | targetCtyType | expectedJsonString | expectedUnmarshaledCtyValue   |
      | [True, False]     | List(Bool)    | "[true,false]"     | [True, False]                 |
      | EmptyList(Bool)   | List(Bool)    | "[]"               | EmptyList(Bool)               |
      | [True, False]     | List(String)  | "[\"true\",\"false\"]" | ["true", "false"]             | # List(Bool) to List(String)

    Examples: Sets
      | ctyValue          | targetCtyType | expectedJsonString | expectedUnmarshaledCtyValue   |
      | Set([T,F])        | Set(Bool)     | "[false,true]"     | Set([True, False])            | # Order in JSON for set is not guaranteed
      | EmptySet(Bool)    | Set(Bool)     | "[]"               | EmptySet(Bool)                |

    Examples: Tuples
      | ctyValue             | targetCtyType    | expectedJsonString | expectedUnmarshaledCtyValue      |
      | Tuple([True, Num(5)])| Tuple([B,N])     | "[true,5]"         | Tuple([True, Num(5)])          |
      | EmptyTuple           | EmptyTuple       | "[]"               | EmptyTuple                     |

    Examples: Maps
      | ctyValue                        | targetCtyType | expectedJsonString         | expectedUnmarshaledCtyValue           |
      | EmptyMap(Bool)                  | Map(Bool)     | "{}"                       | EmptyMap(Bool)                      |
      | Map({"yes":T,"no":F})           | Map(Bool)     | "{\"no\":false,\"yes\":true}" | Map({"yes":True,"no":False})        | # Order in JSON for map is not guaranteed
      | Null(Map(Bool))                 | Map(Bool)     | "null"                     | Null(Map(Bool))                     |

    Examples: Objects
      | ctyValue                        | targetCtyType        | expectedJsonString         | expectedUnmarshaledCtyValue           |
      | EmptyObjectVal                  | EmptyObject          | "{}"                       | EmptyObjectVal                      |
      | Obj({"bool":T,"num":0})         | Object({"bool":B,"num":N}) | "{\"bool\":true,\"number\":0}" | Obj({"bool":True,"num":0})        | # Order in JSON for object is not guaranteed

    Examples: Capsules (Base64 encoded string)
      | ctyValue                        | targetCtyType        | expectedJsonString         | expectedUnmarshaledCtyValue           |
      | Capsule("bytes", "hello")       | Capsule("bytes",byte[]) | "\"aGVsbG8=\""             | Capsule("bytes", "hello")           |

    Examples: Dynamic Type (includes type information in JSON)
      | ctyValue                        | targetCtyType        | expectedJsonString                                     | expectedUnmarshaledCtyValue           |
      | True                            | Dynamic              | "{\"value\":true,\"type\":\"bool\"}"                    | True                                  |
      | "hello"                         | Dynamic              | "{\"value\":\"hello\",\"type\":\"string\"}"              | "hello"                               |
      | Number(5)                       | Dynamic              | "{\"value\":5,\"type\":\"number\"}"                     | Number(5)                             |
      | [True, False]                   | Dynamic              | "{\"value\":[true,false],\"type\":[\"list\",\"bool\"]}"   | [True, False]                         |
      | [True, False]                   | List(Dynamic)        | "[{\"value\":true,\"type\":\"bool\"},{\"value\":false,\"type\":\"bool\"}]" | [True, False]                         |
      | Obj({"static":T,"dynamic":T})   | Obj({"static":B,"dynamic":Dyn}) | "{\"dynamic\":{\"value\":true,\"type\":\"bool\"},\"static\":true}" | Obj({"static":True,"dynamic":True}) |
      | Obj({"static":T,"dynamic":T})   | Dynamic              | "{\"value\":{\"dynamic\":true,\"static\":true},\"type\":[\"object\",{\"dynamic\":\"bool\",\"static\":\"bool\"}]}" | Obj({"static":True,"dynamic":True}) |
