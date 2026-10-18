import Base
import ../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../src/ecs/ordinary-app-resource.bend as ResourceApp
import ../../../../src/ecs/ordinary-app-observation.bend as Leaves
import ../../../../src/ecs/ordinary-app-registration-run.bend as Transport
import ../../../../src/ecs/ordinary-app-local-fields.bend as LF
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-app-schedules.bend as Named
import ../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Records
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/ordinary-resource-system.bend as P
import ../../../../src/ecs/ordinary-app-resource-declaration.bend as D
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/schedule.bend as Sch
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-schedule-description.bend as Detail
import ../../../../src/ecs/local.bend as Local
type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type Store is Type:
  Store{retained:Array<U32>}
type Resources is Data:
  Resources{value:U32}
type Change is Data:
  Keep{}
  Set{value:U32}
type Memory is Type:
  Memory{values:Array<U32>,count:U32}
def empty(_:Unit) -> Store:
  Store{Array.new(U32,1n,77)}
def projected(resource:Resources) -> Resources & U32:
  match resource:
    case Resources{+value}:(Resources{value},value)
def identity(~S:Data) -> Schema.Resource<S,Resources>:
  Schema.resource(~S,~Resources,"Counter")
def declaration(~S:Data) -> D.Declaration<S,Store,Resources,Unit,D.read_ops(~U32),U32>:
  D.read(~S,~Store,~Resources,~Unit,~U32,~projected,~U32.show,identity(~S))
def memory_next(memory:Memory) -> Memory:
  match memory:
    case Memory{values,+count}:Memory{Array.set(U32,values,0,(count+1:U32)),(count+1:U32)}
def memory_project(memory:Memory) -> Memory & U32:
  match memory:
    case Memory{values,+count}:(Memory{values,count},count)
def local_body(~H:Type,caps:Local.Ops<H,Memory,U32>,ctx:H) -> H & U32:
  match caps:
    case Local.Ops{read,_}:read(ctx)
def local_modified(result:Local.Cell<Memory>) -> Memory:
  match result:
    case Local.Cell{memory}:memory
def local_read(result:Memory & U32) -> Memory:
  match result:
    case (memory,_):local_modified(Local.modify_cell(~Memory,Local.Cell{memory},memory_next))
def local_step(memory:Memory) -> Memory:
  local_read(Local.provide(~Memory,~U32,~U32,~memory_project,~local_body,memory))
def body_read(~H:Type,memory:Memory,result:H & U32) -> H & (T.Outcome<String> & Memory):
  match result:
    case (ctx,_):(ctx,(T.Success{},local_step(memory)))
def body(~H:Type,~caps:Cap.ValueRead<H,U32>,memory:Memory,ctx:H) -> H & (T.Outcome<String> & Memory):
  body_read(~H,memory,Cap.value_read(~H,~U32,~caps,ctx))
def raw(~S:Data) -> P.Declaration<S,Resources,T.Tx<W.World<S,Store,Resources,Unit>,Unit>,Cap.ValueRead<T.Tx<W.World<S,Store,Resources,Unit>,Unit>,U32>>:
  D.ordinary(~S,~Store,~Resources,~Unit,~D.read_ops(~U32),~U32,declaration(~S))
def local_result(~H:Type,failed:Bool,ctx:H,memory:Memory) -> H & (Memory & (T.Outcome<String> & Unit)):
  match failed:
    case False{}:(ctx,(memory,(T.Success{},Unit{})))
    case True{}:(ctx,(memory,(T.Failure{"planned"},Unit{})))
def local_observed(~H:Type,memory:Memory,failed:Bool,result:H & U32) -> H & (Memory & (T.Outcome<String> & Unit)):
  match result:
    case (ctx,value):local_result(~H,U32.is_eq(value,99),ctx,local_step(memory))
def local_body_owned(~H:Type,~caps:Cap.ValueRead<H,U32>,memory:Memory,_:Unit,ctx:H) -> H & (Memory & (T.Outcome<String> & Unit)):
  local_observed(~H,memory,False{},Cap.value_read(~H,~U32,~caps,ctx))
def local_runner(~S:Data,world:W.World<S,Store,Resources,Unit>,memory:Memory,args:Unit) -> Local.Outcome<W.World<S,Store,Resources,Unit>,Memory,String,Unit>:
  LF.runner(~S,~Store,~Resources,~Unit,~Memory,~Unit,~String,~Unit,~D.read_ops(~U32),~raw(~S),~local_body_owned,world,memory,args)
