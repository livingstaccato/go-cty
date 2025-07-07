# Original Go Test File: cty/convert/compare_types_test.go
# This feature file covers the test cases found in cty/convert/compare_types_test.go.

Feature: Type Comparison for Conversion
  This feature describes how different cty types are compared,
  which likely influences type conversion behavior or unification order.
  The comparison returns -1 if Type A precedes Type B, 1 if Type B precedes Type A,
  and 0 if they are considered equivalent or have no defined precedence for conversion.

  Background:
    Given the cty type comparison function

  Scenario Outline: Comparing two cty types
    # Covers test: TestCompareTypes
    When type <TypeA> is compared with type <TypeB>
    Then the comparison result should be <ExpectedResult>

    Examples: Primitives
      | TypeA        | TypeB        | ExpectedResult | Description                               |
      | String       | String       | 0              | String is equal to String                 |
      | String       | Number       | -1             | String precedes Number                    |
      | Number       | String       | 1              | Number follows String                     |
      | String       | Bool         | -1             | String precedes Bool                      |
      | Bool         | String       | 1              | Bool follows String                       |
      | Bool         | Number       | 0              | Bool and Number are neutral               |
      | Number       | Bool         | 0              | Number and Bool are neutral               |

    Examples: Lists
      | TypeA        | TypeB        | ExpectedResult | Description                               |
      | List(String) | List(String) | 0              | List of String equals List of String      |
      | List(String) | List(Number) | -1             | List of String precedes List of Number    |
      | List(Number) | List(String) | 1              | List of Number follows List of String     |
      | List(String) | String       | 0              | List of String is neutral to String       |

    Examples: Sets
      | TypeA      | TypeB      | ExpectedResult | Description                             |
      | Set(String)| Set(String)| 0              | Set of String equals Set of String        |
      | Set(String)| Set(Number)| -1             | Set of String precedes Set of Number      |
      | Set(Number)| Set(String)| 1              | Set of Number follows Set of String       |
      | Set(String)| String     | 0              | Set of String is neutral to String        |

    Examples: Maps
      | TypeA      | TypeB      | ExpectedResult | Description                             |
      | Map(String)| Map(String)| 0              | Map of String equals Map of String        |
      | Map(String)| Map(Number)| -1             | Map of String precedes Map of Number      |
      | Map(Number)| Map(String)| 1              | Map of Number follows Map of String       |
      | Map(String)| String     | 0              | Map of String is neutral to String        |

    Examples: Objects
      | TypeA                                  | TypeB                                  | ExpectedResult | Description                                                          |
      | EmptyObject                            | EmptyObject                            | 0              | EmptyObject equals EmptyObject                                       |
      | EmptyObject                            | Object({"name":String})                | 0              | EmptyObject is neutral to Object with attribute                      |
      | Object({"name":String})                | Object({"name":String})                | 0              | Identical Objects are equal                                          |
      | Object({"name":String,"number":Number})| Object({"name":String})                | 0              | Object with more attrs is neutral to subset                          |
      | Object({"number":Number})              | Object({"name":String})                | 0              | Objects with different attrs are neutral                             |
      | Object({"name":String,"number":String})| Object({"name":String,"number":Number})| -1             | Object attr type String precedes Number                              |
      | Object({"name":String,"number":Number})| Object({"name":String,"number":String})| 1              | Object attr type Number follows String                               |
      | Object({"a":String,"b":Number})        | Object({"a":Number,"b":String})        | 0              | Neutral; potential common base type with String attributes exists  |

    Examples: Tuples
      | TypeA                               | TypeB                               | ExpectedResult | Description                                                            |
      | EmptyTuple                          | EmptyTuple                          | 0              | EmptyTuple equals EmptyTuple                                           |
      | EmptyTuple                          | Tuple([String])                     | 0              | EmptyTuple is neutral to Tuple with element                            |
      | Tuple([String])                     | Tuple([String])                     | 0              | Identical Tuples are equal                                             |
      | Tuple([String,Number])              | Tuple([String])                     | 0              | Tuple with more elements is neutral to subset                          |
      | Tuple([String,String])              | Tuple([String,Number])              | -1             | Tuple element type String precedes Number                              |
      | Tuple([String,Number])              | Tuple([String,String])              | 1              | Tuple element type Number follows String                               |
      | Tuple([String,Number])              | Tuple([Number,String])              | 0              | Neutral; potential common base type with String elements exists    |

    Examples: Lists and Sets
      | TypeA        | TypeB        | ExpectedResult | Description                               |
      | Set(String)  | List(String) | 1              | Set follows List of same type             |
      | List(String) | Set(String)  | -1             | List precedes Set of same type            |
      | List(String) | Set(Number)  | -1             | List(String) precedes Set(Number)         |
      | Set(Number)  | List(String) | 1              | Set(Number) follows List(String)          |

    Examples: DynamicType
      | TypeA       | TypeB       | ExpectedResult | Description                               |
      | DynamicType | DynamicType | 0              | DynamicType equals DynamicType            |
      | DynamicType | String      | 1              | DynamicType follows String                |
      | String      | DynamicType | -1             | String precedes DynamicType               |
      | Number      | DynamicType | -1             | Number precedes DynamicType               |
      | DynamicType | Number      | 1              | DynamicType follows Number                |
      | Bool        | DynamicType | -1             | Bool precedes DynamicType                 |
      | DynamicType | Bool        | 1              | DynamicType follows Bool                  |
