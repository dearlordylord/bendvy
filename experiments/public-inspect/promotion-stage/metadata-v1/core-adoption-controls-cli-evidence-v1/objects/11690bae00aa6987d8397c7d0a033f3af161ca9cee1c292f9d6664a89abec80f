import Base
import ../bend-candidate/query-consumer.bend as A
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/inspector-query-projection.bend as Q
import ../../../src/ecs/inspector-query.bend as API
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/capabilities.bend as Cap

type Reads<H:Type> is Type:
  Reads{required:API.ReadQuery<H,A.Schema,List<&2,U32>>,optional:API.ReadQuery<H,A.Schema,List<&2,U32>>,added:API.ReadQuery<H,A.Schema,List<&2,U32>>,changed:API.ReadQuery<H,A.Schema,List<&2,U32>>,score:Cap.ValueRead<H,List<&2,U32>>}
def Ops(H:Type) -> Type:
  Reads<H>
def plan() -> I.Plan<A.Schema,A.Store,A.Resource,U32,Ops>:
  I.Plan{Reads{API.grant(~A.Schema,~A.Store,~A.Resource,~U32,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,~A.family(),~Q.Required{}),API.grant(~A.Schema,~A.Store,~A.Resource,~U32,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,~A.family(),~Q.Optional{}),API.grant(~A.Schema,~A.Store,~A.Resource,~U32,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,~A.family(),~Q.Added{}),API.grant(~A.Schema,~A.Store,~A.Resource,~U32,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,~A.family(),~Q.Changed{}),I.read_resource(~A.Schema,~A.Store,~A.Resource,~U32,~List<&2,U32>,~A.project_resource)}}
def required(~H:Type,caps:Reads<H>) -> API.ReadQuery<H,A.Schema,List<&2,U32>>:
  match caps:
    case Reads{value,_,_,_,_}:value
def optional(~H:Type,caps:Reads<H>) -> API.ReadQuery<H,A.Schema,List<&2,U32>>:
  match caps:
    case Reads{_,value,_,_,_}:value
def added(~H:Type,caps:Reads<H>) -> API.ReadQuery<H,A.Schema,List<&2,U32>>:
  match caps:
    case Reads{_,_,value,_,_}:value
def changed(~H:Type,caps:Reads<H>) -> API.ReadQuery<H,A.Schema,List<&2,U32>>:
  match caps:
    case Reads{_,_,_,value,_}:value
def score(~H:Type,caps:Reads<H>) -> Cap.ValueRead<H,List<&2,U32>>:
  match caps:
    case Reads{_,_,_,_,value}:value
def row(value:Q.Row<A.Schema,List<&2,U32>>) -> String:
  match value:
    case Q.Row{W.Handle{_,id},I.Value{access,_,_}}:U32.show(id) ++ ":" ++ A.access(access)
def lookup_text(value:Result<&2,&2,API.LookupError,Q.Row<A.Schema,List<&2,U32>>>) -> String:
  match value:
    case Fail{API.MissingEntity{id}}:"MissingEntity:" ++ U32.show(id)
    case Fail{API.QueryMismatch{id}}:"QueryMismatch:" ++ U32.show(id)
    case Done{value}:"Found:" ++ row(value)
def single_text(value:Result<&2,&2,API.SingleError,Q.Row<A.Schema,List<&2,U32>>>) -> String:
  match value:
    case Fail{API.NoEntities{}}:"NoEntities"
    case Fail{API.MultipleEntities{count}}:"MultipleEntities:" ++ Nat.show(count)
    case Done{value}:"Found:" ++ row(value)
def optional_text(value:Result<&2,&2,API.SingleError,Maybe<&2,Q.Row<A.Schema,List<&2,U32>>>>) -> String:
  match value:
    case Fail{API.NoEntities{}}:"unexpected-NoEntities"
    case Fail{API.MultipleEntities{count}}:"MultipleEntities:" ++ Nat.show(count)
    case Done{None{}}:"None"
    case Done{Some{value}}:"Found:" ++ row(value)
def optional_done(~H:Type,text:String,result:H & Result<&2,&2,API.SingleError,Maybe<&2,Q.Row<A.Schema,List<&2,U32>>>>) -> H & String:
  (owner,value)=result
  (owner,text ++ "|optional=" ++ optional_text(value) ++ "\n")
