import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import ./game.bend as Save
import ./game.bend as Game
import ./leaf.bend as Leaf
import ./declaration.bend as Decl
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-product.bend as Product
import ../fixture.bend as F
import ../setup.bend as Setup
import ../export.bend as Export
import ./world-owner.bend as Owner
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col

type Saved<-S:Data> is Type:
  Saved{world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,first:Export.Snapshot,second:Export.Snapshot,after:Export.Snapshot,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>}
def mutate_store(~S:Data,store:Game.Store(~S)) -> Game.Store(~S) & Unit:
  match store:
    case Product.Owner{Product.Owner{Leaf.Component{saved,_},transient},units}:(Product.Owner{Product.Owner{Leaf.Component{Setup.swapped(~S,Col.swap(~S,~F.Payload,saved,1,Some{F.payload(11,13)})),Decl.constructed(~S,~F.Payload,~F.declaration(~S),~F.project,D.ArrayValue{D.FiniteNumber{}})},transient},units},Unit{})
def mutate_resource(~S:Data,owner:Game.ResourceStore(~S)) -> Game.ResourceStore(~S) & Unit:
  match owner:
    case Product.Owner{units,Product.Owner{Leaf.Resource{_,_},transient}}:(Product.Owner{units,Product.Owner{Leaf.Resource{F.payload(31,33),Decl.constructed(~S,~F.Payload,~Game.settings(~S),~F.project,D.ArrayValue{D.LiteralValues{[D.Number{31},D.Number{33}]}})},transient}},Unit{})
def third(~S:Data,first:Export.Snapshot,second:Export.Snapshot,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Export.Snapshot) -> Saved<S>:
  match observed:
    case (world,after):Saved{world,first,second,after,firstOwner,secondOwner}
def mutated_resource(~S:Data,first:Export.Snapshot,second:Export.Snapshot,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Unit) -> Saved<S>:
  match observed:
    case (world,_):third(~S,first,second,firstOwner,secondOwner,Save.save(~S,world))
def mutated_store(~S:Data,first:Export.Snapshot,second:Export.Snapshot,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Unit) -> Saved<S>:
  match observed:
    case (world,_):mutated_resource(~S,first,second,firstOwner,secondOwner,W.observe_resource(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~Unit,~mutate_resource(~S),world))
def second_owner(~S:Data,first:Export.Snapshot,second:Export.Snapshot,firstOwner:Owner.Observed<S>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Owner.Observed<S>) -> Saved<S>:
  match observed:
    case (world,secondOwner):mutated_store(~S,first,second,firstOwner,secondOwner,W.with_store(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~Unit,mutate_store(~S),world))
def second(~S:Data,first:Export.Snapshot,firstOwner:Owner.Observed<S>,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Export.Snapshot) -> Saved<S>:
  match observed:
    case (world,second):second_owner(~S,first,second,firstOwner,Owner.observe(~S,world))
def first_owner(~S:Data,first:Export.Snapshot,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Owner.Observed<S>) -> Saved<S>:
  match observed:
    case (world,firstOwner):second(~S,first,firstOwner,Save.save(~S,world))
def first(~S:Data,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Export.Snapshot) -> Saved<S>:
  match observed:
    case (world,snapshot):first_owner(~S,snapshot,Owner.observe(~S,world))
def consume(~S:Data,world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> Saved<S>:
  first(~S,Save.save(~S,world))
