# Covers tests in cty/convert/compare_types_test.go

Feature: Type Comparison
  Background:
    Given a Go environment

  Scenario Outline: Comparing two types
    Given type A is <typeA>
    And type B is <typeB>
    When I compare type A with type B
    Then the result should be <expectedComparison>

    Examples: Primitives
      | typeA  | typeB  | expectedComparison |
      | String | String | 0                  |
      | String | Number | -1                 |
      | Number | String | 1                  |
      | String | Bool   | -1                 |
      | Bool   | String | 1                  |
      | Bool   | Number | 0                  |
      | Number | Bool   | 0                  |

    Examples: Lists
      | typeA        | typeB        | expectedComparison |
      | List(String) | List(String) | 0                  |
      | List(String) | List(Number) | -1                 |
      | List(Number) | List(String) | 1                  |
      | List(String) | String       | 0                  |

    Examples: Sets
      | typeA       | typeB       | expectedComparison |
      | Set(String) | Set(String) | 0                  |
      | Set(String) | Set(Number) | -1                 |
      | Set(Number) | Set(String) | 1                  |
      | Set(String) | String      | 0                  |

    Examples: Maps
      | typeA       | typeB       | expectedComparison |
      | Map(String) | Map(String) | 0                  |
      | Map(String) | Map(Number) | -1                 |
      | Map(Number) | Map(String) | 1                  |
      | Map(String) | String      | 0                  |

    Examples: Objects
      | typeA                                            | typeB                                            | expectedComparison |
      | EmptyObject                                      | EmptyObject                                      | 0                  |
      | EmptyObject                                      | Object({"name": String})                         | 0                  |
      | Object({"name": String})                         | Object({"name": String})                         | 0                  |
      | Object({"name": String, "number": Number})       | Object({"name": String})                         | 0                  |
      | Object({"number": Number})                       | Object({"name": String})                         | 0                  |
      | Object({"name": String, "number": Number})       | Object({"name": String, "number": Number})       | 0                  |
      | Object({"name": String, "number": String})       | Object({"name": String, "number": Number})       | -1                 |
      | Object({"name": String, "number": Number})       | Object({"name": String, "number": String})       | 1                  |
      | Object({"a": String, "b": Number})               | Object({"a": Number, "b": String})               | 0                  |

    Examples: Tuples
      | typeA                               | typeB                               | expectedComparison |
      | EmptyTuple                          | EmptyTuple                          | 0                  |
      | EmptyTuple                          | Tuple([String])                     | 0                  |
      | Tuple([String])                     | Tuple([String])                     | 0                  |
      | Tuple([String, Number])             | Tuple([String])                     | 0                  |
      | Tuple([String, Number])             | Tuple([String, Number])             | 0                  |
      | Tuple([String, String])             | Tuple([String, Number])             | -1                 |
      | Tuple([String, Number])             | Tuple([String, String])             | 1                  |
      | Tuple([String, Number])             | Tuple([Number, String])             | 0                  |

    Examples: Lists and Sets
      | typeA        | typeB        | expectedComparison |
      | Set(String)  | List(String) | 1                  |
      | List(String) | Set(String)  | -1                 |
      | List(String) | Set(Number)  | -1                 |
      | Set(Number)  | List(String) | 1                  |
      | List(Number) | Set(String)  | -1                 |
      | Set(String)  | List(Number) | 1                  |

    Examples: Dynamics
      | typeA    | typeB    | expectedComparison |
      | Dynamic  | Dynamic  | 0                  |
      | Dynamic  | String   | 1                  |
      | String   | Dynamic  | -1                 |
      | Number   | Dynamic  | -1                 |
      | Dynamic  | Number   | 1                  |
      | Bool     | Dynamic  | -1                 |
      | Dynamic  | Bool     | 1                  |
