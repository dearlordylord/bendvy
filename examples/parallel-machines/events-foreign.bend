import Base
import ./component-probe.bend as Probe
import ./component-foreign.bend as ComponentForeign
import ./events-probe-declaration.bend as Declaration
import ./events.bend as Events
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observation.bend as Observe
import ./initialize.bend as Init
import ../../src/ecs/execution-app.bend as Ordinary
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

def Owner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,Events.Ops(~S),Events.Local<S>,String,String,Declaration.declaration(~S),Events.body(~S)>
def Application(~S:Data) -> Type:Ordinary.Application<S,D.Store(~S),D.Resources(~S),Unit,Events.Ops(~S),Events.Local<S>,String,String,Declaration.declaration(~S),Events.body(~S)>
def initial_resource(~S:Data,result:Layout.stored(D.layout(~S),Layout.AtLeaf{}) & Unit) -> D.Resources(~S):
  match result:
    case (stored,_):Layout.ResourceSlot{stored}
def resources(~S:Data,namespace:U32,tick:Tick.Tick,owner:D.Resources(~S)) -> D.Resources(~S):
  match owner:
    case Layout.ResourceSlot{stored}:initial_resource(~S,Layout.rewrite(~D.layout(~S),~Layout.AtLeaf{},Unit,Init.initialized(~S,namespace,tick),stored))
def clocked(~S:Data,result:Probe.World(~S) & Tick.Tick) -> Probe.World(~S):
  match result:
    case (W.World{+namespace,allocator,columns,resource,events,pending,registrations,next,clock,lifecycle},tick):W.World{namespace,allocator,columns,resources(~S,namespace,tick,resource),events,pending,registrations,next,clock,lifecycle}
def setup(~S:Data,world:Probe.World(~S)) -> Probe.World(~S):clocked(~S,W.clock(~S,~D.Store(~S),~D.Resources(~S),~Unit,world))
def bound(~S:Data,owner:Owner(~S)) -> Owner(~S):
  match owner:
    case Sys.Owner{+namespace,+id,name,access,cursor,local}:Sys.Owner{namespace,id,name,access,cursor,Events.bound_local(~S,namespace,id,local)}
def completed(~S:Data,source:String,result:Application(~S) & Ordinary.Status<String,String>) -> String:
  match result:
    case (Ordinary.Application{world,Sys.Owner{namespace,id,name,access,cursor,local}},status):"source{" ++ source ++ "}|target{" ++ ComponentForeign.source(~S,world) ++ "}|reader-owner=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,Observe.text,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ":" ++ Observe.events_local(~S,local) ++ "|" ++ Probe.status(status)
def target_defined(~S:Data,source:String,result:Ordinary.Built<Application(~S),Probe.World(~S),Events.Local<S>>) -> String:
  match result:
    case Ordinary.Built{app}:completed(~S,source,Ordinary.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Events.Ops(~S),~Events.Local<S>,~String,~String,~Declaration.declaration(~S),~Events.body(~S),app))
    case Ordinary.BuildRefused{_,_}:"ERROR:target-define"
def transferred(~S:Data,target:Probe.World(~S),foreign:Probe.World(~S),owner:Owner(~S)) -> String:
  match owner:
    case Sys.Owner{namespace,id,name,access,cursor,local}:target_defined(~S,ComponentForeign.source(~S,foreign) ++ "/registration=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,Observe.text,access) ++ ":" ++ Tick.cursor_show(cursor),Ordinary.define(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Events.Ops(~S),~Events.Local<S>,~String,~String,~Declaration.declaration(~S),~Events.body(~S),target,"transferred-reader",local))
def source_defined(~S:Data,target:Probe.World(~S),result:Ordinary.Built<Application(~S),Probe.World(~S),Events.Local<S>>) -> String:
  match result:
    case Ordinary.Built{Ordinary.Application{foreign,owner}}:transferred(~S,target,foreign,bound(~S,owner))
    case Ordinary.BuildRefused{_,_}:"ERROR:source-define"
def run(~S:Data,target:Probe.World(~S),foreign:Probe.World(~S)) -> String:
  source_defined(~S,setup(~S,target),Ordinary.define(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Events.Ops(~S),~Events.Local<S>,~String,~String,~Declaration.declaration(~S),~Events.body(~S),setup(~S,foreign),"original-reader",Events.Local{None{},Body.local(101,102)}))
def second_created(~S:Data,target:Probe.World(~S),result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,foreign}:run(~S,target,foreign)
    case W.CreateRejected{_,_}:"ERROR:second-create"
def first_created(~S:Data,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{factory,target}:second_created(~S,target,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Probe.empty(~S),factory,Probe.resources(~S)))
    case W.CreateRejected{_,_}:"ERROR:first-create"
type Schema is Data:
  Schema{}
def main() -> IO(Unit):IO.print(first_created(~Schema,W.create(~Schema,~D.Store(~Schema),~D.Resources(~Schema),~Unit,~Probe.empty(~Schema),W.factory(),Probe.resources(~Schema))))
