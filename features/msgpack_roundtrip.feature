# Covers tests in cty/msgpack/roundtrip_test.go

Feature: Cty Value Msgpack Marshaling and Unmarshaling Round Trip
  Background:
    Given a Go environment

  Scenario Outline: Marshal cty.Value to Msgpack and Unmarshal back
    Given a cty.Value <ctyValue> of cty.Type <ctyType>
    When I marshal the cty.Value to Msgpack using cty.Type <ctyType>
    And I unmarshal the Msgpack bytes back to a cty.Value using cty.Type <ctyType>
    Then the resulting cty.Value should be equal to the original <ctyValue>
    And no error should occur during marshaling or unmarshaling

    Examples: Primitives
      | ctyValue                                  | ctyType   |
      | "hello"                                   | String    |
      | ""                                        | String    |
      | Null(String)                              | String    |
      | Unknown(String)                           | String    |
      | UnknownNotNull(String)                    | String    |
      | Unknown(S) refined prefix "foo-"          | String    |
      | UnknownNotNull(S) refined prefix "foo-"   | String    |
      | True                                      | Bool      |
      | False                                     | Bool      |
      | Null(Bool)                                | Bool      |
      | Unknown(Bool)                             | Bool      |
      | UnknownNotNull(Bool)                      | Bool      |
      | Number(1)                                 | Number    |
      | Number(1.5)                               | Number    |
      | Number("9...9" (100 nines))               | Number    | # Big number
      | Number(9223372036854775807)               | Number    | # Max int64
      | Number(9223372036854775808)               | Number    |
      | Number(9223372036854775809)               | Number    |
      | Number(18446744073709551616)              | Number    | # Max uint64 + 1
      | Number(0.8)                               | Number    | # Awkward fraction
      | PositiveInfinity                          | Number    |
      | NegativeInfinity                          | Number    |
      | Unknown(Number)                           | Number    |
      | UnknownNotNull(Number)                    | Number    |
      | Unknown(N) refined lowerBound 0 true      | Number    |
      | Unknown(N) refined lowerBound 0 false     | Number    |
      | Unknown(N) refined upperBound 0 true      | Number    |
      | Unknown(N) refined upperBound 0 false     | Number    |
      | Unknown(N) refined range 0-1 inclusive    | Number    |

    Examples: Lists
      | ctyValue                                  | ctyType      |
      | ["hello"]                                 | List(String) |
      | [Unknown(S)]                              | List(String) |
      | [Null(S)]                                 | List(String) |
      | Null(List(S))                             | List(String) |
      | EmptyList(S)                              | List(String) |
      | Unknown(List(S))                          | List(String) |
      | UnknownNotNull(List(S))                   | List(String) |
      | Unknown(List(S)) refined lowerLen 1      | List(String) |
      | Unknown(List(S)) refined upperLen 1      | List(String) |
      | Unknown(List(S)) refined len 1-2         | List(String) |
      | Unknown(List(S)) refined len 2-2         | List(String) | # Collapses to known list of unknowns
      | UnknownNotNull(List(S)) refined upperLen 1| List(String) |

    Examples: Sets
      | ctyValue                                  | ctyType     |
      | Set(["hello"])                            | Set(String) |
      | Set([Unknown(S)])                         | Set(String) |
      | Set([Null(S)])                            | Set(String) |
      | EmptySet(S)                               | Set(String) |

    Examples: Maps
      | ctyValue                                  | ctyType    |
      | {"greeting":"hello"}                      | Map(String)|
      | {"greeting":Unknown(S)}                   | Map(String)|
      | {"greeting":Null(S)}                      | Map(String)|
      | EmptyMap(S)                               | Map(String)|

    Examples: Tuples
      | ctyValue                                  | ctyType        |
      | Tuple(["hello"])                          | Tuple([S])     |
      | Tuple([Unknown(S)])                       | Tuple([S])     |
      | Tuple([Null(S)])                          | Tuple([S])     |
      | EmptyTuple                                | EmptyTuple     |

    Examples: Objects
      | ctyValue                                  | ctyType        |
      | Obj({"greeting":"hello"})                 | Object({"greeting":S}) |
      | Obj({"greeting":Unknown(S)})              | Object({"greeting":S}) |
      | Obj({"greeting":Null(S)})                 | Object({"greeting":S}) |
      | Obj({"a":Null(S),"b":Null(S)})            | Object({"a":S,"b":S})  |
      | Obj({"a":Unknown(S),"b":Unknown(S)})      | Object({"a":S,"b":S})  |
      | EmptyObjectVal                            | EmptyObject    |

    Examples: Dynamic Values
      | ctyValue                                  | ctyType        |
      | Null(String)                              | Dynamic        | # NullVal(cty.String) encoded as Dynamic
      | Dynamic                                   | Dynamic        |
      | ["hello"]                                 | List(Dynamic)  |
      | [Null(S)]                                 | List(Dynamic)  |
      | [Dynamic]                                 | List(Dynamic)  |

  Scenario Outline: Convert string to cty.Value, marshal to Msgpack, unmarshal, convert back to string
    Given a string value <stringValue>
    And a target cty.Type <ctyType> for the initial conversion
    When I convert the string to a cty.Value "original_cty_value" of type <ctyType>
    And I marshal "original_cty_value" to Msgpack using cty.Type <ctyType>
    And I unmarshal the Msgpack bytes back to "round_tripped_cty_value" using cty.Type <ctyType>
    And I convert "round_tripped_cty_value" back to a cty.String "final_string_value"
    Then "final_string_value" should be equal to the initial string <stringValue>
    And "round_tripped_cty_value" should be equal to "original_cty_value"
    And no error should occur during any step

    Examples:
      | stringValue          | ctyType |
      | "0"                  | Number  |
      | "1"                  | Number  |
      | "-1"                 | Number  |
      | "9223372036854775807"| Number  |
      | "9223372036854775808"| Number  |
      | "9223372036854775809"| Number  |
      | "18446744073709551616"| Number  |
      | "-9223372036854775807"| Number  |
      | "-9223372036854775808"| Number  |
      | "-9223372036854775809"| Number  |
      | "-18446744073709551616"| Number  |
      | "true"               | Bool    |
      | "false"              | Bool    |

  Scenario Outline: Msgpack round trip with string prefix refinement truncation
    Given an initial cty.Value <initialValue> of cty.Type String
    And an expected cty.Value after round trip <expectedRoundTripValue>
    When I marshal <initialValue> to Msgpack using cty.Type String
    And I unmarshal the Msgpack bytes back to "actualRoundTripValue" using cty.Type String
    Then "actualRoundTripValue" should be equal to <expectedRoundTripValue>
    And no error should occur

    Examples:
      | initialValue                                      | expectedRoundTripValue                              |
      | Unknown(S) refined prefix (1024 'a's)             | Unknown(S) refined prefix (255 'a's)              |
      | UnknownNotNull(S) refined prefix (1024 'b's)      | UnknownNotNull(S) refined prefix (255 'b's)        |
      | Unknown(S) refined prefix (255 'c's + "-")         | Unknown(S) refined prefix (255 'c's + "-")         |
      | Unknown(S) refined prefix (255 'd's + "🤷🤷")     | Unknown(S) refined prefix (255 'd's)               | # Emoji part of prefix gets truncated by SafeKnownPrefix logic
