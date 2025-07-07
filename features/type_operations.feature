# Covers tests in cty/type_test.go

Feature: Cty Type Operations
  Background:
    Given a Go environment

  Scenario Outline: Check if a cty.Type has dynamic types
    Given a cty.Type <typeStructure>
    When I check if the type has dynamic types
    Then the result should be <hasDynamic>

    Examples:
      | typeStructure                                            | hasDynamic |
      | Dynamic                                                  | True       |
      | List(Dynamic)                                            | True       |
      | Tuple([String, Dynamic])                                 | True       |
      | Object({"a":String, "unknown":Dynamic})                  | True       |
      | List(Object({"a":String, "unknown":Dynamic}))            | True       |
      | Tuple([Object({"a":String, "unknown":Dynamic})])         | True       |
      | String                                                   | False      | # Example of a non-dynamic type
      | List(Number)                                             | False      | # Example of a non-dynamic collection
      | Object({"a":String, "b":Number})                         | False      | # Example of a non-dynamic object

  Scenario Outline: Remove optional attributes deeply from a cty.Type
    Given a cty.Type <originalType>
    When I remove optional attributes deeply from the type
    Then the resulting cty.Type should be <expectedTypeWithoutOptional>

    Examples:
      | originalType                                                      | expectedTypeWithoutOptional                                 |
      | Dynamic                                                           | Dynamic                                                     |
      | List(Dynamic)                                                     | List(Dynamic)                                               |
      | Tuple([String, Dynamic])                                          | Tuple([String, Dynamic])                                    |
      | Object({"a":String, "unknown":Dynamic})                           | Object({"a":String, "unknown":Dynamic})                     |
      | Object({"a":String, "unknown":Dyn}, optional ["a"])               | Object({"a":String, "unknown":Dynamic})                     |
      | Map(Object({"a":S, "unknown":Dyn}, optional ["a"]))               | Map(Object({"a":String, "unknown":Dynamic}))               |
      | Set(Object({"a":S, "unknown":Dyn}, optional ["a"]))               | Set(Object({"a":String, "unknown":Dynamic}))               |
      | List(Object({"a":S, "unknown":Dyn}, optional ["a"]))              | List(Object({"a":String, "unknown":Dynamic}))              |
      | Tuple([Obj({"a":S,"unk":Dyn},opt ["a"]),Obj({"b":N},opt ["b"])]) | Tuple([Obj({"a":S,"unk":Dyn}),Obj({"b":N})])             |

  Scenario: NilType equality
    Given a default (zero value) cty.Type "defaultType"
    And the cty.NilType constant "NilTypeConst"
    When I check if "defaultType" equals "NilTypeConst"
    Then the result should be True

  Scenario Outline: Get Go string representation of a cty.Type
    Given a cty.Type <typeInput>
    When I get its Go string representation
    Then the result should be "<expectedGoString>"

    Examples:
      | typeInput                                            | expectedGoString                                                                 |
      | Dynamic                                              | "cty.DynamicPseudoType"                                                          |
      | String                                               | "cty.String"                                                                     |
      | Tuple([String, Bool])                                | "cty.Tuple([]cty.Type{cty.String, cty.Bool})"                                    |
      | Number                                               | "cty.Number"                                                                     |
      | Bool                                                 | "cty.Bool"                                                                       |
      | List(String)                                         | "cty.List(cty.String)"                                                           |
      | List(List(String))                                   | "cty.List(cty.List(cty.String))"                                                 |
      | List(Bool)                                           | "cty.List(cty.Bool)"                                                             |
      | Set(String)                                          | "cty.Set(cty.String)"                                                            |
      | Set(Map(String))                                     | "cty.Set(cty.Map(cty.String))"                                                   |
      | Set(Bool)                                            | "cty.Set(cty.Bool)"                                                              |
      | Tuple([Bool])                                        | "cty.Tuple([]cty.Type{cty.Bool})"                                                |
      | Map(String)                                          | "cty.Map(cty.String)"                                                            |
      | Map(Set(String))                                     | "cty.Map(cty.Set(cty.String))"                                                   |
      | Map(Bool)                                            | "cty.Map(cty.Bool)"                                                              |
      | Object({"foo":Bool})                                 | "cty.Object(map[string]cty.Type{\"foo\":cty.Bool})"                              | # Order of attributes in GoString may vary
      | Object({"foo":Bool, "bar":Str}, optional ["bar"])    | "cty.ObjectWithOptionalAttrs(map[string]cty.Type{\"bar\":cty.String, \"foo\":cty.Bool}, []string{\"bar\"})" | # Order of attributes and optional list in GoString may vary
