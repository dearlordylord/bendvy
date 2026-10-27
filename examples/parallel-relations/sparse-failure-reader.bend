import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ./failure-reader.bend as Existing
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-relation-failure-selection.bend as Selection
import ../../src/ecs/execution-query-store.bend as QueryStore
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-relation-failure-access.bend as Access
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-admission.bend as Admission
import ../../src/ecs/execution-prepared.bend as Prepared
import ../../src/ecs/world.bend as W

type Schema is Data:
  SparseScene{}
def C() -> Type:QueryStore.Storage<Schema,Actor.components()>
def R() -> Type:ResourceStore.Storage<Schema,Actor.resources(~Schema)>
def WC() -> Type:QueryStore.owner(~Schema,Actor.components(),QueryStore.Whole{})
def Ops(Permit:Data,H:Type) -> Type:Existing.Ops(~Schema,Permit,H)
def Local() -> Type:Existing.State(~Schema)
def selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~Schema,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~Schema,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~Schema,~C(),~R(),~H,~B),~query:Build.Query(~Schema,~WC(),~C(),~R(),~H,~B),~life:Build.Lifecycle(~Schema,~WC(),~C(),~R(),~H,~B),book:B) -> B & Ops(Permit,H):
  Selection.general(~Schema,~C(),~R(),~H,~B,~Actor.resources(~Schema),~Actor.route(),~{==},~Scene.hierarchy(~Schema),~{==},~{==},~{==},~ResourceStore.Sparse{},~{==},~rr,book)
def declaration(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~WC(),~C(),~R(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):builder(Ops,selection(~Permit,~H,~B),book)
def kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~WC(),~C(),~R(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  Build.framework_program(~Schema,~WC(),~C(),~R(),~Ops,~declaration,~Permit,~token,~H,~B,~builder,book)
def body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Local()) -> Task.Task<Schema,Permit,H & (Local() & Sys.Completion<String,String>)>:
  Existing.body(~Schema,~Permit,~H,~caps,scope,local)
def compiled() -> Decl.Compilation<Schema,WC(),C(),R(),Ops>:Program.compile_framework(~Schema,~WC(),~C(),~R(),~Ops,~kernel)
def Owner() -> Type:Sys.Owner<Schema,WC(),C(),R(),Unit,Ops,Local(),String,String,kernel,body>
def Node() -> Type:Leaf.node_type(~Schema,~Actor.components(),~Actor.resources(~Schema),~Unit,~String,~String,~Ops,~Local(),~kernel,~body)
def retire(node:Node()) -> Owner():
  Leaf.restore_node(Decl.Compilation<Schema,WC(),C(),R(),Ops>,W.World<Schema,WC(),Layout.resources(~Schema,Actor.resources(~Schema)),Unit>,Owner(),Admission.Evidence<Schema,Actor.components(),Actor.resources(~Schema),C(),R(),Ops,kernel>,Prepared.Permit<Schema,WC()>,node)
