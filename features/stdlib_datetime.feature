# Covers tests in cty/function/stdlib/datetime_test.go

Feature: Standard Library Date and Time Functions
  Background:
    Given a Go environment
    And a timestamp string "2006-01-02T15:04:05Z"

  Scenario Outline: Format a date/time string
    Given a format string "<formatString>"
    When I format the timestamp using the format string
    Then the result should be "<expectedFormattedString>"
    And an error <shouldError> occur with message "<errorMessage>"

    Examples: Valid Formats
      | formatString                        | expectedFormattedString      | shouldError | errorMessage |
      | ""                                  | ""                           | should not  |              |
      | "YYYY-MM-DD"                        | "2006-01-02"                 | should not  |              |
      | "EEE, MMM D ''YY"                   | "Mon, Jan 2 '06"             | should not  |              |
      | "hh:mm:ss"                          | "15:04:05"                   | should not  |              |
      | "H 'o''clock' AA"                   | "3 o'clock PM"               | should not  |              |
      | "H 'o''clock'"                      | "3 o'clock"                  | should not  |              |
      | "hh:mm:ssZZZZ"                      | "15:04:05+0000"              | should not  |              |
      | "hh:mm:ssZZZZZ"                     | "15:04:05+00:00"             | should not  |              |
      | "MMMM"                              | "January"                    | should not  |              |
      | "EEEE"                              | "Monday"                     | should not  |              |
      | "aa"                                | "pm"                         | should not  |              |
      | "YYYY-MM-DD'T'hh:mm:ssZ"            | "2006-01-02T15:04:05Z"       | should not  |              | # RFC3339
      | "DD MMM YYYY hh:mm ZZZ"             | "02 Jan 2006 15:04 UTC"      | should not  |              | # RFC822
      | "EEEE, DD-MMM-YY hh:mm:ss ZZZ"      | "Monday, 02-Jan-06 15:04:05 UTC" | should not  |              | # RFC850
      | "EEE, DD MMM YYYY hh:mm:ss ZZZ"     | "Mon, 02 Jan 2006 15:04:05 UTC" | should not  |              | # RFC1123

    Examples: Invalid Formats
      | formatString | expectedFormattedString | shouldError | errorMessage                                                           |
      | "Y"          |                         | should      | "invalid date format verb \"Y\": year must either be \"YY\" or \"YYYY\"" |
      | "YYYYY"      |                         | should      | "invalid date format verb \"YYYYY\": year must either be \"YY\" or \"YYYY\"" |
      | "A"          |                         | should      | "invalid date format verb \"A\": must be \"AA\""                       |
      | "a"          |                         | should      | "invalid date format verb \"a\": must be \"aa\""                       |
      | "'blah blah" |                         | should      | "unterminated literal '"                                               |
      | "'"          |                         | should      | "unterminated literal '"                                               |

  Scenario Outline: Parse invalid timestamp string for FormatDate
    Given a format string ""
    And an invalid timestamp string "<invalidTimestamp>"
    When I attempt to format the invalid timestamp
    Then an error should occur with message "<expectedErrorMessage>"

    Examples:
      | invalidTimestamp           | expectedErrorMessage                                                              |
      | ""                         | "not a valid RFC3339 timestamp: end of string before year"                        |
      | "2017-01-02"               | "not a valid RFC3339 timestamp: missing required time introducer 'T'"             |
      | "2017-12-02t00:00:00Z"     | "not a valid RFC3339 timestamp: missing required time introducer 'T'"             |
      | "2017:01:02"               | "not a valid RFC3339 timestamp: found \":01:02\" where \"-\" is expected"         |
      | "2017"                     | "not a valid RFC3339 timestamp: end of string where \"-\" is expected"            |
      | "2017-01-02T"              | "not a valid RFC3339 timestamp: end of string before hour"                        |
      | "2017-01-02T00"            | "not a valid RFC3339 timestamp: end of string where \":\" is expected"            |
      | "2017-01-02T00:00:00"      | "not a valid RFC3339 timestamp: end of string before UTC offset"                  |
      | "2017-01-02T26:00:00Z"     | "not a valid RFC3339 timestamp: hour must be between 0 and 23 inclusive"          |
      | "2017-13-02T00:00:00Z"     | "not a valid RFC3339 timestamp: cannot use \"-02T00:00:00Z\" as month"            |
      | "2017-02-31T00:00:00Z"     | "not a valid RFC3339 timestamp: day out of range"                                 |
      | "\"2017-12-02T00:00:00Z\"" | "not a valid RFC3339 timestamp: cannot use \"\\\"2017-12-02T00:00:00Z\\\"\" as year" |
      | "2-12-02T00:00:00Z"        | "not a valid RFC3339 timestamp: cannot use \"2-12-02T00:00:00Z\" as year"         |
      | "2000-01-01T1:12:34Z"      | "not a valid RFC3339 timestamp: hour must have exactly two digits"                |
      | "2000-01-01T01:1:34Z"      | "not a valid RFC3339 timestamp: minute must have exactly two digits"              |
      | "2000-01-01T01:01:1Z"      | "not a valid RFC3339 timestamp: cannot use \"1Z\" as second"                      |
      | "2000-01-01T00:00:00,000Z" | "not a valid RFC3339 timestamp: cannot use \",\" as timestamp segment"            |
      | "2000-01-01T00:00:00+24:00"| "not a valid RFC3339 timestamp: cannot use \"+24:00\" as UTC offset"              |
      | "2000-01-01T00:00:00+00:60"| "not a valid RFC3339 timestamp: cannot use \"+00:60\" as UTC offset"              |

  Scenario Outline: Parse valid timestamp string and format it
    Given a valid timestamp string "<inputTimestamp>"
    And a format string "<formatString>"
    When I format the timestamp using the format string
    Then the result should be "<expectedFormattedString>"
    And no error should occur

    Examples:
      | inputTimestamp             | formatString                        | expectedFormattedString           |
      | "2022-03-01T00:23:45Z"     | "YYYY-MM-DD'T'hh:mm:ssZ"            | "2022-03-01T00:23:45Z"            |
      | "2022-03-01T00:23:45Z"     | "EEEE, DD-MMM-YY hh:mm:ss ZZZ"      | "Tuesday, 01-Mar-22 00:23:45 UTC" |
      | "2022-03-01T00:23:45+00:00"| "YYYY-MM-DD'T'hh:mm:ssZ"            | "2022-03-01T00:23:45Z"            |
      | "2022-03-01T00:23:45+00:00"| "EEEE, DD-MMM-YY hh:mm:ss ZZZ"      | "Tuesday, 01-Mar-22 00:23:45 UTC" |
      | "2022-03-01T00:23:45+01:00"| "YYYY-MM-DD'T'hh:mm:ssZ"            | "2022-03-01T00:23:45+01:00"       |
      | "2022-03-01T00:23:45+01:00"| "EEEE, DD-MMM-YY hh:mm:ss ZZZ"      | "Tuesday, 01-Mar-22 00:23:45 +0100"|
      | "2022-03-01T00:23:45-01:00"| "YYYY-MM-DD'T'hh:mm:ssZ"            | "2022-03-01T00:23:45-01:00"       |
      | "2022-03-01T00:23:45-01:00"| "EEEE, DD-MMM-YY hh:mm:ss ZZZ"      | "Tuesday, 01-Mar-22 00:23:45 -0100"|
      | "1900-01-01T00:00:00Z"     | "YYYY-MM-DD'T'hh:mm:ssZ"            | "1900-01-01T00:00:00Z"            |
      | "1900-01-01T00:00:00Z"     | "EEEE, DD-MMM-YY hh:mm:ss ZZZ"      | "Monday, 01-Jan-00 00:00:00 UTC"  |
