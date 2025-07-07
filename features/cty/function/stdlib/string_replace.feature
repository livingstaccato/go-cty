# Original Go Test File: cty/function/stdlib/string_replace_test.go
# This feature file covers tests for string replacement functions
# in the cty standard library.

Feature: Standard Library String Replacement Functions
  This feature describes the behavior of functions that replace occurrences
  of a substring or a regex pattern within a string.

  Scenario Outline: Replacing literal substrings (Replace function)
    # Covers test: TestReplace
    Given an input cty String <InputString>
    And a cty String substring to find <Substring>
    And a cty String replacement string <Replacement>
    When the Replace function is called with input string, substring, and replacement
    Then the result should be the cty String <ExpectedString>
    And if any input is Unknown/Dynamic, the result is Unknown(String) refined NotNull & propagates marks

    Examples: Basic Replace
      | InputString     | Substring | Replacement | ExpectedString  |
      | "hello"         | "l"       | ""          | "heo"           |
      | "😸😸😸😾😾😾"     | "😾"      | "😸"        | "😸😸😸😸😸😸"  |
      | "😸😸😸😸😸😾"     | "😾"      | "😸"        | "😸😸😸😸😸😸"  |

    Examples: Replace with Empty Substring
      | InputString     | Substring | Replacement | ExpectedString  |
      | "abab"          | ""        | "X"         | "XaXbXaXbX"     | # Replaces at beginning, end, and between each char
      | "abab"          | ""        | ""          | "abab"          | # No-op if replacement is also empty

    Examples: Replace with Unknown/Dynamic/Marks
      | InputString        | Substring        | Replacement      | ExpectedString                 |
      | Unknown(String)    | "l"              | "L"              | Unknown(String)                |
      | "hello"            | Unknown(String)  | "L"              | Unknown(String)                |
      | "hello"            | "l"              | Unknown(String)  | Unknown(String)                |
      | Dynamic            | "l"              | "L"              | Unknown(String)                |
      | "hello all".Mark(i)| "l".Mark(s)      | "L".Mark(r)      | "heLLo aLL".WithMarks(i,s,r)   |

  Scenario Outline: Replacing regex pattern matches (RegexReplace function)
    # Covers test: TestRegexReplace
    Given an input cty String <InputString>
    And a cty String regex pattern <Pattern>
    And a cty String replacement string <Replacement>
    When the RegexReplace function is called with input string, pattern, and replacement
    Then the result should be the cty String <ExpectedString>
    And if any input is Unknown/Dynamic, the result is Unknown(String) refined NotNull & propagates marks

    Examples: Basic Regex Replace
      | InputString | Pattern    | Replacement | ExpectedString | Description                                     |
      | "-ab-axxb-" | "a(x*)b"   | "T"         | "-T-T-"        | Replace matches of "a" + (zero or more "x") + "b" with "T" |
      | "-ab-axxb-" | "a(x*)b"   | "${1}W"     | "-W-xxW-"      | Replace matches, using first capture group ("x*") in replacement |

    Examples: RegexReplace with Empty Pattern
      | InputString | Pattern    | Replacement | ExpectedString  |
      | "test"      | ""         | "X"         | "XtXeXsXtX"     | # Empty pattern matches empty strings at beginning, end, and between chars

    Examples: RegexReplace with Unknown/Dynamic/Marks
      | InputString        | Pattern          | Replacement      | ExpectedString                 |
      | Unknown(String)    | "a(x*)b"         | "T"              | Unknown(String)                |
      | "-ab-"             | Unknown(String)  | "T"              | Unknown(String)                | # Pattern unknown
      | "-ab-"             | "a(x*)b"         | Unknown(String)  | Unknown(String)                |
      | Dynamic            | "a(x*)b"         | "T"              | Unknown(String)                |
      | "-ab-".Mark(i)     | "a(x*)b".Mark(p) | "T".Mark(r)      | "-T-".WithMarks(i,p,r)         |


  Scenario: RegexReplace with invalid regex pattern
    # Covers test: TestRegexReplaceInvalidRegex
    Given an input cty String "any"
    And an invalid cty String regex pattern "("
    And a cty String replacement "any"
    When the RegexReplace function is called with these inputs
    Then an error should occur with a message containing "error parsing regexp" # Or similar specific regex error

  Scenario Outline: Replace functions with Null inputs
    # Covers implied error handling for robust porting
    Given an input cty String <InputString>
    And a cty String substring/pattern <Search>
    And a cty String replacement <Replacement>
    When the <Function> function is called with these inputs
    Then an error should occur with a message containing "must not be null"

    Examples:
      | Function     | InputString  | Search       | Replacement  |
      | Replace      | Null(String) | String("a")  | String("b")  |
      | Replace      | String("a")  | Null(String) | String("b")  |
      | Replace      | String("a")  | String("b")  | Null(String) |
      | RegexReplace | Null(String) | String("a")  | String("b")  |
      | RegexReplace | String("a")  | Null(String) | String("b")  |
      | RegexReplace | String("a")  | String("b")  | Null(String) |


    # Note on Value Syntax:
    # - Strings are cty.StringVal, e.g., "hello".
    # - Unknown(String), Dynamic, Null(String) for special string values.
    # - .Mark(x), .WithMarks(x,y,z) for marked values.
    # - Result refinement to NotNull for Unknown(String) is implied.
    # - Emojis are used to test Unicode handling.
