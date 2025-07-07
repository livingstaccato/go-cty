# Original Go Test File: cty/tuple_type_test.go
# This feature file covers tests for cty.TupleType equality.

Feature: cty Tuple Type Equality
  This feature describes how cty Tuple types (typeTuple instances)
  are compared for equality using the Equals method.

  Scenario Outline: Comparing two cty Tuple types for equality
    # Covers test: TestTupleTypeEquals
    Given a cty.TupleType LHS defined with element types <LHSElementTypes>
    And a cty.Type RHS defined as a TupleType with element types <RHSElementTypes>
    When LHS.Equals(RHS) is checked
    Then the result should be <ExpectedEquality>

    Examples: Basic Tuple Equality
      | LHSElementTypes    | RHSElementTypes    | ExpectedEquality |
      | []                 | []                 | true             | # Empty tuples are equal
      | []                 | []                 | true             | # EmptyTuple constant vs. Tuple([])
      | [String]           | [String]           | true             |
      | [Tuple([String])]  | [Tuple([String])]  | true             | # Nested tuples

    Examples: Tuple Inequality
      | LHSElementTypes    | RHSElementTypes    | ExpectedEquality |
      | [String]           | []                 | false            | # Different number of elements
      | []                 | [String]           | false            | # Different number of elements
      | [String]           | [Number]           | false            | # Different element type
      | [String]           | [String, Number]   | false            | # Different number of elements
      | [String, Number]   | [String]           | false            | # Different number of elements
      | [String]           | [Tuple([String])]  | false            | # Different element type (String vs Tuple)

    # Note on Syntax:
    # - Element types are represented as a list, e.g., [String, Number].
    # - [] represents an empty list of element types (for an empty tuple).
    # - String, Number, Bool are cty primitive types.
    # - Tuple([Type]) represents a nested tuple type.
