# Covers tests in cty/object_type_test.go

Feature: Object Type Equality
  Background:
    Given a Go environment

  Scenario Outline: Compare two object types for equality
    Given an object type A: <objectA>
    And an object type B: <objectB>
    When I check if object type A equals object type B
    Then the result should be <expectedEquality>

    Examples: Equal Object Types
      | objectA                                          | objectB                                          | expectedEquality |
      | {}                                               | {}                                               | True             |
      | {"name": String}                                 | {"name": String}                                 | True             |
      | {"h\u00e9llo": String}                           | {"he\u0301llo": String}                           | True             | # Normalized attribute names
      | {"person": {"name": String}}                     | {"person": {"name": String}}                     | True             |
      | {"person": Bool, optional ["person"]}            | {"person": Bool, optional ["person"]}            | True             |

    Examples: Unequal Object Types
      | objectA                                          | objectB                                          | expectedEquality |
      | {"name": String}                                 | {}                                               | False            |
      | {"name": String}                                 | {"name": Number}                                 | False            |
      | {"name": String}                                 | {"nombre": String}                               | False            |
      | {"name": String}                                 | {"name": String, "age": Number}                  | False            |
      | {"person": {"name": String}}                     | {"person": {"name": String, "age": Number}}      | False            |
      | {"person": {"name": String}}                     | {"person": Bool, optional ["person"]}            | False            |
      | {"person": Bool, optional ["person"]}            | {"person": {"name": String}}                     | False            |
