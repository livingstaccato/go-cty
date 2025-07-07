# Covers tests in cty/path_set_test.go

Feature: PathSet Operations
  Background:
    Given a Go environment

  Scenario: Basic PathSet operations
    Given a path "p1" defined as `GetAttr("hello").GetAttr("world")`
    And a new PathSet "s" initialized with "p1"
    Then "s" should contain "p1"
    And "s" should not contain path `GetAttr("hello")`
    And the list representation of "s" should be ["p1"]

    Given a path "p2" defined as `GetAttr("foo").Index(String("bar")).GetAttr("baz")`
    When I add all steps of "p2" to PathSet "s"
    Then "s" should contain "p1"
    And "s" should contain "p2"
    And "s" should contain path `GetAttr("foo").Index(String("bar"))`
    And "s" should contain path `GetAttr("foo")`

    When I remove path `GetAttr("foo").Index(String("bar"))` from "s"
    Then "s" should not contain path `GetAttr("foo").Index(String("bar"))`
    And "s" should contain "p2"
    And "s" should contain path `GetAttr("foo")`

  Scenario: PathSet equality
    Given a PathSet "s1" containing paths:
      | Path                                                        |
      | GetAttr("hello").GetAttr("world")                           |
      | GetAttr("foo").Index(String("bar")).GetAttr("baz")          |
      | GetAttr("foo")                                              |
    And a PathSet "s2" created from the list representation of "s1"
    Then PathSet "s1" should be equal to PathSet "s2"

    When I remove path `GetAttr("hello").GetAttr("world")` from "s2"
    Then PathSet "s1" should not be equal to PathSet "s2"

    When I add path `GetAttr("goodbye").GetAttr("world")` to "s2"
    Then PathSet "s1" should not be equal to PathSet "s2"
