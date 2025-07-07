# Covers tests in cty/convert/unify_test.go

Feature: Type Unification
  Background:
    Given a Go environment

  Scenario Outline: Unify a list of types
    Given a list of types <inputTypes>
    When I unify the list of types
    Then the unified type should be <expectedUnifiedType>
    And the conversion flags should be <expectedConversions>

    Examples: Basic Unification
      | inputTypes               | expectedUnifiedType | expectedConversions |
      | []                       | NilType             | nil                 |
      | [String]                 | String              | [false]             |
      | [Number]                 | Number              | [false]             |
      | [Number, Number]         | Number              | [false, false]      |
      | [Number, String]         | String              | [true, false]       |
      | [String, Number]         | String              | [false, true]       |
      | [Bool, String, Number]   | String              | [true, false, true] |
      | [Bool, Number]           | NilType             | nil                 |

    Examples: Object Unification
      | inputTypes                                                                 | expectedUnifiedType            | expectedConversions |
      | [Object({"foo":S}), Object({"foo":S})]                                     | Object({"foo":S})              | [false, false]      |
      | [Object({"foo":S}), Object({"foo":N})]                                     | Object({"foo":S})              | [false, true]       |
      | [Object({"foo":S}), Object({"bar":N})]                                     | Map(String)                    | [true, true]        |
      | [Object({"foo":S}), EmptyObject]                                           | Map(String)                    | [true, true]        |
      | [Object({"foo":B}), Object({"bar":N})]                                     | NilType                        | nil                 |
      | [Object({"foo":B}), Object({"foo":N})]                                     | NilType                        | nil                 |
      | [Object({"a":Object({"a":S})}), Object({"a":Object({"a":S,"b":S})})]        | Object({"a":Map(String)})      | [true, true]        |
      | [Object({"a":Object({"a":S}),"b":Object({"a":S,"b":S})}), Map(Object({"a":S,"b":S}))] | Map(Map(String))               | [true, true]        |
      | [Object({"a":Object({"a":S}),"b":Object({"a":S})}), Map(Object({"a":S}))]   | Map(Object({"a":S}))           | [true, false]       |
      | [Object({"a":Object({"a":S}),"b":Object({"a":S})}), Map(Dyn), Map(Object({"a":S}))] | Map(Dynamic)                 | [true, false, true] |
      | [Object({"a":Object({"a":Object({"a":S})}),"b":Object({"c":Object({"d":S})})}), Map(Map(Map(String)))] | Map(Map(Map(String)))         | [true, false]       |
      | [Map(Map(Map(S))), Object({"a":Object({"a":Object({"a":S}),"b":Map(S)}),"b":Map(Map(S))})] | Map(Map(Map(String)))         | [false, true]       |

    Examples: Tuple Unification
      | inputTypes                                                              | expectedUnifiedType     | expectedConversions |
      | [Tuple([S]), Tuple([S])]                                                | Tuple([String])         | [false, false]      |
      | [Tuple([S]), Tuple([N])]                                                | Tuple([String])         | [false, true]       |
      | [Tuple([S]), Tuple([S, N])]                                             | List(String)            | [true, true]        |
      | [Tuple([S]), EmptyTuple]                                                | List(String)            | [true, true]        |
      | [Tuple([B]), Tuple([N])]                                                | NilType                 | nil                 |
      | [Tuple([Object({"a":S}), Object({"a":S})]), Tuple([Object({"a":S,"b":S})])]| List(Map(String))       | [true, true]        |
      | [Tuple([Object({"a":S}), Dyn]), List(Dyn)]                              | NilType                 | nil                 | # Complex recursive case
      | [List(Object({"a":S})), Tuple([Object({"a":S,"b":S})]), Tuple([Object({"a":S,"b":S}),Object({"c":S,"d":S})])]| List(Map(String)) | [true, true, true]  |
      | [List(Object({"a":S})), List(Map(S)), Tuple([Map(S),Object({"a":S,"b":S})])]| List(Map(String))     | [true, false, true] |
      | [Tuple([Object({"a":S,"b":N}), Object({"a":S,"b":N})]), Tuple([Object({"a":S})])]| List(Map(String)) | [true, true]        |
      | [Tuple([Object({"a":S,"b":N})]), Tuple([Object({"a":S})])]               | Tuple([Map(String)])    | [true, true]        |
      | [List(Object({"a":N,"b":S})), Tuple([Object({"a":S})])]                  | List(Map(String))       | [true, true]        |
      | [List(Object({"a":N,"b":S})), List(Object({"a":S})])]                    | List(Map(String))       | [true, true]        |

    Examples: Nested Collection Unification
      | inputTypes                                                                                        | expectedUnifiedType            | expectedConversions |
      | [List(Object({"a":Object({"a":S}),"b":Object({"a":S,"b":S})})), List(Map(Object({"a":S,"b":S})))] | List(Map(Map(String)))         | [true, true]        |
      | [Object({"a":Object({"a":List(S)}),"b":Object({"a":Tuple([S]),"b":List(S)})}), Map(Object({"a":List(S),"b":List(S)}))] | Map(Map(List(String)))       | [true, true]        |

    Examples: Dynamic Type Unification
      | inputTypes               | expectedUnifiedType | expectedConversions |
      | [Dynamic, Tuple([N])]    | Dynamic             | [true, true]        |
      | [Dynamic, Object({"num":N})]| Dynamic           | [true, true]        |
      | [Tuple([N]), Dynamic, Object({"num":N})]| NilType | nil                 |
