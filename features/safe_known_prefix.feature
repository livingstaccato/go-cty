# Covers tests in cty/ctystrings/prefix_test.go

Feature: Safe Known Prefix Extraction
  Background:
    Given a Go environment

  Scenario Outline: Extract safe known prefix from a string
    Given an input string "<inputString>"
    When I extract the safe known prefix
    Then the result should be "<expectedPrefix>"

    Examples: General Unicode Rules
      | inputString             | expectedPrefix        |
      | ""                      | ""                    |
      | "a"                     | ""                    | # Discarded due to potential diacritics
      | "boo"                   | "bo"                  | # Final 'o' discarded
      | "boop\r"                | "boop"                | # Final '\r' discarded (potential \r\n)
      | "hello 가"              | "hello "              | # Hangul syllables trimmed
      | "hello 🤷🏽‍♂️"            | "hello "              | # Full emoji sequence trimmed
      | "hello 🤷🏽‍♂️ "           | "hello 🤷🏽‍♂️ "           | # Subsequent space avoids trimming
      | "hello 🤷"              | "hello "              | # Person Shrugging emoji trimmed
      | "hello 🤷 "             | "hello 🤷 "             | # Subsequent space avoids trimming
      | "hello 🤷\u200d"        | "hello "              | # Zero Width Joiner anticipates modifier
      | "hello \U0001f1e6"      | "hello "              | # Start of regional indicator
      | "hello \U0001f1e6\U0001f1e6" | "hello "              | # Regional indicator pair "AA"
      | "hello \U0001f1e6\U0001f1e6 " | "hello \U0001f1e6\U0001f1e6 " | # Subsequent space avoids trimming

    Examples: Common Delimiter Heuristics
      | inputString             | expectedPrefix            |
      | "ami-"                  | "ami-"                  | # EC2 object ID prefix
      | "foo_"                  | "foo_"                  | # Variable name prefix
      | "{\"foo\":"             | "{\"foo\":"             | # JSON object prefix
      | "beep();"               | "beep();"               | # C-like program prefix
      | "https://"              | "https://"              | # URL scheme prefix
      | "c:\\"                  | "c:\\"                  | # Windows path prefix
      | "[\"foo\","             | "[\"foo\","             | # JSON array prefix
      | "foo.bar."              | "foo.bar."              | # Attribute traversal prefix
      | "beep("                 | "beep("                 | # C-like program prefix
      | "beep()"                | "beep()"                | # C-like program prefix
      | "{"                     | "{"                     | # JSON object prefix
      | "[{}"                   | "[{}"                   | # JSON fragment
      | "["                     | "["                     | # JSON array prefix
      | "[[]"                   | "[[]"                   | # JSON fragment
      | "whatever |"            | "whatever |"            | # Unix command line
      | "https://example.com/foo?" | "https://example.com/foo?" | # URL with query string
      | "boop!"                 | "boop!"                 |
      | "ls ~"                  | "ls ~"                  | # Home directory reference
      | "a "                    | "a "                    | # Space disambiguates
      | "a\t"                   | "a\t"                   | # Tab disambiguates
      | "username@"             | "username@"             | # Incomplete email
      | "#"                     | "#"                     | # Comment or hashtag
      | "print $"               | "print $"               | # Perl scalar reference
      | "print %"               | "print %"               | # Perl hash reference
      | "^"                     | "^"                     | # Version constraint
      | "foo(&"                 | "foo(&"                 | # Address-of operator
      | "foo *"                 | "foo *"                 | # Multiplication
      | "foo +"                 | "foo +"                 | # Addition
      | "[\""                   | "[\""                   | # JSON string prefix
      | "['"                    | "['"                    | # JSON-like string prefix (single quote)
