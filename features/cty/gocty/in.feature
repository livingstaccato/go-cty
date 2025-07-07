# Original Go Test File: cty/gocty/in_test.go
# This feature file covers tests for converting Go native values to cty.Value objects.

Feature: Go Native to cty.Value Conversion (ToCtyValue)
  This feature describes how various Go native data types are converted into
  cty.Value objects of a specified cty.Type using the ToCtyValue function.

  This feature describes how various Go native data types are converted into
  cty.Value objects of a specified cty.Type using the ToCtyValue function.

  When converting Go structs to cty.Object, fields are mapped to object attributes
  based on `cty:"attribute_name"` struct tags. If a tag is absent, the
  Go field name is used. Unmatched Go fields are ignored if not required by the
  target object type; missing required object attributes in the cty.Object type
  that are not nullable will typically result in an error or a best-effort conversion
  with nulls if the target attribute is optional or the source provides a Go nil pointer.

  Scenario Outline: Converting Go native value to cty.Value
    # Covers test: TestIn
    Given a Go native value <GoValue> of Go type <GoType>
    And a target cty.Type <TargetCtyType>
    When ToCtyValue is called with the Go value and target cty.Type
    Then the result should be the cty.Value <ExpectedCtyValue> of type <ExpectedCtyValueType>
    And no error should occur

    Examples: Boolean Conversions
      | GoValue      | GoType    | TargetCtyType | ExpectedCtyValue | ExpectedCtyValueType |
      | true         | bool      | Bool          | True             | Bool                 |
      | (*bool)(nil) | *bool     | Bool          | Null(Bool)       | Bool                 |
      | &true        | *bool     | Bool          | True             | Bool                 |

    Examples: String Conversions
      | GoValue          | GoType     | TargetCtyType | ExpectedCtyValue  | ExpectedCtyValueType |
      | "hello"          | string     | String        | String("hello")   | String               |
      | &"hello"         | *string    | String        | String("hello")   | String               |
      | &&"hello"        | **string   | String        | String("hello")   | String               | # Pointer to pointer
      | (*string)(nil)   | *string    | String        | Null(String)      | String               |
      | nil              | nil_interface | String        | Null(String)      | String               | # Untyped Go nil
      | (*bool)(nil)     | *bool      | String        | Null(String)      | String               | # Typed Go nil to different cty type

    Examples: Number Conversions (Integer and Float Types)
      | GoValue          | GoType     | TargetCtyType | ExpectedCtyValue  | ExpectedCtyValueType |
      | int(1)           | int        | Number        | Number(1)         | Number               |
      | int8(1)          | int8       | Number        | Number(1)         | Number               |
      | uint64(1)        | uint64     | Number        | Number(1)         | Number               |
      | float32(1.5)     | float32    | Number        | Number(1.5)       | Number               |
      | float64(1.5)     | float64    | Number        | Number(1.5)       | Number               |
      | big.NewFloat(1.5)| *big.Float | Number        | Number(1.5)       | Number               |
      | big.NewInt(5)    | *big.Int   | Number        | Number(5)         | Number               |
      | (*int)(nil)      | *int       | Number        | Null(Number)      | Number               |

    Examples: List Conversions (from Go Slices and Arrays)
      | GoValue        | GoType     | TargetCtyType | ExpectedCtyValue        | ExpectedCtyValueType |
      | []int{}        | []int      | List(Number)  | EmptyList(Number)       | List(Number)         |
      | []int{1,2}     | []int      | List(Number)  | List(Number(1),Number(2))| List(Number)         |
      | &[]int{1,2}    | *[]int     | List(Number)  | List(Number(1),Number(2))| List(Number)         |
      | ([]int)(nil)   | []int      | List(Number)  | Null(List(Number))      | List(Number)         |
      | (*[]int)(nil)  | *[]int     | List(Number)  | Null(List(Number))      | List(Number)         |
      | [2]int{1,2}    | [2]int     | List(Number)  | List(Number(1),Number(2))| List(Number)         |
      | [0]int{}       | [0]int     | List(Number)  | EmptyList(Number)       | List(Number)         |

    Examples: Set Conversions (from Go Slices, Arrays, and cty.set.Set)
      | GoValue        | GoType     | TargetCtyType | ExpectedCtyValue      | ExpectedCtyValueType |
      | []int{}        | []int      | Set(Number)   | EmptySet(Number)      | Set(Number)          |
      | []int{1,2}     | []int      | Set(Number)   | Set(Number(1),Number(2))| Set(Number)          |
      | []int{2,2}     | []int      | Set(Number)   | Set(Number(2))        | Set(Number)          | # Duplicates removed
      | cty_set_empty  | cty_set.Set| Set(Number)   | EmptySet(Number)      | Set(Number)          | # cty.set.Set instance
      | cty_set_1_2    | cty_set.Set| Set(Number)   | Set(Number(1),Number(2))| Set(Number)          | # cty.set.Set instance

    Examples: Map Conversions (from Go map[string]T)
      | GoValue                 | GoType          | TargetCtyType | ExpectedCtyValue             | ExpectedCtyValueType |
      | map[string]int{}        | map[string]int  | Map(Number)   | EmptyMap(Number)             | Map(Number)          |
      | map[string]int{"one":1} | map[string]int  | Map(Number)   | Map("one"=Number(1))         | Map(Number)          |

    Examples: Object Conversions (from Go Structs with `cty` tags or map[string]interface{})
      | GoValue (Struct)      | GoType (Struct) | TargetCtyType             | ExpectedCtyValue                   | ExpectedCtyValueType |
      | struct{}{}            | struct{}        | EmptyObject               | EmptyObjectVal                     | EmptyObject          |
      | struct{Ignored int}{1}| struct{Ignored int} | EmptyObject           | EmptyObjectVal                     | EmptyObject          | # Untagged field ignored
      | struct{}{}            | struct{}        | Object("name"=String)     | Obj("name"=Null(String))           | Object("name"=String)| # Missing attribute becomes null
      | testStruct{"S",1}     | testStruct      | Object("name"=S,"num"=N)  | Obj("name"=S("S"),"num"=N(1))      | Object("name"=S,"num"=N) | # Using cty tags
      | map[string]interface{}{"name":"S","number":1} | map[string]interface{} | Object("name"=S,"num"=N) | Obj("name"=S("S"),"num"=N(1)) | Object("name"=S,"num"=N) |

    Examples: Tuple Conversions (from Go []interface{} or Structs without tags - by order)
      | GoValue                 | GoType          | TargetCtyType        | ExpectedCtyValue           | ExpectedCtyValueType |
      | []interface{}{}         | []interface{}   | EmptyTuple           | EmptyTupleVal              | EmptyTuple           |
      | struct{}{}              | struct{}        | EmptyTuple           | EmptyTupleVal              | EmptyTuple           |
      | testTupleStruct{"S",23} | testTupleStruct | Tuple(String,Number) | Tuple(S("S"),N(23))        | Tuple(String,Number) |
      | []interface{}{1,"h",3}  | []interface{}   | Tuple(N,S,N)         | Tuple(N(1),S("h"),N(3))    | Tuple(N,S,N)         |

    Examples: Capsule Conversions
      | GoValue           | GoType              | TargetCtyType | ExpectedCtyValue            | ExpectedCtyValueType |
      | capsuleA_native   | *capsuleType1Native | capsuleType1  | Capsule(capsuleType1, &val) | capsuleType1         |

    Examples: DynamicType Target (values often pass through or are wrapped)
      | GoValue                 | GoType          | TargetCtyType      | ExpectedCtyValue        | ExpectedCtyValueType |
      | Number(2)               | cty.Value       | DynamicType        | Number(2)               | Number               | # cty.Value passes through
      | []cty.Value{Number(2)}  | []cty.Value     | List(DynamicType)  | List(Number(2))         | List(Number)         | # Inner type preserved
      | map[string]cty.Value{"num":Number(2)} | map[string]cty.Value | Map(DynamicType)| Map("num"=Number(2))    | Map(Number)          |

    Examples: Passthrough (cty.Value input to matching cty.Type)
      | GoValue        | GoType    | TargetCtyType | ExpectedCtyValue | ExpectedCtyValueType |
      | Number(2)      | cty.Value | Number        | Number(2)        | Number               |
      | String("hi")   | cty.Value | String        | String("hi")     | String               |

    # Note on Value Syntax:
    # - Go values: true, "hello", int(1), &variable, nil, struct{}{}, map[string]int{}, []int{}
    # - cty values: True, String("hello"), Number(1), Null(Type), EmptyList(Type), List(...), Obj(...), Tuple(...)
    # - Types: S=String, N=Number, B=Bool. capsuleType1 is a predefined test capsule.
    # - capsuleA_native is a Go pointer to a capsuleType1Native struct. ExpectedCtyValue will be a capsule containing this pointer.
    # - cty_set_empty and cty_set_1_2 represent pre-created cty.set.Set instances for testing.
    # - testStruct and testTupleStruct are specific Go struct types defined in the Go test.
    # - nil_interface refers to an untyped Go nil.
