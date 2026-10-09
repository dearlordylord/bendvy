import Base
import ./detached.bend as Detached
import ../../../../../../../../src/ecs/ordinary-schema.bend as Normal
import ./app.bend as App
import ./retained-schema.bend as Schema
import ./construction.bend as Construction
import ../app.bend as Original
import ../scenario-schema.bend as S
import ../scenario-driver.bend as Driver
import ../scenario-dto.bend as DTO
import ../app-run-v1/nominal-carrier-v1/accumulated-v1/scenario.bend as Scenario
import ../app-run-v1/nominal-carrier-v1/accumulated-v1/output.bend as Prior
import ../app-run-v1/nominal-carrier-v1/accumulated-v1/dispatch.bend as Dispatch
import ../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../src/ecs/schedule.bend as Sch
import ../../../../../../../../src/ecs/schedule-provision.bend as SP

type Origin is Data:
  Origin{debug:Original.Debug,entries:List<&2,Original.Entry<S.Schema>>,namespace:U32,name:String,steps:List<&2,Sch.Step>,requirements:List<&2,SP.Requirement<S.Schema>>}
type Report is Data:
  Report{baseline:Scenario.Report,origin:Origin,observations:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>}
type Outcome is Data:
  Reported{report:Report,detached:List<&2,Maybe<&2,Detached.Observation>>,detachedOwners:List<&2,DTO.Snapshot>}
  PriorFailed{outcome:Prior.Outcome}
  BuildFailed{baseline:Scenario.Report,origin:Origin,snapshots:List<&2,DTO.Snapshot>}
# The normal schema captures existing typed slot declarations, preserving every World field.
def retained(~C:Type,namespace:U32,nextId:U32,highWater:U32,live:Array<Bool>,capacity:U32,depth:Nat,resource:Unit,events:List<&2,Unit>,pending:List<(W.World<S.Schema,C,Unit,Unit> -> W.World<S.Schema,C,Unit,Unit>)>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:U32,got:C & Normal.Schema<S.Schema,C,Unit>) -> W.World<S.Schema,C,Unit,Unit> & Normal.Schema<S.Schema,C,Unit>:
  match got:
    case (store,catalog):(W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},catalog)
def plain_capture(world:W.World<S.Schema,S.plain_store(),Unit,Unit>) -> W.World<S.Schema,S.plain_store(),Unit,Unit> & Normal.Schema<S.Schema,S.plain_store(),Unit>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:retained(~S.plain_store(),namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId,clock,Schema.plain(store))
def plain_world_seen(~Out:Type,next:W.Factory -> W.World<S.Schema,S.plain_store(),Unit,Unit> -> App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain> -> List<&2,DTO.Snapshot> -> Out,+schema:Normal.Schema<S.Schema,S.plain_store(),Unit>,+debug:App.Debug,+bindings:List<&2,App.Binding<S.Schema>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,+requirements:List<&2,SP.Requirement<S.Schema>>,+trace:Dispatch.Trace,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,owners:Driver.plain_owners(),snapshots:List<&2,DTO.Snapshot>) -> Out:
  next(factory,world,App.Application{schema,debug,bindings,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.plain_pack((owners,trace))},requirements}},snapshots)
def plain_observe(~Out:Type,next:W.Factory -> W.World<S.Schema,S.plain_store(),Unit,Unit> -> App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain> -> List<&2,DTO.Snapshot> -> Out,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,snapshots:List<&2,DTO.Snapshot>,label:String) -> Out:
  match app:
    case App.Application{+schema,+debug,+bindings,SP.Provisioned{Sch.Schedule{+namespace,+name,+steps,Dispatch.Plain{main,added,changed,without,withHealth,+trace}},+requirements}}:
      Driver.plain_observe(~Out,(factory => world => owners => snapshots => plain_world_seen(~Out,next,schema,debug,bindings,namespace,name,steps,requirements,trace,factory,world,owners,snapshots)),factory,world,(((((Unit{},main),added),changed),without),withHealth),snapshots,label,DTO.Observed{},[])
def plain_debug(debug:App.Debug,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>) -> App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>:
  match app:
    case App.Application{schema,_,bindings,schedule}:App.Application{schema,debug,bindings,schedule}
