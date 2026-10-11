import Base
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import state.bend as F
import bindings.bend as B
import operations.bend as Ops
import service-leaf.bend as Service
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-run.bend as Run
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-declaration.bend as RD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-service-declaration.bend as D
type Error is Data:
  ComponentFailed{error:Q.Error<Unit>}
  ResourceFailed{}
  ServiceFailed{}
  UnknownSystem{}
def component_out(result:Sys.Outcome<F.World(),Q.Error<Unit>,List<&2,Unit>>) -> Sys.Outcome<F.World(),Error,Unit>:
  match result:
    case Sys.Succeeded{world,_}:Sys.Succeeded{world,Unit{}}
    case Sys.Failed{world,error}:Sys.Failed{world,ComponentFailed{error}}
def resource_out(result:Sys.Outcome<F.World(),Unit,Unit>) -> Sys.Outcome<F.World(),Error,Unit>:
  match result:
    case Sys.Succeeded{world,_}:Sys.Succeeded{world,Unit{}}
    case Sys.Failed{world,_}:Sys.Failed{world,ResourceFailed{}}
def service_out(result:Sys.Outcome<F.World(),Unit,Unit>) -> Sys.Outcome<F.World(),Error,Unit>:
  match result:
    case Sys.Succeeded{world,_}:Sys.Succeeded{world,Unit{}}
    case Sys.Failed{world,_}:Sys.Failed{world,ServiceFailed{}}
def component_returned(result:Run.TransportResult<F.S,F.World(),Unit & U32,Q.Error<Unit>,List<&2,Unit>,Records.Token<B.ComponentRegistry()>>) -> B.ComponentRecord() & Sys.Outcome<F.World(),Error,Unit>:
  match result:
    case Run.Completed{token,fields,outcome}:(Leaf.Record{token,fields},component_out(outcome))
    case Run.RegistrationRejected{token,fields,world,_}:(Leaf.Record{token,fields},Sys.Failed{world,UnknownSystem{}})
def run_component(record:B.ComponentRecord(),world:F.World()) -> B.ComponentRecord() & Sys.Outcome<F.World(),Error,Unit>:
  match record:
    case Leaf.Record{token,fields}:component_returned(Run.run(~F.S,~F.Store,~F.Resources,~F.Events(),~(Unit & U32),~Q.Error<Unit>,~List<&2,Unit>,~System.observable_runner(~F.S,~F.Store,~F.Resources,~F.Events(),~Ops.ComponentOps,~Unit,~Unit,~Unit,~Cmp.Access<U32>,~Ops.component_query(),~Ops.component_body),token,fields,world,(Unit{},0)))
def resource_returned(result:Run.TransportResult<F.S,F.World(),Unit,Unit,Unit,Records.Token<B.ResourceRegistry()>>) -> B.ResourceRecord() & Sys.Outcome<F.World(),Error,Unit>:
  match result:
    case Run.Completed{token,fields,outcome}:(Leaf.Record{token,fields},resource_out(outcome))
    case Run.RegistrationRejected{token,fields,world,_}:(Leaf.Record{token,fields},Sys.Failed{world,UnknownSystem{}})
def run_resource(record:B.ResourceRecord(),world:F.World()) -> B.ResourceRecord() & Sys.Outcome<F.World(),Error,Unit>:
  match record:
    case Leaf.Record{token,fields}:resource_returned(Run.run(~F.S,~F.Store,~F.Resources,~F.Events(),~(Unit),~Unit,~Unit,~Field.runner(~F.S,~F.Store,~F.Resources,~F.Events(),~RD.read_ops(~F.S,~Array<U32>,~F.inventory_identity(),~U32),~Unit,~Unit,~Unit,~RD.ordinary(~F.S,~F.Store,~F.Resources,~F.Events(),~RD.read_ops(~F.S,~Array<U32>,~F.inventory_identity(),~U32),~U32,Ops.resource_declaration()),~Ops.resource_body),token,fields,world,Unit{}))
def component_completed(service:B.Owners2(),resource:B.ResourceRecord(),result:B.ComponentRecord() & Sys.Outcome<F.World(),Error,Unit>) -> B.Owners4() & Sys.Outcome<F.World(),Error,Unit>:
  match result:
    case (component,outcome):(((service,component),resource),outcome)
def resource_completed(owners:B.Owners3(),result:B.ResourceRecord() & Sys.Outcome<F.World(),Error,Unit>) -> B.Owners4() & Sys.Outcome<F.World(),Error,Unit>:
  match result:
    case (resource,outcome):((owners,resource),outcome)
