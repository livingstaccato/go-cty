# Covers tests in cty/function/stdlib/string_replace_test.go

Feature: Standard Library String Replace Functions
  Background:
    Given a Go environment

  Scenario Outline: Replace occurrences of a substring in a string
    Given an input string <inputString>
    And a substring to find <substring>
    And a replacement string <replacement>
    When I replace all occurrences of the substring with the replacement
    Then the result should be "<expectedString>"
    And no error should occur

    Examples:
      | inputString      | substring | replacement | expectedString   |
      | "hello"          | "l"       | ""          | "heo"            |
      | "😸😸😸😾😾😾" | "😾"      | "😸"        | "😸😸😸😸😸😸" |
      | "😸😸😸😸😸😾" | "😾"      | "😸"        | "😸😸😸😸😸😸" |

  Scenario Outline: Replace occurrences of a regex pattern in a string
    Given an input string <inputString>
    And a regex pattern <pattern>
    And a replacement string <replacement>
    When I replace all occurrences of the regex pattern with the replacement
    Then the result should be "<expectedString>"
    And no error should occur

    Examples:
      | inputString   | pattern   | replacement | expectedString |
      | "-ab-axxb-"   | "a(x*)b"  | "T"         | "-T-T-"        |
      | "-ab-axxb-"   | "a(x*)b"  | "${1}W"     | "-W-xxW-"      |

  Scenario: RegexReplace with invalid regex pattern
    Given an input string ""
    And an invalid regex pattern "("
    And a replacement string ""
    When I attempt to replace occurrences of the invalid regex pattern
    Then an error should occur