def plain_inspected(~Out:Type,next:W.World<S.Schema,S.plain_store(),Unit,Unit> -> App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain> -> Maybe<&2,Detached.Observation> -> Out,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Out:
  match got:
    case (world,observation):next(world,app,observation)
def plain_inspect(~Out:Type,next:W.World<S.Schema,S.plain_store(),Unit,Unit> -> App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain> -> Maybe<&2,Detached.Observation> -> Out,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>) -> Out:
  match app:
    case App.Application{schema,+debug,bindings,schedule}:plain_inspected(~Out,next,App.Application{schema,debug,bindings,schedule},Detached.plain(debug,world))
def plain_detached_last(factory:W.Factory,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,report:Report,before:List<&2,DTO.Snapshot>,first:Maybe<&2,Detached.Observation>,second:Maybe<&2,Detached.Observation>,disabled:Maybe<&2,Detached.Observation>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,last):plain_observe(~Outcome,(factory => world => app => owners => Reported{report,[first,second,disabled,last],owners}),factory,world,app,before,"after-detached-observations")

def plain_detached_disabled(factory:W.Factory,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,report:Report,before:List<&2,DTO.Snapshot>,first:Maybe<&2,Detached.Observation>,second:Maybe<&2,Detached.Observation>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,disabled):plain_inspect(~Outcome,(world => app => observation => plain_detached_last(factory,app,report,before,first,second,disabled,(world,observation))),world,plain_debug(App.Enabled{},app))

def plain_detached_second(factory:W.Factory,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,report:Report,before:List<&2,DTO.Snapshot>,first:Maybe<&2,Detached.Observation>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,second):plain_inspect(~Outcome,(world => app => observation => plain_detached_disabled(factory,app,report,before,first,second,(world,observation))),world,plain_debug(App.Disabled{},app))

def plain_detached_first(factory:W.Factory,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,report:Report,before:List<&2,DTO.Snapshot>,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,first):plain_inspect(~Outcome,(world => app => observation => plain_detached_second(factory,app,report,before,first,(world,observation))),world,plain_debug(App.Enabled{},app))

def plain_detached(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,report:Report,before:List<&2,DTO.Snapshot>) -> Outcome:
  plain_inspect(~Outcome,(world => app => observation => plain_detached_first(factory,app,report,before,(world,observation))),world,plain_debug(App.Enabled{},app))

def plain_finished(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.plain_store(),Unit,Unit>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>) -> Outcome:
  plain_observe(~Outcome,(factory => world => app => before => plain_detached(factory,world,app,Report{baseline,origin,snapshots,descriptions},before)),factory,world,app,[],"before-detached-observations")
def plain_barrier(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.plain_store(),Unit,Unit>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>) -> Outcome:
  plain_observe(~Outcome,(factory => world => app => snapshots => plain_finished(factory,baseline,origin,detached,otherWorlds,world,app,snapshots,descriptions)),factory,W.barrier(~S.Schema,~S.plain_store(),~Unit,~Unit,world),app,snapshots,"after-explicit-barrier")
def plain_last(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.plain_store(),Unit,Unit>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>,got:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,last):plain_observe(~Outcome,(factory => world => app => snapshots => plain_barrier(factory,baseline,origin,detached,otherWorlds,world,app,snapshots,List.append(&2,Maybe<&2,App.Description<S.Schema>>,descriptions,[last]))),factory,world,app,snapshots,"after-repeated-app-descriptions")
def plain_disabled(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.plain_store(),Unit,Unit>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>,got:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,disabled):plain_last(factory,baseline,origin,detached,otherWorlds,world,snapshots,List.append(&2,Maybe<&2,App.Description<S.Schema>>,descriptions,[disabled]),App.describe(~S.Schema,~S.plain_store(),~Unit,~Unit,~Dispatch.Plain,plain_debug(App.Enabled{},app)))
def plain_second(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.plain_store(),Unit,Unit>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,first:Maybe<&2,App.Description<S.Schema>>,got:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,second):plain_disabled(factory,baseline,origin,detached,otherWorlds,world,snapshots,[first,second],App.describe(~S.Schema,~S.plain_store(),~Unit,~Unit,~Dispatch.Plain,plain_debug(App.Disabled{},app)))
def plain_first(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.plain_store(),Unit,Unit>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,got:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,first):plain_second(factory,baseline,origin,detached,otherWorlds,world,snapshots,first,App.describe(~S.Schema,~S.plain_store(),~Unit,~Unit,~Dispatch.Plain,app))
def plain_before(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.plain_store(),Unit,Unit>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,app:App.Application<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>,snapshots:List<&2,DTO.Snapshot>) -> Outcome:
  plain_first(factory,baseline,origin,detached,otherWorlds,world,snapshots,App.describe(~S.Schema,~S.plain_store(),~Unit,~Unit,~Dispatch.Plain,app))
def plain_built(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.plain_store(),Unit,Unit>>,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,result:App.Built<S.Schema,S.plain_store(),Unit,Unit,Dispatch.Plain>) -> Outcome:
  match result:
    case App.Invalid{owners}:
      Dispatch.Plain{main,added,changed,without,withHealth,trace} = owners
      Driver.plain_observe(~Outcome,(factory => world => owners => snapshots => BuildFailed{baseline,origin,snapshots}),factory,world,(((((Unit{},main),added),changed),without),withHealth),[],"unexpected-build-refusal",DTO.Observed{},[])
    case App.Built{app}:plain_observe(~Outcome,(factory => world => app => snapshots => plain_before(factory,baseline,origin,detached,otherWorlds,world,app,snapshots)),factory,W.enqueue(~S.Schema,~S.plain_store(),~Unit,~Unit,W.event_publish(~S.Schema,~S.plain_store(),~Unit,~Unit,world,[Unit{},Unit{}]),(world => W.event_publish(~S.Schema,~S.plain_store(),~Unit,~Unit,world,[Unit{}]))),app,[],"before-repeated-app-descriptions")
def plain_captured(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.plain_store(),Unit,Unit>>,owners:Dispatch.Plain,got:W.World<S.Schema,S.plain_store(),Unit,Unit> & Normal.Schema<S.Schema,S.plain_store(),Unit>) -> Outcome:
  match got:
    case (world,schema):plain_built(factory,baseline,origin,detached,otherWorlds,world,Construction.plain(schema,owners,App.Enabled{}))
def plain(result:Scenario.ExecutionResult<S.plain_store(),Dispatch.Plain>) -> Outcome:
  match result:
    case Scenario.Completed{factory,Original.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},requirements}},world,detached,otherWorlds,report}:plain_captured(factory,report,Origin{debug,entries,namespace,name,steps,requirements},detached,otherWorlds,owners,plain_capture(world))
    case other:PriorFailed{Prior.plain(other)}
