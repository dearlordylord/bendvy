import Base
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx

# Bevy NextState::set_if_different preserves an existing forced same target.
# Equality is the same closed erased V comparator used by apply/conditions.
def forced_pending(~V:Data,same:Bool,prior:V,value:V) -> M.Pending<V>:
  match same:
    case True{}:M.Queued{prior,False{}}
    case False{}:M.Queued{value,True{}}
def conditional_pending(~V:Data,~same:V -> V -> Bool,pending:M.Pending<V>,+value:V) -> M.Pending<V>:
  match pending:
    case M.Queued{+prior,False{}}:forced_pending(~V,same(prior,value),prior,value)
    case _:M.Queued{value,True{}}
def conditional(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,slot:M.Slot<S,K,V>,value:V) -> M.Slot<S,K,V>:
  match slot:
    case M.Missing{}:M.Missing{}
    case M.Present{current,pending,previous,changed}:M.Present{current,conditional_pending(~V,~same,pending,value),previous,changed}
def queue(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,slot:M.Slot<S,K,V>,value:V,skipSame:Bool) -> M.Slot<S,K,V>:
  match skipSame:
    case False{}:M.queue(~S,~K,~V,slot,value,False{})
    case True{}:conditional(~S,~K,~V,~same,slot,value)
def write_taken(~S:Data,~K:Data,~V:Data,~W:Type,~E:Data,~put:W -> M.Slot<S,K,V> -> W,~same:V -> V -> Bool,pair:W & M.Slot<S,K,V>,undo:List<&1,(W -> W)>,commands:List<&1,(W -> W)>,events:List<&2,E>,value:V,skipSame:Bool) -> Tx.Tx<W,E>:
  match pair:
    case (world,+old):Tx.Tx{put(world,queue(~S,~K,~V,~same,old,value,skipSame)),(world => put(world,old)) <> undo,commands,events}
def write(~S:Data,~K:Data,~V:Data,~W:Type,~E:Data,~take:W -> W & M.Slot<S,K,V>,~put:W -> M.Slot<S,K,V> -> W,~same:V -> V -> Bool,tx:Tx.Tx<W,E>,value:V,skipSame:Bool) -> Tx.Tx<W,E>:
  match tx:
    case Tx.Tx{world,undo,commands,events}:write_taken(~S,~K,~V,~W,~E,~put,~same,take(world),undo,commands,events,value,skipSame)
def next(~S:Data,~K:Data,~V:Data,~W:Type,~E:Data,~take:W -> W & M.Slot<S,K,V>,~put:W -> M.Slot<S,K,V> -> W,~same:V -> V -> Bool,tx:Tx.Tx<W,E>,request:M.QueueInput<V>) -> Tx.Tx<W,E>:
  match request:
    case M.Set{value,skipSame}:write(~S,~K,~V,~W,~E,~take,~put,~same,tx,value,skipSame)
    case M.Reset{}:M.reset_tx(~S,~K,~V,~W,~E,~take,~put,tx)
def next_declared(~S:Data,~K:Data,~V:Data,~W:Type,~E:Data,~take:W -> W & M.Slot<S,K,V>,~put:W -> M.Slot<S,K,V> -> W,~same:V -> V -> Bool,_:M.Family<S,K,V,W,take,put>,tx:Tx.Tx<W,E>,request:M.QueueInput<V>) -> Tx.Tx<W,E>:
  next(~S,~K,~V,~W,~E,~take,~put,~same,tx,request)
