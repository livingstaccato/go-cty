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

    Examples:
      | InputString     | Substring | Replacement | ExpectedString  |
      | "hello"         | "l"       | ""          | "heo"           |
      | "😸😸😸😾😾😾"     | "😾"      | "😸"        | "😸😸😸😸😸😸"  |
      | "😸😸😸😸😸😾"     | "😾"      | "😸"        | "😸😸😸😸😸😸"  |
      # The Go test runs these through both Replace and RegexReplace,
      # implying literal strings in RegexReplace should behave like Replace.

  Scenario Outline: Replacing regex pattern matches (RegexReplace function)
    # Covers test: TestRegexReplace
    Given an input cty String <InputString>
    And a cty String regex pattern <Pattern>
    And a cty String replacement string <Replacement>
    When the RegexReplace function is called with input string, pattern, and replacement
    Then the result should be the cty String <ExpectedString>

    Examples:
      | InputString | Pattern    | Replacement | ExpectedString | Description                                     |
      | "-ab-axxb-" | "a(x*)b"   | "T"         | "-T-T-"        | Replace matches of "a" + (zero or more "x") + "b" with "T" |
      | "-ab-axxb-" | "a(x*)b"   | "${1}W"     | "-W-xxW-"      | Replace matches, using first capture group ("x*") in replacement |

  Scenario: RegexReplace with invalid regex pattern
    # Covers test: TestRegexReplaceInvalidRegex
    Given an input cty String "any"
    And an invalid cty String regex pattern "("
    And a cty String replacement "any"
    When the RegexReplace function is called with these inputs
    Then an error should occur due to the invalid regex pattern

    # Note on Value Syntax:
    # - Strings are cty.StringVal, e.g., "hello"
    # - Emojis are used to test Unicode handling.
