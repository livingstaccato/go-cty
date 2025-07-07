# Covers tests in cty/convert/conversion_capsule_test.go

Feature: Capsule Type Conversion
  Background:
    Given a Go environment
    And a capsule type "capTy" for string type with custom operations:
      | Operation      | Implementation                                                                 |
      | GoString       | returns "capTy(%q)" for the value                                              |
      | TypeGoString   | returns "capTy"                                                                |
      | RawEquals      | returns true if string values are equal                                        |
      | ConversionFrom | if source type is String, converts string to capsule value                     |
      | ConversionTo   | if destination type is String, converts capsule value to string                |
    And a capsule type "capIntTy" for integer type with custom operations:
      | Operation      | Implementation                                                                 |
      | ConversionFrom | if source type is "capTy", converts integer to "capTy" value of stringified int |

  Scenario Outline: Convert capsule value
    Given a value <fromValue> of type <fromType>
    When I convert the value to type <toType>
    Then the result should be value <expectedValue> of type <expectedType>
    And no error should occur

    Examples:
      | fromValue     | fromType | toType   | expectedValue | expectedType |
      | "hello"       | capTy    | String   | "hello"       | String       |
      | "hello"       | String   | capTy    | "hello"       | capTy        |
      | Unknown       | capTy    | String   | Unknown       | String       |
      | Null          | capTy    | String   | Null          | String       |
      | 42            | capIntTy | capTy    | "42"          | capTy        |

  Scenario Outline: Convert capsule value with error
    Given a value <fromValue> of type <fromType>
    When I convert the value to type <toType>
    Then an error should occur with message "<errorMessage>"

    Examples:
      | fromValue     | fromType | toType   | errorMessage           |
      | True          | Bool     | capTy    | "test thingy required" |
      | "hello"       | capTy    | Bool     | "bool required"        |
      | Unknown       | Bool     | capTy    | "test thingy required" |
      | Null          | Bool     | capTy    | "test thingy required" |
      | Unknown       | capTy    | Bool     | "bool required"        |
      | Null          | capTy    | Bool     | "bool required"        |
