import Base
import ./helpers.bend as H

def equal_same() -> {U32.is_eq(255,255) == Nat.is_eq(U32.to_nat(255),U32.to_nat(255)) : Bool}: H.equality(255,255)
def equal_different() -> {U32.is_eq(255,256) == Nat.is_eq(U32.to_nat(255),U32.to_nat(256)) : Bool}: H.equality(255,256)
def reserve_low() -> {True{} == U32.is_lt(0,4294967295) : Bool}: H.reserve_below_max(0,1,{==})
def reserve_carry() -> {True{} == U32.is_lt(255,4294967295) : Bool}: H.reserve_below_max(255,256,{==})
def reserve_high_word() -> {True{} == U32.is_lt(4294967294,4294967295) : Bool}: H.reserve_below_max(4294967294,4294967295,{==})
def zero_guard() -> {True{} == Bool.not(Nat.is_ge(U32.to_nat(0),U32.to_nat(4294967295))) : Bool}: {==}
def bump_low() -> {True{} == U32.is_lt(0,4294967295) : Bool}: H.bump_below_max(0,{==})
def bump_successor() -> {U32.to_nat(U32.add(7,1)) == 1n+U32.to_nat(7) : Nat}: H.bump_increment(7,{==})
def wrap_excluded() -> {U32.is_lt(4294967295,4294967295) == False{} : Bool}: {==}
