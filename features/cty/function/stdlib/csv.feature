# Original Go Test File: cty/function/stdlib/csv_test.go
# This feature file covers tests for the CSVDecode function in the cty standard library.

Feature: Standard Library CSV Decoding
  This feature describes the behavior of the `csvdecode` function,
  which parses a CSV-formatted string into a cty list of objects.

  Scenario Outline: Decoding a CSV string
    # Covers test: TestCSVDecode
    Given a cty String value representing CSV data:
      """
      <CsvInput>
      """
    When the CSVDecode function is called with this input
    Then the result should be <ExpectedOutput>
    And the error message, if any, should be "<ExpectedErrorMessage>"

    Examples: Valid CSV Data
      | CsvInput                         | ExpectedOutput                                                                                                | ExpectedErrorMessage |
      | "name","size","type"\n"foo","100","tiny"\n"bar","","huge"\n"baz","50","weedy"\n | List(Obj(name="foo",size="100",type="tiny"), Obj(name="bar",size="",type="huge"), Obj(name="baz",size="50",type="weedy")) |                      |
      | "just","header","line"           | EmptyList(Object(just=S,header=S,line=S))                                                                     |                      |
      | "not csv at all"                 | EmptyList(Object("not csv at all"=S))                                                                         |                      |

    Examples: Invalid or Edge Case CSV Data
      | CsvInput          | ExpectedOutput | ExpectedErrorMessage                                  |
      |                   | Dynamic        | "missing header line"                                 |
      | invalid"thing"    | Dynamic        | "CSV parse error on line 1: bare \" in non-quoted-field" |

    Examples: Unknown, Dynamic, or Null Input
      | CsvInput          | ExpectedOutput | ExpectedErrorMessage                |
      | Unknown(String)   | Dynamic        |                                     | # Type depends on unknown header
      | Dynamic           | Dynamic        |                                     |
      | Null(String)      | Dynamic        | "argument must not be null"         |
      | True              | Dynamic        | "string required, but received bool"| # Input not a string

    # Note on Value Syntax:
    # - List(Obj(attr1=val1, attr2=val2), ...) represents a cty.ListVal containing cty.ObjectVal.
    # - EmptyList(ObjectType) represents cty.ListValEmpty(cty.Object(...)).
    # - S indicates cty.String type for object attributes in EmptyList.
    # - Dynamic represents cty.DynamicVal.
    # - Unknown(String) represents cty.UnknownVal(cty.String).
    # - Null(String) represents cty.NullVal(cty.String).
    # - True represents cty.True.
