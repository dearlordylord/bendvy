import Base
import ./LAWS.bend as Laws
import ./helpers.bend as H
import ./invariants.bend as I
import ./contextual.bend as C
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Generalization needed for slot/fuel induction. This exact isolated obligation
# allows arbitrary tail rows, but requires the inserted key inside the interval
# and absent from tail; it adds no malformed-world or allocator policy.
def insert_interval(+fuel: Nat, +slot: Nat, +id: Nat, +value: Nat, +tag: Bool,
  +tail: List<&2,T.Row>, +selection: T.Selection,
  lo: {True{} == Nat.is_le(slot,id) : Bool},
  hi: {True{} == Nat.is_lt(id,Nat.add(slot,fuel)) : Bool},
  hz: {0n == S.count(tail,id) : Nat})
  -> {M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.enumerate_rows(fuel,slot,tail,selection))
    == S.enumerate_rows(fuel,slot,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>}:
  match fuel:
    case 0n:
      hi_slot = Equal.trans(Bool,True{},Nat.is_lt(id,Nat.add(slot,0n)),Nat.is_lt(id,slot),hi,
        Equal.cong(Nat,Bool,n => Nat.is_lt(id,n),Nat.add(slot,0n),slot,
          Equal.sym(Nat,slot,Nat.add(slot,0n),I.add_zero(slot))))
      Empty.absurd({M.include(M.accepts(selection,tag),T.Row{id,value,tag},[]) == [] : List<&2,T.Row>},
        I.le_lt_cycle(slot,id,lo,hi_slot))
    case 1n+rest: ?interval_ordered_insertion

# Concrete [0,next) specialization supplied to the list induction.
def insert_enumeration(+next: Nat, +id: Nat, +value: Nat, +tag: Bool,
  +tail: List<&2,T.Row>, +selection: T.Selection,
  hi: {True{} == Nat.is_lt(id,next) : Bool}, hz: {0n == S.count(tail,id) : Nat})
  -> {M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.enumerate_rows(next,0n,tail,selection))
    == S.enumerate_rows(next,0n,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>}:
  insert_interval(next,0n,id,value,tag,tail,selection,I.zero_le(id),hi,hz)

# The original domain is retained; the changed-all tail premise is now derived.
def rows_complete(+rows: List<&2,T.Row>, +next: Nat, +selection: T.Selection,
  +h: {True{} == S.rows_valid(rows,rows,next) : Bool})
  -> {M.query_rows(selection,rows) == S.enumerate_rows(next,0n,rows,selection) : List<&2,T.Row>}:
  match rows:
    case Nil{}: H.enumerate_empty(next,0n,selection)
    case Con{T.Row{+id,+value,+tag},+tail}:
      C.rows_cons_from_insert(id,value,tag,tail,next,selection,
        rows_complete(tail,next,selection,I.valid_tail(id,value,tag,tail,next,h)),
      insert_enumeration(next,id,value,tag,tail,selection,
        H.and_left(Nat.is_lt(id,next),S.rows_valid(tail,T.Row{id,value,tag} <> tail,next),
          H.and_right(Nat.is_eq(S.count(T.Row{id,value,tag} <> tail,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,T.Row{id,value,tag} <> tail,next)),h)),
        H.unique_head_tail_zero(id,value,tag,tail,Equal.sym(Nat,S.count(T.Row{id,value,tag} <> tail,id),1n,
          I.eq_reflect(S.count(T.Row{id,value,tag} <> tail,id),1n,
            H.and_left(Nat.is_eq(S.count(T.Row{id,value,tag} <> tail,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,T.Row{id,value,tag} <> tail,next)),h))))))

# Pass the computed guard as a parameter with a definitional tying equality.
def guarded(guard: Bool, +limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>,
  +pending: List<&2,T.Command>, +selection: T.Selection,
  e: {guard == S.admissible(limit,T.World{id,next,rows,pending}) : Bool})
  -> S.When(guard,{M.query(T.World{id,next,rows,pending},selection) == S.query(T.World{id,next,rows,pending},selection) : List<&2,T.Row>}):
  match guard:
    case False{}: Unit{}
    case True{}:
      rows_complete(rows,next,selection,
        H.and_left(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next),
          H.and_right(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next)),e)))

def endpoint(+limit: Nat, +world: T.World, +selection: T.Selection)
  -> S.When(S.admissible(limit,world),{M.query(world,selection) == S.query(world,selection) : List<&2,T.Row>}):
  match world:
    case T.World{+id,+next,+rows,+pending}:
      guarded(S.admissible(limit,T.World{id,next,rows,pending}),limit,id,next,rows,pending,selection,{==})

def Laws.query_any_complete_ordered(limit,world):
  endpoint(limit,world,T.Any{})
def Laws.query_present_complete_ordered(limit,world):
  endpoint(limit,world,T.Present{})
def Laws.query_absent_complete_ordered(limit,world):
  endpoint(limit,world,T.Absent{})
