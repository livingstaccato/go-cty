# Original Go Test File: cty/function/unpredictable_test.go
# This feature file covers tests for the Unpredictable function wrapper.

Feature: Unpredictable Function Wrapper
  This feature describes the behavior of the `Unpredictable` function wrapper,
  which modifies a given cty Function to always return an Unknown value of its
  determined return type, even if all arguments are known. This is useful for
  functions with side effects or non-deterministic results (e.g., random UUID, current timestamp).

  Background:
    Given an original cty Function "F_orig" defined with:
      - Positional parameter "fixed" of type Bool
      - Variadic parameter "variadic" of type String
      - Type logic: returns Bool if only "fixed" is provided, otherwise returns String
      - Implementation: returns NullVal of the determined type (for testing original behavior)
    And an "Unpredictable Function" "F_unpred" is created by wrapping "F_orig"

  Scenario: Calling the Unpredictable Function
    # Covers test: TestUnpredictable (call section)
    When "F_unpred" is called with arguments [True]
    Then the result should be an Unknown cty.Value of type Bool

  Scenario: Return type determination of the Unpredictable Function
    # Covers test: TestUnpredictable (type check sections)
    When the return type of "F_unpred" is requested for arguments [True]
    Then the determined type should be Bool
    When the return type of "F_unpred" is requested for arguments [True, String("hello")]
    Then the determined type should be String

  Scenario: Argument type error with Unpredictable Function
    # Covers test: TestUnpredictable (argument type error section)
    When "F_unpred" is called with arguments [String("hello")]
    Then an error should occur due to argument type mismatch for parameter "fixed"

  Scenario: Original function behavior (for comparison)
    # Covers test: TestUnpredictable (predVal check)
    When the original function "F_orig" is called with arguments [True]
    Then the result should be a known cty.Value Null of type Bool

  Scenario: Mark propagation with Unpredictable Function
    # Covers implied mark handling for robust porting
    Given the "Unpredictable Function" "F_unpred" as defined in the background
    When "F_unpred" is called with arguments [True.Mark("input_mark")]
    Then the result should be an Unknown cty.Value of type Bool
    And the result should have marks ["input_mark"]

    # Note on Value/Type Syntax:
    # - Bool, String are cty types.
    # - True, String("hello"), True.Mark("input_mark") are cty values.
    # - Unknown cty.Value of type X means cty.UnknownVal(cty.X).
    # - Null cty.Value of type X means cty.NullVal(cty.X).
