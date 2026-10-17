import Base
import ../../../src/ecs/ordinary-resource-field-system.bend as Field
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/transaction.bend as T
import bundle.bend as B
import resources.bend as R
import component.bend as C
import resource-capture.bend as RC
import capture.bend as P
import owner-observer.bend as Dump
import ../../../src/ecs/captured-schedule-query.bend as QL
import ../../../src/ecs/captured-schedule-local.bend as RL
import ../../../src/ecs/captured-schedule-composition.bend as Comp
import ../../../src/ecs/captured-schedule.bend as Run
import ../../../src/ecs/captured-schedule-condition.bend as Guard
import ../../../src/ecs/ordinary-condition-composition.bend as Cond
import ../../../src/ecs/ordinary-capture-query.bend as O
import ../../../src/ecs/local.bend as L
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/schedule.bend as Sch
import ../../../src/ecs/schedule-provision.bend as SP
def QLeaf() -> Type:
  QL.Leaf<B.AuditWorkshop,B.Store,R.Resources(),Nat,P.QueryPack,C.Ops,Unit,Unit,U32,C.declaration(),C.body>
def RLeaf() -> Type:
  RL.Leaf<B.AuditWorkshop,B.Store,R.Resources(),Nat,Array<U32>,Unit,Unit,Unit,RC.runner()>
def Captures() -> Type:
  QLeaf() & RLeaf()
def CaptureError() -> Data:
  Comp.Choice<Q.Error<Unit>,Unit>
def capture_catalog(owners:Captures()) -> Captures() & List<&2,Comp.Identity>:
  Comp.pair_catalog(~QLeaf(),~RLeaf(),~QL.catalog(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~P.QueryPack,~C.Ops,~Unit,~Unit,~U32,~C.declaration(),~C.body),~RL.catalog(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Array<U32>,~Unit,~Unit,~Unit,~RC.runner()),owners)
def capture_dispatch(owners:Captures(),world:B.World(R.Resources()),id:U32) -> Comp.Outcome<B.World(R.Resources()),Captures(),CaptureError()>:
  Comp.pair_dispatch(~B.World(R.Resources()),~QLeaf(),~RLeaf(),~Q.Error<Unit>,~Unit,~QL.catalog(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~P.QueryPack,~C.Ops,~Unit,~Unit,~U32,~C.declaration(),~C.body),~QL.dispatch(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~P.QueryPack,~C.Ops,~Unit,~Unit,~U32,~C.declaration(),~C.body),~RL.dispatch(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Array<U32>,~Unit,~Unit,~Unit,~RC.runner()),owners,world,id)
def Tx() -> Type:
  T.Tx<B.World(R.Resources()),Nat>
def field_runner() -> B.World(R.Resources()) -> Unit -> Sys.Outcome<B.World(R.Resources()),Unit,Unit>:
  Field.runner(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~R.Ops,~Unit,~Unit,~Unit,~R.declaration(),~R.body)
def FieldRegistry() -> Type:
  Sys.Registry<B.AuditWorkshop,B.Store,R.Resources(),Nat,Unit,Unit,Unit,field_runner()>
def FieldOwner() -> Type:
  Field.Owner<B.AuditWorkshop,FieldRegistry(),Field.clauses(~B.AuditWorkshop,~T.Tx<B.World(R.Resources()),Nat>,~R.Ops(T.Tx<B.World(R.Resources()),Nat>),R.declaration())>
def field_catalog(owner:FieldOwner()) -> FieldOwner() & List<&2,Comp.Identity>:
  match owner:
    case Field.Owner{Sys.Registry{+ns,+id,+name,+access,cursor}}:(Field.Owner{Sys.Registry{ns,id,name,access,cursor}},[Comp.Identity{ns,id,name,access}])
def field_returned(result:Sys.RunResult<B.AuditWorkshop,B.Store,R.Resources(),Nat,Unit,Unit,Unit,field_runner()>) -> Comp.Outcome<B.World(R.Resources()),FieldOwner(),Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,_}}:Comp.Completed{world,Field.Owner{registry}}
    case Sys.Completed{registry,Sys.Failed{world,error}}:Comp.Failed{world,Field.Owner{registry},error}
    case Sys.RegistrationRejected{registry,world,_}:Comp.Refused{world,Field.Owner{registry}}
def field_dispatch(owner:FieldOwner(),world:B.World(R.Resources()),id:U32) -> Comp.Outcome<B.World(R.Resources()),FieldOwner(),Unit>:
  field_returned(Field.run(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Unit,~Unit,~Unit,~field_runner(),~Field.clauses(~B.AuditWorkshop,~T.Tx<B.World(R.Resources()),Nat>,~R.Ops(T.Tx<B.World(R.Resources()),Nat>),R.declaration()),owner,world,Unit{}))
