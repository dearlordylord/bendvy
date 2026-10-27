import Base
import ./machine.bend as M

# Bevy NextState::set_if_different preserves an existing forced same target.
# Equality is the same closed erased V comparator used by apply/conditions.
def forced_pending_generic(-V:Data,same:Bool,prior:V,value:V) -> M.Pending<V>:
  match same:
    case True{}:M.Queued{prior,False{}}
    case False{}:M.Queued{value,True{}}
def forced_pending(~V:Data,same:Bool,prior:V,value:V) -> M.Pending<V>:
  forced_pending_generic(V,same,prior,value)

def conditional_pending_generic(-V:Data,same:V -> V -> Bool,pending:M.Pending<V>,+value:V) -> M.Pending<V>:
  match pending:
    case M.Queued{+prior,False{}}:forced_pending_generic(V,same(prior,value),prior,value)
    case _:M.Queued{value,True{}}
def conditional_pending(~V:Data,~same:V -> V -> Bool,pending:M.Pending<V>,+value:V) -> M.Pending<V>:
  conditional_pending_generic(V,same,pending,value)

def conditional_generic(-S:Data,-K:Data,-V:Data,same:V -> V -> Bool,slot:M.Slot<S,K,V>,value:V) -> M.Slot<S,K,V>:
  match slot:
    case M.Missing{}:M.Missing{}
    case M.Present{current,pending,previous,changed}:M.Present{current,conditional_pending_generic(V,same,pending,value),previous,changed}
def conditional(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,slot:M.Slot<S,K,V>,value:V) -> M.Slot<S,K,V>:
  conditional_generic(S,K,V,same,slot,value)

def queue_generic(-S:Data,-K:Data,-V:Data,same:V -> V -> Bool,slot:M.Slot<S,K,V>,value:V,skipSame:Bool) -> M.Slot<S,K,V>:
  match skipSame:
    case False{}:M.queue_generic(S,K,V,slot,value,False{})
    case True{}:conditional_generic(S,K,V,same,slot,value)
def queue(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,slot:M.Slot<S,K,V>,value:V,skipSame:Bool) -> M.Slot<S,K,V>:
  queue_generic(S,K,V,same,slot,value,skipSame)
