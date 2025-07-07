# Original Go Test File: cty/json_test.go (top-level one for Type marshaling)
# This feature file covers tests for JSON marshaling and unmarshaling of cty.Type itself.

Feature: cty.Type JSON Serialization
  This feature describes how cty.Type objects are serialized to and
  deserialized from JSON strings. This allows for transmitting or storing
  type definitions.

  Scenario Outline: Round-trip marshaling and unmarshaling of cty.Type
    # Covers test: TestTypeJSONable
    Given a cty.Type <CtyType>
    When the cty.Type is marshaled to JSON
    Then the resulting JSON string should be '<ExpectedJSONString>'
    When this JSON string is unmarshaled back into a cty.Type
    Then the resulting cty.Type should be equal to the original <CtyType>

    Examples: Primitive and Dynamic Types
      | CtyType     | ExpectedJSONString |
      | String      | "string"           |
      | Number      | "number"           |
      | Bool        | "bool"             |
      | DynamicType | "dynamic"          |

    Examples: Collection Types
      | CtyType        | ExpectedJSONString        |
      | List(Bool)     | "[\"list\",\"bool\"]"     |
      | Map(Bool)      | "[\"map\",\"bool\"]"      |
      | Set(Bool)      | "[\"set\",\"bool\"]"      |
      | List(Map(Bool))| "[\"list\",[\"map\",\"bool\"]]" |

    Examples: Tuple Types
      | CtyType              | ExpectedJSONString               |
      | Tuple([Bool, String])| "[\"tuple\",[\"bool\",\"string\"]]" |
      | EmptyTuple           | "[\"tuple\",[]]"                 | # EmptyTuple is Tuple([])

    Examples: Object Types
      | CtyType                                 | ExpectedJSONString                                     |
      | Object({"bool":B, "string":S})          | "[\"object\",{\"bool\":\"bool\",\"string\":\"string\"}]" | # Keys sorted
      | EmptyObject                             | "[\"object\",{}]"                                      |
      | ObjectWithOpt({"b":B,"s":S}, ["s","b"]) | "[\"object\",{\"b\":\"bool\",\"s\":\"string\"},[\"b\",\"s\"]]" | # Optional attrs listed, keys sorted

    # Note on Type Syntax:
    # - String, Number, Bool, DynamicType are primitive cty types.
    # - List(ElementType), Map(ElementType), Set(ElementType).
    # - Tuple([ElementType1, ElementType2, ...]), EmptyTuple.
    # - Object({attrName1: Type1, ...}), EmptyObject.
    # - ObjectWithOpt({attrName1: Type1, ...}, [optAttrName1, ...]).
    # - S=String, B=Bool. Attribute names in JSON for objects are sorted. Optional attribute names are sorted.
