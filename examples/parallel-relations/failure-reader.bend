import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ./scheduled.bend as Scheduled
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-relation-failure-selection.bend as Selection
import ../../src/ecs/execution-relation-failure-access.bend as Access
import ../../src/ecs/execution-relation-failure-local.bend as Local
import ../../src/ecs/execution-relation-failure-channel.bend as Reader
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/change-tick.bend as Tick

def Ops(~S:Data,Permit:Data,H:Type) -> Type:Access.Read<S,Scene.hierarchy(~S),Actor.resources(~S),Actor.route(),H>
type User<-S:Data> is Type:
  User{session:Actor.Session,calls:Nat,received:Nat,missed:Nat,messages:List<&2,Message.Message<S,Scene.hierarchy(~S)>>}
def State(~S:Data) -> Type:Local.Local<S,Scene.hierarchy(~S),Actor.resources(~S),Actor.route(),User<S>>
def selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Actor.C(~S),~Actor.R(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~Actor.C(~S),~Actor.R(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~Actor.C(~S),~Actor.R(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~Actor.C(~S),~Actor.R(~S),~H,~B),~query:Build.Query(~S,~Scheduled.Columns(~S),~Actor.C(~S),~Actor.R(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~Scheduled.Columns(~S),~Actor.C(~S),~Actor.R(~S),~H,~B),book:B) -> B & Ops(~S,Permit,H):
  Selection.select(~S,~Actor.C(~S),~Actor.R(~S),~H,~B,~Actor.resources(~S),~Actor.route(),~{==},~Scene.hierarchy(~S),~{==},~{==},~{==},~Scene.graph_layout(~S),~Layout.AtLeaf{},~{==},~{==},~{==},~resource_read,book)
def declaration(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Scheduled.Columns(~S),~Actor.C(~S),~Actor.R(~S),~Permit,~H,~B),book:B) -> B & Ops(~S,Permit,H):
  builder(Ops(~S),selection(~S,~Permit,~H,~B),book)
def consumed(~S:Data,~H:Type,scope:H,user:User<S>,messages:List<&2,Message.Message<S,Scene.hierarchy(~S)>>,missed:Nat,_:Tick.Tick) -> H & (User<S> & Sys.Completion<String,String>):
  match user messages:
    case User{session,calls,received,priorMissed,previous} +messages:(scope,(User{session,1n+calls,Nat.add(received,List.length(&2,Message.Message<S,Scene.hierarchy(~S)>,messages)),Nat.add(priorMissed,missed),List.append(&2,Message.Message<S,Scene.hierarchy(~S)>,previous,messages)},Sys.BodyError{"reader-after-consume","read retained failures"}))
def returned(~S:Data,~Permit:Data,~H:Type,value:Local.Invocation<H,State(~S),String,String>) -> Task.Task<S,Permit,H & (State(~S) & Sys.Completion<String,String>)>:
  match value:
    case Local.Invoked{scope,local,completion}:Task.TDone{(scope,(local,completion))}
    case Local.Refused{scope,local}:Task.TDone{(scope,(local,Sys.BodyError{"foreign-reader","reader retained"}))}
def body(~S:Data,~Permit:Data,~H:Type,~caps:Ops(~S,Permit,H),scope:H,local:State(~S)) -> Task.Task<S,Permit,H & (State(~S) & Sys.Completion<String,String>)>:
  returned(~S,~Permit,~H,Local.invoke(~S,~Scene.hierarchy(~S),~Actor.resources(~S),~Actor.route(),~H,~User<S>,~String,~String,~consumed(~S,~H),caps,scope,local))
def Owner(~S:Data) -> Type:Sys.Owner<S,Scheduled.Columns(~S),Actor.C(~S),Actor.R(~S),Unit,Ops(~S),State(~S),String,String,Build.framework_program(~S,~Scheduled.Columns(~S),~Actor.C(~S),~Actor.R(~S),~Ops(~S),~declaration(~S)),body(~S)>