def transient_capture(world:W.World<S.Schema,S.transient_store(),Unit,Unit>) -> W.World<S.Schema,S.transient_store(),Unit,Unit> & Normal.Schema<S.Schema,S.transient_store(),Unit>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:retained(~S.transient_store(),namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId,clock,Schema.transient(store))
def transient_world_seen(~Out:Type,next:W.Factory -> W.World<S.Schema,S.transient_store(),Unit,Unit> -> App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient> -> List<&2,DTO.Snapshot> -> Out,+schema:Normal.Schema<S.Schema,S.transient_store(),Unit>,+debug:App.Debug,+bindings:List<&2,App.Binding<S.Schema>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,+requirements:List<&2,SP.Requirement<S.Schema>>,+trace:Dispatch.Trace,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,owners:Driver.transient_owners(),snapshots:List<&2,DTO.Snapshot>) -> Out:
  next(factory,world,App.Application{schema,debug,bindings,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.transient_pack((owners,trace))},requirements}},snapshots)
def transient_observe(~Out:Type,next:W.Factory -> W.World<S.Schema,S.transient_store(),Unit,Unit> -> App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient> -> List<&2,DTO.Snapshot> -> Out,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,snapshots:List<&2,DTO.Snapshot>,label:String) -> Out:
  match app:
    case App.Application{+schema,+debug,+bindings,SP.Provisioned{Sch.Schedule{+namespace,+name,+steps,Dispatch.Transient{main,added,changed,without,withHealth,+trace}},+requirements}}:
      Driver.transient_observe(~Out,(factory => world => owners => snapshots => transient_world_seen(~Out,next,schema,debug,bindings,namespace,name,steps,requirements,trace,factory,world,owners,snapshots)),factory,world,(((((Unit{},main),added),changed),without),withHealth),snapshots,label,DTO.Observed{},[])
