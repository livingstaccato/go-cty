# Covers tests in cty/gocty/in_test.go

Feature: Go To Cty Value Conversion (ToCtyValue)
  Background:
    Given a Go environment

  Scenario Outline: Convert Go value to cty value
    Given a Go value <goValue> of Go type <goType>
    And a target cty.Type <ctyType>
    When I convert the Go value to a cty.Value
    Then the result should be cty.Value <expectedCtyValue> of type <expectedCtyType>
    And no error should occur

    Examples: Boolean
      | goValue           | goType      | ctyType | expectedCtyValue | expectedCtyType |
      | true              | bool        | Bool    | True             | Bool            |
      | nil               | *bool       | Bool    | Null(Bool)       | Bool            |
      | &true             | *bool       | Bool    | True             | Bool            |

    Examples: String
      | goValue           | goType      | ctyType | expectedCtyValue | expectedCtyType |
      | "hello"           | string      | String  | "hello"          | String          |
      | &"hello"          | *string     | String  | "hello"          | String          |
      | &&"hello"         | **string    | String  | "hello"          | String          |
      | nil               | *string     | String  | Null(String)     | String          |
      | nil               | nil-interface | String  | Null(String)     | String          | # any nil to null
      | nil               | *bool       | String  | Null(String)     | String          | # any nil to null

    Examples: Number
      | goValue           | goType      | ctyType | expectedCtyValue | expectedCtyType |
      | 1                 | int         | Number  | 1                | Number          |
      | 1                 | int8        | Number  | 1                | Number          |
      | 1                 | int16       | Number  | 1                | Number          |
      | 1                 | int32       | Number  | 1                | Number          |
      | 1                 | int64       | Number  | 1                | Number          |
      | 1                 | uint        | Number  | 1                | Number          |
      | 1                 | uint8       | Number  | 1                | Number          |
      | 1                 | uint16      | Number  | 1                | Number          |
      | 1                 | uint32      | Number  | 1                | Number          |
      | 1                 | uint64      | Number  | 1                | Number          |
      | 1.5               | float32     | Number  | 1.5              | Number          |
      | 1.5               | float64     | Number  | 1.5              | Number          |
      | BigFloat(1.5)     | *big.Float  | Number  | 1.5              | Number          |
      | BigInt(5)         | *big.Int    | Number  | 5                | Number          |
      | nil               | *int        | Number  | Null(Number)     | Number          |

    Examples: Lists
      | goValue           | goType      | ctyType      | expectedCtyValue   | expectedCtyType   |
      | []                | []int       | List(Number) | EmptyList(Number)  | List(Number)    |
      | [1,2]             | []int       | List(Number) | [1,2]              | List(Number)    |
      | &[1,2]            | *[]int      | List(Number) | [1,2]              | List(Number)    |
      | nil               | []int       | List(Number) | Null(List(Number)) | List(Number)    |
      | nil               | *[]int      | List(Number) | Null(List(Number)) | List(Number)    |
      | [1,2] (array)     | [2]int      | List(Number) | [1,2]              | List(Number)    |
      | [] (array)        | [0]int      | List(Number) | EmptyList(Number)  | List(Number)    |
      | []                | []int       | Set(Number)  | EmptySet(Number)   | Set(Number)     | # List to Set

    Examples: Sets
      | goValue           | goType      | ctyType     | expectedCtyValue   | expectedCtyType  |
      | [1,2]             | []int       | Set(Number) | Set([1,2])         | Set(Number)    |
      | [2,2]             | []int       | Set(Number) | Set([2])           | Set(Number)    |
      | &[1,2]            | *[]int      | Set(Number) | Set([1,2])         | Set(Number)    |
      | nil               | []int       | Set(Number) | Null(Set(Number))  | Set(Number)    |
      | nil               | *[]int      | Set(Number) | Null(Set(Number))  | Set(Number)    |
      | [1,2] (array)     | [2]int      | Set(Number) | Set([1,2])         | Set(Number)    |
      | [] (array)        | [0]int      | Set(Number) | EmptySet(Number)   | Set(Number)    |
      | EmptyCtySet       | cty.Set     | Set(Number) | EmptySet(Number)   | Set(Number)    |
      | CtySet([1,2])     | cty.Set     | Set(Number) | Set([1,2])         | Set(Number)    |

    Examples: Maps
      | goValue           | goType          | ctyType     | expectedCtyValue      | expectedCtyType |
      | {}                | map[string]int  | Map(Number) | EmptyMap(Number)      | Map(Number)     |
      | {"one":1,"two":2} | map[string]int  | Map(Number) | {"one":1,"two":2}     | Map(Number)     |

    Examples: Objects
      | goValue           | goType                          | ctyType                          | expectedCtyValue                      | expectedCtyType                        |
      | {} (empty struct) | struct{}                        | EmptyObject                      | EmptyObjectVal                        | EmptyObject                            |
      | {Ignored:1}       | struct{Ignored int}             | EmptyObject                      | EmptyObjectVal                        | EmptyObject                            |
      | {} (empty struct) | struct{}                        | Object({"name":S})               | Obj({"name":Null(S)})                 | Object({"name":S})                     |
      | {"S",1}           | struct{Name string;Number int}  | Object({"name":S,"number":N})    | Obj({"name":"S","number":1})          | Object({"name":S,"number":N})          |
      | {"S",1}           | struct{Name string;Number int}  | Object({"name":S,"number":N})    | Obj({"name":"S","number":Null(N)})    | Object({"name":S,"number":N})          | # Number field not tagged
      | {"name":"S","num":1}| map[string]interface{}          | Object({"name":S,"number":N})    | Obj({"name":"S","number":1})          | Object({"name":S,"number":N})          |
      | {"num":1}         | map[string]interface{}          | Object({"name":S,"number":N})    | Obj({"name":Null(S),"number":1})      | Object({"name":S,"number":N})          |

    Examples: Tuples
      | goValue           | goType                          | ctyType                          | expectedCtyValue              | expectedCtyType                        |
      | []                | []interface{}                   | EmptyTuple                       | EmptyTupleVal                 | EmptyTuple                             |
      | {} (empty struct) | struct{}                        | EmptyTuple                       | EmptyTupleVal                 | EmptyTuple                             |
      | {"S",23}          | struct{string;int}              | Tuple([S,N])                     | Tuple(["S",23])               | Tuple([S,N])                           |
      | [1,2,3]           | []interface{}                   | Tuple([N,N,N])                   | Tuple([1,2,3])                | Tuple([N,N,N])                         |
      | [1,"h",3]         | []interface{}                   | Tuple([N,S,N])                   | Tuple([1,"h",3])              | Tuple([N,S,N])                         |
      | nil               | []interface{}                   | Tuple([N])                       | Null(Tuple([N]))              | Tuple([N])                             |

    Examples: Capsules
      | goValue           | goType                          | ctyType                          | expectedCtyValue              | expectedCtyType                        |
      | &{capsuleA}       | *capsuleType1Native             | Capsule("capsule type 1", capsuleType1Native) | CapsuleVal(&{capsuleA}) | Capsule("capsule type 1", capsuleType1Native) |

    Examples: Dynamic
      | goValue           | goType                          | ctyType                          | expectedCtyValue              | expectedCtyType                        |
      | Cty(2)            | cty.Value (Number)              | Dynamic                          | 2                             | Number                                 |
      | [Cty(2)]          | []cty.Value                     | List(Dynamic)                    | [2]                           | List(Number)                           |
      | {"num":Cty(2)}    | map[string]cty.Value            | Map(Dynamic)                     | {"num":2}                     | Map(Number)                            |

    Examples: Passthrough (cty.Value input)
      | goValue           | goType                          | ctyType                          | expectedCtyValue              | expectedCtyType                        |
      | Cty(2)            | cty.Value (Number)              | Number                           | 2                             | Number                                 |
      | Cty("hi")         | cty.Value (String)              | String                           | "hi"                          | String                                 |
