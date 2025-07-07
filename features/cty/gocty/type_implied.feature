# Original Go Test File: cty/gocty/type_implied_test.go
# This feature file covers tests for inferring a cty.Type from a Go native value.

Feature: Implied cty.Type from Go Native Value
  This feature describes how a cty.Type is inferred from a given Go native value
  using the ImpliedType function. This is often used before converting a Go value
  to a cty.Value if the target cty.Type is not explicitly known.

  Scenario Outline: Inferring cty.Type from Go value
    # Covers test: TestImpliedType
    Given a Go native value <GoValue> of Go type <GoTypeDescription>
    When the ImpliedType function is called with this Go value
    Then the inferred cty.Type should be <ExpectedCtyType>
    And no error should occur

    Examples: Primitive Go Types
      | GoValue | GoTypeDescription | ExpectedCtyType |
      | 0       | int               | Number          |
      | int8(0) | int8              | Number          |
      | int16(0)| int16             | Number          |
      | int32(0)| int32             | Number          |
      | int64(0)| int64             | Number          |
      | uint(0) | uint              | Number          |
      | uint8(0)| uint8             | Number          |
      | uint16(0)| uint16            | Number          |
      | uint32(0)| uint32            | Number          |
      | uint64(0)| uint64            | Number          |
      | float32(0)| float32           | Number          |
      | float64(0)| float64           | Number          |
      | false   | bool              | Bool            |
      | ""      | string            | String          |

    Examples: Go Collection Types (Slices and Maps)
      | GoValue                     | GoTypeDescription        | ExpectedCtyType        |
      | ([]int)(nil)                | nil slice of int         | List(Number)           |
      | ([][]int)(nil)              | nil slice of slice of int| List(List(Number))     |
      | (map[string]int)(nil)       | nil map string to int    | Map(Number)            |
      | (map[string]map[string]int)(nil) | nil map string to map  | Map(Map(Number))       |
      | (map[string][]int)(nil)     | nil map string to slice  | Map(List(Number))      |

    Examples: Go Struct Types (Mapped to cty.Object)
      | GoValue    | GoTypeDescription | ExpectedCtyType             |
      | testStruct{} | testStruct (defined in Go test) | Object("name"=S, "number"=N) | # Assumes testStruct has 'name' (string) and 'number' (int) with cty tags

    Examples: Go Pointer Types (Pointers are unwrapped)
      | GoValue        | GoTypeDescription | ExpectedCtyType             |
      | &intVal        | *int              | Number                      | # intVal is an int variable
      | &boolVal       | *bool             | Bool                        | # boolVal is a bool variable
      | &stringVal     | *string           | String                      | # stringVal is a string variable
      | &testStructVal | *testStruct       | Object("name"=S, "number"=N) | # testStructVal is a testStruct variable

    Examples: cty.Value Input
      | GoValue        | GoTypeDescription | ExpectedCtyType |
      | cty.NilVal     | cty.Value (NilVal)| DynamicType     | # cty.NilVal itself implies DynamicType

    # Note on Value/Type Syntax:
    # - GoValue: 0, false, "", ([]int)(nil), testStruct{} (a Go struct instance), &variable, cty.NilVal
    # - GoTypeDescription: A human-readable description of the Go type.
    # - ExpectedCtyType: Number, Bool, String, List(Type), Map(Type), Object(attr=Type,...), DynamicType
    # - S=String, N=Number.
    # - For pointer examples, assume corresponding non-pointer variables exist (e.g., intVal, boolVal).
    # - 'testStruct' is assumed to be the struct defined in the Go test with appropriate 'cty' tags.
