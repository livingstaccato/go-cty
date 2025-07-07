# Original Go Test File: cty/json/type_implied_test.go
# This feature file covers tests for inferring a cty.Type from a JSON byte slice.

Feature: Implied cty.Type from JSON Data
  This feature describes how a cty.Type is inferred from a given JSON byte slice
  using the ImpliedType function from the cty/json package. This is useful for
  determining the structure of JSON data before unmarshaling it into a cty.Value.

  Scenario Outline: Inferring cty.Type from valid JSON data
    # Covers test: TestImpliedType
    Given a JSON string: "<JSONInputString>"
    When the ImpliedType function is called with the JSON data
    Then the inferred cty.Type should be <ExpectedCtyType>
    And no error should occur

    Examples: Primitive JSON Types
      | JSONInputString | ExpectedCtyType |
      | "null"          | DynamicType     |
      | "1"             | Number          |
      | "1.2222222222222222222222222222222222" | Number          | # Large float
      | "999999999999999999999999999999999999999999999999999999999999" | Number          | # Large integer
      | "\"\""          | String          |
      | "\"hello\""     | String          |
      | "true"          | Bool            |
      | "false"         | Bool            |

    Examples: JSON Object Types
      | JSONInputString                              | ExpectedCtyType                       |
      | "{}"                                         | EmptyObject                           |
      | "{\"true\": true}"                           | Object("true"=Bool)                   |
      | "{\"true\": true, \"name\": \"E\", \"null\": null}" | Object("true"=B, "name"=S, "null"=Dyn)|
      | "{\"a\": \"hello\", \"a\": \"world\"}"       | Object("a"=String)                    | # Duplicate key, type is consistent (last value wins in Go map, but type is from first seen for ImpliedType logic or consistent type)

    Examples: JSON Array Types (inferred as cty Tuples)
      | JSONInputString                                | ExpectedCtyType                       |
      | "[]"                                           | EmptyTuple                            |
      | "[true, 1.2, null]"                            | Tuple(Bool, Number, DynamicType)      |
      | "[[true], [1.2], [null]]"                      | Tuple(Tuple(B), Tuple(N), Tuple(Dyn)) |
      | "[{\"true\": true}, {\"name\": \"E\"}, {\"null\": null}]" | Tuple(Obj("true"=B), Obj("name"=S), Obj("null"=Dyn)) |

  Scenario Outline: Attempting to infer cty.Type from invalid JSON data
    # Covers test: TestImpliedTypeErrors
    Given an invalid JSON string: "<InvalidJSONInput>"
    When the ImpliedType function is called with the JSON data
    Then an error should occur with a message containing "<ExpectedErrorMessagePart>"

    Examples:
      | InvalidJSONInput            | ExpectedErrorMessagePart               |
      | "{\"a\": \"hello\", \"a\": true}" | "duplicate \"a\" property in JSON object" | # Duplicate key with different types
      | "{}boop"                    | "extraneous data after JSON object"    |
      | "[!]"                       | "invalid character '!' looking for beginning of value" |
      | "[}]"                       | "invalid character '}' looking for beginning of value" |
      | "{true: null}"              | "invalid character 't'"                | # Object key must be a string

    # Note on Type Syntax:
    # - Number, String, Bool, DynamicType (Dyn), EmptyObject, EmptyTuple
    # - Object(attr1=Type1, attr2=Type2, ...)
    # - Tuple(Type1, Type2, ...)
    # - S=String, B=Bool, N=Number. Keys in objects are strings.
