import Base
import ./frames.bend as F
import ../p-approved-owned-safety/member-safety.bend as G
import ../p-observe-schedule/context.bend as C
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def contents(world: T.World) -> List<&2,T.Row>:
  match world:
    case T.World{_,_,rows,_}: rows

def data_guard(+limit: Nat, +data: T.World, +target: Nat,
  valid: {True{} == S.admissible(limit,data) : Bool}, safe: {True{} == S.step_safe(data,T.Bump{target}) : Bool})
  -> {True{} == G.BumpSafe(G.Overflow{},contents(data),target) : Bool}:
  match data:
    case T.World{+id,+next,+rows,+pending}:
      G.from_step(id,next,rows,pending,target,C.live_valid(limit,id,next,rows,pending,valid),safe)

def member_guard(+limit: U32, +data: T.World, +target: U32, +id: U32, +next: U32, -rows: List<R.Cell>, +pending: List<&2,R.Command>,
  observed: {O.snapshot(R.World{id,next,rows,pending}) == data : T.World},
  valid: {True{} == S.admissible(U32.to_nat(limit),data) : Bool}, safe: {True{} == S.step_safe(data,T.Bump{U32.to_nat(target)}) : Bool})
  -> {True{} == G.BumpSafe(G.Overflow{},O.rows(rows),U32.to_nat(target)) : Bool}:
  %Equal.sym(T.World,O.snapshot(R.World{id,next,rows,pending}),data,observed) : {True{} == G.BumpSafe(G.Overflow{},contents(_),U32.to_nat(target)) : Bool}
  data_guard(U32.to_nat(limit),data,U32.to_nat(target),valid,safe)

def finish(+id: U32, +next: U32, +pending: List<&2,R.Command>, +target: U32, -source: List<R.Cell>,
  frame: F.RowsResult<R.bump_rows(target,source),M.bump_rows(U32.to_nat(target),O.rows(source))>)
  -> F.WorldResult<R.bump(R.World{id,next,source,pending},target),M.bump(O.snapshot(R.World{id,next,source,pending}),U32.to_nat(target))>:
  match frame:
    case F.RowsResult{owner,exact,observed}:
      er = Equal.cong(List<R.Cell>,R.World,rs => R.World{id,next,rs,pending},owner,R.bump_rows(target,source),exact)
      eo = Equal.cong(List<&2,T.Row>,T.World,rs => T.World{U32.to_nat(id),U32.to_nat(next),rs,O.commands(pending)},O.rows(owner),M.bump_rows(U32.to_nat(target),O.rows(source)),observed)
      F.WorldResult{R.World{id,next,owner,pending},er,eo}
