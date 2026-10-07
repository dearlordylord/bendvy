import Base
import machine.bend as M
import provider.bend as P
import gameplay.bend as G
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as Tx
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as Cmp
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/system.bend as Sys

type Frame<S: Data> is Type:
  Frame{tx: Tx.Tx<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Unit>,error: Maybe<&2,String>}

def first_error(old: Maybe<&2,String>,next: String) -> Maybe<&2,String>:
  match old:
    case None{}: Some{next}
    case old: old

def flow_read_pair(~S: Data,pair: Tx.Tx<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Unit> & M.Slot<S,P.FlowToken,P.Flow>,error: Maybe<&2,String>) -> Frame<S> & M.Slot<S,P.FlowToken,P.Flow>:
  (tx,slot)=pair
  (Frame{tx,error},slot)
def flow_read(~S: Data,frame: Frame<S>) -> Frame<S> & M.Slot<S,P.FlowToken,P.Flow>:
  match frame:
    case Frame{tx,error}: flow_read_pair(~S,M.read(~S,~P.FlowToken,~P.Flow,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~Unit,~(world => P.flow_take(~S,world)),tx),error)
def flow_next(~S: Data,frame: Frame<S>,request: M.QueueInput<P.Flow>) -> Frame<S>:
  match frame:
    case Frame{tx,error}: Frame{M.next_declared(~S,~P.FlowToken,~P.Flow,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~Unit,~(world => P.flow_take(~S,world)),~(world => slot => P.flow_put(~S,world,slot)),M.Family{"Flow"},tx,request),error}
def level_read_pair(~S: Data,pair: Tx.Tx<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Unit> & M.Slot<S,P.LevelToken,P.Level>,error: Maybe<&2,String>) -> Frame<S> & M.Slot<S,P.LevelToken,P.Level>:
  (tx,slot)=pair
  (Frame{tx,error},slot)
def level_read(~S: Data,frame: Frame<S>) -> Frame<S> & M.Slot<S,P.LevelToken,P.Level>:
  match frame:
    case Frame{tx,error}: level_read_pair(~S,M.read(~S,~P.LevelToken,~P.Level,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~Unit,~(world => P.level_take(~S,world)),tx),error)
def level_next(~S: Data,frame: Frame<S>,request: M.QueueInput<P.Level>) -> Frame<S>:
  match frame:
    case Frame{tx,error}: Frame{M.next_declared(~S,~P.LevelToken,~P.Level,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~Unit,~(world => P.level_take(~S,world)),~(world => slot => P.level_put(~S,world,slot)),M.Family{"Level"},tx,request),error}

