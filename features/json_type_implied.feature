# Covers tests in cty/json/type_implied_test.go

Feature: Implied Cty Type from JSON String
  Background:
    Given a Go environment

  Scenario Outline: Determine implied cty.Type from a JSON string
    Given a JSON string <jsonString>
    When I determine the implied cty.Type from the JSON string
    Then the result should be cty.Type <expectedCtyType>
    And no error should occur

    Examples: Primitives
      | jsonString                                 | expectedCtyType |
      | "null"                                     | Dynamic         |
      | "1"                                        | Number          |
      | "1.2222222222222222222222222222222222"     | Number          |
      | "999999999999999999999999999999999999999999999999999999999999" | Number          |
      | "\"\""                                     | String          |
      | "\"hello\""                                | String          |
      | "true"                                     | Bool            |
      | "false"                                    | Bool            |

    Examples: Objects
      | jsonString                                           | expectedCtyType                          |
      | "{}"                                                 | EmptyObject                              |
      | "{\"true\": true}"                                   | Object({"true":Bool})                    |
      | "{\"true\": true, \"name\": \"Ermintrude\", \"null\": null}" | Object({"true":Bool,"name":S,"null":Dyn}) |
      | "{\"a\": \"hello\", \"a\": \"world\"}"               | Object({"a":String})                     | # Duplicate key, last one wins for type

    Examples: Arrays (Tuples in cty)
      | jsonString                                                 | expectedCtyType                          |
      | "[]"                                                       | EmptyTuple                               |
      | "[true, 1.2, null]"                                        | Tuple([Bool,Number,Dynamic])             |
      | "[[true], [1.2], [null]]"                                  | Tuple([Tuple([B]),Tuple([N]),Tuple([Dyn])]) |
      | "[{\"true\": true}, {\"name\": \"Ermintrude\"}, {\"null\": null}]" | Tuple([Obj({"true":B}),Obj({"name":S}),Obj({"null":Dyn})]) |

  Scenario Outline: Determine implied cty.Type from an invalid JSON string
    Given an invalid JSON string <invalidJsonString>
    When I attempt to determine the implied cty.Type from the JSON string
    Then an error should occur with message "<expectedErrorMessage>"

    Examples:
      | invalidJsonString             | expectedErrorMessage                                  |
      | "{\"a\": \"hello\", \"a\": true}" | "duplicate \"a\" property in JSON object"             |
      | "{}boop"                      | "extraneous data after JSON object"                   |
      | "[!]"                         | "invalid character '!' looking for beginning of value"|
      | "[}"                          | "invalid character '}' looking for beginning of value"|
      | "{true: null}"                | "invalid character 't'"                               |
