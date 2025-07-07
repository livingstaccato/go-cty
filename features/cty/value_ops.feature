# Original Go Test File: cty/value_ops_test.go
# This feature file covers tests for various operations on cty.Value objects.

Feature: cty.Value Operations
  This feature describes the behavior of various operations that can be
  performed on cty.Value objects, including equality checks, arithmetic,
  logical operations, and collection element access.

  Scenario Outline: Checking cty.Value equality (Value.Equals)
    # Covers test: TestValueEquals
    Given a cty.Value LHS <LHSValue> of type <LHSType>
    And a cty.Value RHS <RHSValue> of type <RHSType>
    When LHS.Equals(RHS) is evaluated
    Then the result should be the cty.Bool <ExpectedEqualityResult>
    And if the result is Unknown(Bool), it should be refined as NotNull
    And marks from LHS and RHS should be combined on the result

    Examples: Primitives (Bool, Number, String)
      | LHSValue        | LHSType | RHSValue        | RHSType | ExpectedEqualityResult |
      | True            | Bool    | True            | Bool    | True                   |
      | True            | Bool    | False           | Bool    | False                  |
      | Number(2)       | Number  | Number(2)       | Number  | True                   |
      | Number(2)       | Number  | Number(2.2)     | Number  | False                  |
      | String("hello") | String  | String("hello") | String  | True                   |
      | String("años")  | String  | String("años")  | String  | True                   | # Unicode Normalization

    Examples: Objects
      | LHSValue        | LHSType | RHSValue        | RHSType | ExpectedEqualityResult |
      | EmptyObjectVal  | Obj     | EmptyObjectVal  | Obj     | True                   |
      | Obj(n=Num(1))   | Obj     | Obj(n=Num(1))   | Obj     | True                   |
      | Obj(n=Num(1))   | Obj     | Obj(n=Num(2))   | Obj     | False                  |
      | Obj(n=Num(1))   | Obj     | Obj(o=Num(1))   | Obj     | False                  | # Different attr name

    Examples: Tuples, Lists, Maps, Sets (Selected Cases)
      | LHSValue        | LHSType | RHSValue        | RHSType | ExpectedEqualityResult |
      | EmptyTupleVal   | Tuple   | EmptyTupleVal   | Tuple   | True                   |
      | Tuple(N(1))     | Tuple   | Tuple(N(1))     | Tuple   | True                   |
      | List(N(1),N(2)) | List(N) | List(N(1),N(2)) | List(N) | True                   |
      | Map(k=N(1))     | Map(N)  | Map(k=N(1))     | Map(N)  | True                   |
      | Set(N(1),N(2))  | Set(N)  | Set(N(2),N(1))  | Set(N)  | True                   | # Order doesn't matter for sets
      | Set(N(1))       | Set(N)  | Set(Unk(N))     | Set(N)  | Unknown(Bool)          |

    Examples: Capsules
      | LHSValue        | LHSType    | RHSValue        | RHSType    | ExpectedEqualityResult |
      | CapsuleA        | CapsuleT1  | CapsuleA        | CapsuleT1  | True                   | # Assumes CapsuleOps.Equals exists
      | CapsuleA        | CapsuleT1  | CapsuleB        | CapsuleT1  | False                  |
      | CapsuleA        | CapsuleT1  | CapsuleC        | CapsuleT2  | False                  | # Different capsule types
      | CapsuleA        | CapsuleT1  | Unknown(CapsuleT1)| CapsuleT1| Unknown(Bool)          |

    Examples: Unknowns, Dynamics, and Nulls
      | LHSValue        | LHSType | RHSValue        | RHSType | ExpectedEqualityResult |
      | Number(2)       | Number  | Unknown(Number) | Number  | Unknown(Bool)          |
      | Number(1)       | Number  | Dynamic         | Dyn     | Unknown(Bool)          |
      | Dynamic         | Dyn     | True            | Bool    | Unknown(Bool)          |
      | Dynamic         | Dyn     | Dynamic         | Dyn     | Unknown(Bool)          |
      | List(S("hi"),Dyn)|List(Dyn)| List(S("hi"),Dyn)|List(Dyn)| Unknown(Bool)          |
      | Null(String)    | String  | Null(Dyn)       | Dyn     | True                   |
      | Unknown(S).NotNull | String | Null(String)   | String  | False                  | # Refined not null vs null

  Scenario Outline: Checking cty.Value raw equality (Value.RawEquals)
    # Covers test: TestValueRawEquals
    # RawEquals is stricter: Unknowns only equal if same instance or both Dynamic. Marks must match.
    Given a cty.Value LHS <LHSValue> of type <LHSType>
    And a cty.Value RHS <RHSValue> of type <RHSType>
    When LHS.RawEquals(RHS) is evaluated
    Then the result should be the Go boolean <ExpectedRawEqualityResult>

    Examples:
      | LHSValue          | LHSType | RHSValue          | RHSType | ExpectedRawEqualityResult |
      | True              | Bool    | True              | Bool    | true                      |
      | Unknown(Number)   | Number  | Unknown(Number)   | Number  | true                      | # Same unknown instance (conceptual for Gherkin)
      | Unknown(Number)   | Number  | Number(1)         | Number  | false                     |
      | Dynamic           | Dyn     | Dynamic           | Dyn     | true                      |
      | MapEmpty(N).Mark(a)| Map(N)  | MapEmpty(N).Mark(a)| Map(N)  | true                      |
      | MapEmpty(N).Mark(a)| Map(N)  | MapEmpty(N)       | Map(N)  | false                     | # Marks differ
      | Unk(N).RefineMin(0)| Number  | Unk(N).RefineMin(1)| Number  | false                     | # Different refinements

  Scenario Outline: cty.Value arithmetic operations (Add, Subtract, Multiply, Divide, Modulo, Negate, Absolute)
    # Covers test: TestValueAdd, TestValueSubtract, TestValueMultiply, TestValueDivide, TestValueModulo, TestValueNegate, TestValueAbsolute
    Given a cty.Value <Operand1>
    And an optional cty.Value <Operand2> for binary operations
    When the <Operation> is performed
    Then the result should be <ExpectedResult>
    And marks should be propagated/combined appropriately

    Examples: Add
      | Operand1                      | Operand2        | Operation | ExpectedResult                         |
      | Number(1)                     | Number(2)       | Add       | Number(3)                              |
      | Number(1)                     | Unknown(Number) | Add       | Unknown(Number).NotNull                |
      | Unk(N).RefineMinBound(2,true) | Unk(N).RefineMinBound(2,true) | Add | Unknown(N).NotNull.RefineMinBound(4,true) |
      | Num(0).Mark(1)                | Num(0).Mark(2)  | Add       | Num(0).WithMarks(1,2)                  |

    Examples: Subtract
      | Operand1        | Operand2        | Operation | ExpectedResult                         |
      | Number(1)       | Number(2)       | Subtract  | Number(-1)                             |
      | Unk(N).Range(1,true,2,false) | Unk(N).RefineMinBound(2,false) | Subtract | Unknown(N).NotNull.RefineMaxBound(0,true)|

    Examples: Negate (Unary)
      | Operand1        | Operand2 | Operation | ExpectedResult      |
      | Number(1)       |          | Negate    | Number(-1)          |
      | Unknown(Number) |          | Negate    | Unknown(N).NotNull  |

    Examples: Absolute (Unary)
      | Operand1        | Operand2 | Operation | ExpectedResult      |
      | Number(-1)      |          | Absolute  | Number(1)           |
      | Unknown(Number) |          | Absolute  | Unknown(N).NotNull.RefineMinBound(0,true) |

  Scenario Outline: cty.Value attribute and element access (GetAttr, Index, HasIndex)
    # Covers test: TestValueGetAttr, TestValueIndex, TestValueHasIndex
    Given a cty.Value Collection <Collection>
    And a key/attribute name/index <Key>
    When <AccessorMethod> is used with <Key> on <Collection>
    Then the result should be <ExpectedResult>
    And marks should be propagated

    Examples: GetAttr
      | Collection            | Key          | AccessorMethod | ExpectedResult   |
      | Obj(g=S("h"))         | "greeting"   | GetAttr        | String("h")      | # Assumes "g" is normalized to "greeting" or vice-versa
      | Obj(g=S("h")).Mark(1) | "greeting"   | GetAttr        | String("h").Mark(1)|
      | Dynamic               | "hello"      | GetAttr        | Dynamic          |

    Examples: Index
      | Collection            | Key         | AccessorMethod | ExpectedResult   |
      | List(S("h"))          | Number(0)   | Index          | String("h")      |
      | List(S("h")).Mark(1)  | Number(0)   | Index          | String("h").Mark(1)|
      | List(S("h"))          | Num(0).Mark(1)| Index        | String("h").Mark(1)|
      | Map(g=S("h"))         | String("g") | Index          | String("h")      |
      | Unknown(List(S))      | Number(0)   | Index          | Unknown(String)  |
      | Dynamic               | Number(0)   | Index          | Dynamic          |

    Examples: HasIndex
      | Collection            | Key         | AccessorMethod | ExpectedResult |
      | List(S("h"))          | Number(0)   | HasIndex       | True           |
      | List(S("h"))          | Number(1)   | HasIndex       | False          |
      | List(S("h")).Mark(1)  | Number(0)   | HasIndex       | True.Mark(1)   |
      | Map(g=S("h"))         | String("g") | HasIndex       | True           |
      | Unknown(Map(S))       | String("g") | HasIndex       | Unknown(B).NotNull |

  Scenario Outline: Value Logical Not (Not)
    # Covers test: TestValueNot
    Given a cty.Value <Operand1> (Bool)
    When <Operand1> Not is performed
    Then the result should be cty.Bool <ExpectedResult>
    And marks should be propagated

    Examples:
      | Operand1        | ExpectedResult         |
      | True            | False                  |
      | False           | True                   |
      | Unknown(Bool)   | Unknown(Bool).NotNull  |
      | Dynamic         | Unknown(Bool).NotNull  |
      | True.Mark(1)    | False.Mark(1)          |

  Scenario Outline: Value Logical And (And)
    # Covers test: TestValueAnd
    Given a cty.Value LHS <LHSValue> (Bool)
    And a cty.Value RHS <RHSValue> (Bool)
    When <LHSValue> And <RHSValue> is performed
    Then the result should be cty.Bool <ExpectedResult>
    And marks should be propagated/combined

    Examples:
      | LHSValue      | RHSValue      | ExpectedResult         |
      | False         | False         | False                  |
      | False         | True          | False                  |
      | True          | False         | False                  |
      | True          | True          | True                   |
      | Unknown(Bool) | Unknown(Bool) | Unknown(Bool).NotNull  |
      | True          | Unknown(Bool) | Unknown(Bool).NotNull  |
      | False         | Unknown(Bool) | False                  | # Short-circuit
      | Dynamic       | False         | False                  | # Short-circuit
      | True.Mark(1)  | True.Mark(1)  | True.Mark(1)           |

  Scenario Outline: Value Logical Or (Or)
    # Covers test: TestValueOr
    Given a cty.Value LHS <LHSValue> (Bool)
    And a cty.Value RHS <RHSValue> (Bool)
    When <LHSValue> Or <RHSValue> is performed
    Then the result should be cty.Bool <ExpectedResult>
    And marks should be propagated/combined

    Examples:
      | LHSValue      | RHSValue      | ExpectedResult         |
      | False         | False         | False                  |
      | False         | True          | True                   |
      | True          | False         | True                   |
      | True          | True          | True                   |
      | Unknown(Bool) | Unknown(Bool) | Unknown(Bool).NotNull  |
      | True          | Unknown(Bool) | True                   | # Short-circuit
      | False         | Unknown(Bool) | Unknown(Bool).NotNull  |
      | Dynamic       | True          | True                   | # Short-circuit
      | True.Mark(1)  | False.Mark(1) | True.Mark(1)           |

  Scenario Outline: Value Less Than Comparison (LessThan)
    # Covers test: TestLessThan
    Given a cty.Value LHS <LHSValue> (Number)
    And a cty.Value RHS <RHSValue> (Number)
    When <LHSValue> LessThan <RHSValue> is performed
    Then the result should be cty.Bool <ExpectedResult>
    And marks should be propagated/combined

    Examples:
      | LHSValue                      | RHSValue        | ExpectedResult         |
      | Number(0)                     | Number(1)       | True                   |
      | Number(1)                     | Number(0)       | False                  |
      | Number(0)                     | Number(0)       | False                  |
      | Unknown(N)                    | Unknown(N)      | Unknown(Bool).NotNull  |
      | Unk(N).RefineMaxBound(0,true) | Number(1)       | True                   | # Deduced
      | Num(0).Mark(1)                | Num(1).Mark(1)  | True.Mark(1)           |

  Scenario Outline: Value Greater Than Comparison (GreaterThan)
    # Covers test: TestGreaterThan
    Given a cty.Value LHS <LHSValue> (Number)
    And a cty.Value RHS <RHSValue> (Number)
    When <LHSValue> GreaterThan <RHSValue> is performed
    Then the result should be cty.Bool <ExpectedResult>
    And marks should be propagated/combined

    Examples:
      | LHSValue                       | RHSValue        | ExpectedResult         |
      | Number(1)                      | Number(0)       | True                   |
      | Number(0)                      | Number(1)       | False                  |
      | Unk(N).RefineMinBound(2,true)  | Number(1)       | True                   | # Deduced

  Scenario Outline: Value Less Than Or Equal Comparison (LessThanOrEqualTo)
    # Covers test: TestLessThanOrEqualTo
    Given a cty.Value LHS <LHSValue> (Number)
    And a cty.Value RHS <RHSValue> (Number)
    When <LHSValue> LessThanOrEqualTo <RHSValue> is performed
    Then the result should be cty.Bool <ExpectedResult>
    And marks should be propagated/combined

    Examples:
      | LHSValue        | RHSValue        | ExpectedResult         |
      | Number(0)       | Number(1)       | True                   |
      | Number(0)       | Number(0)       | True                   |
      | Number(1)       | Number(0)       | False                  |
      | Unknown(N)      | Unknown(N)      | Unknown(Bool).NotNull  |

  Scenario Outline: Value Greater Than Or Equal Comparison (GreaterThanOrEqualTo)
    # Covers test: TestGreaterThanOrEqualTo
    Given a cty.Value LHS <LHSValue> (Number)
    And a cty.Value RHS <RHSValue> (Number)
    When <LHSValue> GreaterThanOrEqualTo <RHSValue> is performed
    Then the result should be cty.Bool <ExpectedResult>
    And marks should be propagated/combined

    Examples:
      | LHSValue        | RHSValue        | ExpectedResult         |
      | Number(1)       | Number(0)       | True                   |
      | Number(0)       | Number(0)       | True                   |
      | Number(0)       | Number(1)       | False                  |
      | Unknown(N)      | Unknown(N)      | Unknown(Bool).NotNull  |

  Scenario Outline: Value GoString representation (GoString)
    # Covers test: TestValueGoString
    Given a cty.Value <ValueInstance>
    When its GoString() representation is obtained
    Then the result should be the string "<ExpectedGoString>"

    Examples:
      | ValueInstance                                  | ExpectedGoString                                                                     |
      | NullVal(DynamicType)                           | "cty.NullVal(cty.DynamicPseudoType)"                                                 |
      | NullVal(String)                                | "cty.NullVal(cty.String)"                                                            |
      | NullVal(Tuple([S,B]))                          | "cty.NullVal(cty.Tuple([]cty.Type{cty.String, cty.Bool}))"                           |
      | UnknownVal(DynamicType)                        | "cty.DynamicVal"                                                                     |
      | UnknownVal(S)                                  | "cty.UnknownVal(cty.String)"                                                         |
      | UnknownVal(Tuple([S,B]))                       | "cty.UnknownVal(cty.Tuple([]cty.Type{cty.String, cty.Bool}))"                        |
      | UnknownVal(S).RefineNotNull()                  | "cty.UnknownVal(cty.String).RefineNotNull()"                                         |
      | UnknownVal(S).Refine().NotNull().StringPrefix("a-").NewValue() | "cty.UnknownVal(cty.String).Refine().NotNull().StringPrefixFull(\"a-\").NewValue()" |
      | UnknownVal(S).Refine().NotNull().StringPrefix("foo").NewValue() | "cty.UnknownVal(cty.String).Refine().NotNull().StringPrefixFull(\"fo\").NewValue()" | # Truncated
      | UnknownVal(N).Refine().NumberRangeInclusive(Num(0), Unk(N)).NewValue() | "cty.UnknownVal(cty.Number).Refine().NumberLowerBound(cty.NumberIntVal(0), true).NewValue()" |
      | UnknownVal(N).Refine().NumberRangeInclusive(Num(0), Num(1)).NewValue() | "cty.UnknownVal(cty.Number).Refine().NumberLowerBound(cty.NumberIntVal(0), true).NumberUpperBound(cty.NumberIntVal(1), true).NewValue()" |
      | StringVal("")                                  | "cty.StringVal(\"\")"                                                                |
      | StringVal("hello")                             | "cty.StringVal(\"hello\")"                                                           |
      | Num(0)                                         | "cty.NumberIntVal(0)"                                                                |
      | Num(1.2)                                       | "cty.NumberFloatVal(1.2)"                                                            |
      | Num(1.0)                                       | "cty.NumberIntVal(1)"                                                                | # Whole float
      | Num("3.14159265358979323846264338327950288419716939937510582097494459") | "cty.MustParseNumberVal(\"3.14159265358979323846264338327950288419716939937510582097494459\")" |
      | True                                           | "cty.True"                                                                           |
      | False                                          | "cty.False"                                                                          |
      | EmptyList(String)                              | "cty.ListValEmpty(cty.String)"                                                       |
      | List(True)                                     | "cty.ListVal([]cty.Value{cty.True})"                                                 |
      | EmptySet(String)                               | "cty.SetValEmpty(cty.String)"                                                        |
      | Set(True)                                      | "cty.SetVal([]cty.Value{cty.True})"                                                  |
      | EmptyTupleVal                                  | "cty.EmptyTupleVal"                                                                  |
      | Tuple(True)                                    | "cty.TupleVal([]cty.Value{cty.True})"                                                |
      | EmptyMap(String)                               | "cty.MapValEmpty(cty.String)"                                                        |
      | Map("boop"=True)                               | "cty.MapVal(map[string]cty.Value{\"boop\":cty.True})"                               | # Keys sorted
      | EmptyObjectVal                                 | "cty.EmptyObjectVal"                                                                 |
      | Obj("foo"=True)                                | "cty.ObjectVal(map[string]cty.Value{\"foo\":cty.True})"                             | # Keys sorted

  Scenario Outline: Checking if a value has a wholly known type (HasWhollyKnownType)
    # Covers test: TestHasWhollyKnownType
    Given a cty.Value <ValueInstance>
    When HasWhollyKnownType() is checked on <ValueInstance>
    Then the result should be <ExpectedKnownTypeResult>

    Examples:
      | ValueInstance                                           | ExpectedKnownTypeResult |
      | Dynamic                                                 | false                   |
      | Obj(dyn=Dynamic)                                        | false                   |
      | Null(Obj(dyn=DynamicType))                              | true                    |
      | Tuple(S("a"), Null(DynamicType))                        | true                    |
      | List(Obj(null=Null(DynamicType)))                       | true                    |
      | List(Null(Obj(dyn=DynamicType)))                        | true                    |
      | Obj(tuple=Tuple(S("a"),Null(DynamicType)))              | true                    |
      | Obj(tuple=Tuple(Obj(dyn=Dynamic)))                      | false                   |
      | StringVal("known")                                      | true                    |
      | List(StringVal("known"))                                | true                    |

  Scenario Outline: Checking set element presence (HasElement)
    # Covers test: TestHasElement
    Given a cty.SetVal <SetInput>
    And a cty.Value <ElementToFind>
    When <SetInput>.HasElement(<ElementToFind>) is evaluated
    Then the result should be <ExpectedPresenceResult>

    Examples:
      | SetInput                      | ElementToFind  | ExpectedPresenceResult |
      | Set(S("h"))                   | String("h")    | True                   |
      | Set(S("h"), Unk(S))           | String("w")    | Unknown(B).NotNull     |
      | Set(Unk(S))                   | String("w")    | Unknown(B).NotNull     |
      | Set(DynVal)                   | Null(DynVal)   | Unknown(B).NotNull     |

  Scenario: Float copy assurance (AsBigFloat)
    # Covers test: TestFloatCopy
    Given a cty.NumberFloatVal "original_float_val" (e.g., 1.9)
    When its GoString representation is stored as "original_gos_string"
    And its *big.Float representation is obtained using AsBigFloat() and stored as "big_float_ref"
    And "big_float_ref" is modified (e.g., SetInt64(1))
    Then the GoString representation of "original_float_val" should still be "original_gos_string" (i.e., original value unchanged)

    # Note on Value/Type Syntax:
    # - Values: String("h") or S("h"), Number(N) or Num(N), True/False or T/F, List(...), Map(k=V), Obj(k=V), Set(...), Tuple(...)
    # - Empty collections: EmptyList(T), EmptyMap(T), EmptySet(T), EmptyTupleVal, EmptyObjectVal
    # - Unknowns/Dynamics: Unknown(Type) or Unk(Type), Dynamic or Dyn
    # - Nulls: Null(Type)
    # - Marks: .Mark(mark_id), .WithMarks(id1,id2)
    # - Capsule values: CapsuleA, CapsuleB, CapsuleC (representing specific test capsule instances)
    # - Capsule types: CapsuleT1, CapsuleT2
    # - Refinements: .NotNull, .RefineMinBound(val,incl), .RefineMaxBound(val,incl), .RefineRange(min,max), .RefinePrefix(str)
    # - For GoString, the full cty package syntax is expected.
    # - Some complex examples are simplified for Gherkin readability. Detailed logic is in the Go tests.
