import Base
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../consumer/health.bend as F
import ../../../consumer/health-events.bend as E
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/column.bend as Col
import ../../../../../../src/ecs/commands.bend as Cmd
import ../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../src/ecs/system.bend as Sys

def Store() -> Type:F.Store()
def main_cleared(rest:F.Rest(),result:Col.SwapOutcome<T.HealthSchema,T.Vitals>) -> Store():
  match result:
    case Col.Accepted{column,_}:F.put_main(rest,column)
    case Col.Rejected{column,_}:F.put_main(rest,column)
def main_taken(handle:W.Handle<T.HealthSchema>,observed:F.Rest() & Col.Column<T.HealthSchema,T.Vitals>) -> Store():
  match observed:
    case (rest,column):main_cleared(rest,Col.clear(~T.HealthSchema,~T.Vitals,column,W.handle_index(~T.HealthSchema,handle)))
def clear_main(store:Store(),handle:W.Handle<T.HealthSchema>) -> Store():main_taken(handle,F.take_main(store))

def aux_cleared(rest:F.AuxRest(),result:Col.SwapOutcome<T.HealthSchema,T.Armor>) -> Store():
  match result:
    case Col.Accepted{column,_}:F.put_aux(rest,column)
    case Col.Rejected{column,_}:F.put_aux(rest,column)
def aux_taken(handle:W.Handle<T.HealthSchema>,observed:F.AuxRest() & Col.Column<T.HealthSchema,T.Armor>) -> Store():
  match observed:
    case (rest,column):aux_cleared(rest,Col.clear(~T.HealthSchema,~T.Armor,column,W.handle_index(~T.HealthSchema,handle)))
def clear_aux(store:Store(),handle:W.Handle<T.HealthSchema>) -> Store():aux_taken(handle,F.take_aux(store))

def flag_cleared(rest:F.FlagRest(),result:Col.SwapOutcome<T.HealthSchema,T.Tracked>) -> Store():
  match result:
    case Col.Accepted{column,_}:F.put_flag(rest,column)
    case Col.Rejected{column,_}:F.put_flag(rest,column)
def flag_taken(handle:W.Handle<T.HealthSchema>,observed:F.FlagRest() & Col.Column<T.HealthSchema,T.Tracked>) -> Store():
  match observed:
    case (rest,column):flag_cleared(rest,Col.clear(~T.HealthSchema,~T.Tracked,column,W.handle_index(~T.HealthSchema,handle)))
def clear_flag(store:Store(),handle:W.Handle<T.HealthSchema>) -> Store():flag_taken(handle,F.take_flag(store))

def clear_copy(store:Store(),+handle:W.Handle<T.HealthSchema>) -> Store():clear_flag(clear_aux(clear_main(store,handle),handle),handle)
def clear(store:Store(),handle:W.Handle<T.HealthSchema>) -> Store():clear_copy(store,handle)

type Output is Data:
  Output{statuses:List<&2,W.Status>,outcome:Tx.Outcome<Unit>}
def finished(statuses:List<&2,W.Status>,result:Tx.Returned<F.World(),Unit>) -> Sys.Outcome<F.World(),Empty,Output>:
  match result:
    case Tx.Returned{world,outcome}:Sys.Succeeded{world,Output{statuses,outcome}}
def next(next:(Tx.Tx<F.World(),E.event_type()> & List<&2,W.Status>) -> Sys.Outcome<F.World(),Empty,Output>,statuses:List<&2,W.Status>,result:Tx.Tx<F.World(),E.event_type()> & W.Status) -> Sys.Outcome<F.World(),Empty,Output>:
  match result:
    case (tx,status):next((tx,List.append(&2,W.Status,statuses,[status])))
def queue(handles:List<&2,W.Handle<T.HealthSchema>>,value:Tx.Tx<F.World(),E.event_type()> & List<&2,W.Status>) -> Sys.Outcome<F.World(),Empty,Output>:
  match handles value:
    case [], (tx,statuses):finished(statuses,Cmd.tx_finish(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~Unit,tx,Tx.Success{}))
    case handle <> rest, (tx,statuses):next(value=>queue(rest,value),statuses,Cmd.tx_despawn_with(~T.HealthSchema,~F.Store(),~F.Resources(),~E.event_type(),~clear,tx,handle))
def runner(world:F.World(),handles:List<&2,W.Handle<T.HealthSchema>>) -> Sys.Outcome<F.World(),Empty,Output>:queue(handles,(Tx.begin(~F.World(),~E.event_type(),world),[]))
def Registry() -> Type:Sys.Registry<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),List<&2,W.Handle<T.HealthSchema>>,Empty,Output,runner>
