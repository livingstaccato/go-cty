# Original Go Test File: cty/function/function_test.go
# This feature file covers tests for the cty.function.Function struct and its methods.

Feature: cty Function Core Behavior
  This feature describes the core behavior of cty functions, including
  return type determination, updating descriptions, and handling of unknown/marked arguments.

  Background:
    Given a cty function defined by a Function Spec

  Scenario Outline: Determining return type for given argument values
    # Covers test: TestReturnTypeForValues
    Given a function spec with parameters <Params>, variadic parameter <VarParam>, and type logic <TypeLogic>
    And a function is created from this spec
    When the return type is requested for argument values <Args>
    Then the determined return type should be <ExpectedType>
    And an error should <ErrorOccur>

    Examples: Static Return Type
      | Params        | VarParam | TypeLogic              | Args                  | ExpectedType | ErrorOccur    | Description                                      |
      | []            | <none>   | StaticReturnType(Number) | []                    | Number       | not occur     | No params, static number return type             |
      | []            | <none>   | StaticReturnType(Number) | [Number(2)]           |              | occur         | Too many args for no-param function              |
      | []            | <none>   | StaticReturnType(Number) | [Unknown(Number)]     |              | occur         | Too many args (unknown) for no-param function    |
      | [Number]      | <none>   | StaticReturnType(Number) | [Number(2)]           | Number       | not occur     | One number param, static number return           |
      | [Number]      | <none>   | StaticReturnType(Number) | [Unknown(Number)]     | Number       | not occur     | Unknown number arg, static number return         |

    Examples: Dynamic Arguments and Return Types
      | Params                      | VarParam | TypeLogic              | Args                  | ExpectedType | ErrorOccur    | Description                                      |
      | [Number]                    | <none>   | StaticReturnType(Number) | [Dynamic]             | DynamicType  | not occur     | Dynamic arg, AllowDynamicType=false -> DynamicType |
      | [Number (AllowDynamic)]     | <none>   | StaticReturnType(Number) | [Dynamic]             | Number       | not occur     | Dynamic arg, AllowDynamicType=true -> Number       |
      | [Number (AllowDynamic)]     | <none>   | StaticReturnType(Number) | [Unknown(String)]     |              | occur         | Type mismatch even with AllowDynamicType         |
      | [Number (AllowDynamic)]     | <none>   | StaticReturnType(Number) | [String("hello")]     |              | occur         | Type mismatch even with AllowDynamicType         |

    Examples: Marked Values in Type Logic
      | Params        | VarParam                   | TypeLogic (Dynamic, checks marks) | Args                                      | ExpectedType | ErrorOccur    | Description                                       |
      | [List(Dyn)]   | <none>                     | Returns Number, errors if arg marked | [List(String("ok").Mark("m"))]          | Number       | not occur     | Type func receives marked args, returns type      |
      | [List(Str)]   | List(String) (AllowMarked) | Returns Number, errors if arg marked | [List("one"), List("two".Mark("m"))]    | Number       | not occur     | Type func receives marked varargs, returns type   |

    # Note on syntax:
    # Params: [Type1, Type2 (Option=Value), ...] where Option can be AllowDynamic, etc.
    # VarParam: Type (Option=Value) or <none>
    # TypeLogic: StaticReturnType(Type) or "Dynamic, checks marks" (for brevity)
    # Args: [Value1, Value2, ...]
    # Values: Number(2), String("h"), Unknown(Type), Dynamic, List(...), List(...).Mark("m")

  Scenario Outline: Updating function and parameter descriptions
    # Covers test: TestFunctionWithNewDescriptions
    Given an existing function "f1" with description "<OldFuncDesc>"
    And "f1" has positional parameters <OriginalPosParams>
    And "f1" has a variadic parameter <OriginalVarParam>
    When a new function "f2" is created from "f1" with new function description "<NewFuncDesc>"
    And new parameter descriptions <NewParamDescs>
    Then the description of "f1" should remain "<OldFuncDesc>"
    And the description of "f2" should be "<NewFuncDesc>"
    And for each original positional parameter at index <i> in "f1", its description should be <OriginalPosParamDesc[i]>
    And for each new positional parameter at index <i> in "f2", its description should be <ExpectedNewPosParamDesc[i]>
    And if "f1" has a variadic parameter, its description should be <OriginalVarParamDesc>
    And if "f2" has a variadic parameter, its description should be <ExpectedNewVarParamDesc>

    Examples:
      | OldFuncDesc | OriginalPosParams            | OriginalVarParam          | NewFuncDesc | NewParamDescs        | OriginalPosParamDesc | ExpectedNewPosParamDesc | OriginalVarParamDesc | ExpectedNewVarParamDesc |
      | "old func"  | []                           | <none>                    | "new func"  | <nil>                | []                   | []                      | <none>               | <none>                  |
      | "old func"  | [Param(a, "old a")]          | <none>                    | "new func"  | ["new a"]            | ["old a"]            | ["new a"]               | <none>               | <none>                  |
      | "old func"  | [Param(a,"old a"),Param(b,"old b")] | <none>              | "new func"  | ["new a", "new b"]   | ["old a", "old b"]   | ["new a", "new b"]      | <none>               | <none>                  |
      | "old func"  | [Param(a,"old a")]           | Param(b,"old b")          | "new func"  | ["new a", "new b"]   | ["old a"]            | ["new a"]               | "old b"              | "new b"                 |
      | "old func"  | [Param(a,"old a")]           | Param(b,"old b")          | "new func"  | ["new a"]            | ["old a"]            | ["new a"]               | "old b"              | "old b"                 | # VarParam desc not overridden
      | "old func"  | []                           | Param(a,"old a")          | "new func"  | ["new a"]            | []                   | []                      | "old a"              | "new a"                 |
      | "old func"  | []                           | Param(a,"old a")          | "new func"  | <nil>                | []                   | []                      | "old a"              | "old a"                 | # VarParam desc not overridden

    # Note on syntax:
    # Param(name, desc) represents a Parameter struct.
    # <nil> for NewParamDescs means the argument to WithNewDescriptions is nil.

  Scenario Outline: Calling function with unknown or marked arguments
    # Covers test: TestFunctionCallWithUnknownVals
    Given a function with parameters <Params>, variadic parameter <VarParam>, return type <ReturnType>, and result refiner <RefineResultLogic>
    When the function is called with arguments <Args>
    Then the result should be an <ExpectedResultCategory> value of type <ExpectedResultType>
    And the result's marks should be equivalent to <ExpectedMarks>
    And if the result is an Unknown value, its null-refined status should be <ExpectedNullRefinedStatus>

    Examples:
      | Params                                 | VarParam   | ReturnType | RefineResultLogic | Args                                   | ExpectedResultCategory | ExpectedResultType | ExpectedMarks      | ExpectedNullRefinedStatus |
      | [Str, Str]                             | <none>     | String     | <none>            | [Unknown(Str).Mark(s,e), Str("ok").Mark(e)] | Unknown                | String             | "s" (e is on arg 2 but not propagated) | not null                  | # Mark 'e' on arg2 not propagated because it's known
      | [Str, Str(AllowMarked)]                | <none>     | String     | <none>            | [Unknown(Str).Mark(s), Str("ok").Mark(am)] | Unknown                | String             | "s"                | not null                  | # Mark 'am' on arg2 with AllowMarked is not propagated
      | <none>                                 | String     | String     | <none>            | [Unknown(Str).Mark(s,e)]               | Unknown                | String             | "s", "e"           | not null                  |
      | [Str, Str(AllowMarked, AllowUnknown)]  | <none>     | String     | NotNull           | [Unknown(Str).Mark(f), Unknown(Str).Mark(s)] | Unknown                | String             | "f"                | not null                  | # 's' not propagated, result refined NotNull
      | [Str, Str(AllowMarked, AllowUnknown)]  | <none>     | DynamicType| NotNull           | [Dynamic.Mark(f), Dynamic.Mark(s)]     | Dynamic                | DynamicType        | "f"                |                           | # Dynamic result not refined, 's' not propagated

    # Note on syntax:
    # Params: [Type, Type(Option=Value)...]
    # VarParam: Type or <none>
    # ReturnType: Can be a concrete type or DynamicType
    # RefineResultLogic: <none> or NotNull
    # Args: [Value.Mark(m1,m2)...]
    # ExpectedMarks: "m1", "m2" (comma-separated if multiple)
    # ExpectedNullRefinedStatus: "not null" or "" (if not applicable e.g. for DynamicVal)
