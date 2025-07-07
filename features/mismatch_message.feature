# Covers tests in cty/convert/mismatch_msg_test.go

Feature: Type Mismatch Message Generation
  Background:
    Given a Go environment

  Scenario Outline: Generate mismatch message
    Given the actual type is <actualType>
    And the expected type is <expectedType>
    When I generate a type mismatch message
    Then the message should be "<expectedMessage>"

    Examples:
      | actualType                                                          | expectedType                                                                 | expectedMessage                                      |
      | Bool                                                                | Number                                                                       | "number required"                                    |
      | EmptyObject                                                         | Object({"foo": String})                                                      | "attribute \"foo\" is required"                      |
      | EmptyObject                                                         | Object({"foo": String, "bar": String})                                       | "attributes \"bar\" and \"foo\" are required"        |
      | EmptyObject                                                         | Object({"foo": String, "bar": String, "baz": String})                        | "attributes \"bar\", \"baz\", and \"foo\" are required" |
      | EmptyObject                                                         | List(Object({"foo": String, "bar": String, "baz": String}))                   | "list of object required"                            |
      | List(String)                                                        | List(Object({"foo": String}))                                                | "incorrect list element type: object required"       |
      | List(EmptyObject)                                                   | List(Object({"foo": String}))                                                | "incorrect list element type: attribute \"foo\" is required" |
      | Tuple([EmptyObject])                                                | List(Object({"foo": String}))                                                | "element 0: attribute \"foo\" is required"           |
      | List(EmptyObject)                                                   | Set(Object({"foo": String}))                                                 | "incorrect set element type: attribute \"foo\" is required" |
      | Tuple([EmptyObject])                                                | Set(Object({"foo": String}))                                                 | "element 0: attribute \"foo\" is required"           |
      | Map(EmptyObject)                                                    | Map(Object({"foo": String}))                                                 | "incorrect map element type: attribute \"foo\" is required" |
      | Object({"boop": EmptyObject})                                       | Map(Object({"foo": String}))                                                 | "element \"boop\": attribute \"foo\" is required"    |
      | Tuple([EmptyObject, EmptyTuple])                                    | List(Dynamic)                                                                | "all list elements must have the same type"          |
      | Object({"foo": Bool, "bar": String, "baz": {"boop": Number}})       | Object({"foo": Bool, "bar": String, "baz": {"boop": Number, "beep": Bool}}) | "attribute \"baz\": attribute \"beep\" is required"    |
