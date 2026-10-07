import Base
import fragment-left.bend as L
import fragment-right.bend as R
import ../../src/ecs/schema-fragments.bend as F
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C

# Schema-local heterogeneity is authored here, not imposed by the fragment library.
type Store<S: Data> is Type:
  Store{left: Col.Column<S,L.Payload>,right: Col.Column<S,R.Payload>}
type Context<S: Data> is Type:
  Context{world: W.World<S,Store<S>,U32,U32>,logger: R.Logger}
def project_left_last(value: Array<U32> & U32,first: U32) -> L.Payload & List<&2,U32>:
  (array,last) = value
  (L.Payload{array},[first,last])
def project_left_done(value: Array<U32> & U32) -> L.Payload & List<&2,U32>:
  (array,+first) = value
  project_left_last(Array.get(U32,array,1),first)
def project_left(value: L.Payload) -> L.Payload & List<&2,U32>:
  match value:
    case L.Payload{array}: project_left_done(Array.get(U32,array,0))
def project_right_last(value: Array<U32> & U32,first: U32) -> R.Payload & List<&2,U32>:
  (array,last) = value
  (R.Payload{array},[first,last])
def project_right_done(value: Array<U32> & U32) -> R.Payload & List<&2,U32>:
  (array,first) = value
  project_right_last(Array.get(U32,array,1),first)
def project_right(value: R.Payload) -> R.Payload & List<&2,U32>:
  match value:
    case R.Payload{array}: project_right_done(Array.get(U32,array,0))
def first_value(xs: List<&2,U32>) -> U32:
  match xs:
    case []: 0
    case x <> _: x
def access_value(access: C.Access<List<&2,U32>>) -> U32:
  match access:
    case C.Found{xs}: first_value(xs)
    case _: 0
def read_value(~S: Data,result: W.World<S,Store<S>,U32,U32> & C.Access<List<&2,U32>>) -> W.World<S,Store<S>,U32,U32> & U32:
  (world,access) = result
  (world,access_value(access))
def take_left(~S: Data,store: Store<S>) -> Col.Column<S,R.Payload> & Col.Column<S,L.Payload>:
  match store:
    case Store{left,right}: (right,left)
def put_left(~S: Data,rest: Col.Column<S,R.Payload>,column: Col.Column<S,L.Payload>) -> Store<S>:
  Store{column,rest}
def left_family(~S: Data) -> C.Family<S,Store<S>,Col.Column<S,R.Payload>,L.Payload,List<&2,U32>,L.Token,take_left(~S),put_left(~S),project_left>:
  C.Family{"Position"}
def left_replaced(~S: Data,result: C.Replacement<W.World<S,Store<S>,U32,U32>,L.Payload>) -> W.World<S,Store<S>,U32,U32>:
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world
def left_write(~S: Data,world: W.World<S,Store<S>,U32,U32>,handle: W.Handle<S>,incoming: L.Payload) -> W.World<S,Store<S>,U32,U32>:
  left_replaced(~S,C.structural_replace(~S,~Store<S>,~U32,~U32,~Col.Column<S,R.Payload>,~L.Payload,~List<&2,U32>,~L.Token,~take_left(~S),~put_left(~S),~project_left,left_family(~S),world,handle,Some{incoming}))
def left_set_named(~S: Data,named: W.World<S,Store<S>,U32,U32> & U32,value: U32) -> W.World<S,Store<S>,U32,U32>:
  (world,+ns) = named
  left_write(~S,world,W.Handle{ns,1},L.Payload{ANode{ALeaf{value},ALeaf{11}}})
def left_set(~S: Data,world: W.World<S,Store<S>,U32,U32>,value: U32) -> W.World<S,Store<S>,U32,U32>:
  left_set_named(~S,W.namespace(~S,~Store<S>,~U32,~U32,world),value)
def left_get_named(~S: Data,named: W.World<S,Store<S>,U32,U32> & U32) -> W.World<S,Store<S>,U32,U32> & C.Access<List<&2,U32>>:
  (world,+ns) = named
  C.get(~S,~Store<S>,~U32,~U32,~Col.Column<S,R.Payload>,~L.Payload,~List<&2,U32>,~L.Token,~take_left(~S),~put_left(~S),~project_left,left_family(~S),world,W.Handle{ns,1})
