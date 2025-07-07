# Original Go Test File: cty/convert/unify_test.go
# This feature file covers the test cases for the Unify function,
# which attempts to find a common cty.Type that a list of input types can all convert to.

Feature: Type Unification for Conversion
  This feature describes how a list of cty types is unified into a single common type.
  The process also determines if each input type requires a conversion to reach this unified type.
  If no common type can be found, the unified type is NilType.

  Background:
    Given the cty Type Unification function

  Scenario Outline: Unifying a list of cty types
    # Covers test: TestUnify
    Given an input list of cty types: <InputTypes>
    When the types are unified
    Then the unified cty type should be <UnifiedType>
    And the conversion requirements for each input type should be <ConversionsNeeded>

    Examples: Basic Cases
      | InputTypes             | UnifiedType | ConversionsNeeded   | Description                                      |
      | []                     | NilType     | <nil>               | Empty list unifies to NilType                    |
      | [String]               | String      | [false]             | Single type unifies to itself, no conversion     |
      | [Number]               | Number      | [false]             | Single type unifies to itself, no conversion     |
      | [Number, Number]       | Number      | [false, false]      | Identical types unify, no conversions            |

    Examples: Primitive Unification
      | InputTypes             | UnifiedType | ConversionsNeeded   | Description                                      |
      | [Number, String]       | String      | [true, false]       | Number and String unify to String                |
      | [String, Number]       | String      | [false, true]       | String and Number unify to String                |
      | [Bool, String, Number] | String      | [true, false, true] | Bool, String, Number unify to String             |
      | [Bool, Number]         | NilType     | <nil>               | Bool and Number cannot unify to a common primitive |

    Examples: Object Unification
      | InputTypes                                          | UnifiedType           | ConversionsNeeded | Description                                                                 |
      | [Object({"f":S}), Object({"f":S})]                   | Object({"f":S})       | [false, false]    | Identical objects unify                                                     |
      | [Object({"f":S}), Object({"f":N})]                   | Object({"f":S})       | [false, true]     | Objects with same attr, convertible types, unify attr to String             |
      | [Object({"f":S}), Object({"b":N})]                   | Map(String)           | [true, true]      | Objects with different attrs unify to Map(String)                           |
      | [Object({"f":S}), EmptyObject]                       | Map(String)           | [true, true]      | Object and EmptyObject unify to Map(String)                                 |
      | [Object({"f":B}), Object({"b":N})]                   | NilType               | <nil>             | Objects with different attrs, non-unifiable values -> NilType             |
      | [Object({"f":B}), Object({"f":N})]                   | NilType               | <nil>             | Objects with same attr, non-unifiable types -> NilType                    |

    Examples: Tuple Unification
      | InputTypes                                          | UnifiedType           | ConversionsNeeded | Description                                                                 |
      | [Tuple([S]), Tuple([S])]                             | Tuple([S])            | [false, false]    | Identical tuples unify                                                      |
      | [Tuple([S]), Tuple([N])]                             | Tuple([S])            | [false, true]     | Tuples of same length, convertible elements, unify elements to String       |
      | [Tuple([S]), Tuple([S, N])]                          | List(String)          | [true, true]      | Tuples of different lengths unify to List(String)                           |
      | [Tuple([S]), EmptyTuple]                             | List(String)          | [true, true]      | Tuple and EmptyTuple unify to List(String)                                  |
      | [Tuple([B]), Tuple([N])]                             | NilType               | <nil>             | Tuples with non-unifiable elements -> NilType                               |

    Examples: Nested and Mixed Collection Unification
      | InputTypes                                          | UnifiedType           | ConversionsNeeded   | Description                                                                 |
      | [Tuple([Obj(a=S)]), Tuple([Obj(a=S,b=S)])]           | List(Map(String))     | [true, true]      | Tuple of objects with different attrs -> List(Map(String))                  |
      | [List(Obj(a=S)), Tuple([Obj(a=S,b=S)]), Tuple([Obj(a=S,b=S),Obj(c=S,d=S)])] | List(Map(String)) | [true, true, true]| List of objects and tuples of objects -> List(Map(String))                |
      | [List(Obj(a=S)), List(Map(S)), Tuple([Map(S),Obj(a=S,b=S)])] | List(Map(String)) | [true, false, true] | Mixed list/tuple of object/map -> List(Map(String))                     |
      | [Obj(a=Obj(a=S)), Obj(a=Obj(a=S,b=S))]               | Object(a=Map(String)) | [true, true]      | Nested objects with differing sub-attributes unify inner to Map             |
      | [Obj(a=Obj(a=S),b=Obj(a=S,b=S)), Map(Obj(a=S,b=S))]  | Map(Map(String))      | [true, true]      | Object with nested objects and Map of objects -> Map(Map(String))         |
      | [Obj(a=Obj(a=List(S))),b=Obj(a=Tuple([S]),b=List(S))), Map(Obj(a=List(S),b=List(S)))] | Map(Map(List(String))) | [true, true] | Deeply nested objects/maps with lists/tuples                              |
      | [Obj(a=Obj(a=S),b=Obj(a=S)), Map(Obj(a=S))]          | Map(Object(a=S))      | [true, false]     | Objects unify to Map of common Object type if all attributes match perfectly |
      | [Tuple([Obj(a=S), DynamicType]), List(DynamicType)] | NilType               | <nil>             | Unification to NilType; original test notes FIXME for more complex recursive unification. |


    Examples: DynamicType Unification
      | InputTypes                                          | UnifiedType           | ConversionsNeeded   | Description                                                                 |
      | [DynamicType, Tuple([N])]                           | DynamicType           | [true, true]      | DynamicType with concrete type unifies to DynamicType                       |
      | [DynamicType, Obj(num=N)]                           | DynamicType           | [true, true]      | DynamicType with concrete type unifies to DynamicType                       |
      | [Tuple([N]), DynamicType, Obj(num=N)]                | NilType               | <nil>             | If concrete types cannot unify, DynamicType doesn't bridge them             |
      | [Obj(a=Obj(a=S),b=Obj(a=S)), DynamicType, Map(Obj(a=S))] | Map(DynamicType)  | [true, false, true] | DynamicType can unify with compatible map/object structures             |

    # Note on Type Syntax:
    # S = String, N = Number, B = Bool
    # Object(attrs) = cty.Object(map[string]cty.Type{...})
    # Tuple(elems) = cty.Tuple([]cty.Type{...})
    # List(elemType) = cty.List(elemType)
    # Map(elemType) = cty.Map(elemType)
    # DynamicType = cty.DynamicPseudoType
    # NilType = cty.NilType
    # <nil> for ConversionsNeeded means no conversion functions are returned (because unification failed).
    # ConversionsNeeded is a list of booleans: true if conversion is needed, false otherwise.
