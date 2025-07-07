# Original Go Test File: cty/function/stdlib/bytes_test.go
# This feature file covers tests for 'bytes' capsule type utility functions
# in the cty standard library.

Feature: Standard Library Bytes Functions
  This feature describes the behavior of utility functions for the
  cty 'bytes' capsule type, which encapsulates a Go byte slice.

  Scenario Outline: Bytes Length
    # Covers test: TestBytesLen
    Given a 'bytes' capsule value created from the Go byte slice <InputBytesSlice>
    When the BytesLen function is called with this capsule
    Then the result should be the cty Number <ExpectedLength>

    Examples:
      | InputBytesSlice | ExpectedLength |
      | []              | 0              |
      | ['a']           | 1              |
      | ['a', 'b', 'c'] | 3              |

  Scenario Outline: Bytes Slice
    # Covers test: TestBytesSlice
    Given a 'bytes' capsule value "sourceBytes" created from the Go byte slice <InputBytesSlice>
    And a cty Number "offset" with value <Offset>
    And a cty Number "length" with value <Length>
    When the BytesSlice function is called with "sourceBytes", "offset", and "length"
    Then the result should be a 'bytes' capsule value encapsulating the Go byte slice <ExpectedBytesSlice>

    Examples:
      | InputBytesSlice | Offset | Length | ExpectedBytesSlice |
      | []              | 0      | 0      | []                 |
      | ['a']           | 0      | 1      | ['a']              |
      | ['a', 'b', 'c'] | 0      | 2      | ['a', 'b']         |
      | ['a', 'b', 'c'] | 1      | 2      | ['b', 'c']         |
      | ['a', 'b', 'c'] | 0      | 3      | ['a', 'b', 'c']    |

    # Note on Bytes Slice Syntax:
    # - InputBytesSlice and ExpectedBytesSlice are represented as lists of characters
    #   for readability, e.g., ['a', 'b'] corresponds to []byte{'a', 'b'}.
    # - The 'bytes' capsule type is assumed to be cty.Capsule("bytes", reflect.TypeOf([]byte(nil))).