def left_get(~S: Data,world: W.World<S,Store<S>,U32,U32>) -> W.World<S,Store<S>,U32,U32> & C.Access<List<&2,U32>>:
  left_get_named(~S,W.namespace(~S,~Store<S>,~U32,~U32,world))
def left_read(~S: Data,world: W.World<S,Store<S>,U32,U32>) -> W.World<S,Store<S>,U32,U32> & U32:
  read_value(~S,left_get(~S,world))
def take_right(~S: Data,store: Store<S>) -> Col.Column<S,L.Payload> & Col.Column<S,R.Payload>:
  match store:
    case Store{left,right}: (left,right)
def put_right(~S: Data,rest: Col.Column<S,L.Payload>,column: Col.Column<S,R.Payload>) -> Store<S>:
  Store{rest,column}
def right_family(~S: Data) -> C.Family<S,Store<S>,Col.Column<S,L.Payload>,R.Payload,List<&2,U32>,R.Token,take_right(~S),put_right(~S),project_right>:
  C.Family{"Velocity"}
def right_replaced(~S: Data,result: C.Replacement<W.World<S,Store<S>,U32,U32>,R.Payload>) -> W.World<S,Store<S>,U32,U32>:
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world
def right_write(~S: Data,world: W.World<S,Store<S>,U32,U32>,handle: W.Handle<S>,incoming: R.Payload) -> W.World<S,Store<S>,U32,U32>:
  right_replaced(~S,C.structural_replace(~S,~Store<S>,~U32,~U32,~Col.Column<S,L.Payload>,~R.Payload,~List<&2,U32>,~R.Token,~take_right(~S),~put_right(~S),~project_right,right_family(~S),world,handle,Some{incoming}))
def right_set_named(~S: Data,named: W.World<S,Store<S>,U32,U32> & U32,value: U32) -> W.World<S,Store<S>,U32,U32>:
  (world,+ns) = named
  right_write(~S,world,W.Handle{ns,1},R.Payload{ANode{ALeaf{value},ALeaf{3}}})
def right_set(~S: Data,world: W.World<S,Store<S>,U32,U32>,value: U32) -> W.World<S,Store<S>,U32,U32>:
  right_set_named(~S,W.namespace(~S,~Store<S>,~U32,~U32,world),value)
def right_get_named(~S: Data,named: W.World<S,Store<S>,U32,U32> & U32) -> W.World<S,Store<S>,U32,U32> & C.Access<List<&2,U32>>:
  (world,+ns) = named
  C.get(~S,~Store<S>,~U32,~U32,~Col.Column<S,L.Payload>,~R.Payload,~List<&2,U32>,~R.Token,~take_right(~S),~put_right(~S),~project_right,right_family(~S),world,W.Handle{ns,1})
def right_get(~S: Data,world: W.World<S,Store<S>,U32,U32>) -> W.World<S,Store<S>,U32,U32> & C.Access<List<&2,U32>>:
  right_get_named(~S,W.namespace(~S,~Store<S>,~U32,~U32,world))
def right_read(~S: Data,world: W.World<S,Store<S>,U32,U32>) -> W.World<S,Store<S>,U32,U32> & U32:
  read_value(~S,right_get(~S,world))
def score_replaced(~S: Data,replaced: W.World<S,Store<S>,U32,U32> & U32) -> W.World<S,Store<S>,U32,U32>:
  (world,_) = replaced
  world
def score_set(~S: Data,world: W.World<S,Store<S>,U32,U32>,value: U32) -> W.World<S,Store<S>,U32,U32>:
  score_replaced(~S,W.replace_resource(~S,~Store<S>,~U32,~U32,world,value))
def context_read(~S: Data,result: W.World<S,Store<S>,U32,U32> & U32,logger: R.Logger) -> Context<S> & U32:
  (world,value) = result
  (Context{world,logger},value)
def context_left_read(~S: Data,ctx: Context<S>) -> Context<S> & U32:
  match ctx:
    case Context{world,logger}: context_read(~S,left_read(~S,world),logger)
