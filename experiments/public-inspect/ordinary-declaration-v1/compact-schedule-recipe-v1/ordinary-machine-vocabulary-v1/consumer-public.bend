import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-machine.bend as Machine
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as OD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

type Token is Data:
  Token{}
type Resource<S:Data> is Type:
  Resource{slot:M.Slot<S,Token,U32>,sibling:Array<U32>}
def take(~S:Data,resource:Resource<S>) -> Resource<S> & M.Slot<S,Token,U32>:
  match resource:
    case Resource{+slot,sibling}:(Resource{slot,sibling},slot)
def put(~S:Data,resource:Resource<S>,slot:M.Slot<S,Token,U32>) -> Resource<S>:
  match resource:
    case Resource{_,sibling}:Resource{slot,sibling}
def declaration(~S:Data) -> OD.Declaration<S,Token,U32,Resource<S>,take(~S)>:
  OD.declared(~S,~Token,~U32,~Resource<S>,~take(~S),"Flow",[7,8,42,6])
def World(~S:Data) -> Type:
  W.World<S,Unit,Resource<S>,U32>
def rows(~S:Data) -> Data:
  Machine.ObservedRows(~S,~Token,~U32,~Unit)
def observe(~S:Data) -> World(~S) -> World(~S) & DTO.Observation<rows(~S)>:
  Machine.observation(~S,~Token,~U32,~Unit,~Resource<S>,~U32,~take(~S),~put(~S),~U32.is_eq,~declaration(~S),~U32.show,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S))
def Application(~S:Data) -> Type:
  Machine.Application(~S,~Token,~U32,~Unit,~Resource<S>,~U32,~take(~S),~put(~S),~U32.is_eq,~declaration(~S),~U32.show,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S))
def pending_text(value:M.Pending<U32>) -> String:
  match value:
    case M.NoPending{}:"NoPending"
    case M.Queued{value,skip}:"Queued:" ++ U32.show(value) ++ ":" ++ Bool.show(skip)
def previous_text(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some:" ++ U32.show(value)
def slot_text(~S:Data,value:M.Slot<S,Token,U32>) -> String:
  match value:
    case M.Missing{}:"Missing"
    case M.Present{value,pending,previous,changed}:"Present:" ++ U32.show(value) ++ ":" ++ pending_text(pending) ++ ":" ++ previous_text(previous) ++ ":" ++ Bool.show(changed)
def array_right(left:Array<U32> & String,right:Array<U32> & String) -> Array<U32> & String:
  match left right:
    case (left,l), (right,r):(ANode{left,right},"node(" ++ l ++ "," ++ r ++ ")")
def array_u32(value:Array<U32>) -> Array<U32> & String:
  match value:
    case ALeaf{+value}:(ALeaf{value},"leaf:" ++ U32.show(value))
    case ANode{left,right}:array_right(array_u32(left),array_u32(right))
def bool_right(left:Array<Bool> & String,right:Array<Bool> & String) -> Array<Bool> & String:
  match left right:
    case (left,l), (right,r):(ANode{left,right},"node(" ++ l ++ "," ++ r ++ ")")
def array_bool(value:Array<Bool>) -> Array<Bool> & String:
  match value:
    case ALeaf{+value}:(ALeaf{value},"leaf:" ++ Bool.show(value))
    case ANode{left,right}:bool_right(array_bool(left),array_bool(right))
def pending_counted(~S:Data,first:World(~S) -> World(~S),rest:List<(World(~S) -> World(~S))> & U32) -> List<(World(~S) -> World(~S))> & U32:
  match rest:
    case (rest,count):(first <> rest,U32.add(count,1))
def pending_count(~S:Data,commands:List<(World(~S) -> World(~S))>) -> List<(World(~S) -> World(~S))> & U32:
  match commands:
    case []:([],0)
    case first <> rest:pending_counted(~S,first,pending_count(~S,rest))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access)
