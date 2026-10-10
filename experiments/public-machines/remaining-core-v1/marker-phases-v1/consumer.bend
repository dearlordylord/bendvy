import Base
import phases.bend as Ph
import cohort.bend as Coh
import /workspace/formal-proofs/bendvy/src/ecs/machine-queue.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-operations.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as OD
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-world.bend as MW
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

type SchemaA is Data: SchemaA{}
type SchemaB is Data: SchemaB{}
type FlowKey is Data: FlowKey{}
type LevelKey is Data: LevelKey{}
type Tag is Data: Boot{} Play{} Pause{}
type Value is Data: Value{tag:Tag,representation:U32}
type Resources<S:Data> is Type: Resources{owned:Array<U32>,slot:M.Slot<S,FlowKey,Value>,level:M.Slot<S,LevelKey,Value>}
type Action is Data: Idle{} QueueFlow{input:M.QueueInput<Value>} QueueLevel{input:M.QueueInput<Value>}
type Request is Data: Request{label:String,action:Action}
def tag_same(a:Tag,b:Tag) -> Bool:
  match a b:
    case Boot{} Boot{}:True{}
    case Play{} Play{}:True{}
    case Pause{} Pause{}:True{}
    case _ _:False{}
def same(a:Value,b:Value) -> Bool:
  match a b:
    case Value{a,_} Value{b,_}:tag_same(a,b)
def take_resource(~S:Data,resources:Resources<S>) -> Resources<S> & M.Slot<S,FlowKey,Value>:
  match resources:
    case Resources{owned,+slot,level}:(Resources{owned,slot,level},slot)
def put_resource(~S:Data,resources:Resources<S>,slot:M.Slot<S,FlowKey,Value>) -> Resources<S>:
  match resources:
    case Resources{owned,_,level}:Resources{owned,slot,level}