def reader_declaration(~S:Data) -> D.Declaration<S,Store,Resources,Unit,D.write_ops(~Resources,~U32),U32>:
  D.write(~S,~Store,~Resources,~Unit,~U32,~projected,~U32.show,identity(~S))
def reader_raw(~S:Data) -> P.Declaration<S,Resources,T.Tx<W.World<S,Store,Resources,Unit>,Unit>,Cap.ValueWrite<T.Tx<W.World<S,Store,Resources,Unit>,Unit>,Resources,U32>>:
  D.ordinary(~S,~Store,~Resources,~Unit,~D.write_ops(~Resources,~U32),~U32,reader_declaration(~S))
def reader_returned(~H:Type,result:H & U32) -> H & (T.Outcome<String> & Unit):
  match result:
    case (ctx,_):(ctx,(T.Success{},Unit{}))
def reader_body(~H:Type,~caps:Cap.ValueWrite<H,Resources,U32>,args:Change,ctx:H) -> H & (T.Outcome<String> & Unit):
  match args:
    case Keep{}:reader_returned(~H,Cap.value_write_read_field(~H,~Resources,~U32,caps)(ctx))
    case Set{value}:(Cap.value_write_field(~H,~Resources,~U32,caps)(ctx,Resources{value}),(T.Success{},Unit{}))
def registry(~S:Data) -> Type:
  Sys.Registry<S,Store,Resources,Unit,Change,String,Unit,P.runner(~S,~Store,~Resources,~Unit,~D.write_ops(~Resources,~U32),~Change,~String,~Unit,~reader_raw(~S),~reader_body)>
def owner(~S:Data) -> Type:
  P.Owner<S,registry(~S),P.mode(~S,~Resources,~T.Tx<W.World<S,Store,Resources,Unit>,Unit>,~Cap.ValueWrite<T.Tx<W.World<S,Store,Resources,Unit>,Unit>,Resources,U32>,reader_raw(~S))>
def local_owner(~S:Data) -> Type:
  LF.Owner<S,Store,Resources,Unit,Memory,Unit,String,Unit,D.read_ops(~U32),raw(~S),local_body_owned>
def Reader(~S:Data) -> Type:
  Leaf.Record<S,Records.Token<registry(~S)>>
def Owners(~S:Data) -> Type:
  ((Unit & local_owner(~S)) & local_owner(~S)) & Leaf.Record<S,Records.Token<registry(~S)>>
def Rows() -> Data:
  DTO.Product<Unit,U32>
def local_fold(~S:Data) -> local_owner(~S) -> local_owner(~S) & List<&2,Records.Fields<S>>:
  LF.fold(~S,~Store,~Resources,~Unit,~Memory,~Unit,~String,~Unit,~D.read_ops(~U32),~raw(~S),~local_body_owned)
def fold1(~S:Data) -> (Unit & local_owner(~S)) -> (Unit & local_owner(~S)) & List<&2,Records.Fields<S>>:
  Leaf.fold_pair(~S,~Unit,~local_owner(~S),~Leaf.empty(~S),~local_fold(~S))
def fold2(~S:Data) -> ((Unit & local_owner(~S)) & local_owner(~S)) -> ((Unit & local_owner(~S)) & local_owner(~S)) & List<&2,Records.Fields<S>>:
  Leaf.fold_pair(~S,~(Unit & local_owner(~S)),~local_owner(~S),~fold1(~S),~local_fold(~S))
def fold(~S:Data) -> Owners(~S) -> Owners(~S) & List<&2,Records.Fields<S>>:
  Leaf.fold_pair(~S,~((Unit & local_owner(~S)) & local_owner(~S)),~Reader(~S),~fold2(~S),~Leaf.observed(~S,~Records.Token<registry(~S)>))
def observe(~S:Data) -> W.World<S,Store,Resources,Unit> -> W.World<S,Store,Resources,Unit> & DTO.Observation<Rows()>:
  Tree.observe_pair(~W.World<S,Store,Resources,Unit>,~Unit,~U32,~Build.empty_observe(~W.World<S,Store,Resources,Unit>),~Leaves.resource_observe(~S,~Store,~Resources,~Unit,~D.write_ops(~Resources,~U32),~U32,~reader_declaration(~S)))
def application(~S:Data) -> Type:
  Named.Application<S,Store,Resources,Unit,Owners(~S),Rows(),observe(~S),fold(~S)>
