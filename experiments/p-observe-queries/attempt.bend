import Base
import ./LAWS.bend as Laws
import ./helpers.bend as H
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# General endpoint proof reduces to this precise list/count/enumeration bridge.
# The nonempty case is deliberately retained as a failing research diagnostic.
def rows_complete(+rows: List<&2,T.Row>, +next: Nat, +selection: T.Selection,
  h: {True{} == S.rows_valid(rows,rows,next) : Bool})
  -> {M.query_rows(selection,rows) == S.enumerate_rows(next,0n,rows,selection) : List<&2,T.Row>}:
  match rows:
    case Nil{}: H.enumerate_empty(next,0n,selection)
    case Con{T.Row{+id,+value,+tag},+tail}: ?nonempty_sort_enumeration_bridge

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
