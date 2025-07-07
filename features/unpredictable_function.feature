# Covers tests in cty/function/unpredictable_test.go

Feature: Unpredictable Function Behavior
  Background:
    Given a Go environment
    And a base function "f" with specification:
      | Field        | Value                                                                 |
      | Parameters   | [{"Name":"fixed", "Type":Bool}]                                       |
      | VarParam     | {"Name":"variadic", "Type":String}                                    |
      | ReturnType   | Dynamic: if 1 arg then Bool, else String                              |
      | Implementation| Returns Null of determined return type                                |
    And an unpredictable function "uf" created from "f"

  Scenario: Predictable function call for baseline
    When I call the base function "f" with arguments [True]
    Then the result should be Null(Bool)
    And no error should occur

  Scenario: Unpredictable function call with argument type error
    When I call the unpredictable function "uf" with arguments ["hello"]
    Then an error should occur

  Scenario Outline: Return type determination for unpredictable function
    Given arguments <arguments> for the unpredictable function "uf"
    When I determine the return type for these arguments
    Then the expected return type should be <expectedReturnType>
    And no error should occur

    Examples:
      | arguments          | expectedReturnType |
      | [True]             | Bool               |
      | [True, "hello"]  | String             |

  Scenario: Unpredictable function call returns unknown value
    When I call the unpredictable function "uf" with arguments [True]
    Then the result should be Unknown(Bool)
    And no error should occur
