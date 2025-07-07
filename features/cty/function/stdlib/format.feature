# Original Go Test File: cty/function/stdlib/format_test.go
# This feature file covers tests for the Format and FormatList functions
# in the cty standard library, which provide sprintf-like functionality.

Feature: Standard Library String Formatting (sprintf-like)
  This feature describes the behavior of the `format` and `formatlist` functions,
  which format a series of cty values into a string based on a format string.

  Scenario Outline: Formatting values using Format function (single output string)
    # Covers test: TestFormat
    Given a format string <FormatString>
    And a list of cty arguments <Args>
    When the Format function is called with the format string and arguments
    Then the result should be the cty String <ExpectedResult>
    And the error message, if any, should be "<ExpectedErrorMessage>"
    And if the result is an Unknown(String), its refined prefix should be "<RefinedPrefix>" and it should be <NullRefinedStatus>

    Examples: Basic and No-Arg Formatting
      | FormatString        | Args | ExpectedResult    | ExpectedErrorMessage | RefinedPrefix     | NullRefinedStatus |
      | ""                  | []   | ""                |                      | ""                | not null          |
      | "hello"             | []   | "hello"           |                      | "hello"           | not null          |
      | "100%% successful"  | []   | "100% successful" |                      | "100% successful" | not null          |
      | "100%%"             | []   | "100%"            |                      | "100%"            | not null          |

    Examples: Default Verb (%v, %#v)
      | FormatString        | Args                      | ExpectedResult         | ExpectedErrorMessage | RefinedPrefix        | NullRefinedStatus |
      | "string %v"         | [String("hello")]         | "string hello"         |                      | "string hello"       | not null          |
      | "string %[2]v"      | [True, String("hello")]   | "string hello"         |                      | "string hello"       | not null          |
      | "string %#v"        | [String("hello")]         | "string \"hello\""     |                      | "string \"hello\""   | not null          |
      | "number %v"         | [Number(2)]               | "number 2"             |                      | "number 2"           | not null          |
      | "bool %v"           | [True]                    | "bool true"            |                      | "bool true"          | not null          |
      | "object %v"         | [EmptyObject]             | "object {}"            |                      | "object {}"          | not null          |
      | "tuple %v"          | [EmptyTuple]              | "tuple []"             |                      | "tuple []"           | not null          |
      | "tuple with unknown %v" | [Tuple(Unknown(S))]   | Unknown(String)        |                      | "tuple with unknown " | not null          |
      | "%%%v"              | [False]                   | "%false"               |                      | "%false"             | not null          |
      | "%v"                | [Null(Bool)]              | "null"                 |                      | "null"               | not null          |

    Examples: String Verbs (%s, %q) with padding and precision
      | FormatString        | Args                      | ExpectedResult         | ExpectedErrorMessage | RefinedPrefix     | NullRefinedStatus |
      | "Hello, %s!"        | [String("Ermintrude")]    | "Hello, Ermintrude!"   |                      | "Hello, Ermintrude!" | not null          |
      | "Hello, %q!"        | [String("Ermintrude")]    | "Hello, \"Ermintrude\"!" |                    | "Hello, \"Ermintrude\"!" | not null        |
      | "%10s"              | [String("hello")]         | "     hello"           |                      | "     hello"      | not null          |
      | "%-10s"             | [String("hello")]         | "hello     "           |                      | "hello     "      | not null          |
      | "%.2s"              | [String("hello")]         | "he"                   |                      | "he"              | not null          |
      | "%4.2s"             | [String("hello")]         | "  he"                 |                      | "  he"            | not null          |
      | "%s"                | [Null(String)]            |                        | "unsupported value for \"%s\" at 0: null value cannot be formatted" |                   |                   |

    Examples: Boolean Verb (%t)
      | FormatString        | Args                      | ExpectedResult         | ExpectedErrorMessage | RefinedPrefix     | NullRefinedStatus |
      | "Statement is %t"   | [False]                   | "Statement is false"   |                      | "Statement is false" | not null        |
      | "Statement is %t"   | [String("true")]          | "Statement is true"    |                      | "Statement is true"| not null          |
      | "Statement is %t"   | [Null(Bool)]              |                        | "unsupported value for \"%t\" at 15: null value cannot be formatted" |                   |                   |

    Examples: Integer Verbs (%d, %b, %o, %x, %X)
      | FormatString        | Args                      | ExpectedResult         | ExpectedErrorMessage | RefinedPrefix     | NullRefinedStatus |
      | "%d bottles"        | [Number(10)]              | "10 bottles"           |                      | "10 bottles"      | not null          |
      | "%+d bottles"       | [Number(10)]              | "+10 bottles"          |                      | "+10 bottles"     | not null          |
      | "%b"                | [Number(5)]               | "101"                  |                      | "101"             | not null          |
      | "%x"                | [Number(254)]             | "fe"                   |                      | "fe"              | not null          |
      | "%d"                | [True]                    |                        | "unsupported value for \"%d\" at 0: number required" |                   |                   |

    Examples: Float Verbs (%f, %e, %g)
      | FormatString        | Args                      | ExpectedResult         | ExpectedErrorMessage | RefinedPrefix     | NullRefinedStatus |
      | "%f things"         | [Number(10)]              | "10.000000 things"     |                      | "10.000000 things"| not null          |
      | "%.2f things"       | [String("1.06")]          | "1.06 things"          |                      | "1.06 things"     | not null          | # Original test uses 1.1 due to Go's default float printing for %.1f
      | "%e things"         | [Number(1000)]            | "1.000000e+03 things"  |                      | "1.000000e+03 things"| not null        |
      | "%g things"         | [String("0.00001")]       | "1e-05 things"         |                      | "1e-05 things"    | not null          |

    Examples: Unknown and Dynamic Arguments
      | FormatString        | Args                      | ExpectedResult         | ExpectedErrorMessage | RefinedPrefix     | NullRefinedStatus |
      | Unknown(String)     | [True]                    | Unknown(String)        |                      | ""                | not null          |
      | "Hello, %s!"        | [Unknown(String)]         | Unknown(String)        |                      | "Hello, "         | not null          |
      | "Hello%s"           | [Unknown(String)]         | Unknown(String)        |                      | "Hell"            | not null          | # 'o' trimmed
      | "%s!"               | [Unknown(String)]         | Unknown(String)        |                      | ""                | not null          |
      | "%v"                | [Dynamic]                 | Unknown(String)        |                      | ""                | not null          |

    Examples: Invalid Formatting or Arguments
      | FormatString        | Args                      | ExpectedResult         | ExpectedErrorMessage | RefinedPrefix     | NullRefinedStatus |
      | "%s is missing"     | []                        |                        | "not enough arguments for \"%s\" at 0: need index 1 but have 0 total" |                   |                   |
      | "%[0]s is invalid"  | [True]                    |                        | "unrecognized format character '0' at offset 2" |                   |                   |
      | "%z is invalid"     | [Number(10)]              |                        | "unsupported format verb 'z' in \"%z\" at offset 0" |                   |                   |
      | Null(String)        | [Number(10)]              |                        | "argument must not be null" |                   |                   |
      | "too many args"     | [Number(10)]              |                        | "too many arguments; no verbs in format string" |                   |                   |

    Examples: Marked Values
      | FormatString        | Args                      | ExpectedResult         | ExpectedErrorMessage | RefinedPrefix     | NullRefinedStatus |
      | "hello %s".Mark(1)  | [String("world")]         | "hello world".Mark(1)  |                      | "hello world"     | not null          |
      | "hello %s"          | [String("world").Mark(1)] | "hello world".Mark(1)  |                      | "hello world"     | not null          |
      | "hello %s".Mark(A)  | [String("world").Mark(B)] | "hello world".WithMarks(A,B) |                | "hello world"     | not null          |

  Scenario Outline: Formatting values using FormatList function (list of output strings)
    # Covers test: TestFormatList
    Given a format string <FormatString>
    And a list of cty arguments <Args> for list formatting
    When the FormatList function is called with the format string and arguments
    Then the result should be the cty List <ExpectedListResult> of element type String
    And the error message, if any, should be "<ExpectedErrorMessage>"

    Examples: Basic List Formatting
      | FormatString | Args                      | ExpectedListResult              | ExpectedErrorMessage |
      | ""           | []                        | List("")                        |                      |
      | "hello"      | []                        | List("hello")                   |                      |
      | "%s"         | [String("hello")]         | List("hello")                   |                      |
      | "%s"         | [List(S("h"), S("w"))]    | List("h", "w")                  |                      |

    Examples: Multiple List Arguments
      | FormatString | Args                                           | ExpectedListResult              | ExpectedErrorMessage |
      | "%s %s"      | [List(S("h"),S("g")), List(S("w"),S("u"))]     | List("h w", "g u")              |                      |
      | "%s %s"      | [List(S("h"),S("g")), String("world")]         | List("h world", "g world")      |                      |
      | "%s %s"      | [String("hello"), List(S("w"),S("u"))]         | List("hello w", "hello u")      |                      |
      | "%s %s"      | [List(S("h"),S("g")), List(S("w"))]            | EmptyList(String)               | "argument 2 has length 1, which is inconsistent with argument 1 of length 2" |

    Examples: List Formatting with Errors and Unknowns
      | FormatString | Args                                           | ExpectedListResult              | ExpectedErrorMessage |
      | "%s"         | [EmptyObject]                                  | EmptyList(String)               | "error on format iteration 0: unsupported value for \"%s\" at 0: string required" |
      | "%v"         | [EmptyTuple]                                   | EmptyList(String)               |                      |
      | "%v"         | [Null(List(String))]                           | List("null")                    |                      |
      | Unknown(S)   | [True]                                         | Unknown(List(String)).RefineNotNull() |                      |
      | "%v"         | [Unknown(String)]                              | List(Unknown(String).RefineNotNull()) |                      |
      | "%v"         | [Null(String)]                                 | List("null")                    |                      |
      | "%v"         | [Unknown(List(String))]                        | Unknown(List(String)).RefineNotNull() |                      |
      | "%v"         | [List(Tuple(S("h")),Tuple(Unk(S)),Tuple(S("w")))] | List("[\"h\"]", Unknown(S).RefineNotNull(), "[\"w\"]") |    |
      | "%v"         | [Dynamic]                                      | Unknown(List(String)).RefineNotNull() |                      |
      | "%v %v"      | [Null(Dyn), List(S("a"),Null(S),S("c"))]       | List("null a", "null null", "null c") |                    |

    # Note on Value Syntax:
    # S=String, N=Number, B=Bool, Dyn=DynamicType, Unk=Unknown
    # List(...), Tuple(...), EmptyObject, EmptyTuple, Null(Type)
    # .Mark(X), .WithMarks(X,Y)
    # RefinedPrefix is the expected safe prefix for unknown string results.
    # NullRefinedStatus indicates if an unknown string result is also refined as not null.
    # Args for FormatList are wrapped in an outer list, e.g., [ [List(S("h"))] ] for one list argument.
