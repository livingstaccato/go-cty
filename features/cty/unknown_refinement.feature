# Original Go Test File: cty/unknown_refinement_test.go
# This feature file covers tests for cty.Value.Refine() method,
# which allows adding constraints to UnknownValues.

Feature: cty Unknown Value Refinement
  This feature describes how Unknown cty.Values can be refined with
  additional constraints, potentially making them known or more specific.

  Scenario Outline: Refining an Unknown or Known cty.Value
    # Covers test: TestValueRefine
    Given an initial cty.Value <InitialValue> of type <InitialType>
    When the following refinements are applied in order: <Refinements>
    Then the resulting cty.Value should be <ExpectedValue> of type <ExpectedType>
    And if a panic is expected, the panic message should contain "<ExpectedPanicMessage>"

    Examples: DynamicVal Ignores Refinements
      | InitialValue | InitialType | Refinements                               | ExpectedValue | ExpectedType | ExpectedPanicMessage |
      | Dynamic      | DynamicType | NotNull, StringPrefix("beep"), Range(0,10), Length(5) | Dynamic       | DynamicType  |                      |

    Examples: Null and NotNull Refinements
      | InitialValue        | InitialType | Refinements         | ExpectedValue       | ExpectedType  | ExpectedPanicMessage                |
      | Null(DynamicType)   | DynamicType | Null                | Null(DynamicType)   | DynamicType   |                                     |
      | Null(DynamicType)   | DynamicType | NotNull             |                     |               | "refining null value as non-null"   |
      | Unknown(EmptyObject)| EmptyObject | NotNull             | Unknown(EmptyObject).NotNull | EmptyObject |                                     |
      | Unknown(List(S))    | List(S)     | NotNull             | Unknown(List(S)).NotNull | List(S)   |                                     |
      | Unknown(Map(S))     | Map(S)      | NotNull             | Unknown(Map(S)).NotNull | Map(S)    |                                     |
      | Unknown(Set(S))     | Set(S)      | NotNull             | Unknown(Set(S)).NotNull | Set(S)    |                                     |
      | Unknown(String)     | String      | NotNull             | Unknown(String).NotNull | String    |                                     |
      | Unknown(Number)     | Number      | NotNull             | Unknown(Number).NotNull | Number    |                                     |
      | Unknown(Bool)       | Bool        | NotNull             | Unknown(Bool).NotNull   | Bool      |                                     |
      | Null(Bool)          | Bool        | Null                | Null(Bool)          | Bool          |                                     |
      | Null(Bool)          | Bool        | NotNull             |                     |               | "refining null value as non-null"   |

    Examples: String Prefix Refinements
      | InitialValue    | InitialType | Refinements                                  | ExpectedValue                     | ExpectedType | ExpectedPanicMessage                                  |
      | Unknown(String) | String      | StringPrefix("foo-")                         | Unknown(S).PrefixFull("foo-")     | String       |                                                       |
      | Unknown(String) | String      | StringPrefix("foo")                          | Unknown(S).PrefixFull("fo")       | String       | # Truncated due to potential combining char         |
      | Unknown(String) | String      | StringPrefixFull("foo")                      | Unknown(S).PrefixFull("foo")      | String       |                                                       |
      | Unknown(S).PrefixFull("foo-") | String | StringPrefixFull("foo-bar-")         | Unknown(S).PrefixFull("foo-bar-") | String       |                                                       |
      | Unknown(S).PrefixFull("foo-") | String | StringPrefixFull("bar-")             |                                   |              | "refined prefix is inconsistent with previous"    |
      | String("foo-baz") | String    | StringPrefixFull("foo-")                     | String("foo-baz")                 | String       |                                                       |
      | String("foo-baz") | String    | StringPrefixFull("bar-")                     |                                   |              | "refined prefix is inconsistent with known value" |
      | Unknown(Number) | Number    | StringPrefixFull("foo")                      |                                   |              | "cannot refine string prefix for a cty.Number"    |

    Examples: Number Range Refinements
      | InitialValue    | InitialType | Refinements                                  | ExpectedValue                        | ExpectedType | ExpectedPanicMessage                                  |
      | Unknown(Number) | Number      | RangeLowerBound(Num(1),true)                 | Unknown(N).RangeLower(N(1),true)     | Number       |                                                       |
      | Unknown(Number) | Number      | RangeUpperBound(Num(1),true)                 | Unknown(N).RangeUpper(N(1),true)     | Number       |                                                       |
      | Unknown(N)      | Number      | RangeLowerBound(N(1),true), RangeUpperBound(N(2),false) | Unknown(N).Range(N(1),true, N(2),false) | Number |                                              |
      | Unknown(N).NotNull | Number   | RangeLowerBound(N(1),true), RangeUpperBound(N(1),true) | Number(1)                        | Number       | # Becomes known                                       |
      | Unknown(Number) | Number      | RangeLowerBound(N(2),true), RangeUpperBound(N(1),false) |                                      |              | "number lower bound cty.NumberIntVal(2) is greater" |
      | Number(1)       | Number      | NotNull, RangeLowerBound(N(0),true), RangeUpperBound(N(2),true) | Number(1)                    | Number       |                                                       |
      | Number(10)      | Number      | NotNull, RangeLowerBound(N(0),true), RangeUpperBound(N(2),true) |                                  |              | "refining cty.NumberIntVal(10) to be <= cty.NumberIntVal(2)" |

    Examples: Collection Length Refinements (List, Map, Set)
      | InitialValue        | InitialType  | Refinements                     | ExpectedValue                      | ExpectedType  | ExpectedPanicMessage                                  |
      | Unknown(List(S))    | List(S)      | LengthLowerBound(1)             | Unknown(List(S)).LengthLower(1)    | List(S)       |                                                       |
      | Unknown(List(S))    | List(S)      | LengthUpperBound(1)             | Unknown(List(S)).LengthUpper(1)    | List(S)       |                                                       |
      | Unknown(List(S))    | List(S)      | LengthLowerBound(1), LengthUpperBound(3) | Unknown(List(S)).LengthRange(1,3) | List(S)   |                                                       |
      | Unknown(List(S)).NotNull | List(S)  | Length(2)                       | List(Unknown(S),Unknown(S))        | List(S)       | # Becomes known list of unknowns                      |
      | Unknown(List(S)).NotNull | List(S)  | Length(0)                       | EmptyList(String)                  | List(S)       | # Becomes known empty list                          |
      | EmptyList(String)   | List(S)      | Length(0)                       | EmptyList(String)                  | List(S)       |                                                       |
      | EmptyList(String)   | List(S)      | Length(1)                       |                                    |               | "refining collection of length cty.NumberIntVal(0) with lower bound 1" |
      | Unknown(Map(S)).NotNull | Map(S)   | Length(0)                       | EmptyMap(String)                   | Map(S)        |                                                       |
      | Unknown(Set(S)).NotNull | Set(S)   | Length(0)                       | EmptySet(String)                   | Set(S)        |                                                       |

    # Note on Value/Type Syntax:
    # - Values: Dynamic, Null(Type), Unknown(Type), String("val"), Number(val), List(...), EmptyList(Type), etc.
    # - Types: DynamicType, String (S), Number (N), Bool (B), List(S), Map(S), Set(S), EmptyObject.
    # - Refinements: Comma-separated list of refinement calls, e.g., NotNull, StringPrefix("p"), Range(min,max), Length(len).
    #   - StringPrefix("p") implies SafeKnownPrefix. StringPrefixFull("p") implies exact prefix.
    #   - RangeLowerBound(val, inclusive_bool), RangeUpperBound(val, inclusive_bool), Range(min,min_incl,max,max_incl)
    #   - LengthLowerBound(val), LengthUpperBound(val), Length(val) (for exact length)
    # - .NotNull is shorthand for a NotNull refinement.
    # - If ExpectedPanicMessage is present, ExpectedValue/Type are ignored. Values are cty values unless specified as Go types.
