import Base
import initial.bend as Init
import declared-missing-mutant.bend as Decl
import observer.bend as Obs
import scene/observe.bend as O
import scene/application.bend as A
import scene/provider.bend as P
import scene/readers.bend as R
import scene/hooks.bend as H
import scene/context.bend as Ctx
import scene/catalog.bend as Cat
import scene/slots.bend as Slots
import scene/stream.bend as St
import scene/conditions.bend as Cond
import scene/gameplay.bend as G
import ../../../../../bendvy/src/ecs/machine.bend as M
import ../../../../../bendvy/src/ecs/world.bend as W

type Delivered<S: Data> is Type:
  Delivered{factory: W.Factory,observed: Obs.Observed<S>,incoming: Maybe<&2,P.Flow>}
  SetupFailed{factory: W.Factory,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,hooks: Maybe<&1,H.Owners<S,(w => op => Ctx.hook_runner(~S,w,op))>>}
  OccupiedSetup{factory: W.Factory,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,owners: A.Owners<S>,flow: Maybe<&2,P.Flow>,level: Maybe<&2,P.Level>}
  CreateFailed{factory: W.Factory,resource: P.Resources<S>}

def resources(~S: Data) -> P.Resources<S>:
  P.Resources{ANode{ALeaf{30},ALeaf{130}},Init.empty(~S,~P.FlowToken,~P.Flow),Init.empty(~S,~P.LevelToken,~P.Level),St.empty(~P.Flow),St.empty(~P.Level),0n,0n,[]}
def flow_family(~S: Data) -> M.Family<S,P.FlowToken,P.Flow,W.World<S,P.Store<S>,P.Resources<S>,Unit>,(w => P.flow_take(~S,w)),(w => slot => P.flow_put(~S,w,slot))>:
  M.Family{"Flow"}
def level_family(~S: Data) -> M.Family<S,P.LevelToken,P.Level,W.World<S,P.Store<S>,P.Resources<S>,Unit>,(w => P.level_take(~S,w)),(w => slot => P.level_put(~S,w,slot))>:
  M.Family{"Level"}

def frame(~S: Data,+label: String,+items: List<&2,A.Action<S>>,current: Obs.Observed<S>) -> Obs.Observed<S>:
  match current:
    case Obs.Observed{owners,world,rows}: Obs.checkpoint(~S,label,rows,Decl.frame(~S,owners,world,Decl.declare(~S,label,items)))