def service_completed(component:B.ComponentRecord(),resource:B.ResourceRecord(),result:B.ServiceOwner() & Sys.Outcome<F.World(),Unit,Unit>) -> B.Owners4() & Sys.Outcome<F.World(),Error,Unit>:
  match result:
    case (service,outcome):((((Unit{},service),component),resource),service_out(outcome))
def record_id(~Token:Type,record:Leaf.Record<F.S,Token>) -> Leaf.Record<F.S,Token> & U32:
  match record:
    case Leaf.Record{token,Records.Fields{namespace,+id,name,access,cursor,slot,clauses,kind}}:(Leaf.Record{token,Records.Fields{namespace,id,name,access,cursor,slot,clauses,kind}},id)
def identified_resource(unit:Unit,service:B.ServiceOwner(),sid:U32,component:B.ComponentRecord(),cid:U32,result:B.ResourceRecord() & U32) -> B.Owners4() & (U32 & (U32 & U32)):
  match result:
    case (resource,rid):((((unit,service),component),resource),(sid,(cid,rid)))
def identified_component(unit:Unit,service:B.ServiceOwner(),sid:U32,resource:B.ResourceRecord(),result:B.ComponentRecord() & U32) -> B.Owners4() & (U32 & (U32 & U32)):
  match result:
    case (component,cid):identified_resource(unit,service,sid,component,cid,record_id(~Records.Token<B.ResourceRegistry()>,resource))
def identified(owners:B.Owners4()) -> B.Owners4() & (U32 & (U32 & U32)):
  match owners:
    case (((unit,Service.Owner{Sys.Registry{namespace,+id,name,access,cursor},setup}),component),resource):identified_component(unit,Service.Owner{Sys.Registry{namespace,id,name,access,cursor},setup},id,resource,record_id(~Records.Token<B.ComponentRegistry()>,component))
def selected_resource(unit:Unit,service:B.ServiceOwner(),component:B.ComponentRecord(),resource:B.ResourceRecord(),world:F.World(),selected:Bool) -> B.Owners4() & Sys.Outcome<F.World(),Error,Unit>:
  match selected:
    case True{}:resource_completed(((unit,service),component),run_resource(resource,world))
    case False{}:((((unit,service),component),resource),Sys.Failed{world,UnknownSystem{}})
def selected_component(unit:Unit,service:B.ServiceOwner(),component:B.ComponentRecord(),resource:B.ResourceRecord(),world:F.World(),+id:U32,rid:U32,selected:Bool) -> B.Owners4() & Sys.Outcome<F.World(),Error,Unit>:
  match selected:
    case True{}:component_completed((unit,service),resource,run_component(component,world))
    case False{}:selected_resource(unit,service,component,resource,world,U32.is_eq(id,rid))
def selected_service(unit:Unit,service:B.ServiceOwner(),component:B.ComponentRecord(),resource:B.ResourceRecord(),world:F.World(),+id:U32,cid:U32,rid:U32,selected:Bool) -> B.Owners4() & Sys.Outcome<F.World(),Error,Unit>:
  match selected:
    case True{}:service_completed(component,resource,Service.run(~F.S,~F.Store,~F.Resources,~F.Events(),~Array<U32>,~F.ClockRest,~F.clock_take,~F.clock_put,~F.clock_call,~F.clock_declaration(),~B.scan(),service,world))
    case False{}:selected_component(unit,service,component,resource,world,id,rid,U32.is_eq(id,cid))
def routed(world:F.World(),+id:U32,result:B.Owners4() & (U32 & (U32 & U32))) -> B.Owners4() & Sys.Outcome<F.World(),Error,Unit>:
  match result:
    case ((((unit,service),component),resource),(sid,(cid,rid))):selected_service(unit,service,component,resource,world,id,cid,rid,U32.is_eq(id,sid))
def dispatch(owners:B.Owners4(),world:F.World(),id:U32) -> B.Owners4() & Sys.Outcome<F.World(),Error,Unit>:
  routed(world,id,identified(owners))
def condition(world:F.World(),_:U32) -> F.World() & Bool:(world,True{})
def provision(world:F.World()) -> F.World() & List<&2,SP.Requirement<F.S>>:
  D.provision(~F.S,~F.Store,~F.Resources,~F.Events(),~B.scan(),world)
