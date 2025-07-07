# Original Go Test File: cty/function/stdlib/sequence_test.go
# This feature file covers tests for sequence generation and concatenation functions
# in the cty standard library.

Feature: Standard Library Sequence Functions
  This feature describes the behavior of functions for creating and
  combining sequences (lists/tuples) of cty values.

  Scenario Outline: Concatenating sequences (Concat function)
    # Covers test: TestConcat
    Given a list of cty sequences (lists or tuples) <InputSequences>
    When the Concat function is called with these sequences
    Then the result should be the cty sequence <ExpectedConcatenatedSequence>
    And an error message, if any, should contain "<ExpectedErrorMessagePart>"

    Examples: List Concatenation
      | InputSequences                                      | ExpectedConcatenatedSequence            | ExpectedErrorMessagePart | Description                                      |
      | [EmptyList(Number)]                                 | EmptyList(Number)                       |                          | Single empty list                                |
      | [List(Num(1),Num(2),Num(3))]                        | List(Num(1),Num(2),Num(3))              |                          | Single list                                      |
      | [List(Num(1)), List(Num(2),Num(3))]                 | List(Num(1),Num(2),Num(3))              |                          | Two lists of same type                           |
      | [List(Num(1)), List(Num(2).Mark(b),Num(3))]         | List(Num(1),Num(2).Mark(b),Num(3))      |                          | Element marks preserved                          |
      | [List(Num(1)).Mark(a), List(Num(2).Mark(b),Num(3))] | List(Num(1),Num(2).Mark(b),Num(3)).Mark(a)|                          | Outer and element marks preserved/merged         |
      | [EmptyList(Dyn).Mark(a), List(N(2).M(b),N(3)).M(c)] | List(N(2).M(b),N(3)).WithMarks(a,c)     |                          | Marks merged from empty and non-empty lists      |
      | [List(Num(1)), List(Str("foo")), List(Bool(true))]  | List(Str("1"),Str("foo"),Str("true"))   |                          | Unifies to List(String)                          |

    Examples: Tuple Concatenation
      | InputSequences                                      | ExpectedConcatenatedSequence            | ExpectedErrorMessagePart | Description                                      |
      | [EmptyTuple]                                        | EmptyTuple                              |                          | Single empty tuple                               |
      | [Tuple(Num(1),Bool(true),Num(3))]                   | Tuple(Num(1),Bool(true),Num(3))         |                          | Single tuple                                     |
      | [Tuple(Num(1)), Tuple(Bool(true),Num(3))]           | Tuple(Num(1),Bool(true),Num(3))         |                          | Two tuples, types preserved                      |

    Examples: Mixed List and Tuple Concatenation
      | InputSequences                                      | ExpectedConcatenatedSequence            | ExpectedErrorMessagePart | Description                                      |
      | [List(Num(1)), Tuple(Bool(true),Num(3))]            | Tuple(Num(1),Bool(true),Num(3))         |                          | List then Tuple -> Tuple                         |
      | [Tuple(Num(1),Bool(true)), List(Num(3))]            | Tuple(Num(1),Bool(true),Num(3))         |                          | Tuple then List -> Tuple                         |
      | [List(Num(1)), List(EmptyList(Bool))]               | Tuple(Num(1), EmptyList(Bool))          |                          | Unconvertible list elements -> Tuple             |

    Examples: Concat with Unknown/Dynamic Sequences
      | InputSequences                      | ExpectedConcatenatedSequence      | ExpectedErrorMessagePart | Description                               |
      | [Unknown(List(S)), List(S("a"))]    | Unknown(List(S)).RefineNotNull()  |                          | Unknown sequence input                    |
      | [List(S("a")), Dynamic]             | Dynamic                           |                          | Dynamic sequence input                    |
      | [List(S("a"),Unk(S)), List(S("b"))] | List(S("a"),Unk(S),S("b"))        |                          | List with unknown element                 |

    Examples: Concat Error Handling
      | InputSequences                      | ExpectedConcatenatedSequence      | ExpectedErrorMessagePart                  | Description                |
      | [List(S("a")), Number(1)]           |                                   | "argument 2 is number, not list or tuple" | Non-sequence argument      |
      | [Number(1)]                         |                                   | "argument 1 is number, not list or tuple" | Single non-sequence arg    |


  Scenario Outline: Generating a numerical range (Range function)
    # Covers test: TestRange
    When the Range function is called with arguments <Arguments>
    Then the result should be a cty List of Numbers <ExpectedRangeList>
    And an error message, if any, should contain "<ExpectedErrorMessagePart>"
    And if <ExpectedRangeList> is Unknown, its refinement should be <RefinementNote>
    And marks from arguments should be propagated to the result list and its elements

    Examples: One Argument (limit)
      | Arguments    | ExpectedRangeList                     | ExpectedErrorMessagePart | RefinementNote | Description                               |
      | [Num(5)]     | List(N(0),N(1),N(2),N(3),N(4))        |                          |                | Range up to limit (exclusive)             |
      | [Num(-5)]    | List(N(0),N(-1),N(-2),N(-3),N(-4))    |                          |                | Range down to limit (exclusive)           |
      | [Num(1)]     | List(N(0))                            |                          |                | Single element range                      |
      | [Num(0)]     | EmptyList(Number)                     |                          |                | Empty range                               |
      | [Num(5.5)]   | List(N(0),N(1),N(2),N(3),N(4),N(5))   |                          |                | Float limit                               |

    Examples: Two Arguments (start, limit)
      | Arguments          | ExpectedRangeList                     | ExpectedErrorMessagePart | RefinementNote | Description                               |
      | [Num(1), Num(5)]   | List(N(1),N(2),N(3),N(4))             |                          |                | Start to limit (exclusive)                |
      | [Num(5), Num(1)]   | List(N(5),N(4),N(3),N(2))             |                          |                | Decreasing range                          |
      | [Num(1.5), Num(5)] | List(N(1.5),N(2.5),N(3.5),N(4.5))     |                          |                | Float start                               |
      | [Num(1), Num(1)]   | EmptyList(Number)                     |                          |                | Empty range (start == limit)              |

    Examples: Three Arguments (start, limit, step)
      | Arguments               | ExpectedRangeList                     | ExpectedErrorMessagePart | RefinementNote | Description                               |
      | [Num(0),Num(5),Num(2)]  | List(N(0),N(2),N(4))                  |                          |                | Start, limit, step 2                      |
      | [Num(5),Num(0),Num(-1)] | List(N(5),N(4),N(3),N(2),N(1))        |                          |                | Decreasing range with step -1             |
      | [Num(0),Num(5),Num(0.5)]| List(N(0),N(0.5),N(1),N(1.5),N(2),N(2.5),N(3),N(3.5),N(4),N(4.5)) |       |                | Float step |

    Examples: Range with Unknown/Dynamic Inputs
      | Arguments         | ExpectedRangeList              | ExpectedErrorMessagePart | RefinementNote                 |
      | [Unknown(Number)] | Unknown(List(Number))          |                          | NotNull, NonNegativeLength     |
      | [Dynamic]         | Unknown(List(Number))          |                          | NotNull, NonNegativeLength     |
      | [Num(0), Unk(N)]  | Unknown(List(Number))          |                          | NotNull, NonNegativeLength     |
      | [Unk(N), Num(5)]  | Unknown(List(Number))          |                          | NotNull, NonNegativeLength     |

    Examples: Range Error Handling
      | Arguments             | ExpectedRangeList | ExpectedErrorMessagePart         | RefinementNote |
      | [Null(Number)]        |                   | "must not be null"               |                |
      | [String("5")]         |                   | "must be number"                 |                |
      | [Num(1),Num(5),Num(0)]|                   | "step argument must not be zero" |                |
      | []                    |                   | "takes between 1 and 3 arguments"|                |
      | [N(1),N(2),N(3),N(4)] |                   | "takes between 1 and 3 arguments"|                |


    Examples: Range with Marks
      | Arguments                       | ExpectedRangeList                               | ExpectedErrorMessagePart | RefinementNote |
      | [Num(2).Mark(m)]                | List(N(0).Mark(m), N(1).Mark(m)).Mark(m)        |                          |                |
      | [N(0).M(a), N(2).M(b)]          | List(N(0).WithMarks(a,b), N(1).WithMarks(a,b)).WithMarks(a,b) |       |                |
      | [N(0).M(a), N(2).M(b), N(1).M(c)]| List(N(0).WithMarks(a,b,c), N(1).WithMarks(a,b,c)).WithMarks(a,b,c) |       |                |

    # Note on Value Syntax:
    # - Num(X) or N(X) for cty.NumberIntVal(X) or cty.NumberFloatVal(X)
    # - Str("X") or S("X") for cty.StringVal("X")
    # - Bool(true/false) for cty.BoolVal(true/false)
    # - List(...), Tuple(...), EmptyList(Type), EmptyTuple, Unknown(Type) or Unk(Type), Null(Type)
    # - .Mark(a), .M(a) for marked values
    # - .WithMarks(a,b) for multiple marks
    # - Dyn for DynamicPseudoType
    # - Arguments for Range are a list of cty.Number values.
    # - RefinementNote describes expected refinements on Unknown results.
    # - ExpectedErrorMessagePart: if a scenario is expected to error, this contains part of the message.
    # - If ExpectedErrorMessagePart is blank, no error is expected.
    # - If ExpectedRangeList is blank (and no error message), it implies cty.NilVal or similar, if applicable to function. For Range, it means error.
