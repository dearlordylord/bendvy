import Base
import ./LAWS.bend as L
import ./PROOF.bend as P
import ../t11-replacement/spec.bend as S
import ../t11-replacement/bridge.bend as B

def literal_true_domain() -> {U32.is_lt(255,4294967295) == True{} : Bool}: {==}
def exact_true_instance() -> S.When(U32.is_lt(255,4294967295),{U32.to_nat(B.increment(255)) == 1n+U32.to_nat(255) : Nat}): {==}
def proved_zero() -> S.When(U32.is_lt(0,4294967295),{U32.to_nat(B.increment(0)) == 1n+U32.to_nat(0) : Nat}): L.u32_increment_no_wrap(0)
def proved_carry() -> S.When(U32.is_lt(255,4294967295),{U32.to_nat(B.increment(255)) == 1n+U32.to_nat(255) : Nat}): L.u32_increment_no_wrap(255)
def wrap_guard_false() -> {U32.is_lt(4294967295,4294967295) == False{} : Bool}: {==}
def excluded_wrap() -> Unit: L.u32_increment_no_wrap(4294967295)
def actual_wrap() -> {B.increment(4294967295) == 0 : U32}: {==}
