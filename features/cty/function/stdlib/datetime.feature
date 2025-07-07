# Original Go Test File: cty/function/stdlib/datetime_test.go
# This feature file covers tests for date and time formatting functions
# in the cty standard library, specifically FormatDate.

Feature: Standard Library Date and Time Formatting
  This feature describes the behavior of the `formatdate` function,
  which formats an RFC3339 timestamp string into a custom string representation.

  Background:
    Given the cty FormatDate function
    And a base timestamp string "2006-01-02T15:04:05Z" (representing Go's reference time in UTC)

  Scenario Outline: Formatting a timestamp string with valid format specifiers
    # Covers test: TestFormatDate (successful formatting cases)
    Given a format string <FormatSpecifier>
    And an input timestamp string <TimestampString>
    When FormatDate is called with the format specifier and the timestamp string
    Then the result should be the string <ExpectedFormattedString>
    And marks from format specifier and timestamp string should be propagated to the result

    Examples: Common Date and Time Format Specifiers (Timestamp: "2006-01-02T15:04:05Z" - BaseTimestamp)
      | FormatSpecifier            | TimestampString                 | ExpectedFormattedString         | Description                                      |
      | "YYYY-MM-DD"               | BaseTimestamp                   | "2006-01-02"                    | ISO 8601 Date                                    |
      | String("YYYY-MM-DD").Mark(f)| BaseTimestamp                   | String("2006-01-02").Mark(f)    | Mark on format str                               |
      | "YYYY-MM-DD"               | String(BaseTimestamp).Mark(t)   | String("2006-01-02").Mark(t)    | Mark on timestamp str                            |
      | String("YYYY-MM-DD").Mark(f)| String(BaseTimestamp).Mark(t)   | String("2006-01-02").WithMarks(f,t) | Marks on both inputs                           |
      | ""                           | BaseTimestamp                   | ""                              | Empty format results in empty string             |
      | "EEE, MMM D ''YY"            | BaseTimestamp                   | "Mon, Jan 2 '06"                | Short day, short month, day of month, short year |
      | "hh:mm:ss"                   | BaseTimestamp                   | "15:04:05"                      | Time in 24-hour format                           |
      | "H 'o''clock' AA"            | BaseTimestamp                   | "3 o'clock PM"                  | Hour (12h), literal text, AM/PM marker (upper) |
      | "hh:mm:ssZZZZ"               | BaseTimestamp                   | "15:04:05+0000"                 | Time with numeric timezone offset (no colon)     |
      | "hh:mm:ssZZZZZ"              | BaseTimestamp                   | "15:04:05+00:00"                | Time with numeric timezone offset (with colon)   |
      | "MMMM"                       | BaseTimestamp                   | "January"                       | Full month name                                  |
      | "EEEE"                       | BaseTimestamp                   | "Monday"                        | Full day name                                    |
      | "aa"                         | BaseTimestamp                   | "pm"                            | AM/PM marker (lower)                             |

    Examples: Standard Machine-Oriented Formats (Timestamp: "2006-01-02T15:04:05Z" - BaseTimestamp)
      | FormatSpecifier                 | TimestampString | ExpectedFormattedString         | Standard   |
      | "YYYY-MM-DD'T'hh:mm:ssZ"        | BaseTimestamp   | "2006-01-02T15:04:05Z"          | RFC3339    |
      | "DD MMM YYYY hh:mm ZZZ"         | BaseTimestamp   | "02 Jan 2006 15:04 UTC"         | RFC822     |
      | "EEEE, DD-MMM-YY hh:mm:ss ZZZ"  | BaseTimestamp   | "Monday, 02-Jan-06 15:04:05 UTC"| RFC850     |
      | "EEE, DD MMM YYYY hh:mm:ss ZZZ" | BaseTimestamp   | "Mon, 02 Jan 2006 15:04:05 UTC" | RFC1123    |

  Scenario Outline: Formatting with invalid format specifiers
    # Covers test: TestFormatDate (invalid format specifier error cases)
    Given a format string "<InvalidFormatSpecifier>"
    When FormatDate is called with the invalid format specifier and the base timestamp string
    Then the operation should fail with an error message containing "<ExpectedErrorMessagePart>"

    Examples:
      | InvalidFormatSpecifier | ExpectedErrorMessagePart                                       |
      | "Y"                    | "invalid date format verb \"Y\": year must either be \"YY\" or \"YYYY\"" |
      | "YYYYY"                | "invalid date format verb \"YYYYY\": year must either be \"YY\" or \"YYYY\"" |
      | "A"                    | "invalid date format verb \"A\": must be \"AA\""               |
      | "a"                    | "invalid date format verb \"a\": must be \"aa\""               |
      | "'blah blah"           | "unterminated literal '"                                       |
      | "'"                    | "unterminated literal '"                                       |

  Scenario Outline: Parsing and formatting various timestamp strings
    # Covers test: TestFormatDate (parse success tests)
    Given an input timestamp string "<InputTimestamp>"
    When FormatDate is called with format specifier "<FormatSpecifier>" and the input timestamp
    Then the result should be the string "<ExpectedFormattedString>"

    Examples:
      | InputTimestamp           | FormatSpecifier                 | ExpectedFormattedString         |
      | "2022-03-01T00:23:45Z"     | "YYYY-MM-DD'T'hh:mm:ssZ"        | "2022-03-01T00:23:45Z"          |
      | "2022-03-01T00:23:45+00:00"| "YYYY-MM-DD'T'hh:mm:ssZ"        | "2022-03-01T00:23:45Z"          |
      | "2022-03-01T00:23:45+01:00"| "YYYY-MM-DD'T'hh:mm:ssZ"        | "2022-03-01T00:23:45+01:00"     |
      | "1900-01-01T00:00:00Z"     | "EEEE, DD-MMM-YY hh:mm:ss ZZZ"  | "Monday, 01-Jan-00 00:00:00 UTC"|

  Scenario Outline: Attempting to format invalid timestamp strings
    # Covers test: TestFormatDate (parse error tests)
    Given an invalid input timestamp string "<InvalidTimestamp>"
    When FormatDate is called with any valid format specifier (e.g., "YYYY") and the invalid timestamp
    Then the operation should fail with an error message containing "<ExpectedErrorMessagePart>"

    Examples:
      | InvalidTimestamp           | ExpectedErrorMessagePart                                     |
      | ""                         | "not a valid RFC3339 timestamp: end of string before year"   |
      | "2017-01-02"               | "not a valid RFC3339 timestamp: missing required time introducer 'T'" |
      | "2017-13-02T00:00:00Z"     | "not a valid RFC3339 timestamp: cannot use \"-02T00:00:00Z\" as month" | # Quirky Go parser message
      | "2017-02-31T00:00:00Z"     | "not a valid RFC3339 timestamp: day out of range"            |
      | "2000-01-01T00:00:00,000Z" | "not a valid RFC3339 timestamp: cannot use \",\" as timestamp segment" |

  Scenario Outline: Formatting with Null, Unknown, or Dynamic inputs
    # Covers implied behavior for robust porting
    Given a format string input <FormatInput>
    And a timestamp string input <TimestampInput>
    When FormatDate is called with the format input and timestamp input
    Then the result should be <ExpectedResult>
    And an error message, if any, should contain "<ErrorMessagePart>"

    Examples:
      | FormatInput      | TimestampInput   | ExpectedResult  | ErrorMessagePart           |
      | Null(String)     | BaseTimestamp    |                 | "argument 1 must not be null" | # Assuming format is arg1
      | String("YYYY")   | Null(String)     |                 | "argument 2 must not be null" | # Assuming timestamp is arg2
      | Unknown(String)  | BaseTimestamp    | Unknown(String) |                            |
      | String("YYYY")   | Unknown(String)  | Unknown(String) |                            |
      | Dynamic          | BaseTimestamp    | Unknown(String) |                            |
      | String("YYYY")   | Dynamic          | Unknown(String) |                            |
      | Unknown(String)  | Unknown(String)  | Unknown(String) |                            |
