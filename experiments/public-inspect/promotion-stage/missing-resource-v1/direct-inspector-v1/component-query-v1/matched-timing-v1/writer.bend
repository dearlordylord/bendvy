import Base
import schema-families.bend as D
import runtime-owners.bend as Owners
import world-observer.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
def World(~S:Data) -> Type:W.World<S,D.Store<S>,Owners.Resource(~S),U32>
def Ops(~S:Data,H:Type) -> Type:Cap.Write<H,D.Stock,U32> & Cap.Write<H,D.Title,String>
def declaration(~S:Data) -> Decl.Declaration<S,Q.Frame<S,D.Store<S>,Owners.Resource(~S),U32>,Ops(~S,Q.Frame<S,D.Store<S>,Owners.Resource(~S),U32>)>:
  Decl.pair(~S,~Q.Frame<S,D.Store<S>,Owners.Resource(~S),U32>,~Cap.Write<Q.Frame<S,D.Store<S>,Owners.Resource(~S),U32>,D.Stock,U32>,~Cap.Write<Q.Frame<S,D.Store<S>,Owners.Resource(~S),U32>,D.Title,String>,~Decl.write(~S,~D.Stock,~D.Store<S>,~Owners.Resource(~S),~U32,~D.StockRest<S>,~U32,~D.StockToken,~B.identity(~S,~D.Store<S>,~D.StockRest<S>,~D.Stock,~U32,~D.StockToken,~D.take_stock(~S),~D.put_stock(~S),~D.project_stock,D.stock_binding(~S)),~D.project_stock,~D.take_stock(~S),~D.put_stock(~S)),~Decl.write(~S,~D.Title,~D.Store<S>,~Owners.Resource(~S),~U32,~D.TitleRest<S>,~String,~D.TitleToken,~B.identity(~S,~D.Store<S>,~D.TitleRest<S>,~D.Title,~String,~D.TitleToken,~D.take_title(~S),~D.put_title(~S),~D.project_title,D.title_binding(~S)),~D.project_title,~D.take_title(~S),~D.put_title(~S)))
def first(~S:Data,~H:Type,caps:Ops(~S,H)) -> Cap.Write<H,D.Stock,U32>:
  match caps:
    case (first,_):first
def second(~S:Data,~H:Type,caps:Ops(~S,H)) -> Cap.Write<H,D.Title,String>:
  match caps:
    case (_,second):second
def paired_write(~S:Data,~H:Type,~caps:Ops(~S,H),+value:U32,owner:H) -> H & (T.Outcome<Unit> & Unit):
  (Cap.set(~H,~D.Title,~String,~second(~S,~H,caps),Cap.set(~H,~D.Stock,~U32,~first(~S,~H,caps),owner,D.Stock{Array.new(U32,0n,value)}),D.Title{Array.new(U32,0n,(value + 1 : U32))}),(T.Success{},Unit{}))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),value:U32,owner:H) -> H & (T.Outcome<Unit> & Unit):
  paired_write(~S,~H,~caps,value,owner)
def Registry(~S:Data) -> Type:Sys.Registry<S,D.Store<S>,Owners.Resource(~S),U32,U32 & U32,Q.Error<Unit>,List<&2,Unit>,Ord.runner(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Ops(~S),~U32,~Unit,~Unit,~declaration(~S),~body(~S))>
type Holder<S:Data> is Type:
  Holder{owner:Ord.Owner<S,Registry(~S)>,value:U32,output:Maybe<&2,List<&2,Unit>>}
type Started<S:Data> is Type:
  Started{world:World(~S),holder:Holder<S>}
  Rejected{world:World(~S)}
def registered(~S:Data,result:Ord.Defined<S,World(~S),Registry(~S)>) -> Started<S>:
  match result:
    case Ord.Defined{world,owner}:Started{world,Holder{owner,700,None{}}}
    case Ord.Rejected{world}:Rejected{world}
def start(~S:Data,world:World(~S)) -> Started<S>:
  registered(~S,Ord.define(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Ops(~S),~U32,~Unit,~Unit,~declaration(~S),~body(~S),world,"PairedWriter","StockTitle"))
def completed(~S:Data,value:U32,slot:String,clauses:List<&2,Decl.Clause<S>>,result:Sys.RunResult<S,D.Store<S>,Owners.Resource(~S),U32,U32 & U32,Q.Error<Unit>,List<&2,Unit>,Ord.runner(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Ops(~S),~U32,~Unit,~Unit,~declaration(~S),~body(~S))>) -> Holder<S> & Sys.Outcome<World(~S),Unit,Unit>:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,out}}:(Holder{Ord.Owner{registry,slot,clauses},(value + 100 : U32),Some{out}},Sys.Succeeded{world,Unit{}})
    case Sys.Completed{registry,Sys.Failed{world,_}}:(Holder{Ord.Owner{registry,slot,clauses},value,None{}},Sys.Failed{world,Unit{}})
    case Sys.RegistrationRejected{registry,world,_}:(Holder{Ord.Owner{registry,slot,clauses},value,None{}},Sys.Failed{world,Unit{}})
