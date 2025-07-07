# Original Go Test File: cty/function/stdlib/general_test.go
# This feature file covers tests for general utility functions
# like Equal and Coalesce in the cty standard library.

Feature: Standard Library General Utility Functions
  This feature describes the behavior of general utility functions
  such as value equality checking and coalescing.

  Scenario Outline: Checking cty value equality (Equal function)
    # Covers test: TestEqual
    Given a cty value <A>
    And another cty value <B>
    When the Equal function is called with <A> and <B>
    Then the result should be the cty Bool <ExpectedResult>
    And if <ExpectedResult> is Unknown(Bool), it should be refined as not null

    Examples: Basic Comparisons
      | A                 | B                 | ExpectedResult |
      | Number(1)         | Number(2)         | False          |
      | Number(2)         | Number(2)         | True           |
      | Null(Number)      | Null(Number)      | True           |
      | Number(2)         | Null(Number)      | False          |

    Examples: With Unknown and Dynamic
      | A                 | B                 | ExpectedResult |
      | Number(1)         | Unknown(Number)   | Unknown(Bool)  |
      | Unknown(Number)   | Unknown(Number)   | Unknown(Bool)  |
      | Number(1)         | Dynamic           | Unknown(Bool)  |
      | Dynamic           | Dynamic           | Unknown(Bool)  |

    Examples: With Marks
      | A                 | B                 | ExpectedResult        |
      | Number(2).Mark(m1)| Number(2).Mark(m2)| True.WithMarks(m1,m2) |
      | Number(1).Mark(m1)| Number(2).Mark(m2)| False.WithMarks(m1,m2)|
      | Number(1).Mark(m) | Unknown(Number)   | Unknown(Bool).Mark(m) |


  Scenario Outline: Coalescing a list of cty values (Coalesce function)
    # Covers test: TestCoalesce
    Given a list of cty values <InputValues>
    When the Coalesce function is called with these values
    Then the result should be <ExpectedResult>
    And if <ExpectedResult> is an Unknown value, it should be refined as not null (unless it's DynamicVal)
    And an error message, if any, should be "<ExpectedErrorMessage>"

    Examples: Successful Coalescing
      | InputValues                         | ExpectedResult  | ExpectedErrorMessage | Description                                         |
      | [True]                              | True            |                      | Single value returns itself                         |
      | [Null(Bool), True]                  | True            |                      | Skips null, returns first non-null                  |
      | [Null(Bool), False]                 | False           |                      | Skips null, returns first non-null                  |
      | [Null(Bool), False, String("hello")]| String("false") |                      | Unifies to string, returns "false"                  |
      | [True, Unknown(Bool)]               | True            |                      | Short-circuits before unknown                       |
      | [Unknown(Bool), True]               | Unknown(Bool)   |                      | Depends on unknown, result is Unknown(Bool)         |
      | [Unknown(Bool), String("hello")]    | Unknown(String) |                      | Depends on unknown, unifies to String               |
      | [Dynamic, True]                     | Unknown(Bool)   |                      | Dynamic followed by True, result Unknown(Bool)      |
      | [Dynamic]                           | Dynamic         |                      | Single Dynamic value returns Dynamic                |
      | [Null(Bool).Mark(m), True.Mark(n)]  | True.WithMarks(m,n) |                    | Marks from considered values are combined       |

    Examples: Error Cases
      | InputValues                         | ExpectedResult  | ExpectedErrorMessage          | Description                |
      | [Null(Bool), Null(String)]         |                 | "all arguments are null"      | All arguments null         |


    # Note on Value Syntax:
    # - Number(1), True, False, String("hello")
    # - Null(Type), Unknown(Type), Dynamic
    # - .Mark(m), .WithMarks(m1,m2) for marked values.
