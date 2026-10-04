import Base
import ./contextual.bend as C
import ./invariants.bend as I
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

# Active premise for the narrowed empty-world specialization.
def active_premise() -> {True{} == S.admissible(1n,T.World{0n,1n,[],[]}) : Bool}:
  {==}

def active_any() -> {[] == S.query(T.World{0n,1n,[],[]},T.Any{}) : List<&2,T.Row>}:
  C.empty_world(1n,0n,1n,[],T.Any{})
def active_present() -> {[] == S.query(T.World{0n,1n,[],[]},T.Present{}) : List<&2,T.Row>}:
  C.empty_world(1n,0n,1n,[],T.Present{})
def active_absent() -> {[] == S.query(T.World{0n,1n,[],[]},T.Absent{}) : List<&2,T.Row>}:
  C.empty_world(1n,0n,1n,[],T.Absent{})

# Nonempty, physically unsorted contextual invariant witness.
def unsorted_tail_valid() -> {True{} == S.rows_valid([T.Row{1n,10n,False{}},T.Row{0n,5n,True{}}],[T.Row{1n,10n,False{}},T.Row{0n,5n,True{}}],3n) : Bool}:
  I.valid_tail(2n,20n,True{},[T.Row{1n,10n,False{}},T.Row{0n,5n,True{}}],3n,{==})