def transient_debug(debug:App.Debug,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>) -> App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>:
  match app:
    case App.Application{schema,_,bindings,schedule}:App.Application{schema,debug,bindings,schedule}
def transient_inspected(~Out:Type,next:W.World<S.Schema,S.transient_store(),Unit,Unit> -> App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient> -> Maybe<&2,Detached.Observation> -> Out,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Out:
  match got:
    case (world,observation):next(world,app,observation)
def transient_inspect(~Out:Type,next:W.World<S.Schema,S.transient_store(),Unit,Unit> -> App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient> -> Maybe<&2,Detached.Observation> -> Out,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>) -> Out:
  match app:
    case App.Application{schema,+debug,bindings,schedule}:transient_inspected(~Out,next,App.Application{schema,debug,bindings,schedule},Detached.transient(debug,world))
def transient_detached_last(factory:W.Factory,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,report:Report,before:List<&2,DTO.Snapshot>,first:Maybe<&2,Detached.Observation>,second:Maybe<&2,Detached.Observation>,disabled:Maybe<&2,Detached.Observation>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,last):transient_observe(~Outcome,(factory => world => app => owners => Reported{report,[first,second,disabled,last],owners}),factory,world,app,before,"after-detached-observations")

def transient_detached_disabled(factory:W.Factory,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,report:Report,before:List<&2,DTO.Snapshot>,first:Maybe<&2,Detached.Observation>,second:Maybe<&2,Detached.Observation>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,disabled):transient_inspect(~Outcome,(world => app => observation => transient_detached_last(factory,app,report,before,first,second,disabled,(world,observation))),world,transient_debug(App.Enabled{},app))

def transient_detached_second(factory:W.Factory,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,report:Report,before:List<&2,DTO.Snapshot>,first:Maybe<&2,Detached.Observation>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,second):transient_inspect(~Outcome,(world => app => observation => transient_detached_disabled(factory,app,report,before,first,second,(world,observation))),world,transient_debug(App.Disabled{},app))

def transient_detached_first(factory:W.Factory,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,report:Report,before:List<&2,DTO.Snapshot>,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,first):transient_inspect(~Outcome,(world => app => observation => transient_detached_second(factory,app,report,before,first,(world,observation))),world,transient_debug(App.Enabled{},app))

def transient_detached(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,report:Report,before:List<&2,DTO.Snapshot>) -> Outcome:
  transient_inspect(~Outcome,(world => app => observation => transient_detached_first(factory,app,report,before,(world,observation))),world,transient_debug(App.Enabled{},app))

def transient_finished(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.transient_store(),Unit,Unit>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>) -> Outcome:
  transient_observe(~Outcome,(factory => world => app => before => transient_detached(factory,world,app,Report{baseline,origin,snapshots,descriptions},before)),factory,world,app,[],"before-detached-observations")
def transient_barrier(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.transient_store(),Unit,Unit>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>) -> Outcome:
  transient_observe(~Outcome,(factory => world => app => snapshots => transient_finished(factory,baseline,origin,detached,otherWorlds,world,app,snapshots,descriptions)),factory,W.barrier(~S.Schema,~S.transient_store(),~Unit,~Unit,world),app,snapshots,"after-explicit-barrier")
def transient_last(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.transient_store(),Unit,Unit>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>,got:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,last):transient_observe(~Outcome,(factory => world => app => snapshots => transient_barrier(factory,baseline,origin,detached,otherWorlds,world,app,snapshots,List.append(&2,Maybe<&2,App.Description<S.Schema>>,descriptions,[last]))),factory,world,app,snapshots,"after-repeated-app-descriptions")
def transient_disabled(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.transient_store(),Unit,Unit>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>,got:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,disabled):transient_last(factory,baseline,origin,detached,otherWorlds,world,snapshots,List.append(&2,Maybe<&2,App.Description<S.Schema>>,descriptions,[disabled]),App.describe(~S.Schema,~S.transient_store(),~Unit,~Unit,~Dispatch.Transient,transient_debug(App.Enabled{},app)))
def transient_second(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.transient_store(),Unit,Unit>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,first:Maybe<&2,App.Description<S.Schema>>,got:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,second):transient_disabled(factory,baseline,origin,detached,otherWorlds,world,snapshots,[first,second],App.describe(~S.Schema,~S.transient_store(),~Unit,~Unit,~Dispatch.Transient,transient_debug(App.Disabled{},app)))
def transient_first(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.transient_store(),Unit,Unit>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,got:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,first):transient_second(factory,baseline,origin,detached,otherWorlds,world,snapshots,first,App.describe(~S.Schema,~S.transient_store(),~Unit,~Unit,~Dispatch.Transient,app))
def transient_before(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.transient_store(),Unit,Unit>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,app:App.Application<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>,snapshots:List<&2,DTO.Snapshot>) -> Outcome:
  transient_first(factory,baseline,origin,detached,otherWorlds,world,snapshots,App.describe(~S.Schema,~S.transient_store(),~Unit,~Unit,~Dispatch.Transient,app))
def transient_built(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.transient_store(),Unit,Unit>>,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,result:App.Built<S.Schema,S.transient_store(),Unit,Unit,Dispatch.Transient>) -> Outcome:
  match result:
    case App.Invalid{owners}:
      Dispatch.Transient{main,added,changed,without,withHealth,trace} = owners
      Driver.transient_observe(~Outcome,(factory => world => owners => snapshots => BuildFailed{baseline,origin,snapshots}),factory,world,(((((Unit{},main),added),changed),without),withHealth),[],"unexpected-build-refusal",DTO.Observed{},[])
    case App.Built{app}:transient_observe(~Outcome,(factory => world => app => snapshots => transient_before(factory,baseline,origin,detached,otherWorlds,world,app,snapshots)),factory,W.enqueue(~S.Schema,~S.transient_store(),~Unit,~Unit,W.event_publish(~S.Schema,~S.transient_store(),~Unit,~Unit,world,[Unit{},Unit{}]),(world => W.event_publish(~S.Schema,~S.transient_store(),~Unit,~Unit,world,[Unit{}]))),app,[],"before-repeated-app-descriptions")
def transient_captured(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.transient_store(),Unit,Unit>>,owners:Dispatch.Transient,got:W.World<S.Schema,S.transient_store(),Unit,Unit> & Normal.Schema<S.Schema,S.transient_store(),Unit>) -> Outcome:
  match got:
    case (world,schema):transient_built(factory,baseline,origin,detached,otherWorlds,world,Construction.transient(schema,owners,App.Enabled{}))
def transient(result:Scenario.ExecutionResult<S.transient_store(),Dispatch.Transient>) -> Outcome:
  match result:
    case Scenario.Completed{factory,Original.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},requirements}},world,detached,otherWorlds,report}:transient_captured(factory,report,Origin{debug,entries,namespace,name,steps,requirements},detached,otherWorlds,owners,transient_capture(world))
    case other:PriorFailed{Prior.transient(other)}
