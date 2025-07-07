# Covers tests in cty/value_init_test.go

Feature: Cty Value Initialization and Type Validation
  Background:
    Given a Go environment

  Scenario: SetVal with marks
    Given a cty.Set value "plain_set" initialized with elements [True]
    And a cty.Set value "marked_set" initialized with elements [True] and marked with "1"
    And a cty.Set value "deep_marked_set" initialized with elements [True (mark "2"), True (mark "3")]
    Then "plain_set" should not be equal to "marked_set"
    And "marked_set" should not be equal to "deep_marked_set"
    And the marks of "marked_set" should be ["1"]
    And the marks of "deep_marked_set" should be ["2", "3"]

    When I unmark "deep_marked_set" forcefully into "unmarked_deep"
    Then "unmarked_deep" should be equal to SetVal([True])

  Scenario Outline: SetVal with nested structures
    Given a list of cty.Value elements for a set: <elements>
    When I attempt to create a cty.Set value with these elements
    Then the operation should succeed (no panic)

    Examples:
      | elements                                                              |
      | [Set([Number(5)])]                                                    |
      | [Set([Set([Number(5)])])]                                             |
      | [List([Number(5)])]                                                   |
      | [List([List([Number(5)])])]                                           |
      | [Map({"key":Number(5)})]                                               |
      | [Map({"key":Map({"child":"hello world"})})]                           |
      | [Tuple([Number(5)])]                                                  |
      | [Tuple([Tuple([Number(5)])])]                                         |

  Scenario Outline: Check if elements can form a valid cty.List
    Given a list of cty.Value elements <elements>
    When I check if these elements can form a valid cty.List
    Then the result should be <canFormList>

    Examples: Valid Lists
      | elements                                                              | canFormList |
      | ["Hello", "World"]                                                    | True        |
      | [Number(13), Number(31)]                                              | True        |
      | [True, False]                                                         | True        |
      | [["Hello", "World"], ["beep", "boop", "bloop"]]                       | True        |
      | [{"a":"Hello"}, {"c":"World"}] (as Maps)                               | True        |
      | [Set(["Hello","World"]), Set(["beep","boop","bloop"])]                | True        |

    Examples: Invalid Lists (due to type mismatch)
      | elements                                                              | canFormList |
      | ["hello", Number(13)]                                                 | False       |
      | [["Hello","World"], {"a":"bloop"} (as Map)]                           | False       |
      | [["Hello","World"], [["a","b"],["c","d"]]]                            | False       | # List of String vs List of List of String
      | [{"a":"Hello"}, {"a":True}] (as Maps)                                 | False       | # Inconsistent map element types

  Scenario Outline: Check if elements can form a valid cty.Set
    Given a list of cty.Value elements <elements>
    When I check if these elements can form a valid cty.Set
    Then the result should be <canFormSet>

    Examples: Valid Sets
      | elements                                                              | canFormSet  |
      | ["Hello", "World"]                                                    | True        |
      | ["Hello" (m 1), "World" (m 2)]                                        | True        |
      | [Number(13), Number(31)]                                              | True        |
      | [True, False]                                                         | True        |
      | [["Hello", "World"], ["beep", "boop", "bloop"]]                       | True        |
      | [{"a":"Hello"}, {"c":"World"}] (as Maps)                               | True        |
      | [Set(["Hello","World"]), Set(["beep","boop","bloop"])]                | True        |

    Examples: Invalid Sets (due to type mismatch)
      | elements                                                              | canFormSet  |
      | ["hello", Number(13)]                                                 | False       |
      | [["Hello","World"], {"a":"bloop"} (as Map)]                           | False       |
      | [["Hello","World"], [["a","b"],["c","d"]]]                            | False       |
      | [{"a":"Hello"}, {"a":True}] (as Maps)                                 | False       |

  Scenario Outline: Check if elements can form a valid cty.Map
    Given a map of string to cty.Value elements <elements>
    When I check if these elements can form a valid cty.Map
    Then the result should be <canFormMap>

    Examples: Valid Maps
      | elements                                                                          | canFormMap  |
      | {"a":"Hello", "b":"World"}                                                        | True        |
      | {"one":Number(13), "two":Number(31)}                                              | True        |
      | {"one":True, "two":False}                                                         | True        |
      | {"lista":["Hello","World"], "listb":["beep","boop","bloop"]}                      | True        |
      | {"map_a":{"a":"Hello"}, "map_b":{"c":"World"}} (as Maps)                           | True        |
      | {"set_a":Set(["Hello","World"]), "set_b":Set(["beep","boop","bloop"])}             | True        |

    Examples: Invalid Maps (due to type mismatch)
      | elements                                                                          | canFormMap  |
      | {"one":"hello", "two":Number(13)}                                                 | False       |
      | {"one":["Hello","World"], "two":{"a":"bloop"} (as Map)}                           | False       |
      | {"one":["Hello","World"], "two":[["a","b"],["c","d"]]}                            | False       |
      | {"one":{"a":"Hello"}, "two":{"a":True}} (as Maps)                                 | False       |
