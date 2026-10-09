import Base
import ../domains.bend as D
import ../routing.bend as Route
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/src/ecs/world.bend as W

type BarrierState<S: Data,C: Type,R: Type,E: Data> is Type:
  BarrierState{world: W.World<S,C,R,E>,domains: List<&2,D.Domain<S,E>>,tick: Nat}

def collected(~S: Data,~C: Type,~R: Type,~E: Data,joined: W.World<S,C,R,E> & List<&2,D.Domain<S,E>>,tick: Nat) -> BarrierState<S,C,R,E>:
  (world,domains) = joined
  BarrierState{world,domains,tick}

def command_collected(~S: Data,~C: Type,~R: Type,~E: Data,~classify: E -> Maybe<D.DescriptorKey<S>>,command: W.World<S,C,R,E> -> W.World<S,C,R,E>,state: BarrierState<S,C,R,E>) -> BarrierState<S,C,R,E>:
  match state:
    case BarrierState{world,domains,+tick}: collected(~S,~C,~R,~E,Route.collect(~S,~C,~R,~E,~classify,command(world),tick,domains),tick)

def drain(~S: Data,~C: Type,~R: Type,~E: Data,~classify: E -> Maybe<D.DescriptorKey<S>>,commands: List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,state: BarrierState<S,C,R,E>) -> BarrierState<S,C,R,E>:
  match commands:
    case []: state
    case command <> rest: drain(~S,~C,~R,~E,~classify,rest,command_collected(~S,~C,~R,~E,~classify,command,state))

# The deferred barrier advances the actual World clock once. Every command
# publishes a distinct batch stamped with that same barrier tick.
def opened(~S: Data,~C: Type,~R: Type,~E: Data,~classify: E -> Maybe<D.DescriptorKey<S>>,advanced: W.World<S,C,R,E> & U32,domains: List<&2,D.Domain<S,E>>) -> BarrierState<S,C,R,E>:
  (world,+tick) = advanced
  match world:
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,pending,+registrations,+nextSystemId,+clock}: drain(~S,~C,~R,~E,~classify,List.reverse(&1,(W.World<S,C,R,E> -> W.World<S,C,R,E>),pending),BarrierState{W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,[],registrations,nextSystemId,clock},domains,U32.to_nat(tick)})

def barrier(~S: Data,~C: Type,~R: Type,~E: Data,~classify: E -> Maybe<D.DescriptorKey<S>>,world: W.World<S,C,R,E>,domains: List<&2,D.Domain<S,E>>) -> BarrierState<S,C,R,E>:
  opened(~S,~C,~R,~E,~classify,W.advance_clock(~S,~C,~R,~E,world),domains)