def context_right_read(~S: Data,ctx: Context<S>) -> Context<S> & U32:
  match ctx:
    case Context{world,logger}: context_read(~S,right_read(~S,world),logger)
def context_left_set(~S: Data,ctx: Context<S>,value: U32) -> Context<S>:
  match ctx:
    case Context{world,logger}: Context{left_set(~S,world,value),logger}
def context_right_set(~S: Data,ctx: Context<S>,value: U32) -> Context<S>:
  match ctx:
    case Context{world,logger}: Context{right_set(~S,world,value),logger}
def context_log(~S: Data,ctx: Context<S>) -> Context<S>:
  match ctx:
    case Context{world,logger}: Context{world,R.log(logger)}
def gameplay_right(~H: Type,~left: Cap.ValueWrite<H,U32,U32>,~right: Cap.ValueWrite<H,U32,U32>,~logger: Cap.Action<H>,read: H & U32,a: U32) -> H:
  (ctx,+b) = read
  Cap.action(~H,~logger,Cap.value_set(~H,~U32,~U32,~right,Cap.value_set(~H,~U32,~U32,~left,ctx,(a + b : U32)),(b + 1 : U32)))
def gameplay_left(~H: Type,~left: Cap.ValueWrite<H,U32,U32>,~right: Cap.ValueWrite<H,U32,U32>,~logger: Cap.Action<H>,read: H & U32) -> H:
  (ctx,a) = read
  gameplay_right(~H,~left,~right,~logger,Cap.value_get(~H,~U32,~U32,~right,ctx),a)
def gameplay(~H: Type,~left: Cap.ValueWrite<H,U32,U32>,~right: Cap.ValueWrite<H,U32,U32>,~logger: Cap.Action<H>,ctx: H) -> H:
  gameplay_left(~H,~left,~right,~logger,Cap.value_get(~H,~U32,~U32,~left,ctx))
def runner_done(~S: Data,ctx: Context<S>) -> Sys.Outcome<W.World<S,Store<S>,U32,U32>,String,R.Logger>:
  match ctx:
    case Context{world,logger}: Sys.Succeeded{W.enqueue(~S,~Store<S>,~U32,~U32,W.event_publish(~S,~Store<S>,~U32,~U32,score_set(~S,world,1),[9]),w => left_set(~S,w,13)),logger}
def runner(~S: Data,world: W.World<S,Store<S>,U32,U32>,logger: R.Logger) -> Sys.Outcome<W.World<S,Store<S>,U32,U32>,String,R.Logger>:
  runner_done(~S,gameplay(~Context<S>,~Cap.ValueWrite{context_left_read(~S),context_left_set(~S)},~Cap.ValueWrite{context_right_read(~S),context_right_set(~S)},~Cap.Action{context_log(~S)},Context{world,logger}))
def numbers(xs: List<&2,U32>) -> String:
  match xs:
    case []: ""
    case x <> rest: U32.show(x) ++ "," ++ numbers(rest)
def view_text(views: List<&2,U32> & List<&2,U32>) -> String:
  (a,b) = views
  numbers(a) ++ ":" ++ numbers(b)
def access_text(access: C.Access<List<&2,U32>>) -> String:
  match access:
    case C.Found{xs}: numbers(xs)
    case C.MissingEntity{}: "missing"
    case C.ComponentAbsent{}: "absent"
def show_resource(~S: Data,world: W.World<S,Store<S>,U32,U32>,a: String,b: String) -> String:
  match world:
    case W.World{_,_,_,_,_,_,_,score,events,pending,_,_,_}: a ++ ":" ++ b ++ ":" ++ U32.show(score) ++ ":" ++ numbers(events) ++ ":" ++ U32.show(U32.from_nat(List.length(&1,W.World<S,Store<S>,U32,U32> -> W.World<S,Store<S>,U32,U32>,pending)))
def show_right(~S: Data,result: W.World<S,Store<S>,U32,U32> & C.Access<List<&2,U32>>,a: String) -> String:
  (world,access) = result
  show_resource(~S,world,a,access_text(access))
def show_left(~S: Data,result: W.World<S,Store<S>,U32,U32> & C.Access<List<&2,U32>>) -> String:
  (world,access) = result
  show_right(~S,right_get(~S,world),access_text(access))
