import Base
import ../consumer-source-v1/state.bend as State
import ../consumer-source-v1/dump.bend as Dump
import ../consumer-source-v1/consumer.bend as C
import ./host.bend as Host
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-optional-resource.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-optional-resource-run.bend as Run
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I

type Report<S:Data> is Data:
  Report{initial:String,optional:List<&2,C.Snapshot1(~S)>,optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,required:List<&2,C.Snapshot2(~S)>,requiredStatus:Run.Status<Maybe<&2,List<&2,U32>>>,host:List<&2,Host.Observation>}
def boundary1_after(~S:Data,before:C.Snapshot1(~S),carry:Host.Carry<S>,result:C.App1(~S) & C.Snapshot1(~S)) -> C.App1(~S) & (Host.Carry<S> & List<&2,C.Snapshot1(~S)>):
  match result:
    case (app,after):(app,(carry,[before,after]))
def boundary1_probed(~S:Data,before:C.Snapshot1(~S),result:C.App1(~S) & Host.Carry<S>) -> C.App1(~S) & (Host.Carry<S> & List<&2,C.Snapshot1(~S)>):
  match result:
    case (app,carry):boundary1_after(~S,before,carry,C.snapshot(~S,~C.Owners1(~S),~C.Rows1(~S),~C.observe1(~S),~C.fold1(~S),app))
def boundary1_before(~S:Data,carry:Host.Carry<S>,result:C.App1(~S) & C.Snapshot1(~S)) -> C.App1(~S) & (Host.Carry<S> & List<&2,C.Snapshot1(~S)>):
  match result:
    case (app,before):boundary1_probed(~S,before,Host.probe(~S,~C.Owners1(~S),~C.Rows1(~S),~C.observe1(~S),~C.fold1(~S),app,carry))
def boundary1(~S:Data,app:C.App1(~S),carry:Host.Carry<S>) -> C.App1(~S) & (Host.Carry<S> & List<&2,C.Snapshot1(~S)>):
  boundary1_before(~S,carry,C.snapshot(~S,~C.Owners1(~S),~C.Rows1(~S),~C.observe1(~S),~C.fold1(~S),app))
def boundary2_after(~S:Data,before:C.Snapshot2(~S),carry:Host.Carry<S>,result:C.App2(~S) & C.Snapshot2(~S)) -> C.App2(~S) & (Host.Carry<S> & List<&2,C.Snapshot2(~S)>):
  match result:
    case (app,after):(app,(carry,[before,after]))
def boundary2_probed(~S:Data,before:C.Snapshot2(~S),result:C.App2(~S) & Host.Carry<S>) -> C.App2(~S) & (Host.Carry<S> & List<&2,C.Snapshot2(~S)>):
  match result:
    case (app,carry):boundary2_after(~S,before,carry,C.snapshot(~S,~C.Owners2(~S),~C.Rows2(~S),~C.observe2(~S),~C.fold2(~S),app))
def boundary2_before(~S:Data,carry:Host.Carry<S>,result:C.App2(~S) & C.Snapshot2(~S)) -> C.App2(~S) & (Host.Carry<S> & List<&2,C.Snapshot2(~S)>):
  match result:
    case (app,before):boundary2_probed(~S,before,Host.probe(~S,~C.Owners2(~S),~C.Rows2(~S),~C.observe2(~S),~C.fold2(~S),app,carry))
def boundary2(~S:Data,app:C.App2(~S),carry:Host.Carry<S>) -> C.App2(~S) & (Host.Carry<S> & List<&2,C.Snapshot2(~S)>):
  boundary2_before(~S,carry,C.snapshot(~S,~C.Owners2(~S),~C.Rows2(~S),~C.observe2(~S),~C.fold2(~S),app))
