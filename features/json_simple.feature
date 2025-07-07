# Covers tests in cty/json/simple_test.go

Feature: Simple JSON Value Marshaling and Unmarshaling
  Background:
    Given a Go environment

  Scenario Outline: Marshal cty.Value to JSON and Unmarshal back
    Given a cty.Value <ctyValue>
    When I marshal it to JSON using SimpleJSONValue
    Then the JSON string should be <expectedJsonString>
    When I unmarshal this JSON string back to a cty.Value using SimpleJSONValue
    Then the resulting cty.Value should be <expectedUnmarshaledCtyValue>
    And no error should occur during marshaling or unmarshaling

    Examples:
      | ctyValue                               | expectedJsonString              | expectedUnmarshaledCtyValue            |
      | Number(5)                              | "5"                             | Number(5)                              |
      | True                                   | "true"                          | True                                   |
      | "hello"                                | "\"hello\""                       | "hello"                                |
      | Tuple(["hello", True])                 | "[\"hello\",true]"                | Tuple(["hello", True])                 |
      | List([False, True])                    | "[false,true]"                  | Tuple([False, True])                   | # List becomes Tuple
      | Set([False, True])                     | "[false,true]"                  | Tuple([False, True])                   | # Set becomes Tuple, order may vary in JSON
      | Obj({"true":True, "greet":"hello"})    | "{\"greet\":\"hello\",\"true\":true}" | Obj({"true":True, "greet":"hello"})    | # Object key order may vary in JSON
      | Map({"true":True, "false":False})      | "{\"false\":false,\"true\":true}" | Obj({"true":True, "false":False})      | # Map becomes Object, key order may vary
      | Null(Bool)                             | "null"                          | Null(Dynamic)                          | # Type is lost
