# Covers tests in cty/json_test.go

Feature: Cty Type JSON Marshaling and Unmarshaling
  Background:
    Given a Go environment

  Scenario Outline: Marshal cty.Type to JSON and Unmarshal back
    Given a cty.Type <ctyType>
    When I marshal the cty.Type to JSON
    Then the JSON string should be <expectedJsonString>
    When I unmarshal this JSON string back to a cty.Type
    Then the resulting cty.Type should be <ctyType>
    And no error should occur during marshaling or unmarshaling

    Examples: Primitive Types
      | ctyType | expectedJsonString |
      | String  | "\"string\""       |
      | Number  | "\"number\""       |
      | Bool    | "\"bool\""         |
      | Dynamic | "\"dynamic\""      |

    Examples: Collection Types
      | ctyType               | expectedJsonString               |
      | List(Bool)            | "[\"list\",\"bool\"]"            |
      | Map(Bool)             | "[\"map\",\"bool\"]"             |
      | Set(Bool)             | "[\"set\",\"bool\"]"             |
      | List(Map(Bool))       | "[\"list\",[\"map\",\"bool\"]]"   |

    Examples: Tuple Types
      | ctyType               | expectedJsonString               |
      | Tuple([Bool, String]) | "[\"tuple\",[\"bool\",\"string\"]]" |

    Examples: Object Types
      | ctyType                                         | expectedJsonString                                             |
      | Object({"bool":B, "string":S})                  | "[\"object\",{\"bool\":\"bool\",\"string\":\"string\"}]"          | # Order of attributes in JSON may vary
      | Object({"bool":B,"str":S}, optional ["str","bool"]) | "[\"object\",{\"bool\":\"bool\",\"string\":\"string\"},[\"bool\",\"string\"]]" | # Order of attributes and optional list in JSON may vary
