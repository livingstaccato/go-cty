# Original Go Test File: cty/unknown_as_null_test.go
# This feature file covers tests for the UnknownAsNull function.

Feature: Converting Unknown and Dynamic Values to Null
  This feature describes the behavior of the `UnknownAsNull` function,
  which recursively traverses a cty.Value and converts all instances of
  UnknownValue and DynamicValue into NullValue of their respective types.

  Scenario Outline: Transforming unknown or dynamic values to null
    # Covers test: TestUnknownAsNull
    Given an input cty.Value <InputValue> of type <InputType>
    When the UnknownAsNull function is applied to it
    Then the result should be the cty.Value <ExpectedOutputValue> of type <ExpectedOutputType>

    Examples: Primitive Types
      | InputValue      | InputType     | ExpectedOutputValue | ExpectedOutputType |
      | String("hello") | String        | String("hello")     | String             |
      | Null(String)    | String        | Null(String)        | String             |
      | Unknown(String) | String        | Null(String)        | String             |
      | Dynamic         | DynamicType   | Null(DynamicType)   | DynamicType        |
      | Null(DynamicType)| DynamicType | Null(DynamicType)   | DynamicType        |
      | Null(Obj(t=S))  | Object(t=S)   | Null(Obj(t=S))      | Object(t=S)        |

    Examples: List Types
      | InputValue          | InputType    | ExpectedOutputValue     | ExpectedOutputType |
      | EmptyList(String)   | List(String) | EmptyList(String)       | List(String)       |
      | List(S("hello"))    | List(String) | List(S("hello"))        | List(String)       |
      | List(Null(String))  | List(String) | List(Null(String))      | List(String)       |
      | List(Unknown(S))    | List(String) | List(Null(String))      | List(String)       |

    Examples: Set Types
      | InputValue          | InputType   | ExpectedOutputValue    | ExpectedOutputType |
      | EmptySet(String)    | Set(String) | EmptySet(String)       | Set(String)        |
      | Set(S("hello"))     | Set(String) | Set(S("hello"))        | Set(String)        |
      | Set(Null(String))   | Set(String) | Set(Null(String))      | Set(String)        |
      | Set(Unknown(S))     | Set(String) | Set(Null(String))      | Set(String)        |

    Examples: Tuple Types
      | InputValue          | InputType    | ExpectedOutputValue    | ExpectedOutputType |
      | EmptyTupleVal       | EmptyTuple   | EmptyTupleVal          | EmptyTuple         |
      | Tuple(S("hello"))   | Tuple(S)     | Tuple(S("hello"))      | Tuple(S)           |
      | Tuple(Null(String)) | Tuple(S)     | Tuple(Null(String))    | Tuple(S)           |
      | Tuple(Unknown(S))   | Tuple(S)     | Tuple(Null(String))    | Tuple(S)           |

    Examples: Map Types
      | InputValue          | InputType   | ExpectedOutputValue        | ExpectedOutputType |
      | EmptyMap(String)    | Map(String) | EmptyMap(String)           | Map(String)        |
      | Map(g=S("hello"))   | Map(String) | Map(g=S("hello"))          | Map(String)        |
      | Map(g=Null(String)) | Map(String) | Map(g=Null(String))        | Map(String)        |
      | Map(g=Unknown(S))   | Map(String) | Map(g=Null(String))        | Map(String)        |

    Examples: Object Types
      | InputValue          | InputType   | ExpectedOutputValue        | ExpectedOutputType |
      | EmptyObjectVal      | EmptyObject | EmptyObjectVal             | EmptyObject        |
      | Obj(g=S("hello"))   | Obj(g=S)    | Obj(g=S("hello"))          | Obj(g=S)           |
      | Obj(g=Null(String)) | Obj(g=S)    | Obj(g=Null(String))        | Obj(g=S)           |
      | Obj(g=Unknown(S))   | Obj(g=S)    | Obj(g=Null(String))        | Obj(g=S)           |

    # Note on Value/Type Syntax:
    # - String("text") or S("text"), Number(n), True/False, Unknown(Type), Null(Type), Dynamic
    # - List(val,...), Set(val,...), Tuple(val,...), Map(key=val,...), Obj(key=val,...)
    # - EmptyList(T), EmptySet(T), EmptyTupleVal, EmptyMap(T), EmptyObjectVal
    # - Types: String (S), Number (N), Bool (B), List(T), Set(T), Tuple(T,...), Map(T), Object(attr=T,...), EmptyTuple, EmptyObject, DynamicType.
    # - Obj(t=S) is shorthand for Object(map[string]Type{"t": String}).
