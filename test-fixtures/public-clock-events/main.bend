import Base
import ../../src/ecs/ordinary-machine-declaration.bend as MachineDeclaration
import ../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../src/ecs/ordinary-machine-initialization-marker.bend as Marker
import ../../src/ecs/machine-stream.bend as Stream
import ../../src/ecs/machine.bend as Machine
import ../../src/ecs/world.bend as W
import ../../src/ecs/system.bend as Sys
import ../../src/ecs/event-runtime.bend as Ev
import ../../src/ecs/relation-failure-runtime.bend as Failure
import ../../src/ecs/internal/relation-failures/domains.bend as Domains
import ../../src/ecs/commands.bend as Cmd
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/change-tick.bend as Tick

type S is Data:S{}
def World() -> Type:W.World<S,Unit,Unit,U32>
def reading(values:List<&2,U32>,lagged:Bool) -> String:List.show(&2,U32,U32.show,values)++":lag="++Bool.show(lagged)
def decided(fail:Bool,world:World(),text:String) -> Sys.Outcome<World(),String,String>:
  match fail:
    case False{}:Sys.Succeeded{world,text}
    case True{}:Sys.Failed{world,text}
def runner(world:World(),input:Ev.Input<U32,Bool>) -> Sys.Outcome<World(),String,String>:
  match input:
    case Ev.Input{values,lagged,fail}:decided(fail,world,reading(values,lagged))
def Registry() -> Type:Sys.Registry<S,Unit,Unit,U32,Ev.Input<U32,Bool>,String,String,runner>
def Runtime() -> Type:Ev.Runtime<S,Unit,Unit,U32>
type State is Type:
  State{runtime:Runtime(),readerA:Ev.Reader<S>,registryA:Registry(),readerB:Ev.Reader<S>,registryB:Registry()}
type Action is Data:FailA{} RunA{} RunB{} Publish{} SkipA{}
def tick(t:Tick.Tick) -> String:
  match t:
    case Tick.Tick{epoch,low}:Nat.show(epoch)++":"++U32.show(low)
def cursor(c:Maybe<&2,Tick.Tick>) -> String:
  match c:
    case None{}:"none"
    case Some{t}:tick(t)
def position(p:Ev.Position) -> String:
  match p:
    case Ev.Position{id,cursor,registered}:U32.show(id)++":"++Nat.show(cursor)++":"++Nat.show(registered)
def describe(label:String,state:State) -> State & String:
  match state:
    case State{Ev.Runtime{W.World{ns,a,s,r,e,p,g,n,+clock,lifecycle},rn,batches,+positions,next,+eventTick,fs,b,cap,d},ra,Sys.Registry{an,ai,na,aa,+ca},rb,Sys.Registry{bn,bi,nb,ba,+cb}}:
      (State{Ev.Runtime{W.World{ns,a,s,r,e,p,g,n,clock,lifecycle},rn,batches,positions,next,eventTick,fs,b,cap,d},ra,Sys.Registry{an,ai,na,aa,ca},rb,Sys.Registry{bn,bi,nb,ba,cb}},label++":world="++tick(Clock.now(clock))++":event="++Nat.show(eventTick)++":A="++cursor(ca)++":B="++cursor(cb)++":positions="++List.show(&2,Ev.Position,position,positions))
def completion(c:Ev.Completion<String,String,Bool>) -> String:
  match c:
    case Ev.Succeeded{text}:"ok:"++text
    case Ev.Failed{text}:"fail:"++text
    case Ev.Rejected{arg}:"rejected:"++Bool.show(arg)
def a_done(rb:Ev.Reader<S>,gb:Registry(),result:Ev.RunResult<S,Unit,Unit,U32,Bool,String,String,runner>) -> State & String:
  match result:
    case Ev.Ran{runtime,ra,ga,c}:describe("A:"++completion(c),State{runtime,ra,ga,rb,gb})
