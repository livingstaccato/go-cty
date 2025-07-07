# Original Go Test File: cty/function/stdlib/string_test.go
# This feature file covers tests for various string manipulation functions
# in the cty standard library.

Feature: Standard Library String Manipulation Functions
  This feature describes the behavior of functions for manipulating
  cty String values, such as changing case, reversing, getting length,
  extracting substrings, and joining.

  Scenario Outline: Converting string to uppercase (Upper function)
    # Covers test: TestUpper
    Given a cty String <InputString>
    When the Upper function is called
    Then the result should be the cty String <ExpectedUppercaseString>
    And if the input was Unknown or Dynamic, the result should be Unknown(String) refined as NotNull
    And marks from the input string should be propagated to the result

    Examples:
      | InputString         | ExpectedUppercaseString |
      | "hello"             | "HELLO"                 |
      | "HELLO"             | "HELLO"                 |
      | ""                  | ""                      |
      | "1"                 | "1"                     |
      | "жж"                | "ЖЖ"                    | # Cyrillic
      | "noël"              | "NOËL"                  | # Latin with diaeresis
      | "baﬄe"              | "BAﬄE"                  | # Ligature (Go specific behavior)
      | "😸😾"               | "😸😾"                  | # Emojis
      | Unknown(String)     | Unknown(String)         |
      | Dynamic             | Unknown(String)         |
      | String("hello").Mark(1)| String("HELLO").Mark(1)|

  Scenario Outline: Converting string to lowercase (Lower function)
    # Covers test: TestLower
    Given a cty String <InputString>
    When the Lower function is called
    Then the result should be the cty String <ExpectedLowercaseString>
    And if the input was Unknown or Dynamic, the result should be Unknown(String) refined as NotNull

    Examples:
      | InputString     | ExpectedLowercaseString |
      | "HELLO"         | "hello"                 |
      | "hello"         | "hello"                 |
      | ""              | ""                      |
      | "1"             | "1"                     |
      | "ЖЖ"            | "жж"                    |
      | Unknown(String) | Unknown(String)         |
      | Dynamic         | Unknown(String)         |

  Scenario Outline: Reversing a string (Reverse function)
    # Covers test: TestReverse
    Given a cty String <InputString>
    When the Reverse function is called
    Then the result should be the cty String <ExpectedReversedString> (grapheme-aware)
    And if the input was Unknown or Dynamic, the result should be Unknown(String) refined as NotNull

    Examples:
      | InputString     | ExpectedReversedString |
      | "hello"         | "olleh"                |
      | ""              | ""                     |
      | "1"             | "1"                    |
      | "Живой Журнал"  | "ланруЖ йовиЖ"         | # Cyrillic
      | "noël"          | "lëon"                 | # Combining diaeresis
      | "wé́́é́́é́́!"    | "!é́́é́́é́́w"        | # Multiple combining accents
      | "baﬄe"          | "eﬄab"                 | # Ligature (Go specific behavior)
      | "😸😾"           | "😾😸"                  | # Emojis
      | Unknown(String) | Unknown(String)        |
      | Dynamic         | Unknown(String)        |

  Scenario Outline: Getting string length (Strlen function)
    # Covers test: TestStrlen
    Given a cty String <InputString>
    When the Strlen function is called
    Then the result should be a cty Number <ExpectedLength> (grapheme count)
    And if the input was Unknown or Dynamic, the result should be Unknown(Number) refined as NotNull and non-negative

    Examples:
      | InputString               | ExpectedLength  |
      | "hello"                   | Number(5)       |
      | ""                        | Number(0)       |
      | "Живой Журнал"            | Number(12)      |
      | "noël"                    | Number(4)       |
      | "wé́́é́́é́́!"              | Number(5)       |
      | "😸😾"                     | Number(2)       |
      | Unknown(String)           | Unknown(Number) |
      | Unknown(S).RefinePrefix("abc-") | Unknown(Number) | # Length refined >= 4
      | Dynamic                   | Unknown(Number) |

  Scenario Outline: Extracting a substring (Substr function)
    # Covers test: TestSubstr
    Given a cty String <InputString>
    And a cty Number offset <Offset>
    And a cty Number length <Length>
    When the Substr function is called with input, offset, and length
    Then the result should be the cty String <ExpectedSubstring> (grapheme-aware)

    Examples:
      | InputString | Offset    | Length    | ExpectedSubstring |
      | "hello"     | Number(0) | Number(2) | "he"              |
      | "hello"     | Number(1) | Number(3) | "ell"             |
      | "hello"     | Number(1) | Number(-1)| "ello"            | # Length -1 means to end of string
      | "hello"     | Number(-3)| Number(2) | "ll"              | # Negative offset from end
      | "noël"      | Number(0) | Number(3) | "noë"             |
      | "wé́́é́́é́́!"| Number(2) | Number(2) | "é́́é́́"        |
      | "😸😾"       | Number(1) | Number(1) | "😾"              |

  Scenario Outline: Extracting a substring (Substr function) - Error and Unknown Cases
    # Covers implied error handling and unknown argument behavior for Substr
    Given a cty String <InputString>
    And a cty Value offset <Offset>
    And a cty Value length <Length>
    When the Substr function is called with input, offset, and length
    Then an error should <ErrorOccur> with message part "<ErrorMessagePart>"
    And if no error, the result should be cty String <ExpectedSubstring>

    Examples: Invalid Offset/Length Types
      | InputString    | Offset        | Length    | ErrorOccur | ErrorMessagePart        | ExpectedSubstring |
      | String("hello")| String("a")   | Number(2) | occur      | "offset must be number" |                   |
      | String("hello")| Number(0)     | True      | occur      | "length must be number" |                   |

    Examples: Unknown Offset/Length or Input String
      | InputString    | Offset          | Length          | ErrorOccur | ErrorMessagePart        | ExpectedSubstring      |
      | String("hello")| Unknown(Number) | Number(2)       | not occur  |                         | Unknown(String)        |
      | String("hello")| Number(0)       | Unknown(Number) | not occur  |                         | Unknown(String)        |
      | Unknown(String)| Number(0)       | Number(2)       | not occur  |                         | Unknown(String)        |
      # Note: .NotNull refinement is implied for Unknown(String) results from Substr function

  Scenario Outline: Joining a list of strings (Join function)
    # Covers test: TestJoin
    Given a cty String separator <Separator>
    And a list of cty Lists of Strings <ListsToJoin>
    When the Join function is called with the separator and lists
    Then the result should be the cty String <ExpectedJoinedString>
    And marks from separator, lists, and elements should be propagated/merged to the result

    Examples:
      | Separator        | ListsToJoin                                  | ExpectedJoinedString    |
      | "-"              | [List(S("hello"),S("world"))]                | "hello-world"           |
      | "-"              | [List(S("chicken")), List(S("egg"))]         | "chicken-egg"           | # Implicitly concatenates lists first
      | "-"              | [List(S("chicken"))]                         | "chicken"               |
      | ""               | [List(S("horse"),S("face"))]                 | "horseface"             |
      | "-".Mark(a)      | [List(S("h").M(b),S("w").M(c))]              | "h-w".WithMarks(a,b,c)  |
      | "-"              | [List(S("h"),S("w")).M(s)]                   | "h-w".Mark(s)           |

    # Note on Value Syntax:
    # - String("text"), Number(X), Unknown(Type), Dynamic
    # - .Mark(m), .WithMarks(a,b) for marked values
    # - S for cty.String type, e.g. Unknown(S)
    # - Refinements like .RefineNotNull(), .RefinePrefix() are applied to Unknown results.
    # - For Join, ListsToJoin is a list of cty.ListVal arguments.

  Scenario Outline: Sorting a list of strings (Sort function)
    # Covers test: TestSort (from cty/function/stdlib/string_test.go)
    Given a cty List of Strings <InputList>
    When the Sort function is called
    Then the result should be the cty List of Strings <ExpectedSortedList>
    And if the input list was Unknown, the result should be Unknown(List(String)) refined as NotNull, preserving length refinements
    And if the input list contained Unknown elements, the result is a list of Unknown(String) elements of the same length

    Examples:
      | InputList                                      | ExpectedSortedList                              |
      | List()                                         | List()                                          | # Empty list
      | List("a")                                      | List("a")                                       | # Single element
      | List("b", "a")                                 | List("a", "b")                                  |
      | List("b", "a", "c")                            | List("a", "b", "c")                             |
      | Unknown(List(String))                          | Unknown(List(String))                           |
      | List("b", Unknown(String))                     | List(Unknown(String), Unknown(String))          |
      | Unknown(List(S)).RefineLengthBounds(1,2)       | Unknown(List(S)).RefineNotNull().RefineLengthBounds(1,2) |

    # Note on Value Syntax (continued for Sort):
    # - List() implies cty.ListValEmpty(cty.String) for Sort scenarios.
    # - List("a", "b") implies cty.ListVal([]cty.Value{cty.StringVal("a"), cty.StringVal("b")})
    # - .RefineLengthBounds(min,max) is a shorthand for refinement on unknown list length.
