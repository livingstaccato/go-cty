# Covers tests in cty/unknown_refinement_test.go

Feature: Unknown Value Refinement
  Background:
    Given a Go environment

  Scenario Outline: Refine an unknown or known cty.Value
    Given an initial cty.Value created by <builderFunction>
    When I attempt to build the refined value
    Then the result should be <expectedOutcome>

    Examples: General Refinements
      | builderFunction                                                                          | expectedOutcome                                              |
      | `DynamicVal.Refine().NotNull().StringPrefix("beep").NumberRange(0,10).CollectionLength(5)` | Dynamic                                                      |
      | `NullVal(Dynamic).Refine().Null()`                                                       | Null(Dynamic)                                                |
      | `NullVal(Dynamic).RefineNotNull()`                                                       | Panic: "refining null value as non-null"                     |
      | `UnknownVal(EmptyObject).RefineNotNull()`                                                | UnknownNotNull(EmptyObject)                                  |
      | `UnknownVal(EmptyTuple).RefineNotNull()`                                                 | UnknownNotNull(EmptyTuple)                                   |
      | `UnknownVal(List(S)).RefineNotNull()`                                                    | UnknownNotNull(List(String))                                 |
      | `UnknownVal(Map(S)).RefineNotNull()`                                                     | UnknownNotNull(Map(String))                                  |
      | `UnknownVal(Set(S)).RefineNotNull()`                                                     | UnknownNotNull(Set(String))                                  |
      | `UnknownVal(String).RefineNotNull()`                                                     | UnknownNotNull(String)                                       |
      | `UnknownVal(Number).RefineNotNull()`                                                     | UnknownNotNull(Number)                                       |
      | `UnknownVal(Bool).RefineNotNull()`                                                       | UnknownNotNull(Bool)                                         |
      | `NullVal(Bool).Refine().Null()`                                                          | Null(Bool)                                                   |
      | `NullVal(Bool).RefineNotNull()`                                                          | Panic: "refining null value as non-null"                     |

    Examples: String Refinements
      | builderFunction                                                                          | expectedOutcome                                              |
      | `UnknownVal(S).Refine().StringPrefix("foo-")`                                            | Unknown(S) refined prefix "foo-"                             |
      | `UnknownVal(S).Refine().StringPrefix("foo")`                                             | Unknown(S) refined prefix "fo"                               | # Truncated
      | `UnknownVal(S).Refine().StringPrefix("a😶")`                                            | Unknown(S) refined prefix "a"                                | # Truncated emoji
      | `UnknownVal(S).Refine().StringPrefixFull("foo")`                                         | Unknown(S) refined prefix "foo"                              |
      | `UnknownVal(S).Refine().StringPrefixFull("foo-").StringPrefixFull("foo-bar-")`           | Unknown(S) refined prefix "foo-bar-"                         |
      | `UnknownVal(S).Refine().StringPrefixFull("foo-").StringPrefixFull("bar-")`               | Panic: "refined prefix is inconsistent with previous refined prefix" |
      | `StringVal("foo-baz").Refine().StringPrefixFull("foo-")`                                 | "foo-baz"                                                    |
      | `StringVal("foo-baz").Refine().StringPrefixFull("bar-")`                                 | Panic: "refined prefix is inconsistent with known value"     |
      | `UnknownVal(N).Refine().StringPrefixFull("foo")`                                         | Panic: "cannot refine string prefix for a cty.Number value"  |

    Examples: Number Range Refinements
      | builderFunction                                                                          | expectedOutcome                                              |
      | `UnknownVal(N).Refine().NumberRangeLowerBound(1, true)`                                  | Unknown(N) refined lowerBound 1 true                         |
      | `UnknownVal(N).Refine().NumberRangeUpperBound(1, true)`                                  | Unknown(N) refined upperBound 1 true                         |
      | `UnknownVal(N).Refine().NumberRangeLowerBound(1, true).NumberRangeUpperBound(2, false)`  | Unknown(N) refined lowerBound 1 true, upperBound 2 false     |
      | `UnknownVal(N).Refine().NumberRangeLowerBound(1, true).NumberRangeUpperBound(1, true).NotNull()` | Number(1)                                                    |
      | `UnknownVal(N).Refine().NumberRangeLowerBound(2, true).NumberRangeUpperBound(1, false)`  | Panic: "number lower bound cty.NumberIntVal(2) is greater than upper bound cty.NumberIntVal(1)" |
      | `NumberVal(1).Refine().NumberRangeLowerBound(0, true).NumberRangeUpperBound(2, true).NotNull()` | Number(1)                                                    |
      | `NumberVal(10).Refine().NumberRangeLowerBound(0, true).NumberRangeUpperBound(2, true).NotNull()`| Panic: "refining cty.NumberIntVal(10) to be <= cty.NumberIntVal(2)" |

    Examples: List Length Refinements
      | builderFunction                                                                          | expectedOutcome                                              |
      | `UnknownVal(List(S)).Refine().CollectionLengthLowerBound(1)`                             | Unknown(List(S)) refined lowerLen 1                          |
      | `UnknownVal(List(S)).Refine().CollectionLengthUpperBound(1)`                             | Unknown(List(S)) refined upperLen 1                          |
      | `UnknownVal(List(S)).Refine().CollectionLengthLowerBound(1).CollectionLengthUpperBound(3)`| Unknown(List(S)) refined len 1-3                             |
      | `UnknownVal(List(S)).Refine().NotNull().CollectionLength(2)`                             | List([Unknown(S), Unknown(S)])                               |
      | `UnknownVal(List(S)).Refine().NotNull().CollectionLength(0)`                             | EmptyList(S)                                                 |
      | `ListValEmpty(S).Refine().CollectionLength(0)`                                           | EmptyList(S)                                                 |
      | `ListValEmpty(S).Refine().CollectionLength(1)`                                           | Panic: "refining collection of length cty.NumberIntVal(0) with lower bound 1" |

    Examples: Map Length Refinements
      | builderFunction                                                                          | expectedOutcome                                              |
      | `UnknownVal(Map(S)).Refine().CollectionLengthLowerBound(1)`                              | Unknown(Map(S)) refined lowerLen 1                           |
      | `UnknownVal(Map(S)).Refine().CollectionLengthUpperBound(1)`                              | Unknown(Map(S)) refined upperLen 1                           |
      | `UnknownVal(Map(S)).Refine().CollectionLengthLowerBound(1).CollectionLengthUpperBound(3)` | Unknown(Map(S)) refined len 1-3                              |
      | `UnknownVal(Map(S)).Refine().NotNull().CollectionLength(2)`                              | UnknownNotNull(Map(S)) refined len 2                          |
      | `UnknownVal(Map(S)).Refine().NotNull().CollectionLength(0)`                              | EmptyMap(S)                                                  |
      | `MapValEmpty(S).Refine().CollectionLength(0)`                                            | EmptyMap(S)                                                  |
      | `MapValEmpty(S).Refine().CollectionLength(1)`                                            | Panic: "refining collection of length cty.NumberIntVal(0) with lower bound 1" |

    Examples: Set Length Refinements
      | builderFunction                                                                          | expectedOutcome                                              |
      | `UnknownVal(Set(S)).Refine().CollectionLengthLowerBound(1)`                              | Unknown(Set(S)) refined lowerLen 1                           |
      | `UnknownVal(Set(S)).Refine().CollectionLengthUpperBound(1)`                              | Unknown(Set(S)) refined upperLen 1                           |
      | `UnknownVal(Set(S)).Refine().CollectionLengthLowerBound(1).CollectionLengthUpperBound(3)` | Unknown(Set(S)) refined len 1-3                              |
      | `UnknownVal(Set(S)).Refine().NotNull().CollectionLength(2)`                              | UnknownNotNull(Set(S)) refined len 2                          |
      | `UnknownVal(Set(S)).Refine().NotNull().CollectionLength(0)`                              | EmptySet(S)                                                  |
      | `SetValEmpty(S).Refine().CollectionLength(0)`                                            | EmptySet(S)                                                  |
      | `SetValEmpty(S).Refine().CollectionLength(1)`                                            | Panic: "refining collection of length cty.NumberIntVal(0) with lower bound 1" |