def b_done(ra:Ev.Reader<S>,ga:Registry(),result:Ev.RunResult<S,Unit,Unit,U32,Bool,String,String,runner>) -> State & String:
  match result:
    case Ev.Ran{runtime,rb,gb,c}:describe("B:"++completion(c),State{runtime,ra,ga,rb,gb})
def published(world:World()) -> World() & Unit:(Cmd.publish(~S,~Unit,~Unit,~U32,world,[9]),Unit{})
def publish_done(ra:Ev.Reader<S>,ga:Registry(),rb:Ev.Reader<S>,gb:Registry(),result:Runtime() & Unit) -> State & String:
  match result:
    case (runtime,_):describe("publish9",State{runtime,ra,ga,rb,gb})
def skip_done(ga:Registry(),rb:Ev.Reader<S>,gb:Registry(),result:Runtime() & Ev.Reader<S>) -> State & String:
  match result:
    case (runtime,ra):describe("skipA",State{runtime,ra,ga,rb,gb})
def apply(action:Action,state:State) -> State & String:
  match action state:
    case FailA{},State{runtime,ra,ga,rb,gb}:a_done(rb,gb,Ev.run(~S,~Unit,~Unit,~U32,~Bool,~String,~String,~runner,runtime,ra,ga,True{}))
    case RunA{},State{runtime,ra,ga,rb,gb}:a_done(rb,gb,Ev.run(~S,~Unit,~Unit,~U32,~Bool,~String,~String,~runner,runtime,ra,ga,False{}))
    case RunB{},State{runtime,ra,ga,rb,gb}:b_done(ra,ga,Ev.run(~S,~Unit,~Unit,~U32,~Bool,~String,~String,~runner,runtime,rb,gb,False{}))
    case Publish{},State{runtime,ra,ga,rb,gb}:publish_done(ra,ga,rb,gb,Ev.with_world(~S,~Unit,~Unit,~U32,~Unit,published,runtime))
    case SkipA{},State{runtime,ra,ga,rb,gb}:skip_done(ga,rb,gb,Ev.skip(~S,~Unit,~Unit,~U32,runtime,ra))
def stepped(result:State & String,next:State -> String) -> String:
  match result:
    case (state,line):line++"\n"++next(state)
def steps(actions:List<&2,Action>,state:State) -> String:
  match actions:
    case []:"done"
    case action <> rest:stepped(apply(action,state),s => steps(rest,s))
def b_registered(ra:Ev.Reader<S>,ga:Registry(),result:Ev.Registered<S,Unit,Unit,U32,Bool,String,String,runner>) -> String:
  match result:
    case Ev.RegisterFailed{_}:"registerB-failed"
    case Ev.Registered{runtime,rb,gb}:steps([FailA{},RunA{},RunB{},Publish{},SkipA{},RunA{},RunB{}],State{runtime,ra,ga,rb,gb})
def a_registered(result:Ev.Registered<S,Unit,Unit,U32,Bool,String,String,runner>) -> String:
  match result:
    case Ev.RegisterFailed{_}:"registerA-failed"
    case Ev.Registered{runtime,ra,ga}:b_registered(ra,ga,Ev.register(~S,~Unit,~Unit,~U32,~Bool,~String,~String,~runner,runtime,"B",["event:read"]))
def initial(world:World()) -> World() & Unit:(Cmd.publish(~S,~Unit,~Unit,~U32,world,[7,8]),Unit{})
def initialized(result:Runtime() & Unit) -> String:
  match result:
    case (runtime,_):a_registered(Ev.register(~S,~Unit,~Unit,~U32,~Bool,~String,~String,~runner,runtime,"A",["event:read"]))
def created(result:W.Creation<S,Unit,Unit,U32>) -> String:
  match result:
    case W.CreateRejected{_,_}:"create-failed"
    case W.Created{_,world}:initialized(Ev.with_world(~S,~Unit,~Unit,~U32,~Unit,initial,Ev.start(~S,~Unit,~Unit,~U32,world,64n)))

