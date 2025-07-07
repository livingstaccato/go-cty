# Original Go Test File: cty/function/stdlib/regexp_test.go
# This feature file covers tests for regular expression functions
# in the cty standard library.

Feature: Standard Library Regular Expression Functions
  This feature describes the behavior of functions that use regular expressions
  to find and extract parts of strings.

  Scenario Outline: Finding the first regex match in a string (Regex function)
    # Covers test: TestRegex
    Given a cty String regular expression pattern <Pattern>
    And a cty String <InputString> to search
    When the Regex function is called with the pattern and input string
    Then the result should be <ExpectedResult>
    And if the pattern has no capture groups, the result type is String
    And if the pattern has unnamed capture groups, the result type is Tuple of String
    And if the pattern has named capture groups, the result type is Object with String attributes
    And if the input string is Unknown, the result is Unknown of the determined type, refined as NotNull
    And if the pattern is Unknown, the result is DynamicVal
    And marks from pattern or input string are propagated to the result

    Examples: No Capture Groups
      | Pattern        | InputString            | ExpectedResult  |
      | "[a-z]+"       | "135abc456def789"      | String("abc")   |
      | "[a-z]+".Mark(1)| "135abc456def789"      | String("abc").Mark(1) |
      | "[a-z]+"       | "135abc456def789".Mark(2)| String("abc").Mark(2) |

    Examples: Unnamed Capture Groups
      | Pattern           | InputString      | ExpectedResult             |
      | "([0-9]*)([a-z]*)"| "135abc456def"   | Tuple(String("135"), String("abc")) |
      | "([0-9]*)([a-z]*)"| Unknown(String)  | Unknown(Tuple(String,String)) |

    Examples: Named Capture Groups (URI Parsing)
      | Pattern                                                                                                | InputString                                    | ExpectedResult                                                                                                |
      | "^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?(?P<path>[^?#]*)(?:\\?(?P<query>[^#]*))?(?:#(?P<fragment>.*))?$" | "http://www.ics.uci.edu/pub/ietf/uri/#Related" | Obj(scheme="http", authority="www.ics.uci.edu", path="/pub/ietf/uri/", query=Null(S), fragment="Related") |
      | "(?P<num>[0-9]*)"                                                                                      | Unknown(String)                                | Unknown(Object(num=S))                                                                                        |

    Examples: Unknown Pattern
      | Pattern         | InputString    | ExpectedResult |
      | Unknown(String) | "135abc456def" | Dynamic        |

  Scenario Outline: Finding all regex matches in a string (RegexAll function)
    # Covers test: TestRegexAll
    Given a cty String regular expression pattern <Pattern>
    And a cty String <InputString> to search
    When the RegexAll function is called with the pattern and input string
    Then the result should be a cty List of <MatchResultType>, with values <ExpectedMatches>
    And if the input string is Unknown, the result is Unknown List of the determined type, refined as NotNull
    And if the pattern is Unknown, the result is Unknown List of DynamicType, refined as NotNull

    Examples: No Capture Groups
      | Pattern        | InputString            | MatchResultType | ExpectedMatches              |
      | "[a-z]+"       | "135abc456def789"      | String          | [String("abc"), String("def")] |

    Examples: Unnamed Capture Groups
      | Pattern           | InputString      | MatchResultType    | ExpectedMatches                                           |
      | "([0-9]*)([a-z]*)"| "135abc456def"   | Tuple(String,String) | [Tuple(S("135"),S("abc")), Tuple(S("456"),S("def"))]     |
      | "([0-9]*)([a-z]*)"| Unknown(String)  | Tuple(String,String) | Unknown(List(Tuple(S,S)))                                 |

    Examples: Named Capture Groups (URI Parsing)
      | Pattern                                                                                                | InputString                                    | MatchResultType    | ExpectedMatches                                                                                                   |
      | "^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?(?P<path>[^?#]*)(?:\\?(?P<query>[^#]*))?(?:#(?P<fragment>.*))?$" | "http://www.ics.uci.edu/pub/ietf/uri/#Related" | Object             | [Obj(scheme="http", authority="www.ics.uci.edu", path="/pub/ietf/uri/", query=Null(S), fragment="Related")] |
      | "(?P<num>[0-9]*)"                                                                                      | Unknown(String)  | Object(num=S)      | Unknown(List(Object(num=S)))                                                                      |

    Examples: Unknown Pattern
      | Pattern         | InputString    | MatchResultType | ExpectedMatches                |
      | Unknown(String) | "135abc456def" | DynamicType     | Unknown(List(DynamicType))     |

    Examples: No Match (Result is Null of appropriate type)
      | Pattern           | InputString         | ExpectedResult             |
      | "[0-9]+"          | "abc"               | Null(String)               | # No digits in "abc"
      | "([a-z])([0-9])"  | "abc123def"         | Null(Tuple(S,S))           | # Example: if pattern was "([x])([y])" it wouldn't match
      | "(?P<word>[a-z]+)"| "123"               | Null(Object(word=S))       | # No letters in "123"
      | "[a-z]+".Mark(p)  | String("123").Mark(s) | Null(String).WithMarks(p,s)| # Marks propagated to null result

  Scenario Outline: Finding all regex matches in a string (RegexAll function)
    # Covers test: TestRegexAll
    Given a cty String regular expression pattern <Pattern>
    And a cty String <InputString> to search
    When the RegexAll function is called with the pattern and input string
    Then the result should be a cty List of <MatchResultType>, with values <ExpectedMatches>
    And if the input string is Unknown, the result is Unknown List of the determined type, refined as NotNull
    And if the pattern is Unknown, the result is Unknown List of DynamicType, refined as NotNull

    Examples: No Capture Groups
      | Pattern        | InputString            | MatchResultType | ExpectedMatches              |
      | "[a-z]+"       | "135abc456def789"      | String          | [String("abc"), String("def")] |

    Examples: Unnamed Capture Groups
      | Pattern           | InputString      | MatchResultType    | ExpectedMatches                                           |
      | "([0-9]*)([a-z]*)"| "135abc456def"   | Tuple(String,String) | [Tuple(S("135"),S("abc")), Tuple(S("456"),S("def"))]     |
      | "([0-9]*)([a-z]*)"| Unknown(String)  | Tuple(String,String) | Unknown(List(Tuple(S,S)))                                 |

    Examples: Named Capture Groups (URI Parsing)
      | Pattern                                                                                                | InputString                                    | MatchResultType    | ExpectedMatches                                                                                                   |
      | "^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?(?P<path>[^?#]*)(?:\\?(?P<query>[^#]*))?(?:#(?P<fragment>.*))?$" | "http://www.ics.uci.edu/pub/ietf/uri/#Related" | Object             | [Obj(scheme="http", authority="www.ics.uci.edu", path="/pub/ietf/uri/", query=Null(S), fragment="Related")] |
      | "(?P<num>[0-9]*)"                                                                                      | Unknown(String)  | Object(num=S)      | Unknown(List(Object(num=S)))                                                                      |

    Examples: Unknown Pattern
      | Pattern         | InputString    | MatchResultType | ExpectedMatches                |
      | Unknown(String) | "135abc456def" | DynamicType     | Unknown(List(DynamicType))     |

    Examples: No Match (Result is Empty List of appropriate type)
      | Pattern           | InputString         | MatchResultType | ExpectedMatches                       |
      | "[0-9]+"          | "abc"               | String          | EmptyList(String)                     |
      | "([a-z])([0-9])"  | "abc"               | Tuple(S,S)      | EmptyList(Tuple(S,S))                 |
      | "(?P<w>[a-z]+)"   | "123"               | Object(w=S)     | EmptyList(Object(w=S))                |
      | "[0-9]+".Mark(p)  | String("abc").Mark(s) | String          | EmptyList(String).WithMarks(p,s)      | # Marks propagated to empty list

  Scenario: Regex function with invalid regex pattern
    Given a cty String invalid regex pattern "("
    And a cty String "any input" to search
    When the Regex function is called with the invalid pattern and input string
    Then an error should occur due to the invalid regex pattern

  Scenario: RegexAll function with invalid regex pattern
    Given a cty String invalid regex pattern "("
    And a cty String "any input" to search
    When the RegexAll function is called with the invalid pattern and input string
    Then an error should occur due to the invalid regex pattern

  Scenario Outline: Regex functions with Null inputs
    Given a cty String pattern <Pattern>
    And a cty String input <InputString>
    When the <Function> function is called with the pattern and input string
    Then an error should occur with a message containing "must not be null"

    Examples:
      | Function | Pattern      | InputString  |
      | Regex    | Null(String) | String("abc")|
      | Regex    | String("a")  | Null(String) |
      | RegexAll | Null(String) | String("abc")|
      | RegexAll | String("a")  | Null(String) |

    # Note on Value Syntax:
    # - String("abc"), Number(123), True, False, Null(Type), Unknown(Type), Dynamic
    # - Tuple(val1, val2), Obj(key1=val1), List(val1, val2), EmptyList(Type)
    # - Types: S=String
    # - Refinement: .RefineNotNull() is implied for unknown results from these functions.
    # - For RegexAll, ExpectedMatches is a list of the individual match structures.
    # - If ExpectedMatches is an Unknown List, the inner structure (e.g. Tuple(S,S)) is still defined.
    # - .Mark(p), .WithMarks(p,s) for marked values.
