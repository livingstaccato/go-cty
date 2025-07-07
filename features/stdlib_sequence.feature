# Covers tests in cty/function/stdlib/sequence_test.go

Feature: Standard Library Sequence Functions
  Background:
    Given a Go environment

  Scenario Outline: Concatenate sequences (lists or tuples)
    Given a list of sequences <inputSequences>
    When I concatenate these sequences
    Then the result should be <expectedSequence>
    And no error should occur

    Examples: List Concatenation
      | inputSequences                                                                 | expectedSequence                     |
      | [EmptyList(N)]                                                                 | EmptyList(N)                         |
      | [[1,2,3]]                                                                      | [1,2,3]                              |
      | [[1],[2,3]]                                                                    | [1,2,3]                              |
      | [[1],[2,3](m "a")]                                                             | [1,2,3](m "a")                       |
      | [[1],[2(m "b"),3]]                                                             | [1,2(m "b"),3]                       |
      | [[1](m "a"),[2(m "b"),3]]                                                       | [1,2(m "b"),3](m "a")                |
      | [EmptyList(Dyn)(m "a"),[2(m "b"),3](m "c")]                                     | [2(m "b"),3](m "a","c")              |
      | [EmptyList(Dyn)(m "a"),Tuple([2(m "b"),3])(m "c")]                              | Tuple([2(m "b"),3])(m "a","c")       |
      | [[1],["foo"],[True]]                                                           | ["1","foo","true"]                   | # Unified to List(String)
      | [[1],["foo","bar"]]                                                            | ["1","foo","bar"]                    | # Unified to List(String)

    Examples: Tuple Concatenation
      | inputSequences                                                                 | expectedSequence                     |
      | [EmptyTuple]                                                                   | EmptyTuple                           |
      | [Tuple([1,True,3])]                                                            | Tuple([1,True,3])                    |
      | [Tuple([1]),Tuple([True,3])]                                                   | Tuple([1,True,3])                    |

    Examples: Mixed List and Tuple Concatenation (results in Tuple)
      | inputSequences                                                                 | expectedSequence                     |
      | [[1],Tuple([True,3])]                                                          | Tuple([1,True,3])                    |
      | [Tuple([1,True]),[3]]                                                          | Tuple([1,True,3])                    |
      | [[1], [EmptyList(B)]]                                                          | Tuple([1, EmptyList(B)])             | # Unconvertible types

  Scenario Outline: Generate a range of numbers
    Given range arguments <rangeArguments>
    When I generate a range of numbers
    Then the result should be list <expectedRange>
    And no error should occur

    Examples: One Argument (limit)
      | rangeArguments | expectedRange          |
      | [5]            | [0,1,2,3,4]            |
      | [-5]           | [0,-1,-2,-3,-4]        |
      | [1]            | [0]                    |
      | [0]            | EmptyList(Number)      |
      | [5.5]          | [0,1,2,3,4,5]          |

    Examples: Two Arguments (start, limit)
      | rangeArguments | expectedRange          |
      | [1, 5]         | [1,2,3,4]              |
      | [5, 1]         | [5,4,3,2]              |
      | [1.5, 5]       | [1.5,2.5,3.5,4.5]      |
      | [1, 2]         | [1]                    |
      | [1, 1]         | EmptyList(Number)      |

    Examples: Three Arguments (start, limit, step)
      | rangeArguments | expectedRange                |
      | [0, 5, 2]      | [0,2,4]                      |
      | [0, 5, 1]      | [0,1,2,3,4]                  |
      | [0, 1, 1]      | [0]                          |
      | [0, 0, 1]      | EmptyList(Number)            |
      | [5, 0, -1]     | [5,4,3,2,1]                  |
      | [0, 5, 0.5]    | [0,0.5,1,1.5,2,2.5,3,3.5,4,4.5] |
