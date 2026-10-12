import Base
import ./state.bend as State
import ./dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-optional-resource.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-optional-resource-run.bend as Run
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource-system.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-optional-resource-observation.bend as Leaves
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
def runner1(~S:Data,world:W.World<S,Array<U32>,State.Resource(~S),U32>,args:Unit) -> Sys.Outcome<W.World<S,Array<U32>,State.Resource(~S),U32>,K.Error,Maybe<&2,List<&2,U32>>>:
  P.runner(~S,~Array<U32>,~State.Resource(~S),~U32,~State.Ops(~S),~Unit,~Maybe<&2,List<&2,U32>>,~Maybe<&2,List<&2,U32>>,~State.declaration(~S,~False{}),~State.body(~S),world,args)
def Record1(~S:Data) -> Type:
  Leaf.Record<S,Records.Token<Sys.Registry<S,Array<U32>,State.Resource(~S),U32,Unit,K.Error,Maybe<&2,List<&2,U32>>,runner1(~S)>>>
def Owners1(~S:Data) -> Type:
  Unit & Record1(~S)
def Rows1(~S:Data) -> Data:
  DTO.Product<Unit,Maybe<&2,List<&2,U32>>>
def observe1(~S:Data,world:W.World<S,Array<U32>,State.Resource(~S),U32>) -> W.World<S,Array<U32>,State.Resource(~S),U32> & DTO.Observation<Rows1(~S)>:
  Tree.observe_pair(~W.World<S,Array<U32>,State.Resource(~S),U32>,~Unit,~Maybe<&2,List<&2,U32>>,~Build.empty_observe(~W.World<S,Array<U32>,State.Resource(~S),U32>),~Leaves.resource_observe(~S,~Array<U32>,~State.Resource(~S),~U32,~State.Ops(~S),~Maybe<&2,List<&2,U32>>,~State.declaration(~S,~False{})),world)
def fold1(~S:Data,owners:Owners1(~S)) -> Owners1(~S) & List<&2,Records.Fields<S>>:
  Leaf.fold_pair(~S,~Unit,~Record1(~S),~Leaf.empty(~S),~Leaf.observed(~S,~Records.Token<Sys.Registry<S,Array<U32>,State.Resource(~S),U32,Unit,K.Error,Maybe<&2,List<&2,U32>>,runner1(~S)>>),owners)
