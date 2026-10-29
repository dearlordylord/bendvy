import Base
import ../../src/ecs/execution-reservation-task.bend as Effect
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observation.bend as Observe
import ../../src/ecs/execution-machine-access.bend as Machine
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-app.bend as Ordinary
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/machine.bend as M
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Life
import ../../test-fixtures/common/column-observation.bend as Common

# Same S/K/V, distinct actual resource routes. Only the selected left callback
# may change left Next; right is read through its separately declared callback.
type Schema is Data:
  Schema{}
def layout() -> Layout.Layout:Layout.LayoutPair{Machine.leaf(Schema,D.Key,D.Mode,"left-mode"),Machine.leaf(Schema,D.Key,D.Mode,"right-mode")}
def Resources() -> Type:Layout.resources(~Schema,layout())
def Ops(Permit:Data,H:Type) -> Type:Product.Owner<Machine.Write<Schema,D.Key,D.Mode,H>,Machine.Read<Schema,D.Key,D.Mode,H>>
def left_payload() -> {Layout.payload(layout(),Layout.InLeft{Layout.AtLeaf{}}) == State.Cell<Schema,D.Key,D.Mode> : Type}:{==}
def left_view() -> {Layout.view(layout(),Layout.InLeft{Layout.AtLeaf{}}) == State.View<Schema,D.Key,D.Mode> : Data}:{==}
def right_view() -> {Layout.view(layout(),Layout.InRight{Layout.AtLeaf{}}) == State.View<Schema,D.Key,D.Mode> : Data}:{==}
def right_selected(~Permit:Data,~H:Type,~B:Type,left:Machine.Write<Schema,D.Key,D.Mode,H>,result:B & Machine.Read<Schema,D.Key,D.Mode,H>) -> B & Ops(Permit,H):
  match result:
    case (book,right):(book,Product.Owner{left,right})
def left_selected(~Permit:Data,~H:Type,~B:Type,~rr:Build.ResourceRead(~Schema,~Unit,~Resources(),~H,~B),result:B & Machine.Write<Schema,D.Key,D.Mode,H>) -> B & Ops(Permit,H):
  match result:
    case (book,left):right_selected(~Permit,~H,~B,left,Machine.select_read(~Schema,~D.Key,~D.Mode,~Unit,~Resources(),~H,~B,~layout(),~Layout.InRight{Layout.AtLeaf{}},~{==},~{==},~right_view(),~rr,book))
def selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema,~Unit,~Resources(),~H,~B),~cw:Build.ComponentWrite(~Schema,~Unit,~Resources(),~H,~B),~rr:Build.ResourceRead(~Schema,~Unit,~Resources(),~H,~B),~rw:Build.ResourceWrite(~Schema,~Unit,~Resources(),~H,~B),~q:Build.Query(~Schema,~Unit,~Unit,~Resources(),~H,~B),~lifecycle:Build.Lifecycle(~Schema,~Unit,~Unit,~Resources(),~H,~B),book:B) -> B & Ops(Permit,H):
  left_selected(~Permit,~H,~B,~rr,Machine.select_write(~Schema,~D.Key,~D.Mode,~Unit,~Resources(),~H,~B,~layout(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~left_payload(),~left_view(),~D.same,~rw,book))
def declaration(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Unit,~Unit,~Resources(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):builder(Ops,selection(~Permit,~H,~B),book)
def read_right(~H:Type,local:Body.Local(),result:H & State.View<Schema,D.Key,D.Mode>) -> H & (Body.Local() & Sys.Completion<String,String>):
  match result:
    case (scope,value):(scope,(local,Sys.Success{"right=" ++ Body.view(~Schema,value)}))
def requested(~H:Type,right:Machine.Read<Schema,D.Key,D.Mode,H>,local:Body.Local(),result:H & Unit) -> H & (Body.Local() & Sys.Completion<String,String>):
  match result:
    case (scope,_):read_right(~H,local,Machine.read_field(~Schema,~D.Key,~D.Mode,~H,right)(scope))
def body_ops(~Permit:Data,~H:Type,caps:Ops(Permit,H),scope:H,local:Body.Local()) -> H & (Body.Local() & Sys.Completion<String,String>):
  match caps:
    case Product.Owner{left,right}:requested(~H,right,local,Machine.request_field(~Schema,~D.Key,~D.Mode,~H,left)(M.Set{D.Running{},True{}},scope))
def body_sync(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Body.Local()) -> H & (Body.Local() & Sys.Completion<String,String>):body_ops(~Permit,~H,caps,scope,local)
def body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Body.Local()) -> Effect.Task<Schema,Permit,H & (Body.Local() & Sys.Completion<String,String>)>:
  Effect.TDone{body_sync(~Permit,~H,~caps,scope,local)}
def empty(_:Unit) -> Unit:Unit{}
def resources() -> Resources():Product.Owner{Layout.ResourceSlot{Layout.initialize(layout(),Layout.InLeft{Layout.AtLeaf{}},State.empty(~Schema,~D.Key,~D.Mode)),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(layout(),Layout.InRight{Layout.AtLeaf{}},State.empty(~Schema,~D.Key,~D.Mode)),Layout.unknown_stamp()}}
def initial_cell(namespace:U32,tick:Tick.Tick,value:D.Mode,cell:State.Cell<Schema,D.Key,D.Mode>) -> State.Cell<Schema,D.Key,D.Mode> & Unit:
  (State.initialize(~Schema,~D.Key,~D.Mode,State.bind(~Schema,~D.Key,~D.Mode,namespace,cell),value,tick),Unit{})
def joined_initial(+tick:Tick.Tick,left:Layout.stored(layout(),Layout.InLeft{Layout.AtLeaf{}}),result:Layout.stored(layout(),Layout.InRight{Layout.AtLeaf{}}) & Unit) -> Resources():
  match result:
    case (right,_):Product.Owner{Layout.ResourceSlot{left,Life.Stamp{Some{tick},Some{tick}}},Layout.ResourceSlot{right,Life.Stamp{Some{tick},Some{tick}}}}
def left_initial(namespace:U32,+tick:Tick.Tick,right:Layout.stored(layout(),Layout.InRight{Layout.AtLeaf{}}),result:Layout.stored(layout(),Layout.InLeft{Layout.AtLeaf{}}) & Unit) -> Resources():
  match result:
    case (left,_):joined_initial(tick,left,Layout.rewrite(~layout(),~Layout.InRight{Layout.AtLeaf{}},Unit,initial_cell(namespace,tick,D.Running{}),right))
def initial_resources(+namespace:U32,+tick:Tick.Tick,resource:Resources()) -> Resources():
  match resource:
    case Product.Owner{Layout.ResourceSlot{left,_},Layout.ResourceSlot{right,_}}:left_initial(namespace,tick,right,Layout.rewrite(~layout(),~Layout.InLeft{Layout.AtLeaf{}},Unit,initial_cell(namespace,tick,D.Waiting{}),left))
def clocked(result:W.World<Schema,Unit,Resources(),Unit> & Tick.Tick) -> W.World<Schema,Unit,Resources(),Unit>:
  match result:
    case (W.World{+namespace,allocator,store,resource,events,pending,registrations,next,clock,lifecycle},tick):W.World{namespace,allocator,store,initial_resources(namespace,tick,resource),events,pending,registrations,next,clock,lifecycle}
def snapshot(value:Resources()) -> String:
  match value:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{left,leftCache},leftStamp},Layout.ResourceSlot{Layout.Viewed{right,rightCache},rightStamp}}:"left{" ++ Observe.cell(~Schema,left) ++ "/cache=" ++ Body.view(~Schema,leftCache) ++ "/resource-stamp=" ++ Common.stamp_text(Some{leftStamp}) ++ "};right{" ++ Observe.cell(~Schema,right) ++ "/cache=" ++ Body.view(~Schema,rightCache) ++ "/resource-stamp=" ++ Common.stamp_text(Some{rightStamp}) ++ "}"
def completed(result:Ordinary.Application<Schema,Unit,Resources(),Unit,Ops,Body.Local(),String,String,Build.framework_program(~Schema,~Unit,~Unit,~Resources(),~Ops,~declaration),body> & Ordinary.Status<String,String>) -> String:
  match result:
    case (Ordinary.Application{W.World{_,_,_,resource,_,_,_,_,_,_},Sys.Owner{_,_,_,_,_,local}},Ordinary.Ran{Sys.Success{out}}):out ++ "|" ++ snapshot(resource) ++ "|local=" ++ Observe.local(local)
    case (_,_):"ERROR:run"
def defined(result:Ordinary.Built<Ordinary.Application<Schema,Unit,Resources(),Unit,Ops,Body.Local(),String,String,Build.framework_program(~Schema,~Unit,~Unit,~Resources(),~Ops,~declaration),body>,W.World<Schema,Unit,Resources(),Unit>,Body.Local()>) -> IO(String):
  match result:
    case Ordinary.Built{app}:IO.bind(Ordinary.Application<Schema,Unit,Resources(),Unit,Ops,Body.Local(),String,String,Build.framework_program(~Schema,~Unit,~Unit,~Resources(),~Ops,~declaration),body> & Ordinary.Status<String,String>,String,Ordinary.run(~Schema,~Unit,~Resources(),~Unit,~Ops,~Body.Local(),~String,~String,~Build.framework_program(~Schema,~Unit,~Unit,~Resources(),~Ops,~declaration),~body,app),result => IO.pure(String,completed(result)))
    case Ordinary.BuildRefused{_,_}:IO.pure(String,"ERROR:define")
def created(result:W.Creation<Schema,Unit,Resources(),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:defined(Ordinary.define(~Schema,~Unit,~Resources(),~Unit,~Ops,~Body.Local(),~String,~String,~declaration,~body,clocked(W.clock(~Schema,~Unit,~Resources(),~Unit,world)),"route-request",Body.local(101,102)))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR:create")
def main() -> IO(Unit):IO.bind(String,Unit,created(W.create(~Schema,~Unit,~Resources(),~Unit,~empty,W.factory(),resources())),IO.print)