def Owners() -> Type:
  Captures() & FieldOwner()
def Error() -> Data:
  Comp.Choice<CaptureError(),Unit>
def catalog(owners:Owners()) -> Owners() & List<&2,Comp.Identity>:
  Comp.pair_catalog(~Captures(),~FieldOwner(),~capture_catalog,~field_catalog,owners)
def dispatch(owners:Owners(),world:B.World(R.Resources()),id:U32) -> Comp.Outcome<B.World(R.Resources()),Owners(),Error()>:
  Comp.pair_dispatch(~B.World(R.Resources()),~Captures(),~FieldOwner(),~CaptureError(),~Unit,~capture_catalog,~capture_dispatch,~field_dispatch,owners,world,id)
def Conditions() -> Type:
  Cond.Bindings<B.World(R.Resources()),Cond.BoundOwner<Bool>,Cond.bound_run(~B.World(R.Resources()),~Bool,~Cond.constant_run(~B.World(R.Resources())))>
def Schedule() -> Type:
  Guard.Owned<B.AuditWorkshop,B.Store,R.Resources(),Nat,Owners(),Cond.BoundOwner<Bool>,Error(),catalog,dispatch,Cond.bound_run(~B.World(R.Resources()),~Bool,~Cond.constant_run(~B.World(R.Resources())))>
def plan(qid:U32,rid:U32,fid:U32) -> SP.Plan<B.AuditWorkshop>:
  SP.Sequence{SP.Sequence{SP.Entry{Sch.System{fid,0},[]},SP.Entry{Sch.Phase{"AuditCapturedPipeline"},[]}},SP.Sequence{SP.Entry{Sch.System{qid,0},[]},SP.Sequence{SP.Entry{Sch.Barrier{},[]},SP.Sequence{SP.Entry{Sch.System{rid,0},[]},SP.Entry{Sch.Barrier{},[]}}}}}
def bind_ids(+qid:U32,rid:U32,fid:U32,query:C.Owned(),resource:RC.Instance(),field:FieldOwner()) -> Schedule():
  Guard.attach(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Owners(),~Cond.BoundOwner<Bool>,~Error(),~catalog,~dispatch,~Cond.bound_run(~B.World(R.Resources()),~Bool,~Cond.constant_run(~B.World(R.Resources()))),Run.compose(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Owners(),~Error(),~catalog,~dispatch,"AuditCapturedPipeline",plan(qid,rid,fid),((QL.bind(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~P.QueryPack,~C.Ops,~Unit,~Unit,~U32,~C.declaration(),~C.body,query,Unit{},True{}),RL.bind(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Array<U32>,~Unit,~Unit,~Unit,~RC.runner(),resource,Unit{},True{})),field)),Cond.bind(~B.World(R.Resources()),~Bool,~Cond.constant_run(~B.World(R.Resources())),qid,Cond.constant(~B.World(R.Resources()),True{})))
def bind(query:C.Owned(),resource:RC.Instance(),field:FieldOwner()) -> Schedule():
  match query resource field:
    case O.Owner{L.Instance{qn,+qid,qname,qa,qcapture},cursor} L.Instance{rn,+rid,rname,ra,rcapture} Field.Owner{Sys.Registry{fn,+fid,fname,fa,fc}}:bind_ids(qid,rid,fid,O.Owner{L.Instance{qn,qid,qname,qa,qcapture},cursor},L.Instance{rn,rid,rname,ra,rcapture},Field.Owner{Sys.Registry{fn,fid,fname,fa,fc}})
def provision(world:B.World(R.Resources())) -> B.World(R.Resources()) & List<&2,SP.Requirement<B.AuditWorkshop>>:
  (world,[])
def run(schedule:Schedule(),world:B.World(R.Resources())) -> Run.Run<B.World(R.Resources()),Schedule(),B.AuditWorkshop,Cond.Error<Error()>>:
  Guard.run(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~Owners(),~Cond.BoundOwner<Bool>,~Error(),~catalog,~dispatch,~Cond.bound_run(~B.World(R.Resources()),~Bool,~Cond.constant_run(~B.World(R.Resources()))),~provision,schedule,world)
def allow(schedule:Schedule(),value:Bool) -> Schedule():
  match schedule:
    case Guard.Owned{name,plan,owners,Cond.Bindings{Cond.BoundOwner{+id,_},_}}:Guard.Owned{name,plan,owners,Cond.bind(~B.World(R.Resources()),~Bool,~Cond.constant_run(~B.World(R.Resources())),id,Cond.constant(~B.World(R.Resources()),value))}
