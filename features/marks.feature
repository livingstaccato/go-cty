# Covers tests in cty/marks_test.go

Feature: Value Marks
  Background:
    Given a Go environment

  Scenario Outline: Check if a value or its nested elements contain any marks
    Given a cty.Value <value>
    When I check if the value contains any marks
    Then the result should be <expectedResult>

    Examples:
      | value                                                       | expectedResult |
      | "a"                                                         | False          |
      | Number(1) (m "a")                                           | True           |
      | [1,2]                                                       | False          |
      | [1, Number(2)(m "a")]                                       | True           |
      | [1,2] (m "a")                                               | True           |
      | EmptyList(S) (m "c")                                        | True           |
      | {"a":"b"(m "c"), "x":"y"(m "z")}                            | True           |
      | Tuple([Number(1)(m "a"), "y"(m "z")])                       | True           |
      | Set([Number(1)(m "a"), Number(2)(m "z")])                   | True           |
      | Obj({"x":[Number(1)(m "a"),2],"y":"y","z":True})            | True           |

  Scenario Outline: Check if a value itself is marked (not nested elements)
    Given a cty.Value <value>
    When I check if the value itself is marked
    Then the result should be <expectedResult>

    Examples:
      | value                                    | expectedResult |
      | "a"                                      | False          |
      | Number(1) (m "a")                        | True           |
      | [1,2]                                    | False          |
      | [1, Number(2)(m "a")]                    | False          | # Element is marked, not the list itself
      | [1,2] (m "a")                            | True           |

  Scenario: Manipulating Value Marks
    Given a cty.Value True named "v"
    And a cty.Value "v1" created by marking "v" with "1"
    And a cty.Value "v2" created by marking "v" with "2"
    Then the marks of "v" should be empty
    And the marks of "v1" should be ["1"]
    And the marks of "v2" should be ["2"]

    When I create "v12" as cty.Value False with marks from "v", "v1", and "v2"
    Then the marks of "v12" should be ["1", "2"]

    When I mark "v12" with "1" to create "v12Again"
    Then the marks of "v12Again" should be ["1", "2"] # Mark "1" already exists

    When I mark "v12" with new marks ["2", "3", "4"] to create "v1234"
    Then the marks of "v1234" should be ["1", "2", "3", "4"]
    And "v1234" should have mark "2"
    And "v1234" should not have mark "5"

    When I unmark "v1234" into "unmarked_v" and "marks_1234"
    Then "unmarked_v" should be cty.Value False
    And the marks of "unmarked_v" should be empty
    And "marks_1234" should be ["1", "2", "3", "4"]

  Scenario: Marks propagation through operations
    Given a cty.Value Number(2) marked "a" as "val_a"
    And a cty.Value Number(5) marked "b" as "val_b"
    And a cty.Value Number(1) marked "c" as "val_c"
    And a cty.Value Number(12) marked "d" as "val_d"
    When I compute (("val_a" * "val_b") - "val_c") >= "val_d" into "op_result"
    Then "op_result" should be cty.Value False with marks ["a", "b", "c", "d"]

  Scenario: UnmarkDeepWithPaths and MarkWithPaths
    Given a cty.Value `(Number(2)(m "a") * Number(5)(m "b")) - Number(1)(m "c") >= Number(12)(m "d")` as "complex_marked_val"
    When I deeply unmark "complex_marked_val" into "unmarked_val" and path-value-marks "pvms"
    And I remark "unmarked_val" with "pvms" into "remarked_val"
    Then "remarked_val" should be equal to "complex_marked_val"

    When I remark "unmarked_val" with path-value-marks [{Path: [IndexStep(Key:Number(0))], Marks: ["z"]}] into "marked_with_no_paths"
    Then "marked_with_no_paths" should be equal to "unmarked_val" # No matching paths

  Scenario Outline: PathValueMarks equality
    Given a PathValueMarks <pvm1>
    And a PathValueMarks <pvm2>
    When I check if <pvm1> equals <pvm2>
    Then the result should be <expectedEquality>

    Examples:
      | pvm1                                                | pvm2                                                | expectedEquality |
      | {Path:[Index(0)], Marks:["a"]}                      | {Path:[Index(0)], Marks:["a"]}                      | True             |
      | {Path:[Index("p")], Marks:[123]}                    | {Path:[Index("p")], Marks:[123]}                    | True             |
      | {Path:[Index(0)], Marks:["a"]}                      | {Path:[Index(1)], Marks:["a"]}                      | False            |
      | {Path:[Index(0)], Marks:["a"]}                      | {Path:[Index(0)], Marks:["b"]}                      | False            |
      | {Path:[Index(0)], Marks:["a"]}                      | {Path:[Index(1)], Marks:["b"]}                      | False            |

  Scenario: Basic Mark and Unmark operations
    Given a cty.Value String("foo")
    When I mark it with "a" to get "val_marked_a"
    Then the marks of "val_marked_a" should be ["a"]
    When I unmark "val_marked_a" into "unmarked_val1" and "marks1"
    Then "unmarked_val1" should not be marked
    And "marks1" should be ["a"]

    When I mark "unmarked_val1" with marks ["a", "b", "c"] to get "val_marked_abc"
    Then the marks of "val_marked_abc" should be ["a", "b", "c"]
    When I unmark "val_marked_abc" into "unmarked_val2" and "marks2"
    Then "unmarked_val2" should not be marked
    And "marks2" should be ["a", "b", "c"]

    When I mark "unmarked_val2" with "a" then with "b" to get "val_marked_ab_sep"
    Then the marks of "val_marked_ab_sep" should be ["a", "b"]
    When I unmark "val_marked_ab_sep" into "unmarked_val3" and "marks3"
    Then "unmarked_val3" should not be marked
    And "marks3" should be ["a", "b"]

  Scenario Outline: UnmarkDeep functionality
    Given a cty.Value <inputValue>
    When I deeply unmark the value into "unmarkedValue" and "collectedMarks"
    Then "unmarkedValue" should be equal to <expectedUnmarkedValue>
    And "collectedMarks" should be <expectedCollectedMarks>

    Examples:
      | inputValue                                                      | expectedUnmarkedValue                                 | expectedCollectedMarks |
      | "a"                                                               | "a"                                                   | []                     |
      | Number(1) (m "a")                                                 | Number(1)                                             | ["a"]                  |
      | [1,2]                                                             | [1,2]                                                 | []                     |
      | [Number(1)(m "a"), 2]                                             | [1,2]                                                 | ["a"]                  |
      | [Number(1)(m "a"), Number(2)(m "b")] (m "c")                      | [1,2]                                                 | ["a","b","c"]          |
      | EmptyList(S) (m "c")                                              | EmptyList(S)                                          | ["c"]                  |
      | {"a":"b"(m "c"), "x":"y"(m "z")}                                  | {"a":"b", "x":"y"}                                    | ["c","z"]              |
      | Tuple([Number(1)(m "a"), "y"(m "z")])                             | Tuple([1, "y"])                                       | ["a","z"]              |
      | Set([Number(1)(m "a"), Number(2)(m "z")])                         | Set([1,2])                                            | ["a","z"]              |
      | Obj({"x":[3(m "a"),5(m "b")](m "c","d"),"y":"y"(m "e"),"z":T(m "f")})(m "g") | Obj({"x":[3,5],"y":"y","z":True})                 | ["a","b","c","d","e","f","g"] |

  Scenario Outline: PathValueMarks UnmarkDeepWithPaths and MarkWithPaths
    Given a marked cty.Value <markedValue>
    And its expected unmarked cty.Value <unmarkedValue>
    And its expected list of PathValueMarks <expectedPvms>
    When I deeply unmark <markedValue> with paths into "actualUnmarked" and "actualPvms"
    Then "actualUnmarked" should be equal to <unmarkedValue>
    And "actualPvms" should contain the same PathValueMarks as <expectedPvms> (order may differ)
    When I mark "actualUnmarked" with "actualPvms"
    Then the result should be equal to <markedValue>

    Examples:
      | markedValue              | unmarkedValue            | expectedPvms                                                                |
      | "a"                      | "a"                      | []                                                                          |
      | Number(1) (m "a")        | Number(1)                | [{Path:[], Marks:["a"]}]                                                    |
      | [Num(1)(m "a"), Num(2)]  | [Num(1), Num(2)]         | [{Path:[Index(0)], Marks:["a"]}]                                            |
      | [N(1)(m "a"),N(2)(m "b")](m "c") | [N(1),N(2)]      | [{Path:[],Marks:["c"]},{Path:[Idx(0)],M:["a"]},{Path:[Idx(1)],M:["b"]}]       |
      | EmptyList(S)(m "c")      | EmptyList(S)             | [{Path:[], Marks:["c"]}]                                                    |
      | {"a":"b"(m "c"),"x":"y"(m "z")} | {"a":"b","x":"y"}  | [{P:[Attr("a")],M:["c"]},{P:[Attr("x")],M:["z"]}]                             |
      | Tuple([N(1)(m "a"),"y"(m "z"),Obj({"x":T})(m "o")]) | Tuple([N(1),"y",Obj({"x":T})]) | [{P:[Idx(0)],M:["a"]},{P:[Idx(1)],M:["z"]},{P:[Idx(2)],M:["o"]}] |
      | Set([N(1)(m "a"),N(2)(m "z")]) | Set([N(1),N(2)])   | [{Path:[], Marks:["a","z"]}]                                                | # Marks on set elements aggregate to the set itself for PathValueMarks
      | Obj({"x":[N(3)(m "a"),N(5)(m "b")](m "c","d"),"y":"y"(m "e"),"z":T(m "f")})(m "g") | Obj({"x":[N(3),N(5)],"y":"y","z":T}) | [{P:[],M:["g"]},{P:[Attr("x")],M:["c","d"]},{P:[Attr("x"),Idx(0)],M:["a"]},{P:[Attr("x"),Idx(1)],M:["b"]},{P:[Attr("y")],M:["e"]},{P:[Attr("z")],M:["f"]}] |
      | Obj({"env": [Obj({"vars": {"bar":"sec"(m "s"),"foo":"sec"(m "s")} }) ]}) | Obj({"env": [Obj({"vars": {"bar":"sec","foo":"sec"} }) ]}) | [{P:[Attr("env"),Idx(0),Attr("vars"),Idx("bar")],M:["s"]},{P:[Attr("env"),Idx(0),Attr("vars"),Idx("foo")],M:["s"]}] |

  Scenario: Reapplying marks to an object value
    Given an object value `Obj({"nested": Obj({"attr": "not directly marked"})})` as "obj"
    And path-value-marks `[{Path:[Attr("nested")], Marks:["mark"]}]` as "pvm"
    When I mark "obj" with "pvm" to get "first_marked_obj"
    And I mark "first_marked_obj" with "pvm" again to get "second_marked_obj"
    Then "first_marked_obj" should be equal to "second_marked_obj"
