# Covers tests in cty/gocty/out_test.go

Feature: Cty Value To Go Value Conversion (FromCtyValue)
  Background:
    Given a Go environment

  Scenario Outline: Convert cty.Value to a Go value of a specified Go type
    Given a cty.Value <ctyValue> of cty.Type <ctyType>
    And a target Go type <goType>
    When I convert the cty.Value to the Go type
    Then the result should be Go value <expectedGoValue> of type <expectedGoType>
    And no error should occur

    Examples: Boolean
      | ctyValue     | ctyType | goType    | expectedGoValue | expectedGoType |
      | True         | Bool    | bool      | true            | bool           |
      | False        | Bool    | bool      | false           | bool           |
      | True         | Bool    | *bool     | &true           | *bool          |
      | Null(Bool)   | Bool    | *bool     | nil             | *bool          |
      | True         | Bool    | boolAlias | boolAlias(true) | boolAlias      |

    Examples: String
      | ctyValue     | ctyType | goType       | expectedGoValue    | expectedGoType |
      | "hello"      | String  | string       | "hello"            | string         |
      | ""           | String  | string       | ""                 | string         |
      | "hello"      | String  | *string      | &"hello"           | *string        |
      | Null(String) | String  | *string      | nil                | *string        |
      | "hello"      | String  | stringAlias  | stringAlias("hello")| stringAlias    |

    Examples: Number
      | ctyValue     | ctyType | goType       | expectedGoValue    | expectedGoType |
      | 5            | Number  | int          | 5                  | int            |
      | 5            | Number  | int8         | 5                  | int8           |
      | 5            | Number  | int16        | 5                  | int16          |
      | 5            | Number  | int32        | 5                  | int32          |
      | 5            | Number  | int64        | 5                  | int64          |
      | 5            | Number  | uint         | 5                  | uint           |
      | 5            | Number  | uint8        | 5                  | uint8          |
      | 5            | Number  | uint16       | 5                  | uint16         |
      | 5            | Number  | uint32       | 5                  | uint32         |
      | 5            | Number  | uint64       | 5                  | uint64         |
      | 1.5          | Number  | float32      | 1.5                | float32        |
      | 1.5          | Number  | float64      | 1.5                | float64        |
      | 1.5          | Number  | *big.Float   | BigFloat(1.5)      | *big.Float     |
      | 5            | Number  | *big.Int     | BigInt(5)          | *big.Int       |
      | 5            | Number  | intAlias     | intAlias(5)        | intAlias       |
      | 1.5          | Number  | float32Alias | float32Alias(1.5)  | float32Alias   |
      | 1.5          | Number  | float64Alias | float64Alias(1.5)  | float64Alias   |
      | 5            | Number  | *bigIntAlias | &bigIntAlias(5)    | *bigIntAlias   |

    Examples: Lists & Arrays
      | ctyValue          | ctyType      | goType    | expectedGoValue | expectedGoType |
      | EmptyList(N)      | List(Number) | []int     | []              | []int          |
      | [1,5]             | List(Number) | []int     | [1,5]           | []int          |
      | Null(List(N))     | List(Number) | []int     | nil             | []int          |
      | [1,5]             | List(Number) | [2]int    | [1,5] (array)   | [2]int         |
      | EmptyList(N)      | List(Number) | [0]int    | [] (array)      | [0]int         |
      | EmptyList(N)      | List(Number) | *[0]int   | &[] (array)     | *[0]int        |
      | [1,5]             | List(Number) | listIntAlias | listIntAlias{1,5} | listIntAlias |

    Examples: Maps
      | ctyValue          | ctyType     | goType         | expectedGoValue       | expectedGoType   |
      | EmptyMap(N)       | Map(Number) | map[string]int | {}                    | map[string]int   |
      | {"one":1,"five":5}| Map(Number) | map[string]int | {"one":1,"five":5}    | map[string]int   |
      | Null(Map(N))      | Map(Number) | map[string]int | nil                   | map[string]int   |
      | {"one":1,"five":5}| Map(Number) | mapIntAlias    | mapIntAlias{"one":1,"five":5} | mapIntAlias    |

    Examples: Sets (converted to Go slices/arrays)
      | ctyValue          | ctyType     | goType    | expectedGoValue | expectedGoType |
      | EmptySet(N)       | Set(Number) | []int     | []              | []int          |
      | Set([1,5])        | Set(Number) | []int     | [1,5]           | []int          | # Order might vary in Go slice
      | Set([1,5])        | Set(Number) | [2]int    | [1,5] (array)   | [2]int         | # Order might vary

    Examples: Objects (converted to Go structs)
      | ctyValue               | ctyType                       | goType             | expectedGoValue         | expectedGoType     |
      | EmptyObjectVal         | EmptyObject                   | struct{}           | {} (empty struct)       | struct{}           |
      | Obj({"name":"S"})      | Object({"name":S})            | testStruct         | {Name:"S",Number:nil}   | testStruct         |
      | Obj({"name":"S","num":12})| Object({"name":S,"number":N}) | testStruct         | {Name:"S",Number:&12}   | testStruct         |

    Examples: Tuples (converted to Go structs)
      | ctyValue               | ctyType                       | goType             | expectedGoValue         | expectedGoType     |
      | EmptyTupleVal          | EmptyTuple                    | struct{}           | {} (empty struct)       | struct{}           |
      | Tuple(["S",5])         | Tuple([S,N])                  | testTupleStruct    | {Name:"S",Number:5}     | testTupleStruct    |

    Examples: Capsules
      | ctyValue                      | ctyType                                       | goType                | expectedGoValue       | expectedGoType         |
      | CapsuleVal(&{capsuleA})       | Capsule("capsule type 1", capsuleType1Native) | capsuleType1Native    | {name:"capsuleA"}     | capsuleType1Native     |
      | CapsuleVal(&{capsuleA})       | Capsule("capsule type 1", capsuleType1Native) | *capsuleType1Native   | &{name:"capsuleA"}    | *capsuleType1Native    | # Pointer recovered

    Examples: Passthrough (cty.Value target)
      | ctyValue          | ctyType     | goType    | expectedGoValue   | expectedGoType |
      | 2                 | Number      | cty.Value | Cty(2)            | cty.Value      |
      | Unknown(Bool)     | Bool        | cty.Value | Unknown(Bool)     | cty.Value      |
      | Null(Bool)        | Bool        | cty.Value | Null(Bool)        | cty.Value      |
      | Dynamic           | Dynamic     | cty.Value | Dynamic           | cty.Value      |
      | Null(Dynamic)     | Dynamic     | cty.Value | Null(Dynamic)     | cty.Value      |