def observe(~S: Data,world: W.World<S,Store<S>,U32,U32>) -> String:
  show_left(~S,left_get(~S,world))
def log_last(read: Array<U32> & U32,calls: U32) -> String:
  (_,tail) = read
  U32.show(calls) ++ "," ++ U32.show(tail)
def log_first(read: Array<U32> & U32) -> String:
  (array,calls) = read
  log_last(Array.get(U32,array,1),calls)
def log_show(logger: R.Logger) -> String:
  match logger:
    case R.Logger{array}: log_first(Array.get(U32,array,0))
def snapshot_resource(~S: Data,world: W.World<S,Store<S>,U32,U32>,a: String,b: String) -> W.World<S,Store<S>,U32,U32> & String:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,+score,+events,pending,registrations,system,clock}: (W.World{ns,next,high,live,cap,depth,store,score,events,pending,registrations,system,clock},a ++ ":" ++ b ++ ":" ++ U32.show(score) ++ ":" ++ numbers(events) )
def snapshot_right(~S: Data,result: W.World<S,Store<S>,U32,U32> & C.Access<List<&2,U32>>,a: String) -> W.World<S,Store<S>,U32,U32> & String:
  (world,access) = result
  snapshot_resource(~S,world,a,access_text(access))
def snapshot_left(~S: Data,result: W.World<S,Store<S>,U32,U32> & C.Access<List<&2,U32>>) -> W.World<S,Store<S>,U32,U32> & String:
  (world,access) = result
  snapshot_right(~S,right_get(~S,world),access_text(access))
def snapshot_logger_last(read: Array<U32> & U32,+calls: U32) -> R.Logger & String:
  (array,+tail) = read
  (R.Logger{array},U32.show(calls) ++ "," ++ U32.show(tail))
def snapshot_logger_first(read: Array<U32> & U32) -> R.Logger & String:
  (array,calls) = read
  snapshot_logger_last(Array.get(U32,array,1),calls)
def snapshot_logger(logger: R.Logger) -> R.Logger & String:
  match logger:
    case R.Logger{array}: snapshot_logger_first(Array.get(U32,array,0))
def before_counted(~S: Data,counted: W.World<S,Store<S>,U32,U32> & U32,before: String,logger: R.Logger,log: String) -> String:
  (world,count) = counted
  before ++ ":" ++ U32.show(count) ++ ":log=" ++ log ++ "|" ++ observe(~S,W.barrier(~S,~Store<S>,~U32,~U32,world)) ++ ":log=" ++ log_show(logger)
def before_barrier(~S: Data,view: W.World<S,Store<S>,U32,U32> & String,logged: R.Logger & String) -> String:
  (world,before) = view
  (logger,log) = logged
  before_counted(~S,W.pending_count(~S,~Store<S>,~U32,~U32,world),before,logger,log)
def executed(~S: Data,result: Sys.RunResult<S,Store<S>,U32,U32,R.Logger,String,R.Logger,runner(~S)>) -> String:
  match result:
    case Sys.Completed{_,Sys.Succeeded{world,logger}}: before_barrier(~S,snapshot_left(~S,left_get(~S,world)),snapshot_logger(logger))
    case _: "system-failed"
def registered(~S: Data,logger: R.Logger,result: Sys.RegistrationResult<S,Store<S>,U32,U32,R.Logger,String,R.Logger,runner(~S)>) -> String:
  match result:
    case Sys.Registered{world,registry}: executed(~S,Sys.run(~S,~Store<S>,~U32,~U32,~R.Logger,~String,~R.Logger,~runner(~S),registry,world,logger))
    case _: "registration-failed"
def empty_store(~S: Data,_: Unit) -> Store<S>:
  Store{Col.empty(~S,~L.Payload),Col.empty(~S,~R.Payload)}
def populated_values(~S: Data,logger: R.Logger,left: L.Payload,right: R.Payload,world: W.World<S,Store<S>,U32,U32>,+handle: W.Handle<S>) -> String:
  registered(~S,logger,Sys.register(~S,~Store<S>,~U32,~U32,~R.Logger,~String,~R.Logger,~runner(~S),right_write(~S,left_write(~S,world,handle,left),handle,right),"compose",["Position.write","Velocity.write","Score.write","Tick.write"]))
