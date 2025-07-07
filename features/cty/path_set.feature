# Original Go Test File: cty/path_set_test.go
# This feature file covers tests for the cty.PathSet data structure.

Feature: cty PathSet Operations
  This feature describes the behavior of the PathSet data structure,
  which stores a collection of cty.Path objects and provides operations
  for managing and querying these paths.

  Scenario: Basic PathSet operations
    # Covers test: TestPathSet
    Given an empty PathSet "s"
    And a path "p_hello_world" defined as [Attr("hello"), Attr("world")]
    When "p_hello_world" is added to "s" using NewPathSet constructor or Add
    Then "s" should contain "p_hello_world"
    And "s" should not contain the path [Attr("hello")] (prefix not automatically added by NewPathSet/Add)
    And the list of paths in "s" should be ["p_hello_world"]

    Given a path "p_foo_bar_baz" defined as [Attr("foo"), Index(String("bar")), Attr("baz")]
    When "p_foo_bar_baz" is added to "s" using AddAllSteps
    Then "s" should contain "p_hello_world"
    And "s" should contain "p_foo_bar_baz"
    And "s" should contain the path [Attr("foo"), Index(String("bar"))] (prefix p_foo_bar_baz[:2])
    And "s" should contain the path [Attr("foo")] (prefix p_foo_bar_baz[:1])

    When the path [Attr("foo"), Index(String("bar"))] is removed from "s"
    Then "s" should not contain the path [Attr("foo"), Index(String("bar"))]
    But "s" should still contain "p_foo_bar_baz"
    And "s" should still contain the path [Attr("foo")]

    Given a new PathSet "s_new" created from the list of paths in "s"
    Then "s_new" should be equal to "s"

    When "p_hello_world" is removed from "s_new"
    Then "s_new" should not be equal to "s"

    Given a path "p_goodbye_world" defined as [Attr("goodbye"), Attr("world")]
    When "p_goodbye_world" is added to "s_new" using Add
    Then "s_new" should still not be equal to "s" (as it now has goodbye.world and lacks hello.world compared to original s)

    # Note on Path Syntax:
    # - Attr("name") represents cty.GetAttrStep{Name: "name"}
    # - Index(cty.Value) represents cty.IndexStep{Key: cty.Value}
    # - String("bar") is cty.StringVal("bar")
    # - "s should contain path" means s.Has(path) is true.
    # - "s should be equal to s_new" means s.Equal(s_new) is true.
