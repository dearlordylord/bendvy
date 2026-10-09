import Base
import provider.bend as P
import gameplay.bend as G
import context.bend as Ctx
import conditions.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import hooks.bend as H
import readers.bend as R
import catalog.bend as Cat
import slots.bend as Slots
import observe.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch

type Action<S: Data> is Data:
  Body{key: U32,name: String,operation: G.Operation}
  Marker{enabled: Bool}
  Deferred{}
  Read{key: U32,name: String,fails: Bool}
  GatedRead{key: U32,name: String,condition: C.Tree<P.Atom<S>>}
  Gate{key: U32,name: String,condition: C.Tree<P.Atom<S>>}
type FramePlan<S: Data> is Data:
  FramePlan{label: String,actions: List<&2,Action<S>>}
type Owners<S: Data> is Type:
  Owners{users: Cat.Catalog<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>,hooks: H.Owners<S,(world => operation => Ctx.hook_runner(~S,world,operation))>,readers: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>>,attempts: List<&2,String>,deliveries: List<&2,String>,conditions: List<&2,String>,active: List<&2,Action<S>>}

def operation_view(operation: G.Operation) -> String:
  match operation:
    case G.Seed{}: "Seed"
    case G.Queue{}: "Queue"
    case G.OldPending{}: "OldPending"
    case G.FailingPublisher{error}: "FailingPublisher:" ++ error
    case G.Reset{}: "Reset"
    case G.MarkerQueues{}: "MarkerQueues"
    case G.SameSet{}: "SameSet"
    case G.SameSkip{}: "SameSkip"
    case G.OverwriteSkip{}: "OverwriteSkip"
    case G.PauseRequest{}: "PauseRequest"
    case G.PlayRequest{}: "PlayRequest"
    case G.Noop{}: "Noop"
def atom_view(~S: Data,atom: P.Atom<S>) -> String:
  match atom:
    case P.InFlow{value}: "Flow=" ++ O.flow(value)
    case P.InLevel{value}: "Level=" ++ O.level(value)
    case P.FlowChanged{}: "FlowChanged"
    case P.LevelChanged{}: "LevelChanged"
def condition_view(~S: Data,tree: C.Tree<P.Atom<S>>) -> String:
  match tree:
    case C.Leaf{atom}: atom_view(~S,atom)
    case C.Constant{value}: O.bool(value)
    case C.Negate{inner}: "not(" ++ condition_view(~S,inner) ++ ")"
    case C.Both{left,right}: "and(" ++ condition_view(~S,left) ++ "," ++ condition_view(~S,right) ++ ")"
    case C.Either{left,right}: "or(" ++ condition_view(~S,left) ++ "," ++ condition_view(~S,right) ++ ")"
def action_view(~S: Data,action: Action<S>) -> String:
  match action:
    case Body{key,name,operation}: "Body:" ++ U32.show(key) ++ ":" ++ name ++ ":" ++ operation_view(operation)
    case Marker{value}: "Marker:" ++ O.bool(value)
    case Deferred{}: "Deferred"
    case Read{key,name,fails}: "Read:" ++ U32.show(key) ++ ":" ++ name ++ ":" ++ O.bool(fails)
    case GatedRead{key,name,tree}: "GatedRead:" ++ U32.show(key) ++ ":" ++ name ++ ":" ++ condition_view(~S,tree)
    case Gate{key,name,tree}: "Gate:" ++ U32.show(key) ++ ":" ++ name ++ ":" ++ condition_view(~S,tree)

def attempt(operation: G.Operation,rows: List<&2,String>) -> List<&2,String>:
  match operation:
    case G.Queue{}: List.append(&2,String,rows,["overwrite:Boot:Pause"])
    case G.Reset{}: List.append(&2,String,rows,["reset:none"])
    case G.FailingPublisher{_}: List.append(&2,String,rows,["failed-publisher"])
    case _: rows
def delivery(name: String,result: Maybe<&2,R.Delivery>,rows: List<&2,String>) -> List<&2,String>:
  match result:
    case None{}: rows
    case Some{R.Delivery{flow,level,fl,ll}}:
      List.append(&2,String,rows,[name ++ ":flow=" ++ List.show(&2,M.Transition<P.Flow>,(x => O.transition(~P.Flow,~O.flow,x)),flow) ++ ":level=" ++ List.show(&2,M.Transition<P.Level>,(x => O.transition(~P.Level,~O.level,x)),level) ++ ":lagged=" ++ O.bool(fl) ++ "," ++ O.bool(ll)])

