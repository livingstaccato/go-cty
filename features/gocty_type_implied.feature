# Covers tests in cty/gocty/type_implied_test.go

Feature: Implied Cty Type from Go Value
  Background:
    Given a Go environment

  Scenario Outline: Determine implied cty.Type from a Go value
    Given a Go value <goValue> of Go type <goTypeDescription>
    When I determine the implied cty.Type
    Then the result should be cty.Type <expectedCtyType>
    And no error should occur

    Examples: Primitive Types
      | goValue | goTypeDescription | expectedCtyType |
      | 0       | int               | Number          |
      | 0       | int8              | Number          |
      | 0       | int16             | Number          |
      | 0       | int32             | Number          |
      | 0       | int64             | Number          |
      | 0       | uint              | Number          |
      | 0       | uint8             | Number          |
      | 0       | uint16            | Number          |
      | 0       | uint32            | Number          |
      | 0       | uint64            | Number          |
      | 0.0     | float32           | Number          |
      | 0.0     | float64           | Number          |
      | false   | bool              | Bool            |
      | ""      | string            | String          |

    Examples: Collection Types
      | goValue           | goTypeDescription        | expectedCtyType        |
      | nil               | []int                    | List(Number)           |
      | nil               | [][]int                  | List(List(Number))     |
      | nil               | map[string]int           | Map(Number)            |
      | nil               | map[string]map[string]int| Map(Map(Number))       |
      | nil               | map[string][]int         | Map(List(Number))      |

    Examples: Structs
      | goValue           | goTypeDescription        | expectedCtyType                 |
      | testStruct{}      | testStruct               | Object({"name":S,"number":N})   | # Assumes testStruct has Name (string) and Number (int/*int) fields with cty tags

    Examples: Pointers (unwrapped and ignored)
      | goValue           | goTypeDescription        | expectedCtyType                 |
      | &0                | *int                     | Number                          |
      | &false            | *bool                    | Bool                            |
      | &""               | *string                  | String                          |
      | &testStruct{}     | *testStruct              | Object({"name":S,"number":N})   |

    Examples: Dynamic Type
      | goValue           | goTypeDescription        | expectedCtyType                 |
      | cty.NilVal        | cty.Value (NilType)      | Dynamic                         |
