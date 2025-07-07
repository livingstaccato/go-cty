# Original Go Test File: cty/function/stdlib/set_test.go
# This feature file covers tests for set operation functions
# in the cty standard library.

Feature: Standard Library Set Operations
  This feature describes the behavior of functions that perform set operations
  like union, intersection, subtraction, and symmetric difference on cty Set values.

  Scenario Outline: Set Union operation
    # Covers test: TestSetUnion
    Given a list of cty Sets <InputSets>
    When the SetUnion function is called with these sets
    Then the result should be a cty Set <ExpectedUnionSet> containing the union of elements

    Examples:
      | InputSets                                     | ExpectedUnionSet                     | Description                                         |
      | [EmptySet(String)]                            | EmptySet(String)                     | Union of one empty set                              |
      | [EmptySet(String), EmptySet(String)]          | EmptySet(String)                     | Union of two empty sets                             |
      | [Set(True), EmptySet(String)]                 | Set(String("true"))                  | Union with empty set, type unified to String        |
      | [Set(True), Set(True), Set(False)]            | Set(True, False)                     | Duplicates handled, bools remain bools              |
      | [Set(S("a")), Set(S("b")), Set(S("b"),S("c"))] | Set(S("a"),S("b"),S("c"))            | Union of multiple string sets                       |
      | [Set(True), EmptySet(DynamicType)]            | Set(True)                            | Union with empty dynamic set, type is Bool          |
      | [Set(EmptyObject), EmptySet(DynamicType)]     | Set(EmptyObject)                     | Union with empty dynamic set, type is Object        |
      | [Set(S("5")), Unknown(Set(Number))]           | Unknown(Set(String)).RefineNotNull() | Union with unknown set results in unknown set       |
      | [Set(S("5")), Set(Unknown(String))]           | Set(S("5"), Unknown(String))         | Union with set containing unknown element           |

    Examples: With Marks
      | InputSets                                           | ExpectedUnionSet                          |
      | [Set(S("a").M(m1)), Set(S("b").M(m2)).M(s2)]        | Set(S("a"), S("b")).WithMarks(m1,m2,s2)    |
      | [Unknown(Set(S)).M(s1), Set(S("a")).M(s2)]          | Unknown(Set(S)).RefineNotNull().WithMarks(s1,s2) |

  Scenario Outline: Set Intersection operation
    # Covers test: TestSetIntersection
    Given a list of cty Sets <InputSets>
    When the SetIntersection function is called with these sets
    Then the result should be a cty Set <ExpectedIntersectionSet> containing common elements

    Examples: Basic Intersection
      | InputSets                                     | ExpectedIntersectionSet              | Description                                         |
      | [EmptySet(String)]                            | EmptySet(String)                     | Intersection of one empty set                         |
      | [EmptySet(String), EmptySet(String)]          | EmptySet(String)                     | Intersection of two empty sets                      |
      | [Set(True), EmptySet(String)]                 | EmptySet(String)                     | Intersection with empty set is empty (type unified) |
      | [Set(True), Set(True,False), Set(True,False)] | Set(True)                            | Intersection of multiple boolean sets               |
      | [Set(S("a"),S("b")), Set(S("b")), Set(S("b"),S("c"))] | Set(S("b"))                      | Intersection of multiple string sets                |
      | [Set(True), EmptySet(DynamicType)]            | EmptySet(Bool)                       | Intersection with empty dynamic set                 |
      | [Set(S("5")), Unknown(Set(Number))]           | Unknown(Set(String)).RefineNotNull() | Intersection with unknown set                       |
      | [Set(S("5")), Set(Unknown(String))]           | Unknown(Set(String)).RefineNotNull() | Intersection with set containing unknown element    |

    Examples: Intersection With Marks
      | InputSets                                           | ExpectedIntersectionSet                   |
      | [Set(S("a").M(m1),S("b")), Set(S("a").M(m2)).M(s2)]  | Set(S("a")).WithMarks(m1,m2,s2)            | # Marks from common element and sets are combined
      | [Unknown(Set(S)).M(s1), Set(S("a")).M(s2)]          | Unknown(Set(S)).RefineNotNull().WithMarks(s1,s2) |

  Scenario Outline: Set Subtraction operation (A - B)
    # Covers test: TestSetSubtract
    Given cty Set A: <SetA>
    And cty Set B: <SetB>
    When the SetSubtract function is called with Set A and Set B
    Then the result should be a cty Set <ExpectedResultSet> containing elements in A but not in B

    Examples: Basic Subtraction
      | SetA                                  | SetB                  | ExpectedResultSet                    |
      | EmptySet(String)                      | EmptySet(String)      | EmptySet(String)                     |
      | Set(True)                             | EmptySet(String)      | Set(String("true"))                  |
      | Set(True)                             | Set(False)            | Set(True)                            |
      | Set(S("a"),S("b"),S("c"))             | Set(S("a"),S("c"))    | Set(S("b"))                          |
      | Set(S("a"))                           | EmptySet(DynamicType) | Set(S("a"))                          |
      | Set(S("5"))                           | Unknown(Set(Number))  | Unknown(Set(String)).RefineNotNull() |
      | Set(S("5"))                           | Set(Unknown(String))  | Unknown(Set(String)).RefineNotNull() |

    Examples: Subtraction With Marks
      | SetA                                  | SetB                  | ExpectedResultSet                    |
      | Set(S("a").M(m1),S("b").M(m2)).M(s1)   | Set(S("b").M(m3)).M(s2)| Set(S("a")).WithMarks(m1,s1,s2)      | # Marks from A, A's elements, and B are relevant
      | Unknown(Set(S)).M(s1)                 | Set(S("any")).M(s2)   | Unknown(Set(S)).RefineNotNull().WithMarks(s1,s2) |

  Scenario Outline: Set Symmetric Difference operation
    # Covers test: TestSetSymmetricDifference
    Given cty Set A: <SetA>
    And cty Set B: <SetB>
    When the SetSymmetricDifference function is called with Set A and Set B
    Then the result should be a cty Set <ExpectedResultSet> containing elements in either A or B, but not both

    Examples: Basic Symmetric Difference
      | SetA                                  | SetB                  | ExpectedResultSet                    |
      | EmptySet(String)                      | EmptySet(String)      | EmptySet(String)                     |
      | Set(True)                             | EmptySet(String)      | Set(String("true"))                  |
      | Set(True)                             | Set(False)            | Set(True, False)                     |
      | Set(S("a"),S("b"),S("c"))             | Set(S("a"),S("c"))    | Set(S("b"))                          |
      | Set(S("a"))                           | EmptySet(DynamicType) | Set(S("a"))                          |
      | Set(S("5"))                           | Unknown(Set(Number))  | Unknown(Set(String)).RefineNotNull() |
      | Set(S("5"))                           | Set(Unknown(Number))  | Unknown(Set(String)).RefineNotNull() | # Assuming Number can convert to String for comparison context

    Examples: Symmetric Difference With Marks
      | SetA                                  | SetB                  | ExpectedResultSet                    |
      | Set(S("a").M(m1),S("b").M(m2)).M(s1)   | Set(S("b").M(m3),S("c").M(m4)).M(s2) | Set(S("a"),S("c")).WithMarks(m1,m2,m3,m4,s1,s2) | # All marks from distinct elements and sets combined
      | Unknown(Set(S)).M(s1)                 | Set(S("any")).M(s2)   | Unknown(Set(S)).RefineNotNull().WithMarks(s1,s2) |

  Scenario Outline: Set operations with invalid input types
    Given a cty.Value <Arg1>
    And a cty.Value <Arg2> (if applicable for binary ops)
    When the <SetFunction> function is called with these arguments
    Then an error should occur with a message containing "set required"

    Examples:
      | SetFunction            | Arg1          | Arg2          |
      | SetUnion               | List(S("a"))  | Set(S("b"))   | # Arg1 is not a set
      | SetUnion               | Set(S("a"))   | String("b")   | # Arg2 is not a set
      | SetIntersection        | String("a")   | Set(S("b"))   |
      | SetSubtract            | List(S("a"))  | Set(S("b"))   |
      | SetSubtract            | Set(S("a"))   | Number(1)     |
      | SetSymmetricDifference | Map(a=S)      | Set(S("b"))   |

    # Note on Value Syntax:
    # - S("x") for cty.StringVal("x")
    # - True, False for cty.BoolVal(true/false)
    # - Set(...) for cty.SetVal([]cty.Value{...})
    # - EmptySet(Type) for cty.SetValEmpty(cty.Type)
    # - Unknown(Type) for cty.UnknownVal(cty.Type)
    # - DynamicType for cty.DynamicPseudoType
    # - EmptyObject for cty.EmptyObjectVal
    # - .RefineNotNull() indicates the unknown set result is refined.
    # - .M(mark) or .WithMarks(m1,m2) for marks.