def single_done(~H:Type,~cap:API.ReadQuery<H,A.Schema,List<&2,U32>>,text:String,result:H & Result<&2,&2,API.SingleError,Q.Row<A.Schema,List<&2,U32>>>) -> H & String:
  (owner,value)=result
  optional_done(~H,text ++ "|single=" ++ single_text(value),API.single_optional(~H,~A.Schema,~List<&2,U32>,~cap,owner))
def lookup_done(~H:Type,~cap:API.ReadQuery<H,A.Schema,List<&2,U32>>,text:String,result:H & Result<&2,&2,API.LookupError,Q.Row<A.Schema,List<&2,U32>>>) -> H & String:
  (owner,value)=result
  single_done(~H,~cap,text ++ "|get=" ++ lookup_text(value),API.single(~H,~A.Schema,~List<&2,U32>,~cap,owner))
def each_done(~H:Type,~cap:API.ReadQuery<H,A.Schema,List<&2,U32>>,label:String,target:W.Handle<A.Schema>,result:H & List<&2,Q.Row<A.Schema,List<&2,U32>>>) -> H & String:
  (owner,rows)=result
  lookup_done(~H,~cap,label ++ "|each=" ++ List.show(&2,Q.Row<A.Schema,List<&2,U32>>,row,rows),API.get(~H,~A.Schema,~List<&2,U32>,~cap,owner,target))
def read_query(~H:Type,~cap:API.ReadQuery<H,A.Schema,List<&2,U32>>,label:String,target:W.Handle<A.Schema>,owner:H) -> H & String:
  each_done(~H,~cap,label,target,API.each(~H,~A.Schema,~List<&2,U32>,~cap,owner))
def scored(~H:Type,text:String,result:H & List<&2,U32>) -> H & Result<&2,&2,String,String>:
  (owner,value)=result
  (owner,Done{text ++ "score=" ++ List.show(&2,U32,U32.show,value) ++ "\n"})
def changed_done(~H:Type,~caps:Reads<H>,text:String,result:H & String) -> H & Result<&2,&2,String,String>:
  (owner,line)=result
  scored(~H,text ++ line,Cap.value_read(~H,~List<&2,U32>,~score(~H,caps),owner))
def added_done(~H:Type,~caps:Reads<H>,target:W.Handle<A.Schema>,text:String,result:H & String) -> H & Result<&2,&2,String,String>:
  (owner,line)=result
  changed_done(~H,~caps,text ++ line,read_query(~H,~changed(~H,caps),"changed",target,owner))
def optional_read_done(~H:Type,~caps:Reads<H>,+target:W.Handle<A.Schema>,text:String,result:H & String) -> H & Result<&2,&2,String,String>:
  (owner,line)=result
  added_done(~H,~caps,target,text ++ line,read_query(~H,~added(~H,caps),"added",target,owner))
def required_done(~H:Type,~caps:Reads<H>,+target:W.Handle<A.Schema>,result:H & String) -> H & Result<&2,&2,String,String>:
  (owner,line)=result
  optional_read_done(~H,~caps,target,line,read_query(~H,~optional(~H,caps),"optional",target,owner))
def body(~H:Type,~caps:Reads<H>,target:W.Handle<A.Schema>,owner:H) -> H & Result<&2,&2,String,String>:
  match target:
    case W.Handle{+namespace,+id}:required_done(~H,~caps,W.Handle{namespace,id},read_query(~H,~required(~H,caps),"required",W.Handle{namespace,id},owner))
type State is Type:
  State{world:W.World<A.Schema,A.Store,A.Resource,U32>,instance:I.Instance<A.Schema>,target:W.Handle<A.Schema>,text:String}
def observed(+target:W.Handle<A.Schema>,prefix:String,label:String,result:I.Observed<A.Schema,A.Store,A.Resource,U32,String,String>) -> State:
  match result:
    case I.Observed{world,instance,Done{text}}:State{world,instance,target,prefix ++ label ++ "\n" ++ text}
    case I.Observed{world,instance,Fail{text}}:State{world,instance,target,prefix ++ "unexpected-failure:" ++ text}