def snapshot(~S: Data,label: String,status: String,owners: A.Owners<S>,rows: List<&2,String>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Obs.Observed<S>:
  Obs.checkpoint(~S,label,rows,A.FrameResult{owners,world,status})

def finished(~S: Data,factory: W.Factory,current: Obs.Observed<S>,incoming: Maybe<&2,P.Flow>) -> Delivered<S>:
  Delivered{factory,current,incoming}
def occupied(~S: Data,factory: W.Factory,owners: A.Owners<S>,rows: List<&2,String>,result: Init.Installation<W.World<S,P.Store<S>,P.Resources<S>,Unit>,P.Flow>) -> Delivered<S>:
  match result:
    case Init.Installed{world}: finished(~S,factory,snapshot(~S,"private-occupied-control","unexpected-empty-slot",owners,rows,world),None{})
    case Init.Occupied{world,+incoming}: finished(~S,factory,snapshot(~S,"private-occupied-control","occupied-incoming:" ++ O.flow(incoming),owners,rows,world),Some{incoming})
def after_frames(~S: Data,factory: W.Factory,current: Obs.Observed<S>) -> Delivered<S>:
  match current:
    case Obs.Observed{owners,world,rows}:
      occupied(~S,factory,owners,rows,Init.install_empty(~S,~P.FlowToken,~P.Flow,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~(w => P.flow_take(~S,w)),~(w => slot => P.flow_put(~S,w,slot)),flow_family(~S),world,P.Pause{}))
def level_installed(~S: Data,factory: W.Factory,owners: A.Owners<S>,rows: List<&2,String>,result: Init.Installation<W.World<S,P.Store<S>,P.Resources<S>,Unit>,P.Level>) -> Delivered<S>:
  match result:
    case Init.Occupied{world,incoming}: OccupiedSetup{factory,world,owners,None{},Some{incoming}}
    case Init.Installed{world}:
      current=snapshot(~S,"level-installed","ok",owners,rows,world)
      current=frame(~S,"reader-retry",[A.Read{12,"retained-reader",False{}}],current)
      current=frame(~S,"seed",[A.Body{1,"seed",G.Seed{}},A.Deferred{}],current)
      current=frame(~S,"old-pending",[A.Body{2,"old",G.OldPending{}}],current)
      current=frame(~S,"failed-publisher",[A.Body{3,"fails",G.FailingPublisher{"planned"}}],current)
      current=frame(~S,"failed-reader",[A.Read{12,"retained-reader",True{}}],current)
      after_frames(~S,factory,frame(~S,"failed-reader-retry",[A.Read{12,"retained-reader",False{}}],current))
def level_ready(~S: Data,factory: W.Factory,current: Obs.Observed<S>) -> Delivered<S>:
  match current:
    case Obs.Observed{owners,world,rows}:
      level_installed(~S,factory,owners,rows,Init.install_empty(~S,~P.LevelToken,~P.Level,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~(w => P.level_take(~S,w)),~(w => slot => P.level_put(~S,w,slot)),level_family(~S),world,P.Low{}))
def flow_installed(~S: Data,factory: W.Factory,owners: A.Owners<S>,rows: List<&2,String>,result: Init.Installation<W.World<S,P.Store<S>,P.Resources<S>,Unit>,P.Flow>) -> Delivered<S>:
  match result:
    case Init.Occupied{world,incoming}: OccupiedSetup{factory,world,owners,Some{incoming},None{}}
    case Init.Installed{world}:
      current=snapshot(~S,"flow-installed","ok",owners,rows,world)
      current=frame(~S,"present-state-exists",[A.Gate{22,"exists",Cond.Leaf{P.FlowExists{}}}],current)
      current=frame(~S,"reader-level-missing",[A.Read{12,"retained-reader",False{}}],current)
      current=frame(~S,"flow-only-false-gate",[A.Gate{20,"flow-only",Cond.Leaf{P.InFlow{P.Play{}}}}],current)
      level_ready(~S,factory,current)
def flow_ready(~S: Data,factory: W.Factory,current: Obs.Observed<S>) -> Delivered<S>:
  match current:
    case Obs.Observed{owners,world,rows}:
      flow_installed(~S,factory,owners,rows,Init.install_empty(~S,~P.FlowToken,~P.Flow,~W.World<S,P.Store<S>,P.Resources<S>,Unit>,~(w => P.flow_take(~S,w)),~(w => slot => P.flow_put(~S,w,slot)),flow_family(~S),world,P.Boot{}))
def initial_owners(~S: Data,hooks: H.Owners<S,(w => op => Ctx.hook_runner(~S,w,op))>,instance: R.Instance<S,(w => input => R.runner(~S,w,input))>) -> A.Owners<S>:
  A.Owners{Cat.Catalog{[]},hooks,[Slots.Entry{12,instance}],[],[],[],[]}
def reader_registered(~S: Data,factory: W.Factory,hooks: H.Owners<S,(w => op => Ctx.hook_runner(~S,w,op))>,result: R.Provision<S,(w => input => R.runner(~S,w,input))>) -> Delivered<S>:
  match result:
    case R.ProvisionFailed{world}: SetupFailed{factory,world,Some{hooks}}
    case R.Provisioned{world,instance}:
      owners=initial_owners(~S,hooks,instance)
      current=snapshot(~S,"missing-initial","ok",owners,[],world)
      current=frame(~S,"required-reader-missing",[A.Read{12,"retained-reader",False{}}],current)
      current=frame(~S,"missing-state-exists",[A.Gate{22,"exists",Cond.Leaf{P.FlowExists{}}}],current)
      current=frame(~S,"true-or-missing",[A.Gate{20,"true-or",Cond.Either{Cond.Constant{True{}},Cond.Leaf{P.InFlow{P.Boot{}}}}}],current)
      current=frame(~S,"negated-missing",[A.Gate{20,"not",Cond.Negate{Cond.Leaf{P.InLevel{P.Low{}}}}}],current)
      flow_ready(~S,factory,current)
def hooks_registered(~S: Data,factory: W.Factory,result: H.Provision<S,(w => op => Ctx.hook_runner(~S,w,op))>) -> Delivered<S>:
  match result:
    case H.ProvisionFailed{world}: SetupFailed{factory,world,None{}}
    case H.Provisioned{world,hooks}: reader_registered(~S,factory,hooks,R.provision(~S,~(w => input => R.runner(~S,w,input)),world,"retained-reader"))
def created(~S: Data,result: W.Creation<S,P.Store<S>,P.Resources<S>,Unit>) -> Delivered<S>:
  match result:
    case W.CreateRejected{factory,resource}: CreateFailed{factory,resource}
    case W.Created{factory,world}: hooks_registered(~S,factory,H.provision(~S,~(w => op => Ctx.hook_runner(~S,w,op)),world))
def scenario(~S: Data) -> Delivered<S>:
  created(~S,W.create(~S,~P.Store<S>,~P.Resources<S>,~Unit,~(u => P.empty_store(~S,u)),W.factory(),resources(~S)))
def teardown(~S: Data,result: Delivered<S>) -> String:
  match result:
    case Delivered{_,Obs.Observed{_,_,rows},_}: String.join(rows,"\n")
    case SetupFailed{_,_,_}: "setup-failed"
    case OccupiedSetup{_,_,_,_,_}: "private-occupied-setup"
    case CreateFailed{_,_}: "creation-failed"
def main() -> String:
  "SCHEMA=A\n" ++ teardown(~P.SchemaA,scenario(~P.SchemaA)) ++ "\nSCHEMA=B\n" ++ teardown(~P.SchemaB,scenario(~P.SchemaB))
