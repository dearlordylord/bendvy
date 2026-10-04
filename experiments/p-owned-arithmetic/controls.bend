import Base
import ./structural.bend as A

def clear() -> {U32.to_nat(U32.add(2,1)) == 3n : Nat}: {==}
def carry() -> {U32.to_nat(U32.add(7,1)) == 8n : Nat}: {==}
def wrap() -> {U32.add(4294967295,1) == 0 : U32}: {==}
def symbolic(+value: U32) -> {U32.add(value,1) == U32.inc(value) : U32}: A.runtime_add_one(value)
def equal_low() -> {Word.cmp(2n,WCon{True{},WCon{False{},WNil{}}},WCon{True{},WCon{False{},WNil{}}}) == EQ{} : Cmp}: {==}
