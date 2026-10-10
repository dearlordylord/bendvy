import Base
import queue.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-world.bend as MW
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

type SchemaA is Data: SchemaA{}
type SchemaB is Data: SchemaB{}
type FlowKey is Data: FlowKey{}
type Tag is Data: Boot{} Play{} Pause{}
type Value is Data: Value{tag:Tag,representation:U32}
type Resources<S:Data> is Type: Resources{owned:Array<U32>,slot:M.Slot<S,FlowKey,Value>}
type Request is Data: Request{input:M.QueueInput<Value>,fail:Bool}
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
    case Resources{owned,+slot}:(Resources{owned,slot},slot)
def put_resource(~S:Data,resources:Resources<S>,slot:M.Slot<S,FlowKey,Value>) -> Resources<S>:
  match resources:
    case Resources{owned,_}:Resources{owned,slot}
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
def runner(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>,request:Request) -> Sys.Outcome<W.World<S,Array<Array<U32>>,Resources<S>,String>,String,Unit>:
  match request:
    case Request{input,fail}:finish(~S,Q.next_declared(~S,~FlowKey,~Value,~W.World<S,Array<Array<U32>>,Resources<S>,String>,~String,~take(~S),~put(~S),~same,family(~S),Tx.begin(~W.World<S,Array<Array<U32>>,Resources<S>,String>,~String,world),input),fail)
type Application<S:Data> is Type: Application{world:W.World<S,Array<Array<U32>>,Resources<S>,String>,registry:Maybe<&1,Sys.Registry<S,Array<Array<U32>>,Resources<S>,String,Request,String,Unit,runner(~S)>>,status:String}
def registered(~S:Data,result:Sys.RegistrationResult<S,Array<Array<U32>>,Resources<S>,String,Request,String,Unit,runner(~S)>) -> Application<S>:
  match result:
    case Sys.Registered{world,registry}:Application{world,Some{registry},"ok"}
    case Sys.RegistrationFailed{world}:Application{world,None{},"registration-refused"}
def barrier_result(~S:Data,pair:W.World<S,Array<Array<U32>>,Resources<S>,String> & U32) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  (world,_)=pair
  world
def barrier(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  barrier_result(~S,W.advance_clock(~S,~Array<Array<U32>>,~Resources<S>,~String,world))
def seed(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> W.World<S,Array<Array<U32>>,Resources<S>,String>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resource,_,_,registrations,nextSystem,_}:W.World{ns,next,high,live,capacity,depth,store,resource,["seed"],[barrier(~S)],registrations,nextSystem,17}
def created(~S:Data,result:W.Creation<S,Array<Array<U32>>,Resources<S>,String>) -> Maybe<&1,Application<S>>:
  match result:
    case W.Created{_,world}:Some{registered(~S,Sys.register(~S,~Array<Array<U32>>,~Resources<S>,~String,~Request,~String,~Unit,~runner(~S),seed(~S,world),"publisher",["Flow.next"]))}
    case W.CreateRejected{_,_}:None{}
def create(~S:Data) -> Maybe<&1,Application<S>>:
  created(~S,W.create(~S,~Array<Array<U32>>,~Resources<S>,~String,~(u => ANode{ALeaf{ANode{ALeaf{13},ALeaf{29}}},ALeaf{ALeaf{47}}}),W.factory(),Resources{ANode{ALeaf{31},ALeaf{37}},M.Present{Value{Boot{},10},M.NoPending{},Some{Value{Pause{},90}},True{}}}))
def outcome(~S:Data,registry:Sys.Registry<S,Array<Array<U32>>,Resources<S>,String,Request,String,Unit,runner(~S)>,result:Sys.Outcome<W.World<S,Array<Array<U32>>,Resources<S>,String>,String,Unit>) -> Application<S>:
  match result:
    case Sys.Succeeded{world,_}:Application{world,Some{registry},"ok"}
    case Sys.Failed{world,error}:Application{world,Some{registry},error}
def returned(~S:Data,result:Sys.RunResult<S,Array<Array<U32>>,Resources<S>,String,Request,String,Unit,runner(~S)>) -> Application<S>:
  match result:
    case Sys.Completed{registry,result}:outcome(~S,registry,result)
    case Sys.RegistrationRejected{registry,world,_}:Application{world,Some{registry},"registration-rejected"}
def operate(~S:Data,app:Application<S>,request:Request) -> Application<S>:
  match app:
    case Application{world,None{},status}:Application{world,None{},status}
    case Application{world,Some{registry},_}:returned(~S,Sys.run_tracked(~S,~Array<Array<U32>>,~Resources<S>,~String,~Request,~String,~Unit,~runner(~S),registry,world,request))
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
def tag(tag:Tag) -> String:
  match tag:
    case Boot{}:"Boot"
    case Play{}:"Play"
    case Pause{}:"Pause"
def show_value(value:Value) -> String:
  match value:
    case Value{kind,representation}:tag(kind) ++ ":" ++ U32.show(representation)
def previous(prior:Maybe<&2,Value>) -> String:
  match prior:
    case None{}:"none"
    case Some{prior}:show_value(prior)
def show_pending(pending:M.Pending<Value>) -> String:
  match pending:
    case M.NoPending{}:"none"
    case M.Queued{value,skip}:show_value(value) ++ ":skip=" ++ Bool.show(skip)
def show_slot(~S:Data,slot:M.Slot<S,FlowKey,Value>) -> String:
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
def world_view(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+slot:M.Slot<S,FlowKey,Value>,+events:List<&2,String>,pending:List<&1,(W.World<S,Array<Array<U32>>,Resources<S>,String> -> W.World<S,Array<Array<U32>>,Resources<S>,String>)> & Nat,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,live:Array<Bool> & String,store:Array<Array<U32>> & String,owned:Array<U32> & String) -> W.World<S,Array<Array<U32>>,Resources<S>,String> & String:
  match pending live store owned:
    case (pending,count),(live,a),(store,b),(owned,c):(W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot},events,pending,registrations,nextSystem,clock},"ns=" ++ U32.show(ns) ++ "/next=" ++ U32.show(next) ++ "/high=" ++ U32.show(high) ++ "/capacity=" ++ U32.show(capacity) ++ "/depth=" ++ Nat.show(depth) ++ "/live=" ++ a ++ "/components=" ++ b ++ "/resource=" ++ c ++ "/slot=" ++ show_slot(~S,slot) ++ "/events=" ++ List.show(&2,String,s => s,events) ++ "/pending=" ++ Nat.show(count) ++ "/registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ "/nextSystem=" ++ U32.show(nextSystem) ++ "/clock=" ++ U32.show(clock))
