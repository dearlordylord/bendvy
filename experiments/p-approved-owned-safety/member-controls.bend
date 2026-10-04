import Base
import ./member-safety.bend as P
import ../t11-replacement/types.bend as T

def actual_member() -> {True{} == P.BumpSafe(P.Overflow{},[T.Row{0n,2n,False{}},T.Row{1n,4n,True{}}],1n) : Bool}:
  P.from_step(7n,2n,[T.Row{0n,2n,False{}},T.Row{1n,4n,True{}}],[],1n,{==},{==})
def outside_target() -> {True{} == P.BumpSafe(P.Overflow{},[T.Row{0n,2n,False{}}],9n) : Bool}:
  P.from_step(7n,1n,[T.Row{0n,2n,False{}}],[],9n,{==},{==})
# First matching row is safe, but a duplicated later matching row is not.
def duplicate_is_unsafe() -> {False{} == P.BumpSafe(P.Below{5n},[T.Row{0n,2n,False{}},T.Row{0n,9n,True{}}],0n) : Bool}:
  {==}
