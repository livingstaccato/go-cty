# Original Go Test File: cty/marks_test.go
# This feature file covers tests for the cty value marking system.

Feature: cty Value Marks
  This feature describes how cty values can be "marked" with opaque data,
  how these marks are propagated, and how they can be inspected or removed.
  Marks do not affect a value's core type or equality for cty operations
  but can be used to track metadata like sensitivity or provenance.
  Mark values themselves can be of any comparable Go type (e.g., string, int).

  Scenario Outline: Checking if a value contains any marks (ContainsMarked)
    # Covers test: TestContainsMarked
    Given a cty.Value <Value>
    When its `ContainsMarked` status is checked
    Then the result should be <ExpectedContainsMarkedStatus>

    Examples:
      | Value                                       | ExpectedContainsMarkedStatus | Description                                           |
      | String("a")                                 | false                        | Unmarked primitive                                    |
      | Number(1).Mark("a")                         | true                         | Marked primitive                                      |
      | List(Num(1), Num(2))                        | false                        | Unmarked list with unmarked elements                  |
      | List(Num(1), Num(2).Mark("a"))              | true                         | List with a marked element                            |
      | List(Num(1), Num(2)).Mark("a")              | true                         | Marked list                                           |
      | EmptyList(String).Mark("c")                 | true                         | Marked empty list                                     |
      | Map(a=S("b").Mark(c), x=S("y").Mark(z))     | true                         | Map with marked elements                              |
      | Tuple(Num(1).Mark(a), S("y").Mark(z))       | true                         | Tuple with marked elements                            |
      | Set(Num(1).Mark(a), Num(2).Mark(z))         | true                         | Set with marks from elements (marks aggregate on set) |
      | Obj(x=List(N(1).Mark(a),N(2)), y=S("y"), z=True) | true                     | Object with a nested marked element                   |

  Scenario Outline: Checking if a value itself is marked (IsMarked)
    # Covers test: TestIsMarked
    Given a cty.Value <Value>
    When its `IsMarked` status is checked
    Then the result should be <ExpectedIsMarkedStatus>

    Examples:
      | Value                                | ExpectedIsMarkedStatus | Description                          |
      | String("a")                          | false                  | Unmarked primitive                   |
      | Number(1).Mark("a")                  | true                   | Marked primitive                     |
      | List(Num(1), Num(2))                 | false                  | Unmarked list                        |
      | List(Num(1), Num(2).Mark("a"))       | false                  | List itself is not marked            |
      | List(Num(1), Num(2)).Mark("a")       | true                   | Marked list                          |

  Scenario: Managing and inspecting value marks
    # Covers test: TestValueMarks
    Given an initial cty.Value True named "v_orig"
    When "v1" is created by marking "v_orig" with mark "1"
    And "v2" is created by marking "v_orig" with mark "2"
    Then "v_orig" should have no marks
    And "v1" should have marks ["1"]
    And "v2" should have marks ["2"]

    When "v12" is created from cty.Value False with the combined marks of "v_orig", "v1", and "v2"
    Then "v12" should have marks ["1", "2"]

    When "v12_again" is created by marking "v12" with mark "1"
    Then "v12_again" should still have marks ["1", "2"] (mark "1" was already present)

    When "v1234" is created by "v12" taking on additional marks ["2", "3", "4"]
    Then "v1234" should have marks ["1", "2", "3", "4"]
    And "v1234" should have mark "2"
    And "v1234" should not have mark "5"

    When "v_unmarked" and "marks_1234" are obtained by unmarking "v1234"
    Then "v_unmarked" should be cty.Value False
    And "v_unmarked" should have no marks
    And "marks_1234" should be the set of marks ["1", "2", "3", "4"]

  Scenario: Mark propagation through operations
    # Covers test: TestValueMarks (arithmetic marks propagation part)
    Given cty.Value "a_val" as Number(2) marked "a"
    And cty.Value "b_val" as Number(5) marked "b"
    And cty.Value "c_val" as Number(1) marked "c"
    And cty.Value "d_val" as Number(12) marked "d"
    When "result" is calculated as (a_val * b_val - c_val) >= d_val
    Then "result" should be cty.Value False
    And "result" should have marks ["a", "b", "c", "d"]

  Scenario: Deep unmarking and re-marking with paths
    # Covers test: TestValueMarks (UnmarkDeepWithPaths and MarkWithPaths part)
    Given a complex marked cty.Value "initial_result" (e.g., False with marks ["a","b","c","d"])
    When "unmarked_deep_result" and "path_value_marks_list" are obtained by deep unmarking "initial_result" with paths
    And "remarked_result" is created by marking "unmarked_deep_result" with "path_value_marks_list"
    Then "remarked_result" should be RawEqualTo "initial_result"

    When "marked_with_no_paths_result" is created by marking "unmarked_deep_result" with a non-matching PathValueMarks list (e.g., path [0], marks ["z"])
    Then "marked_with_no_paths_result" should be RawEqualTo "unmarked_deep_result" (i.e., remain unmarked)

  Scenario Outline: PathValueMarks equality
    # Covers test: TestPathValueMarksEqual
    Given a PathValueMarks "pvm1" with path <Path1> and marks <Marks1>
    And a PathValueMarks "pvm2" with path <Path2> and marks <Marks2>
    When "pvm1" is compared for equality with "pvm2"
    Then the result should be <IsEqual>

    Examples:
      | Path1          | Marks1 | Path2          | Marks2 | IsEqual |
      | [IdxKey(Num(0))] | ["a"]  | [IdxKey(Num(0))] | ["a"]  | true    |
      | [IdxKey(Str("p"))]| [123]  | [IdxKey(Str("p"))]| [123]  | true    |
      | [IdxKey(Num(0))] | ["a"]  | [IdxKey(Num(1))] | ["a"]  | false   | # Different path
      | [IdxKey(Num(0))] | ["a"]  | [IdxKey(Num(0))] | ["b"]  | false   | # Different marks
      | [IdxKey(Num(0))] | ["a"]  | [IdxKey(Num(1))] | ["b"]  | false   | # Different path and marks

  Scenario: Basic mark, unmark, and WithMarks operations
    # Covers test: TestMarks
    Given an unmarked cty.String "foo"
    When it is marked with "a", resulting in "val_a"
    Then "val_a" should have marks ["a"]
    When "val_a" is unmarked, resulting in "unmarked_val_a" and "marks_a"
    Then "unmarked_val_a" should not be marked
    And "marks_a" should be ["a"]

    When "val_abc" is created by taking "unmarked_val_a" and applying marks ["a", "b", "c"] using WithMarks
    Then "val_abc" should have marks ["a", "b", "c"]

    When "val_ab_separate" is created by marking "unmarked_val_a" with "a", then with "b"
    Then "val_ab_separate" should have marks ["a", "b"]

  Scenario Outline: Deep unmarking of values (UnmarkDeep)
    # Covers test: TestUnmarkDeep
    Given a cty.Value <OriginalValue> (potentially marked and nested)
    When `UnmarkDeep` is called on <OriginalValue>, resulting in <UnmarkedValue> and <AggregatedMarks>
    Then <UnmarkedValue> should be RawEqualTo <ExpectedUnmarkedBaseValue>
    And <AggregatedMarks> should be equal to the set of marks <ExpectedAggregatedMarks>

    Examples:
      | OriginalValue                                  | ExpectedUnmarkedBaseValue                | ExpectedAggregatedMarks   |
      | String("a")                                    | String("a")                              | []                        |
      | Number(1).Mark("a")                            | Number(1)                                | ["a"]                     |
      | List(N(1).Mark(a), N(2))                       | List(N(1), N(2))                         | ["a"]                     |
      | List(N(1).M(a), N(2).M(b)).M(c)                 | List(N(1), N(2))                         | ["a", "b", "c"]           |
      | EmptyList(String).Mark("c")                    | EmptyList(String)                        | ["c"]                     |
      | Map(a=S("b").M(c), x=S("y").M(z))               | Map(a=S("b"), x=S("y"))                  | ["c", "z"]                |
      | Set(N(1).M(a), N(2).M(z))                       | Set(N(1), N(2))                          | ["a", "z"]                | # Set elements' marks aggregate
      | Obj(x=List(N(3).M(a),N(5).M(b)).WithMarks(c,d), y=S("y").M(e), z=True.M(f)).M(g) | Obj(x=List(N(3),N(5)), y=S("y"), z=True) | ["a","b","c","d","e","f","g"] |

  Scenario Outline: Deep unmarking with paths and re-marking (UnmarkDeepWithPaths, MarkWithPaths)
    # Covers test: TestPathValueMarks
    Given a cty.Value <OriginalMarkedValue>
    When it is deep unmarked with paths, yielding <BaseUnmarkedValue> and <PathValueMarksList>
    And then <BaseUnmarkedValue> is re-marked using <PathValueMarksList>
    Then the re-marked value should be RawEqualTo <OriginalMarkedValue>
    And <BaseUnmarkedValue> should be RawEqualTo <ExpectedBaseUnmarkedValue>
    And <PathValueMarksList> should correctly represent the original marks and their paths

    Examples:
      | OriginalMarkedValue                       | ExpectedBaseUnmarkedValue        | Description                                 |
      | String("a")                               | String("a")                      | Unmarked primitive                          |
      | Number(1).Mark("a")                       | Number(1)                        | Marked primitive                            |
      | List(N(1).Mark(a), N(2))                  | List(N(1), N(2))                 | List with one marked element                |
      | List(N(1).M(a),N(2).M(b)).M(c)             | List(N(1),N(2))                  | Marked list with marked elements            |
      | EmptyList(String).Mark("c")               | EmptyList(String)                | Marked empty list                           |
      | Map(a=S("b").M(c), x=S("y").M(z))          | Map(a=S("b"), x=S("y"))          | Map with marked elements                    |
      | Obj(env=List(Obj(vars=Map(b=S("s").M(sen),f=S("s").M(sen))))) | Obj(env=List(Obj(vars=Map(b=S("s"),f=S("s"))))) | Regression test for path array reuse      |
      # The PathValueMarksList for each example would be detailed, e.g. for Number(1).Mark("a"): [{Path{}, ["a"]}]

  Scenario: Re-applying PathValueMarks to an already marked value
    # Covers test: TestReapplyMarks
    Given an cty.Object <InitialObject> with a nested attribute "nested.attr"
    And a PathValueMarks list "pvm_list" that marks the "nested" attribute with "mark"
    When "marked_once_object" is created by marking <InitialObject> with "pvm_list"
    And "marked_twice_object" is created by marking "marked_once_object" with "pvm_list" again
    Then "marked_twice_object" should be RawEqualTo "marked_once_object"

    # Note on Value/Type Syntax:
    # - String("a"), Number(1) or N(1), True, List(...), Map(key=Val), Tuple(...), Set(...), Obj(key=Val)
    # - .Mark(mark_name) or .M(mark_name)
    # - Marks are represented as lists of strings, e.g., ["a", "b"]
    # - Path syntax: [IdxKey(KeyValue)], [GetAttrStep(AttrName)] - simplified for readability in examples.
    # - S=String. sen=sensitive (a mark). Other letters a,b,c.. also represent marks.
