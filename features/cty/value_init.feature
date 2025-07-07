# Original Go Test File: cty/value_init_test.go
# This feature file covers tests for cty.Value constructors,
# particularly for collection types, and how marks are handled.

Feature: cty.Value Initialization and Construction
  This feature describes how cty.Value objects are created, especially
  for collection types like Set, List, and Map, and how value marks
  are handled during construction.

  Scenario: SetVal constructor with marks
    # Covers test: TestSetVal
    Given a cty.Value "TrueVal" as True
    When a cty.SetVal "plain_set" is created with elements [TrueVal]
    And a cty.SetVal "marked_set" is created with elements [TrueVal] and then marked with "1"
    And a cty.SetVal "deep_marked_set" is created with elements [TrueVal.Mark("2"), TrueVal.Mark("3")]
    Then "plain_set" should not be RawEqualTo "marked_set"
    And "marked_set" should not be RawEqualTo "deep_marked_set"
    And "marked_set" should have marks ["1"]
    And "deep_marked_set" should have marks ["2", "3"] (marks from elements aggregate on the set)
    When "deep_marked_set" is force unmarked
    Then its underlying value should be RawEqualTo a SetVal created with elements [TrueVal]

  Scenario Outline: SetVal constructor with nested structure elements
    # Covers test: TestSetVal_nestedStructures
    # This test primarily ensures that SetVal does not panic with complex element types.
    Given a list of cty.Value elements: <Elements>
    When a cty.SetVal is created with these elements
    Then the construction should succeed without panic

    Examples:
      | ElementsDescription         | Elements                                         |
      | Set of Sets                 | [Set(Set(Number(5)))]                            |
      | Set of Lists                | [List(List(Number(5)))]                          |
      | Set of Maps                 | [Map(key=Map(child=String("hello")))]            |
      | Set of Tuples               | [Tuple(Tuple(Number(5)))]                        |

  Scenario Outline: Checking if elements can form a valid List (CanListVal)
    # Covers test: TestCanListVal
    Given a list of cty.Value elements: <Elements>
    When CanListVal is checked for these elements
    Then the result should be <CanFormList>

    Examples: Valid Lists (elements can unify to a common type)
      | ElementsDescription        | Elements                                    | CanFormList |
      | List of Strings            | [String("Hello"), String("World")]          | true        |
      | List of Numbers            | [Number(13), Number(31)]                    | true        |
      | List of Lists of Strings   | [List(S("H"),S("W")), List(S("b"),S("b"))]  | true        |
      | List of Maps of Strings    | [Map(a=S("H")), Map(c=S("W"))]              | true        |
      | List of Sets of Strings    | [Set(S("H"),S("W")), Set(S("b"),S("b"))]    | true        |

    Examples: Invalid Lists (elements cannot unify or have incompatible structures)
      | ElementsDescription        | Elements                                    | CanFormList |
      | String and Number          | [String("hello"), Number(13)]               | false       |
      | List of String and Map     | [List(S("H"),S("W")), Map(a=S("b"))]        | false       |
      | List of String and List of List | [List(S("H"),S("W")), List(List(S("a")))] | false       |
      | Maps with different value types | [Map(a=S("H")), Map(a=Bool(true))]      | false       |

  Scenario Outline: Checking if elements can form a valid Set (CanSetVal)
    # Covers test: TestCanSetVal
    # Similar logic to CanListVal regarding type unification. Marks on elements do not prevent set formation.
    Given a list of cty.Value elements: <Elements>
    When CanSetVal is checked for these elements
    Then the result should be <CanFormSet>

    Examples: Valid Sets
      | ElementsDescription        | Elements                                    | CanFormSet  |
      | Set of Strings             | [String("Hello"), String("World")]          | true        |
      | Set of Marked Strings      | [String("Hello").Mark(1), String("World").Mark(2)] | true    |
      | Set of Lists of Strings    | [List(S("H"),S("W")), List(S("b"),S("b"))]  | true        |

    Examples: Invalid Sets
      | ElementsDescription        | Elements                                    | CanFormSet  |
      | String and Number          | [String("hello"), Number(13)]               | false       |
      | List of String and Map     | [List(S("H"),S("W")), Map(a=S("b"))]        | false       |

  Scenario Outline: Checking if elements can form a valid Map (CanMapVal)
    # Covers test: TestCanMapVal
    # Checks if all values in a Go map[string]cty.Value can unify to a common type.
    Given a Go map of string to cty.Value elements: <ElementsMap>
    When CanMapVal is checked for this map
    Then the result should be <CanFormMap>

    Examples: Valid Maps
      | ElementsMapDescription     | ElementsMap                                 | CanFormMap  |
      | Map of Strings             | {"a":String("H"), "b":String("W")}          | true        |
      | Map of Lists of Strings    | {"l_a":List(S("H")), "l_b":List(S("b"))}    | true        |

    Examples: Invalid Maps
      | ElementsMapDescription     | ElementsMap                                 | CanFormMap  |
      | String and Number values   | {"s":String("H"), "n":Number(13)}           | false       |
      | List and Map values        | {"l":List(S("H")), "m":Map(a=S("b"))}       | false       |

    # Note on Value Syntax:
    # - String("text") or S("text"), Number(n), True/False.
    # - List(val,...), Set(val,...), Tuple(val,...), Map(key=val,...), Obj(key=val,...)
    # - .Mark(mark_val) for marked values.
    # - Elements for CanListVal/CanSetVal are Go slices of cty.Value.
    # - ElementsMap for CanMapVal is a Go map[string]cty.Value.
    # - Type abbreviations: S=String.
    # - Some complex structures are described textually for brevity in "ElementsDescription".
