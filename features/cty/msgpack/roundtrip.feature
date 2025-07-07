# Original Go Test File: cty/msgpack/roundtrip_test.go
# This feature file covers tests for MessagePack marshaling and unmarshaling of cty values.

Feature: cty.Value MessagePack Serialization Round Trip
  This feature describes how cty.Value objects are marshaled to MessagePack
  and then unmarshaled back, ensuring the value remains consistent.
  This tests the cty/msgpack.Marshal and cty/msgpack.Unmarshal functions.

  Scenario Outline: Round-trip marshaling and unmarshaling of cty.Value via MessagePack
    # Covers test: TestRoundTrip and TestRoundTrip_fromString
    Given a cty.Value <InputValue> of cty type <TargetCtyType>
    When the value is marshaled to MessagePack using the target type
    And the resulting MessagePack bytes are unmarshaled back using the target type
    Then the unmarshaled cty.Value should be RawEqualTo the original <InputValue>
    And if <InputValueOriginatesFromString> is true, the unmarshaled value, when converted back to cty.String, should equal the original cty.String representation of <InputValue>

    Examples: Primitive Types
      | InputValue            | TargetCtyType | InputValueOriginatesFromString |
      | String("hello")       | String        | false                          |
      | String("")            | String        | false                          |
      | Null(String)          | String        | false                          |
      | Unknown(String)       | String        | false                          |
      | Unknown(S).NotNull    | String        | false                          |
      | Unknown(S).Prefix("foo-") | String    | false                          |
      | True                  | Bool          | false                          |
      | False                 | Bool          | false                          |
      | Null(Bool)            | Bool          | false                          |
      | Unknown(Bool)         | Bool          | false                          |
      | Unknown(B).NotNull    | Bool          | false                          |
      | String("true")        | Bool          | true                           | # Originates as String("true"), converted to Bool(true) for test

    Examples: Number Types
      | InputValue            | TargetCtyType | InputValueOriginatesFromString |
      | Number(1)             | Number        | false                          |
      | Number(1.5)           | Number        | false                          |
      | Number("BIG_NUM")     | Number        | false                          | # Represents a very large number
      | Number("0.8")         | Number        | false                          | # Awkward fraction
      | PositiveInfinity      | Number        | false                          |
      | NegativeInfinity      | Number        | false                          |
      | Unknown(Number)       | Number        | false                          |
      | Unknown(N).NotNull    | Number        | false                          |
      | Unknown(N).RangeLower(0,true) | Number | false                          |
      | Unknown(N).RangeUpper(0,true) | Number | false                          |
      | Unknown(N).Range(0,1) | Number        | false                          |
      | String("0")           | Number        | true                           |
      | String("9223372036854775808") | Number | true                           | # MaxInt64 + 1

    Examples: Collection Types (List, Set, Map, Tuple, Object)
      | InputValue                      | TargetCtyType          | InputValueOriginatesFromString |
      | List(String("hello"))           | List(String)           | false                          |
      | List(Unknown(String))           | List(String)           | false                          |
      | Null(List(String))              | List(String)           | false                          |
      | EmptyList(String)               | List(String)           | false                          |
      | Unknown(List(S))                | List(String)           | false                          |
      | Unknown(List(S)).NotNull        | List(String)           | false                          |
      | Unknown(List(S)).LengthLower(1) | List(String)           | false                          |
      | Unknown(List(S)).Length(2)      | List(String)           | false                          | # Becomes known list of 2 unknowns
      | Set(String("hello"))            | Set(String)            | false                          |
      | Map("g"=S("h"))                 | Map(String)            | false                          |
      | Tuple(String("h"))              | Tuple([String])        | false                          |
      | Obj("g"=S("h"))                 | Object({"g":String})   | false                          |

    Examples: DynamicPseudoType Target
      | InputValue            | TargetCtyType          | InputValueOriginatesFromString |
      | Null(String)          | DynamicType            | false                          |
      | Dynamic               | DynamicType            | false                          |
      | List(String("hello")) | List(DynamicType)      | false                          |
      | List(Null(String))    | List(DynamicType)      | false                          |
      | List(Dynamic)         | List(DynamicType)      | false                          |

  Scenario Outline: String prefix refinement truncation during MessagePack round-trip
    # Covers test: TestRoundTrip_truncatesStringPrefixRefinement
    Given a cty.Value <InputValueWithLongPrefix> of cty type String
    When the value is marshaled to MessagePack and unmarshaled back
    Then the unmarshaled cty.Value should be RawEqualTo <ExpectedValueAfterTruncation>

    Examples:
      | InputValueWithLongPrefix                            | ExpectedValueAfterTruncation                        |
      | Unknown(S).RefinePrefix(Repeat("a",1024))           | Unknown(S).RefinePrefix(Repeat("a",255))          |
      | Unknown(S).NotNull.RefinePrefix(Repeat("b",1024))   | Unknown(S).NotNull.RefinePrefix(Repeat("b",255))  |
      | Unknown(S).RefinePrefix(Repeat("c",255) + "-")      | Unknown(S).RefinePrefix(Repeat("c",255) + "-")    | # Max length prefix is fine
      | Unknown(S).RefinePrefix(Repeat("d",255) + "🤷🤷")    | Unknown(S).RefinePrefix(Repeat("d",255))          | # Suffix that might combine is trimmed

    # Note on Value Syntax:
    # - Primitives: String("h"), Number(1), True, Null(Type), Unknown(Type), Dynamic, PositiveInfinity
    # - Collections: List(val), Set(val), Map(key=val), Tuple(val), Obj(key=val), EmptyList(Type)
    # - Refinements: .NotNull, .Prefix("foo-"), .RangeLower(X,bool), .Length(X), etc.
    # - S=String, B=Bool, N=Number.
    # - Repeat("char", count) is a placeholder for a long repeated string.
    # - "BIG_NUM" represents a very large number string.
    # - InputValueOriginatesFromString: true if the test case in Go converts a string to the InputValue's type first.
    #   This is to check if string representations of numbers/bools survive the round trip.
    # - The unmarshaled value is compared using RawEquals to the original InputValue.