def constructed_capture(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>) -> W.World<S.Schema,S.constructed_store(),Unit,Unit> & Normal.Schema<S.Schema,S.constructed_store(),Unit>:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:retained(~S.constructed_store(),namespace,nextId,highWater,live,capacity,depth,resource,events,pending,registrations,nextSystemId,clock,Schema.constructed(store))
def constructed_world_seen(~Out:Type,next:W.Factory -> W.World<S.Schema,S.constructed_store(),Unit,Unit> -> App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed> -> List<&2,DTO.Snapshot> -> Out,+schema:Normal.Schema<S.Schema,S.constructed_store(),Unit>,+debug:App.Debug,+bindings:List<&2,App.Binding<S.Schema>>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,+requirements:List<&2,SP.Requirement<S.Schema>>,+trace:Dispatch.Trace,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,owners:Driver.constructed_owners(),snapshots:List<&2,DTO.Snapshot>) -> Out:
  next(factory,world,App.Application{schema,debug,bindings,SP.Provisioned{Sch.Schedule{namespace,name,steps,Dispatch.constructed_pack((owners,trace))},requirements}},snapshots)
def constructed_observe(~Out:Type,next:W.Factory -> W.World<S.Schema,S.constructed_store(),Unit,Unit> -> App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed> -> List<&2,DTO.Snapshot> -> Out,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,snapshots:List<&2,DTO.Snapshot>,label:String) -> Out:
  match app:
    case App.Application{+schema,+debug,+bindings,SP.Provisioned{Sch.Schedule{+namespace,+name,+steps,Dispatch.Constructed{main,added,changed,without,withHealth,+trace}},+requirements}}:
      Driver.constructed_observe(~Out,(factory => world => owners => snapshots => constructed_world_seen(~Out,next,schema,debug,bindings,namespace,name,steps,requirements,trace,factory,world,owners,snapshots)),factory,world,(((((Unit{},main),added),changed),without),withHealth),snapshots,label,DTO.Observed{},[])