def show_world(~S:Data,world:W.World<S,Array<Array<U32>>,Resources<S>,String>) -> W.World<S,Array<Array<U32>>,Resources<S>,String> & String:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,slot},events,pending,registrations,nextSystem,clock}:world_view(~S,ns,next,high,capacity,depth,slot,events,commands(~S,pending),registrations,nextSystem,clock,tree(~Bool,~boolean,live),tree(~Array<U32>,~payload,store),tree(~U32,~number,owned))
def observed(~S:Data,+status:String,pair:W.World<S,Array<Array<U32>>,Resources<S>,String> & String,registry:Maybe<&1,Sys.Registry<S,Array<Array<U32>>,Resources<S>,String,Request,String,Unit,runner(~S)>>) -> Application<S> & String:
  match pair registry:
    case (world,text),None{}:(Application{world,None{},status},text ++ "/registry=none/status=" ++ status)
    case (world,text),Some{Sys.Registry{+ns,+id,+name,+access,+cursor}}:(Application{world,Some{Sys.Registry{ns,id,name,access,cursor}},status},text ++ "/registry=" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,s => s,access) ++ ":cursor=" ++ U32.show(cursor) ++ "/status=" ++ status)
def observe(~S:Data,app:Application<S>) -> Application<S> & String:
  match app:
    case Application{world,registry,status}:observed(~S,status,show_world(~S,world),registry)
def capture(~S:Data,label:String,prior:String,pair:Application<S> & String) -> Application<S> & String:
  (app,text)=pair
  (app,prior ++ label ++ ":" ++ text ++ "\n")
def checkpoint(~S:Data,app:Application<S>,label:String,prior:String) -> Application<S> & String:capture(~S,label,prior,observe(~S,app))
def final(~S:Data,pair:Application<S> & String) -> String:
  (_,text)=pair
  text
def failed(~S:Data,pair:Application<S> & String) -> String:
  (app,prior)=pair
  final(~S,checkpoint(~S,operate(~S,app,Request{M.Set{Value{Pause{},30},True{}},True{}}),"rollback",prior))
def conditional_same(~S:Data,pair:Application<S> & String) -> String:
  (app,prior)=pair
  failed(~S,checkpoint(~S,operate(~S,app,Request{M.Set{Value{Play{},21},True{}},False{}}),"conditional-same",prior))
def forced(~S:Data,pair:Application<S> & String) -> String:
  (app,prior)=pair
  conditional_same(~S,checkpoint(~S,operate(~S,app,Request{M.Set{Value{Play{},20},False{}},False{}}),"forced",prior))
def minimal(~S:Data,app:Maybe<&1,Application<S>>) -> String:
  match app:
    case None{}:"construction-refused"
    case Some{app}:forced(~S,checkpoint(~S,app,"initial",""))

type Step is Data: Step{label:String,request:Maybe<&2,Request>}
def make_missing(~S:Data,app:Application<S>) -> Application<S>:
  match app:
    case Application{world,registry,status}:Application{put(~S,world,M.Missing{}),registry,status}
def action(~S:Data,app:Application<S>,request:Maybe<&2,Request>) -> Application<S>:
  match request:
    case None{}:make_missing(~S,app)
    case Some{request}:operate(~S,app,request)
def steps(~S:Data,remaining:List<&2,Step>,pair:Application<S> & String) -> String:
  match remaining pair:
    case [],(_,text):text
    case Step{label,request} <> rest,(app,prior):steps(~S,rest,checkpoint(~S,action(~S,app,request),label,prior))
def expanded(~S:Data,app:Maybe<&1,Application<S>>) -> String:
  match app:
    case None{}:"construction-refused"
    case Some{app}:steps(~S,[Step{"forced",Some{Request{M.Set{Value{Play{},20},False{}},False{}}}},Step{"conditional-equal",Some{Request{M.Set{Value{Play{},21},True{}},False{}}}},Step{"different",Some{Request{M.Set{Value{Pause{},30},True{}},False{}}}},Step{"reset",Some{Request{M.Reset{},False{}}}},Step{"conditional",Some{Request{M.Set{Value{Play{},21},True{}},False{}}}},Step{"forced-equal",Some{Request{M.Set{Value{Play{},20},False{}},False{}}}},Step{"rollback",Some{Request{M.Set{Value{Pause{},30},True{}},True{}}}},Step{"reset-again",Some{Request{M.Reset{},False{}}}},Step{"missing-fixture",None{}},Step{"missing-set",Some{Request{M.Set{Value{Play{},21},True{}},False{}}}},Step{"missing-reset",Some{Request{M.Reset{},False{}}}}],checkpoint(~S,app,"initial",""))
