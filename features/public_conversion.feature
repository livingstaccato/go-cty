# Covers tests in cty/convert/public_test.go

Feature: Public Value Conversion
  Background:
    Given a Go environment

  Scenario Outline: Convert value to a specified type
    Given a value <fromValue> of type <fromType>
    When I convert the value to type <toType>
    Then the result should be value <expectedValue> of type <expectedType>
    And no error should occur

    Examples: Basic Conversions
      | fromValue | fromType | toType   | expectedValue   | expectedType |
      | "hello"   | String   | String   | "hello"         | String       |
      | "1"       | String   | Number   | 1               | Number       |
      | "1.5"     | String   | Number   | 1.5             | Number       |
      | "true"    | String   | Bool     | True            | Bool         |
      | "1"       | String   | Bool     | True            | Bool         |
      | "false"   | String   | Bool     | False           | Bool         |
      | "0"       | String   | Bool     | False           | Bool         |
      | 4         | Number   | String   | "4"             | String       |
      | 3.14159265359 | Number | String | "3.14159265359" | String       |
      | True      | Bool     | String   | "true"          | String       |
      | False     | Bool     | String   | "false"         | String       |
      | Unknown   | String   | Number   | Unknown         | Number       |
      | Unknown   | Number   | String   | Unknown         | String       |
      | Dynamic   | Dynamic  | String   | Unknown         | String       |
      | "hello"   | String   | Dynamic  | "hello"         | String       |
      | Null      | String   | Dynamic  | Null            | String       |
      | Unknown   | String   | Dynamic  | Unknown         | String       |

    Examples: List Conversions
      | fromValue          | fromType          | toType        | expectedValue      | expectedType      |
      | [5, 10]            | List(Number)      | List(String)  | ["5", "10"]        | List(String)      |
      | [5, 10]            | List(Number)      | List(Dynamic) | [5, 10]            | List(Number)      | # Type preserved
      | ["5", Unknown]     | Set(String)       | List(String)  | Unknown            | List(String)      | # Set to List with Unknown
      | [Unknown]          | Set(String)       | List(String)  | [Unknown]          | List(String)      | # Set with single Unknown to List
      | EmptyList(String)  | List(String)      | Set(Dynamic)  | EmptySet(String)   | Set(String)       |
      | EmptyList(Number)  | List(Number)      | List(Dynamic) | EmptyList(Number)  | List(Number)      |
      | NullValue(List(Number)) | List(Number) | List(Dynamic) | NullValue(List(Number)) | List(Number) |

    Examples: Set Conversions
      | fromValue        | fromType     | toType      | expectedValue    | expectedType    |
      | ["5", Unknown]   | Set(String)  | Set(Number) | [5, Unknown]     | Set(Number)     |
      | ["5", "10"]      | Set(String)  | List(String)| ["10", "5"]      | List(String)    | # Order may vary
      | ["5", "10"]      | Set(String)  | List(Dynamic)| ["10", "5"]      | List(String)    | # Order may vary, type preserved
      | [5, 10]          | Set(Number)  | List(String)| ["5", "10"]      | List(String)    | # Order may vary
      | [5, 10, 10]      | List(Number) | Set(String) | ["5", "10"]      | Set(String)     |
      | EmptySet(String) | Set(String)  | List(Dynamic)| EmptyList(String)| List(String)    |
      | NullValue(Set(Number)) | Set(Number) | Set(Dynamic) | NullValue(Set(Number)) | Set(Number) |
      | NullValue(Set(Number)) | Set(Number) | List(Dynamic) | NullValue(List(Number)) | List(Number) |

    Examples: Tuple to List/Set Conversions
      | fromValue        | fromType              | toType        | expectedValue   | expectedType   |
      | [5, "hello"]     | Tuple([Number,String])| List(String)  | ["5", "hello"]  | List(String)   |
      | [5, "12"]        | Tuple([Number,String])| List(Number)  | [5, 12]         | List(Number)   |
      | [5, 10]          | Tuple([Number,Number])| List(Dynamic) | [5, 10]         | List(Number)   | # Type preserved
      | [5, "hello"]     | Tuple([Number,String])| List(Dynamic) | ["5", "hello"]  | List(String)   | # Unified to String
      | [5, "hello"]     | Tuple([Number,String])| Set(Dynamic)  | ["5", "hello"]  | Set(String)    | # Unified to String
      | EmptyTuple       | EmptyTuple            | Set(String)   | EmptySet(String)| Set(String)    |

    Examples: Object to Map Conversions
      | fromValue               | fromType                         | toType       | expectedValue          | expectedType       |
      | {"num":5, "str":"hello"}  | Object({"num":N,"str":S})        | Map(String)  | {"num":"5", "str":"hello"} | Map(String)        |
      | {"num":5, "str":"12"}     | Object({"num":N,"str":S})        | Map(Number)  | {"num":5, "str":12}      | Map(Number)        |
      | {"num1":5, "num2":10}   | Object({"num1":N,"num2":N})      | Map(Dynamic)| {"num1":5, "num2":10}    | Map(Number)        | # Type preserved
      | {"num":5, "str":"hello"}  | Object({"num":N,"str":S})        | Map(Dynamic)| {"num":"5", "str":"hello"}| Map(String)        | # Unified to String
      | {"list":[], "tuple":()}  | Object({"list":List(B),"tuple":Tuple}) | Map(Dynamic)| {"list":[], "tuple":[]} | Map(List(Bool))  | # Unified to List(Bool)
      | {"map":{}, "obj":{}}    | Object({"map":Map(S),"obj":Object}) | Map(Dynamic)| {"map":{}, "obj":{}}    | Map(Map(String)) | # Unified to Map(String)

    Examples: Map to Object Conversions
      | fromValue                  | fromType    | toType                               | expectedValue                  | expectedType                             |
      | {"greeting":"H","name":"J"}| Map(String) | Object({"greeting":S,"name":S})        | {"greeting":"H","name":"J"}    | Object({"greeting":S,"name":S})        |
      | {"name":"J"}               | Map(String) | Object({"name":S,"greeting":S?})       | {"greeting":Null,"name":"J"}   | Object({"name":S,"greeting":S?})       |
      | {"a":2,"b":5}              | Map(Number) | Map(String)                          | {"a":"2","b":"5"}              | Map(String)                              |
      | {"greeting":"H","name":"J"}| Map(String) | Map(Dynamic)                         | {"greeting":"H","name":"J"}    | Map(String)                              | # Type preserved

    Examples: Object to Object Conversions
      | fromValue               | fromType                      | toType                          | expectedValue        | expectedType                          |
      | {"foo":"fv","bar":"bv"} | Object({"foo":S,"bar":S})     | Object({"foo":S})               | {"foo":"fv"}         | Object({"foo":S})                     |
      | {"foo":True}            | Object({"foo":B})             | Object({"foo":S})               | {"foo":"true"}       | Object({"foo":S})                     |
      | {"foo":Dynamic}         | Object({"foo":Dyn})           | Object({"foo":S})               | {"foo":Unknown}      | Object({"foo":S})                     |
      | {"foo":NullString}      | Object({"foo":S})             | Object({"foo":S})               | {"foo":NullString}   | Object({"foo":S})                     |
      | {"foo":True}            | Object({"foo":B})             | Object({"foo":Dyn})             | {"foo":True}         | Object({"foo":B})                     | # Type preserved
      | {"bar":"bv"}            | Object({"bar":S})             | Object({"foo":S?,"bar":S})      | {"foo":Null,"bar":"bv"}| Object({"foo":S?,"bar":S})      |
      | {"foo":"fv","bar":"bv"} | Object({"foo":S,"bar":S})     | Object({"foo":S?,"bar":S})      | {"foo":"fv","bar":"bv"}| Object({"foo":S?,"bar":S})      |

    Examples: Tuple to Tuple Conversions
      | fromValue | fromType        | toType          | expectedValue | expectedType    |
      | ["hello"] | Tuple([String]) | Tuple([String]) | ["hello"]     | Tuple([String]) |
      | [True]    | Tuple([Bool])   | Tuple([String]) | ["true"]      | Tuple([String]) |

    Examples: Marks Propagation
      | fromValue             | fromType     | toType       | expectedValue          | expectedType    |
      | "hello" (mark 1)      | String       | String       | "hello" (mark 1)       | String          |
      | "true" (mark 1)       | String       | Bool         | True (mark 1)          | Bool            |
      | ["hello" (mark 1)]    | Tuple([Str]) | List(String) | ["hello" (mark 1)]     | List(String)    |
      | {"foo":"h" (mark 1)}  | Object       | Map(String)  | {"foo":"h" (mark 1)}   | Map(String)     |
      | {"f":"h"(m1),"b":"w"(m1)}| Object    | Object({"f":S})| {"f":"h" (mark 1)}     | Object({"f":S}) |
      | {"f":"h", "b":"w"(m1)}| Object      | Object({"f":S})| {"f":"h"}              | Object({"f":S}) |

    Examples: Complex Nested Conversions (Reductions of GitHub Issues)
      | fromValue                                                                         | fromType | toType                          | expectedValue                                                                         | expectedType |
      | {"a":{"x":["foo"]},"b":{"x":["bar"]},"c":{"x":["foo","bar"]}}                       | Object   | Map(Map(Dynamic))               | {"a":{"x":["foo"]},"b":{"x":["bar"]},"c":{"x":["foo","bar"]}}                       | Map(Map(List(String))) |
      | {"a":{"x":"foo"},"b":{}}                                                           | Object   | Map(Map(Dynamic))               | {"a":{"x":"foo"},"b":{}}                                                           | Map(Map(String)) |
      | [{"a":Null},{"a":{"b":[{"c":"d"}]}}]                                               | Tuple    | List(Object({"a":Object({"b":List(Object({"c":S,"d":S?}))})})) | [{"a":Null},{"a":{"b":[{"c":"d","d":Null}]}}]                                       | List(Object) |
      | Null                                                                              | Dynamic  | Object({"foo":Object({"bar":S?})}) | Null                                                                              | Object({"foo":Object({"bar":S})}) |
      | Unknown                                                                           | Dynamic  | Object({"foo":Object({"bar":S?})}) | Unknown                                                                           | Object({"foo":Object({"bar":S})}) |
      | [{"a":{},"b":2},{"a":{"var1":"val1"},"b":"2"}]                                      | Tuple    | List(Object({"a":Dyn,"b":S}))   | [{"a":{},"b":"2"},{"a":{"var1":"val1"},"b":"2"}]                                   | List(Object) | # 'a' becomes Map(String)
      | ["a",9,Null]                                                                      | Tuple    | Set(Dynamic)                    | ["a","9",Null]                                                                      | Set(String)  | # Unified to String, Null preserved
      | ["a",9,Null]                                                                      | Tuple    | List(Dynamic)                   | ["a","9",Null]                                                                      | List(String) | # Unified to String, Null preserved
      | [Null,Null,Null]                                                                  | Tuple    | Set(Dynamic)                    | [Null]                                                                              | Set(Dynamic) |
      | [Null,Null,Null]                                                                  | Tuple    | List(Dynamic)                   | [Null,Null,Null]                                                                    | List(Dynamic)|
      | {"a":"boop"}                                                                      | Map(Str) | Object({"a":S,"b":S?,"c":Obj({"d":S})?}) | {"a":"boop","b":Null,"c":Null}                                                    | Object |
      | [{"d":10,"c":{"a":"foo","b":True}},{"d":5,"c":NullObj({"a":S,"b":B?})}]             | Tuple    | Set(Obj({"c":Obj({"a":S,"b":B?})?,"d":N})) | [{"d":10,"c":{"a":"foo","b":True}},{"d":5,"c":NullObj({"a":S,"b":B})}]           | Set(Object) |
      | [{"d":10,"c":{"a":"foo","b":True}},{"d":5}]                                        | Tuple    | Set(Obj({"c":Obj({"a":S,"b":B?})?,"d":N})) | [{"d":10,"c":{"a":"foo","b":True}},{"d":5,"c":NullObj({"a":S,"b":B})}]           | Set(Object) |
      | {"a":"boop"}                                                                      | Map(Str) | Object({"a":S,"b":S?,"c":Obj({"d":Dyn})?}) | {"a":"boop","b":Null,"c":Null}                                                    | Object |
      | {"a":"boop"}                                                                      | Map(Str) | Object({"a":S,"b":S?,"c":Dyn?})     | {"a":"boop","b":Null,"c":Null}                                                    | Object |
      | [{"xs":[{"x":1234}]},{"xs":[]}]                                                     | List(Obj)| List(Obj({"xs":List(Obj({"x":N?}))})) | [{"xs":[{"x":1234}]},{"xs":[]}]                                                     | List(Object) |
      | Set([{"xs":Set([{"x":1234}])},{"xs":EmptySet(Obj({"x":N}))}])                       | Set(Obj) | Set(Obj({"xs":Set(Obj({"x":N?}))}))   | Set([{"xs":Set([{"x":1234}])},{"xs":EmptySet(Obj({"x":N}))}])                       | Set(Object) |
      | {"foo":{"xs":{"nf":{"x":1234}}},"bar":{"xs":EmptyMap(Obj({"x":N}))}}                | Map(Obj) | Map(Obj({"xs":Map(Obj({"x":N?}))}))   | {"foo":{"xs":{"nf":{"x":1234}}},"bar":{"xs":EmptyMap(Obj({"x":N}))}}                | Map(Object) |

    Examples: Stripping Optional Attributes from Empty/Null Collections
      | fromValue                       | fromType                          | toType                            | expectedValue                   | expectedType                        |
      | EmptyList(Object({"a":S?}))     | List(Object({"a":S?}))           | Set(Object({"a":S?}))             | EmptySet(Object({"a":S}))       | Set(Object({"a":S}))              |
      | EmptyTuple                      | EmptyTuple                        | Set(Object({"a":S?}))             | EmptySet(Object({"a":S}))       | Set(Object({"a":S}))              |
      | EmptySet(Object({"a":S?}))      | Set(Object({"a":S?}))            | List(Object({"a":S?}))            | EmptyList(Object({"a":S}))      | List(Object({"a":S}))             |
      | EmptyTuple                      | EmptyTuple                        | List(Object({"a":S?}))            | EmptyList(Object({"a":S}))      | List(Object({"a":S}))             |
      | EmptyObject                     | EmptyObject                       | Map(Object({"a":S?}))             | EmptyMap(Object({"a":S}))       | Map(Object({"a":S}))              |
      | EmptyMap(String)                | Map(String)                       | Object({"a":S?})                  | {"a":Null}                      | Object({"a":S})                     |
      | NullValue(List(Obj({"a":S?})))  | List(Object({"a":S?}))           | Set(Object({"a":S?}))             | NullValue(Set(Obj({"a":S})))    | Set(Object({"a":S}))              |
      | NullValue(EmptyTuple)           | EmptyTuple                        | Set(Object({"a":S?}))             | NullValue(Set(Obj({"a":S})))    | Set(Object({"a":S}))              |
      | NullValue(Set(Obj({"a":S?})))   | Set(Object({"a":S?}))            | List(Object({"a":S?}))            | NullValue(List(Obj({"a":S})))   | List(Object({"a":S}))             |
      | NullValue(EmptyTuple)           | EmptyTuple                        | List(Object({"a":S?}))            | NullValue(List(Obj({"a":S})))   | List(Object({"a":S}))             |
      | NullValue(EmptyObject)          | EmptyObject                       | Map(Object({"a":S?}))             | NullValue(Map(Obj({"a":S})))    | Map(Object({"a":S}))              |
      | NullValue(Map(String))          | Map(String)                       | Object({"a":S?})                  | NullValue(Object({"a":S}))      | Object({"a":S})                     |

    Examples: Stripping Optional Attributes from Null Values in Collections
      | fromValue                             | fromType                          | toType                            | expectedValue                           | expectedType                        |
      | [NullValue(Object({"a":S?}))]         | List(Object({"a":S?}))           | Set(Object({"a":S?}))             | [NullValue(Object({"a":S}))]           | Set(Object({"a":S}))              |
      | [NullValue(Object({"a":S?}))]         | Tuple([Object({"a":S?})])         | Set(Object({"a":S?}))             | [NullValue(Object({"a":S}))]           | Set(Object({"a":S}))              |
      | Set([NullValue(Object({"a":S?}))])    | Set(Object({"a":S?}))            | List(Object({"a":S?}))            | [NullValue(Object({"a":S}))]           | List(Object({"a":S}))             |
      | [NullValue(Object({"a":S?}))]         | Tuple([Object({"a":S?})])         | List(Object({"a":S?}))            | [NullValue(Object({"a":S}))]           | List(Object({"a":S}))             |
      | {"obj":NullValue(Object({"a":S?}))}   | Object({"obj":Object({"a":S?})})  | Map(Object({"a":S?}))             | {"obj":NullValue(Object({"a":S}))}    | Map(Object({"a":S}))              |
      | {"obj":NullValue(Object({"a":S?}))}   | Map({"obj":Object({"a":S?})})     | Object({"obj":Object({"a":S?})})   | {"obj":NullValue(Object({"a":S}))}    | Object({"obj":Object({"a":S})})   |
      | {"obj":NullValue(Object({"a":N?}))}   | Map({"obj":Object({"a":N?})})     | Map(Object({"a":S?}))             | {"obj":NullValue(Object({"a":S}))}    | Map(Object({"a":S}))              | # Type conversion for null
      | [NullValue(Object({"a":N?}))]         | Tuple([Object({"a":N?})])         | Tuple([Object({"a":S?})])         | [NullValue(Object({"a":S}))]           | Tuple([Object({"a":S})])          | # Type conversion for null

    Examples: Unknown Value Refinements
      | fromValue                                    | fromType                      | toType       | expectedValue                                              | expectedType    |
      | Unknown(EmptyObject)                         | EmptyObject                   | Map(String)  | Unknown(Map(String)) refined with length 0                 | Map(String)     |
      | UnknownNotNull(EmptyObject)                  | EmptyObject                   | Map(String)  | EmptyMap(String)                                           | Map(String)     |
      | Unknown(Object({"a":S}))                     | Object({"a":S})               | Map(String)  | Unknown(Map(String)) refined with length 1                 | Map(String)     |
      | UnknownNotNull(Object({"a":S}))              | Object({"a":S})               | Map(String)  | Unknown(Map(String)) refined with not null, length 1       | Map(String)     |
      | Unknown(EmptyTuple)                          | EmptyTuple                    | List(String) | Unknown(List(String)) refined with length 0                | List(String)    |
      | UnknownNotNull(EmptyTuple)                   | EmptyTuple                    | List(String) | EmptyList(String)                                          | List(String)    |
      | Unknown(Tuple([S]))                          | Tuple([S])                    | List(String) | Unknown(List(String)) refined with length 1                | List(String)    |
      | UnknownNotNull(Tuple([S]))                   | Tuple([S])                    | List(String) | [Unknown(String)]                                          | List(String)    |
      | Unknown(EmptyTuple)                          | EmptyTuple                    | Set(String)  | Unknown(Set(String)) refined with length 0                 | Set(String)     |
      | UnknownNotNull(EmptyTuple)                   | EmptyTuple                    | Set(String)  | EmptySet(String)                                           | Set(String)     |
      | Unknown(Tuple([S]))                          | Tuple([S])                    | Set(String)  | Unknown(Set(String)) refined with length 1                 | Set(String)     |
      | UnknownNotNull(Tuple([S]))                   | Tuple([S])                    | Set(String)  | [Unknown(String)]                                          | Set(String)     |
      | Unknown(Tuple([S,S]))                        | Tuple([S,S])                  | Set(String)  | Unknown(Set(String)) refined with length 1-2             | Set(String)     |
      | UnknownNotNull(Tuple([S,S]))                 | Tuple([S,S])                  | Set(String)  | Unknown(Set(String)) refined with not null, length 1-2     | Set(String)     |
      | Unknown(List(S)) refined length 2-4          | List(String)                  | Set(String)  | Unknown(Set(String)) refined with length 1-4             | Set(String)     |
      | UnknownNotNull(List(S)) refined length 2-4   | List(String)                  | Set(String)  | UnknownNotNull(Set(S)) refined with length 1-4           | Set(String)     |
      | Unknown(Set(S)) refined length 2-4           | Set(String)                   | List(String) | Unknown(List(String)) refined with length 2-4            | List(String)    |
      | UnknownNotNull(Set(S)) refined length 2-4    | Set(String)                   | List(String) | UnknownNotNull(List(S)) refined with length 2-4          | List(String)    |
      | UnknownNotNull(Bool)                         | Bool                          | String       | UnknownNotNull(String)                                     | String          |
      | {"TTTattr":Unknown(Map(S))}                  | Object({"TTTattr":Map(S)})    | Object({"TTTattr":Obj({"s":S,"set":Set(S)?,"l":List(S)?,"m":Map(S)?})}) | {"TTTattr":Unknown(Obj({"s":S,"set":Set(S),"l":List(S),"m":Map(S)}))} | Object |
      | [{"optional_map":{}},{"optional_map":EmptyMap(Obj({"asdf":S}))}] | Tuple    | Set(Obj({"optional_map":Map(Obj({"asdf":S?}))?})) | Set([{"optional_map":EmptyMap(Obj({"asdf":S}))},{"optional_map":EmptyMap(Obj({"asdf":S}))}]) | Set(Object) |


  Scenario Outline: Convert value to a specified type with error
    Given a value <fromValue> of type <fromType>
    When I convert the value to type <toType>
    Then an error should occur with message "<errorMessage>"

    Examples:
      | fromValue                  | fromType    | toType                               | errorMessage                                                  |
      | "hello"                    | String      | Number                               | "a number is required"                                        |
      | "hello"                    | String      | Bool                                 | "a bool is required"                                        |
      | {"type":"ingress",...}     | Tuple       | List(Dynamic)                        | "all list elements must have the same type"                 | # Complex tuple from test
      | {"num":5,"bool":True}      | Object      | Map(Dynamic)                         | "all map elements must have the same type"                    |
      | {"greeting":"H","name":"J"}| Map(String) | Object({"greeting":List(S),"name":S})| "object required"                                           | # Should be "attribute greeting: must be a list"
      | {"name":"J"}               | Map(String) | Object({"name":S,"greeting":S})        | "map has no element for required attribute \"greeting\""      |
      | {"bar":"bv"}               | Object      | Object({"foo":S})                    | "attribute \"foo\" is required"                               |
      | {"bar":"bv"}               | Object      | Object({"foo":S,"baz":S})            | "attributes \"baz\" and \"foo\" are required"               |
      | EmptyObject                | Object      | Object({"foo":S,"bar":S,"baz":S})    | "attributes \"bar\", \"baz\", and \"foo\" are required"       |
      | EmptyObject                | Object      | Object({"foo":S?,"bar":S})           | "attribute \"bar\" is required"                               |
      | {"foo":True}               | Object      | Object({"foo":N})                    | "attribute \"foo\": number required"                          |
      | {"foo":Unknown(Bool)}      | Object      | Object({"foo":N})                    | "attribute \"foo\": number required"                          |
      | [True]                     | Tuple([B])  | EmptyTuple                           | "tuple required"                                              | # Not descriptive enough
      | EmptyTuple                 | EmptyTuple  | Tuple([String])                      | "tuple required"                                              | # Not descriptive enough
      | {"a":{"x":Null},"b":{"x":{"c":1,"d":2}}} | Object | Map(Map(Object({"x":Map(Dyn)}))) | "element \"b\": element \"x\": attribute \"x\" is required" |
      | [["a"],"b",Null]           | Tuple       | Set(Dynamic)                         | "all set elements must have the same type"                    |
      | [["a"],"b",Null]           | Tuple       | List(Dynamic)                        | "all list elements must have the same type"                    |
      | [["a"],"b"]                | Tuple       | Set(Dynamic)                         | "all set elements must have the same type"                    |
      | [["a"],"b"]                | Tuple       | List(Dynamic)                        | "all list elements must have the same type"                    |
      | {"a":"boop","c":"foobar"}  | Map(Str)    | Object({"a":S,"b":S?,"c":Obj({"d":S})?}) | "map element type is incompatible with attribute \"c\": object required" |
