# Original Go Test File: cty/convert/conversion_capsule_test.go
# This feature file covers the test cases found in cty/convert/conversion_capsule_test.go.

Feature: Capsule Type Conversion
  This feature describes how cty capsule types are converted to and from other cty types,
  especially when custom conversion logic is defined via CapsuleOps.

  Background:
    Given a capsule type "capTyString" for Go type "string" with custom operations:
      | Operation      | CustomLogic                                                                 |
      | GoString       | returns "capTy(<string_value>)"                                             |
      | TypeGoString   | returns "test thingy" (this name is used in error messages like "test thingy required") |
      | RawEquals      | compares underlying string values for equality                              |
      | ConversionFrom | allows conversion ONLY from cty.String, creating capTyString(source_string_value) |
      | ConversionTo   | allows conversion ONLY to cty.String, returning cty.StringVal(encapsulated_string)   |
    And a capsule type "capTyInt" for Go type "int" with custom operations:
      | Operation      | CustomLogic                                                                                                |
      | ConversionFrom | allows conversion from "capTyString" to "capTyInt" by parsing the encapsulated string to an int (this specific op is not directly exercised by the examples below) |
    # Note on capTyInt -> capTyString conversion:
    # The conversion from "capTyInt" to "capTyString" in the examples below works implicitly because:
    # 1. "capTyInt" encapsulates an 'int'.
    # 2. The 'int' value is first converted to a standard 'cty.String' value using cty's built-in rules (e.g., 42 becomes "42").
    # 3. "capTyString" can then be created from this intermediate 'cty.String' value via its 'ConversionFrom' operation.

  Scenario Outline: Converting capsule values
    # Covers test: TestConvertCapsuleType
    Given a cty value <FromValue> of type <FromType>
    When an attempt is made to convert the value to type <ToType>
    Then the result should be <ExpectedValue> of type <ExpectedTypeOrError>
    And the conversion error, if any, should be "<ExpectedErrorMessage>"

    Examples: Successful Conversions
      | FromValue            | FromType      | ToType        | ExpectedValue          | ExpectedTypeOrError | ExpectedErrorMessage |
      | Capsule("hello")     | capTyString   | String        | "hello"                | String              |                      |
      | "hello"              | String        | capTyString   | Capsule("hello")       | capTyString         |                      |
      | Unknown(capTyString) | capTyString   | String        | Unknown(String)        | String              |                      |
      | Null(capTyString)    | capTyString   | String        | Null(String)           | String              |                      |
      | CapsuleInt(42)       | capTyInt      | capTyString   | Capsule("42")          | capTyString         |                      |

    Examples: Failed Conversions
      | FromValue            | FromType      | ToType        | ExpectedValue | ExpectedTypeOrError | ExpectedErrorMessage          |
      | True                 | Bool          | capTyString   |               | Error               | "test thingy required"      |
      | Capsule("hello")     | capTyString   | Bool          |               | Error               | "bool required"             |
      | Unknown(Bool)        | Bool          | capTyString   |               | Error               | "test thingy required"      |
      | Null(Bool)           | Bool          | capTyString   |               | Error               | "test thingy required"      |
      | Unknown(capTyString) | capTyString   | Bool          |               | Error               | "bool required"             |
      | Null(capTyString)    | capTyString   | Bool          |               | Error               | "bool required"             |

    # Note:
    # - 'Capsule("hello")' refers to cty.CapsuleVal(capTyString, &"hello")
    # - 'CapsuleInt(42)' refers to cty.CapsuleVal(capTyInt, &42)
    # - 'Unknown(capTyString)' refers to cty.UnknownVal(capTyString)
    # - 'Null(capTyString)' refers to cty.NullVal(capTyString)
    # - 'Unknown(String)' refers to cty.UnknownVal(cty.String)
    # - 'Null(String)' refers to cty.NullVal(cty.String)
    # - 'ExpectedTypeOrError' is 'Error' if 'ExpectedErrorMessage' is present, otherwise it's the cty type of ExpectedValue.
