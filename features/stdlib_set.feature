# Covers tests in cty/function/stdlib/set_test.go

Feature: Standard Library Set Functions
  Background:
    Given a Go environment

  Scenario Outline: Calculate the union of sets
    Given a list of sets <inputSets>
    When I calculate the union of these sets
    Then the result should be set <expectedUnion>
    And no error should occur

    Examples:
      | inputSets                                                       | expectedUnion                      |
      | [EmptySet(S)]                                                   | EmptySet(S)                        |
      | [EmptySet(S), EmptySet(S)]                                      | EmptySet(S)                        |
      | [Set([True]), EmptySet(S)]                                      | Set(["true"])                      | # Type coercion
      | [Set([True]), Set([True]), Set([False])]                        | Set([True, False])                 |
      | [Set(["a"]), Set(["b"]), Set(["b","c"])]                         | Set(["a","b","c"])                 |
      | [Set([True]), EmptySet(Dyn)]                                    | Set([True])                        |
      | [Set([EmptyObj]), EmptySet(Dyn)]                                | Set([EmptyObj])                    |
      | [EmptySet(Dyn), EmptySet(Dyn)]                                  | EmptySet(Dyn)                      |
      | [Set(["5"]), Unknown(Set(N))]                                   | UnknownNotNull(Set(S))             |
      | [Set(["5"]), Set([Unknown(S)])]                                 | Set(["5", Unknown(S)])             |

  Scenario Outline: Calculate the intersection of sets
    Given a list of sets <inputSets>
    When I calculate the intersection of these sets
    Then the result should be set <expectedIntersection>
    And no error should occur

    Examples:
      | inputSets                                                       | expectedIntersection               |
      | [EmptySet(S)]                                                   | EmptySet(S)                        |
      | [EmptySet(S), EmptySet(S)]                                      | EmptySet(S)                        |
      | [Set([True]), EmptySet(S)]                                      | EmptySet(S)                        | # Type coercion
      | [Set([True]), Set([True,False]), Set([True,False])]             | Set([True])                        |
      | [Set(["a","b"]), Set(["b"]), Set(["b","c"])]                     | Set(["b"])                         |
      | [Set([True]), EmptySet(Dyn)]                                    | EmptySet(Bool)                     |
      | [Set([EmptyObj]), EmptySet(Dyn)]                                | EmptySet(EmptyObj)                 |
      | [EmptySet(Dyn), EmptySet(Dyn)]                                  | EmptySet(Dyn)                      |
      | [Set(["5"]), Unknown(Set(N))]                                   | UnknownNotNull(Set(S))             |
      | [Set(["5"]), Set([Unknown(S)])]                                 | UnknownNotNull(Set(S))             |

  Scenario Outline: Calculate the subtraction of one set from another
    Given set A is <setA>
    And set B is <setB>
    When I subtract set B from set A
    Then the result should be set <expectedDifference>
    And no error should occur

    Examples:
      | setA                      | setB                   | expectedDifference           |
      | EmptySet(S)               | EmptySet(S)            | EmptySet(S)                    |
      | Set([True])               | EmptySet(S)            | Set(["true"])                  | # Type coercion
      | Set([True])               | Set([False])           | Set([True])                    |
      | Set(["a","b","c"])        | Set(["a","c"])         | Set(["b"])                     |
      | Set(["a"])                | EmptySet(Dyn)          | Set(["a"])                     |
      | Set([EmptyObj])           | EmptySet(Dyn)          | Set([EmptyObj])                |
      | EmptySet(Dyn)             | EmptySet(Dyn)          | EmptySet(Dyn)                  |
      | Set(["5"])                | Unknown(Set(N))        | UnknownNotNull(Set(S))         |
      | Set(["5"])                | Set([Unknown(S)])      | UnknownNotNull(Set(S))         |

  Scenario Outline: Calculate the symmetric difference of two sets
    Given set A is <setA>
    And set B is <setB>
    When I calculate the symmetric difference of set A and set B
    Then the result should be set <expectedSymDifference>
    And no error should occur

    Examples:
      | setA                      | setB                   | expectedSymDifference        |
      | EmptySet(S)               | EmptySet(S)            | EmptySet(S)                    |
      | Set([True])               | EmptySet(S)            | Set(["true"])                  | # Type coercion
      | Set([True])               | Set([False])           | Set([True, False])             |
      | Set(["a","b","c"])        | Set(["a","c"])         | Set(["b"])                     |
      | Set(["a"])                | EmptySet(Dyn)          | Set(["a"])                     |
      | Set([EmptyObj])           | EmptySet(Dyn)          | Set([EmptyObj])                |
      | EmptySet(Dyn)             | EmptySet(Dyn)          | EmptySet(Dyn)                  |
      | Set(["5"])                | Unknown(Set(N))        | UnknownNotNull(Set(S))         |
      | Set(["5"])                | Set([Unknown(N)])      | UnknownNotNull(Set(S))         | # Input B was Unknown(Set(Number)) in test, assuming Unknown(Number) for single element in BDD for simplicity
