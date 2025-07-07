# Covers tests in cty/function/stdlib/format_test.go

Feature: Standard Library String Formatting Functions
  Background:
    Given a Go environment

  Scenario Outline: Format a string with arguments using 'format'
    Given a format string <formatString>
    And format arguments <arguments>
    When I format the string with these arguments
    Then the result should be <expectedString>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples: Basic Formatting
      | formatString      | arguments        | expectedString         | shouldError | errorMessage |
      | ""                | []               | ""                     | should not  |              |
      | "hello"           | []               | "hello"                | should not  |              |
      | "100%% successful"| []               | "100% successful"      | should not  |              |
      | "100%%"           | []               | "100%"                 | should not  |              |

    Examples: Default Formats (%v, %#v)
      | formatString             | arguments               | expectedString                         | shouldError | errorMessage |
      | "string %v"              | ["hello"]               | "string hello"                         | should not  |              |
      | "string %[2]v"           | [True, "hello"]         | "string hello"                         | should not  |              |
      | "string %#v"             | ["hello"]               | "string \"hello\""                     | should not  |              |
      | "number %v"              | [2]                     | "number 2"                             | should not  |              |
      | "number %#v"             | [2]                     | "number 2"                             | should not  |              |
      | "bool %v"                | [True]                  | "bool true"                            | should not  |              |
      | "bool %#v"               | [True]                  | "bool true"                            | should not  |              |
      | "object %v"              | [EmptyObject]           | "object {}"                            | should not  |              |
      | "tuple %v"               | [EmptyTuple]            | "tuple []"                             | should not  |              |
      | "tuple with unknown %v"  | [Tuple([Unknown(S)])]   | Unknown(S) refined not null, prefix "tuple with unknown " | should not  |              |
      | "%%%v"                   | [False]                 | "%false"                               | should not  |              |
      | "%v"                     | [Null(Bool)]            | "null"                                 | should not  |              |
      | "%v"                     | [Null(Dynamic)]         | "null"                                 | should not  |              |

    Examples: String Formats (%s, %q)
      | formatString        | arguments               | expectedString         | shouldError | errorMessage |
      | "Hello, %s!"        | ["Ermintrude"]          | "Hello, Ermintrude!"   | should not  |              |
      | "Hello, %[2]s!"     | ["Stephen","Ermintrude"]| "Hello, Ermintrude!"   | should not  |              |
      | "Hello, %q..."      | ["Ermintrude"]          | "Hello, \"Ermintrude\"..." | should not  |              |
      | "Statement is %s"   | [False]                 | "Statement is false"   | should not  |              |
      | "Statement is %q"   | [False]                 | "Statement is \"false\"" | should not  |              |
      | "%10s"              | ["hello"]               | "     hello"           | should not  |              |
      | "%-10s"             | ["hello"]               | "hello     "           | should not  |              |
      | "%4s"               | ["💃🏿"]                  | "   💃🏿"                | should not  |              |
      | "%-4s"              | ["💃🏿"]                  | "💃🏿   "                | should not  |              |
      | "%q"                | ["💃🏿"]                  | "\"💃🏿\""                | should not  |              |
      | "%6q"               | ["💃🏿"]                  | "   \"💃🏿\""             | should not  |              |
      | "%-6q"              | ["💃🏿"]                  | "\"💃🏿\"   "             | should not  |              |
      | "%.2s"              | ["hello"]               | "he"                   | should not  |              |
      | "%.2q"              | ["hello"]               | "\"he\""                 | should not  |              |
      | "%.5s"              | ["日本語日本語"]        | "日本語日本"           | should not  |              |
      | "%.1q"              | ["日本語日本語"]        | "\"日\""                 | should not  |              |
      | "%.10s"             | ["hello"]               | "hello"                | should not  |              |
      | "%4.2s"             | ["hello"]               | "  he"                 | should not  |              |
      | "%6.2q"             | ["hello"]               | "  \"he\""               | should not  |              |
      | "%-4.2s"            | ["hello"]               | "he  "                 | should not  |              |
      | "%q"                | ["Hello\nWorld"]        | "\"Hello\\nWorld\""      | should not  |              |

    Examples: Boolean Format (%t)
      | formatString        | arguments        | expectedString         | shouldError | errorMessage |
      | "Statement is %t"   | [False]          | "Statement is false"   | should not  |              |
      | "Statement is %[2]t"| [True, False]    | "Statement is false"   | should not  |              |
      | "Statement is %t"   | [True]           | "Statement is true"    | should not  |              |
      | "Statement is %t"   | ["false"]        | "Statement is false"   | should not  |              |

    Examples: Integer Formats (%d, %b, %o, %x, %X)
      | formatString        | arguments        | expectedString         | shouldError | errorMessage |
      | "%d bottles"        | [10]             | "10 bottles"           | should not  |              |
      | "%[2]d things"      | [1, 10]          | "10 things"            | should not  |              |
      | "%+d bottles"       | [10]             | "+10 bottles"          | should not  |              |
      | "% d bottles"       | [10]             | " 10 bottles"          | should not  |              |
      | "%5d bottles"       | [10]             | "   10 bottles"        | should not  |              |
      | "%-5d bottles"      | [10]             | "10    bottles"        | should not  |              |
      | "%b"                | [5]              | "101"                  | should not  |              |
      | "%o"                | [9]              | "11"                   | should not  |              |
      | "%x"                | [254]            | "fe"                   | should not  |              |
      | "%X"                | [254]            | "FE"                   | should not  |              |

    Examples: Float Formats (%f, %e, %E, %g, %G)
      | formatString        | arguments          | expectedString           | shouldError | errorMessage |
      | "%f things"         | [10]               | "10.000000 things"       | should not  |              |
      | "%[2]f things"      | [1,10]             | "10.000000 things"       | should not  |              |
      | "%+f things"        | [10]               | "+10.000000 things"      | should not  |              |
      | "% f things"        | [10]               | " 10.000000 things"      | should not  |              |
      | "%+f things"        | [-10]              | "-10.000000 things"      | should not  |              |
      | "% f things"        | [-10]              | "-10.000000 things"      | should not  |              |
      | "%f things"         | ["1e38+1"]         | "100000000000000000000000000000000000001.000000 things" | should not  |       |
      | "%f things"         | ["1.00000000000000000000000000000000000001"] | "1.000000 things"        | should not  |              |
      | "%.4f things"       | ["1.00000000000000000000000000000000000001"] | "1.0000 things"          | should not  |              |
      | "%.1f things"       | ["1.06"]           | "1.1 things"             | should not  |              |
      | "%e things"         | [1000]             | "1.000000e+03 things"    | should not  |              |
      | "%E things"         | [1000]             | "1.000000E+03 things"    | should not  |              |
      | "%g things"         | [1000]             | "1000 things"            | should not  |              |
      | "%G things"         | [1000]             | "1000 things"            | should not  |              |
      | "%g things"         | ["1e-23"]          | "1e-23 things"           | should not  |              |
      | "%G things"         | ["1e-23"]          | "1E-23 things"           | should not  |              |

    Examples: Unknown and Null Value Handling
      | formatString        | arguments               | expectedString                         | shouldError | errorMessage |
      | Unknown(String)     | [True]                  | UnknownNotNull(String)                 | should not  |              |
      | "Hello, %s!"        | [Unknown(String)]       | Unknown(S) refined not null, prefix "Hello, " | should not  |              |
      | "Hello%s"           | [Unknown(String)]       | Unknown(S) refined not null, prefix "Hell" | should not  |              | # 'o' trimmed
      | "Hello, %[2]s!"     | [Unknown(S),"Ermintrude"]| Unknown(S) refined not null, prefix "Hello, " | should not  |              |
      | "%s!"               | [Unknown(String)]       | UnknownNotNull(String)                 | should not  |              |
      | "%v"                | [Dynamic]               | UnknownNotNull(String)                 | should not  |              |
      | "%s"                | [Null(String)]          |                                        | should      | "unsupported value for \"%s\" at 0: null value cannot be formatted" |
      | "%s"                | [Null(Dynamic)]         |                                        | should      | "unsupported value for \"%s\" at 0: null value cannot be formatted" |
      | "%t"                | [Null(Bool)]            |                                        | should      | "unsupported value for \"%t\" at 18: null value cannot be formatted" |
      | "%t"                | [Null(Dynamic)]         |                                        | should      | "unsupported value for \"%t\" at 18: null value cannot be formatted" |
      | "%d"                | [Null(Number)]          |                                        | should      | "unsupported value for \"%d\" at 0: null value cannot be formatted" |
      | "%d"                | [Null(EmptyTuple)]      |                                        | should      | "unsupported value for \"%d\" at 0: null value cannot be formatted" | # Assuming tuple cannot be number
      | "%d"                | [Null(Dynamic)]         |                                        | should      | "unsupported value for \"%d\" at 0: null value cannot be formatted" |

    Examples: Marked Value Handling
      | formatString        | arguments            | expectedString              | shouldError | errorMessage |
      | "hello %s" (m 1)    | ["world"]            | "hello world" (m 1)         | should not  |              |
      | "hello %s"          | ["world" (m 1)]      | "hello world" (m 1)         | should not  |              |
      | "hello %s" (m 0)    | ["world" (m 1)]      | "hello world" (m 0, 1)      | should not  |              |

    Examples: Error Cases
      | formatString        | arguments        | expectedString | shouldError | errorMessage |
      | Unknown(Bool)       | [True]           |                | should      | "string required, but received bool" |
      | "%s is not in args" | []               |                | should      | "not enough arguments for \"%s\" at 0: need index 1 but have 0 total" |
      | "%[3]s not in args" | [True, True]     |                | should      | "not enough arguments for \"%[3]s\" at 0: need index 3 but have 2 total" |
      | "%[0]s not valid"   | [True, True]     |                | should      | "unrecognized format character '0' at offset 2" |
      | "%v %v %v"          | [True, True]     |                | should      | "not enough arguments for \"%v\" at 6: need index 3 but have 2 total" |
      | "%z not valid"      | [10]             |                | should      | "unsupported format verb 'z' in \"%z\" at offset 0" |
      | "%#z not valid"     | [10]             |                | should      | "unsupported format verb 'z' in \"%#z\" at offset 0" |
      | "%012z not valid"   | [10]             |                | should      | "unsupported format verb 'z' in \"%012z\" at offset 0" |
      | "%☠ not valid"      | [10]             |                | should      | "unrecognized format character '☠' at offset 1" |
      | "%💃🏿 not valid"    | [10]             |                | should      | "unrecognized format character '💃' at offset 1" |
      | Null(String)        | [10]             |                | should      | "argument must not be null" |
      | "no verbs"          | [10]             |                | should      | "too many arguments; no verbs in format string" |
      | "one verb %d"       | [10, 11]         |                | should      | "too many arguments; only 1 used by format string" |
      | "%d bottles"        | [True]           |                | should      | "unsupported value for \"%d\" at 0: number required" |

  Scenario Outline: Format a list of strings with arguments using 'formatlist'
    Given a format string <formatString>
    And format arguments <arguments>
    When I format the list of strings with these arguments
    Then the result should be list <expectedList>
    And an error <shouldError> occur with message "<errorMessage>"

    Examples: Basic List Formatting
      | formatString      | arguments             | expectedList                      | shouldError | errorMessage |
      | ""                | []                    | [""]                              | should not  |              |
      | "hello"           | []                    | ["hello"]                         | should not  |              |
      | "100%% successful"| []                    | ["100% successful"]               | should not  |              |
      | "100%%"           | []                    | ["100%"]                          | should not  |              |
      | "%s"              | ["hello"]             | ["hello"]                         | should not  |              |
      | "%s"              | [["hello"]]           | ["hello"]                         | should not  |              |
      | "%s"              | [["hello", "world"]]  | ["hello", "world"]                | should not  |              |
      | "%s %s"           | [["h","g"],["w","u"]] | ["hello world", "goodbye universe"] | should not  |              |
      | "%s %s"           | [["h","g"],"world"]   | ["hello world", "goodbye world"]    | should not  |              |
      | "%s %s"           | ["hello",["w","u"]]   | ["hello world", "hello universe"]   | should not  |              |
      | "%v"              | [EmptyTuple]          | []                                | should not  |              | # Empty tuple iterates 0 times
      | "%v"              | [Null(List(S))]       | ["null"]                          | should not  |              | # Null list treated as list of nulls

    Examples: List Formatting with Unknown/Null/Dynamic
      | formatString      | arguments                        | expectedList                      | shouldError | errorMessage |
      | Unknown(String)     | [True]                           | UnknownNotNull(List(S))           | should not  |              |
      | "%v"              | [Unknown(S)]                     | [UnknownNotNull(S)]               | should not  |              |
      | "%v"              | [Null(S)]                        | ["null"]                          | should not  |              |
      | "%v"              | [Unknown(List(S))]               | UnknownNotNull(List(S))           | should not  |              |
      | "%v"              | [[Tuple(["h"]),Tuple([Unk(S)]),Tuple(["w"])]] | ["[\"hello\"]",UnknownNotNull(S),"[\"world\"]"] | should not  |              |
      | "%v"              | [Unknown(Tuple([S]))]            | UnknownNotNull(List(S))           | should not  |              |
      | "%v"              | [Set(["hello", Unknown(S)])]     | UnknownNotNull(List(S))           | should not  |              |
      | "%v"              | [Dynamic]                        | UnknownNotNull(List(S))           | should not  |              |
      | "%v"              | [Null(Dynamic)]                  | ["null"]                          | should not  |              |
      | "%v %v"           | [Null(Dyn), ["a",Null(S),"c"]]   | ["null a", "null null", "null c"] | should not  |              |
      | "%v %v"           | [Null(Dyn), [Null(Dyn),Null(Dyn)]]| ["null null", "null null"]        | should not  |              |

    Examples: List Formatting Error Cases
      | formatString      | arguments             | expectedList        | shouldError | errorMessage |
      | "%s %s"           | [["h","g"],["w"]]     | EmptyList(S)        | should      | "argument 2 has length 1, which is inconsistent with argument 1 of length 2" |
      | "%s"              | [EmptyObject]         | EmptyList(S)        | should      | "error on format iteration 0: unsupported value for \"%s\" at 0: string required" |
      | "%s %s"           | [Unk(Tuple([S])), Unk(Tuple([S,S]))] | UnknownNotNull(List(S)) | should    | "argument 2 has length 2, which is inconsistent with argument 1 of length 1" |
      | "%s %s"           | [["hi"], Unk(Tuple([S,S]))] | UnknownNotNull(List(S)) | should    | "argument 2 has length 2, which is inconsistent with argument 1 of length 1" |