def local_completed(~S:Data,result:Local.Run<S,Store,Resources,Unit,Memory,Unit,String,Unit,LF.runner(~S,~Store,~Resources,~Unit,~Memory,~Unit,~String,~Unit,~D.read_ops(~U32),~raw(~S),~local_body_owned)>) -> local_owner(~S) & Sys.Outcome<W.World<S,Store,Resources,Unit>,String,Unit>:
  match result:
    case Local.Completed{world,instance,Done{_}}:(LF.Owner{instance},Sys.Succeeded{world,Unit{}})
    case Local.Completed{world,instance,Fail{error}}:(LF.Owner{instance},Sys.Failed{world,error})
    case Local.Refused{world,instance,_}:(LF.Owner{instance},Sys.Failed{world,"registration"})
def first_done(~S:Data,second:local_owner(~S),reader:Reader(~S),result:local_owner(~S) & Sys.Outcome<W.World<S,Store,Resources,Unit>,String,Unit>) -> Owners(~S) & Sys.Outcome<W.World<S,Store,Resources,Unit>,String,Unit>:
  match result:
    case (first,outcome):((((Unit{},first),second),reader),outcome)
def second_done(~S:Data,first:local_owner(~S),reader:Reader(~S),result:local_owner(~S) & Sys.Outcome<W.World<S,Store,Resources,Unit>,String,Unit>) -> Owners(~S) & Sys.Outcome<W.World<S,Store,Resources,Unit>,String,Unit>:
  match result:
    case (second,outcome):((((Unit{},first),second),reader),outcome)
def reader_done(~S:Data,first:local_owner(~S),second:local_owner(~S),result:Transport.TransportResult<S,W.World<S,Store,Resources,Unit>,Change,String,Unit,Records.Token<registry(~S)>>) -> Owners(~S) & Sys.Outcome<W.World<S,Store,Resources,Unit>,String,Unit>:
  match result:
    case Transport.Completed{token,fields,outcome}:((((Unit{},first),second),Leaf.Record{token,fields}),outcome)
    case Transport.RegistrationRejected{token,fields,world,_}:((((Unit{},first),second),Leaf.Record{token,fields}),Sys.Failed{world,"registration"})
def reader_called(~S:Data,first:local_owner(~S),second:local_owner(~S),reader:Reader(~S),world:W.World<S,Store,Resources,Unit>,args:Change) -> Owners(~S) & Sys.Outcome<W.World<S,Store,Resources,Unit>,String,Unit>:
  match reader:
    case Leaf.Record{token,fields}:reader_done(~S,first,second,Transport.run(~S,~Store,~Resources,~Unit,~Change,~String,~Unit,~P.runner(~S,~Store,~Resources,~Unit,~D.write_ops(~Resources,~U32),~Change,~String,~Unit,~reader_raw(~S),~reader_body),token,fields,world,args))
def dispatch(~S:Data,owners:Owners(~S),world:W.World<S,Store,Resources,Unit>,id:U32) -> Owners(~S) & Sys.Outcome<W.World<S,Store,Resources,Unit>,String,Unit>:
  match owners id:
    case (((_,first),second),reader) 1:first_done(~S,second,reader,local_completed(~S,LF.run(~S,~Store,~Resources,~Unit,~Memory,~Unit,~String,~Unit,~D.read_ops(~U32),~raw(~S),~local_body_owned,first,world,Unit{})))
    case (((_,first),second),reader) 2:second_done(~S,first,reader,local_completed(~S,LF.run(~S,~Store,~Resources,~Unit,~Memory,~Unit,~String,~Unit,~D.read_ops(~U32),~raw(~S),~local_body_owned,second,world,Unit{})))
    case (((_,first),second),reader) 3:reader_called(~S,first,second,reader,world,Keep{})
    case owners _:(owners,Sys.Failed{world,"unknown"})
def condition(~S:Data,world:W.World<S,Store,Resources,Unit>,slot:U32) -> W.World<S,Store,Resources,Unit> & Bool:
  (world,U32.is_eq(slot,0))
def provision(~S:Data,world:W.World<S,Store,Resources,Unit>) -> W.World<S,Store,Resources,Unit> & List<&2,SP.Requirement<S>>:
  (world,[])
