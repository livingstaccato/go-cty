# Original Go Test File: cty/set_internals_test.go
# This feature file covers tests for internal mechanisms of cty sets,
# specifically how values are hashed and ordered.

Feature: cty Set Internals - Hashing and Ordering
  This feature describes the internal mechanisms for hashing cty.Value objects
  for storage in sets and the rules for ordering elements within a set.

  Scenario Outline: Generating canonical hash bytes for cty.Value
    # Covers test: TestSetHashBytes
    Given a cty.Value <Value> of type <Type>
    When its canonical set hash bytes and marks are generated
    Then the hash bytes string should be "<ExpectedHashBytesString>"
    And the associated marks should be <ExpectedMarks>

    Examples: Primitives
      | Value          | Type   | ExpectedHashBytesString | ExpectedMarks |
      | Unknown(Number)| Number | "?"                     | none          |
      | Null(Number)   | Number | "~"                     | none          |
      | Dynamic        | Dyn    | "?"                     | none          |
      | Number(12)     | Number | "12"                    | none          |
      | String("")     | String | "\"\""                  | none          |
      | String("pizza")| String | "\"pizza\""             | none          |
      | True           | Bool   | "T"                     | none          |
      | False          | Bool   | "F"                     | none          |

    Examples: Collections
      | Value                           | Type        | ExpectedHashBytesString   | ExpectedMarks |
      | EmptyList(Bool)                 | List(Bool)  | "[]"                      | none          |
      | List(True, False)               | List(Bool)  | "[T;F;]"                  | none          |
      | List(Unknown(Bool))             | List(Bool)  | "[?;]"                    | none          |
      | EmptyMap(Bool)                  | Map(Bool)   | "{}"                      | none          |
      | Map("true"=True, "false"=False) | Map(Bool)   | "{\"false\":F;\"true\":T;}" | none          | # Keys sorted
      | EmptySet(Bool)                  | Set(Bool)   | "[]"                      | none          |
      | Set(True, True, False)          | Set(Bool)   | "[F;T;]"                  | none          | # Elements sorted
      | EmptyObjectVal                  | EmptyObject | "<>"                      | none          |
      | Obj(name=S("E"),age=Num(54))    | Obj(n=S,a=N)| "<54;\"E\";>"              | none          | # Attrs sorted by name
      | EmptyTupleVal                   | EmptyTuple  | "<>"                      | none          |
      | Tuple(S("E"), Num(54))          | Tuple(S,N)  | "<\"E\";54;>"              | none          |

    Examples: Marked Values
      | Value                  | Type   | ExpectedHashBytesString | ExpectedMarks |
      | String("pizza").Mark(1)| String | "\"pizza\""             | ["1"]         |
      | Obj(name=S("E").M(1), age=N(54).M(2)) | Obj(n=S,a=N) | "<54;\"E\";>" | ["1", "2"]    |

    Examples: Capsule Values
      | Value                         | Type         | ExpectedHashBytesString | ExpectedMarks |
      | Capsule(typeWithHash, "boop") | CapsuleTH    | "«\"boop\"»"            | none          |
      | Capsule(typeWithoutHash, "boop")| CapsuleTWO   | "«?»"                   | none          |

  Scenario Outline: Ordering of cty values within a set (setRules.Less)
    # Covers test: TestSetOrder
    Given a cty.Value A: <ValueA> of type <TypeA>
    And a cty.Value B: <ValueB> of type <TypeB> # Assuming TypeA and TypeB are compatible for set comparison
    When set ordering rule `Less(A, B)` is evaluated
    Then the result should be <A_is_less_than_B>

    Examples: String Ordering (Lexicographical)
      | ValueA        | TypeA  | ValueB        | TypeB  | A_is_less_than_B |
      | String("a")   | String | String("b")   | String | true             |
      | String("b")   | String | String("a")   | String | false            |

    Examples: Number Ordering (Numerical)
      | ValueA        | TypeA  | ValueB        | TypeB  | A_is_less_than_B |
      | Number(0)     | Number | Number(1)     | Number | true             |
      | Number(1)     | Number | Number(0)     | Number | false            |

    Examples: Boolean Ordering (False < True)
      | ValueA        | TypeA  | ValueB        | TypeB  | A_is_less_than_B |
      | False         | Bool   | True          | Bool   | true             |
      | True          | Bool   | False         | Bool   | false            |

    Examples: Unknown and Null Ordering (Pushed to end: Known < Unknown < Null)
      | ValueA          | TypeA  | ValueB          | TypeB  | A_is_less_than_B |
      | Unknown(String) | String | Unknown(String) | String | false            | # No defined order between two unknowns of same type
      | Null(String)    | String | String("a")     | String | false            |
      | String("a")     | String | Null(String)    | String | true             |
      | Unknown(String) | String | Null(String)    | String | true             |
      | Null(String)    | String | Unknown(String) | String | false            |

    Examples: Other Types (Arbitrary but consistent fallback based on hash bytes)
      | ValueA             | TypeA      | ValueB             | TypeB      | A_is_less_than_B |
      | EmptyList(String)  | List(S)    | List(String("b"))  | List(S)    | false            | # Based on hash bytes of "[]" vs "[b;]"
      | List(String("b"))  | List(S)    | EmptyList(String)  | List(S)    | true             |
      | EmptySet(String)   | Set(S)     | Set(String("b"))   | Set(S)     | false            |
      | EmptyMap(String)   | Map(S)     | Map(k=String("b")) | Map(S)     | false            |

  Scenario Outline: Comparing setRules instances for equality (setRules.SameRules)
    # Covers test: TestSetRulesSameRules
    Given a setRules instance "rulesA" for element type <ElementTypeA>
    And a setRules instance "rulesB" for element type <ElementTypeB>
    When "rulesA.SameRules(rulesB)" is evaluated
    Then the result should be <AreSameRules>

    Examples:
      | ElementTypeA        | ElementTypeB        | AreSameRules |
      | EmptyObject         | DynamicType         | false        |
      | EmptyObject         | EmptyObject         | true         |
      | String              | String              | true         |
      | Object({"a":String})| Object({"a":String})| true         |
      | Object({"a":String})| Object({"a":Bool})  | false        |

    # Note on Value/Type Syntax:
    # - Values: String("val"), Number(val), True, False, Unknown(Type), Null(Type), Dynamic, EmptyList(Type), List(...), etc.
    # - Types: String (S), Number (N), Bool (B), List(Type), Map(Type), Set(Type), Tuple(Type,...), Object(attrs), EmptyObject, EmptyTuple, Dyn(DynamicType).
    # - Marks: .Mark(mark_val) or .M(mark_val). Represented as a list of strings, e.g. ["1"]. "none" for no marks.
    # - Capsule(type, "val_str") represents a capsule value. typeWithHash and typeWithoutHash are specific test capsule types.
    # - Obj(name=S("E"),age=Num(54)) is short for ObjectVal(map[string]Value{"name":StringVal("E"),"age":NumberIntVal(54)})
    # - ExpectedHashBytesString: «» for capsules, <> for object/tuple, [] for list/set, {} for map. String quotes are included. Elements are semi-colon delimited. Map keys are sorted.
    # - Set ordering for "Other Types" is based on the hash bytes and is not a compatibility guarantee, just for test consistency.
