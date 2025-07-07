# Original Go Test File: cty/function/stdlib/collection_test.go
# This feature file covers tests for collection manipulation functions in the cty standard library.

Feature: Standard Library Collection Functions
  This feature describes the behavior of functions that operate on
  cty collection types like lists, sets, maps, and tuples.

  Scenario Outline: Checking if a collection has an index/key (HasIndex)
    # Covers test: TestHasIndex
    Given a cty collection <Collection> of type <CollectionType>
    And a cty key <Key> of type <KeyType>
    When the HasIndex function is called with the collection and key
    Then the result should be the cty Bool <ExpectedResult>
    And if <ExpectedResult> is Unknown(Bool), it should be refined as not null

    Examples:
      | Collection                      | CollectionType | Key          | KeyType | ExpectedResult |
      | EmptyList(Number)               | List(Number)   | Number(2)    | Number  | False          |
      | List(True)                      | List(Bool)     | Number(0)    | Number  | True           |
      | List(True)                      | List(Bool)     | String("h")  | String  | False          |
      | EmptyMap(Bool)                  | Map(Bool)      | String("h")  | String  | False          |
      | Map("hello"=True)               | Map(Bool)      | String("h")  | String  | True           |
      | EmptyTuple                      | EmptyTuple     | String("h")  | String  | False          |
      | EmptyTuple                      | EmptyTuple     | Number(0)    | Number  | False          |
      | Tuple(True)                     | Tuple(Bool)    | Number(0)    | Number  | True           |
      | EmptyList(Number)               | List(Number)   | Unknown(Num) | Number  | Unknown(Bool)  |
      | Unknown(List(Bool))             | List(Bool)     | Unknown(Num) | Number  | Unknown(Bool)  |
      | EmptyList(Number)               | List(Number)   | Dynamic      | Dynamic | Unknown(Bool)  |
      | Dynamic                         | DynamicType    | Dynamic      | Dynamic | Unknown(Bool)  |

  Scenario Outline: Chunking a list (Chunklist)
    # Covers test: TestChunklist
    Given a cty list <ListValue> of element type <ElementType>
    And a cty number <ChunkSize> for the chunk length
    When the Chunklist function is called with the list and chunk size
    Then the result should be <ExpectedListOrError>
    And the error message, if any, should be "<ExpectedErrorMessage>"

    Examples:
      | ListValue                     | ElementType | ChunkSize        | ExpectedListOrError                                     | ExpectedErrorMessage |
      | EmptyList                     | String      | Number(2)        | EmptyList(List(String))                                 |                      |
      | UnknownList                   | String      | Number(2)        | Unknown(List(List(String))).RefineNotNull()             |                      |
      | List("a")                     | String      | Number(2)        | List(List("a"))                                         |                      |
      | List("a".Mark(m))             | String      | Number(2)        | List(List("a".Mark(m)))                                 |                      |
      | List("a").Mark(m)             | String      | Number(2)        | List(List("a")).Mark(m)                                 |                      |
      | List(Unknown(String))         | String      | Number(2)        | List(List(Unknown(String)))                             |                      |
      | List("a", "b", "c")           | String      | Number(2)        | List(List("a","b"), List("c"))                          |                      |
      | List("a")                     | String      | Number(0)        | List(List("a"))                                         | # Zero size means infinite |
      | Unknown(List(S))              | String      | Number(2)        | Unknown(List(List(String))).RefineNotNull()             |                      |
      | List("a","b","c","d")         | String      | Unknown(Number)  | Unknown(List(List(String))).RefineNotNull()             |                      |
      | EmptyList                     | String      | Number(2)        | EmptyList(List(String))                                 |                      |
      | EmptyList                     | String      | Number(-1)       |                                                         | "the size argument must be positive" |
      | EmptyList                     | String      | PositiveInfinity |                                                         | "invalid size: value must be a whole number..." |
      | EmptyList                     | String      | Number(1.5)      |                                                         | "invalid size: value must be a whole number..." |

  Scenario Outline: Checking if a collection contains a value (Contains)
    # Covers test: TestContains
    Given a cty collection <Collection>
    And a cty value <ValueToFind>
    When the Contains function is called with the collection and value
    Then the result should be the cty Bool <ExpectedResult>
    And if <ExpectedResult> is Unknown(Bool), it should be refined as not null

    Examples:
      | Collection                          | ValueToFind    | ExpectedResult |
      | List("the", "quick", "brown", "fox")| String("the")  | True           |
      | List("the", "quick", "brown", Unknown(String)) | String("the")  | True           |
      | List("the", "quick", "brown", Unknown(String)) | String("orange")| Unknown(Bool)  |
      | List(1, 2, 3, 4)                    | Number(1)      | True           |
      | List(1, 2, 3, 4)                    | String("1")    | False          | # Type mismatch
      | Set("quick", "brown", "fox")        | String("quick")| True           |
      | Set(Unknown(String), "brown", "fox")| String("quick")| Unknown(Bool)  |
      | Unknown(List(String))               | String("any")  | Unknown(Bool)  |
      | List("a", "b")                      | Unknown(String)| Unknown(Bool)  |
      | Unknown(Set(String))                | Dynamic        | Unknown(Bool)  |
      | Tuple("quick", "brown", Number(3))  | Number(3)      | True           |

  Scenario Outline: Merging maps/objects (Merge)
    # Covers test: TestMerge
    Given a list of cty maps/objects <MapsToMerge>
    When the Merge function is called with these maps/objects
    Then the result should be <ExpectedMapOrObject>
    And the error message, if any, should be "<ExpectedErrorMessage>"

    Examples:
      | MapsToMerge                                     | ExpectedMapOrObject                         | ExpectedErrorMessage |
      | [Map(a="b"), Map(c="d")]                        | Map(a="b", c="d")                           |                      |
      | [Map(a=Unknown(S)), Map(c="d")]                 | Map(a=Unknown(S), c="d")                    |                      |
      | [Null(Map(S)), Map(c="d")]                      | Map(c="d")                                  |                      |
      | [Null(Map(S)), Null(Obj(a=List(S)))]            | EmptyObject                                 |                      |
      | [Unknown(Map(S)), Map(c="d")]                   | Unknown(Map(S)).RefineNotNull()             |                      |
      | [Dynamic, Map(c="d")]                           | Dynamic                                     |                      |
      | [Unknown(Object(a=S)), Obj(b="B")]              | Unknown(Object(a=S,b=S)).RefineNotNull()    |                      |
      | [Map(a="A"), Unknown(Map(S))]                   | Unknown(Map(S)).RefineNotNull()             |                      |
      | [Map(a="b",c="d"), Map(a="x")]                  | Map(a="x", c="d")                           | # Last-in wins       |
      | [Map(a="b"), List("a","x")]                     |                                             | "argument 2 is list of string, not map" |
      | [Map(a=List("b","c")), Map(d=Map(e="f"))]       | Obj(a=List("b","c"), d=Map(e="f"))          |                      |
      | [Map(a="a".M(f)), Map(a="A",b="B".M(s)), EmptyMap(S).M(t)] | Map(a="A",b="B".M(s)).WithMarks(f,s,t) |                      |

  Scenario Outline: Accessing element by index/key (Index)
    # Covers test: TestIndex
    Given a cty collection <Collection>
    And a cty key <Key>
    When the Index function is called with the collection and key
    Then the result should be <ExpectedValue>
    And an error should <ErrorOccur>

    Examples: Successful Access
      | Collection        | Key           | ExpectedValue   | ErrorOccur |
      | List(True)        | Number(0)     | True            | not occur  |
      | Map("h"=True)     | String("h")   | True            | not occur  |
      | Tuple(True, "s")  | Number(1)     | String("s")     | not occur  |
      | EmptyList(Number) | Unknown(Num)  | Unknown(Number) | not occur  |
      | Dynamic           | String("h")   | Dynamic         | not occur  |

    Examples: Access Errors
      | Collection        | Key           | ExpectedValue   | ErrorOccur | # ExpectedErrorMessage in practice
      | List(True)        | Number(1)     |                 | occur      | # Index out of bounds
      | Map("h"=True)     | String("x")   |                 | occur      | # Key not found
      | List(True)        | String("x")   |                 | occur      | # Invalid key type for list

  Scenario Outline: Getting collection length (Length)
    # Covers test: TestLength
    Given a cty collection <Collection>
    When the Length function is called with the collection
    Then the result should be <ExpectedLength>

    Examples:
      | Collection                           | ExpectedLength                                |
      | EmptyList(Number)                    | Number(0)                                     |
      | List(True)                           | Number(1)                                     |
      | Set(True, Unknown(Bool))             | Unknown(Number).RefineNotNull().Range(1,2)    |
      | Set(Unknown(Bool))                   | Number(1)                                     |
      | Map("h"=True)                        | Number(1)                                     |
      | EmptyTuple                           | Number(0)                                     |
      | Unknown(List(Bool))                  | Unknown(Number).RefineNotNull().MinLength(0)  |
      | Unknown(List(Bool)).RefineMaxLength(2) | Unknown(Number).RefineNotNull().Range(0,2)    |
      | List("h","w").Mark(m)                | Number(2).Mark(m)                             |

  Scenario Outline: Looking up a key in a map with a default (Lookup)
    # Covers test: TestLookup
    Given a cty map <Map>
    And a cty key <Key>
    And a cty default value <Default>
    When the Lookup function is called with the map, key, and default
    Then the result should be <ExpectedValue>

    Examples:
      | Map                               | Key          | Default        | ExpectedValue                     |
      | EmptyMap(String)                  | String("baz")| String("foo")  | String("foo")                     |
      | Map(foo="bar")                    | String("foo")| String("nope") | String("bar")                     |
      | Map(b="B").Mark(a)                | String("b")  | String("N")    | String("B").Mark(a)               |
      | Map(b="B",f=Unk(S)).Mark(a)       | String("b")  | String("N")    | Unknown(String).Mark(a)           | # Should be String("B").Mark(a) if 'f' is not chosen for key "b"
      | Map(b="B").Mark(a)                | String("f")  | String("N").Mark(b)| String("N").WithMarks(a,b)      |
      | Map(b="B".M(a),f="H".M(b))        | String("f")  | String("N").Mark(c)| String("H").Mark(b)             |
      | Map(b="B".M(a),f="H".M(b))        | String("s")  | String("N").Mark(c)| String("N").Mark(c)             |
      | Map(b="B".M(a),f="H".M(b))        | String("s")  | Number(5).Mark(c)| String("5").Mark(c)             |
      | Map(b="B",f="H")                  | String("b").Mark(a)| String("N") | String("B").Mark(a)             |

    Examples: Unknown Inputs and Incompatible Default
      | Map                               | Key             | Default        | ExpectedValue                     |
      | Unknown(Map(String))              | String("k")     | String("def")  | Unknown(String).RefineNotNull()   |
      | Map(k="v")                        | Unknown(String) | String("def")  | Unknown(String).RefineNotNull()   |
      | Map(k="v")                        | String("x")     | Unknown(String)| Unknown(String).RefineNotNull()   |
      | Map(k=String("v"))                | String("x")     | Number(1)      | String("1")                       | # Default converted
      | Map(k=String("v"))                | String("x")     | List(S("a"))   | # Error: default not convertible  | # This should ideally error, needs specific error message

  Scenario Outline: Accessing element by list/tuple index with wrapping (Element)
    # Covers test: TestElement
    Given a cty list or tuple <ListOrTuple>
    And a cty number index <Index>
    When the Element function is called with the list/tuple and index
    Then the result should be <ExpectedElement>
    And an error should <ErrorOccur>

    Examples:
      | ListOrTuple                       | Index        | ExpectedElement   | ErrorOccur |
      | List("t","q","b","f")             | Number(2)    | String("b")       | not occur  |
      | List("t","q","b","f")             | Number(5)    | String("q")       | not occur  | # Wraps: 5 % 4 = 1
      | List("t","q","b","f")             | Number(-1)   | String("f")       | not occur  | # Wraps: -1 % 4 = 3
      | List("t","q","b".Mark(m),"f")     | Number(2)    | String("b").Mark(m)| not occur  |
      | List("t","q","b","f").Mark(l)     | Number(2)    | String("b").Mark(l)| not occur  |
      | List("t","q","b","f")             | String("b")  |                   | occur      | # Invalid index type
      | Tuple("t",Unknown(S),"b",False)   | Number(1)    | Unknown(String)   | not occur  |
      | Unknown(Tuple(S,S,S,B))           | Number(3)    | Unknown(Bool)     | not occur  |

  Scenario Outline: Coalescing a list of lists/tuples (CoalesceList)
    # Covers test: TestCoalesceList
    Given a list of cty lists/tuples <Lists>
    When the CoalesceList function is called with these lists/tuples
    Then the result should be <ExpectedListOrTuple>
    And an error should <ErrorOccur>

    Examples:
      | Lists                                      | ExpectedListOrTuple    | ErrorOccur |
      | [List("a","b"), List("c","d")]             | List("a","b")          | not occur  |
      | [EmptyList(S), List("c","d")]              | List("c","d")          | not occur  |
      | [EmptyList(S), List(Number(3),Number(4))]  | List(Number(3),Number(4))| not occur  | # Type is of first non-empty
      | [EmptyTuple, Tuple("c","d")]               | Tuple("c","d")         | not occur  |
      | [Unknown(List(S)), List("c","d")]          | Dynamic                | not occur  |
      | [Null(List(S)), List("c","d")]             | List("c","d")          | not occur  |
      | [Null(List(S)), Null(List(S))]             |                        | occur      | # All null
      | [Map(a=T), Obj(b=F)]                       |                        | occur      | # Invalid arg types
      | []                                         |                        | occur      | # No args

  Scenario Outline: Getting map/object values (Values)
    # Covers test: TestValues
    Given a cty map or object <Collection>
    When the Values function is called
    Then the result should be <ExpectedValuesListOrTuple>
    And an error should <ErrorOccur>

    Examples:
      | Collection                   | ExpectedValuesListOrTuple     | ErrorOccur |
      | EmptyMap(String)             | EmptyList(String)             | not occur  |
      | EmptyMap(String).Mark(a)     | EmptyList(String).Mark(a)     | not occur  |
      | Null(Map(String))            |                               | occur      | # Arg must not be null
      | Unknown(Map(String))         | Unknown(List(String)).RefineNotNull() | not occur  |
      | Map(hello="world")           | List("world")                 | not occur  | # Order can vary for map
      | Map(hello="world".Mark(a))   | List("world".Mark(a))         | not occur  |
      | Map(hello="world").Mark(a)   | List("world").Mark(a)         | not occur  |
      | Obj(hello="world")           | Tuple("world")                | not occur  | # Order is defined for object
      | EmptyObject.Mark(a)          | EmptyTuple.Mark(a)            | not occur  |

  Scenario Outline: Creating a map/object from keys and values (Zipmap)
    # Covers test: TestZipMap
    Given a cty list of keys <KeysList>
    And a cty list or tuple of values <ValuesListOrTuple>
    When the Zipmap function is called
    Then the result should be <ExpectedMapOrObject>
    And an error should <ErrorOccur>

    Examples:
      | KeysList                    | ValuesListOrTuple       | ExpectedMapOrObject                | ErrorOccur |
      | EmptyList(String)           | EmptyList(String)       | EmptyMap(String)                   | not occur  |
      | List("k1")                  | List("v1")              | Map(k1="v1")                       | not occur  |
      | List("k1").Mark(a)          | List("v1")              | Map(k1="v1").Mark(a)               | not occur  |
      | List("k1")                  | List("v1").Mark(b)      | Map(k1="v1").Mark(b)               | not occur  |
      | List("k1".Mark(a))          | List("v1")              | Map(k1="v1").Mark(a)               | not occur  | # Key marks go to map
      | List("k1")                  | List("v1".Mark(a))      | Map(k1="v1".Mark(a))               | not occur  | # Value marks stay on value
      | List("k1")                  | EmptyList(String)       |                                    | occur      | # Length mismatch
      | EmptyList(String)           | EmptyTuple              | EmptyObject                        | not occur  |
      | List("k1")                  | Tuple("v1")             | Obj(k1="v1")                       | not occur  |
      | Unknown(List(S))            | Unknown(EmptyTuple)     | Dynamic                            | not occur  |

  Scenario Outline: Getting map/object keys (Keys)
    # Covers test: TestKeys
    Given a cty map or object <Collection>
    When the Keys function is called
    Then the result should be <ExpectedKeysListOrTuple>
    And an error should <ErrorOccur>

    Examples:
      | Collection                   | ExpectedKeysListOrTuple       | ErrorOccur |
      | EmptyMap(String)             | EmptyList(String)             | not occur  |
      | EmptyMap(String).Mark(a)     | EmptyList(String).Mark(a)     | not occur  |
      | Null(Map(String))            |                               | occur      | # Arg must not be null
      | Map(hello="world")           | List("hello")                 | not occur  | # Order can vary for map
      | Map(hello="w".Mark(a)).Mark(b)| List("hello").Mark(b)         | not occur  | # Value marks ignored, map marks kept
      | Obj(hello="world")           | Tuple("hello")                | not occur  | # Order is defined for object
      | Unknown(Obj(a=S))            | Tuple("a")                    | not occur  |

  Scenario Outline: Flattening a list/tuple of lists/tuples (Flatten)
    # Covers test: TestFlatten
    Given a cty list or tuple <ListOrTupleToFlatten>
    When the Flatten function is called
    Then the result should be <ExpectedFlatTuple>
    And an error should <ErrorOccur>

    Examples:
      | ListOrTupleToFlatten                | ExpectedFlatTuple                           | ErrorOccur |
      | EmptyList(String)                   | EmptyTuple                                  | not occur  |
      | List(List(Unk(S),"a"),List(Unk(S),"b",Unk(S))) | Tuple(Unk(S),"a",Unk(S),"b",Unk(S))      | not occur  |
      | Unknown(List(List(S)))              | Unknown(DynamicType)                        | not occur  |
      | EmptyMap(String)                    |                                             | occur      | # Not a list/tuple
      | List(List("a").M(f),List("b","c").M(s),EmptyList(S).M(t)).M(m) | Tuple("a","b","c").WithMarks(f,s,t,m) | not occur  | # Marks propagate
      | Tuple("a",List("b"),Tuple(List("c"),List("d","e"))) | Tuple("a","b","c","d","e")            | not occur  |
      | Tuple(Tuple("a","b"),Null(Dyn),Tuple("c")) | Tuple("a","b",Null(Dyn),"c")            | not occur  |
      | Tuple(Tuple("a","b"),Dynamic,Tuple("c"))| Unknown(DynamicType)                        | not occur  |

  Scenario Outline: Cartesian product of collections (Setproduct)
    # Covers test: TestSetproduct
    Given a list of cty collections <Collections>
    When the Setproduct function is called
    Then the result should be <ExpectedProductSetOrList>
    And an error should <ErrorOccur>

    Examples:
      | Collections                                       | ExpectedProductSetOrList                                  | ErrorOccur |
      | [List()]                                          |                                                           | occur      | # Needs >= 2 args
      | [EmptyList(EmptyObj), List("q","f")]              | EmptyList(Tuple(EmptyObj,String))                         | not occur  |
      | [Set(S("t","b")), Set(S("f","q"))]                 | Set(Tuple(S("t"),S("f")),Tuple(S("t"),S("q")),Tuple(S("b"),S("f")),Tuple(S("b"),S("q")))| not occur  | # Order in result set elems undefined
      | [List(S("t"),S("b").M(a)).M(b), List(S("q"),S("f").M(c))] | List(T(S("t"),S("q")),T(S("t"),S("f").M(c)),T(S("b").M(a),S("q")),T(S("b").M(a),S("f").M(c))).M(b) | not occur  | # List preserves order & element marks
      | [EmptySet(S).M(a), EmptySet(B).M(b)]              | EmptySet(Tuple(S,B)).WithMarks(a,b)                       | not occur  |
      | [Set(S("x"),Unk(S)).M(a), Set(True,False).M(b)]    | Unknown(Set(Tuple(S,B))).RefineNotNull().WithMarks(a,b)   | not occur  |
      | [Set(True), Dynamic]                              | Dynamic                                                   | not occur  |
      | [Unk(Set(S)).RefineMaxLen(2), Unk(Set(N)).RefineMaxLen(3)] | Unk(Set(Tuple(S,N))).RefineNotNull().MinLen(1).MaxLen(6) | not occur  | # Length refinements propagate

  Scenario Outline: Reversing a list/tuple (ReverseList)
    # Covers test: TestReverseList
    Given a cty list, set, or tuple <Collection>
    When the ReverseList function is called
    Then the result should be <ExpectedReversedListOrTuple>
    And an error should <ErrorOccur>

    Examples:
      | Collection                           | ExpectedReversedListOrTuple          | ErrorOccur |
      | NullValue                            |                                      | occur      | # Arg must not be null
      | EmptyList(String)                    | EmptyList(String)                    | not occur  |
      | EmptyList(String).Mark(m)            | EmptyList(String).Mark(m)            | not occur  |
      | Unknown(List(String))                | Unknown(List(String)).RefineNotNull()| not occur  |
      | List("beep".M(b),"bop","bloop")       | List("bloop","bop","beep".M(b))      | not occur  |
      | List("beep".M(b),"bop","bloop").M(o)  | List("bloop","bop","beep".M(b)).M(o) | not occur  |
      | Tuple("beep".M(b),"bop","bloop")      | Tuple("bloop","bop","beep".M(b))     | not occur  |
      | Set("beep".M(b),"bop","bloop")        | List("bop","bloop","beep").M(b)      | not occur  | # Set to list (sorted), then reversed

  Scenario Outline: Slicing a list/tuple (Slice)
    # Covers test: TestSlice
    Given a cty list or tuple <InputCollection>
    And a cty number start index <StartIndex>
    And a cty number end index <EndIndex>
    When the Slice function is called
    Then the result should be <ExpectedSlice>
    And an error should <ErrorOccur>

    Examples:
      | InputCollection                   | StartIndex | EndIndex  | ExpectedSlice                | ErrorOccur |
      | List("a","b","c")                 | Number(0)  | Number(2) | List("a","b")                | not occur  |
      | List("a","b","c").Mark(m)         | Number(0)  | Number(2) | List("a","b").Mark(m)        | not occur  |
      | List("a","b".Mark(m),"c")         | Number(0)  | Number(2) | List("a","b".Mark(m))        | not occur  |
      # More slice examples would go here, covering negative indices, out of bounds, etc.

  Scenario Outline: Getting distinct elements from a list (Distinct)
    # Covers test: TestDistinct
    Given a cty list <InputList>
    When the Distinct function is called
    Then the result should be <ExpectedDistinctList>
    And an error should <ErrorOccur>

    Examples:
      | InputList                             | ExpectedDistinctList                  | ErrorOccur |
      | EmptyList(String)                     | EmptyList(String)                     | not occur  |
      | List("single")                        | List("single")                        | not occur  |
      | List(N(42),N(42),N(42))               | List(N(42))                           | not occur  |
      | List("a","b","c")                     | List("a","b","c")                     | not occur  |
      | List(List("a","a"),List("b"),List("a","a")) | List(List("a","a"),List("b"))     | not occur  |
      | Unknown(List(String))                 | Unknown(List(String)).RefineNotNull() | not occur  |
      | List(Unknown(S),"a","b",Unknown(S))   | Unknown(List(String)).RefineNotNull() | not occur  |
      | Null(List(String))                    |                                       | occur      | # Arg must not be null
      | List(Null(S),"a",Null(S),"b")         | List(Null(S),"a","b")                 | not occur  |

    # Note on Value Syntax:
    # S=String, N=Number, B=Bool, Dyn=DynamicType, Unk=Unknown, Obj=Object, M=Mark
    # List(...), Set(...), Tuple(...), Map(key=val), Obj(key=val), EmptyList(T), etc.
    # .RefineNotNull(), .RefineMinLength(X), .RefineMaxLength(X), .Range(X,Y)
    # .M(mark) is a shorthand for .Mark(mark_value)
    # .WithMarks(m1,m2) means combined marks
    # Some complex values are abbreviated for clarity. True refers to cty.True etc.
    # "Error" in ExpectedListOrError/ExpectedMapOrObject means the function returns an error.
