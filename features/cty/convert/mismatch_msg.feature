# Original Go Test File: cty/convert/mismatch_msg_test.go
# This feature file covers the test cases found in cty/convert/mismatch_msg_test.go.

Feature: Type Mismatch Error Messages
  This feature describes the expected error messages generated when a cty type
  conversion fails due to a type mismatch. The messages should be user-friendly
  and clearly indicate the nature of the mismatch.
  When multiple attributes are missing for an object type, they are listed alphabetically.

  Background:
    Given the cty type mismatch message generation function

  Scenario Outline: Generating mismatch messages
    # Covers test: TestMismatchMessage
    When the system encounters a value of type <ActualType>
    But it expected a value of type <ExpectedType>
    Then the generated mismatch error message should be "<ExpectedMessage>"

    Examples: Primitive Mismatches
      | ActualType  | ExpectedType | ExpectedMessage   |
      | Bool        | Number       | "number required" |

    Examples: Object Mismatches - Missing Attributes
      | ActualType  | ExpectedType                                  | ExpectedMessage                                  |
      | EmptyObject | Object({"foo":String})                        | "attribute \"foo\" is required"                  |
      | EmptyObject | Object({"foo":String, "bar":String})          | "attributes \"bar\" and \"foo\" are required"    | # Attributes listed alphabetically
      | EmptyObject | Object({"foo":String, "bar":String, "baz":String}) | "attributes \"bar\", \"baz\", and \"foo\" are required" | # Attributes listed alphabetically

    Examples: Collection Element Mismatches
      | ActualType               | ExpectedType                                     | ExpectedMessage                                          |
      | EmptyObject              | List(Object({"foo":String, "bar":String, "baz":String})) | "list of object required"                                | # Got object, want list(object)
      | List(String)             | List(Object({"foo":String}))                     | "incorrect list element type: object required"           |
      | List(EmptyObject)        | List(Object({"foo":String}))                     | "incorrect list element type: attribute \"foo\" is required" |
      | Tuple([EmptyObject])     | List(Object({"foo":String}))                     | "element 0: attribute \"foo\" is required"               |
      | List(EmptyObject)        | Set(Object({"foo":String}))                      | "incorrect set element type: attribute \"foo\" is required"  |
      | Tuple([EmptyObject])     | Set(Object({"foo":String}))                      | "element 0: attribute \"foo\" is required"               |
      | Map(EmptyObject)         | Map(Object({"foo":String}))                      | "incorrect map element type: attribute \"foo\" is required"|
      | Object({"boop":EmptyObject}) | Map(Object({"foo":String}))                      | "element \"boop\": attribute \"foo\" is required"        |

    Examples: Homogeneous Collection Type Mismatches
      | ActualType                              | ExpectedType              | ExpectedMessage                               |
      | Tuple([EmptyObject, EmptyTuple])        | List(DynamicType)         | "all list elements must have the same type" | # Tuple elements can't unify for List(Dynamic)

    Examples: Nested Object Mismatches
      | ActualType                                                                 | ExpectedType                                                                      | ExpectedMessage                                 |
      | Object({"foo":Bool, "bar":String, "baz":Object({"boop":Number})})           | Object({"foo":Bool, "bar":String, "baz":Object({"boop":Number, "beep":Bool})}) | "attribute \"baz\": attribute \"beep\" is required" |