# Trusted seed exercises the actual full-Tick -> Nat bridge across low-word zero.
# No relation messages/classifier semantics are inferred from this empty domain.
def seed(world:World()) -> World():
  match world:
    case W.World{ns,a,s,r,e,p,g,n,_,lifecycle}:W.World{ns,a,s,r,e,p,g,n,Clock.State{Tick.Tick{0n,4294967295},[]},lifecycle}
def classify(_:U32) -> Maybe<Domains.DescriptorKey<S>>:None{}
def identity(world:World()) -> World() & Unit:(world,Unit{})
def bridge_view(runtime:Failure.Runtime<S,Unit,Unit,U32>) -> Failure.Runtime<S,Unit,Unit,U32> & String:
  match runtime:
    case Failure.Runtime{W.World{ns,a,s,r,e,p,g,n,+clock,lifecycle},domains,positions,+t,fs,b,cap,nr}:(Failure.Runtime{W.World{ns,a,s,r,e,p,g,n,clock,lifecycle},domains,positions,t,fs,b,cap,nr},"bridge:world="++tick(Clock.now(clock))++":event="++Nat.show(t))
def bridge_end(prefix:String,result:Failure.Runtime<S,Unit,Unit,U32> & String) -> String:
  match result:
    case (_,line):prefix++"\n"++line
def bridge_second(prefix:String,result:Failure.Runtime<S,Unit,Unit,U32> & Unit) -> String:
  match result:
    case (runtime,_):bridge_end(prefix,bridge_view(runtime))
def bridge_first(result:Failure.Runtime<S,Unit,Unit,U32> & String) -> String:
  match result:
    case (runtime,line):bridge_second(line,Failure.with_world(~S,~Unit,~Unit,~U32,~Unit,~classify,identity,runtime))
def bridge_initial(result:Failure.Runtime<S,Unit,Unit,U32> & Unit) -> String:
  match result:
    case (runtime,_):bridge_first(bridge_view(runtime))
def bridge_created(result:W.Creation<S,Unit,Unit,U32>) -> String:
  match result:
    case W.CreateRejected{_,_}:"bridge-create-failed"
    case W.Created{_,world}:bridge_initial(Failure.with_world(~S,~Unit,~Unit,~U32,~Unit,~classify,identity,Failure.start(~S,~Unit,~Unit,~U32,seed(world))))
# Trusted machine resource lens and reader setup; actual publication/open APIs
# must preserve observation ordering even inside one enclosing execution scope.
def MachineState() -> Data:Init.State<S,Unit,U32>
def machine_take(state:MachineState()) -> MachineState() & MachineState():
  match state:
    case Init.State{+slot,+stream,+revision}:(Init.State{slot,stream,revision},Init.State{slot,stream,revision})
def machine_put(_:MachineState(),state:MachineState()) -> MachineState():state
def declaration() -> MachineDeclaration.Declaration<S,Unit,U32,MachineState(),Init.take_slot(~S,~Unit,~U32,~MachineState(),~machine_take,~machine_put)>:
  Init.declared(~S,~Unit,~U32,~MachineState(),~machine_take,~machine_put,"mode",[4,5,6])
def transition(value:Maybe<&2,Machine.Transition<U32>>) -> String:
  match value:
    case None{}:"none"
    case Some{Machine.Initial{v}}:"initial"++U32.show(v)
    case Some{Machine.Transition{a,b}}:U32.show(a)++">"++U32.show(b)
def machine_description(label:String,latest:Maybe<&2,Machine.Transition<U32>>,through:Nat,world:W.World<S,Unit,MachineState(),U32>) -> W.World<S,Unit,MachineState(),U32> & String:
  match world:
    case W.World{ns,a,s,r,e,p,g,n,+clock,lifecycle}:(W.World{ns,a,s,r,e,p,g,n,clock,lifecycle},label++":"++transition(latest)++":through="++Nat.show(through)++":now="++tick(Clock.now(clock))++":active="++tick(Clock.current(clock)))
