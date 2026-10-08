import Base
import ./fixture.bend as F
import ./setup.bend as Setup
import ./export.bend as Export
import ./world-owner.bend as Owner
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col

type Saved<-S:Data> is Type:
  Saved{world:W.World<S,F.Store<S>,F.Resources,Unit>,first:Export.Snapshot,second:Export.Snapshot,after:Export.Snapshot,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>}
def mutate_store(~S:Data,store:F.Store<S>) -> F.Store<S> & Unit:
  match store:
    case F.Store{saved,transient,codec}:(F.Store{Setup.swapped(~S,Col.swap(~S,~F.Payload,saved,1,Some{F.payload(11,13)})),transient,codec},Unit{})
def mutate_resource(owner:F.Resources) -> F.Resources & Unit:
  match owner:
    case F.Resources{_,transient,codec}:(F.Resources{F.payload(31,33),transient,codec},Unit{})
def third(~S:Data,first:Export.Snapshot,second:Export.Snapshot,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Export.Snapshot) -> Saved<S>:
  match observed:
    case (world,after):Saved{world,first,second,after,firstOwner,secondOwner}
def mutated_resource(~S:Data,first:Export.Snapshot,second:Export.Snapshot,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Unit) -> Saved<S>:
  match observed:
    case (world,_):third(~S,first,second,firstOwner,secondOwner,F.save(~S,world))
def mutated_store(~S:Data,first:Export.Snapshot,second:Export.Snapshot,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Unit) -> Saved<S>:
  match observed:
    case (world,_):mutated_resource(~S,first,second,firstOwner,secondOwner,W.observe_resource(~S,~F.Store<S>,~F.Resources,~Unit,~Unit,~mutate_resource,world))
def second_owner(~S:Data,first:Export.Snapshot,second:Export.Snapshot,firstOwner:Owner.Observed<S>,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Owner.Observed<S>) -> Saved<S>:
  match observed:
    case (world,secondOwner):mutated_store(~S,first,second,firstOwner,secondOwner,W.with_store(~S,~F.Store<S>,~F.Resources,~Unit,~Unit,mutate_store(~S),world))
def second(~S:Data,first:Export.Snapshot,firstOwner:Owner.Observed<S>,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Export.Snapshot) -> Saved<S>:
  match observed:
    case (world,second):second_owner(~S,first,second,firstOwner,Owner.observe(~S,world))
def first_owner(~S:Data,first:Export.Snapshot,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Owner.Observed<S>) -> Saved<S>:
  match observed:
    case (world,firstOwner):second(~S,first,firstOwner,F.save(~S,world))
def first(~S:Data,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Export.Snapshot) -> Saved<S>:
  match observed:
    case (world,snapshot):first_owner(~S,snapshot,Owner.observe(~S,world))
def consume(~S:Data,world:W.World<S,F.Store<S>,F.Resources,Unit>) -> Saved<S>:
  first(~S,F.save(~S,world))
