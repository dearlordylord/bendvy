import Base
import ../dense-runtime-v1/types.bend as T
import motion.bend as F
import events.bend as E
import motion-tx-observe.bend as Inspect
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/system.bend as Sys

def Store() -> Type:F.Store()
def main_cleared(rest:F.Rest(),result:Col.SwapOutcome<T.MotionSchema,T.Position>) -> Store():
  match result:
    case Col.Accepted{column,_}:F.put_main(rest,column)
    case Col.Rejected{column,_}:F.put_main(rest,column)
def main_taken(handle:W.Handle<T.MotionSchema>,observed:F.Rest() & Col.Column<T.MotionSchema,T.Position>) -> Store():
  match observed:
    case (rest,column):main_cleared(rest,Col.clear(~T.MotionSchema,~T.Position,column,W.handle_index(~T.MotionSchema,handle)))
def clear_main(store:Store(),handle:W.Handle<T.MotionSchema>) -> Store():main_taken(handle,F.take_main(store))

def aux_cleared(rest:F.AuxRest(),result:Col.SwapOutcome<T.MotionSchema,T.Velocity>) -> Store():
  match result:
    case Col.Accepted{column,_}:F.put_aux(rest,column)
    case Col.Rejected{column,_}:F.put_aux(rest,column)
def aux_taken(handle:W.Handle<T.MotionSchema>,observed:F.AuxRest() & Col.Column<T.MotionSchema,T.Velocity>) -> Store():
  match observed:
    case (rest,column):aux_cleared(rest,Col.clear(~T.MotionSchema,~T.Velocity,column,W.handle_index(~T.MotionSchema,handle)))
def clear_aux(store:Store(),handle:W.Handle<T.MotionSchema>) -> Store():aux_taken(handle,F.take_aux(store))

def flag_cleared(rest:F.FlagRest(),result:Col.SwapOutcome<T.MotionSchema,T.Selected>) -> Store():
  match result:
    case Col.Accepted{column,_}:F.put_flag(rest,column)
    case Col.Rejected{column,_}:F.put_flag(rest,column)
def flag_taken(handle:W.Handle<T.MotionSchema>,observed:F.FlagRest() & Col.Column<T.MotionSchema,T.Selected>) -> Store():
  match observed:
    case (rest,column):flag_cleared(rest,Col.clear(~T.MotionSchema,~T.Selected,column,W.handle_index(~T.MotionSchema,handle)))
def clear_flag(store:Store(),handle:W.Handle<T.MotionSchema>) -> Store():flag_taken(handle,F.take_flag(store))

def clear_copy(store:Store(),+handle:W.Handle<T.MotionSchema>) -> Store():clear_flag(clear_aux(clear_main(store,handle),handle),handle)
def clear(store:Store(),handle:W.Handle<T.MotionSchema>) -> Store():clear_copy(store,handle)

type Output is Data:
  Output{statuses:List<&2,W.Status>,facts:Inspect.Facts,outcome:Tx.Outcome<Unit>}
def finished(statuses:List<&2,W.Status>,facts:Inspect.Facts,result:Tx.Returned<F.World(),Unit>) -> Sys.Outcome<F.World(),Empty,Output>:
  match result:
    case Tx.Returned{world,outcome}:Sys.Succeeded{world,Output{statuses,facts,outcome}}
def observed(statuses:List<&2,W.Status>,value:Tx.Tx<F.World(),E.event_type()> & Inspect.Facts) -> Sys.Outcome<F.World(),Empty,Output>:
  match value:
    case (tx,facts):finished(statuses,facts,Cmd.tx_finish(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~Unit,tx,Tx.Success{}))
def next(next:(Tx.Tx<F.World(),E.event_type()> & List<&2,W.Status>) -> Sys.Outcome<F.World(),Empty,Output>,statuses:List<&2,W.Status>,result:Tx.Tx<F.World(),E.event_type()> & W.Status) -> Sys.Outcome<F.World(),Empty,Output>:
  match result:
    case (tx,status):next((tx,List.append(&2,W.Status,statuses,[status])))
def queue(handles:List<&2,W.Handle<T.MotionSchema>>,value:Tx.Tx<F.World(),E.event_type()> & List<&2,W.Status>) -> Sys.Outcome<F.World(),Empty,Output>:
  match handles value:
    case [], (tx,statuses):observed(statuses,Inspect.observe(tx))
    case handle <> rest, (tx,statuses):next(value=>queue(rest,value),statuses,Cmd.tx_despawn_with(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~clear,tx,handle))
def runner(world:F.World(),handles:List<&2,W.Handle<T.MotionSchema>>) -> Sys.Outcome<F.World(),Empty,Output>:queue(handles,(Tx.begin(~F.World(),~E.event_type(),world),[]))
def Registry() -> Type:Sys.Registry<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),List<&2,W.Handle<T.MotionSchema>>,Empty,Output,runner>
