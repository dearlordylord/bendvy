import Base
import ./safety.bend as V
import ./transport.bend as P
import ../p-observe-schedule/relation.bend as R
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

def steps() -> List<&2,T.Step>:
  [T.Bump{0n},T.Reserve{4n},T.Publish{T.Handle{7n,1n},T.Insert{}},T.Barrier{},T.Bump{1n}]
def world() -> T.World:
  T.World{7n,1n,[T.Row{0n,2n,False{}}],[]}
def original_safe() -> {True{} == S.run_safe(steps(),4n,world()) : Bool}:
  {==}
def transported() -> {True{} == V.ModelSafe(steps(),4n,world()) : Bool}:
  P.from_independent(steps(),4n,world(),original_safe())

# Slots alone do not establish physical admissibility.
def duplicate_slots() -> R.Slots(1n,0n,[T.Row{0n,2n,False{}}],[T.Row{0n,2n,False{}},T.Row{0n,2n,False{}}]):
  ({==},Unit{})
def duplicate_rejected() -> {False{} == S.admissible(1n,T.World{7n,1n,[T.Row{0n,2n,False{}},T.Row{0n,2n,False{}}],[]}) : Bool}:
  {==}
def frontier_rejected() -> {False{} == S.run_safe([],0n,world()) : Bool}:
  {==}