def physical_observed(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,store:Unit,+slot:M.Slot<S,Token,U32>,+events:List<&2,U32>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,live:Array<Bool> & String,sibling:Array<U32> & String,pending:List<(World(~S) -> World(~S))> & U32) -> World(~S) & String:
  match live sibling pending:
    case (live,liveText), (sibling,siblingText), (pending,count):(W.World{namespace,nextId,highWater,live,capacity,depth,store,Resource{slot,sibling},events,pending,registrations,nextSystemId,clock},"world{" ++ U32.show(namespace) ++ "|" ++ U32.show(nextId) ++ "|" ++ U32.show(highWater) ++ "|" ++ liveText ++ "|" ++ U32.show(capacity) ++ "|" ++ Nat.show(depth) ++ "|Unit|" ++ slot_text(~S,slot) ++ "|" ++ siblingText ++ "|" ++ List.show(&2,U32,U32.show,events) ++ "|pending=" ++ U32.show(count) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ "|nextSystem=" ++ U32.show(nextSystemId) ++ "|clock=" ++ U32.show(clock) ++ "}")
def physical(~S:Data,world:World(~S)) -> World(~S) & String:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,Resource{+slot,sibling},+events,pending,+registrations,nextSystemId,clock}:physical_observed(~S,namespace,nextId,highWater,capacity,depth,store,slot,events,registrations,nextSystemId,clock,array_bool(live),array_u32(sibling),pending_count(~S,pending))
def completed(~S:Data,text:String,owners:Unit,recipe:Machine.Recipe(~S,~Token,~U32,~Unit,~Resource<S>,~U32,~take(~S),~put(~S),~U32.is_eq,~declaration(~S),~U32.show,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S)),debug:Bool,result:World(~S) & String) -> Application(~S) & String:
  match result:
    case (world,body):(Build.Registered{world,owners,recipe,debug},text ++ "|owners=Unit|" ++ body)
def complete(~S:Data,text:String,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Build.Registered{world,owners,recipe,debug}:completed(~S,text,owners,recipe,debug,physical(~S,world))
def view(~S:Data,value:Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<rows(~S)>>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{DTO.Product{bindings,DTO.Observation{_,text}}}:"Debug{bindings=" ++ Nat.show(List.length(&2,DTO.Binding<S>,bindings)) ++ "|machines=" ++ List.show(&2,String,x=>x,text) ++ "}"
def shown(~S:Data,result:Application(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<rows(~S)>>>) -> Application(~S) & String:
  match result:
    case (app,value):complete(~S,view(~S,value),app)
def snapshot(~S:Data,flag:Bool,app:Application(~S)) -> Application(~S) & String:
  shown(~S,Machine.snapshot_app(~S,~Token,~U32,~Unit,~Resource<S>,~U32,~take(~S),~put(~S),~U32.is_eq,~declaration(~S),~U32.show,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),app,flag))
def selected_outcome(fail:Bool) -> T.Outcome<Unit>:
  match fail:
    case True{}:T.Failure{Unit{}}
    case False{}:T.Success{}
def outcome(value:T.Outcome<Unit>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{_}:"Failure:Unit"
def operated(~S:Data,owners:Unit,recipe:Machine.Recipe(~S,~Token,~U32,~Unit,~Resource<S>,~U32,~take(~S),~put(~S),~U32.is_eq,~declaration(~S),~U32.show,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S)),debug:Bool,result:T.Returned<World(~S),Unit>) -> Application(~S) & String:
  match result:
    case T.Returned{world,status}:complete(~S,outcome(status),Build.Registered{world,owners,recipe,debug})
def queued(~S:Data,result:Application(~S) & T.Outcome<Unit>) -> Application(~S) & String:
  match result:
    case (app,status):complete(~S,outcome(status),app)
def queue(~S:Data,~fail:Bool,value:U32,app:Application(~S)) -> Application(~S) & String:
  queued(~S,Machine.queue_app(~S,~Token,~U32,~Unit,~Resource<S>,~U32,~take(~S),~put(~S),~U32.is_eq,~declaration(~S),~U32.show,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),~Unit,app,M.Set{value,False{}},selected_outcome(fail)))
def read_shown(~S:Data,result:Application(~S) & M.CurrentView<S,Token,U32>) -> Application(~S) & String:
  match result:
    case (app,value):complete(~S,"Read:" ++ Machine.current_text(~S,~Token,~U32,~U32.show,value),app)
def read(~S:Data,app:Application(~S)) -> Application(~S) & String:
  read_shown(~S,Machine.read_app(~S,~Token,~U32,~Unit,~Resource<S>,~U32,~take(~S),~put(~S),~U32.is_eq,~declaration(~S),~U32.show,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),app))