def finish(~S:Data,initial:String,optional:List<&2,C.Snapshot1(~S)>,optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,requiredBefore:List<&2,C.Snapshot2(~S)>,requiredStatus:Run.Status<Maybe<&2,List<&2,U32>>>,result:C.App2(~S) & (Host.Carry<S> & List<&2,C.Snapshot2(~S)>)) -> W.Factory & Report<S>:
  match result:
    case (_,(Host.Carry{factory,_,host},requiredAfter)):(factory,Report{initial,optional,optionalStatus,List.append(&2,C.Snapshot2(~S),requiredBefore,requiredAfter),requiredStatus,host})
def required_run(~S:Data,initial:String,optional:List<&2,C.Snapshot1(~S)>,optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,requiredBefore:List<&2,C.Snapshot2(~S)>,carry:Host.Carry<S>,result:C.App2(~S) & Run.Status<Maybe<&2,List<&2,U32>>>) -> W.Factory & Report<S>:
  match result:
    case (app,status):finish(~S,initial,optional,optionalStatus,requiredBefore,status,boundary2(~S,app,carry))
def required_boundary(~S:Data,initial:String,optional:List<&2,C.Snapshot1(~S)>,optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,result:C.App2(~S) & (Host.Carry<S> & List<&2,C.Snapshot2(~S)>)) -> W.Factory & Report<S>:
  match result:
    case (app,(carry,before)):required_run(~S,initial,optional,optionalStatus,before,carry,Run.run_latest(~S,~Array<U32>,~State.Resource(~S),~U32,~Unit,~Maybe<&2,List<&2,U32>>,~C.runner2(~S),~C.Owners1(~S),~C.Rows2(~S),~C.observe2(~S),~C.fold2(~S),app,Unit{}))
def required_ready(~S:Data,initial:String,optional:List<&2,C.Snapshot1(~S)>,optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,app:C.App2(~S),carry:Host.Carry<S>) -> W.Factory & Report<S>:
  required_boundary(~S,initial,optional,optionalStatus,boundary2(~S,app,carry))
def required_failed(~S:Data,initial:String,optional:List<&2,C.Snapshot1(~S)>,optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,app:C.App1(~S),carry:Host.Carry<S>) -> W.Factory & Report<S>:
  match carry:
    case Host.Carry{factory,_,host}:(factory,Report{initial,optional,optionalStatus,[],Run.RegistrationRejected{},host})
def optional_register(~S:Data,+initial:String,+all:List<&2,C.Snapshot1(~S)>,+status:Run.Status<Maybe<&2,List<&2,U32>>>,app:C.App1(~S),carry:Host.Carry<S>) -> W.Factory & Report<S>:
  App.register(~S,~Array<U32>,~State.Resource(~S),~U32,~C.Owners1(~S),~C.Rows1(~S),~C.observe1(~S),~C.fold1(~S),~State.Ops(~S),~Unit,~Maybe<&2,List<&2,U32>>,~Maybe<&2,List<&2,U32>>,~State.required_declaration(~S),~State.body(~S),~(Host.Carry<S> -> W.Factory & Report<S>),(required_ready(~S,initial,all,status) : C.App2(~S) -> Host.Carry<S> -> W.Factory & Report<S>),(required_failed(~S,initial,all,status) : C.App1(~S) -> Host.Carry<S> -> W.Factory & Report<S>),app,"RequiredPayload","RequiredPayload")(carry)
def optional_after(~S:Data,initial:String,before:List<&2,C.Snapshot1(~S)>,status:Run.Status<Maybe<&2,List<&2,U32>>>,result:C.App1(~S) & (Host.Carry<S> & List<&2,C.Snapshot1(~S)>)) -> W.Factory & Report<S>:
  match result:
    case (app,(carry,after)):optional_register(~S,initial,List.append(&2,C.Snapshot1(~S),before,after),status,app,carry)
def optional_run(~S:Data,initial:String,before:List<&2,C.Snapshot1(~S)>,carry:Host.Carry<S>,result:C.App1(~S) & Run.Status<Maybe<&2,List<&2,U32>>>) -> W.Factory & Report<S>:
  match result:
    case (app,status):optional_after(~S,initial,before,status,boundary1(~S,app,carry))