def take(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> W.World<S,Array<Array<U32>>,Resources<S>,String> & M.Slot<S,FlowKey,Value>:
  MW.take(~S,~FlowKey,~Value,~Array<Array<U32>>,~Resources<S>,~String,~take_resource(~S),world)
def put(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>,slot:M.Slot<S,FlowKey,Value>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  MW.put(~S,~FlowKey,~Value,~Array<Array<U32>>,~Resources<S>,~String,~put_resource(~S),world,slot)
def family(~S:Data) -> M.Family<S,FlowKey,Value,W.World<S,Array<Array<U32>>,Resources<S>,String>,take(~S),put(~S)>:
  M.Family{"Flow"}
def enqueue_go(~S:Data,commands:List<&1,(W.World<S,Array<Array<U32>>,Resources<S>,String> -> W.World<S,Array<Array<U32>>,Resources<S>,String>)>,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match commands:
    case []:world
    case command <> rest:enqueue_go(~S,rest,W.enqueue(~S,~Array<Array<U32>>,~Resources<S>,~String,world,command))
def enqueue(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>,commands:List<&1,(W.World<S,Array<Array<U32>>,Resources<S>,String> -> W.World<S,Array<Array<U32>>,Resources<S>,String>)>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  enqueue_go(~S,commands,world)
def publish(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>,events:List<&2,String>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,prior,pending,registrations,nextSystem,clock}:W.World{ns,next,high,live,capacity,depth,store,resource,List.append(&2,String,prior,events),pending,registrations,nextSystem,clock}
def completed(~S:Data,result:Tx.Returned<W.World<S,Array<Array<U32>>,Resources<S>,String>,String>) -> Sys.Outcome<W.World<S,Array<Array<U32>>,Resources<S>,String>,String,Unit>:
  match result:
    case Tx.Returned{world,Tx.Success{}}:Sys.Succeeded{world,Unit{}}
    case Tx.Returned{world,Tx.Failure{error}}:Sys.Failed{world,error}
def finish(~S:Data,frame:Tx.Tx<W.World<S,Array<Array<U32>>,Resources<S>,String>,String>,fail:Bool) -> Sys.Outcome<W.World<S,Array<Array<U32>>,Resources<S>,String>,String,Unit>:
  match fail:
    case False{}:completed(~S,Tx.finish(~W.World<S,Array<Array<U32>>,Resources<S>,String>,~String,~String,~enqueue(~S),~publish(~S),frame,Tx.Success{}))
    case True{}:completed(~S,Tx.finish(~W.World<S,Array<Array<U32>>,Resources<S>,String>,~String,~String,~enqueue(~S),~publish(~S),frame,Tx.Failure{"rollback"}))
def tag(tag:Tag) -> String:
  match tag:
    case Boot{}:"Boot"
    case Play{}:"Play"
    case Pause{}:"Pause"
def show_value(value:Value) -> String:
  match value:
    case Value{kind,representation}:tag(kind) ++ ":" ++ U32.show(representation)
def take_level_resource(~S:Data,resources:Resources<S>) -> Resources<S> & M.Slot<S,LevelKey,Value>:
  match resources:
    case Resources{owned,flow,+level}:(Resources{owned,flow,level},level)
def put_level_resource(~S:Data,resources:Resources<S>,slot:M.Slot<S,LevelKey,Value>) -> Resources<S>:
  match resources:
    case Resources{owned,flow,_}:Resources{owned,flow,slot}
def take_level(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> W.World<S,Array<Array<U32>>,Resources<S>,String> & M.Slot<S,LevelKey,Value>:MW.take(~S,~LevelKey,~Value,~Array<Array<U32>>,~Resources<S>,~String,~take_level_resource(~S),world)
def put_level(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>,slot:M.Slot<S,LevelKey,Value>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:MW.put(~S,~LevelKey,~Value,~Array<Array<U32>>,~Resources<S>,~String,~put_level_resource(~S),world,slot)
def flow_declaration(~S:Data) -> OD.Declaration<S,FlowKey,Value,Resources<S>,take_resource(~S)>:OD.Declaration{"Flow"}
def level_declaration(~S:Data) -> OD.Declaration<S,LevelKey,Value,Resources<S>,take_level_resource(~S)>:OD.Declaration{"Level"}
type Ops<-S:Data,-H:Type> is Type: Ops{flow:Cap.ValueWrite<H,M.QueueInput<Value>,M.CurrentView<S,FlowKey,Value>>,level:Cap.ValueWrite<H,M.QueueInput<Value>,M.CurrentView<S,LevelKey,Value>>}
def flow_cap(~S:Data,~H:Type,ops:Ops<S,H>) -> Cap.ValueWrite<H,M.QueueInput<Value>,M.CurrentView<S,FlowKey,Value>>:
  match ops:
    case Ops{flow,_}:flow
def level_cap(~S:Data,~H:Type,ops:Ops<S,H>) -> Cap.ValueWrite<H,M.QueueInput<Value>,M.CurrentView<S,LevelKey,Value>>:
  match ops:
    case Ops{_,level}:level
def current(~S:Data,~K:Data,view:M.CurrentView<S,K,Value>) -> String:
  match view:
    case M.Unavailable{}:"missing"
    case M.Current{value}:show_value(value)
def act(~S:Data,~H:Type,~ops:Ops<S,H>,owner:H,action:Action) -> H:
  match action:
    case Idle{}:owner
    case QueueFlow{input}:Cap.value_set(~H,~M.QueueInput<Value>,~M.CurrentView<S,FlowKey,Value>,~flow_cap(~S,~H,ops),owner,input)
    case QueueLevel{input}:Cap.value_set(~H,~M.QueueInput<Value>,~M.CurrentView<S,LevelKey,Value>,~level_cap(~S,~H,ops),owner,input)
def body_level(~S:Data,~H:Type,~ops:Ops<S,H>,request:Request,flow:M.CurrentView<S,FlowKey,Value>,observed:H & M.CurrentView<S,LevelKey,Value>) -> H & String:
  match request observed:
    case Request{label,action},(owner,level):(act(~S,~H,~ops,owner,action),label ++ ":Flow=" ++ current(~S,~FlowKey,flow) ++ ",Level=" ++ current(~S,~LevelKey,level))
def body_flow(~S:Data,~H:Type,~ops:Ops<S,H>,request:Request,observed:H & M.CurrentView<S,FlowKey,Value>) -> H & String:
  (owner,flow)=observed
  body_level(~S,~H,~ops,request,flow,Cap.value_get(~H,~M.QueueInput<Value>,~M.CurrentView<S,LevelKey,Value>,~level_cap(~S,~H,ops),owner))
def body(~S:Data,~H:Type,~ops:Ops<S,H>,request:Request,owner:H) -> H & String:
  body_flow(~S,~H,~ops,request,Cap.value_get(~H,~M.QueueInput<Value>,~M.CurrentView<S,FlowKey,Value>,~flow_cap(~S,~H,ops),owner))
def invoked(~S:Data,pair:Tx.Tx<W.World<S,Array<Array<U32>>,Resources<S>,String>,String> & String) -> Sys.Outcome<W.World<S,Array<Array<U32>>,Resources<S>,String>,String,Unit>:
  (frame,event)=pair
  finish(~S,Tx.emit(~W.World<S,Array<Array<U32>>,Resources<S>,String>,~String,frame,event),False{})
def runner(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>,request:Request) -> Sys.Outcome<W.World<S,Array<Array<U32>>,Resources<S>,String>,String,Unit>:
  invoked(~S,Cap.invoke(~(H => Ops<S,H>),~Request,~String,~body(~S),~Tx.Tx<W.World<S,Array<Array<U32>>,Resources<S>,String>,String>,~Ops{F.write(~S,~FlowKey,~Value,~Array<Array<U32>>,~Resources<S>,~String,~take_resource(~S),~put_resource(~S),~same,~flow_declaration(~S)),F.write(~S,~LevelKey,~Value,~Array<Array<U32>>,~Resources<S>,~String,~take_level_resource(~S),~put_level_resource(~S),~same,~level_declaration(~S))},request,Tx.begin(~W.World<S,Array<Array<U32>>,Resources<S>,String>,~String,world)))
type Owners<S:Data> is Type: Owners{registry:Sys.Registry<S,Array<Array<U32>>,Resources<S>,String,Request,String,Unit,runner(~S)>,flow:M.Snapshot<Value>,level:M.Snapshot<Value>,owned:Array<U32>,status:String}
type Application<S:Data> is Type: Application{owners:Owners<S>,world:W.World<S,Array<Array<U32>>,Resources<S>,String>}
def barrier_result(~S:Data,pair:W.World<S,Array<Array<U32>>,Resources<S>,String> & U32) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  (world,_)=pair
  world
def barrier(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:barrier_result(~S,W.advance_clock(~S,~Array<Array<U32>>,~Resources<S>,~String,world))
def seed(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,_,_,registrations,nextSystem,_}:W.World{ns,next,high,live,capacity,depth,store,resource,["seed"],[barrier(~S)],registrations,nextSystem,17}
def registered(~S:Data,result:Sys.RegistrationResult<S,Array<Array<U32>>,Resources<S>,String,Request,String,Unit,runner(~S)>) -> Maybe<&1,Application<S>>:
  match result:
    case Sys.Registered{world,registry}:Some{Application{Owners{registry,M.Unscheduled{},M.Unscheduled{},ANode{ALeaf{43},ALeaf{59}},"ok"},world}}
    case Sys.RegistrationFailed{_}:None{}
def created(~S:Data,result:W.Creation<S,Array<Array<U32>>,Resources<S>,String>) -> Maybe<&1,Application<S>>:
  match result:
    case W.Created{_,world}:registered(~S,Sys.register(~S,~Array<Array<U32>>,~Resources<S>,~String,~Request,~String,~Unit,~runner(~S),seed(~S,world),"phases",["Flow.next","Level.next"]))
    case W.CreateRejected{_,_}:None{}
def create(~S:Data) -> Maybe<&1,Application<S>>:
  created(~S,W.create(~S,~Array<Array<U32>>,~Resources<S>,~String,~(u => ANode{ALeaf{ANode{ALeaf{13},ALeaf{29}}},ALeaf{ALeaf{47}}}),W.factory(),Resources{ANode{ALeaf{31},ALeaf{37}},M.Present{Value{Boot{},10},M.Queued{Value{Play{},20},False{}},Some{Value{Pause{},90}},False{}},M.Present{Value{Boot{},90},M.Queued{Value{Pause{},30},False{}},Some{Value{Play{},70}},False{}}}))
def outcome(~S:Data,registry:Sys.Registry<S,Array<Array<U32>>,Resources<S>,String,Request,String,Unit,runner(~S)>,flow:M.Snapshot<Value>,level:M.Snapshot<Value>,owned:Array<U32>,result:Sys.Outcome<W.World<S,Array<Array<U32>>,Resources<S>,String>,String,Unit>) -> Owners<S> & W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match result:
    case Sys.Succeeded{world,_}:(Owners{registry,flow,level,owned,"ok"},world)
    case Sys.Failed{world,error}:(Owners{registry,flow,level,owned,error},world)
def returned(~S:Data,flow:M.Snapshot<Value>,level:M.Snapshot<Value>,owned:Array<U32>,result:Sys.RunResult<S,Array<Array<U32>>,Resources<S>,String,Request,String,Unit,runner(~S)>) -> Owners<S> & W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match result:
    case Sys.Completed{registry,result}:outcome(~S,registry,flow,level,owned,result)
    case Sys.RegistrationRejected{registry,world,_}:(Owners{registry,flow,level,owned,"registration-rejected"},world)
def hook(~S:Data,request:Request,owners:Owners<S>,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> Owners<S> & W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match owners:
    case Owners{registry,flow,level,owned,_}:returned(~S,flow,level,owned,Sys.run_tracked(~S,~Array<Array<U32>>,~Resources<S>,~String,~Request,~String,~Unit,~runner(~S),registry,world,request))
def capture_slots(~S:Data,owned:Array<U32>,flow:M.Slot<S,FlowKey,Value> & M.Snapshot<Value>,level:M.Slot<S,LevelKey,Value> & M.Snapshot<Value>) -> Resources<S> & (M.Snapshot<Value> & M.Snapshot<Value>):
  match flow level:
    case (flow,capturedFlow),(level,capturedLevel):(Resources{owned,flow,level},(capturedFlow,capturedLevel))
def capture_resource(~S:Data,resources:Resources<S>) -> Resources<S> & (M.Snapshot<Value> & M.Snapshot<Value>):
  match resources:
    case Resources{owned,flow,level}:capture_slots(~S,owned,Coh.take_slot(~S,~FlowKey,~Value,flow),Coh.take_slot(~S,~LevelKey,~Value,level))
def captured(~S:Data,owners:Owners<S>,observed:W.World<S,Array<Array<U32>>,Resources<S>,String> & (M.Snapshot<Value> & M.Snapshot<Value>)) -> Owners<S> & W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match owners observed:
    case Owners{registry,_,_,owned,status},(world,(flow,level)):(Owners{registry,flow,level,owned,status},world)
def capture(~S:Data,owners:Owners<S>,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> Owners<S> & W.World<S,Array<Array<U32>>,Resources<S>,String>:
  captured(~S,owners,W.observe_resource(~S,~Array<Array<U32>>,~Resources<S>,~String,~(M.Snapshot<Value> & M.Snapshot<Value>),~capture_resource(~S),world))
def applied_world(~S:Data,~K:Data,~put:W.World<S,Array<Array<U32>>,Resources<S>,String> -> M.Slot<S,K,Value> -> W.World<S,Array<Array<U32>>,Resources<S>,String>,label:String,world:W.World<S,Array<Array<U32>>,Resources<S>,String>,applied:M.Applied<S,K,Value>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match applied:
    case M.Applied{slot,None{}}:put(world,slot)
    case M.Applied{slot,Some{M.Transition{from,to}}}:W.event_publish(~S,~Array<Array<U32>>,~Resources<S>,~String,put(world,slot),[label ++ ":" ++ show_value(from) ++ "->" ++ show_value(to)])
def apply_pair(~S:Data,~K:Data,~put:W.World<S,Array<Array<U32>>,Resources<S>,String> -> M.Slot<S,K,Value> -> W.World<S,Array<Array<U32>>,Resources<S>,String>,label:String,captured:M.Snapshot<Value>,observed:W.World<S,Array<Array<U32>>,Resources<S>,String> & M.Slot<S,K,Value>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  (world,slot)=observed
  applied_world(~S,~K,~put,label,world,Coh.apply(~S,~K,~Value,~same,slot,captured))
def apply_flow(~S:Data,owners:Owners<S>,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> Owners<S> & W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match owners:
    case Owners{registry,+flow,level,owned,status}:(Owners{registry,flow,level,owned,status},apply_pair(~S,~FlowKey,~put(~S),"applyFlow",flow,take(~S,world)))
def apply_level(~S:Data,owners:Owners<S>,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> Owners<S> & W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match owners:
    case Owners{registry,flow,+level,owned,status}:(Owners{registry,flow,level,owned,status},apply_pair(~S,~LevelKey,~put_level(~S),"applyLevel",level,take_level(~S,world)))
def marker(~S:Data) -> Ph.PhasedMarker<S,W.World<S,Array<Array<U32>>,Resources<S>,String>,Owners<S>>:
  Ph.PhasedMarker{M.OwnedMarker{[capture(~S),apply_flow(~S),apply_level(~S)]},M.OwnedMarker{[hook(~S,Request{"exitFlow",QueueLevel{M.Set{Value{Boot{},40},False{}}}}),hook(~S,Request{"exitLevel",Idle{}})]},M.OwnedMarker{[hook(~S,Request{"transitionFlow",QueueFlow{M.Set{Value{Pause{},50},False{}}}}),hook(~S,Request{"transitionLevel",Idle{}})]},M.OwnedMarker{[hook(~S,Request{"enterFlow",QueueLevel{M.Set{Value{Play{},60},False{}}}}),hook(~S,Request{"enterLevel",Idle{}})]}}
def application_returned(~S:Data,pair:Owners<S> & W.World<S,Array<Array<U32>>,Resources<S>,String>) -> Application<S>:
  (owners,world)=pair
  Application{owners,world}
def run_marker(~S:Data,app:Application<S>) -> Application<S>:
  match app:
    case Application{owners,world}:application_returned(~S,Ph.run(~S,~W.World<S,Array<Array<U32>>,Resources<S>,String>,~Owners<S>,~MW.structural_flush(~S,~Array<Array<U32>>,~Resources<S>,~String),marker(~S),owners,world))
def leaf(~T:Type,pair:T & String) -> Array<T> & String:
  (value,text)=pair
  (ALeaf{value},"L(" ++ text ++ ")")
def tree_right(~T:Type,a:Array<T>,text:String,pair:Array<T> & String) -> Array<T> & String:
  (b,other)=pair
  (ANode{a,b},"N(" ++ text ++ "," ++ other ++ ")")
def tree_left(~T:Type,b:Array<T> & String,pair:Array<T> & String) -> Array<T> & String:
  (a,text)=pair
  tree_right(~T,a,text,b)
def tree(~T:Type,~show:T -> T & String,value:Array<T>) -> Array<T> & String:
  match value:
    case ALeaf{value}:leaf(~T,show(value))
    case ANode{a,b}:tree_left(~T,tree(~T,~show,b),tree(~T,~show,a))
def number_value(+value:U32) -> U32 & String:(value,U32.show(value))
def number(value:U32) -> U32 & String:number_value(value)
def boolean_value(+value:Bool) -> Bool & String:(value,Bool.show(value))
def boolean(value:Bool) -> Bool & String:boolean_value(value)
def payload(value:Array<U32>) -> Array<U32> & String:tree(~U32,~number,value)
def previous(prior:Maybe<&2,Value>) -> String:
  match prior:
    case None{}:"none"
    case Some{prior}:show_value(prior)
def show_pending(pending:M.Pending<Value>) -> String:
  match pending:
    case M.NoPending{}:"none"
    case M.Queued{value,skip}:show_value(value) ++ ":skip=" ++ Bool.show(skip)
def show_slot(~S:Data,~K:Data,slot:M.Slot<S,K,Value>) -> String:
  match slot:
    case M.Missing{}:"missing"
    case M.Present{current,pending,prior,changed}:show_value(current) ++ "/" ++ show_pending(pending) ++ "/previous=" ++ previous(prior) ++ "/changed=" ++ Bool.show(changed)
def registration(meta:W.RegistrationMeta) -> String:
  match meta:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,s => s,access)
def commands_join(~S:Data,head:W.World<S,Array<Array<U32>>,Resources<S>,String> -> W.World<S,Array<Array<U32>>,Resources<S>,String>,pair:List<&1,(W.World<S,Array<Array<U32>>,Resources<S>,String> -> W.World<S,Array<Array<U32>>,Resources<S>,String>)> & Nat) -> List<&1,(W.World<S,Array<Array<U32>>,Resources<S>,String> -> W.World<S,Array<Array<U32>>,Resources<S>,String>)> & Nat:
  (tail,count)=pair
  (head <> tail,1n+count)
def commands(~S:Data,items:List<&1,(W.World<S,Array<Array<U32>>,Resources<S>,String> -> W.World<S,Array<Array<U32>>,Resources<S>,String>)>) -> List<&1,(W.World<S,Array<Array<U32>>,Resources<S>,String> -> W.World<S,Array<Array<U32>>,Resources<S>,String>)> & Nat:
  match items:
    case []:([],0n)
    case head <> rest:commands_join(~S,head,commands(~S,rest))
def world_view(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+slot:M.Slot<S,FlowKey,Value>,+level:M.Slot<S,LevelKey,Value>,+events:List<&2,String>,pending:List<&1,(W.World<S,Array<Array<U32>>,Resources<S>,String> -> W.World<S,Array<Array<U32>>,Resources<S>,String>)> & Nat,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,live:Array<Bool> & String,store:Array<Array<U32>> & String,owned:Array<U32> & String) -> W.World<S,Array<Array<U32>>,Resources<S>,String> & String:
  match pending live store owned:
    case (pending,count),(live,a),(store,b),(owned,c):(W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,level},events,pending,registrations,nextSystem,clock},"ns=" ++ U32.show(ns) ++ "/next=" ++ U32.show(next) ++ "/high=" ++ U32.show(high) ++ "/capacity=" ++ U32.show(capacity) ++ "/depth=" ++ Nat.show(depth) ++ "/live=" ++ a ++ "/components=" ++ b ++ "/resource=" ++ c ++ "/slot=" ++ show_slot(~S,~FlowKey,slot) ++ "/level=" ++ show_slot(~S,~LevelKey,level) ++ "/events=" ++ List.show(&2,String,s => s,events) ++ "/pending=" ++ Nat.show(count) ++ "/registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ "/nextSystem=" ++ U32.show(nextSystem) ++ "/clock=" ++ U32.show(clock))
def show_world(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> W.World<S,Array<Array<U32>>,Resources<S>,String> & String:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot,level},events,pending,registrations,nextSystem,clock}:world_view(~S,ns,next,high,capacity,depth,slot,level,events,commands(~S,pending),registrations,nextSystem,clock,tree(~Bool,~boolean,live),tree(~Array<U32>,~payload,store),tree(~U32,~number,owned))
def snapshot(value:M.Snapshot<Value>) -> String:
  match value:
    case M.Unscheduled{}:"none"
    case M.Scheduled{value,skip}:show_value(value) ++ ":skip=" ++ Bool.show(skip)
def owners_view(~S:Data,registry:Sys.Registry<S,Array<Array<U32>>,Resources<S>,String,Request,String,Unit,runner(~S)>,+flow:M.Snapshot<Value>,+level:M.Snapshot<Value>,+status:String,owned:Array<U32> & String,pair:W.World<S,Array<Array<U32>>,Resources<S>,String> & String) -> Application<S> & String:
  match registry owned pair:
    case Sys.Registry{+ns,+id,+name,+access,+cursor},(owned,a),(world,text):(Application{Owners{Sys.Registry{ns,id,name,access,cursor},flow,level,owned,status},world},text ++ "/registry=" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,s => s,access) ++ ":cursor=" ++ U32.show(cursor) ++ "/cohort=" ++ snapshot(flow) ++ "," ++ snapshot(level) ++ "/owners=" ++ a ++ "/status=" ++ status)
def observed(~S:Data,owners:Owners<S>,pair:W.World<S,Array<Array<U32>>,Resources<S>,String> & String) -> Application<S> & String:
  match owners:
    case Owners{registry,flow,level,owned,status}:owners_view(~S,registry,flow,level,status,tree(~U32,~number,owned),pair)
def observe(~S:Data,app:Application<S>) -> Application<S> & String:
  match app:
    case Application{owners,world}:observed(~S,owners,show_world(~S,world))
def checkpoint_join(~S:Data,label:String,prior:String,pair:Application<S> & String) -> Application<S> & String:
  (app,text)=pair
  (app,prior ++ label ++ ":" ++ text ++ "\n")
def checkpoint(~S:Data,app:Application<S>,label:String,prior:String) -> Application<S> & String:checkpoint_join(~S,label,prior,observe(~S,app))
def final(~S:Data,pair:Application<S> & String) -> String:
  (_,text)=pair
  text
def second(~S:Data,pair:Application<S> & String) -> String:
  (app,prior)=pair
  final(~S,checkpoint(~S,run_marker(~S,app),"marker2",prior))
def first(~S:Data,pair:Application<S> & String) -> String:
  (app,prior)=pair
  second(~S,checkpoint(~S,run_marker(~S,app),"marker1",prior))
def main_trace(~S:Data,app:Maybe<&1,Application<S>>) -> String:
  match app:
    case None{}:"creation-refused"
    case Some{app}:first(~S,checkpoint(~S,app,"initial",""))
