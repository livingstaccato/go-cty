# Original Go Test File: cty/path_test.go
# This feature file covers tests for cty.Path objects, including application and equality.

Feature: cty Path Operations
  This feature describes how cty.Path objects are used to access nested
  elements within cty.Value structures and how paths are compared.

  Scenario Outline: Applying a path to a cty.Value
    # Covers test: TestPathApply
    Given a starting cty.Value <StartValue> of type <StartType>
    And a cty.Path <PathSteps>
    When the path is applied to the starting value
    Then the result should be cty.Value <ExpectedValue> of type <ExpectedType>
    And the error message, if any, should be "<ExpectedErrorMessage>"
    And if marks are involved, the result's marks should be the combination of marks from the start value and intermediate path elements

    Examples: Basic Path Application
      | StartValue    | StartType | PathSteps                     | ExpectedValue | ExpectedType | ExpectedErrorMessage |
      | String("hello") | String    | <nil>                         | String("hello") | String       |                      |
      | List(S("h"))  | List(S)   | [Index(Num(0))]               | String("h")   | String       |                      |
      | Tuple(S("h")) | Tuple(S)  | [Index(Num(0))]               | String("h")   | String       |                      |
      | Map(k=S("v")) | Map(S)    | [Index(Str("k"))]             | String("v")   | String       |                      |
      | Obj(a=S("v")) | Obj(a=S)  | [Attr("a")]                   | String("v")   | String       |                      |

    Examples: Path Application with Errors
      | StartValue    | StartType | PathSteps                     | ExpectedValue | ExpectedType | ExpectedErrorMessage                             |
      | String("hello") | String    | [Index(Str("b"))]             | NilValue      | NilType      | "at step 0: not a map type"                      |
      | String("hello") | String    | [Index(Num(0))]               | NilValue      | NilType      | "at step 0: not a list type"                     |
      | EmptyList(S)  | List(S)   | [Index(Num(0))]               | NilValue      | NilType      | "at step 0: value does not have given index key" |
      | List(S("h"))  | List(S)   | [Index(Num(0)), Attr("foo")]   | NilValue      | NilType      | "at step 1: not an object type"                  |
      | List(EmptyObj)| List(Obj) | [Index(Num(0)), Attr("foo")]   | NilValue      | NilType      | "at step 1: object has no attribute \"foo\""     |
      | Null(List(S)) | List(S)   | [Index(Num(0))]               | NilValue      | NilType      | "at step 0: cannot index a null value"           |
      | Null(EmptyObj)| Obj       | [Attr("foo")]                 | NilValue      | NilType      | "at step 0: cannot access attributes on a null value" |

    Examples: Path Application with Marks
      | StartValue                                 | StartType     | PathSteps                          | ExpectedValue              | ExpectedType | ExpectedErrorMessage |
      | List(List(S("h")).Mark(2)).Mark(1)         | List(List(S)) | [Index(Num(0)), Index(Num(0))]    | String("h").WithMarks(1,2) | String       |                      |
      | Tuple(List(S("h")).Mark(2)).Mark(1)        | Tuple(List(S))| [Index(Num(0)), Index(Num(0))]    | String("h").WithMarks(1,2) | String       |                      |
      | Map("k"=S("v")).Mark(1)                    | Map(S)        | [Index(Str("k"))]                  | String("v").Mark(1)        | String       |                      |
      | Obj("a"=S("v")).Mark(1)                    | Obj(a=S)      | [Attr("a")]                        | String("v").Mark(1)        | String       |                      |
      | List(S("h").Mark(1))                       | List(S)       | [Index(Num(0))]                    | String("h").Mark(1)        | String       |                      |

  Scenario Outline: Comparing two cty.Paths for equality or prefix relationship
    # Covers test: TestPathEquals
    Given a cty.Path "PathA" defined as <PathASteps>
    And a cty.Path "PathB" defined as <PathBSteps>
    When "PathA" is compared to "PathB"
    Then "PathA.Equals(PathB)" should return <IsEqual>
    And "PathA.HasPrefix(PathB)" should return <IsPrefix> (B is prefix of A)

    Examples:
      | PathASteps                                  | PathBSteps                                  | IsEqual | IsPrefix |
      | <nil>                                       | <nil>                                       | true    | true     |
      | []                                          | []                                          | true    | true     |
      | [Attr("a")]                                 | [Attr("a")]                                 | true    | true     |
      | [Attr("a"), Index(Unk(S))]                  | [Attr("a"), Index(Str("k"))]                | false   | false    | # Unknown key vs known key
      | [Attr("a"), Index(Unk(S))]                  | [Attr("a"), Index(Unk(S))]                  | true    | true     | # Two different UnknownVal(String) instances are equal as path keys
      | [Attr("a"), Index(Str("k"))]                | [Attr("a"), Index(Str("k")), Attr("b")]     | false   | false    | # B is longer
      | [Attr("a"), Index(Str("k")), Attr("b")]     | [Attr("a"), Index(Str("k"))]                | false   | true     | # B is a prefix of A
      | [Attr("a"), Index(Num(0.0))]                | [Attr("a"), Index(Num(0))]                  | true    | true     | # Number 0.0 equals 0
      | [Attr("a"), Index(Num(1))]                  | [Attr("a"), Index(Num(0))]                  | false   | false    |

    # Note on Syntax:
    # - Values: String("h"), Number(0) or Num(0), Str("k"), True, List(...), Map(...), Obj(...), EmptyList(Type), EmptyObj, Null(Type), Unknown(Type) or Unk(Type), NilValue
    # - Types: S=String, Obj=Object type, List(S)=List of String, etc.
    # - PathSteps: [Step1, Step2, ...]. <nil> for nil path. [] for empty path.
    #   - Attr("name") for GetAttrStep
    #   - Index(cty.Value) for IndexStep
    # - Marks: .Mark(m), .WithMarks(m1,m2)
    # - IsPrefix: True if PathB is a prefix of PathA.