def optional_boundary(~S:Data,initial:String,result:C.App1(~S) & (Host.Carry<S> & List<&2,C.Snapshot1(~S)>)) -> W.Factory & Report<S>:
  match result:
    case (app,(carry,before)):optional_run(~S,initial,before,carry,Run.run_latest(~S,~Array<U32>,~State.Resource(~S),~U32,~Unit,~Maybe<&2,List<&2,U32>>,~C.runner1(~S),~Unit,~C.Rows1(~S),~C.observe1(~S),~C.fold1(~S),app,Unit{}))
def optional_ready(~S:Data,initial:String,app:C.App1(~S),carry:Host.Carry<S>) -> W.Factory & Report<S>:
  optional_boundary(~S,initial,boundary1(~S,app,carry))
def optional_failed(~S:Data,initial:String,app:Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Unit,Unit,Build.empty_observe(~W.World<S,Array<U32>,State.Resource(~S),U32>),Leaf.empty(~S)>,carry:Host.Carry<S>) -> W.Factory & Report<S>:
  match carry:
    case Host.Carry{factory,_,host}:(factory,Report{initial,[],Run.RegistrationRejected{},[],Run.RegistrationRejected{},host})
def initial(~S:Data,factory:W.Factory,result:W.World<S,Array<U32>,State.Resource(~S),U32> & String) -> W.Factory & Report<S>:
  match result:
    case (world,+text):App.register(~S,~Array<U32>,~State.Resource(~S),~U32,~Unit,~Unit,~Build.empty_observe(~W.World<S,Array<U32>,State.Resource(~S),U32>),~Leaf.empty(~S),~State.Ops(~S),~Unit,~Maybe<&2,List<&2,U32>>,~Maybe<&2,List<&2,U32>>,~State.optional_declaration(~S),~State.body(~S),~(Host.Carry<S> -> W.Factory & Report<S>),(optional_ready(~S,text) : C.App1(~S) -> Host.Carry<S> -> W.Factory & Report<S>),(optional_failed(~S,text) : Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Unit,Unit,Build.empty_observe(~W.World<S,Array<U32>,State.Resource(~S),U32>),Leaf.empty(~S)> -> Host.Carry<S> -> W.Factory & Report<S>),Build.enabled(~S,~W.World<S,Array<U32>,State.Resource(~S),U32>,~Unit,~Unit,~Build.empty_observe(~W.World<S,Array<U32>,State.Resource(~S),U32>),~Leaf.empty(~S),Build.empty(~S,~W.World<S,Array<U32>,State.Resource(~S),U32>,world),True{}),"OptionalPayload","OptionalPayload")(Host.Carry{factory,I.Fresh{},[]})
def created(~S:Data,result:W.Creation<S,Array<U32>,State.Resource(~S),U32>) -> W.Factory & Report<S>:
  match result:
    case W.Created{factory,world}:initial(~S,factory,Dump.world(~S,W.enqueue(~S,~Array<U32>,~State.Resource(~S),~U32,world,State.pending(~S))))
    case W.CreateRejected{factory,_}:(factory,Report{"create-refused",[],Run.RegistrationRejected{},[],Run.RegistrationRejected{},[]})
def present_done(~S:Data,missing:Report<S>,result:W.Factory & Report<S>) -> List<&2,Report<S>>:
  match result:
    case (_,present):[missing,present]
def missing_done(~S:Data,result:W.Factory & Report<S>) -> List<&2,Report<S>>:
  match result:
    case (factory,missing):present_done(~S,missing,created(~S,W.create(~S,~Array<U32>,~State.Resource(~S),~U32,~State.store,factory,State.resource(~S,True{}))))
def run(~S:Data) -> List<&2,Report<S>>:
  missing_done(~S,created(~S,W.create(~S,~Array<U32>,~State.Resource(~S),~U32,~State.store,W.factory(),State.resource(~S,False{}))))
