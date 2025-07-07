# Original Go Test File: cty/function/stdlib/conversion_test.go
# This feature file covers tests for cty standard library conversion functions
# like tostring, tonumber, tobool, tolist, toset, tomap.

Feature: Standard Library Type Conversion Functions
  This feature describes the behavior of the `to<type>` functions in the
  cty standard library, which attempt to convert a given cty.Value to a
  specified target cty.Type.

  Scenario Outline: Converting a cty.Value to a target cty.Type using "to<Type>" functions
    # Covers test: TestTo (which tests MakeToFunc)
    Given a cty value <InputValue> of type <InputType>
    When the conversion function "to<TargetFunctionName>" is called with the input value
    Then the result should be <ExpectedValue> of type <ExpectedResultTypeOrError>
    And the conversion error, if any, should be "<ExpectedErrorMessage>"

    Examples: ToString Conversions
      | InputValue          | InputType     | TargetFunctionName | ExpectedValue   | ExpectedResultTypeOrError | ExpectedErrorMessage |
      | String("a")         | String        | string             | String("a")     | String                    |                      |
      | Unknown(String)     | String        | string             | Unknown(String) | String                    |                      |
      | Null(String)        | String        | string             | Null(String)    | String                    |                      |
      | True                | Bool          | string             | String("true")  | String                    |                      |
      | Unknown(Bool)       | Bool          | string             | Unknown(String) | String                    |                      |

    Examples: ToBool Conversions
      | InputValue          | InputType     | TargetFunctionName | ExpectedValue   | ExpectedResultTypeOrError | ExpectedErrorMessage                                                     |
      | String("a")         | String        | bool               |                 | Error                     | "cannot convert \"a\" to bool; only the strings \"true\" or \"false\" are allowed" |
      | String("true")      | String        | bool               | True            | Bool                      |                                                                          |
      | Unknown(String)     | String        | bool               | Unknown(Bool)   | Bool                      | # Optimistic conversion                                                  |

    Examples: ToNumber Conversions
      | InputValue          | InputType     | TargetFunctionName | ExpectedValue   | ExpectedResultTypeOrError | ExpectedErrorMessage                                                              |
      | String("a")         | String        | number             |                 | Error                     | "cannot convert \"a\" to number; given string must be a decimal representation of a number" |
      | String("123")       | String        | number             | Number(123)     | Number                    |                                                                                   |
      | Null(String)        | String        | number             | Null(Number)    | Number                    |                                                                                   |
      | Null(DynamicType)   | DynamicType   | number             | Null(Number)    | Number                    |                                                                                   |

    Examples: ToCollection Conversions (List, Set, Map)
      | InputValue                | InputType           | TargetFunctionName | ExpectedValue                        | ExpectedResultTypeOrError | ExpectedErrorMessage |
      | Tuple(String("h"), True)  | Tuple(String,Bool)  | list               | List(String("h"), String("true"))    | List(String)              |                      |
      | Tuple(String("h"), True)  | Tuple(String,Bool)  | set                | Set(String("h"), String("true"))     | Set(String)               |                      |
      | Obj(f=S("h"),b=True)      | Object(f=S,b=B)     | map                | Map(f=String("h"), b=String("true")) | Map(String)               |                      |
      | EmptyTuple                | EmptyTuple          | string             |                                      | Error                     | "cannot convert tuple to string" |
      | Unknown(EmptyTuple)       | EmptyTuple          | string             |                                      | Error                     | "cannot convert tuple to string" |

    Examples: ToObject Conversion (Error Case)
      | InputValue          | InputType     | TargetFunctionName | ExpectedValue   | ExpectedResultTypeOrError | ExpectedErrorMessage                                                     |
      | EmptyObject         | EmptyObject   | object_foo_string  |                 | Error                     | "incompatible object type for conversion: attribute \"foo\" is required" |
      # 'object_foo_string' implies a target type of Object(map[string]cty.Type{"foo": cty.String})

    # Note on Value Syntax:
    # String("a"), Number(123), True, Bool, Unknown(Type), Null(Type), DynamicType
    # List(...), Set(...), Tuple(...), Obj(key=Val), Map(key=Val), EmptyTuple, EmptyObject
    # Types: S=String, B=Bool, N=Number
    # TargetFunctionName: string, bool, number, list, set, map, object_<details_if_needed>
    # ExpectedResultTypeOrError: cty.Type or "Error" if ExpectedErrorMessage is present.
