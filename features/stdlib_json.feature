# Covers tests in cty/function/stdlib/json_test.go

Feature: Standard Library JSON Functions
  Background:
    Given a Go environment

  Scenario Outline: Encode a cty value to a JSON string
    Given a cty value <inputValue>
    When I encode the value to JSON
    Then the result should be JSON string <expectedJsonString>
    And no error should occur

    Examples:
      | inputValue                                 | expectedJsonString                         |
      | 15                                         | "15"                                       |
      | "hello"                                    | "\"hello\""                                |
      | True                                       | "true"                                     |
      | EmptyList(Number)                          | "[]"                                       |
      | [True, False]                              | "[true,false]"                             |
      | {"true":True, "false":False}               | "{\"false\":false,\"true\":true}"          | # Order might vary
      | Unknown(Number)                            | UnknownNotNull(String)                     |
      | {"dunno":Unknown(Bool), "false":False}     | UnknownNotNull(String) refined prefix "{"  |
      | [Unknown(String)]                          | UnknownNotNull(String) refined prefix "["  |
      | Unknown(String)                            | UnknownNotNull(String)                     | # No prefix refinement for potentially null string
      | UnknownNotNull(String)                     | UnknownNotNull(String) refined prefix "\"" |
      | Unknown(Number)                            | UnknownNotNull(String)                     |
      | Unknown(Bool)                              | UnknownNotNull(String)                     |
      | Dynamic                                    | UnknownNotNull(String)                     |
      | Null(String)                               | "null"                                     |

  Scenario Outline: Decode a JSON string to a cty value
    Given a JSON string <jsonString>
    When I decode the JSON string
    Then the result should be cty value <expectedCtyValue>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples: Successful Decoding
      | jsonString                               | expectedCtyValue                   | shouldError | errorMessage |
      | "15"                                     | 15                                 | should not  |              |
      | "\"hello\""                              | "hello"                            | should not  |              |
      | "true"                                   | True                               | should not  |              |
      | "[]"                                     | EmptyTuple                         | should not  |              |
      | "[true,false]"                           | Tuple([True,False])                | should not  |              |
      | "{\"false\":false,\"true\":true}"        | Obj({"true":True, "false":False})  | should not  |              | # Order might vary
      | Unknown(String)                          | Dynamic                            | should not  |              |
      | Unknown(S) refined prefix "1"            | Unknown(Number)                    | should not  |              |
      | Unknown(S) refined prefix "-"            | Unknown(Number)                    | should not  |              |
      | Unknown(S) refined prefix "."            | Unknown(Number)                    | should not  |              |
      | Unknown(S) refined prefix "t"            | Unknown(Bool)                      | should not  |              |
      | Unknown(S) refined prefix "f"            | Unknown(Bool)                      | should not  |              |
      | Unknown(S) refined prefix "\"blurt"      | Unknown(String)                    | should not  |              |
      | Unknown(S) refined prefix "{"            | Dynamic                            | should not  |              |
      | Unknown(S) refined prefix "["            | Dynamic                            | should not  |              |
      | Dynamic                                  | Dynamic                            | should not  |              |
      | "true" (mark 1)                          | True (mark 1)                      | should not  |              |

    Examples: Decoding Failures
      | jsonString                       | expectedCtyValue | shouldError | errorMessage                                            |
      | "aaaa"                           |                  | should      | "invalid character 'a' looking for beginning of value"  |
      | "nope"                           |                  | should      | "invalid character 'o' in literal null (expecting 'u')" |
      | Unknown(S) refined prefix "a"    |                  | should      | "a JSON document cannot begin with the character 'a'"   |
