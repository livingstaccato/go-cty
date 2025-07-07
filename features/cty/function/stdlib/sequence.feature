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

    Examples: List Concatenation
      | InputSequences                                      | ExpectedConcatenatedSequence            | Description                                      |
      | [EmptyList(Number)]                                 | EmptyList(Number)                       | Single empty list                                |
      | [List(Num(1),Num(2),Num(3))]                        | List(Num(1),Num(2),Num(3))              | Single list                                      |
      | [List(Num(1)), List(Num(2),Num(3))]                 | List(Num(1),Num(2),Num(3))              | Two lists of same type                           |
      | [List(Num(1)), List(Num(2).Mark(b),Num(3))]         | List(Num(1),Num(2).Mark(b),Num(3))      | Element marks preserved                          |
      | [List(Num(1)).Mark(a), List(Num(2).Mark(b),Num(3))] | List(Num(1),Num(2).Mark(b),Num(3)).Mark(a)| Outer and element marks preserved/merged         |
      | [EmptyList(Dyn).Mark(a), List(N(2).M(b),N(3)).M(c)] | List(N(2).M(b),N(3)).WithMarks(a,c)     | Marks merged from empty and non-empty lists      |
      | [List(Num(1)), List(Str("foo")), List(Bool(true))]  | List(Str("1"),Str("foo"),Str("true"))   | Unifies to List(String)                          |

    Examples: Tuple Concatenation
      | InputSequences                                      | ExpectedConcatenatedSequence            | Description                                      |
      | [EmptyTuple]                                        | EmptyTuple                              | Single empty tuple                               |
      | [Tuple(Num(1),Bool(true),Num(3))]                   | Tuple(Num(1),Bool(true),Num(3))         | Single tuple                                     |
      | [Tuple(Num(1)), Tuple(Bool(true),Num(3))]           | Tuple(Num(1),Bool(true),Num(3))         | Two tuples, types preserved                      |

    Examples: Mixed List and Tuple Concatenation
      | InputSequences                                      | ExpectedConcatenatedSequence            | Description                                      |
      | [List(Num(1)), Tuple(Bool(true),Num(3))]            | Tuple(Num(1),Bool(true),Num(3))         | List then Tuple -> Tuple                         |
      | [Tuple(Num(1),Bool(true)), List(Num(3))]            | Tuple(Num(1),Bool(true),Num(3))         | Tuple then List -> Tuple                         |
      | [List(Num(1)), List(EmptyList(Bool))]               | Tuple(Num(1), EmptyList(Bool))          | Unconvertible list elements -> Tuple             |

  Scenario Outline: Generating a numerical range (Range function)
    # Covers test: TestRange
    When the Range function is called with arguments <Arguments>
    Then the result should be a cty List of Numbers <ExpectedRangeList>

    Examples: One Argument (limit)
      | Arguments    | ExpectedRangeList                     | Description                               |
      | [Num(5)]     | List(N(0),N(1),N(2),N(3),N(4))        | Range up to limit (exclusive)             |
      | [Num(-5)]    | List(N(0),N(-1),N(-2),N(-3),N(-4))    | Range down to limit (exclusive)           |
      | [Num(1)]     | List(N(0))                            | Single element range                      |
      | [Num(0)]     | EmptyList(Number)                     | Empty range                               |
      | [Num(5.5)]   | List(N(0),N(1),N(2),N(3),N(4),N(5))   | Float limit, includes integers up to floor(limit-step) if step positive, or ceil if negative |

    Examples: Two Arguments (start, limit)
      | Arguments          | ExpectedRangeList                     | Description                               |
      | [Num(1), Num(5)]   | List(N(1),N(2),N(3),N(4))             | Start to limit (exclusive)                |
      | [Num(5), Num(1)]   | List(N(5),N(4),N(3),N(2))             | Decreasing range                          |
      | [Num(1.5), Num(5)] | List(N(1.5),N(2.5),N(3.5),N(4.5))     | Float start                               |
      | [Num(1), Num(1)]   | EmptyList(Number)                     | Empty range (start == limit)              |

    Examples: Three Arguments (start, limit, step)
      | Arguments               | ExpectedRangeList                     | Description                               |
      | [Num(0),Num(5),Num(2)]  | List(N(0),N(2),N(4))                  | Start, limit, step 2                      |
      | [Num(5),Num(0),Num(-1)] | List(N(5),N(4),N(3),N(2),N(1))        | Decreasing range with step -1             |
      | [Num(0),Num(5),Num(0.5)]| List(N(0),N(0.5),N(1),N(1.5),N(2),N(2.5),N(3),N(3.5),N(4),N(4.5)) | Float step |

    # Note on Value Syntax:
    # - Num(X) or N(X) for cty.NumberIntVal(X) or cty.NumberFloatVal(X)
    # - Str("X") for cty.StringVal("X")
    # - Bool(true/false) for cty.BoolVal(true/false)
    # - List(...), Tuple(...), EmptyList(Type), EmptyTuple
    # - .Mark(a), .M(a) for marked values
    # - .WithMarks(a,b) for multiple marks
    # - Dyn for DynamicPseudoType
    # - Arguments for Range are a list of cty.Number values.