def machine_finished(prefix:String,world:W.World<S,Unit,MachineState(),U32>) -> String:
  match world:
    case W.World{_,_,_,_,_,_,_,_,Clock.State{now,scopes},lifecycle}:prefix++"\nleave:now="++tick(now)++":scopes="++List.show(&2,Tick.Tick,tick,scopes)
def machine_last_described(prefix:String,result:W.World<S,Unit,MachineState(),U32> & String) -> String:
  match result:
    case (world,line):machine_finished(prefix++"\n"++line,W.leave_run(~S,~Unit,~MachineState(),~U32,world))
def machine_third(prefix:String,result:Marker.Opening<S,Unit,U32,Unit,MachineState(),U32>) -> String:
  match result:
    case Marker.OpenRejected{_,_}:"machine-third-refused"
    case Marker.Opened{world,_,latest,through}:machine_last_described(prefix,machine_description("marker",latest,through,world))
def machine_second_described(reader:Stream.Reader<S,Unit>,prefix:String,result:W.World<S,Unit,MachineState(),U32> & String) -> String:
  match result:
    case (world,line):machine_third(prefix++"\n"++line,Marker.open(~S,~Unit,~U32,~MachineState(),~machine_take,~machine_put,~Unit,~U32,reader,Marker.publish(~S,~Unit,~U32,~MachineState(),~machine_take,~machine_put,~Unit,~U32,world,Machine.Transition{5,6})))
def machine_second(prefix:String,result:Marker.Opening<S,Unit,U32,Unit,MachineState(),U32>) -> String:
  match result:
    case Marker.OpenRejected{_,_}:"machine-second-refused"
    case Marker.Opened{world,reader,latest,through}:machine_second_described(reader,prefix,machine_description("insert-again",latest,through,world))
def machine_first_described(reader:Stream.Reader<S,Unit>,result:W.World<S,Unit,MachineState(),U32> & String) -> String:
  match result:
    case (world,line):machine_second(line,Marker.open(~S,~Unit,~U32,~MachineState(),~machine_take,~machine_put,~Unit,~U32,reader,Init.insert_state(~S,~Unit,~U32,~MachineState(),~machine_take,~machine_put,~Unit,~U32,~declaration(),world,5)))
def machine_first(result:Marker.Opening<S,Unit,U32,Unit,MachineState(),U32>) -> String:
  match result:
    case Marker.OpenRejected{_,_}:"machine-first-refused"
    case Marker.Opened{world,reader,latest,through}:machine_first_described(reader,machine_description("initial",latest,through,world))
def machine_entered(result:W.World<S,Unit,MachineState(),U32> & Tick.Tick) -> String:
  match result:
    case (world,_):machine_first(Marker.open(~S,~Unit,~U32,~MachineState(),~machine_take,~machine_put,~Unit,~U32,Stream.Reader{500,1},Init.insert_state(~S,~Unit,~U32,~MachineState(),~machine_take,~machine_put,~Unit,~U32,~declaration(),world,4)))
def machine_created(result:W.Creation<S,Unit,MachineState(),U32>) -> String:
  match result:
    case W.CreateRejected{_,_}:"machine-create-refused"
    case W.Created{_,world}:machine_entered(W.enter_run(~S,~Unit,~MachineState(),~U32,world))
def machine_scenario() -> String:
  machine_created(W.create(~S,~Unit,~MachineState(),~U32,~(u => Unit{}),W.Factory{500},Init.empty(~S,~Unit,~U32)))

def main() -> IO(Unit):
  IO.print(created(W.create(~S,~Unit,~Unit,~U32,~(u => Unit{}),W.Factory{100},Unit{}))++"\n"++bridge_created(W.create(~S,~Unit,~Unit,~U32,~(u => Unit{}),W.Factory{200},Unit{}))++"\n"++machine_scenario())
