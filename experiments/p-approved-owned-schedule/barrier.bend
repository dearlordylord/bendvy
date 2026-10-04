import Base
import ./frames.bend as F
import ./commands.bend as C
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M

def finish(+id: U32, +next: U32, +pending: List<&2,R.Command>, -source: List<R.Cell>,
  frame: F.RowsResult<R.apply_all(pending,source),M.apply_all(O.commands(pending),O.rows(source))>)
  -> F.WorldResult<R.flush(R.World{id,next,source,pending}),M.flush(O.snapshot(R.World{id,next,source,pending}))>:
  match frame:
    case F.RowsResult{owner,exact,observed}:
      er = Equal.cong(List<R.Cell>,R.World,rs => R.World{id,next,rs,[]},owner,R.apply_all(pending,source),exact)
      eo = Equal.cong(List<&2,T.Row>,T.World,rs => T.World{U32.to_nat(id),U32.to_nat(next),rs,[]},O.rows(owner),M.apply_all(O.commands(pending),O.rows(source)),observed)
      F.WorldResult{R.World{id,next,owner,[]},er,eo}

def flush(world: R.World) -> F.WorldResult<R.flush(world),M.flush(O.snapshot(world))>:
  match world:
    case R.World{+id,+next,rows,+pending}: finish(id,next,pending,rows,C.apply_all(pending,rows))