def constructed_debug(debug:App.Debug,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>) -> App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>:
  match app:
    case App.Application{schema,_,bindings,schedule}:App.Application{schema,debug,bindings,schedule}
def constructed_inspected(~Out:Type,next:W.World<S.Schema,S.constructed_store(),Unit,Unit> -> App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed> -> Maybe<&2,Detached.Observation> -> Out,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Out:
  match got:
    case (world,observation):next(world,app,observation)
def constructed_inspect(~Out:Type,next:W.World<S.Schema,S.constructed_store(),Unit,Unit> -> App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed> -> Maybe<&2,Detached.Observation> -> Out,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>) -> Out:
  match app:
    case App.Application{schema,+debug,bindings,schedule}:constructed_inspected(~Out,next,App.Application{schema,debug,bindings,schedule},Detached.constructed(debug,world))
def constructed_detached_last(factory:W.Factory,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,report:Report,before:List<&2,DTO.Snapshot>,first:Maybe<&2,Detached.Observation>,second:Maybe<&2,Detached.Observation>,disabled:Maybe<&2,Detached.Observation>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,last):constructed_observe(~Outcome,(factory => world => app => owners => Reported{report,[first,second,disabled,last],owners}),factory,world,app,before,"after-detached-observations")

def constructed_detached_disabled(factory:W.Factory,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,report:Report,before:List<&2,DTO.Snapshot>,first:Maybe<&2,Detached.Observation>,second:Maybe<&2,Detached.Observation>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,disabled):constructed_inspect(~Outcome,(world => app => observation => constructed_detached_last(factory,app,report,before,first,second,disabled,(world,observation))),world,constructed_debug(App.Enabled{},app))

def constructed_detached_second(factory:W.Factory,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,report:Report,before:List<&2,DTO.Snapshot>,first:Maybe<&2,Detached.Observation>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,second):constructed_inspect(~Outcome,(world => app => observation => constructed_detached_disabled(factory,app,report,before,first,second,(world,observation))),world,constructed_debug(App.Disabled{},app))

def constructed_detached_first(factory:W.Factory,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,report:Report,before:List<&2,DTO.Snapshot>,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Maybe<&2,Detached.Observation>) -> Outcome:
  match got:
    case (world,first):constructed_inspect(~Outcome,(world => app => observation => constructed_detached_second(factory,app,report,before,first,(world,observation))),world,constructed_debug(App.Enabled{},app))

def constructed_detached(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,report:Report,before:List<&2,DTO.Snapshot>) -> Outcome:
  constructed_inspect(~Outcome,(world => app => observation => constructed_detached_first(factory,app,report,before,(world,observation))),world,constructed_debug(App.Enabled{},app))

def constructed_finished(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.constructed_store(),Unit,Unit>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>) -> Outcome:
  constructed_observe(~Outcome,(factory => world => app => before => constructed_detached(factory,world,app,Report{baseline,origin,snapshots,descriptions},before)),factory,world,app,[],"before-detached-observations")
def constructed_barrier(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.constructed_store(),Unit,Unit>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>) -> Outcome:
  constructed_observe(~Outcome,(factory => world => app => snapshots => constructed_finished(factory,baseline,origin,detached,otherWorlds,world,app,snapshots,descriptions)),factory,W.barrier(~S.Schema,~S.constructed_store(),~Unit,~Unit,world),app,snapshots,"after-explicit-barrier")
def constructed_last(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.constructed_store(),Unit,Unit>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>,got:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,last):constructed_observe(~Outcome,(factory => world => app => snapshots => constructed_barrier(factory,baseline,origin,detached,otherWorlds,world,app,snapshots,List.append(&2,Maybe<&2,App.Description<S.Schema>>,descriptions,[last]))),factory,world,app,snapshots,"after-repeated-app-descriptions")
def constructed_disabled(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.constructed_store(),Unit,Unit>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,descriptions:List<&2,Maybe<&2,App.Description<S.Schema>>>,got:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,disabled):constructed_last(factory,baseline,origin,detached,otherWorlds,world,snapshots,List.append(&2,Maybe<&2,App.Description<S.Schema>>,descriptions,[disabled]),App.describe(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Dispatch.Constructed,constructed_debug(App.Enabled{},app)))
def constructed_second(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.constructed_store(),Unit,Unit>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,first:Maybe<&2,App.Description<S.Schema>>,got:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,second):constructed_disabled(factory,baseline,origin,detached,otherWorlds,world,snapshots,[first,second],App.describe(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Dispatch.Constructed,constructed_debug(App.Disabled{},app)))
def constructed_first(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.constructed_store(),Unit,Unit>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,snapshots:List<&2,DTO.Snapshot>,got:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed> & Maybe<&2,App.Description<S.Schema>>) -> Outcome:
  match got:
    case (app,first):constructed_second(factory,baseline,origin,detached,otherWorlds,world,snapshots,first,App.describe(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Dispatch.Constructed,app))
def constructed_before(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.constructed_store(),Unit,Unit>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,app:App.Application<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>,snapshots:List<&2,DTO.Snapshot>) -> Outcome:
  constructed_first(factory,baseline,origin,detached,otherWorlds,world,snapshots,App.describe(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Dispatch.Constructed,app))
def constructed_built(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.constructed_store(),Unit,Unit>>,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,result:App.Built<S.Schema,S.constructed_store(),Unit,Unit,Dispatch.Constructed>) -> Outcome:
  match result:
    case App.Invalid{owners}:
      Dispatch.Constructed{main,added,changed,without,withHealth,trace} = owners
      Driver.constructed_observe(~Outcome,(factory => world => owners => snapshots => BuildFailed{baseline,origin,snapshots}),factory,world,(((((Unit{},main),added),changed),without),withHealth),[],"unexpected-build-refusal",DTO.Observed{},[])
    case App.Built{app}:constructed_observe(~Outcome,(factory => world => app => snapshots => constructed_before(factory,baseline,origin,detached,otherWorlds,world,app,snapshots)),factory,W.enqueue(~S.Schema,~S.constructed_store(),~Unit,~Unit,W.event_publish(~S.Schema,~S.constructed_store(),~Unit,~Unit,world,[Unit{},Unit{}]),(world => W.event_publish(~S.Schema,~S.constructed_store(),~Unit,~Unit,world,[Unit{}]))),app,[],"before-repeated-app-descriptions")
def constructed_captured(factory:W.Factory,baseline:Scenario.Report,origin:Origin,detached:List<Maybe<&1,Array<U32>>>,otherWorlds:List<W.World<S.Schema,S.constructed_store(),Unit,Unit>>,owners:Dispatch.Constructed,got:W.World<S.Schema,S.constructed_store(),Unit,Unit> & Normal.Schema<S.Schema,S.constructed_store(),Unit>) -> Outcome:
  match got:
    case (world,schema):constructed_built(factory,baseline,origin,detached,otherWorlds,world,Construction.constructed(schema,owners,App.Enabled{}))
def constructed(result:Scenario.ExecutionResult<S.constructed_store(),Dispatch.Constructed>) -> Outcome:
  match result:
    case Scenario.Completed{factory,Original.Application{debug,entries,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},requirements}},world,detached,otherWorlds,report}:constructed_captured(factory,report,Origin{debug,entries,namespace,name,steps,requirements},detached,otherWorlds,owners,constructed_capture(world))
    case other:PriorFailed{Prior.constructed(other)}
type Complete is Data:
  Complete{plain:Outcome,transient:Outcome,constructed:Outcome}
def main() -> Complete:
  Complete{plain(Scenario.plain()),transient(Scenario.transient()),constructed(Scenario.constructed())}
