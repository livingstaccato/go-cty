# Original Go Test File: cty/gocty/out_test.go
# This feature file covers tests for converting cty.Value objects to Go native values.

Feature: cty.Value to Go Native Conversion (FromCtyValue)
  This feature describes how cty.Value objects are converted into Go native
  data types, populating a Go variable of a specified reflect.Type.

  Scenario Outline: Converting cty.Value to Go native value
    # Covers test: TestOut
    Given a cty.Value <CtyValue> of cty type <CtyValueType>
    And a target Go reflect.Type <TargetGoType>
    When FromCtyValue is called with the cty.Value and a pointer to a Go variable of the target type
    Then the Go variable should be populated with <ExpectedGoValue>
    And no error should occur

    Examples: Boolean Conversions
      | CtyValue     | CtyValueType | TargetGoType | ExpectedGoValue |
      | True         | Bool         | bool         | true            |
      | False        | Bool         | bool         | false           |
      | True         | Bool         | *bool        | &true           |
      | Null(Bool)   | Bool         | *bool        | (*bool)(nil)    |
      | True         | Bool         | boolAlias    | boolAlias(true) |

    Examples: String Conversions
      | CtyValue        | CtyValueType | TargetGoType | ExpectedGoValue     |
      | String("hello") | String       | string       | "hello"             |
      | String("")      | String       | string       | ""                  |
      | String("hello") | String       | *string      | &"hello"            |
      | Null(String)    | String       | *string      | (*string)(nil)      |
      | String("hello") | String       | stringAlias  | stringAlias("hello")|

    Examples: Number Conversions (Integer, Float, Big Types)
      | CtyValue     | CtyValueType | TargetGoType | ExpectedGoValue   |
      | Number(5)    | Number       | int          | int(5)            |
      | Number(5)    | Number       | int8         | int8(5)           |
      | Number(5)    | Number       | uint64       | uint64(5)         |
      | Number(1.5)  | Number       | float32      | float32(1.5)      |
      | Number(1.5)  | Number       | float64      | float64(1.5)      |
      | Number(1.5)  | Number       | *big.Float   | big.NewFloat(1.5) |
      | Number(5)    | Number       | *big.Int     | big.NewInt(5)     |
      | Number(5)    | Number       | intAlias     | intAlias(5)       |
      | Number(1.5)  | Number       | float64Alias | float64Alias(1.5) |
      | Number(5)    | Number       | *bigIntAlias | &bigIntAlias(5)   |

    Examples: List Conversions (to Go Slices and Arrays)
      | CtyValue                  | CtyValueType | TargetGoType | ExpectedGoValue         |
      | EmptyList(Number)         | List(Number) | []int        | []int{}                 |
      | List(Number(1),Number(5)) | List(Number) | []int        | []int{1,5}              |
      | Null(List(Number))        | List(Number) | []int        | ([]int)(nil)            |
      | List(Number(1),Number(5)) | List(Number) | [2]int       | [2]int{1,5}             |
      | EmptyList(Number)         | List(Number) | [0]int       | [0]int{}                |
      | EmptyList(Number)         | List(Number) | *[0]int      | &[0]int{}               |
      | List(Number(1),Number(5)) | List(Number) | listIntAlias | listIntAlias{1,5}       |

    Examples: Map Conversions (to Go map[string]T)
      | CtyValue                  | CtyValueType | TargetGoType   | ExpectedGoValue              |
      | EmptyMap(Number)          | Map(Number)  | map[string]int | map[string]int{}             |
      | Map("one"=N(1),"five"=N(5))| Map(Number)  | map[string]int | map[string]int{"one":1,"five":5} |
      | Null(Map(Number))         | Map(Number)  | map[string]int | (map[string]int)(nil)        |
      | Map("one"=N(1),"five"=N(5))| Map(Number)  | mapIntAlias    | mapIntAlias{"one":1,"five":5} |

    Examples: Set Conversions (to Go Slices and Arrays - order may vary but is consistent for test)
      | CtyValue                  | CtyValueType | TargetGoType | ExpectedGoValue         |
      | EmptySet(Number)          | Set(Number)  | []int        | []int{}                 |
      | Set(Number(1),Number(5))  | Set(Number)  | []int        | []int{1,5}              | # Order sorted for test
      | Set(Number(1),Number(5))  | Set(Number)  | [2]int       | [2]int{1,5}             | # Order sorted for test

    Examples: Object Conversions (to Go Structs with `cty` tags)
      | CtyValue                      | CtyValueType          | TargetGoType | ExpectedGoValue         |
      | EmptyObjectVal                | EmptyObject           | struct{}     | struct{}{}              |
      | Obj("name"=String("Stephen")) | Object("name"=String) | testStruct   | testStruct{Name:"Stephen", Number:nil} |
      | Obj("name"=S("S"),"num"=N(12))| Object("name"=S,"num"=N)| testStruct | testStruct{Name:"S", Number:&int12} |

    Examples: Tuple Conversions (to Go Structs - by order)
      | CtyValue                  | CtyValueType      | TargetGoType    | ExpectedGoValue           |
      | EmptyTupleVal             | EmptyTuple        | struct{}        | struct{}{}                |
      | Tuple(S("S"),N(5))        | Tuple(String,Num) | testTupleStruct | testTupleStruct{"S",5}    |

    Examples: Capsule Conversions
      | CtyValue                            | CtyValueType | TargetGoType         | ExpectedGoValue            |
      | Capsule(capsuleType1, &capsuleValA) | capsuleType1 | capsuleType1Native   | capsuleType1Native{"capsuleA"} |
      | Capsule(capsuleType1, &capsuleValA) | capsuleType1 | *capsuleType1Native  | &capsuleValA_original_ptr  | # Original pointer recovered

    Examples: Passthrough (cty.Value target type)
      | CtyValue        | CtyValueType | TargetGoType | ExpectedGoValue   |
      | Number(2)       | Number       | cty.Value    | Number(2)         |
      | Unknown(Bool)   | Bool         | cty.Value    | Unknown(Bool)     |
      | Null(Bool)      | Bool         | cty.Value    | Null(Bool)        |
      | Dynamic         | DynamicType  | cty.Value    | Dynamic           |
      | Null(DynamicType)| DynamicType  | cty.Value    | Null(DynamicType) |

    # Note on Value Syntax:
    # - Go values: true, "hello", int(5), &variable, (*bool)(nil), big.NewFloat(1.5), []int{1,5}, map[string]int{"k":1}
    # - cty values: True, String("hello"), Number(5), Null(Type), EmptyList(Type), List(...), Obj(key=Val), Capsule(type, &goVal)
    # - Types: S=String, N=Number. capsuleType1 is a predefined test capsule.
    # - Go types: bool, string, int, *bool, []int, map[string]int, struct{}, specific struct types (testStruct, testTupleStruct), type aliases (boolAlias).
    # - &capsuleValA_original_ptr indicates that the original Go pointer encapsulated in the cty.CapsuleVal is expected.
    # - &int12 represents a pointer to an int with value 12.
    # - The Go variable to be populated is created via reflect.New(TargetGoType).Elem().Interface() for non-pointer ExpectedGoValues,
    #   or reflect.New(TargetGoType).Interface() for pointer ExpectedGoValues, then its Elem() is compared.
    # - For pointer ExpectedGoValues like &true or (*bool)(nil), the test asserts the pointed-to value or nil-ness.
