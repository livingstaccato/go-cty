# Covers tests in cty/function/stdlib/collection_test.go

Feature: Standard Library Collection Functions
  Background:
    Given a Go environment

  Scenario Outline: Check if collection has index/key
    Given a collection <collection>
    And a key <key>
    When I check if the collection has the key
    Then the result should be <expectedResult>
    And no error should occur

    Examples:
      | collection                         | key            | expectedResult         |
      | EmptyList(Number)                  | 2              | False                  |
      | [True]                             | 0              | True                   |
      | [True]                             | "hello"        | False                  |
      | EmptyMap(Bool)                     | "hello"        | False                  |
      | {"hello": True}                    | "hello"        | True                   |
      | EmptyTuple                         | "hello"        | False                  |
      | EmptyTuple                         | 0              | False                  |
      | Tuple([True])                      | 0              | True                   |
      | EmptyList(Number)                  | Unknown(Num)   | UnknownNotNull(Bool)   |
      | Unknown(List(Bool))                | Unknown(Num)   | UnknownNotNull(Bool)   |
      | EmptyList(Number)                  | Dynamic        | UnknownNotNull(Bool)   |
      | Dynamic                            | Dynamic        | UnknownNotNull(Bool)   |

  Scenario Outline: Chunk a list into smaller lists
    Given a list <listValue>
    And a chunk size <chunkSize>
    When I chunk the list by the given size
    Then the result should be <expectedChunkedList>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples:
      | listValue                      | chunkSize | expectedChunkedList                                  | shouldError | errorMessage |
      | EmptyList(String)              | 2         | EmptyList(List(String))                              | should not  |              |
      | Unknown(List(String))          | 2         | UnknownNotNull(List(List(String)))                   | should not  |              |
      | ["a"]                          | 2         | [["a"]]                                              | should not  |              |
      | ["a" (mark "b")]               | 2         | [["a" (mark "b")]]                                   | should not  |              |
      | ["a"] (mark "a")               | 2         | [["a"]] (mark "a")                                   | should not  |              |
      | ["a" (mark "b")] (mark "a")    | 2         | [["a" (mark "b")]] (mark "a")                        | should not  |              |
      | [Unknown(String)]              | 2         | [[Unknown(String)]]                                  | should not  |              |
      | ["a", "b"]                     | 2         | [["a", "b"]]                                         | should not  |              |
      | ["a", "b", "c"]                | 2         | [["a", "b"], ["c"]]                                  | should not  |              |
      | ["a", "b", "c", "d", "e", "f"] | 2         | [["a", "b"], ["c", "d"], ["e", "f"]]                 | should not  |              |
      | ["a"]                          | 0         | [["a"]]                                              | should not  |              | # Zero length means infinite
      | ["a"] (mark "a")               | 0         | [["a"]] (mark "a")                                   | should not  |              |
      | ["a"]                          | 0 (mark "a")| [["a"]] (mark "a")                                   | should not  |              |
      | ["a" (mark "b")]               | 0         | [["a" (mark "b")]]                                   | should not  |              |
      | EmptyList(String)              | -1        |                                                      | should      | "the size argument must be positive" |
      | EmptyList(String)              | Infinity  |                                                      | should      | "invalid size: value must be a whole number, between -9223372036854775808 and 9223372036854775807" |
      | EmptyList(String)              | 1.5       |                                                      | should      | "invalid size: value must be a whole number, between -9223372036854775808 and 9223372036854775807" |

  Scenario Outline: Check if a list contains a value
    Given a list <listValue>
    And a value <searchValue>
    When I check if the list contains the value
    Then the result should be <expectedResult>
    And an error <shouldError> occur

    Examples:
      | listValue                      | searchValue    | expectedResult         | shouldError |
      | ["the","quick","brown","fox"]  | "the"          | True                   | should not  |
      | ["the","quick","brown",Unknown]| "the"          | True                   | should not  |
      | ["the","quick","brown",Unknown]| "orange"       | UnknownNotNull(Bool)   | should not  |
      | ["the","quick","brown","fox"]  | "penguin"      | False                  | should not  |
      | [1,2,3,4]                      | 1              | True                   | should not  |
      | [1,2,3,4]                      | 42             | False                  | should not  |
      | [1,2,3,4]                      | "1"            | False                  | should not  | # Type mismatch
      | [Unknown,"quick","brown","fox"]| "quick"        | True                   | should not  |
      | [Unknown,"brown","fox"]        | "quick"        | UnknownNotNull(Bool)   | should not  |
      | Set(["quick","brown","fox"])   | "quick"        | True                   | should not  |
      | Set([Unknown,"brown","fox"])   | "quick"        | UnknownNotNull(Bool)   | should not  |
      | [{"a":Unknown}]                | {"a":"b"}      | UnknownNotNull(Bool)   | should not  |
      | Tuple(["quick","brown",3])     | 3              | True                   | should not  |

  Scenario Outline: Merge maps or objects
    Given a list of maps/objects <valuesToMerge>
    When I merge these values
    Then the result should be <expectedMergedValue>
    And an error <shouldError> occur

    Examples:
      | valuesToMerge                                                                 | expectedMergedValue                                      | shouldError |
      | [{"a":"b"}, {"c":"d"}]                                                        | {"a":"b", "c":"d"}                                       | should not  |
      | [{"a":Unknown}, {"c":"d"}]                                                    | {"a":Unknown, "c":"d"}                                   | should not  |
      | [NullMap(S), {"c":"d"}]                                                       | {"c":"d"}                                                | should not  |
      | [NullMap(S), NullObj({"a":List(S)})]                                          | EmptyObject                                              | should not  |
      | [EmptyMap(S)]                                                                 | EmptyMap(S)                                              | should not  |
      | [{"c":"d"}, NullObj({"a":List(S)})]                                           | {"c":"d"} (as Object)                                    | should not  |
      | [UnknownMap(S), {"c":"d"}]                                                    | UnknownNotNull(Map(S))                                   | should not  |
      | [Unknown(Dyn), {"c":"d"}]                                                     | Dynamic                                                  | should not  |
      | [{"a":"b","c":"d"}, {"a":"x"}]                                                | {"a":"x", "c":"d"}                                       | should not  |
      | [{"a":"b"}, ["a","x"]]                                                        |                                                          | should      | # Non-map/object
      | [{"a":"b"}, Null(S)]                                                          |                                                          | should      | # Non-map/object
      | [{"a":{"b":"c"}}, {"d":{"e":"f"}}]                                            | {"a":{"b":"c"}, "d":{"e":"f"}}                           | should not  |
      | [{"a":["b","c"]}, {"d":["e","f"]}]                                            | {"a":["b","c"], "d":["e","f"]}                           | should not  |
      | [{"a":["b","c"]}, {"d":{"e":"f"}}]                                            | Obj({"a":["b","c"], "d":{"e":"f"}})                       | should not  |
      | [Obj({"a":["b"]}), Obj({"d":Dyn})]                                            | Obj({"a":["b"], "d":Dyn})                                | should not  |
      | [Map({"a":["b"]}), Obj({"d":2})]                                               | Obj({"a":["b"], "d":2})                                  | should not  |
      | [Obj({"a":["b"],"b":"b"}), Obj({"a":{"e":"f"}})]                               | Obj({"a":{"e":"f"},"b":"b"})                              | should not  |
      | [EmptyMap(S), EmptyMap(S)]                                                    | EmptyMap(S)                                              | should not  |
      | [{"a":"a"(m "f"),"c":"c","d":"d"(m "f")}, {"a":"a","b":"b"(m "s"),"c":"c"(m "s")}] | {"a":"a","b":"b"(m "s"),"c":"c"(m "s"),"d":"d"(m "f")}   | should not  |
      | [{"a":"a"}(m "f"), {"a":"a","b":"b"}(m "s"), EmptyMap(S)(m "t")]               | {"a":"a","b":"b"} (m "f","s","t")                        | should not  |
      | [Obj({"a":"a","b":Null(S)})(m "f"), Obj({"a":"A","b":"B"})(m "s")]             | Obj({"a":"A","b":"B"}) (m "f","s")                       | should not  |

  Scenario Outline: Get element at index from collection
    Given a collection <collection>
    And an index <key>
    When I get the element at the index
    Then the result should be <expectedValue>
    And no error should occur

    Examples:
      | collection                         | key            | expectedValue          |
      | [True]                             | 0              | True                   |
      | {"hello": True}                    | "hello"        | True                   |
      | Tuple([True, "hello"])             | 0              | True                   |
      | Tuple([True, "hello"])             | 1              | "hello"                |
      | EmptyList(Number)                  | Unknown(Num)   | Unknown(Number)        |
      | Unknown(List(Bool))                | Unknown(Num)   | Unknown(Bool)          |
      | EmptyList(Number)                  | Dynamic        | Unknown(Number)        |
      | EmptyMap(Number)                   | Dynamic        | Unknown(Number)        |
      | Dynamic                            | "hello"        | Dynamic                |
      | Dynamic                            | Dynamic        | Dynamic                |

  Scenario Outline: Get length of collection
    Given a collection <collection>
    When I get the length of the collection
    Then the result should be <expectedLength>
    And no error should occur

    Examples:
      | collection                                  | expectedLength                                           |
      | EmptyList(Number)                           | 0                                                        |
      | [True]                                      | 1                                                        |
      | EmptySet(Number)                            | 0                                                        |
      | Set([True])                                 | 1                                                        |
      | Set([True, False])                          | 2                                                        |
      | Set([True, Unknown(Bool)])                  | Unknown(Number) refined not null, range 1-2            |
      | Set([Unknown(Bool)])                        | 1                                                        |
      | EmptyMap(Bool)                              | 0                                                        |
      | {"hello": True}                             | 1                                                        |
      | EmptyTuple                                  | 0                                                        |
      | Tuple([True])                               | 1                                                        |
      | Unknown(List(Bool))                         | Unknown(Number) refined not null, range 0-MaxInt         |
      | Dynamic                                     | Unknown(Number) refined not null, range 0-MaxInt         |
      | Unknown(List(Bool)) refined maxLen 2        | Unknown(Number) refined not null, range 0-2            |
      | ["hello","world"] (mark "secret")           | 2 (mark "secret")                                        |
      | ["hello" (m "a"), "world" (m "b")]          | 2                                                        |

  Scenario Outline: Lookup key in map with default value
    Given a map <mapValue>
    And a key <keyValue>
    And a default value <defaultValue>
    When I lookup the key in the map with the default value
    Then the result should be <expectedValue>
    And no error should occur

    Examples:
      | mapValue                             | keyValue       | defaultValue    | expectedValue                |
      | EmptyMap(String)                     | "baz"          | "foo"           | "foo"                        |
      | {"foo":"bar"}                        | "foo"          | "nope"          | "bar"                        |
      | {"boop":"beep"} (mark "a")           | "boop"         | "nope"          | "beep" (mark "a")            |
      | {"boop":"beep","frob":Unknown(S)}(m "a")| "boop"         | "nope"          | Unknown(S) (mark "a")        | # Key is "boop" in example, "frob" in code. Assuming "boop" for BDD.
      | {"boop":"beep"} (mark "a")           | "frob"         | "nope" (mark "b") | "nope" (mark "a", "b")       |
      | {"boop":"beep"(m "a"),"frob":"honk"(m "b")} | "frob"   | "nope" (mark "c") | "honk" (mark "b")            |
      | {"boop":"beep"(m "a"),"frob":"honk"(m "b")} | "squish" | "nope" (mark "c") | "nope" (mark "c")            |
      | {"boop":"beep"(m "a"),"frob":"honk"(m "b")} | "squish" | 5 (mark "c")      | "5" (mark "c")               |
      | {"boop":"beep","frob":"honk"}        | "boop" (m "a") | "nope"          | "beep" (mark "a")            |

  Scenario Outline: Get element from list or tuple with wrapping index
    Given a list or tuple <collection>
    And an index <indexValue>
    When I get the element at the wrapped index
    Then the result should be <expectedValue>
    And an error <shouldError> occur

    Examples:
      | collection                                    | indexValue | expectedValue        | shouldError |
      | ["the","quick","brown","fox"]                 | 2          | "brown"              | should not  |
      | ["the","quick","brown","fox"]                 | 5          | "quick"              | should not  | # Wraps: 5 % 4 = 1
      | ["the","quick","brown","fox"]                 | -1         | "fox"                | should not  | # Wraps: -1 % 4 = 3
      | ["the","quick","brown","fox"]                 | -6         | "brown"              | should not  | # Wraps: -6 % 4 = 2
      | ["the","quick","brown","fox"]                 | -9223372036854775808 | "the"      | should not  | # MinInt64 % 4 = 0
      | ["the","quick","brown","fox"]                 | 9223372036854775807  | "fox"      | should not  | # MaxInt64 % 4 = 3
      | [["the",...],["the",...]]                     | 0          | ["the","quick","brown","fox"] | should not  |
      | ["the","quick","brown","fox"]                 | Unknown(Num) | Unknown(String)      | should not  |
      | [1,2,3,4]                                     | 2          | 3                    | should not  |
      | ["the","quick","brown",Unknown(S)]            | 2          | "brown"              | should not  |
      | ["the","quick","brown",Unknown(S)]            | 3          | Unknown(String)      | should not  |
      | ["the","quick","brown"(m "fox"),Unknown(S)]   | 2          | "brown" (m "fox")    | should not  |
      | ["the","quick","brown"(m "fox"),Unknown(S)]   | 1          | "quick"              | should not  |
      | ["the","quick","brown"(m "fox"),Unknown(S)](m "all")| 2    | "brown" (m "fox","all")| should not  |
      | ["the","quick","brown","fox"]                 | "brown"    |                      | should      | # Not an index
      | ["the","quick","brown","fox"]                 | 0.5        |                      | should      | # Not an integer
      | ["the","quick","brown","fox"]                 | -9223372036854775809 |            | should      | # Index out of bounds
      | ["the","quick","brown","fox"]                 | 9223372036854775808  |            | should      | # Index out of bounds
      | Tuple(["the",Unknown(S),"brown",False])       | 0          | "the"                | should not  |
      | Tuple(["the",Unknown(S),"brown",False])       | 1          | Unknown(String)      | should not  |
      | Tuple(["the",Unknown(S),"brown",False])       | 3          | False                | should not  |
      | Tuple(["the",Unknown(S),"brown",False])       | 4          | "the"                | should not  | # Wraps
      | Tuple(["the",Unknown(S),"brown",False])       | 10         | "brown"              | should not  | # Wraps
      | Tuple(["the",Unknown(S),"brown",False])       | -1         | False                | should not  | # Wraps
      | Tuple(["the",Unknown(S),"brown",False])       | -6         | "brown"              | should not  | # Wraps
      | Unknown(Tuple([S,S,S,B]))                     | 0          | Unknown(String)      | should not  |
      | Unknown(Tuple([S,S,S,B]))                     | 3          | Unknown(Bool)        | should not  |

  Scenario Outline: Coalesce a list of lists/tuples
    Given a list of lists/tuples <inputLists>
    When I coalesce these lists/tuples
    Then the result should be <expectedResult>
    And an error <shouldError> occur

    Examples:
      | inputLists                                     | expectedResult     | shouldError |
      | [["a","b"], ["c","d"]]                         | ["a","b"]          | should not  |
      | [EmptyList(S), ["c","d"]]                      | ["c","d"]          | should not  |
      | [EmptyList(S), [3,4]]                          | [3,4]              | should not  | # Type is dynamic
      | [EmptyTuple, Tuple(["c","d"])]                 | Tuple(["c","d"])   | should not  |
      | [Unknown(List(S)), ["c","d"]]                  | Dynamic            | should not  |
      | [Null(List(S)), ["c","d"]]                     | ["c","d"]          | should not  |
      | [Null(List(S)), Null(List(S))]                 |                    | should      |
      | [{"a":True}, {"b":False}]                      |                    | should      | # Not lists/tuples
      | []                                             |                    | should      | # No arguments

  Scenario Outline: Get values from a map or object
    Given a collection <collection>
    When I get the values from the collection
    Then the result should be <expectedValues>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples:
      | collection                                  | expectedValues                 | shouldError | errorMessage            |
      | EmptyMap(String)                            | EmptyList(String)              | should not  |                         |
      | EmptyMap(String) (mark "a")                 | EmptyList(String) (mark "a")   | should not  |                         |
      | Null(Map(String))                           |                                | should      | "argument must not be null" |
      | Unknown(Map(String))                        | UnknownNotNull(List(String))   | should not  |                         |
      | {"hello":"world"}                           | ["world"]                      | should not  |                         |
      | {"hello":"world" (mark "a")}                | ["world" (mark "a")]           | should not  |                         |
      | {"hello":"world"} (mark "a")                | ["world"] (mark "a")           | should not  |                         |
      | {"hello":"world" (mark "a")} (mark "a")     | ["world" (mark "a")] (mark "a")| should not  |                         |
      | Obj({"hello":"world"})                      | Tuple(["world"])               | should not  |                         |
      | EmptyObject                                 | EmptyTuple                     | should not  |                         |
      | EmptyObject (mark "a")                      | EmptyTuple (mark "a")          | should not  |                         |
      | Null(EmptyObject)                           |                                | should      | "argument must not be null" |
      | Unknown(EmptyObject)                        | UnknownNotNull(EmptyTuple)     | should not  |                         |
      | Unknown(Object({"a":S}))                    | UnknownNotNull(Tuple([S]))     | should not  |                         |
      | Obj({"hello":"world" (mark "a")})           | Tuple(["world" (mark "a")])    | should not  |                         |
      | Obj({"hello":"world"}) (mark "a")           | Tuple(["world"]) (mark "a")    | should not  |                         |
      | Obj({"hello":"world" (mark "a")}) (mark "a")| Tuple(["world" (mark "a")]) (mark "a") | should not  |                         |

  Scenario Outline: Create a map or object from keys and values lists/tuples (zipmap)
    Given a keys list <keysList>
    And a values list/tuple <valuesCollection>
    When I create a map/object from these keys and values
    Then the result should be <expectedMapOrObject>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples: List of Values (Map Result)
      | keysList                          | valuesCollection                  | expectedMapOrObject             | shouldError | errorMessage |
      | EmptyList(S)                      | EmptyList(S)                      | EmptyMap(S)                     | should not  |              |
      | ["bleep"]                         | ["bloop"]                         | {"bleep":"bloop"}               | should not  |              |
      | ["bleep","beep"]                  | ["bloop","boop"]                  | {"beep":"boop","bleep":"bloop"} | should not  |              |
      | Unknown(List(S))                  | Unknown(List(S))                  | UnknownNotNull(Map(S))          | should not  |              |
      | Unknown(List(S))                  | EmptyList(S)                      | UnknownNotNull(Map(S))          | should not  |              |
      | EmptyList(S)                      | Unknown(List(S))                  | UnknownNotNull(Map(S))          | should not  |              |
      | ["bleep"] (m "a")                 | ["bloop"]                         | {"bleep":"bloop"} (m "a")       | should not  |              |
      | ["bleep"]                         | ["bloop"] (m "b")                 | {"bleep":"bloop"} (m "b")       | should not  |              |
      | ["bleep"] (m "a")                 | ["bloop"] (m "b")                 | {"bleep":"bloop"} (m "a","b")   | should not  |              |
      | ["bleep" (m "a")]                 | ["bloop"]                         | {"bleep":"bloop"} (m "a")       | should not  |              | # Key marks aggregate
      | ["bleep"]                         | ["bloop" (m "a")]                 | {"bleep":"bloop" (m "a")}       | should not  |              | # Value marks preserved
      | ["boop"]                          | EmptyList(S)                      |                                 | should      | "number of keys (1) does not match number of values (0)" |
      | EmptyList(S)                      | ["boop"]                          |                                 | should      | "number of keys (0) does not match number of values (1)" |

    Examples: Tuple of Values (Object Result)
      | keysList                          | valuesCollection                | expectedMapOrObject             | shouldError | errorMessage |
      | EmptyList(S)                      | EmptyTuple                      | EmptyObject                     | should not  |              |
      | ["bleep"]                         | Tuple(["bloop"])                | Obj({"bleep":"bloop"})          | should not  |              |
      | ["bleep","beep"]                  | Tuple(["bloop","boop"])         | Obj({"beep":"boop","bleep":"bloop"})| should not  |              |
      | Unknown(List(S))                  | Unknown(EmptyTuple)             | Dynamic                         | should not  |              |
      | Unknown(List(S))                  | EmptyTuple                      | Dynamic                         | should not  |              |
      | EmptyList(S)                      | Unknown(EmptyTuple)             | UnknownNotNull(EmptyObject)     | should not  |              |
      | ["bleep"] (m "a")                 | Tuple(["bloop"])                | Obj({"bleep":"bloop"}) (m "a")  | should not  |              |
      | ["bleep"]                         | Tuple(["bloop"]) (m "b")        | Obj({"bleep":"bloop"}) (m "b")  | should not  |              |
      | ["bleep"] (m "a")                 | Tuple(["bloop"]) (m "b")        | Obj({"bleep":"bloop"}) (m "a","b")| should not  |              |
      | ["bleep" (m "a")]                 | Tuple(["bloop"])                | Obj({"bleep":"bloop"}) (m "a")  | should not  |              | # Key marks aggregate
      | ["bleep"]                         | Tuple(["bloop" (m "a")])        | Obj({"bleep":"bloop" (m "a")})  | should not  |              | # Value marks preserved
      | ["boop"]                          | EmptyTuple                      |                                 | should      | "number of keys (1) does not match number of values (0)" |
      | EmptyList(S)                      | Tuple(["boop"])                 |                                 | should      | "number of keys (0) does not match number of values (1)" |

  Scenario Outline: Get keys from a map or object
    Given a collection <collection>
    When I get the keys from the collection
    Then the result should be <expectedKeys>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples:
      | collection                                  | expectedKeys                 | shouldError | errorMessage            |
      | EmptyMap(String)                            | EmptyList(String)            | should not  |                         |
      | EmptyMap(String) (mark "a")                 | EmptyList(String) (mark "a") | should not  |                         |
      | Null(Map(String))                           |                              | should      | "argument must not be null" |
      | {"hello":"world"}                           | ["hello"]                    | should not  |                         |
      | {"hello":"world" (mark "a")}                | ["hello"]                    | should not  |                         | # Marks on values ignored
      | {"hello":"world"} (mark "a")                | ["hello"] (mark "a")         | should not  |                         |
      | {"hello":"world" (mark "a")} (mark "a")     | ["hello"] (mark "a")         | should not  |                         |
      | Obj({"hello":"world"})                      | Tuple(["hello"])             | should not  |                         |
      | EmptyObject                                 | EmptyTuple                   | should not  |                         |
      | EmptyObject (mark "a")                      | EmptyTuple (mark "a")        | should not  |                         |
      | Null(EmptyObject)                           |                              | should      | "argument must not be null" |
      | Unknown(EmptyObject)                        | EmptyTuple                   | should not  |                         | # Keys are known
      | Unknown(Object({"a":S}))                    | Tuple(["a"])                 | should not  |                         | # Keys are known
      | Obj({"hello":"world" (mark "a")})           | Tuple(["hello"])             | should not  |                         |
      | Obj({"hello":"world"}) (mark "a")           | Tuple(["hello"]) (mark "a")  | should not  |                         |
      | Obj({"hello":"world" (mark "a")}) (mark "a")| Tuple(["hello"]) (mark "a")  | should not  |                         |

  Scenario Outline: Flatten a list of lists/tuples
    Given a list or tuple <listValue>
    When I flatten the list/tuple
    Then the result should be <expectedFlattenedList>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples:
      | listValue                                                                 | expectedFlattenedList                                      | shouldError | errorMessage |
      | EmptyList(S)                                                              | EmptyTuple                                                 | should not  |              |
      | [[Unknown(S),"a"], [Unknown(S),"b",Unknown(S)]]                           | Tuple([Unknown(S),"a",Unknown(S),"b",Unknown(S)])          | should not  |              |
      | Unknown(List(List(S)))                                                    | Unknown(Dynamic)                                           | should not  |              |
      | EmptyMap(S)                                                               |                                                            | should      | "can only flatten lists, sets and tuples" |
      | [["a"],["b","c"],[]] (m "mark")                                           | Tuple(["a","b","c"]) (m "mark")                            | should not  |              |
      | [["a"](m "f"),["b","c"](m "s"),[](m "t")]                                 | Tuple(["a","b","c"]) (m "f","s","t")                       | should not  |              |
      | [["a"(m "a")],["b"(m "b"),"c"(m "b")]]                                    | Tuple(["a"(m "a"),"b"(m "b"),"c"(m "b")])                  | should not  |              |
      | [["a"](m "f"),Unknown(List(S))(m "s"),["c"](m "t")]                       | Unknown(Dynamic) (m "f","s","t")                           | should not  |              |
      | EmptyList(S) (m "a")                                                      | EmptyTuple (m "a")                                         | should not  |              |
      | EmptyList(N)                                                              | EmptyTuple                                                 | should not  |              |
      | [Dynamic]                                                                 | Dynamic                                                    | should not  |              |
      | Tuple([[Dynamic]], [Dynamic(m "marked")]])                               | Dynamic (m "marked")                                       | should not  |              | # The inner list was [[Dynamic]](m "marked")
      | Tuple([Obj({"blop":[Dynamic]})], [Obj({"bloop":Dynamic})])                 | Tuple([Obj({"blop":[Dynamic]}), Obj({"bloop":Dynamic})])    | should not  |              |
      | [ [Obj({"bloop":Dynamic})], [Obj({"bloop":Dynamic})] ]                     | Tuple([Obj({"bloop":Dynamic}), Obj({"bloop":Dynamic})])    | should not  |              |
      | Tuple(["a",["b"],Tuple([["c"],["d","e"]])])                               | Tuple(["a","b","c","d","e"])                               | should not  |              |
      | Tuple([Tuple(["a","b"]),Null(Dyn),Tuple(["c"])])                           | Tuple(["a","b",Null(Dyn),"c"])                             | should not  |              |
      | Tuple([Tuple(["a","b"]),Dynamic,Tuple(["c"])])                            | Unknown(Dynamic)                                           | should not  |              |
      | Tuple([Null(Dyn), True])                                                  | Tuple([Null(Dyn), True])                                   | should not  |              |
      | Tuple([Null(S), True])                                                    | Tuple([Null(S), True])                                     | should not  |              |
      | Tuple([Null(List(S)), True])                                              | Tuple([Null(List(S)), True])                               | should not  |              |
      | Tuple([Null(EmptyTuple), True])                                           | Tuple([Null(EmptyTuple), True])                            | should not  |              |
      | Tuple([Tuple([Null(Dyn)]) , True])                                        | Tuple([Null(Dyn), True])                                   | should not  |              |
      | Tuple([Tuple([Null(S)]) , True])                                          | Tuple([Null(S), True])                                     | should not  |              |
      | Tuple([Tuple([Null(List(S))]) , True])                                    | Tuple([Null(List(S)), True])                               | should not  |              |
      | Tuple([Tuple([Null(EmptyTuple)]) , True])                                 | Tuple([Null(EmptyTuple), True])                            | should not  |              |

  Scenario Outline: Create Cartesian product of sets/lists (setproduct)
    Given a list of collections <collections>
    When I compute the Cartesian product
    Then the result should be <expectedProduct>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples:
      | collections                                                                | expectedProduct                                                              | shouldError | errorMessage |
      | [EmptyList(S)]                                                             |                                                                              | should      | "at least two arguments are required" |
      | [EmptyList(Obj), ["quick","fox"]]                                          | EmptyList(Tuple([Obj,S]))                                                    | should not  |              |
      | [EmptySet(Obj), Set(["quick","fox"])]                                      | EmptySet(Tuple([Obj,S]))                                                     | should not  |              |
      | [EmptyList(Obj), EmptyList(Obj)]                                           | EmptyList(Tuple([Obj,Obj]))                                                  | should not  |              |
      | [EmptySet(Obj), EmptySet(Obj)]                                             | EmptySet(Tuple([Obj,Obj]))                                                   | should not  |              |
      | [[EmptyList(S)], [EmptyList(S)]]                                           | [Tuple([EmptyList(S),EmptyList(S)])]                                         | should not  |              |
      | [Set([EmptyList(S)]), Set([EmptyList(S)])]                                 | Set([Tuple([EmptyList(S),EmptyList(S)])])                                    | should not  |              |
      | [Set([EmptyList(S)(m "a")]), Set([EmptyList(S)])]                           | Set([Tuple([EmptyList(S)(m "a"),EmptyList(S)])])                             | should not  |              |
      | [Tuple(["the","brown"]), Tuple(["fox",3])]                                 | [Tuple(["the","fox"]),Tuple(["the","3"]),Tuple(["brown","fox"]),Tuple(["brown","3"])] | should not  |              |
      | [Set(["the","brown"]), Set(["quick","fox"])]                               | Set([Tuple(["t","q"]),Tuple(["t","f"]),Tuple(["b","q"]),Tuple(["b","f"])])    | should not  |              | # Order in set is arbitrary
      | [Set(["the","brown"(m "a")]), Set(["quick","fox"(m "b")])]                  | Set([Tuple(["t","q"]),Tuple(["t","f"]),Tuple(["b","q"]),Tuple(["b","f"])]) (m "a","b") | should not  |              |
      | [Set(["the","brown"])(m "a"), Set(["quick","fox"])(m "b")]                  | Set([Tuple(["t","q"]),Tuple(["t","f"]),Tuple(["b","q"]),Tuple(["b","f"])]) (m "a","b") | should not  |              |
      | [Set(["the","brown"])(m "a"), Set(["quick","fox"])]                         | Set([Tuple(["t","q"]),Tuple(["t","f"]),Tuple(["b","q"]),Tuple(["b","f"])]) (m "a")    | should not  |              |
      | [Set(["the","brown"(m "a")])(m "b"), Set(["quick","fox"(m "c")])]           | Set([Tuple(["t","q"]),Tuple(["t","f"]),Tuple(["b","q"]),Tuple(["b","f"])]) (m "b","c","a") | should not  |              |
      | [["the","brown"(m "a")], ["quick","fox"(m "b")]]                           | [Tuple(["t","q"]),Tuple(["t","f"(m "b")]),Tuple(["b"(m "a"),"q"]),Tuple(["b"(m "a"),"f"(m "b")])] | should not  |              |
      | [["the","brown"](m "a"), ["quick","fox"](m "b")]                           | [Tuple(["t","q"]),Tuple(["t","f"]),Tuple(["b","q"]),Tuple(["b","f"])](m "a","b") | should not  |              |
      | [["the","brown"](m "a"), ["quick","fox"]]                                  | [Tuple(["t","q"]),Tuple(["t","f"]),Tuple(["b","q"]),Tuple(["b","f"])](m "a")    | should not  |              |
      | [["the","brown"(m "a")](m "b"), ["quick","fox"(m "c")]]                     | [Tuple(["t","q"]),Tuple(["t","f"(m "c")]),Tuple(["b"(m "a"),"q"]),Tuple(["b"(m "a"),"f"(m "c")])](m "b") | should not  |              |
      | [EmptyList(S)(m "a"), EmptyList(B)(m "b")]                                 | EmptyList(Tuple([S,B])) (m "a","b")                                          | should not  |              |
      | [EmptySet(S)(m "a"), EmptySet(B)(m "b")]                                   | EmptySet(Tuple([S,B])) (m "a","b")                                           | should not  |              |
      | [Set(["x",Unknown(S)])(m "a"), Set([True,False])(m "b")]                   | UnknownNotNull(Set(Tuple([S,B]))) (m "a","b")                                 | should not  |              |
      | [Set([True]), Dynamic]                                                     | Dynamic                                                                      | should not  |              |
      | [Unknown(Set(S)) refined maxLen 2, Unknown(Set(N)) refined maxLen 3]       | UnknownNotNull(Set(Tuple([S,N]))) refined len 1-6                             | should not  |              |
      | [Unknown(Set(S)) refined maxLen 2, EmptySet(N)]                            | EmptySet(Tuple([S,N]))                                                       | should not  |              |
      | [Unknown(Set(S)) refined maxLen 2, Unknown(Set(N)) refined maxLen 4096]    | UnknownNotNull(Set(Tuple([S,N])))                                            | should not  |              | # Large max len, unrefined length
      | [Unknown(List(S)) refined maxLen 2, Unknown(List(N)) refined maxLen 3]     | UnknownNotNull(List(Tuple([S,N]))) refined len 1-6                            | should not  |              |
      | [Unknown(List(S)) refined maxLen 2, EmptyList(N)]                          | EmptyList(Tuple([S,N]))                                                      | should not  |              |
      | [Unknown(Tuple([S,S])), Unknown(Tuple([N,N,N]))]                           | UnknownNotNull(List(Tuple([S,N]))) refined len 1-6                            | should not  |              |
      | [Unknown(Tuple([S,S])), EmptyTuple]                                        | EmptyList(Tuple([S,Dyn]))                                                    | should not  |              |

  Scenario Outline: Reverse a list, tuple, or set (converted to list)
    Given a collection <collection>
    When I reverse the collection
    Then the result should be <reversedCollection>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples:
      | collection                                | reversedCollection                         | shouldError | errorMessage            |
      | NullValue                                 |                                            | should      | "argument must not be null" |
      | EmptyList(S)                              | EmptyList(S)                               | should not  |                         |
      | EmptyList(S) (m "foo")                    | EmptyList(S) (m "foo")                     | should not  |                         |
      | Unknown(List(S))                          | UnknownNotNull(List(S))                    | should not  |                         |
      | ["beep"(m "boop"),"bop","bloop"]           | ["bloop","bop","beep"(m "boop")]           | should not  |                         |
      | ["beep"(m "boop"),"bop","bloop"] (m "outer")| ["bloop","bop","beep"(m "boop")] (m "outer")| should not  |                         |
      | Tuple(["beep"(m "boop"),"bop","bloop"])   | Tuple(["bloop","bop","beep"(m "boop")])    | should not  |                         |
      | Set(["beep"(m "boop"),"bop","bloop"])     | ["bop","bloop","beep"] (m "boop")          | should not  |                         | # Set to list, sorted, then reversed. Marks aggregate.

  Scenario Outline: Slice a list
    Given a list <listValue>
    And a start index <startIndex>
    And an end index <endIndex>
    When I slice the list
    Then the result should be <expectedSlice>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples:
      | listValue                          | startIndex | endIndex | expectedSlice                | shouldError | errorMessage |
      | ["a","b","c"]                      | 0          | 2        | ["a","b"]                    | should not  |              |
      | ["a","b","c"] (m "bloop")          | 0          | 2        | ["a","b"] (m "bloop")        | should not  |              |
      | ["a","b"(m "bloop"),"c"]           | 0          | 2        | ["a","b"(m "bloop")]         | should not  |              |

  Scenario Outline: Get distinct elements from a list
    Given a list <listValue>
    When I get the distinct elements from the list
    Then the result should be <expectedDistinctList>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples:
      | listValue                                | expectedDistinctList                 | shouldError | errorMessage            |
      | EmptyList(S)                             | EmptyList(S)                         | should not  |                         |
      | EmptyList(N)                             | EmptyList(N)                         | should not  |                         |
      | EmptyList(Dyn)                           | EmptyList(Dyn)                       | should not  |                         |
      | ["single"]                               | ["single"]                           | should not  |                         |
      | [42,42,42]                               | [42]                                 | should not  |                         |
      | ["a","b","c"]                            | ["a","b","c"]                        | should not  |                         |
      | [["a","a"],["b"],["a","a"]]              | [["a","a"],["b"]]                    | should not  |                         |
      | Unknown(List(S))                         | UnknownNotNull(List(S))              | should not  |                         |
      | [Unknown(S),"a","b",Unknown(S)]          | UnknownNotNull(List(S))              | should not  |                         |
      | Null(List(S))                            |                                      | should      | "argument must not be null" |
      | [Null(S),"a",Null(S),"b"]                | [Null(S),"a","b"]                    | should not  |                         |
