# Original Go Test File: cty/ctystrings/prefix_test.go
# This feature file covers the test cases for the SafeKnownPrefix function.

Feature: Safe Known String Prefix
  This feature describes the behavior of the SafeKnownPrefix function,
  which identifies the longest prefix of a string that is guaranteed
  not to change its grapheme cluster representation if more characters are appended.
  This is crucial for unknown string refinement in cty.

  Background:
    Given the SafeKnownPrefix function

  Scenario Outline: Determining the safe known prefix of a string
    # Covers test: TestSafeKnownPrefix
    Given the input string "<InputString>"
    When the safe known prefix is determined
    Then the resulting prefix should be "<ExpectedPrefix>"

    Examples: General Unicode Rules
      | InputString          | ExpectedPrefix       | Description                                                                 |
      | ""                   | ""                   | Empty string has empty prefix                                               |
      | "a"                  | ""                   | Single letter 'a' might combine, so trimmed                                 |
      | "boo"                | "bo"                 | Final 'o' might combine, so trimmed                                         |
      | "boop\r"             | "boop"               | Carriage return might form CRLF, so trimmed                               |
      | "hello 가"           | "hello "             | Hangul syllable might combine, trimmed                                      |
      | "hello 🤷🏽‍♂️"    | "hello "             | Complex emoji sequence trimmed conservatively                               |
      | "hello 🤷🏽‍♂️ "   | "hello 🤷🏽‍♂️ "    | Subsequent space prevents trimming of emoji                                 |
      | "hello 🤷"           | "hello "             | Base emoji (person shrugging) might combine, trimmed                        |
      | "hello 🤷 "          | "hello 🤷 "          | Subsequent space prevents trimming                                          |
      | "hello 🤷\u200d"     | "hello "             | Emoji with Zero Width Joiner anticipates more, trimmed                      |
      | "hello \U0001f1e6"   | "hello "             | Single regional indicator trimmed (expects pair)                            |
      | "hello \U0001f1e6\U0001f1e6" | "hello "             | Pair of regional indicators trimmed (any number can combine)              |
      | "hello \U0001f1e6\U0001f1e6 " | "hello \U0001f1e6\U0001f1e6 " | Subsequent space prevents trimming of regional indicators                 |

    Examples: Heuristics for Common Delimiters (Machine-Readable Strings)
      | InputString                | ExpectedPrefix             | Description (Context)                                     |
      | "ami-"                     | "ami-"                     | EC2 object identifier prefix                              |
      | "foo_"                     | "foo_"                     | Variable name prefix                                      |
      | "{\"foo\":"                | "{\"foo\":"                | JSON object prefix                                        |
      | "beep();"                  | "beep();"                  | C-like language statement prefix                          |
      | "https://"                 | "https://"                 | URL scheme prefix                                         |
      | "c:\\"                     | "c:\\"                     | Windows path prefix                                       |
      | "[\"foo\","                | "[\"foo\","                | JSON array prefix with partial content                    |
      | "foo.bar."                 | "foo.bar."                 | Attribute traversal prefix                                |
      | "beep("                    | "beep("                    | Function call prefix                                      |
      | "beep()"                   | "beep()"                   | Full function call (empty params)                         |
      | "{"                        | "{"                        | JSON object start                                         |
      | "[{}"                       | "[{}"                       | JSON fragment                                             |
      | "["                        | "["                        | JSON array start                                          |
      | "[[]"                       | "[[]"                       | JSON fragment (nested empty array)                      |
      | "whatever |"               | "whatever |"               | Unix-style command line pipe                              |
      | "https://example.com/foo?" | "https://example.com/foo?" | URL with query string start                               |
      | "boop!"                    | "boop!"                    | Exclamation mark                                          |
      | "ls ~"                     | "ls ~"                     | Home directory tilde                                      |
      | "a "                       | "a "                       | Space disambiguates                                       |
      | "a\t"                      | "a\t"                      | Tab disambiguates                                         |
      | "username@"                | "username@"                | Email prefix                                              |
      | "#"                        | "#"                        | Comment/hashtag start                                     |
      | "print $"                  | "print $"                  | Perl scalar reference                                     |
      | "print %"                  | "print %"                  | Perl hash reference                                       |
      | "^"                        | "^"                        | Version constraint prefix                                 |
      | "foo(&"                    | "foo(&"                    | Address-of operator                                       |
      | "foo *"                    | "foo *"                    | Multiplication operator                                   |
      | "foo +"                    | "foo +"                    | Addition operator                                         |
      | "[\""                      | "[\""                      | JSON array starting a string                              |
      | "['"                       | "['"                       | JSON-like array starting single-quoted string             |
