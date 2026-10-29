import Base
import ./machine.bend as M
import ./execution-machine-state.bend as State
import ./change-tick.bend as Tick

# Trusted restore publication after the retained schema has admitted and decoded
# the detached committed value. This helper grants no codec or storage access.
type Commit<-V:Data> is Data:
  Commit{current:Maybe<&2,V>,revision:Nat,stamp:Maybe<&2,Tick.Tick>}
type Admission<-V:Data,-Source:Type> is Type:
  MachineRestoreReady{commit:Commit<V>,source:Source}
  Refused{source:Source}
type Publication<-S:Data,-K:Data,-V:Data,-Source:Type> is Type:
  Installed{cell:State.Cell<S,K,V>,source:Source}
  Rejected{cell:State.Cell<S,K,V>,source:Source}

def slot(-S:Data,-K:Data,-V:Data,current:Maybe<&2,V>) -> M.Slot<S,K,V>:
  match current:
    case None{}:M.Missing{}
    case Some{value}:M.Present{value,M.NoPending{},None{},False{}}

# Receiver channels, sequence, namespace and Next's receiver-local stamp survive.
# Restore does not enqueue an initial/transition event or resurrect source intent.
def install(-S:Data,-K:Data,-V:Data,cell:State.Cell<S,K,V>,commit:Commit<V>) -> State.Cell<S,K,V>:
  match cell commit:
    case State.Cell{_,stream,_,_,nextStamp,sequence,_,namespace,_} Commit{current,revision,stamp}:
      State.Cell{slot(S,K,V,current),stream,revision,stamp,nextStamp,sequence,False{},namespace,State.Idle{}}

# Source is genuinely affine: admission refusal returns the same receiver and
# source owners without projection, duplication or rebuilding the receiver.
def publish(-S:Data,-K:Data,-V:Data,-Source:Type,cell:State.Cell<S,K,V>,admission:Admission<V,Source>) -> Publication<S,K,V,Source>:
  match admission:
    case Refused{source}:Rejected{cell,source}
    case MachineRestoreReady{commit,source}:Installed{install(S,K,V,cell,commit),source}
