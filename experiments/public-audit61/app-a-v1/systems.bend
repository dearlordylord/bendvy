import Base
import bundle.bend as B
import resources.bend as R
import component.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
def ComponentRegistry() -> Type:
  Sys.Registry<B.AuditWorkshop,B.Store,R.Resources(),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ordinary.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~Component.Ops,~Unit,~Unit,~Unit,~Component.declaration(),~Component.body)>
def ResourceRegistry() -> Type:
  Sys.Registry<B.AuditWorkshop,B.Store,R.Resources(),U32,Unit,Unit,Unit,Field.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~R.Ops,~Unit,~Unit,~Unit,~R.declaration(),~R.body)>
def ComponentOwner() -> Type:
  Ordinary.Owner<B.AuditWorkshop,ComponentRegistry()>
def Tx() -> Type:
  T.Tx<B.World(R.Resources()),U32>
def ResourceOwner() -> Type:
  Field.Owner<B.AuditWorkshop,ResourceRegistry(),Field.clauses(~B.AuditWorkshop,~Tx(),~R.Ops(Tx()),R.declaration())>
type Owners is Type:
  Owners{component:ComponentOwner(),resource:ResourceOwner()}
type Error is Data:
  ComponentFailed{error:Q.Error<Unit>}
  ResourceFailed{}
  Refused{}
def component_outcome(resource:ResourceOwner(),slot:String,clauses:List<&2,Query.Clause<B.AuditWorkshop>>,result:Sys.RunResult<B.AuditWorkshop,B.Store,R.Resources(),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ordinary.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~Component.Ops,~Unit,~Unit,~Unit,~Component.declaration(),~Component.body)>) -> Owners & Sys.Outcome<B.World(R.Resources()),Error,Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,values}}:(Owners{Ordinary.Owner{registry,slot,clauses},resource},Sys.Succeeded{world,Unit{}})
    case Sys.Completed{registry,Sys.Failed{world,error}}:(Owners{Ordinary.Owner{registry,slot,clauses},resource},Sys.Failed{world,ComponentFailed{error}})
    case Sys.RegistrationRejected{registry,world,args}:(Owners{Ordinary.Owner{registry,slot,clauses},resource},Sys.Failed{world,Refused{}})
def component_returned(resource:ResourceOwner(),result:Sys.RunResult<B.AuditWorkshop,B.Store,R.Resources(),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ordinary.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~Component.Ops,~Unit,~Unit,~Unit,~Component.declaration(),~Component.body)> & (String & List<&2,Query.Clause<B.AuditWorkshop>>)) -> Owners & Sys.Outcome<B.World(R.Resources()),Error,Unit>:
  match result:
    case (result,(slot,clauses)):component_outcome(resource,slot,clauses,result)
def resource_returned(component:ComponentOwner(),result:Sys.RunResult<B.AuditWorkshop,B.Store,R.Resources(),U32,Unit,Unit,Unit,Field.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~R.Ops,~Unit,~Unit,~Unit,~R.declaration(),~R.body)>) -> Owners & Sys.Outcome<B.World(R.Resources()),Error,Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,out}}:(Owners{component,Field.Owner{registry}},Sys.Succeeded{world,Unit{}})
    case Sys.Completed{registry,Sys.Failed{world,error}}:(Owners{component,Field.Owner{registry}},Sys.Failed{world,ResourceFailed{}})
    case Sys.RegistrationRejected{registry,world,args}:(Owners{component,Field.Owner{registry}},Sys.Failed{world,Refused{}})
def dispatch(owners:Owners,world:B.World(R.Resources()),id:U32) -> Owners & Sys.Outcome<B.World(R.Resources()),Error,Unit>:
  match owners id:
    case Owners{component,resource} 1:component_returned(resource,Ordinary.run(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~Component.Ops,~Unit,~Unit,~Unit,~Component.declaration(),~Component.body,component,world,Unit{}))
    case Owners{component,resource} 2:resource_returned(component,Field.run(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~Unit,~Unit,~Unit,~Field.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~R.Ops,~Unit,~Unit,~Unit,~R.declaration(),~R.body),~Field.clauses(~B.AuditWorkshop,~Tx(),~R.Ops(Tx()),R.declaration()),resource,world,Unit{}))
    case owners _:(owners,Sys.Failed{world,Refused{}})
