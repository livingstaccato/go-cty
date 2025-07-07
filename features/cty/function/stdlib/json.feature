# Original Go Test File: cty/function/stdlib/json_test.go
# This feature file covers tests for JSON encoding and decoding functions
# in the cty standard library.

Feature: Standard Library JSON Operations
  This feature describes the behavior of `jsonencode` and `jsondecode`
  functions for converting cty values to and from JSON strings.

  Scenario Outline: Encoding a cty value to a JSON string (jsonencode)
    # Covers test: TestJSONEncode
    Given a cty value <InputValue>
    When the JSONEncode function is called with this value
    Then the result should be a cty String representing the JSON: "<ExpectedJSONString>"
    And if the input value or parts of it are Unknown, the result string should be Unknown(String) and refined appropriately

    Examples: Primitive Values
      | InputValue          | ExpectedJSONString        | Refinement Note                                    |
      | Number(15)          | "15"                      |                                                    |
      | String("hello")     | "\"hello\""               |                                                    |
      | True                | "true"                    |                                                    |
      | Null(String)        | "null"                    |                                                    |

    Examples: Collection Values
      | InputValue          | ExpectedJSONString        | Refinement Note                                    |
      | EmptyList(Number)   | "[]"                      |                                                    |
      | List(True, False)   | "[true,false]"            |                                                    |
      | Obj(true=T, false=F)| "{\"false\":false,\"true\":true}" | # Keys sorted                                      |

    Examples: Unknown and Dynamic Values
      | InputValue          | ExpectedJSONString        | Refinement Note                                    |
      | Unknown(Number)     | Unknown(String)           | Refined NotNull                                    |
      | Obj(dunno=Unk(B), false=F) | Unknown(String)    | Refined NotNull, StringPrefixFull "{"            |
      | List(Unknown(S))    | Unknown(String)           | Refined NotNull, StringPrefixFull "["            |
      | Unknown(String)     | Unknown(String)           | Refined NotNull (cannot guarantee prefix if null)  |
      | Unknown(S).NotNull  | Unknown(String)           | Refined NotNull, StringPrefixFull "\""           |
      | Dynamic             | Unknown(String)           | Refined NotNull                                    |

  Scenario Outline: Decoding a JSON string to a cty value (jsondecode)
    # Covers test: TestJSONDecode
    Given a cty String value representing JSON data: "<JSONInputString>"
    When the JSONDecode function is called with this string
    Then the result should be the cty value <ExpectedDecodedValue>
    And the error message, if any, should be "<ExpectedErrorMessage>"

    Examples: Primitive JSON Values
      | JSONInputString | ExpectedDecodedValue | ExpectedErrorMessage |
      | "15"            | Number(15)           |                      |
      | "\"hello\""     | String("hello")      |                      |
      | "true"          | True                 |                      |

    Examples: Collection JSON Values
      | JSONInputString             | ExpectedDecodedValue          | ExpectedErrorMessage |
      | "[]"                        | EmptyTuple                    |                      |
      | "[true,false]"              | Tuple(True, False)            |                      |
      | "{\"false\":false,\"true\":true}" | Obj(false=F, true=T)        |                      |

    Examples: Unknown JSON String Input
      | JSONInputString                               | ExpectedDecodedValue | ExpectedErrorMessage |
      | Unknown(String)                               | Dynamic              |                      |
      | Unknown(String).RefinePrefix("1")             | Unknown(Number)      |                      | # Type deduced from prefix
      | Unknown(String).RefinePrefix("t")             | Unknown(Bool)        |                      | # Type deduced from prefix
      | Unknown(String).RefinePrefix("\"str")         | Unknown(String)      |                      | # Type deduced from prefix
      | Unknown(String).RefinePrefix("{")             | Dynamic              |                      | # Ambiguous object/map
      | Unknown(String).RefinePrefix("[")             | Dynamic              |                      | # Ambiguous list/tuple

    Examples: Invalid JSON String Input
      | JSONInputString                               | ExpectedDecodedValue | ExpectedErrorMessage                                  |
      | "aaaa"                                        |                      | "invalid character 'a' looking for beginning of value"|
      | "nope"                                        |                      | "invalid character 'o' in literal null (expecting 'u')" |
      | Unknown(String).RefinePrefix("a")             |                      | "a JSON document cannot begin with the character 'a'" | # Error deduced from refinement

    Examples: Marked Input
      | JSONInputString     | ExpectedDecodedValue | ExpectedErrorMessage |
      | String("true").Mark(1) | True.Mark(1)         |                      |

    # Note on Value Syntax:
    # - Primitives: Number(15), String("hello"), True, False, Null(Type)
    # - Collections: EmptyList(Type), List(val1, val2), Obj(key1=val1), EmptyTuple, Tuple(val1, val2)
    # - Unknown/Dynamic: Unknown(Type), Unknown(Type).NotNull, Unknown(Type).RefinePrefix("p"), Dynamic
    # - Types: S=String, B=Bool, F=False, T=True
    # - ExpectedJSONString for jsonencode is a cty.String value containing the JSON, or Unknown(String).
    # - ExpectedDecodedValue for jsondecode is the resulting cty.Value. If error, this column is empty.