def body_result(~S: Data,rest: Owners<S>,operation: G.Operation,result: Cat.CatalogResult<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match rest result:
    case Owners{_,hooks,readers,attempts,deliveries,conditions,active}, Cat.Completed{users,outcome}:
      (Owners{users,hooks,readers,attempt(operation,attempts),deliveries,conditions,active},outcome)
    case Owners{_,hooks,readers,attempts,deliveries,conditions,active}, Cat.Refused{users,world,_}:
      (Owners{users,hooks,readers,attempts,deliveries,conditions,active},Sys.Failed{world,"BodyRegistrationRejected"})
def run_body(~S: Data,owners: Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,key: U32,name: String,+operation: G.Operation) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match owners:
    case Owners{users,hooks,readers,attempts,deliveries,conditions,active}:
      body_result(~S,Owners{Cat.Catalog{[]},hooks,readers,attempts,deliveries,conditions,active},operation,Cat.invoke(~S,~P.Store<S>,~P.Resources<S>,~Unit,~G.Operation,~String,~Unit,~(world => operation => Ctx.runner(~S,world,operation)),users,world,key,name,["machine.Flow.read","machine.Flow.next","machine.Level.next","component.cells.write","resource.owned.write","commands.spawn"],operation))

def read_result(~S: Data,rest: Owners<S>,key: U32,name: String,entries: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>>,result: R.Returned<S,(world => input => R.runner(~S,world,input))>) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match rest result:
    case Owners{users,hooks,_,attempts,deliveries,conditions,active}, R.Returned{instance,world,report,"ok"}:
      (Owners{users,hooks,Slots.Entry{key,instance} <> entries,attempts,delivery(name,report,deliveries),conditions,active},Sys.Succeeded{world,Unit{}})
    case Owners{users,hooks,_,attempts,deliveries,conditions,active}, R.Returned{instance,world,report,status}:
      (Owners{users,hooks,Slots.Entry{key,instance} <> entries,attempts,delivery(name,report,deliveries),conditions,active},Sys.Failed{world,status})
def with_readers(~S: Data,owners: Owners<S>,entries: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>>) -> Owners<S>:
  match owners:
    case Owners{users,hooks,_,attempts,deliveries,conditions,active}: Owners{users,hooks,entries,attempts,deliveries,conditions,active}

def read_provisioned(~S: Data,rest: Owners<S>,key: U32,name: String,fails: Bool,entries: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>>,result: R.Provision<S,(world => input => R.runner(~S,world,input))>) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match result:
    case R.Provisioned{world,instance}: read_result(~S,rest,key,name,entries,R.invoke(~S,~(world => input => R.runner(~S,world,input)),instance,world,fails))
    case R.ProvisionFailed{world}: (with_readers(~S,rest,entries),Sys.Failed{world,"ReaderProvisionRejected"})
def read_selected(~S: Data,rest: Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,key: U32,+name: String,fails: Bool,selected: Slots.Selected<R.Instance<S,(world => input => R.runner(~S,world,input))>>) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match selected:
    case Slots.Selected{Some{instance},entries}: read_result(~S,rest,key,name,entries,R.invoke(~S,~(world => input => R.runner(~S,world,input)),instance,world,fails))
    case Slots.Selected{None{},entries}: read_provisioned(~S,rest,key,name,fails,entries,R.provision(~S,~(world => input => R.runner(~S,world,input)),world,name))
def run_reader(~S: Data,owners: Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,+key: U32,name: String,fails: Bool) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match owners:
    case Owners{users,hooks,readers,attempts,deliveries,conditions,active}:
      read_selected(~S,Owners{users,hooks,[],attempts,deliveries,conditions,active},world,key,name,fails,Slots.take(~R.Instance<S,(world => input => R.runner(~S,world,input))>,readers,key))

def skip_returned(~S: Data,rest: Owners<S>,key: U32,entries: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>>,pair: R.Instance<S,(world => input => R.runner(~S,world,input))> & W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match rest pair:
    case Owners{users,hooks,_,attempts,deliveries,conditions,active}, (instance,world):
      (Owners{users,hooks,Slots.Entry{key,instance} <> entries,attempts,deliveries,conditions,active},Sys.Succeeded{world,Unit{}})
def skip_selected(~S: Data,rest: Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,key: U32,selected: Slots.Selected<R.Instance<S,(world => input => R.runner(~S,world,input))>>) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match rest selected:
    case rest, Slots.Selected{Some{instance},entries}: skip_returned(~S,rest,key,entries,R.skip(~S,~(world => input => R.runner(~S,world,input)),instance,world))
    case Owners{users,hooks,_,attempts,deliveries,conditions,active}, Slots.Selected{None{},entries}:
      (Owners{users,hooks,entries,attempts,deliveries,conditions,active},Sys.Succeeded{world,Unit{}})
def skip_reader(~S: Data,owners: Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,+key: U32) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match owners:
    case Owners{users,hooks,readers,attempts,deliveries,conditions,active}:
      skip_selected(~S,Owners{users,hooks,[],attempts,deliveries,conditions,active},world,key,Slots.take(~R.Instance<S,(world => input => R.runner(~S,world,input))>,readers,key))

def gate_completed(~S: Data,+name: String,result: Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match result:
    case (Owners{users,hooks,readers,attempts,deliveries,conditions,active},Sys.Succeeded{world,output}):
      (Owners{users,hooks,readers,attempts,deliveries,List.append(&2,String,conditions,[name]),active},Sys.Succeeded{world,output})
    case result: result
def gate_checked(~S: Data,owners: Owners<S>,key: U32,+name: String,checked: W.World<S,P.Store<S>,P.Resources<S>,Unit> & P.ConditionCheck) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match checked:
    case (world,P.ConditionMissing{}): (owners,Sys.Failed{world,"ConditionProvisionRejected"})
    case (world,P.ConditionValue{False{}}): (owners,Sys.Succeeded{world,Unit{}})
    case (world,P.ConditionValue{True{}}): gate_completed(~S,name,run_body(~S,owners,world,key,name,G.Noop{}))
def reader_checked(~S: Data,owners: Owners<S>,key: U32,name: String,checked: W.World<S,P.Store<S>,P.Resources<S>,Unit> & P.ConditionCheck) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match checked:
    case (world,P.ConditionMissing{}): (owners,Sys.Failed{world,"ConditionProvisionRejected"})
    case (world,P.ConditionValue{False{}}): skip_reader(~S,owners,world,key)
    case (world,P.ConditionValue{True{}}): run_reader(~S,owners,world,key,name,False{})

def marker_returned(~S: Data,users: Cat.Catalog<S,P.Store<S>,P.Resources<S>,Unit,G.Operation,String,Unit,(world => operation => Ctx.runner(~S,world,operation))>,readers: List<&1,Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>>>,attempts: List<&2,String>,deliveries: List<&2,String>,conditions: List<&2,String>,active: List<&2,Action<S>>,pair: H.Owners<S,(world => operation => Ctx.hook_runner(~S,world,operation))> & W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match pair:
    case (hooks,world): (Owners{users,hooks,readers,attempts,deliveries,conditions,active},Sys.Succeeded{world,Unit{}})
def run_marker(~S: Data,owners: Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,enabled: Bool) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match owners:
    case Owners{users,hooks,readers,attempts,deliveries,conditions,active}:
      marker_returned(~S,users,readers,attempts,deliveries,conditions,active,H.run(~S,~(world => operation => Ctx.hook_runner(~S,world,operation)),hooks,world,enabled))

def action_id(~S: Data,action: Action<S>) -> U32:
  match action:
    case Body{key,_,_}: key
    case Read{key,_,_}: key
    case GatedRead{key,_,_}: key
    case Gate{key,_,_}: key
    case Marker{_}: 100
    case Deferred{}: 101
def find_checked(~S: Data,same: Bool,action: Action<S>,tail: Maybe<&2,Action<S>>) -> Maybe<&2,Action<S>>:
  match same:
    case True{}: Some{action}
    case False{}: tail
def find(~S: Data,actions: List<&2,Action<S>>,+id: U32) -> Maybe<&2,Action<S>>:
  match actions:
    case Nil{}: None{}
    case Con{+action,rest}: find_checked(~S,U32.is_eq(action_id(~S,action),id),action,find(~S,rest,id))

def action(~S: Data,owners: Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,chosen: Maybe<&2,Action<S>>) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match chosen:
    case None{}: (owners,Sys.Failed{world,"MissingScheduleAction"})
    case Some{Body{key,name,operation}}: run_body(~S,owners,world,key,name,operation)
    case Some{Read{key,name,fails}}: run_reader(~S,owners,world,key,name,fails)
    case Some{GatedRead{key,name,condition}}: reader_checked(~S,owners,key,name,P.condition_world(~S,world,condition))
    case Some{Gate{key,name,condition}}: gate_checked(~S,owners,key,name,P.condition_world(~S,world,condition))
    case Some{Marker{enabled}}: run_marker(~S,owners,world,enabled)
    case Some{Deferred{}}: (owners,Sys.Succeeded{P.pulse(~S,W.barrier(~S,~P.Store<S>,~P.Resources<S>,~Unit,world)),Unit{}})
def dispatch(~S: Data,owners: Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,id: U32) -> Owners<S> & Sys.Outcome<W.World<S,P.Store<S>,P.Resources<S>,Unit>,String,Unit>:
  match owners:
    case Owners{users,hooks,readers,attempts,deliveries,conditions,+active}:
      action(~S,Owners{users,hooks,readers,attempts,deliveries,conditions,active},world,find(~S,active,id))
def condition(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,_: U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & Bool:
  (world,True{})
def steps(~S: Data,actions: List<&2,Action<S>>) -> List<&2,Sch.Step>:
  match actions:
    case Nil{}: []
    case Con{head,rest}: Sch.System{action_id(~S,head),0} <> steps(~S,rest)
def ids(~S: Data,actions: List<&2,Action<S>>) -> List<&2,U32>:
  match actions:
    case Nil{}: []
    case Con{head,rest}: action_id(~S,head) <> ids(~S,rest)

def slots_present(~S: Data,+env: P.ConditionEnv<S>) -> Bool:
  match env:
    case P.ConditionEnv{flow,level}: Bool.and(P.slot_present(~S,~P.FlowToken,~P.Flow,flow),P.slot_present(~S,~P.LevelToken,~P.Level,level))
def action_ready(~S: Data,action: Action<S>,env: P.ConditionEnv<S>) -> Bool:
  match action:
    case Body{_,_,G.Seed{}}: True{}
    case Body{_,_,_}: slots_present(~S,env)
    case Marker{False{}}: True{}
    case Marker{True{}}: slots_present(~S,env)
    case Deferred{}: True{}
    case Read{_,_,_}: slots_present(~S,env)
    case GatedRead{_,_,_}: slots_present(~S,env)
    case Gate{_,_,tree}: P.condition_provisioned(~S,P.condition_needs(~S,tree),env)
def ready(~S: Data,actions: List<&2,Action<S>>,+env: P.ConditionEnv<S>) -> Bool:
  match actions:
    case Nil{}: True{}
    case Con{head,rest}: Bool.and(action_ready(~S,head,env),ready(~S,rest,env))
def provision_checked(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,actions: List<&2,Action<S>>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & Bool:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,+flow,+level,flowStream,levelStream,frame,tick,trace},events,commands,registrations,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace},events,commands,registrations,nextSystem,clock},ready(~S,actions,P.ConditionEnv{flow,level}))

type FrameResult<S: Data> is Type:
  FrameResult{owners: Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,status: String}
def schedule_returned(~S: Data,result: Sch.RunResult<S,P.Store<S>,P.Resources<S>,Unit,Owners<S>,String>) -> FrameResult<S>:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,owners},world,_}: FrameResult{owners,world,"ok"}
    case Sch.Failed{Sch.Schedule{_,_,_,owners},world,error,_}: FrameResult{owners,world,"failed:" ++ error}
    case Sch.Rejected{Sch.Schedule{_,_,_,owners},world}: FrameResult{owners,world,"schedule-namespace-rejected"}
