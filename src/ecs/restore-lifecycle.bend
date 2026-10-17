import Base
import ./world.bend as W
import ./restore-world.bend as Adapter
import ./restore-data.bend as R
import ./transaction.bend as T
import ./commands.bend as Cmd

def changes(~S:Data,~E:Data,~emit:R.Change<S> -> E,values:List<&2,R.Change<S>>) -> List<&2,E>:
  match values:
    case []:[]
    case value <> rest:emit(value) <> changes(~S,~E,~emit,rest)
def clear_join(~S:Data,~C:Type,~E:Data,~emit:R.Change<S> -> E,observed:C & List<&2,R.Change<S>>) -> C & List<&2,E>:
  match observed:
    case (store,events):(store,changes(~S,~E,~emit,events))
def clear_store(~S:Data,~C:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~emit:R.Change<S> -> E,store:C,handle:W.Handle<S>) -> C & List<&2,E>:
  clear_join(~S,~C,~E,~emit,clear(store,handle))
def despawned(~S:Data,~E:Data,~emit:R.Change<S> -> E,handle:W.Handle<S>) -> E:emit(R.Despawned{handle})
def queued(~S:Data,~C:Type,~Resources:Type,~E:Data,next:T.Tx<W.World<S,C,Resources,E>,E> -> T.Tx<W.World<S,C,Resources,E>,E>,observed:T.Tx<W.World<S,C,Resources,E>,E> & W.Status) -> T.Tx<W.World<S,C,Resources,E>,E>:
  match observed:
    case (tx,_):next(tx)
def queue(~S:Data,~C:Type,~Resources:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~emit:R.Change<S> -> E,handles:List<&2,W.Handle<S>>,tx:T.Tx<W.World<S,C,Resources,E>,E>) -> T.Tx<W.World<S,C,Resources,E>,E>:
  match handles:
    case []:tx
    case handle <> rest:queued(~S,~C,~Resources,~E,next => queue(~S,~C,~Resources,~E,~clear,~emit,rest,next),Cmd.tx_despawn_observed(~S,~C,~Resources,~E,~clear_store(~S,~C,~E,~clear,~emit),~despawned(~S,~E,~emit),tx,handle))
def committed(~S:Data,~C:Type,~Resources:Type,~E:Data,observed:T.Returned<W.World<S,C,Resources,E>,Unit>) -> W.World<S,C,Resources,E>:
  match observed:
    case T.Returned{world,_}:W.barrier(~S,~C,~Resources,~E,world)
def clean(~S:Data,~C:Type,~Resources:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~emit:R.Change<S> -> E,handles:List<&2,W.Handle<S>>,world:W.World<S,C,Resources,E>) -> W.World<S,C,Resources,E>:
  committed(~S,~C,~Resources,~E,Cmd.tx_finish(~S,~C,~Resources,~E,~Unit,queue(~S,~C,~Resources,~E,~clear,~emit,handles,T.begin(~W.World<S,C,Resources,E>,~E,Adapter.cancel_pending(~S,~C,~Resources,~E,world))),T.Success{}))
def populate(~S:Data,~C:Type,~Resources:Type,~E:Data,world:W.World<S,C,Resources,E>,handle:W.Handle<S>,unit:Unit) -> W.World<S,C,Resources,E>:
  world
def spawn_committed(~S:Data,~C:Type,~Resources:Type,~E:Data,reservation:W.Reservation<S>,observed:T.Returned<W.World<S,C,Resources,E>,Unit>) -> W.World<S,C,Resources,E> & W.Reservation<S>:
  match observed:
    case T.Returned{world,_}:(W.barrier(~S,~C,~Resources,~E,world),reservation)
def spawn_staged(~S:Data,~C:Type,~Resources:Type,~E:Data,observed:T.Tx<W.World<S,C,Resources,E>,E> & W.Reservation<S>) -> W.World<S,C,Resources,E> & W.Reservation<S>:
  match observed:
    case (tx,reservation):spawn_committed(~S,~C,~Resources,~E,reservation,Cmd.tx_finish(~S,~C,~Resources,~E,~Unit,tx,T.Success{}))
def spawn(~S:Data,~C:Type,~Resources:Type,~E:Data,world:W.World<S,C,Resources,E>) -> W.World<S,C,Resources,E> & W.Reservation<S>:
  spawn_staged(~S,~C,~Resources,~E,Cmd.tx_spawn(~S,~C,~Resources,~E,~Unit,~populate(~S,~C,~Resources,~E),T.begin(~W.World<S,C,Resources,E>,~E,world),Unit{}))
