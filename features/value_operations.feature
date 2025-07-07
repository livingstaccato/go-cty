# Covers tests in cty/value_ops_test.go

Feature: Cty Value Operations
  Background:
    Given a Go environment

  Scenario Outline: Compare two cty.Values for equality using 'Equals' method
    Given a cty.Value <lhs>
    And a cty.Value <rhs>
    When I compare them using the 'Equals' method
    Then the result should be cty.Value <expectedResult>

  Scenario Outline: Compare two cty.Values for raw equality using 'RawEquals' method
    Given a cty.Value <lhs>
    And a cty.Value <rhs>
    When I compare them using the 'RawEquals' method
    Then the result should be <expectedResult>

  Scenario Outline: Perform arithmetic and logical operations on cty.Values
    Given a cty.Value <lhs>
    And a cty.Value <rhs> (if applicable for the operation)
    When I perform operation <operation>
    Then the result should be cty.Value <expectedResult>

  Scenario Outline: Get an attribute from an object cty.Value
    Given an object cty.Value <objectValue>
    And an attribute name "<attributeName>"
    When I get the attribute
    Then the result should be cty.Value <expectedValue>

  Scenario Outline: Index into a collection cty.Value
    Given a collection cty.Value <collectionValue>
    And a key/index cty.Value <keyValue>
    When I index into the collection
    Then the result should be cty.Value <expectedValue>

  Scenario Outline: Check if a collection cty.Value has a key/index
    Given a collection cty.Value <collectionValue>
    And a key/index cty.Value <keyValue>
    When I check if the collection has the key/index
    Then the result should be cty.Value <expectedResult>

  Scenario Outline: Iterate over elements of a collection cty.Value
    Given a collection cty.Value <collectionValue>
    When I iterate over its elements, collecting (key, element) pairs, stopping if element is "stop"
    Then the collected pairs should be <expectedPairs>
    And the iteration should have stopped early if <stoppedEarly> is true

  Scenario Outline: Get the Go string representation of a cty.Value
    Given a cty.Value <inputValue>
    When I get its Go string representation
    Then the result should be "<expectedGoString>"

  Scenario Outline: Check if a cty.Value has a wholly known type
    Given a cty.Value <inputValue>
    When I check if it has a wholly known type
    Then the result should be <expectedKnownTypeResult>

  Scenario Outline: Check if a set cty.Value contains a specific element
    Given a set cty.Value <setValue>
    And an element cty.Value <elementValue>
    When I check if the set contains the element
    Then the result should be cty.Value <expectedResult>

  # --- Examples for ValueEquals ---
  Examples: Equals - Booleans
    | lhs   | rhs   | expectedResult |
    | True  | True  | True           |
    | False | False | True           |
    | True  | False | False          |

  Examples: Equals - Numbers
    | lhs                                 | rhs                                 | expectedResult         |
    | Number(1)                           | Number(2)                           | False                  |
    | Number(2)                           | Number(2)                           | True                   |
    | Number(2)                           | Number(2.2)                         | False                  |
    | Number(2.0)                         | Number(2.2)                         | False                  |
    | Number("0.0")                       | Number("-0.0")                      | True                   | # Zero equality
    | Number(0.0)                         | Number(0.0) * Number(-1)            | True                   | # Dynamic negative zero
    | Number("3.14...long")               | Number("3.14...long")               | True                   |
    | Number("-3.14...long")              | Number("-3.14...long")              | True                   |
    | Number("3.14...long")               | Number("-3.14...long")              | False                  |
    | Number("1.2")                       | Number(1.2)                         | True                   |
    | Number("1.22222")                   | Number(1.22222)                     | True                   |
    | Number("9223372036854775808")       | Number(9223372036854775808.0)       | True                   |

  Examples: Equals - Strings
    | lhs          | rhs          | expectedResult |
    | ""           | ""           | True           |
    | "hello"      | "hello"      | True           |
    | "hello"      | "world"      | False          |
    | "0"          | ""           | False          |
    | "años"       | "años"       | True           |
    | "años"       | "años"       | True           | # Normalization
    | "años"       | "anos"       | False          |

  Examples: Equals - Objects
    | lhs                                  | rhs                                  | expectedResult |
    | EmptyObjectVal                       | EmptyObjectVal                       | True           |
    | Obj({"num":1})                       | Obj({"num":1})                       | True           |
    | Obj({"h\u00e9llo":1})                | Obj({"he\u0301llo":1})                | True           | # Normalized keys
    | Obj({"num":1})                       | EmptyObjectVal                       | False          |
    | Obj({"num":1, "flag":True})          | Obj({"num":1, "flag":True})          | True           |
    | Obj({"num":1})                       | Obj({"num":2})                       | False          |
    | Obj({"num":1})                       | Obj({"othernum":1})                  | False          |
    | Obj({"num":1, "flag":True})          | Obj({"num":1})                       | False          |
    | Obj({"num":1, "flag":True})          | Obj({"num":1, "flag":False})         | False          |

  Examples: Equals - Tuples
    | lhs                               | rhs                               | expectedResult         |
    | EmptyTupleVal                     | EmptyTupleVal                     | True                   |
    | Tuple([Num(1)])                   | Tuple([Num(1)])                   | True                   |
    | Tuple([Num(1)])                   | Tuple([Num(2)])                   | False                  |
    | Tuple(["hi"])                     | Tuple([Num(1)])                   | False                  |
    | Tuple([Num(1)])                   | Tuple([Num(1),Num(2)])            | False                  |
    | Tuple([Unk(N)])                   | Tuple([Num(1)])                   | UnknownNotNull(Bool)   |
    | Tuple([Unk(N)])                   | Tuple([Unk(N)])                   | UnknownNotNull(Bool)   |
    | Tuple([Num(1)])                   | Tuple([DynVal])                   | UnknownNotNull(Bool)   |
    | Tuple([Num(1)])                   | Unknown(Tuple([N]))               | UnknownNotNull(Bool)   |
    | DynamicVal                        | Tuple([Num(1)])                   | UnknownNotNull(Bool)   |

  Examples: Equals - Lists
    | lhs                               | rhs                               | expectedResult |
    | EmptyList(N)                      | EmptyList(N)                      | True           |
    | EmptyList(N)                      | EmptyList(B)                      | False          |
    | [Num(1)]                          | [Num(1)]                          | True           |
    | [Num(1)]                          | EmptyList(S)                      | False          |
    | [Num(1),Num(2)]                   | [Num(1),Num(2)]                   | True           |

  Examples: Equals - Maps
    | lhs                               | rhs                               | expectedResult |
    | EmptyMap(N)                       | EmptyMap(N)                       | True           |
    | EmptyMap(N)                       | EmptyMap(B)                       | False          |
    | {"num":Num(1)}                    | {"num":Num(1)}                    | True           |
    | {"h\u00e9llo":Num(1)}             | {"he\u0301llo":Num(1)}             | True           |

  Examples: Equals - Sets
    | lhs                               | rhs                               | expectedResult         |
    | EmptySet(N)                       | EmptySet(N)                       | True           |
    | EmptySet(N)                       | EmptySet(B)                       | False          |
    | Set([Num(1)])                     | Set([Num(1)])                     | True           |
    | Set([Num(1),Num(2)])              | Set([Num(2),Num(1)])              | True           |
    | Set([Num(1)])                     | Set([Unk(N)])                     | UnknownNotNull(Bool)   |

  Examples: Equals - Capsules
    | lhs                               | rhs                               | expectedResult         |
    | Capsule("t1","A")                 | Capsule("t1","A")                 | True                   | # Assumes same instance for "A"
    | Capsule("t1","A")                 | Capsule("t1","B")                 | False                  |
    | Capsule("t1","A")                 | Capsule("t2","C")                 | False                  |
    | Capsule("t1","A")                 | Unknown(Capsule("t1"))            | UnknownNotNull(Bool)   |
    | Capsule("t1","A")                 | Unknown(Capsule("t2"))            | False                  |

  Examples: Equals - Unknowns and Dynamics
    | lhs                               | rhs                               | expectedResult         |
    | Num(2)                            | Unknown(N)                        | UnknownNotNull(Bool)   |
    | Num(1)                            | DynamicVal                        | UnknownNotNull(Bool)   |
    | Num(2)                            | Unknown(N) refined lowerBound 0   | UnknownNotNull(Bool)   |
    | Num(2)                            | Unknown(N) refined lowerBound 4   | False                  |
    | DynamicVal                        | True                              | UnknownNotNull(Bool)   |
    | DynamicVal                        | DynamicVal                        | UnknownNotNull(Bool)   |
    | ["hi",DynVal]                     | ["hi",DynVal]                     | UnknownNotNull(Bool)   |
    | ["hi",Unk(S)]                     | ["hi",Unk(S)]                     | UnknownNotNull(Bool)   |
    | Unknown(List(S)) refined lowerLen 1| EmptyList(S)                      | False                  |
    | {"s":"hi","d":DynVal}             | {"s":"hi","d":DynVal}             | UnknownNotNull(Bool)   |
    | Null(S)                           | Null(Dyn)                         | True                   |
    | Unknown(S)                        | Unknown(N)                        | UnknownNotNull(Bool)   |
    | ""                                | Null(Dyn)                         | False                  |
    | ""                                | Unknown(S)                        | UnknownNotNull(Bool)   |
    | Null(S)                           | Unknown(N)                        | UnknownNotNull(Bool)   |
    | "hello"                           | Unknown(N)                        | False                  |
    | Obj({"a":"a"})                    | Obj({"a":Null(Dyn)})              | False                  |
    | Obj({"a":Null(Dyn)})              | Obj({"a":DynVal})                 | UnknownNotNull(Bool)   |
    | Null(S)                           | UnknownNotNull(S)                 | False                  |
    | Unknown(S) refined Null           | Null(S)                           | True                   |
    | Unknown(S) refined prefix "foo-"  | "notfoo-bar"                      | False                  |

  Examples: Equals - Marks
    | lhs           | rhs           | expectedResult    |
    | "a" (m 1)     | "b"           | False (m 1)       |
    | "a"           | "b" (m 2)     | False (m 2)       |
    | "a" (m 1)     | "b" (m 2)     | False (m 1, 2)    |
    | {"a":"a"(m B)}| {"a":"a"(m L)}| True (m B, L)     |

  # --- Examples for ValueRawEquals ---
  Examples: RawEquals - General (subset of Equals, focuses on no Unknown/Dynamic ambiguity)
    | lhs                               | rhs                               | expectedResult |
    | True                              | True                              | True           |
    | Num(2)                            | Num(2)                            | True           |
    | "hello"                           | "hello"                           | True           |
    | EmptyObjectVal                    | EmptyObjectVal                    | True           |
    | Tuple([Num(1)])                   | Tuple([Num(1)])                   | True           |
    | EmptyList(N)                      | EmptyList(N)                      | True           |
    | EmptyMap(N)                       | EmptyMap(N)                       | True           |
    | EmptyMap(N) (m "a")               | EmptyMap(N) (m "a")               | True           |
    | EmptyMap(N) (m "a")               | EmptyMap(N)                       | False          | # Marks differ
    | EmptySet(N)                       | EmptySet(N)                       | True           |
    | Capsule("t1","A")                 | Capsule("t1","A")                 | True           |
    | DynamicVal                        | DynamicVal                        | True           |
    | Tuple([Unk(N)])                   | Tuple([Num(1)])                   | False          |
    | Tuple([Unk(N)])                   | Tuple([Unk(N)])                   | True           |
    | Null(S)                           | Null(Dyn)                         | False          | # Types differ
    | Unknown(S) refined Null           | Null(S)                           | False          | # Refinement vs actual null
    | Unknown(N) refined range 0-0 notnull | Num(0)                         | False          | # Refinement vs actual value

  # --- Examples for Arithmetic/Logical Operations ---
  Examples: Add
    | operation | lhs                               | rhs                               | expectedResult                      |
    | Add       | Num(1)                            | Num(2)                            | Num(3)                              |
    | Add       | Num(1)                            | Unk(N)                            | UnknownNotNull(N)                   |
    | Add       | Num(1)                            | Unk(N) refined lowerBound 2 false | UnknownNotNull(N) refined lowerBound 3 true |
    | Add       | Unk(N) refined lowerBound 1 true, upperBound 2 false | Unk(N) refined lowerBound 2 false, upperBound 3 false | UnknownNotNull(N) refined lowerBound 3 true, upperBound 5 true |
    | Add       | Num(0) (m 1)                      | Num(0) (m 2)                      | Num(0) (m 1,2)                      |

  Examples: Subtract
    | operation | lhs                               | rhs                               | expectedResult                      |
    | Subtract  | Num(1)                            | Num(2)                            | Num(-1)                             |
    | Subtract  | Num(1)                            | Unk(N)                            | UnknownNotNull(N)                   |
    | Subtract  | Num(1)                            | Unk(N) refined lowerBound 2 true  | UnknownNotNull(N) refined upperBound -1 true |
    | Subtract  | Unk(N) refined lowerBound 1 true, upperBound 2 false | Unk(N) refined lowerBound 2 false, upperBound 3 false | UnknownNotNull(N) refined lowerBound -2 true, upperBound 0 true |

  Examples: Negate
    | operation | lhs          | rhs  | expectedResult         |
    | Negate    | Num(1)       |      | Num(-1)                |
    | Negate    | Unk(N)       |      | UnknownNotNull(N)      |
    | Negate    | Num(0) (m 1) |      | Num(0) (m 1)           |

  Examples: Multiply
    | operation | lhs                               | rhs                               | expectedResult                      |
    | Multiply  | Num(4)                            | Num(2)                            | Num(8)                              |
    | Multiply  | Num(3)                            | Unk(N) refined lowerBound 2 false | UnknownNotNull(N) refined lowerBound 6 true |
    | Multiply  | Num(0)                            | Unk(N)                            | Num(0)                              |
    | Multiply  | Unk(N) refined lowerBound 1 true, upperBound 2 false | Num(0)          | Num(0)                              |

  Examples: Divide
    | operation | lhs    | rhs    | expectedResult     |
    | Divide    | Num(10)| Num(2) | Num(5)             |
    | Divide    | Num(5) | Num(0) | PositiveInfinity   |

  Examples: Modulo
    | operation | lhs    | rhs    | expectedResult     |
    | Modulo    | Num(10)| Num(2) | Num(0)             |
    | Modulo    | Num(5) | Num(0) | Num(5)             |

  Examples: Absolute
    | operation | lhs          | rhs  | expectedResult         |
    | Absolute  | Num(-1)      |      | Num(1)                 |
    | Absolute  | PosInfinity  |      | PosInfinity            |
    | Absolute  | NegInfinity  |      | PosInfinity            |
    | Absolute  | Unk(N)       |      | UnknownNotNull(N) refined range 0-Unknown |
    | Absolute  | Num(-1) (m 1)|      | Num(1) (m 1)           |

  Examples: Not (Logical)
    | operation | lhs        | rhs  | expectedResult       |
    | Not       | True       |      | False                |
    | Not       | Unk(B)     |      | UnknownNotNull(B)    |
    | Not       | True (m 1) |      | False (m 1)          |

  Examples: And (Logical)
    | operation | lhs    | rhs    | expectedResult       |
    | And       | True   | True   | True                 |
    | And       | False  | Unk(B) | False                |
    | And       | True   | Unk(B) | UnknownNotNull(B)    |

  Examples: Or (Logical)
    | operation | lhs    | rhs    | expectedResult       |
    | Or        | False  | False  | False                |
    | Or        | True   | Unk(B) | True                 |
    | Or        | False  | Unk(B) | UnknownNotNull(B)    |

  Examples: LessThan
    | operation | lhs                               | rhs    | expectedResult       |
    | LessThan  | Num(0)                            | Num(1) | True                 |
    | LessThan  | Unk(N) refined upperBound 0 true  | Num(1) | True                 |

  Examples: GreaterThan
    | operation | lhs                               | rhs    | expectedResult       |
    | GreaterThan | Num(1)                          | Num(0) | True                 |
    | GreaterThan | Unk(N) refined lowerBound 2 true| Num(1) | True                 |

  Examples: LessThanOrEqualTo
    | operation        | lhs    | rhs    | expectedResult       |
    | LessThanOrEqualTo| Num(0) | Num(0) | True                 |

  Examples: GreaterThanOrEqualTo
    | operation           | lhs    | rhs    | expectedResult       |
    | GreaterThanOrEqualTo| Num(1) | Num(0) | True                 |

  # --- Examples for GetAttr ---
  Examples: GetAttr
    | objectValue                             | attributeName | expectedValue    |
    | Obj({"greeting":"hello"})               | "greeting"    | "hello"          |
    | Obj({"gr\u00e9eting":"hello"})          | "gre\u0301eting"| "hello"          | # Normalized key
    | Unknown(Object({"gr\u00e9eting":S}))   | "gre\u0301eting"| Unknown(S)       |
    | DynamicVal                              | "hello"       | DynamicVal       |
    | Obj({"greeting":"hello"}) (m 1)         | "greeting"    | "hello" (m 1)    |

  # --- Examples for Index ---
  Examples: Index
    | collectionValue                       | keyValue      | expectedValue    |
    | ["hello"]                             | Num(0)        | "hello"          |
    | ["hello"]                             | Unk(N)        | Unknown(S)       |
    | Unknown(List(S))                      | Num(0)        | Unknown(S)       |
    | {"greeting":"hello"}                  | "greeting"    | "hello"          |
    | {"greeting":True}                     | Unk(S)        | Unknown(B)       |
    | DynamicVal                            | "hello"       | DynamicVal       |
    | Tuple(["hello", DynVal])              | Num(1)        | DynamicVal       |
    | ["hello"] (m 1)                       | Num(0)        | "hello" (m 1)    |
    | ["hello"]                             | Num(0) (m 1)  | "hello" (m 1)    |

  # --- Examples for HasIndex ---
  Examples: HasIndex
    | collectionValue                       | keyValue      | expectedResult       |
    | ["hello"]                             | Num(0)        | True                 |
    | ["hello","world"]                     | Num(2)        | False                |
    | ["hello"]                             | Unk(N)        | UnknownNotNull(B)    |
    | Unknown(List(S))                      | Num(0)        | UnknownNotNull(B)    |
    | {"greeting":"hello"}                  | "greeting"    | True                 |
    | {"greeting":"hello"}                  | "grouting"    | False                |
    | {"greeting":"hello"}                  | Unk(S)        | UnknownNotNull(B)    |
    | Tuple(["hello"])                      | Num(0)        | True                 |
    | DynamicVal                            | "hello"       | UnknownNotNull(B)    |
    | ["hello"] (m 1)                       | Num(0)        | True (m 1)           |

  # --- Examples for ForEachElement ---
  Examples: ForEachElement
    | collectionValue             | expectedPairs                                    | stoppedEarly |
    | EmptyList(S)                | []                                               | False        |
    | [Num(1),Num(2)]             | [{Key:0,Elem:1},{Key:1,Elem:2}]                  | False        |
    | ["hey","stop","hey"]        | [{K:0,E:"hey"},{K:1,E:"stop"}]                   | True         |
    | Set([Num(1),Num(10),Num(2)]) | [{K:1,E:1},{K:2,E:2},{K:10,E:10}]                | False        | # Sorted
    | {"s":Num(2),"f":Num(1)}     | [{K:"first",E:1},{K:"second",E:2}]               | False        | # Sorted by key
    | Tuple(["h",Num(2)])         | [{K:0,E:"hello"},{K:1,E:2}]                      | False        |

  # --- Examples for GoString ---
  Examples: GoString
    | inputValue                                     | expectedGoString                                                              |
    | Null(Dyn)                                      | "cty.NullVal(cty.DynamicPseudoType)"                                          |
    | Null(S)                                        | "cty.NullVal(cty.String)"                                                     |
    | Unknown(Dyn)                                   | "cty.DynamicVal"                                                              |
    | Unknown(S)                                     | "cty.UnknownVal(cty.String)"                                                  |
    | UnknownNotNull(S)                              | "cty.UnknownVal(cty.String).RefineNotNull()"                                  |
    | UnknownNotNull(S) refined prefix "a-"          | "cty.UnknownVal(cty.String).Refine().NotNull().StringPrefixFull(\"a-\").NewValue()" |
    | UnknownNotNull(S) refined prefix "foo"         | "cty.UnknownVal(cty.String).Refine().NotNull().StringPrefixFull(\"fo\").NewValue()" | # Truncated
    | Unknown(N) refined range 0-Unknown inclusive   | "cty.UnknownVal(cty.Number).Refine().NumberLowerBound(cty.NumberIntVal(0), true).NewValue()" |
    | ""                                             | "cty.StringVal(\"\")"                                                         |
    | Num(1.2)                                       | "cty.NumberFloatVal(1.2)"                                                     |
    | Num(1.0)                                       | "cty.NumberIntVal(1)"                                                         |
    | True                                           | "cty.True"                                                                    |
    | EmptyList(S)                                   | "cty.ListValEmpty(cty.String)"                                                |
    | [True]                                         | "cty.ListVal([]cty.Value{cty.True})"                                          |
    | EmptySet(S)                                    | "cty.SetValEmpty(cty.String)"                                                 |
    | EmptyTupleVal                                  | "cty.EmptyTupleVal"                                                           |
    | EmptyMap(S)                                    | "cty.MapValEmpty(cty.String)"                                                 |
    | EmptyObjectVal                                 | "cty.EmptyObjectVal"                                                          |

  # --- Examples for HasWhollyKnownType ---
  Examples: HasWhollyKnownType
    | inputValue                                 | expectedKnownTypeResult |
    | DynamicVal                                 | False                   |
    | Obj({"dyn":DynVal})                        | False                   |
    | Null(Object({"dyn":Dyn}))                  | True                    |
    | Tuple(["a",Null(Dyn)])                     | True                    |
    | [Obj({"null":Null(Dyn)})]                  | True                    |
    | [Null(Obj({"dyn":Dyn}))]                   | True                    |
    | Obj({"tuple":Tuple(["a",Null(Dyn)])})      | True                    |
    | Obj({"tuple":Tuple([Obj({"dyn":DynVal})])}) | False                   |

  # --- Examples for HasElement (Set specific) ---
  Examples: Set HasElement
    | setValue                                    | elementValue | expectedResult       |
    | EmptySet(S)                                 | "hello"      | False                |
    | Set(["hello"])                              | "hello"      | True                 |
    | Set(["hello",Unk(S)])                       | "world"      | UnknownNotNull(B)    |
    | Set([Unk(S)])                               | "world"      | UnknownNotNull(B)    |
    | Set(["hello",Unk(S)])                       | True         | False                | # Type mismatch
    | Set([Null(Dyn)])                            | Null(Dyn)    | True                 |
    | Set([DynVal])                               | DynVal       | UnknownNotNull(B)    |

  Scenario: Float copy ensures no modification of original cty.Value
    Given a cty.Value NumberFloat(1.9) as "v_float"
    And its GoString representation as "v_float_gostring"
    When I get the *big.Float from "v_float" and set its Int64 value to 1
    Then the GoString representation of "v_float" should still be "v_float_gostring"