def owned_replace(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,incoming: Array<U32>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & Array<U32>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{old,flow,level,flowStream,levelStream,frame,tick,trace},events,commands,registrations,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,P.Resources{incoming,flow,level,flowStream,levelStream,frame,tick,trace},events,commands,registrations,nextSystem,clock},old)
def owned_restored(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & Array<U32>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  (world,_)=pair
  world
def owned_restore(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,old: Array<U32>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  owned_restored(~S,owned_replace(~S,world,old))
def owned_written(~S: Data,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & Array<U32>,undo: List<&1,(W.World<S,P.Store<S>,P.Resources<S>,Unit> -> W.World<S,P.Store<S>,P.Resources<S>,Unit>)>,commands: List<&1,(W.World<S,P.Store<S>,P.Resources<S>,Unit> -> W.World<S,P.Store<S>,P.Resources<S>,Unit>)>,events: List<&2,Unit>) -> Tx.Tx<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Unit>:
  (world,old)=pair
  Tx.Tx{world,(world => owned_restore(~S,world,old)) <> undo,commands,events}
def owned_tx(~S: Data,tx: Tx.Tx<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Unit>,incoming: Array<U32>) -> Tx.Tx<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Unit>:
  match tx:
    case Tx.Tx{world,undo,commands,events}: owned_written(~S,owned_replace(~S,world,incoming),undo,commands,events)
def owned_write(~S: Data,frame: Frame<S>,incoming: Array<U32>) -> Frame<S>:
  match frame:
    case Frame{tx,error}: Frame{owned_tx(~S,tx,incoming),error}

def cells_result(~S: Data,result: Cmp.SetResult<Tx.Tx<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Unit>,Array<U32>>,error: Maybe<&2,String>) -> Frame<S>:
  match result:
    case Cmp.Written{tx}: Frame{tx,error}
    case Cmp.WriteRejected{tx,_,_}: Frame{tx,first_error(error,"ComponentWriteRejected")}
    case Cmp.WriteFailure{tx,_}: Frame{tx,first_error(error,"ComponentWriteFailure")}
def cells_write(~S: Data,frame: Frame<S>,incoming: Array<U32>) -> Frame<S>:
  match frame:
    case Frame{tx,error}: cells_result(~S,P.cells_set(~S,tx,incoming),error)

def populate_empty(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,_: W.Handle<S>,_: Unit) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  world
def spawned(~S: Data,result: Tx.Tx<W.World<S,P.Store<S>,P.Resources<S>,Unit>,Unit> & W.Reservation<S>,error: Maybe<&2,String>) -> Frame<S>:
  match result:
    case (tx,W.Reserved{_}): Frame{tx,error}
    case (tx,W.ReservationRejected{_}): Frame{tx,first_error(error,"SpawnRejected")}
def spawn_empty(~S: Data,frame: Frame<S>) -> Frame<S>:
  match frame:
    case Frame{tx,error}: spawned(~S,Cmd.tx_spawn(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Unit,~(world => handle => payload => populate_empty(~S,world,handle,payload)),tx,Unit{}),error)

def spawn_seed(~S: Data,frame: Frame<S>,owner: Array<U32>) -> Frame<S>:
  match frame:
    case Frame{tx,error}: spawned(~S,Cmd.tx_spawn(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Array<U32>,~(world => handle => payload => P.populate_cells(~S,world,handle,payload)),tx,owner),error)
def spawn(~S: Data,frame: Frame<S>,payload: G.SpawnPayload) -> Frame<S>:
  match payload:
    case G.Empty{}: spawn_empty(~S,frame)
    case G.SeedCells{owner}: spawn_seed(~S,frame,owner)

def flow_current_pair(~S: Data,pair: Frame<S> & M.Slot<S,P.FlowToken,P.Flow>) -> Frame<S> & M.CurrentView<S,P.FlowToken,P.Flow>:
  (frame,slot)=pair
  (frame,M.current_view(~S,~P.FlowToken,~P.Flow,slot))
def flow_current(~S: Data,frame: Frame<S>) -> Frame<S> & M.CurrentView<S,P.FlowToken,P.Flow>:
  flow_current_pair(~S,flow_read(~S,frame))
def flow_pending_pair(~S: Data,pair: Frame<S> & M.Slot<S,P.FlowToken,P.Flow>) -> Frame<S> & M.NextView<S,P.FlowToken,P.Flow>:
  (frame,slot)=pair
  (frame,M.next_view(~S,~P.FlowToken,~P.Flow,slot))
def flow_pending(~S: Data,frame: Frame<S>) -> Frame<S> & M.NextView<S,P.FlowToken,P.Flow>:
  flow_pending_pair(~S,flow_read(~S,frame))
def level_pending_pair(~S: Data,pair: Frame<S> & M.Slot<S,P.LevelToken,P.Level>) -> Frame<S> & M.NextView<S,P.LevelToken,P.Level>:
  (frame,slot)=pair
  (frame,M.next_view(~S,~P.LevelToken,~P.Level,slot))
def level_pending(~S: Data,frame: Frame<S>) -> Frame<S> & M.NextView<S,P.LevelToken,P.Level>:
  level_pending_pair(~S,level_read(~S,frame))

def work(~S: Data) -> G.Work<S,Frame<S>>:
  G.Work{Cap.ValueRead{frame => flow_current(~S,frame)},Cap.ValueWrite{frame => flow_pending(~S,frame),frame => value => flow_next(~S,frame,value)},Cap.ValueWrite{frame => flow_pending(~S,frame),frame => value => flow_next(~S,frame,value)},Cap.ValueWrite{frame => level_pending(~S,frame),frame => value => level_next(~S,frame,value)},Cap.Send{frame => owner => cells_write(~S,frame,owner)},Cap.Send{frame => owner => owned_write(~S,frame,owner)},Cap.Send{frame => payload => spawn(~S,frame,payload)}}

def effective(outcome: Tx.Outcome<String>,error: Maybe<&2,String>) -> Tx.Outcome<String>:
  match error:
    case None{}: outcome
    case Some{error}: Tx.Failure{error}
def returned(~S: Data,result: Tx.Returned<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match result:
    case Tx.Returned{world,Tx.Success{}}: Sys.Succeeded{world,Unit{}}
    case Tx.Returned{world,Tx.Failure{error}}: Sys.Failed{world,error}
def finish(~S: Data,pair: Frame<S> & Tx.Outcome<String>) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match pair:
    case (Frame{tx,error},outcome): returned(~S,Cmd.tx_finish(~S,~P.Store<S>,~P.Resources<S>,~Unit,~String,tx,effective(outcome,error)))
def runner(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,operation: G.Operation) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  finish(~S,G.body(~S,~Frame<S>,~work(~S),operation,Frame{Tx.begin(~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~Unit,P.pulse(~S,world)),None{}}))

def hook_work(~S: Data) -> G.HookWork<S,Frame<S>>:
  G.HookWork{Cap.ValueWrite{frame => flow_pending(~S,frame),frame => value => flow_next(~S,frame,value)},Cap.ValueWrite{frame => level_pending(~S,frame),frame => value => level_next(~S,frame,value)}}
def hook_runner(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,operation: G.HookOperation) -> Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  finish(~S,G.hook_body(~S,~Frame<S>,~hook_work(~S),operation,Frame{Tx.begin(~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~Unit,P.pulse(~S,world)),None{}}))
