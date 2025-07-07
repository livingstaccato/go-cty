# Covers tests in cty/function/function_test.go

Feature: Function Definition and Behavior
  Background:
    Given a Go environment

  Scenario Outline: Determine return type for given argument values
    Given a function specification:
      | Field            | Value                                              |
      | Parameters       | <parameters>                                       |
      | VariadicParameter| <variadicParameter>                                |
      | ReturnType       | <returnTypeStrategy>                               |
      | Implementation   | stub                                               |
    And argument values <argumentValues>
    When I determine the return type for these values
    Then the expected return type should be <expectedReturnType>
    And an error <shouldError> occur

    Examples: Basic Return Type
      | parameters | variadicParameter | returnTypeStrategy   | argumentValues | expectedReturnType | shouldError |
      | []         | null              | Static(Number)       | []             | Number             | should not  |
      | []         | null              | Static(Number)       | [2]            |                    | should      |
      | []         | null              | Static(Number)       | [Unknown(Num)] |                    | should      |

    Examples: Parameters and Return Type
      | parameters              | variadicParameter | returnTypeStrategy   | argumentValues | expectedReturnType | shouldError |
      | [{"Type":Number}]       | null              | Static(Number)       | [2]            | Number             | should not  |
      | [{"Type":Number}]       | null              | Static(Number)       | [Unknown(Num)] | Number             | should not  |
      | [{"Type":Number}]       | null              | Static(Number)       | [Dynamic]      | Dynamic            | should not  |
      | [{"Type":N,"AllowDyn":true}] | null         | Static(Number)       | [Dynamic]      | Number             | should not  |
      | [{"Type":N,"AllowDyn":true}] | null         | Static(Number)       | [Unknown(Str)] |                    | should      |
      | [{"Type":N,"AllowDyn":true}] | null         | Static(Number)       | ["hello"]      |                    | should      |

    Examples: Marked Values in Return Type Calculation
      | parameters                     | variadicParameter          | returnTypeStrategy        | argumentValues                       | expectedReturnType | shouldError |
      | [{"Type":List(Dyn)}]          | null                       | Dynamic(NoMarksCheck)     | [["ok" (mark "marked")]]             | Number             | should not  | # Test uses custom type func that doesn't actually check marks if args are marked
      | [{"Type":List(Str)}]          | {"Type":List(Str)}         | Dynamic(NoMarksCheck)     | [["one"], ["two" (mark "marked")]] | Number             | should not  | # Same as above

  Scenario Outline: Create function with new descriptions
    Given an initial function "f1" with description "<oldFuncDesc>"
    And parameters <oldParams>
    And variadic parameter <oldVarParam>
    When I create a new function "f2" from "f1" with function description "<newFuncDesc>" and parameter descriptions <newParamDescs>
    Then the description of "f1" should be "<oldFuncDesc>"
    And the description of "f2" should be "<newFuncDesc>"
    And the parameters of "f1" should be <oldParams>
    And the parameters of "f2" should be <updatedParams>
    And the variadic parameter of "f1" should be <oldVarParam>
    And the variadic parameter of "f2" should be <updatedVarParam>

    Examples: No Parameters
      | oldFuncDesc | oldParams | oldVarParam | newFuncDesc | newParamDescs | updatedParams | updatedVarParam |
      | old func    | []        | null        | new func    | null          | []            | null            |

    Examples: Positional Parameters
      | oldFuncDesc | oldParams                               | oldVarParam | newFuncDesc | newParamDescs      | updatedParams                             | updatedVarParam |
      | old func    | [{"Name":"a","Desc":"old a"}]           | null        | new func    | ["new a"]          | [{"Name":"a","Desc":"new a"}]             | null            |
      | old func    | [{"N":"a","D":"old a"},{"N":"b","D":"old b"}] | null    | new func    | ["new a","new b"]  | [{"N":"a","D":"new a"},{"N":"b","D":"new b"}] | null            |

    Examples: Variadic Parameter
      | oldFuncDesc | oldParams                     | oldVarParam             | newFuncDesc | newParamDescs      | updatedParams                 | updatedVarParam           |
      | old func    | [{"Name":"a","Desc":"old a"}] | {"Name":"b","Desc":"old b"} | new func  | ["new a","new b"]  | [{"Name":"a","Desc":"new a"}] | {"Name":"b","Desc":"new b"} |
      | old func    | [{"Name":"a","Desc":"old a"}] | {"Name":"b","Desc":"old b"} | new func  | ["new a"]          | [{"Name":"a","Desc":"new a"}] | {"Name":"b","Desc":"old b"} | # VarParam not overridden
      | old func    | []                            | {"Name":"a","Desc":"old a"} | new func  | ["new a"]          | []                            | {"Name":"a","Desc":"new a"} |
      | old func    | []                            | {"Name":"a","Desc":"old a"} | new func  | null               | []                            | {"Name":"a","Desc":"old a"} | # VarParam not overridden

  Scenario Outline: Function call with unknown or marked values
    Given a function with specification:
      | Field        | Value                                   |
      | Parameters   | <parameters>                            |
      | VarParam     | <varParam>                              |
      | ReturnType   | <returnTypeStrategy>                    |
      | RefineResult | <refineResult>                          |
      | Implementation| stub                                    |
    And argument values <argumentValues>
    When I call the function with these arguments
    Then the result should be <expectedResult>
    And an error should not occur

    Examples: Marks Propagation
      | parameters                                     | varParam | returnTypeStrategy | refineResult | argumentValues                               | expectedResult                       |
      | [{"N":"f","T":S},{"N":"b","T":S}]              | null     | Static(String)     | null         | [Unknown(S) (m "s","e"), "ok" (m "s","e")] | Unknown(S) (m "s","e")             |
      | [{"N":"f","T":S},{"N":"b","T":S,"AllowMark":true}] | null   | Static(String)     | null         | [Unknown(S) (m "s"), "ok" (m "allow_marked")]| Unknown(S) (m "s")                 |
      | null                                           | {"N":"f","T":S} | Static(String)| null         | [Unknown(S) (m "s","e")]                     | Unknown(S) (m "s","e")             |

    Examples: Refined Marked Values
      | parameters                                                        | varParam | returnTypeStrategy | refineResult | argumentValues                                     | expectedResult                               |
      | [{"N":"f","T":S},{"N":"s","T":S,"AllowMark":true,"AllowUnk":true}] | null     | Static(String)     | NotNull      | [Unknown(S) (m "first"), Unknown(S) (m "second")]| UnknownNotNull(S) (m "first")            |
      | [{"N":"f","T":S},{"N":"s","T":S,"AllowMark":true,"AllowUnk":true}] | null     | DynamicNoCall      | NotNull      | [Dynamic (m "first"), Dynamic (m "second")]      | Dynamic (m "first")                        | # Not refined because type is dynamic
