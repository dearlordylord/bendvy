import Base
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
# Consume the whole initial cohort before callback execution; capture is Data.
def take_slot(~S:Data,~K:Data,~V:Data,+slot:M.Slot<S,K,V>) -> M.Slot<S,K,V> & M.Snapshot<V>:
  (M.reset(~S,~K,~V,slot),M.snapshot(~S,~K,~V,slot))
def restored(~S:Data,~K:Data,~V:Data,pending:M.Pending<V>,applied:M.Applied<S,K,V>) -> M.Applied<S,K,V>:
  match applied:
    case M.Applied{M.Missing{},event}:M.Applied{M.Missing{},event}
    case M.Applied{M.Present{current,_,previous,changed},event}:M.Applied{M.Present{current,pending,previous,changed},event}
def apply(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,slot:M.Slot<S,K,V>,captured:M.Snapshot<V>) -> M.Applied<S,K,V>:
  match slot captured:
    case slot M.Unscheduled{}:M.Applied{slot,None{}}
    case M.Missing{} M.Scheduled{_,_}:M.Applied{M.Missing{},None{}}
    case M.Present{current,pending,previous,changed} M.Scheduled{value,skipSame}:restored(~S,~K,~V,pending,M.apply_present(~S,~K,~V,~same,current,value,previous,changed,skipSame))
