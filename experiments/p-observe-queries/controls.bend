import Base
import ./contextual.bend as C
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
