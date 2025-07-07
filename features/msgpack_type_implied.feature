# Covers tests in cty/msgpack/type_implied_test.go

Feature: Implied Cty Type from Msgpack Bytes
  Background:
    Given a Go environment

  Scenario Outline: Determine implied cty.Type from Msgpack bytes
    Given Msgpack bytes <msgpackBytes> representing a value
    When I determine the implied cty.Type from the Msgpack bytes
    Then the result should be cty.Type <expectedCtyType>
    And no error should occur

    Examples: Null and Booleans
      | msgpackBytes | expectedCtyType |
      | "\xc0"       | Dynamic         | # nil
      | "\xc2"       | Bool            | # false
      | "\xc3"       | Bool            | # true

    Examples: Numbers (Integers and Floats)
      | msgpackBytes                             | expectedCtyType |
      | "\x01"                                   | Number          | # positive fixnum 1
      | "\xff"                                   | Number          | # negative fixnum -1
      | "\xcc\x04"                               | Number          | # uint8 4
      | "\xcd\x00\x04"                           | Number          | # uint16 4
      | "\xce\x00\x04\x02\x01"                   | Number          | # uint32 262657
      | "\xcf\x00\x04\x02\x01\x00\x04\x02\x01"   | Number          | # uint64 281475940831745
      | "\xd0\x04"                               | Number          | # int8 4
      | "\xd1\x00\x04"                           | Number          | # int16 4
      | "\xd2\x00\x04\x02\x01"                   | Number          | # int32 262657
      | "\xd3\x00\x04\x02\x01\x00\x04\x02\x01"   | Number          | # int64 281475940831745
      | "\xca\x01\x01\x01\x01"                   | Number          | # float32
      | "\xcb\x01\x01\x01\x01\x01\x01\x01\x01"   | Number          | # float64

    Examples: Strings
      | msgpackBytes               | expectedCtyType |
      | "\xa0"                     | String          | # fixstr len 0
      | "\xa1\xff"                 | String          | # fixstr len 1
      | "\xd9\x00"                 | String          | # str8 len 0
      | "\xd9\x01\xff"             | String          | # str8 len 1
      | "\xda\x00\x00"             | String          | # str16 len 0
      | "\xda\x00\x01\xff"         | String          | # str16 len 1
      | "\xdb\x00\x00\x00\x00"     | String          | # str32 len 0
      | "\xdb\x00\x00\x00\x01\xff" | String          | # str32 len 1

    Examples: Arrays (Tuples in cty)
      | msgpackBytes               | expectedCtyType |
      | "\x90"                     | EmptyTuple      | # fixarray len 0
      | "\x91\xa0"                 | Tuple([S])      | # fixarray len 1, elem empty string
      | "\xdc\x00\x00"             | EmptyTuple      | # array16 len 0
      | "\xdc\x00\x01\xc2"         | Tuple([B])      | # array16 len 1, elem false
      | "\xdd\x00\x00\x00\x00"     | EmptyTuple      | # array32 len 0
      | "\xdd\x00\x00\x00\x01\xc2" | Tuple([B])      | # array32 len 1, elem false

    Examples: Maps (Objects in cty)
      | msgpackBytes               | expectedCtyType      |
      | "\x80"                     | EmptyObject          | # fixmap len 0
      | "\x81\xa1a\xc2"            | Object({"a":Bool})   | # fixmap len 1, "a":false
      | "\xde\x00\x00"             | EmptyObject          | # map16 len 0
      | "\xde\x00\x01\xa1a\xc2"    | Object({"a":Bool})   | # map16 len 1, "a":false
      | "\xdf\x00\x00\x00\x00"     | EmptyObject          | # map32 len 0
      | "\xdf\x00\x00\x00\x01\xa1a\xc2" | Object({"a":Bool})   | # map32 len 1, "a":false

    Examples: FixExt (DynamicPseudoType for unknown extensions)
      | msgpackBytes       | expectedCtyType |
      | "\xd4\x00\x00"     | Dynamic         | # fixext1 (type 0, data 0x00)
      | "\xd5\x00\x00\x00" | Dynamic         | # fixext2 (type 0, data 0x0000)
