# Covers tests in cty/path_test.go

Feature: Path Application and Equality
  Background:
    Given a Go environment

  Scenario Outline: Apply a path to a cty.Value
    Given a starting cty.Value <startValue>
    And a cty.Path <path>
    When I apply the path to the starting value
    Then the result should be cty.Value <expectedValue>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples: Successful Applications
      | startValue                                     | path                                      | expectedValue                   | shouldError | errorMessage |
      | "hello"                                        | nil                                       | "hello"                         | should not  |              |
      | ["hello"]                                      | Index(0)                                  | "hello"                         | should not  |              |
      | Tuple(["hello"])                               | Index(0)                                  | "hello"                         | should not  |              |
      | [ [ "hello" ] (m 2) ] (m 1)                    | Index(0).Index(0)                         | "hello" (m 1, 2)                | should not  |              |
      | Tuple([ ["hello"](m 2) ]) (m 1)                | Index(0).Index(0)                         | "hello" (m 1, 2)                | should not  |              |
      | {"hello":"there"} (m 1)                        | Index("hello")                            | "there" (m 1)                   | should not  |              |
      | Obj({"hello":"there"}) (m 1)                   | GetAttr("hello")                          | "there" (m 1)                   | should not  |              |
      | ["hello" (m 1)]                                | Index(0)                                  | "hello" (m 1)                   | should not  |              |
      | Tuple(["hello" (m 1)])                         | Index(0)                                  | "hello" (m 1)                   | should not  |              |
      | {"hello":"there" (m 1)}                        | Index("hello")                            | "there" (m 1)                   | should not  |              |
      | Obj({"hello":"there" (m 1)})                   | GetAttr("hello")                          | "there" (m 1)                   | should not  |              |

    Examples: Application Errors
      | startValue                                     | path                                      | expectedValue | shouldError | errorMessage                                  |
      | "hello"                                        | Index("boop")                             |               | should      | "at step 0: not a map type"                   |
      | "hello"                                        | Index(0)                                  |               | should      | "at step 0: not a list type"                  |
      | EmptyList(S)                                   | Index(0)                                  |               | should      | "at step 0: value does not have given index key"|
      | ["hello"]                                      | Index(1)                                  |               | should      | "at step 0: value does not have given index key"|
      | ["hello"]                                      | Index(0).GetAttr("foo")                   |               | should      | "at step 1: not an object type"               |
      | [EmptyObject]                                  | Index(0).GetAttr("foo")                   |               | should      | "at step 1: object has no attribute \"foo\""  |
      | Null(List(S))                                  | Index(0)                                  |               | should      | "at step 0: cannot index a null value"        |
      | Null(Map(S))                                   | Index(0)                                  |               | should      | "at step 0: cannot index a null value"        | # Path was Index(0), but map keys are strings
      | Null(EmptyObject)                              | GetAttr("foo")                            |               | should      | "at step 0: cannot access attributes on a null value" |

  Scenario Outline: Compare two cty.Paths for equality and prefix relationship
    Given a cty.Path A: <pathA>
    And a cty.Path B: <pathB>
    When I check if path A equals path B
    Then the equality result should be <expectedEquality>
    When I check if path A has path B as a prefix
    Then the prefix result should be <expectedPrefix>

    Examples:
      | pathA                                      | pathB                                      | expectedEquality | expectedPrefix |
      | nil                                        | nil                                        | True             | True           |
      | EmptyPath                                  | EmptyPath                                  | True             | True           |
      | [nilStep]                                  | [GetAttr("attr")]                          | False            | False          |
      | [Attr("a"),Idx(Unk(S)),Attr("a")]          | [Attr("a"),Idx("k"),Attr("a")]             | False            | False          |
      | [Attr("a"),Idx(List([Unk(S)])),Attr("a")]  | [Attr("a"),Idx(List(["k"])),Attr("a")]     | False            | False          |
      | [Attr("a"),Idx(Unk(S))]                    | [Attr("a"),Idx("k"),Attr("a")]             | False            | False          |
      | [Attr("a"),Idx("k")]                       | [Attr("a"),Idx("k"),Attr("a")]             | False            | False          |
      | [Attr("a"),Idx("k"),Attr("a")]             | [Attr("a"),Idx("k")]                       | False            | True           |
      | [Attr("a"),Idx(Unk(S))]                    | [Attr("a"),Idx(Unk(S))]                    | True             | True           |
      | [Attr("a"),Idx(Num(0.0)),Attr("a")]        | [Attr("a"),Idx(Num(0)),Attr("a")]          | True             | True           |
      | [Attr("a"),Idx(Num(1)),Attr("a")]          | [Attr("a"),Idx(Num(0)),Attr("a")]          | False            | False          |
      | [GetAttr("attr")]                          | GetAttrPath("attr")                        | True             | True           |
      | [Index(Num(0))]                            | IndexPath(Num(0))                          | True             | True           |
      | [Index(Num(0))]                            | IndexIntPath(0)                            | True             | True           |
      | [Index(Str("key"))]                        | IndexStringPath("key")                     | True             | True           |
      | [GetAttr("attr"), Index(Num(0))]           | GetAttrPath("attr").IndexInt(0)            | True             | True           |
      | [GetAttr("attr"), Index(Str("key"))]       | GetAttrPath("attr").IndexString("key")     | True             | True           |
