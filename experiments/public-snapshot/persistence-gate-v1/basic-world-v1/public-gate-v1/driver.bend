import Base
import ../fixture.bend as F
import ../setup.bend as Setup
import ./consumer.bend as Consumer
import ../export.bend as Export
import ../world-owner.bend as Owner
import ../validation.bend as Validation
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D

type Report<-S:Data> is Data:
  Report{before:Owner.Observed<S>,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,first:Export.Snapshot,second:Export.Snapshot,after:Export.Snapshot,firstValidation:Validation.Validation,afterValidation:Validation.Validation,owner:Owner.Observed<S>}
type Finished<-S:Data> is Type:
  Finished{factory:W.Factory,report:Report<S>}
  SetupRefused{factory:W.Factory,world:W.World<S,F.Store<S>,F.Resources,Unit>}
  CreationRefused{factory:W.Factory,resource:F.Resources}
def finish(~S:Data,factory:W.Factory,before:Owner.Observed<S>,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,first:Export.Snapshot,second:Export.Snapshot,after:Export.Snapshot,firstValidation:Validation.Validation,afterValidation:Validation.Validation,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Owner.Observed<S>) -> Finished<S>:
  match observed:
    case (_,owner):Finished{factory,Report{before,firstOwner,secondOwner,first,second,after,firstValidation,afterValidation,owner}}
def checked_after(~S:Data,factory:W.Factory,before:Owner.Observed<S>,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,first:Export.Snapshot,second:Export.Snapshot,after:Export.Snapshot,firstValidation:Validation.Validation,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Validation.Validation) -> Finished<S>:
  match observed:
    case (world,afterValidation):finish(~S,factory,before,firstOwner,secondOwner,first,second,after,firstValidation,afterValidation,Owner.observe(~S,world))
def checked_first(~S:Data,factory:W.Factory,before:Owner.Observed<S>,firstOwner:Owner.Observed<S>,secondOwner:Owner.Observed<S>,first:Export.Snapshot,second:Export.Snapshot,+after:Export.Snapshot,observed:W.World<S,F.Store<S>,F.Resources,Unit> & Validation.Validation) -> Finished<S>:
  match observed:
    case (world,firstValidation):checked_after(~S,factory,before,firstOwner,secondOwner,first,second,after,firstValidation,Validation.validate(~S,after,world))
def saved(~S:Data,factory:W.Factory,before:Owner.Observed<S>,result:Consumer.Saved<S>) -> Finished<S>:
  match result:
    case Consumer.Saved{world,+first,second,after,firstOwner,secondOwner}:checked_first(~S,factory,before,firstOwner,secondOwner,first,second,after,Validation.validate(~S,first,world))
def observed_before(~S:Data,factory:W.Factory,result:W.World<S,F.Store<S>,F.Resources,Unit> & Owner.Observed<S>) -> Finished<S>:
  match result:
    case (world,before):saved(~S,factory,before,Consumer.consume(~S,world))
def setup_done(~S:Data,factory:W.Factory,result:Setup.Setup<S>) -> Finished<S>:
  match result:
    case Setup.Ready{world}:observed_before(~S,factory,Owner.observe(~S,world))
    case Setup.Refused{world}:SetupRefused{factory,world}
def created(~S:Data,result:W.Creation<S,F.Store<S>,F.Resources,Unit>) -> Finished<S>:
  match result:
    case W.Created{factory,world}:setup_done(~S,factory,Setup.setup(~S,world))
    case W.CreateRejected{factory,resource}:CreationRefused{factory,resource}
def run(~S:Data,factory:W.Factory) -> Finished<S>:
  created(~S,W.create(~S,~F.Store<S>,~F.Resources,~Unit,~F.empty(~S),factory,F.Resources{F.payload(27,29),F.payload(127,129),D.ArrayValue{D.Integer{}}}))