def joined(~Value:Type,next:Value -> String -> String,result:Value & String) -> String:
  match result:
    case (value,text):next(value,text)
def sequence(~Value:Type,actions:List<(Value -> Value & String)>,prefix:String,value:Value) -> String:
  match actions:
    case []:prefix
    case first <> rest:joined(~Value,next=>text=>sequence(~Value,rest,prefix ++ text ++ "\n",next),first(value))
def attached(~S:Data,app:Application(~S)) -> String:
  sequence(~Application(~S),[snapshot(~S,False{}),read(~S),snapshot(~S,True{}),snapshot(~S,True{}),snapshot(~S,False{}),queue(~S,~False{},8),snapshot(~S,True{}),queue(~S,~True{},9),snapshot(~S,True{}),snapshot(~S,False{})],"",app)
def pending(~S:Data,world:World(~S)) -> World(~S):
  W.event_publish(~S,~Unit,~Resource<S>,~U32,world,[99])
def second_activated(~S:Data,result:World(~S) & W.Status) -> World(~S):
  match result:
    case (world,_):world
def second_reserved(~S:Data,result:World(~S) & W.Reservation<S>) -> World(~S):
  match result:
    case (world,W.Reserved{handle}):second_activated(~S,W.activate(~S,~Unit,~Resource<S>,~U32,world,handle))
    case (world,W.ReservationRejected{_}):world
def first_activated(~S:Data,result:World(~S) & W.Status) -> World(~S):
  match result:
    case (world,_):second_reserved(~S,W.reserve_id(~S,~Unit,~Resource<S>,~U32,world))
def first_reserved(~S:Data,result:World(~S) & W.Reservation<S>) -> World(~S):
  match result:
    case (world,W.Reserved{handle}):first_activated(~S,W.activate(~S,~Unit,~Resource<S>,~U32,world,handle))
    case (world,W.ReservationRejected{_}):world
def entities(~S:Data,count:Nat,world:World(~S)) -> World(~S):
  match count:
    case 0n:world
    case _:first_reserved(~S,W.reserve_id(~S,~Unit,~Resource<S>,~U32,world))
def created(~S:Data,count:Nat,result:W.Creation<S,Unit,Resource<S>,U32>) -> String:
  match result:
    case W.Created{_,world}:attached(~S,Machine.install(~S,~Token,~U32,~Unit,~Resource<S>,~U32,~take(~S),~put(~S),~U32.is_eq,~declaration(~S),~U32.show,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Leaf.empty(~S),Build.empty(~S,~World(~S),W.enqueue(~S,~Unit,~Resource<S>,~U32,W.event_publish(~S,~Unit,~Resource<S>,~U32,entities(~S,count,world),[91,92]),pending(~S)))))
    case _:"CREATE_REJECTED"
def initial_slot(~S:Data,available:Bool) -> M.Slot<S,Token,U32>:
  match available:
    case True{}:M.Present{7,M.NoPending{},Some{6},True{}}
    case False{}:M.Missing{}
def scenario(~S:Data,count:Nat,available:Bool) -> String:
  created(~S,count,W.create(~S,~Unit,~Resource<S>,~U32,unit=>unit,W.factory(),Resource{initial_slot(~S,available),Array.set(U32,Array.new(U32,1n,41),1,42)}))
