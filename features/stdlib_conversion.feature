# Covers tests in cty/function/stdlib/conversion_test.go

Feature: Standard Library Type Conversion Functions
  Background:
    Given a Go environment

  Scenario Outline: Convert value to a target type using 'To<Type>' function
    Given a value <inputValue> of type <inputType>
    And a target type <targetType>
    When I convert the value to the target type
    Then the result should be <expectedValue> of type <expectedType>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples: Successful Conversions
      | inputValue                     | inputType    | targetType                | expectedValue                      | expectedType              | shouldError | errorMessage |
      | "a"                            | String       | String                    | "a"                                | String                    | should not  |              |
      | Unknown(String)                | String       | String                    | Unknown(String)                    | String                    | should not  |              |
      | Null(String)                   | String       | String                    | Null(String)                       | String                    | should not  |              |
      | True                           | Bool         | String                    | "true"                             | String                    | should not  |              |
      | Null(String)                   | String       | Number                    | Null(Number)                       | Number                    | should not  |              |
      | Null(Dynamic)                  | Dynamic      | Number                    | Null(Number)                       | Number                    | should not  |              |
      | Unknown(Bool)                  | Bool         | String                    | Unknown(String)                    | String                    | should not  |              |
      | Unknown(String)                | String       | Bool                      | Unknown(Bool)                      | Bool                      | should not  |              | # Optimistic conversion
      | Tuple(["hello", True])         | Tuple        | List(String)              | ["hello", "true"]                  | List(String)              | should not  |              |
      | Tuple(["hello", True])         | Tuple        | Set(String)               | Set(["hello", "true"])             | Set(String)               | should not  |              |
      | Obj({"foo":"h", "bar":True})   | Object       | Map(String)               | {"foo":"h", "bar":"true"}          | Map(String)               | should not  |              |

    Examples: Conversion Failures
      | inputValue                     | inputType    | targetType                | expectedValue                      | expectedType              | shouldError | errorMessage |
      | "a"                            | String       | Bool                      | Dynamic                            | Dynamic                   | should      | "cannot convert \"a\" to bool; only the strings \"true\" or \"false\" are allowed" |
      | "a"                            | String       | Number                    | Dynamic                            | Dynamic                   | should      | "cannot convert \"a\" to number; given string must be a decimal representation of a number" |
      | EmptyTuple                     | Tuple        | String                    | Dynamic                            | Dynamic                   | should      | "cannot convert tuple to string" |
      | Unknown(EmptyTuple)            | Tuple        | String                    | Dynamic                            | Dynamic                   | should      | "cannot convert tuple to string" |
      | EmptyObject                    | Object       | Object({"foo": String})   | Dynamic                            | Dynamic                   | should      | "incompatible object type for conversion: attribute \"foo\" is required" |
