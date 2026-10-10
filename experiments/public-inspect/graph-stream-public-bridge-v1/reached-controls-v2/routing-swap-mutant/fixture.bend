import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import ../../state.bend as State
import consumer.bend as Consumer

def graph(~S:Data) -> G.Graph<S>:
  G.Graph{[G.Edge{Consumer.link(~S),1,2},G.Edge{Consumer.link(~S),3,2},G.Edge{Consumer.parent(~S),1,2},G.Edge{Consumer.parent(~S),3,2}],[G.Inverse{Consumer.link(~S),2,[3,1]},G.Inverse{Consumer.parent(~S),2,[1,3]}]}
def stream() -> St.Stream<U32>:
  St.Stream{[Ev.Batch{2n,[M.Transition{4,7}]},Ev.Batch{3n,[M.Transition{7,8},M.Transition{8,7}]}],[Ev.Position{5,1n,1n}],0n,2n}
def resources(~S:Data,+base:U32) -> State.Resources<S>:
  State.Resources{ANode{ALeaf{base},ALeaf{(base+1:U32)}},M.Present{7,M.Queued{9,False{}},Some{4},True{}},M.Present{11,M.Queued{12,True{}},Some{10},False{}},0,stream(),St.empty(~U32)}
# Retained public Notice payloads, not a newly selected reader projection.
def notices(~S:Data) -> List<&2,A.Notice<S,U32>>:
  [A.Original{17},A.RelationFailed{G.Failure{Consumer.parent(~S),G.Relate{},2,3,G.HierarchyCycle{2,3,"Parent"}}},A.ComponentRemoved{23},A.CleanupPaused{[G.CleanupEnter{3},G.CleanupDescriptors{3,[Consumer.link(~S),Consumer.parent(~S)]},G.CleanupChildren{3,Consumer.parent(~S),[Consumer.link(~S)],[1,3]},G.CleanupFinish{3}]}]
def clocked(~S:Data,observed:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>> & U32) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>:
  (world,clock)=observed
  world
def command(~S:Data,world:W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>:
  clocked(~S,W.advance_clock(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,world))
def world(~S:Data,namespace:U32,+base:U32) -> W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>:
  W.World{namespace,4,3,ANode{ANode{ALeaf{False{}},ALeaf{True{}}},ANode{ALeaf{True{}},ALeaf{True{}}}},4,2n,A.Store{State.Components{ANode{ALeaf{base},ALeaf{(base+2:U32)}}},graph(~S)},resources(~S,base),notices(~S),[command(~S)],[W.RegistrationMeta{1,"Existing",["Flow","Link"]}],2,13}