def populated(~S: Data,world: W.World<S,Store<S>,U32,U32>,+handle: W.Handle<S>,owners: L.Payload & R.Owners) -> String:
  match owners:
    case (left,R.Owners{right,logger}): populated_values(~S,logger,left,right,world,handle)
def activated(~S: Data,result: W.World<S,Store<S>,U32,U32> & W.Status,+handle: W.Handle<S>,owners: L.Payload & R.Owners) -> String:
  (world,_) = result
  populated(~S,world,handle,owners)
def reserved(~S: Data,result: W.World<S,Store<S>,U32,U32> & W.Reservation<S>,owners: L.Payload & R.Owners) -> String:
  match result:
    case (world,W.Reserved{+handle}): activated(~S,W.activate(~S,~Store<S>,~U32,~U32,world,handle),handle,owners)
    case _: "reserve-failed"
def created(~S: Data,result: W.Creation<S,Store<S>,U32,U32>,owners: L.Payload & R.Owners) -> String:
  match result:
    case W.Created{_,world}: reserved(~S,W.reserve_id(~S,~Store<S>,~U32,~U32,world),owners)
    case _: "create-failed"
def build(~S: Data,owners: L.Payload & R.Owners) -> String:
  created(~S,W.create(~S,~Store<S>,~U32,~U32,~empty_store(~S),W.factory(),0),owners)
def rejected_projected(left: L.Payload & List<&2,U32>,right: R.Payload & List<&2,U32>,logger: R.Logger) -> String:
  (_,a) = left
  (_,b) = right
  "rejected:" ++ numbers(a) ++ ":" ++ numbers(b) ++ ":log=" ++ log_show(logger)
def rejected_values(left: L.Payload,owners: R.Owners) -> String:
  match owners:
    case R.Owners{right,logger}: rejected_projected(project_left(left),project_right(right),logger)
def rejected_owners(owners: L.Payload & R.Owners) -> String:
  (left,right) = owners
  rejected_values(left,right)
def bound(~S: Data,result: F.Bound<S,L.Payload & R.Owners,String>) -> String:
  match result:
    case F.Built{output}: output
    case F.BindRejected{_,F.Fragment{_,owners}}: rejected_owners(owners)
def merged(~S: Data,result: F.Merge<S,L.Payload,R.Owners>) -> String:
  match result:
    case F.Merged{fragment}: bound(~S,F.bind_declared(~S,~L.Payload & R.Owners,~String,~build(~S),fragment,[F.Entry{F.Component{},"Position","Position"},F.Entry{F.Component{},"Velocity","Velocity"},F.Entry{F.Resource{},"Score","Score"},F.Entry{F.Event{},"Tick","Tick"},F.Entry{F.Service{},"Logger","Logger"}]))
    case F.Rejected{_,F.Fragment{_,left},F.Fragment{_,right}}: rejected_values(left,right)
def run(~S: Data) -> String:
  merged(~S,F.merge(~S,~L.Payload,~R.Owners,L.fragment(~S),R.supplied(~S)))
def collision_right(~S: Data,fragment: F.Fragment<S,R.Owners>) -> F.Fragment<S,R.Owners>:
  match fragment:
    case F.Fragment{entries,owners}: F.fragment(~S,~R.Owners,F.Entry{F.Component{},"other","Position"} <> entries,owners)
def invalid(~S: Data) -> String:
  merged(~S,F.merge(~S,~L.Payload,~R.Owners,L.fragment(~S),collision_right(~S,R.supplied(~S))))
def undeclared_right(~S: Data,fragment: F.Fragment<S,R.Owners>) -> F.Fragment<S,R.Owners>:
  match fragment:
    case F.Fragment{_,owners}: F.fragment(~S,~R.Owners,[F.Entry{F.Component{},"Velocity","Velocity"}],owners)
def undeclared(~S: Data) -> String:
  merged(~S,F.merge(~S,~L.Payload,~R.Owners,L.fragment(~S),undeclared_right(~S,R.supplied(~S))))
