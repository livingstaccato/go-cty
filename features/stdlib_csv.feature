# Covers tests in cty/function/stdlib/csv_test.go

Feature: Standard Library CSV Functions
  Background:
    Given a Go environment

  Scenario Outline: Decode a CSV string
    Given a CSV string <csvString>
    When I decode the CSV string
    Then the result should be <expectedValue>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples: Successful Decoding
      | csvString                                                 | expectedValue                                                                                                | shouldError | errorMessage |
      | "\"name\",\"size\",\"type\"\n\"foo\",\"100\",\"tiny\"\n\"bar\",\"\",\"huge\"\n\"baz\",\"50\",\"weedy\"\n" | [Obj({"name":"foo","size":"100","type":"tiny"}), Obj({"name":"bar","size":"","type":"huge"}), Obj({"name":"baz","size":"50","type":"weedy"})] | should not  |              |
      | "\"just\",\"header\",\"line\""                              | EmptyList(Object({"just":S,"header":S,"line":S}))                                                            | should not  |              |
      | "not csv at all"                                          | EmptyList(Object({"not csv at all":S}))                                                                      | should not  |              |
      | Unknown(String)                                           | Dynamic                                                                                                      | should not  |              | # Type depends on value
      | Dynamic                                                   | Dynamic                                                                                                      | should not  |              |

    Examples: Decoding Failures
      | csvString           | expectedValue | shouldError | errorMessage                                            |
      | ""                  | Dynamic       | should      | "missing header line"                                   |
      | "invalid\"thing\""  | Dynamic       | should      | "CSV parse error on line 1: bare \" in non-quoted-field" |
      | True                | Dynamic       | should      | "string required, but received bool"                    |
      | Null(String)        | Dynamic       | should      | "argument must not be null"                             |
