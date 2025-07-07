# Covers tests in cty/function/stdlib/string_test.go

Feature: Standard Library String Manipulation Functions
  Background:
    Given a Go environment

  Scenario Outline: Convert string to uppercase
    Given an input string <inputValue>
    When I convert the string to uppercase
    Then the result should be "<expectedValue>"
    And no error should occur

    Examples:
      | inputValue      | expectedValue          |
      | "hello"         | "HELLO"                |
      | "HELLO"         | "HELLO"                |
      | ""              | ""                     |
      | "1"             | "1"                    |
      | "жж"            | "ЖЖ"                   |
      | "noël"          | "NOËL"                 |
      | "baﬄe"          | "BAﬄE"                 | # Ligature handling
      | "😸😾"          | "😸😾"                 | # Emoji
      | Unknown(String) | UnknownNotNull(String) |
      | Dynamic         | UnknownNotNull(String) |
      | "hello" (m 1)   | "HELLO" (m 1)          |

  Scenario Outline: Convert string to lowercase
    Given an input string <inputValue>
    When I convert the string to lowercase
    Then the result should be "<expectedValue>"
    And no error should occur

    Examples:
      | inputValue      | expectedValue          |
      | "HELLO"         | "hello"                |
      | "hello"         | "hello"                |
      | ""              | ""                     |
      | "1"             | "1"                    |
      | "ЖЖ"            | "жж"                   |
      | Unknown(String) | UnknownNotNull(String) |
      | Dynamic         | UnknownNotNull(String) |

  Scenario Outline: Reverse a string
    Given an input string <inputValue>
    When I reverse the string
    Then the result should be "<expectedValue>"
    And no error should occur

    Examples:
      | inputValue      | expectedValue          |
      | "hello"         | "olleh"                |
      | ""              | ""                     |
      | "1"             | "1"                    |
      | "Живой Журнал"  | "ланруЖ йовиЖ"         |
      | "noël"          | "lëon"                 | # Combining dieresis
      | "wé́́é́́é́́!"    | "!é́́é́́é́́w"    | # Combining acute accents
      | "baﬄe"          | "eﬄab"                 | # Ligature handling (compatibility)
      | "😸😾"          | "😾😸"                 | # Emoji
      | Unknown(String) | UnknownNotNull(String) |
      | Dynamic         | UnknownNotNull(String) |

  Scenario Outline: Get the length of a string (number of graphemes)
    Given an input string <inputValue>
    When I get the length of the string
    Then the result should be <expectedLength>
    And no error should occur

    Examples:
      | inputValue                           | expectedLength                                  |
      | "hello"                              | 5                                               |
      | ""                                   | 0                                               |
      | "1"                                  | 1                                               |
      | "Живой Журнал"                       | 12                                              |
      | "noël"                               | 4                                               |
      | "wé́́é́́é́́!"                         | 5                                               |
      | "baﬄe"                               | 4                                               |
      | "😸😾"                               | 2                                               |
      | Unknown(String)                      | Unknown(Number) refined not null, lower bound 0 |
      | Unknown(S) refined prefix "wé́́é́́é́́-" | Unknown(Number) refined not null, lower bound 5 |
      | Dynamic                              | Unknown(Number) refined not null, lower bound 0 |

  Scenario Outline: Extract a substring
    Given an input string <inputString>
    And an offset <offset>
    And a length <length>
    When I extract the substring
    Then the result should be "<expectedSubstring>"
    And no error should occur

    Examples:
      | inputString      | offset | length | expectedSubstring |
      | "hello"          | 0      | 2      | "he"              |
      | "hello"          | 1      | 3      | "ell"             |
      | "hello"          | 1      | -1     | "ello"            | # -1 means to end of string
      | "hello"          | 1      | -10    | "ello"            | # <0 same as -1
      | "hello"          | 1      | 10     | "ello"            | # Length exceeds string
      | "hello"          | -3     | -1     | "llo"             |
      | "hello"          | -3     | 2      | "ll"              |
      | "hello"          | 10     | 10     | ""                | # Offset out of bounds
      | "hello"          | 0      | 0      | ""                |
      | "noël"          | 0      | 3      | "noë"             |
      | "noël"          | 3      | -1     | "l"               |
      | "wé́́é́́é́́!"    | 2      | 2      | "é́́é́́"            |
      | "wé́́é́́é́́!"    | 3      | 2      | "é́́!"             |
      | "wé́́é́́é́́!"    | -2     | -1     | "é́́!"             |
      | "noël"          | -2     | -1     | "ël"              |
      | "😸😾"          | 0      | 1      | "😸"              |
      | "😸😾"          | 1      | 1      | "😾"              |

  Scenario Outline: Join a list of strings with a separator
    Given a separator string <separator>
    And a list of lists of strings <listsToJoin>
    When I join the lists with the separator
    Then the result should be "<expectedJoinedString>"
    And no error should occur

    Examples:
      | separator | listsToJoin                                        | expectedJoinedString        |
      | "-"       | [["hello","world"]]                                | "hello-world"               |
      | "-"       | [["chicken"],["egg"]]                               | "chicken-egg"               |
      | "-"       | [["chicken"]]                                      | "chicken"                   |
      | ""        | [["horse","face"]]                                 | "horseface"                 |
      | "-"       | [["hello","world"] (m "sensitive")]                | "hello-world" (m "sensitive") |
      | "-" (m "sensitive") | [["hello","world"]]                      | "hello-world" (m "sensitive") |
      | "-"       | [["hello"(m "sensitive"),"world"]]                 | "hello-world" (m "sensitive") |
      | "-" (m "a") | [["hello"(m "b"),"world"(m "c")]]                | "hello-world" (m "a","b","c") |

  Scenario Outline: Sort a list of strings
    Given a list of strings <listToSort>
    When I sort the list
    Then the result should be list <expectedSortedList>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples:
      | listToSort                                    | expectedSortedList               | shouldError | errorMessage |
      | EmptyList(S)                                  | EmptyList(S)                     | should not  |              |
      | ["a"]                                         | ["a"]                            | should not  |              |
      | ["b","a"]                                     | ["a","b"]                        | should not  |              |
      | ["b","a","c"]                                 | ["a","b","c"]                    | should not  |              |
      | Unknown(List(S))                              | UnknownNotNull(List(S))          | should not  |              |
      | ["b", Unknown(S)]                             | [Unknown(S), Unknown(S)]         | should not  |              | # Length preserved
      | Unknown(List(S)) refined len 1-2              | UnknownNotNull(List(S)) refined len 1-2 | should not  |              |
