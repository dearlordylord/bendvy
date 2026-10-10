import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import ../state.bend as State
import fixture.bend as Fixture

# Draft operational provenance helper; no source/runtime qualification yet.
# Both reservations are real. The live id2 handle is retained from Reserved,
# rather than reconstructed from namespace/id constants.
type Created<S:Data> is Type:
  Created{factory:W.Factory,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,handle:Maybe<W.Handle<S>>,statuses:List<&2,W.Status>}
def empty(~S:Data,unit:Unit) -> A.Store<S,State.Components<S>>:
  A.Store{State.Components{ANode{ALeaf{300},ALeaf{302}}},G.Graph{[],[]}}
def activated(~S:Data,factory:W.Factory,handle:W.Handle<S>,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & W.Status) -> Created<S>:
  (world,status)=observed
  Created{factory,world,Some{handle},[status]}
def second(~S:Data,factory:W.Factory,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & W.Reservation<S>) -> Created<S>:
  match observed:
    case (world,W.Reserved{+handle}):activated(~S,factory,handle,W.activate(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world,handle))
    case (world,W.ReservationRejected{error}):Created{factory,world,None{},[W.Rejected{error}]}
def first(~S:Data,factory:W.Factory,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & W.Reservation<S>) -> Created<S>:
  match observed:
    case (world,W.Reserved{handle}):second(~S,factory,W.reserve_id(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))
    case (world,W.ReservationRejected{error}):Created{factory,world,None{},[W.Rejected{error}]}
def created(~S:Data,result:W.Creation<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> Maybe<Created<S>>:
  match result:
    case W.Created{factory,world}:Some{first(~S,factory,W.reserve_id(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))}
    case W.CreateRejected{factory,resource}:None{}
def create(~S:Data) -> Maybe<Created<S>>:
  created(~S,W.create(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~empty(~S),W.Factory{99},Fixture.resources(~S,300)))
