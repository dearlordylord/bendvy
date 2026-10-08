import Base
import ./legacy-fixture.bend as F
import ./game.bend as Game
import ../library/snapshot-leaf.bend as Leaf
import ../library/persistence-declaration.bend as Decl
import ../library/owner-product.bend as Product
import ./setup.bend as Setup
import ./consumer.bend as Consumer
import ../library/snapshot-data.bend as Export
import ./world-owner.bend as Owner
import ./validation.bend as Validation
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import ../library/decode-data.bend as D

type Report<-S:Data> is Data:
  Report{before:Owner.Observed<S>,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,first:Export.Snapshot,second:Export.Snapshot,after:Export.Snapshot,firstValidation:Validation.Validation,afterValidation:Validation.Validation,owner:Owner.Observed<S>}
type Finished<-S:Data> is Type:
  Finished{factory:W.Factory,report:Report<S>}
  SetupRefused{factory:W.Factory,world:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit>,incoming:Maybe<F.Payload>}
  CreationRefused{factory:W.Factory,resource:Game.ResourceStore(~S)}
def finish(~S:Data,factory:W.Factory,before:Owner.Observed<S>,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,first:Export.Snapshot,second:Export.Snapshot,after:Export.Snapshot,firstValidation:Validation.Validation,afterValidation:Validation.Validation,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Owner.Observed<S>) -> Finished<S>:
  match observed:
    case (_,owner):Finished{factory,Report{before,firstOwner,secondOwner,first,second,after,firstValidation,afterValidation,owner}}
def checked_after(~S:Data,factory:W.Factory,before:Owner.Observed<S>,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,first:Export.Snapshot,second:Export.Snapshot,after:Export.Snapshot,firstValidation:Validation.Validation,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Validation.Validation) -> Finished<S>:
  match observed:
    case (world,afterValidation):finish(~S,factory,before,firstOwner,secondOwner,first,second,after,firstValidation,afterValidation,Owner.observe(~S,world))
def checked_first(~S:Data,factory:W.Factory,before:Owner.Observed<S>,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,first:Export.Snapshot,second:Export.Snapshot,+after:Export.Snapshot,observed:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Validation.Validation) -> Finished<S>:
  match observed:
    case (world,firstValidation):checked_after(~S,factory,before,firstOwner,secondOwner,first,second,after,firstValidation,Validation.validate(~S,after,world))
def saved(~S:Data,factory:W.Factory,before:Owner.Observed<S>,result:Consumer.Saved<S>) -> Finished<S>:
  match result:
    case Consumer.Saved{world,+first,second,after,firstOwner,secondOwner}:checked_first(~S,factory,before,firstOwner,secondOwner,first,second,after,Validation.validate(~S,first,world))
def observed_before(~S:Data,factory:W.Factory,result:W.World<S,Game.Store(~S),Game.ResourceStore(~S),Unit> & Owner.Observed<S>) -> Finished<S>:
  match result:
    case (world,before):saved(~S,factory,before,Consumer.consume(~S,world))
def setup_done(~S:Data,factory:W.Factory,result:Setup.Setup<S>) -> Finished<S>:
  match result:
    case Setup.Ready{world}:observed_before(~S,factory,Owner.observe(~S,world))
    case Setup.Refused{world,incoming}:SetupRefused{factory,world,incoming}
def created(~S:Data,result:W.Creation<S,Game.Store(~S),Game.ResourceStore(~S),Unit>) -> Finished<S>:
  match result:
    case W.Created{factory,world}:setup_done(~S,factory,Setup.setup(~S,world))
    case W.CreateRejected{factory,resource}:CreationRefused{factory,resource}
def admitted_resource(~S:Data,factory:W.Factory,units:Product.Owner<Unit,Unit>,scratch:Game.ScratchSettings(~S),prepared:Decl.Constructed<S,F.Payload,Game.settings(~S),F.project> & D.Receipt<F.Payload>) -> Finished<S>:
  match prepared:
    case (declaration,D.Receipt{owner,D.Accepted{_}}):created(~S,W.create(~S,~Game.Store(~S),~Game.ResourceStore(~S),~Unit,~Game.empty(~S),factory,Product.Owner{units,Product.Owner{Leaf.Resource{owner,declaration},scratch}}))
    case (declaration,D.Receipt{owner,D.Rejected{_}}):CreationRefused{factory,Product.Owner{units,Product.Owner{Leaf.Resource{owner,declaration},scratch}}}
def initial_resource(~S:Data,factory:W.Factory,resource:Game.ResourceStore(~S)) -> Finished<S>:
  match resource:
    case Product.Owner{units,Product.Owner{Leaf.Resource{owner,declaration},scratch}}:admitted_resource(~S,factory,units,scratch,Decl.prepare(~S,~F.Payload,~Game.settings(~S),~F.project,declaration,owner))
def run(~S:Data,factory:W.Factory) -> Finished<S>:
  initial_resource(~S,factory,Game.initial_resources(~S))