def returned(~S:Data,value:U32,result:Sys.RunResult<S,D.Store<S>,Owners.Resource(~S),U32,U32 & U32,Q.Error<Unit>,List<&2,Unit>,Ord.runner(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Ops(~S),~U32,~Unit,~Unit,~declaration(~S),~body(~S))> & (String & List<&2,Decl.Clause<S>>)) -> Holder<S> & Sys.Outcome<World(~S),Unit,Unit>:
  (ran,(slot,clauses))=result
  completed(~S,value,slot,clauses,ran)
def dispatch(~S:Data,holder:Holder<S>,world:World(~S),_:U32) -> Holder<S> & Sys.Outcome<World(~S),Unit,Unit>:
  match holder:
    case Holder{owner,+value,_}:returned(~S,value,Ord.run(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Ops(~S),~U32,~Unit,~Unit,~declaration(~S),~body(~S),owner,world,value))
def condition(~S:Data,world:World(~S),_:U32) -> World(~S) & Bool:(world,True{})
type Outcome<S:Data> is Type:
  Outcome{world:World(~S),holder:Holder<S>,observations:List<&2,Sch.Observation>,status:String}
def finished(~S:Data,result:Sch.RunResult<S,D.Store<S>,Owners.Resource(~S),U32,Holder<S>,Unit>) -> Outcome<S>:
  match result:
    case Sch.Finished{Sch.Schedule{_,_,_,holder},world,observations}:Outcome{world,holder,observations,"Finished"}
    case Sch.Failed{Sch.Schedule{_,_,_,holder},world,_,observations}:Outcome{world,holder,observations,"Failed"}
    case Sch.Rejected{Sch.Schedule{_,_,_,holder},world}:Outcome{world,holder,[],"Rejected"}
def built(~S:Data,world:World(~S),result:Sch.Build<S,D.Store<S>,Owners.Resource(~S),U32,Holder<S>>) -> Outcome<S>:
  match result:
    case Sch.Built{schedule}:finished(~S,Sch.run(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Holder<S>,~Unit,~dispatch(~S),~condition(~S),schedule,world))
    case Sch.Invalid{holder}:Outcome{world,holder,[],"Invalid"}
def ids(values:List<&2,W.RegistrationMeta>) -> List<&2,U32>:
  match values:
    case []:[]
    case W.RegistrationMeta{id,_,_} <> rest:id <> ids(rest)
def cataloged(~S:Data,+id:U32,holder:Holder<S>,world:World(~S)) -> Outcome<S>:
  match world:
    case W.World{+namespace,next,high,live,capacity,depth,store,resource,events,pending,+registrations,nextSystem,clock}:built(~S,W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,clock},Sch.build(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Holder<S>,namespace,"PairedWriterSchedule",[Sch.System{id,0}],ids(registrations),holder))
def identified(~S:Data,world:World(~S),value:U32,out:Maybe<&2,List<&2,Unit>>,slot:String,clauses:List<&2,Decl.Clause<S>>,result:Registry(~S) & U32) -> Outcome<S>:
  (registry,id)=result
  cataloged(~S,id,Holder{Ord.Owner{registry,slot,clauses},value,out},world)
def run(~S:Data,world:World(~S),holder:Holder<S>) -> Outcome<S>:
  match holder:
    case Holder{Ord.Owner{registry,slot,clauses},value,out}:identified(~S,world,value,out,slot,clauses,Sys.identity(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~(U32 & U32),~Q.Error<Unit>,~List<&2,Unit>,~Ord.runner(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Ops(~S),~U32,~Unit,~Unit,~declaration(~S),~body(~S)),registry))
def observed(~S:Data,+value:U32,+out:Maybe<&2,List<&2,Unit>>,slot:String,clauses:List<&2,Decl.Clause<S>>,result:Registry(~S) & String) -> Holder<S> & String:
  (registry,text)=result
  (Holder{Ord.Owner{registry,slot,clauses},value,out},text ++ "|writerValue=" ++ U32.show(value) ++ "|writerOut=" ++ Maybe.show(&2,List<&2,Unit>,List.show(&2,Unit,_ => "Unit"),out))
def observe(~S:Data,holder:Holder<S>) -> Holder<S> & String:
  match holder:
    case Holder{Ord.Owner{registry,slot,clauses},value,out}:observed(~S,value,out,slot,clauses,Dump.registry(~S,~(U32 & U32),~Q.Error<Unit>,~List<&2,Unit>,~Ord.runner(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Ops(~S),~U32,~Unit,~Unit,~declaration(~S),~body(~S)),registry))