def Before(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Store,Resources,Unit>,Unit,Unit,Build.empty_observe(~W.World<S,Store,Resources,Unit>),Leaf.empty(~S)>
def First(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Store,Resources,Unit>,Unit & local_owner(~S),Unit,Build.empty_observe(~W.World<S,Store,Resources,Unit>),fold1(~S)>
def Second(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Store,Resources,Unit>,(Unit & local_owner(~S)) & local_owner(~S),Unit,Build.empty_observe(~W.World<S,Store,Resources,Unit>),fold2(~S)>
def Final(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Store,Resources,Unit>,Owners(~S),Rows(),observe(~S),fold(~S)>
def reader_registered(~S:Data,app:Final(~S)) -> Maybe<&1,application(~S)>:
  Some{Named.create(~S,~Store,~Resources,~Unit,~Owners(~S),~Rows(),~observe(~S),~fold(~S),App.Application{Schema.Schema{Schema.entries(~S,~Unit,~Resources,Schema.resource_schema(~S,~Resources,identity(~S)))},app})}
def reader_failed(~S:Data,_:Second(~S)) -> Maybe<&1,application(~S)>:
  None{}
def second_registered(~S:Data,result:LF.Appended<First(~S),Second(~S),Memory>) -> Maybe<&1,application(~S)>:
  match result:
    case LF.AppendRejected{_,_}:None{}
    case LF.Appended{app}:ResourceApp.register(~S,~Store,~Resources,~Unit,~((Unit & local_owner(~S)) & local_owner(~S)),~Unit,~Build.empty_observe(~W.World<S,Store,Resources,Unit>),~fold2(~S),~D.write_ops(~Resources,~U32),~Change,~String,~Unit,~U32,~reader_declaration(~S),~reader_body,~Maybe<&1,application(~S)>,reader_registered(~S),reader_failed(~S),app,"Reader","Counter")
def first_registered(~S:Data,result:LF.Appended<Before(~S),First(~S),Memory>) -> Maybe<&1,application(~S)>:
  match result:
    case LF.AppendRejected{_,_}:None{}
    case LF.Appended{app}:second_registered(~S,LF.register(~S,~Store,~Resources,~Unit,~Memory,~Unit,~String,~Unit,~D.read_ops(~U32),~raw(~S),~local_body_owned,~(Unit & local_owner(~S)),~Unit,~Build.empty_observe(~W.World<S,Store,Resources,Unit>),~fold1(~S),app,"Independent",Memory{Array.new(U32,0n,0),0}))
def created(~S:Data,result:WI.Creation<S,Store,Resources,Unit>) -> Maybe<&1,application(~S)>:
  match result:
    case WI.Refused{_}:None{}
    case WI.Created{world}:first_registered(~S,LF.register(~S,~Store,~Resources,~Unit,~Memory,~Unit,~String,~Unit,~D.read_ops(~U32),~raw(~S),~local_body_owned,~Unit,~Unit,~Build.empty_observe(~W.World<S,Store,Resources,Unit>),~Leaf.empty(~S),Build.empty(~S,~W.World<S,Store,Resources,Unit>,world),"Shared",Memory{Array.new(U32,0n,0),0}))
def create(~S:Data) -> IO(Maybe<&1,application(~S)>):
  IO.bind(WI.Creation<S,Store,Resources,Unit>,Maybe<&1,application(~S)>,WI.create(~S,~Store,~Resources,~Unit,~empty,Resources{9}),value => IO.pure(Maybe<&1,application(~S)>,created(~S,value)))
def mode_value(failed:Bool) -> U32:
  match failed:
    case False{}:9
    case True{}:99
def advanced(~S:Data,schema:Schema.Schema<S,Store,Resources>,owners:Owners(~S),recipe:Tree.Recipe<W.World<S,Store,Resources,Unit>,Rows(),observe(~S)>,debug:Bool,plans:List<&2,Named.Named<S>>,result:W.World<S,Store,Resources,Unit> & U32) -> application(~S):
  match result:
    case (world,_):Named.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plans}
def advance(~S:Data,value:application(~S)) -> application(~S):
  match value:
    case Named.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plans}:advanced(~S,schema,owners,recipe,debug,plans,W.advance_clock(~S,~Store,~Resources,~Unit,world))
def mode_restored(~S:Data,schema:Schema.Schema<S,Store,Resources>,recipe:Tree.Recipe<W.World<S,Store,Resources,Unit>,Rows(),observe(~S)>,debug:Bool,plans:List<&2,Named.Named<S>>,result:Owners(~S) & Sys.Outcome<W.World<S,Store,Resources,Unit>,String,Unit>) -> application(~S):
  match result:
    case (owners,Sys.Succeeded{world,_}):Named.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plans}
    case (owners,Sys.Failed{world,_}):Named.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plans}
def mode(~S:Data,value:application(~S),failed:Bool) -> application(~S):
  match value:
    case Named.Application{App.Application{schema,Build.Registered{world,(((unit,first),second),reader),recipe,debug}},plans}:mode_restored(~S,schema,recipe,debug,plans,reader_called(~S,first,second,reader,world,Set{mode_value(failed)}))