def inspect(+target:W.Handle<A.Schema>,world:W.World<A.Schema,A.Store,A.Resource,U32>,instance:I.Instance<A.Schema>,prefix:String,label:String) -> State:
  observed(target,prefix,label,I.run(~A.Schema,~A.Store,~A.Resource,~U32,~Ops,~W.Handle<A.Schema>,~String,~String,~plan(),~body,instance,target,world))
def final(state:State) -> String:
  match state:
    case State{_,_,_,text}:text
def many_repeat(state:State) -> String:
  match state:
    case State{world,instance,+target,text}:final(inspect(target,world,instance,text,"many-repeat"))
def second_replaced(+target:W.Handle<A.Schema>,instance:I.Instance<A.Schema>,text:String,result:C.Replacement<W.World<A.Schema,A.Store,A.Resource,U32>,A.Payload>) -> String:
  match result:
    case C.Replaced{world,_}:many_repeat(inspect(target,world,instance,text,"many"))
    case _:"second-replacement-rejected"
def second_activated(+target:W.Handle<A.Schema>,+second:W.Handle<A.Schema>,instance:I.Instance<A.Schema>,text:String,result:W.World<A.Schema,A.Store,A.Resource,U32> & W.Status) -> String:
  (world,_)=result
  second_replaced(target,instance,text,C.replace(~A.Schema,~A.Store,~A.Resource,~U32,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,A.family(),world,second,Some{A.Payload{Array.set(U32,Array.new(U32,2n,31),3,34)}}))
def second_reserved(+target:W.Handle<A.Schema>,instance:I.Instance<A.Schema>,text:String,result:W.World<A.Schema,A.Store,A.Resource,U32> & W.Reservation<A.Schema>) -> String:
  match result:
    case (world,W.Reserved{+second}):second_activated(target,second,instance,text,W.activate(~A.Schema,~A.Store,~A.Resource,~U32,world,second))
    case _:"second-reservation-rejected"
def one_repeat(state:State) -> String:
  match state:
    case State{world,instance,+target,text}:second_reserved(target,instance,text,W.reserve_id(~A.Schema,~A.Store,~A.Resource,~U32,world))
def one(state:State) -> String:
  match state:
    case State{world,instance,+target,text}:one_repeat(inspect(target,world,instance,text,"one-repeat"))
def first_replaced(+target:W.Handle<A.Schema>,instance:I.Instance<A.Schema>,text:String,result:C.Replacement<W.World<A.Schema,A.Store,A.Resource,U32>,A.Payload>) -> String:
  match result:
    case C.Replaced{world,_}:one(inspect(target,world,instance,text,"one"))
    case _:"first-replacement-rejected"
def absent(state:State) -> String:
  match state:
    case State{world,instance,+target,text}:first_replaced(target,instance,text,C.replace(~A.Schema,~A.Store,~A.Resource,~U32,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,A.family(),world,target,Some{A.Payload{Array.set(U32,Array.new(U32,2n,11),3,14)}}))
def first_activated(+target:W.Handle<A.Schema>,instance:I.Instance<A.Schema>,text:String,result:W.World<A.Schema,A.Store,A.Resource,U32> & W.Status) -> String:
  (world,_)=result
  absent(inspect(target,world,instance,text,"absent"))
def reserved_observed(state:State) -> String:
  match state:
    case State{world,instance,+target,text}:first_activated(target,instance,text,W.activate(~A.Schema,~A.Store,~A.Resource,~U32,world,target))
def reserved(result:W.World<A.Schema,A.Store,A.Resource,U32> & W.Reservation<A.Schema>) -> String:
  match result:
    case (world,W.Reserved{+target}):reserved_observed(inspect(target,world,I.Fresh{},"","reserved"))
    case _:"first-reservation-rejected"
def created(result:W.Creation<A.Schema,A.Store,A.Resource,U32>) -> String:
  match result:
    case W.Created{_,world}:reserved(W.reserve_id(~A.Schema,~A.Store,~A.Resource,~U32,world))
    case _:"creation-rejected"
def main() -> String:
  created(W.create(~A.Schema,~A.Store,~A.Resource,~U32,~A.empty,W.factory(),A.Resource{Array.set(U32,Array.new(U32,2n,21),3,24)}))
