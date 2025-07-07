# Covers tests in cty/type_conform_test.go

Feature: Cty Type Conformance Testing
  Background:
    Given a Go environment

  Scenario Outline: Test if a given cty.Type conforms to a receiver cty.Type
    Given a receiver cty.Type <receiverType>
    And a given cty.Type <givenType>
    When I test if the given type conforms to the receiver type
    Then the result should be <conforms> (no errors if true, errors if false)

    Examples: Primitive Types
      | receiverType | givenType | conforms |
      | Number       | Number    | True     |
      | Number       | String    | False    |
      | Number       | Dynamic   | True     | # Dynamic conforms to any concrete type
      | Dynamic      | Dynamic   | True     |
      | Dynamic      | Number    | False    | # Concrete type does not conform to Dynamic

    Examples: List Types
      | receiverType | givenType    | conforms |
      | List(Number) | List(Number) | True     |
      | List(Number) | Map(Number)  | False    |
      | List(Number) | List(Dynamic)| True     |
      | List(Number) | List(String) | False    |

    Examples: Map Types
      | receiverType | givenType   | conforms |
      | Map(Number)  | Map(Number) | True     |
      | Map(Number)  | Set(Number) | False    |
      | List(Number) | Map(Dynamic)| False    | # Receiver is List, Given is Map
      | Map(Number)  | Map(Dynamic)| True     |
      | Map(Number)  | Map(String) | False    |

    Examples: Set Types
      | receiverType | givenType    | conforms |
      | Set(Number)  | Set(Number)  | True     |
      | Set(Number)  | List(Number) | False    |
      | Set(Number)  | List(Dynamic)| False    |
      | Set(Number)  | Set(Dynamic) | True     |
      | Set(Number)  | Set(String)  | False    |

    Examples: Object Types
      | receiverType                     | givenType                        | conforms |
      | EmptyObject                      | EmptyObject                      | True     |
      | EmptyObject                      | Object({"name":S})               | False    |
      | Object({"name":S})               | EmptyObject                      | False    |
      | Object({"name":S})               | Object({"name":S})               | True     |
      | Object({"name":S})               | Object({"gnome":S})              | False    | # Different attribute name
      | Object({"name":N})               | Object({"name":S})               | False    | # Different attribute type
      | Object({"name":N})               | Object({"name":S, "number":N})   | False    | # Given has extra attribute
      | Object({"name":N}, optional ["name"]) | Object({"name":N})               | True     |
      | Object({"name":N}, optional ["name"]) | EmptyObject                      | False    | # Optionality not considered for conformance here

    Examples: Tuple Types
      | receiverType           | givenType              | conforms |
      | EmptyTuple             | EmptyTuple             | True     |
      | EmptyTuple             | Tuple([S])             | False    |
      | Tuple([S])             | EmptyTuple             | False    |
      | Tuple([S])             | Tuple([S])             | True     |
      | Tuple([S])             | Tuple([N])             | False    | # Different element type
      | Tuple([S,N])           | Tuple([S,N])           | True     |
      | Tuple([S])             | Tuple([S,N])           | False    | # Different length
      | Tuple([S,N])           | Tuple([S])             | False    | # Different length
