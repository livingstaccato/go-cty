# Original Go Test File: cty/msgpack/type_implied_test.go
# This feature file covers tests for inferring a cty.Type from MessagePack bytes.

Feature: Implied cty.Type from MessagePack Data
  This feature describes how a cty.Type is inferred from a given MessagePack byte sequence
  using the ImpliedType function from the cty/msgpack package. This is useful for
  determining the structure of MessagePack data before unmarshaling it into a cty.Value.

  Scenario Outline: Inferring cty.Type from valid MessagePack data
    # Covers test: TestImpliedType
    Given a MessagePack byte sequence represented by hex string "<MsgPackHexString>"
    When the ImpliedType function is called with this MessagePack data
    Then the inferred cty.Type should be <ExpectedCtyType>
    And no error should occur

    Examples: Nil and Boolean Types
      | MsgPackHexString | ExpectedCtyType | Description      |
      | "c0"             | DynamicType     | msgpack nil      |
      | "c2"             | Bool            | msgpack false    |
      | "c3"             | Bool            | msgpack true     |

    Examples: Number Types (Integers and Floats)
      | MsgPackHexString                 | ExpectedCtyType | Description      |
      | "01"                             | Number          | positive fixnum 1|
      | "ff"                             | Number          | negative fixnum -1|
      | "cc04"                           | Number          | uint8 4          |
      | "cd0004"                         | Number          | uint16 4         |
      | "ce00040201"                     | Number          | uint32           |
      | "cf0004020100040201"             | Number          | uint64           |
      | "d004"                           | Number          | int8 4           |
      | "d10004"                         | Number          | int16 4          |
      | "d200040201"                     | Number          | int32            |
      | "d30004020100040201"             | Number          | int64            |
      | "ca01010101"                     | Number          | float32          |
      | "cb0101010101010101"             | Number          | float64          |

    Examples: String Types
      | MsgPackHexString                 | ExpectedCtyType | Description      |
      | "a0"                             | String          | fixstr len 0     |
      | "a1ff"                           | String          | fixstr len 1     |
      | "d900"                           | String          | str8 len 0       |
      | "d901ff"                         | String          | str8 len 1       |
      | "da0000"                         | String          | str16 len 0      |
      | "da0001ff"                       | String          | str16 len 1      |
      | "db00000000"                     | String          | str32 len 0      |
      | "db00000001ff"                   | String          | str32 len 1      |

    Examples: Array Types (inferred as cty Tuples)
      | MsgPackHexString                 | ExpectedCtyType    | Description            |
      | "90"                             | EmptyTuple         | fixarray len 0         |
      | "91a0"                           | Tuple([String])    | fixarray len 1 (str)   |
      | "dc0000"                         | EmptyTuple         | array16 len 0          |
      | "dc0001c2"                       | Tuple([Bool])      | array16 len 1 (bool)   |
      | "dd00000000"                     | EmptyTuple         | array32 len 0          |
      | "dd00000001c2"                   | Tuple([Bool])      | array32 len 1 (bool)   |

    Examples: Map Types (inferred as cty Objects)
      | MsgPackHexString                 | ExpectedCtyType      | Description            |
      | "80"                             | EmptyObject          | fixmap len 0           |
      | "81a161c2"                       | Object({"a":Bool})   | fixmap len 1 ("a":bool)|
      | "de0000"                         | EmptyObject          | map16 len 0            |
      | "de0001a161c2"                   | Object({"a":Bool})   | map16 len 1 ("a":bool) |
      | "df00000000"                     | EmptyObject          | map32 len 0            |
      | "df00000001a161c2"               | Object({"a":Bool})   | map32 len 1 ("a":bool) |

    Examples: Extension Types (cty uses these for Unknown/Dynamic and Capsule info)
      | MsgPackHexString | ExpectedCtyType | Description        |
      | "d40000"         | DynamicType     | fixext1 (cty unknown)| # Actual type depends on encoded cty extension type
      | "d5000000"       | DynamicType     | fixext2 (cty unknown)|

    # Note on Type Syntax:
    # - Number, String, Bool, DynamicType, EmptyObject, EmptyTuple
    # - Object({attrName1: Type1, ...})
    # - Tuple([Type1, Type2, ...])
    # - The hex strings represent raw MessagePack byte sequences.
    # - cty's msgpack encoding for Unknown values uses msgpack extension types.
    #   The ImpliedType function currently infers DynamicPseudoType for these generic extensions if not further specified by cty's own ext codes.
