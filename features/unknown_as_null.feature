# Covers tests in cty/unknown_as_null_test.go

Feature: Convert Unknown Values to Null Values
  Background:
    Given a Go environment

  Scenario Outline: Convert unknown cty.Value to its null equivalent
    Given an input cty.Value <inputValue>
    When I convert unknown values to null within this value
    Then the result should be <expectedValue>

    Examples: Primitive Types
      | inputValue        | expectedValue     |
      | "hello"           | "hello"           |
      | Null(String)      | Null(String)      |
      | Unknown(String)   | Null(String)      |
      | Null(Dynamic)     | Null(Dynamic)     |
      | Null(Object({"test":S})) | Null(Object({"test":S})) |
      | Dynamic           | Null(Dynamic)     | # DynamicVal becomes NullVal(DynamicPseudoType)

    Examples: List Types
      | inputValue        | expectedValue     |
      | EmptyList(String) | EmptyList(String) |
      | ["hello"]         | ["hello"]         |
      | [Null(String)]    | [Null(String)]    |
      | [Unknown(String)] | [Null(String)]    |

    Examples: Set Types
      | inputValue        | expectedValue     |
      | EmptySet(String)  | EmptySet(String)  |
      | Set(["hello"])    | Set(["hello"])    |
      | Set([Null(S)])    | Set([Null(S)])    |
      | Set([Unknown(S)]) | Set([Null(S)])    |

    Examples: Tuple Types
      | inputValue        | expectedValue     |
      | EmptyTuple        | EmptyTuple        |
      | Tuple(["hello"])  | Tuple(["hello"])  |
      | Tuple([Null(S)])  | Tuple([Null(S)])  |
      | Tuple([Unk(S)])   | Tuple([Null(S)])  |

    Examples: Map Types
      | inputValue               | expectedValue            |
      | EmptyMap(String)         | EmptyMap(String)         |
      | {"greeting":"hello"}     | {"greeting":"hello"}     |
      | {"greeting":Null(S)}     | {"greeting":Null(S)}     |
      | {"greeting":Unknown(S)}  | {"greeting":Null(S)}     |

    Examples: Object Types
      | inputValue               | expectedValue            |
      | EmptyObjectVal           | EmptyObjectVal           |
      | Obj({"greeting":"hello"})| Obj({"greeting":"hello"})|
      | Obj({"greeting":Null(S)})| Obj({"greeting":Null(S)})|
      | Obj({"greeting":Unk(S)}) | Obj({"greeting":Null(S)})|
