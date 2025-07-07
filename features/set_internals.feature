# Covers tests in cty/set_internals_test.go

Feature: Set Internals - Hashing and Ordering
  Background:
    Given a Go environment

  Scenario Outline: Generate hash bytes for a cty.Value
    Given a cty.Value <value>
    When I generate its set hash bytes string and marks
    Then the hash bytes string should be "<expectedHashString>"
    And the collected marks should be <expectedMarks>

    Examples: Primitive Types
      | value               | expectedHashString | expectedMarks      |
      | Unknown(Number)     | "?"                | []                 |
      | Unknown(String)     | "?"                | []                 |
      | Null(Number)        | "~"                | []                 |
      | Null(String)        | "~"                | []                 |
      | Dynamic             | "?"                | []                 |
      | Number(12)          | "12"               | []                 |
      | String("")          | "\"\""             | []                 |
      | String("pizza")     | "\"pizza\""        | []                 |
      | True                | "T"                | []                 |
      | False               | "F"                | []                 |

    Examples: Collection Types
      | value                           | expectedHashString       | expectedMarks      |
      | EmptyList(Bool)                 | "[]"                     | []                 |
      | EmptyList(Dynamic)              | "[]"                     | []                 |
      | [True, False]                   | "[T;F;]"                 | []                 |
      | [Unknown(Bool)]                 | "[?;]"                   | []                 |
      | [EmptyList(Bool)]               | "[[];]"                  | []                 |
      | EmptyMap(Bool)                  | "{}"                     | []                 |
      | {"false":F, "true":T}           | "{\"false\":F;\"true\":T;}" | []                 | # Order of keys in hash is normalized
      | {"dyn":Dyn, "true":T, "unk":Unk(B)} | "{\"dynamic\":?;"true\":T;\"unknown\":?;}" | []    |
      | EmptySet(Bool)                  | "[]"                     | []                 |
      | Set([True, True, False])        | "[F;T;]"                 | []                 | # Order in set hash is normalized
      | Set([Unknown(B), Unknown(B)])   | "[?;?;]"                 | []                 | # Multiple unknowns allowed
      | EmptyObjectVal                  | "<>"                     | []                 |
      | Obj({"name":"erm","age":54})    | "<54;\"ermintrude\";>"   | []                 | # Order of attributes in hash is normalized
      | EmptyTupleVal                   | "<>"                     | []                 |
      | Tuple(["erm", 54])              | "<\"ermintrude\";54;>"   | []                 |

    Examples: Marked Values
      | value                           | expectedHashString       | expectedMarks      |
      | "pizza" (m 1)                   | "\"pizza\""              | [1]                |
      | Obj({"name":"erm"(m 1),"age":54(m 2)}) | "<54;\"ermintrude\";>"   | [1,2]              |

    Examples: Encapsulated Values
      | value                           | expectedHashString       | expectedMarks      |
      | Capsule("with hash","boop")     | "«\"boop\"»"             | []                 |
      | Capsule("no hash","boop")       | "«?»"                   | []                 |


  Scenario Outline: Compare two cty.Values for set ordering
    Given cty.Value A is <valueA>
    And cty.Value B is <valueB>
    And both values are of cty.Type <valueType>
    When I compare if A is less than B using set ordering rules for <valueType>
    Then the result should be <isALessThanB>

    Examples: String Ordering (Lexicographical)
      | valueA          | valueB          | valueType | isALessThanB |
      | "a"             | "b"             | String    | True         |
      | "b"             | "a"             | String    | False        |
      | Unknown(String) | "a"             | String    | False        |
      | "a"             | Unknown(String) | String    | True         |

    Examples: Number Ordering (Numerical)
      | valueA          | valueB          | valueType | isALessThanB |
      | Number(0)       | Number(1)       | Number    | True         |
      | Number(1)       | Number(0)       | Number    | False        |

    Examples: Boolean Ordering (False then True)
      | valueA          | valueB          | valueType | isALessThanB |
      | False           | True            | Bool      | True         |
      | True            | False           | Bool      | False        |

    Examples: Unknown and Null Ordering (Pushed to end)
      | valueA          | valueB          | valueType | isALessThanB |
      | Unknown(String) | Unknown(String) | String    | False        | # No defined order between two unknowns
      | Null(String)    | "a"             | String    | False        |
      | "a"             | Null(String)    | String    | True         |
      | Unknown(String) | Null(String)    | String    | True         |
      | Null(String)    | Unknown(String) | String    | False        |

    Examples: Other Types (Arbitrary but Consistent Fallback Sort)
      | valueA                      | valueB                      | valueType    | isALessThanB |
      | EmptyList(String)           | ["boop"]                    | List(String) | False        |
      | ["boop"]                    | EmptyList(String)           | List(String) | True         |
      | EmptySet(String)            | Set(["boop"])               | Set(String)  | False        |
      | Set(["boop"])               | EmptySet(String)            | Set(String)  | True         |
      | EmptyMap(String)            | {"blah":"boop"}             | Map(String)  | False        |
      | {"blah":"boop"}             | EmptyMap(String)            | Map(String)  | True         |

  Scenario Outline: Compare set rules for equality
    Given set rules A for type <typeA>
    And set rules B for type <typeB>
    When I check if set rules A are the same as set rules B
    Then the result should be <areSame>

    Examples:
      | typeA                  | typeB                  | areSame |
      | EmptyObject            | Dynamic                | False   |
      | EmptyObject            | EmptyObject            | True    |
      | String                 | String                 | True    |
      | Object({"a": String})  | Object({"a": String})  | True    |
      | Object({"a": String})  | Object({"a": Bool})    | False   |
