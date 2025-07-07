# Covers tests in cty/function/stdlib/regexp_test.go

Feature: Standard Library Regular Expression Functions
  Background:
    Given a Go environment

  Scenario Outline: Find first regex match in a string
    Given a regex pattern <pattern>
    And an input string <inputString>
    When I find the first regex match
    Then the result should be <expectedMatch>
    And no error should occur

    Examples:
      | pattern        | inputString           | expectedMatch                                                                 |
      | "[a-z]+"       | "135abc456def789"     | "abc"                                                                         |
      | "([0-9]*)([a-z]*)" | "135abc456def"        | Tuple(["135", "abc"])                                                         |
      | <uriRegex>     | <uriString>           | Obj({"scheme":"http","authority":"www.ics.uci.edu","path":"/pub/ietf/uri/","query":Null(S),"fragment":"Related"}) |
      | "([0-9]*)([a-z]*)" | Unknown(String)       | UnknownNotNull(Tuple([S,S]))                                                  |
      | "(?P<num>[0-9]*)"| Unknown(String)       | UnknownNotNull(Object({"num":S}))                                              |
      | Unknown(String)  | "135abc456def"        | Dynamic                                                                       |
      | "[a-z]+" (m 1) | "135abc456def789"     | "abc" (m 1)                                                                   |
      | "[a-z]+"       | "135abc456def789" (m 2) | "abc" (m 2)                                                                   |

    Variables:
      uriRegex: "^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?(?P<path>[^?#]*)(?:\\?(?P<query>[^#]*))?(?:#(?P<fragment>.*))?$"
      uriString: "http://www.ics.uci.edu/pub/ietf/uri/#Related"

  Scenario Outline: Find all regex matches in a string
    Given a regex pattern <pattern>
    And an input string <inputString>
    When I find all regex matches
    Then the result should be list <expectedMatches>
    And no error should occur

    Examples:
      | pattern        | inputString           | expectedMatches                                                                 |
      | "[a-z]+"       | "135abc456def789"     | ["abc", "def"]                                                                  |
      | "([0-9]*)([a-z]*)" | "135abc456def"        | [Tuple(["135","abc"]), Tuple(["456","def"])]                                  |
      | <uriRegex>     | <uriString>           | [Obj({"scheme":"http","authority":"www.ics.uci.edu","path":"/pub/ietf/uri/","query":Null(S),"fragment":"Related"})] |
      | "([0-9]*)([a-z]*)" | Unknown(String)       | UnknownNotNull(List(Tuple([S,S])))                                            |
      | "(?P<num>[0-9]*)"| Unknown(String)       | UnknownNotNull(List(Object({"num":S})))                                        |
      | Unknown(String)  | "135abc456def"        | UnknownNotNull(List(Dynamic))                                                 |

    Variables:
      uriRegex: "^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?(?P<path>[^?#]*)(?:\\?(?P<query>[^#]*))?(?:#(?P<fragment>.*))?$"
      uriString: "http://www.ics.uci.edu/pub/ietf/uri/#Related"