def App1(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Owners1(~S),Rows1(~S),observe1(~S),fold1(~S)>
def Snapshot1(~S:Data) -> Data:
  DTO.Product<String,Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows1(~S)>>>>
def runner2(~S:Data,world:W.World<S,Array<U32>,State.Resource(~S),U32>,args:Unit) -> Sys.Outcome<W.World<S,Array<U32>,State.Resource(~S),U32>,K.Error,Maybe<&2,List<&2,U32>>>:
  P.runner(~S,~Array<U32>,~State.Resource(~S),~U32,~State.Ops(~S),~Unit,~Maybe<&2,List<&2,U32>>,~Maybe<&2,List<&2,U32>>,~State.declaration(~S,~True{}),~State.body(~S),world,args)
def Record2(~S:Data) -> Type:
  Leaf.Record<S,Records.Token<Sys.Registry<S,Array<U32>,State.Resource(~S),U32,Unit,K.Error,Maybe<&2,List<&2,U32>>,runner2(~S)>>>
def Owners2(~S:Data) -> Type:
  Owners1(~S) & Record2(~S)
def Rows2(~S:Data) -> Data:
  DTO.Product<Rows1(~S),Maybe<&2,List<&2,U32>>>
def observe2(~S:Data,world:W.World<S,Array<U32>,State.Resource(~S),U32>) -> W.World<S,Array<U32>,State.Resource(~S),U32> & DTO.Observation<Rows2(~S)>:
  Tree.observe_pair(~W.World<S,Array<U32>,State.Resource(~S),U32>,~Rows1(~S),~Maybe<&2,List<&2,U32>>,~observe1(~S),~Leaves.resource_observe(~S,~Array<U32>,~State.Resource(~S),~U32,~State.Ops(~S),~Maybe<&2,List<&2,U32>>,~State.declaration(~S,~True{})),world)
def fold2(~S:Data,owners:Owners2(~S)) -> Owners2(~S) & List<&2,Records.Fields<S>>:
  Leaf.fold_pair(~S,~Owners1(~S),~Record2(~S),~fold1(~S),~Leaf.observed(~S,~Records.Token<Sys.Registry<S,Array<U32>,State.Resource(~S),U32,Unit,K.Error,Maybe<&2,List<&2,U32>>,runner2(~S)>>),owners)
def App2(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Owners2(~S),Rows2(~S),observe2(~S),fold2(~S)>
def Snapshot2(~S:Data) -> Data:
  DTO.Product<String,Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows2(~S)>>>>
type Report<S:Data> is Data:
  Report{initial:String,optionalRegistered:Snapshot1(~S),optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,optionalAfter:Snapshot1(~S),optionalRepeated:Snapshot1(~S),requiredRegistered:Snapshot2(~S),requiredStatus:Run.Status<Maybe<&2,List<&2,U32>>>,requiredAfter:Snapshot2(~S),requiredRepeated:Snapshot2(~S)}
def snap_returned(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Array<U32>,State.Resource(~S),U32> -> W.World<S,Array<U32>,State.Resource(~S),U32> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,physical:String,result:Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Owners,Rows,observe,fold> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>) -> Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Owners,Rows,observe,fold> & DTO.Product<String,Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>>:
  match result:
    case (app,view):(app,DTO.Product{physical,view})
def physical_returned(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Array<U32>,State.Resource(~S),U32> -> W.World<S,Array<U32>,State.Resource(~S),U32> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,owners:Owners,recipe:Tree.Recipe<W.World<S,Array<U32>,State.Resource(~S),U32>,Rows,observe>,debug:Bool,result:W.World<S,Array<U32>,State.Resource(~S),U32> & String) -> Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Owners,Rows,observe,fold> & DTO.Product<String,Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>>:
  match result:
    case (world,physical):snap_returned(~S,~Owners,~Rows,~observe,~fold,physical,Build.snapshot(~S,~W.World<S,Array<U32>,State.Resource(~S),U32>,~Owners,~Rows,~observe,~fold,Build.Registered{world,owners,recipe,debug}))
def snapshot(~S:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,Array<U32>,State.Resource(~S),U32> -> W.World<S,Array<U32>,State.Resource(~S),U32> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,app:Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Owners,Rows,observe,fold>) -> Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Owners,Rows,observe,fold> & DTO.Product<String,Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:physical_returned(~S,~Owners,~Rows,~observe,~fold,owners,recipe,debug,Dump.world(~S,world))
def final(~S:Data,factory:W.Factory,initial:String, optionalRegistered:Snapshot1(~S), optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>, optionalAfter:Snapshot1(~S), optionalRepeated:Snapshot1(~S), requiredRegistered:Snapshot2(~S), requiredStatus:Run.Status<Maybe<&2,List<&2,U32>>>, requiredAfter:Snapshot2(~S),result:App2(~S) & Snapshot2(~S)) -> W.Factory & Report<S>:
  match result:
    case (_,requiredRepeated):(factory,Report{initial,optionalRegistered,optionalStatus,optionalAfter,optionalRepeated,requiredRegistered,requiredStatus,requiredAfter,requiredRepeated})
def required_after(~S:Data,factory:W.Factory,initial:String,optionalRegistered:Snapshot1(~S),optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,optionalAfter:Snapshot1(~S),optionalRepeated:Snapshot1(~S),requiredRegistered:Snapshot2(~S),requiredStatus:Run.Status<Maybe<&2,List<&2,U32>>>,result:App2(~S) & Snapshot2(~S)) -> W.Factory & Report<S>:
  match result:
    case (app,requiredAfter):final(~S,factory,initial,optionalRegistered,optionalStatus,optionalAfter,optionalRepeated,requiredRegistered,requiredStatus,requiredAfter,snapshot(~S,~Owners2(~S),~Rows2(~S),~observe2(~S),~fold2(~S),app))
def required_run(~S:Data,factory:W.Factory,initial:String,optionalRegistered:Snapshot1(~S),optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,optionalAfter:Snapshot1(~S),optionalRepeated:Snapshot1(~S),requiredRegistered:Snapshot2(~S),result:App2(~S) & Run.Status<Maybe<&2,List<&2,U32>>>) -> W.Factory & Report<S>:
  match result:
    case (app,requiredStatus):required_after(~S,factory,initial,optionalRegistered,optionalStatus,optionalAfter,optionalRepeated,requiredRegistered,requiredStatus,snapshot(~S,~Owners2(~S),~Rows2(~S),~observe2(~S),~fold2(~S),app))
def required_registered(~S:Data,factory:W.Factory,initial:String,optionalRegistered:Snapshot1(~S),optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,optionalAfter:Snapshot1(~S),optionalRepeated:Snapshot1(~S),result:App2(~S) & Snapshot2(~S)) -> W.Factory & Report<S>:
  match result:
    case (app,requiredRegistered):required_run(~S,factory,initial,optionalRegistered,optionalStatus,optionalAfter,optionalRepeated,requiredRegistered,Run.run_latest(~S,~Array<U32>,~State.Resource(~S),~U32,~Unit,~Maybe<&2,List<&2,U32>>,~runner2(~S),~Owners1(~S),~Rows2(~S),~observe2(~S),~fold2(~S),app,Unit{}))
def required_ready(~S:Data,initial:String,optionalRegistered:Snapshot1(~S),optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,optionalAfter:Snapshot1(~S),optionalRepeated:Snapshot1(~S),app:App2(~S),factory:W.Factory) -> W.Factory & Report<S>:
  required_registered(~S,factory,initial,optionalRegistered,optionalStatus,optionalAfter,optionalRepeated,snapshot(~S,~Owners2(~S),~Rows2(~S),~observe2(~S),~fold2(~S),app))
def required_failed(~S:Data,initial:String,optionalRegistered:Snapshot1(~S),optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,optionalAfter:Snapshot1(~S),optionalRepeated:Snapshot1(~S),app:App1(~S),factory:W.Factory) -> W.Factory & Report<S>:
  (factory,Report{initial,optionalRegistered,optionalStatus,optionalAfter,optionalRepeated,DTO.Product{"registration-refused",None{}},Run.RegistrationRejected{},DTO.Product{"registration-refused",None{}},DTO.Product{"registration-refused",None{}}})
def optional_repeated(~S:Data,factory:W.Factory,initial:String,optionalRegistered:Snapshot1(~S),optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,optionalAfter:Snapshot1(~S),result:App1(~S) & Snapshot1(~S)) -> W.Factory & Report<S>:
  match result:
    case (app,optionalRepeated):App.register(~S,~Array<U32>,~State.Resource(~S),~U32,~Owners1(~S),~Rows1(~S),~observe1(~S),~fold1(~S),~State.Ops(~S),~Unit,~Maybe<&2,List<&2,U32>>,~Maybe<&2,List<&2,U32>>,~State.declaration(~S,~True{}),~State.body(~S),~(W.Factory -> W.Factory & Report<S>),required_ready(~S,initial,optionalRegistered,optionalStatus,optionalAfter,optionalRepeated),required_failed(~S,initial,optionalRegistered,optionalStatus,optionalAfter,optionalRepeated),app,"RequiredPayload","RequiredPayload")(factory)
def optional_after(~S:Data,factory:W.Factory,initial:String,optionalRegistered:Snapshot1(~S),optionalStatus:Run.Status<Maybe<&2,List<&2,U32>>>,result:App1(~S) & Snapshot1(~S)) -> W.Factory & Report<S>:
  match result:
    case (app,optionalAfter):optional_repeated(~S,factory,initial,optionalRegistered,optionalStatus,optionalAfter,snapshot(~S,~Owners1(~S),~Rows1(~S),~observe1(~S),~fold1(~S),app))
def optional_run(~S:Data,factory:W.Factory,initial:String,optionalRegistered:Snapshot1(~S),result:App1(~S) & Run.Status<Maybe<&2,List<&2,U32>>>) -> W.Factory & Report<S>:
  match result:
    case (app,optionalStatus):optional_after(~S,factory,initial,optionalRegistered,optionalStatus,snapshot(~S,~Owners1(~S),~Rows1(~S),~observe1(~S),~fold1(~S),app))
def optional_registered(~S:Data,factory:W.Factory,initial:String,result:App1(~S) & Snapshot1(~S)) -> W.Factory & Report<S>:
  match result:
    case (app,optionalRegistered):optional_run(~S,factory,initial,optionalRegistered,Run.run_latest(~S,~Array<U32>,~State.Resource(~S),~U32,~Unit,~Maybe<&2,List<&2,U32>>,~runner1(~S),~Unit,~Rows1(~S),~observe1(~S),~fold1(~S),app,Unit{}))
def optional_ready(~S:Data,initial:String,app:App1(~S),factory:W.Factory) -> W.Factory & Report<S>:
  optional_registered(~S,factory,initial,snapshot(~S,~Owners1(~S),~Rows1(~S),~observe1(~S),~fold1(~S),app))
def optional_failed(~S:Data,initial:String,app:Build.Registered<S,W.World<S,Array<U32>,State.Resource(~S),U32>,Unit,Unit,Build.empty_observe(~W.World<S,Array<U32>,State.Resource(~S),U32>),Leaf.empty(~S)>,factory:W.Factory) -> W.Factory & Report<S>:
  (factory,Report{initial,DTO.Product{"registration-refused",None{}},Run.RegistrationRejected{},DTO.Product{"registration-refused",None{}},DTO.Product{"registration-refused",None{}},DTO.Product{"registration-refused",None{}},Run.RegistrationRejected{},DTO.Product{"registration-refused",None{}},DTO.Product{"registration-refused",None{}}})
def initial(~S:Data,factory:W.Factory,result:W.World<S,Array<U32>,State.Resource(~S),U32> & String) -> W.Factory & Report<S>:
  match result:
    case (world,text):App.register(~S,~Array<U32>,~State.Resource(~S),~U32,~Unit,~Unit,~Build.empty_observe(~W.World<S,Array<U32>,State.Resource(~S),U32>),~Leaf.empty(~S),~State.Ops(~S),~Unit,~Maybe<&2,List<&2,U32>>,~Maybe<&2,List<&2,U32>>,~State.declaration(~S,~False{}),~State.body(~S),~(W.Factory -> W.Factory & Report<S>),optional_ready(~S,text),optional_failed(~S,text),Build.enabled(~S,~W.World<S,Array<U32>,State.Resource(~S),U32>,~Unit,~Unit,~Build.empty_observe(~W.World<S,Array<U32>,State.Resource(~S),U32>),~Leaf.empty(~S),Build.empty(~S,~W.World<S,Array<U32>,State.Resource(~S),U32>,world),True{}),"OptionalPayload","OptionalPayload")(factory)
def created(~S:Data,result:W.Creation<S,Array<U32>,State.Resource(~S),U32>) -> W.Factory & Report<S>:
  match result:
    case W.Created{factory,world}:initial(~S,factory,Dump.world(~S,W.enqueue(~S,~Array<U32>,~State.Resource(~S),~U32,world,State.pending(~S))))
    case W.CreateRejected{factory,_}:(factory,Report{"create-refused",DTO.Product{"create-refused",None{}},Run.RegistrationRejected{},DTO.Product{"create-refused",None{}},DTO.Product{"create-refused",None{}},DTO.Product{"create-refused",None{}},Run.RegistrationRejected{},DTO.Product{"create-refused",None{}},DTO.Product{"create-refused",None{}}})
def present_done(~S:Data,missing:Report<S>,result:W.Factory & Report<S>) -> List<&2,Report<S>>:
  match result:
    case (_,present):[missing,present]
def missing_done(~S:Data,result:W.Factory & Report<S>) -> List<&2,Report<S>>:
  match result:
    case (factory,missing):present_done(~S,missing,created(~S,W.create(~S,~Array<U32>,~State.Resource(~S),~U32,~State.store,factory,State.resource(~S,True{}))))
def run(~S:Data) -> List<&2,Report<S>>:
  missing_done(~S,created(~S,W.create(~S,~Array<U32>,~State.Resource(~S),~U32,~State.store,W.factory(),State.resource(~S,False{}))))