def built(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,result: Sch.Build<S,P.Store<S>,P.Resources<S>,Unit,Owners<S>>) -> FrameResult<S>:
  match result:
    case Sch.Invalid{owners}: FrameResult{owners,world,"invalid-schedule"}
    case Sch.Built{schedule}: schedule_returned(~S,Sch.run(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Owners<S>,~String,~(h => w => id => dispatch(~S,h,w,id)),~(w => id => condition(~S,w,id)),schedule,world))
def named(~S: Data,owners: Owners<S>,+name: String,+actions: List<&2,Action<S>>,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & U32) -> FrameResult<S>:
  match owners pair:
    case Owners{users,hooks,readers,attempts,deliveries,conditions,_}, (world,namespace):
      built(~S,P.frame(~S,world),Sch.build(~S,~P.Store<S>,~P.Resources<S>,~Unit,~Owners<S>,namespace,name,steps(~S,actions),ids(~S,actions),Owners{users,hooks,readers,attempts,deliveries,conditions,actions}))
def checked(~S: Data,owners: Owners<S>,name: String,+actions: List<&2,Action<S>>,pair: W.World<S,P.Store<S>,P.Resources<S>,Unit> & Bool) -> FrameResult<S>:
  match pair:
    case (world,False{}): FrameResult{owners,world,"machine-provision-rejected"}
    case (world,True{}): named(~S,owners,name,actions,W.namespace(~S,~P.Store<S>,~P.Resources<S>,~Unit,world))
def frame(~S: Data,owners: Owners<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,name: String,+actions: List<&2,Action<S>>) -> FrameResult<S>:
  checked(~S,owners,name,actions,provision_checked(~S,world,actions))
