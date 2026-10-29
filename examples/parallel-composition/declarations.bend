import Base
import ./schema.bend as Schema
import ./feature-motion.bend as Motion
import ./feature-labels.bend as Labels
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-service.bend as Service
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as QueryStore
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-access.bend as Resource
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-parallel-scope-registry.bend as Registry
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-registration.bend as Reg

def C() -> Type:QueryStore.owner(~Schema.Nominal,Schema.components(),QueryStore.Sparse{})
def R() -> Type:ResourceStore.owner(~Schema.Nominal,Schema.resources(),ResourceStore.Sparse{})
def any(_:Maybe<&2,String>) -> Bool:True{}
def motion_combined(~Permit:Data,~H:Type,~B:Type,component:Q.GeneralWriter<Schema.Nominal,H,Motion.Position,String>,result:B & Resource.Writer<H,Motion.Counter,String>) -> B & Motion.Ops(~Schema.Nominal,Permit,H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def motion_component(~Permit:Data,~H:Type,~B:Type,~rw:Build.ResourceWrite(~Schema.Nominal,~C(),~R(),~H,~B),result:B & Q.GeneralWriter<Schema.Nominal,H,Motion.Position,String>) -> B & Motion.Ops(~Schema.Nominal,Permit,H):
  match result:
    case (book,component):motion_combined(~Permit,~H,~B,component,Build.general_resource_write(~Schema.Nominal,~C(),~R(),~H,~B,~Schema.resources(),~Schema.left(),~{==},~ResourceStore.Sparse{},~{==},~rw,book))
def motion_grants(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema.Nominal,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~Schema.Nominal,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~Schema.Nominal,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~Schema.Nominal,~C(),~R(),~H,~B),~query:Build.Query(~Schema.Nominal,~Schema.Store(),~C(),~R(),~H,~B),~lifecycle:Build.Lifecycle(~Schema.Nominal,~Schema.Store(),~C(),~R(),~H,~B),book:B) -> B & Motion.Ops(~Schema.Nominal,Permit,H):
  motion_component(~Permit,~H,~B,~rw,Build.general_query(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Schema.components(),~Schema.left(),~{==},~{==},~QueryStore.Sparse{},~{==},~Recipe.WriteRows{},~Recipe.AllLive{},~Match.Required{},~any,~H,~B,~query,book))
def motion_program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Permit,~H,~B),book:B) -> B & Motion.Ops(~Schema.Nominal,Permit,H):
  builder(Motion.Family(~Schema.Nominal),motion_grants(~Permit,~H,~B),book)
def motion_kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Permit,~H,~B),book:B) -> B & Motion.Ops(~Schema.Nominal,Permit,H):
  Build.framework_program(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Motion.Family(~Schema.Nominal),~motion_program,~Permit,~token,~H,~B,~builder,book)
def motion_compiled() -> D.Compilation<Schema.Nominal,Schema.Store(),C(),R(),Motion.Family(~Schema.Nominal)>:
  Program.compile_framework(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Motion.Family(~Schema.Nominal),~motion_kernel)
def MotionOwner() -> Type:Sys.Owner<Schema.Nominal,Schema.Store(),C(),R(),Unit,Motion.Family(~Schema.Nominal),Motion.Local<Schema.Nominal>,String,String,motion_kernel,Motion.body(~Schema.Nominal)>
def MotionBinding() -> Type:Scope.CompiledBinding<D.Compilation<Schema.Nominal,Schema.Store(),C(),R(),Motion.Family(~Schema.Nominal)>,MotionOwner()>
def MotionNode() -> Type:Leaf.node_type(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~String,~String,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~motion_kernel,~Motion.body(~Schema.Nominal))
def motion_facts(binding:MotionBinding()) -> Registry.GeneralizedFacts<MotionNode()>:
  Registry.generalized_leaf_facts(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~String,~String,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~motion_kernel,~Motion.body(~Schema.Nominal),binding)
def labels_combined(~Permit:Data,~H:Type,~B:Type,component:Q.GeneralWriter<Schema.Nominal,H,Labels.Label,String>,result:B & Resource.Writer<H,Service.Slot<Labels.Host>,Service.Status<String>>) -> B & Labels.Ops(~Schema.Nominal,Permit,H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def labels_component(~Permit:Data,~H:Type,~B:Type,~rw:Build.ResourceWrite(~Schema.Nominal,~C(),~R(),~H,~B),result:B & Q.GeneralWriter<Schema.Nominal,H,Labels.Label,String>) -> B & Labels.Ops(~Schema.Nominal,Permit,H):
  match result:
    case (book,component):labels_combined(~Permit,~H,~B,component,Build.general_resource_write(~Schema.Nominal,~C(),~R(),~H,~B,~Schema.resources(),~Schema.host_route(),~{==},~ResourceStore.Sparse{},~{==},~rw,book))
def labels_grants(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema.Nominal,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~Schema.Nominal,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~Schema.Nominal,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~Schema.Nominal,~C(),~R(),~H,~B),~query:Build.Query(~Schema.Nominal,~Schema.Store(),~C(),~R(),~H,~B),~lifecycle:Build.Lifecycle(~Schema.Nominal,~Schema.Store(),~C(),~R(),~H,~B),book:B) -> B & Labels.Ops(~Schema.Nominal,Permit,H):
  labels_component(~Permit,~H,~B,~rw,Build.general_query(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Schema.components(),~Schema.right(),~{==},~{==},~QueryStore.Sparse{},~{==},~Recipe.WriteRows{},~Recipe.AllLive{},~Match.Required{},~any,~H,~B,~query,book))
def labels_program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Permit,~H,~B),book:B) -> B & Labels.Ops(~Schema.Nominal,Permit,H):
  builder(Labels.Family(~Schema.Nominal),labels_grants(~Permit,~H,~B),book)
def labels_kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Permit,~H,~B),book:B) -> B & Labels.Ops(~Schema.Nominal,Permit,H):
  Build.framework_program(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Labels.Family(~Schema.Nominal),~labels_program,~Permit,~token,~H,~B,~builder,book)
def labels_compiled() -> D.Compilation<Schema.Nominal,Schema.Store(),C(),R(),Labels.Family(~Schema.Nominal)>:
  Program.compile_framework(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Labels.Family(~Schema.Nominal),~labels_kernel)
def LabelsOwner() -> Type:Sys.Owner<Schema.Nominal,Schema.Store(),C(),R(),Unit,Labels.Family(~Schema.Nominal),Labels.Local<Schema.Nominal>,String,String,labels_kernel,Labels.body(~Schema.Nominal)>
def LabelsBinding() -> Type:Scope.CompiledBinding<D.Compilation<Schema.Nominal,Schema.Store(),C(),R(),Labels.Family(~Schema.Nominal)>,LabelsOwner()>
def LabelsNode() -> Type:Leaf.node_type(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~String,~String,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~labels_kernel,~Labels.body(~Schema.Nominal))
def labels_facts(binding:LabelsBinding()) -> Registry.GeneralizedFacts<LabelsNode()>:
  Registry.generalized_leaf_facts(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~String,~String,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~labels_kernel,~Labels.body(~Schema.Nominal),binding)
def GuardFamily(Permit:Data,H:Type) -> Type:Cap.Bundle<Access.ResourceRead<H,Service.Status<String>>,Access.ResourceRead<H,String>>
type GuardLocal is Type:GuardLocal{token:Array<U32>,checks:U32}
def guard_combined(~Permit:Data,~H:Type,~B:Type,host:Access.ResourceRead<H,Service.Status<String>>,result:B & Access.ResourceRead<H,String>) -> B & GuardFamily(Permit,H):
  match result:
    case (book,optional):(book,Cap.Bundle{host,optional})
def guard_host(~Permit:Data,~H:Type,~B:Type,~rr:Build.ResourceRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),result:B & Access.ResourceRead<H,Service.Status<String>>) -> B & GuardFamily(Permit,H):
  match result:
    case (book,host):guard_combined(~Permit,~H,~B,host,Build.basic_resource_read(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B,~Schema.resources(),~Schema.optional_route(),~{==},~{==},~rr,book))
def guard_grants(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~cw:Build.ComponentWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~rr:Build.ResourceRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~rw:Build.ResourceWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~query:Build.Query(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),~lifecycle:Build.Lifecycle(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),book:B) -> B & GuardFamily(Permit,H):
  guard_host(~Permit,~H,~B,~rr,Build.basic_resource_read(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B,~Schema.resources(),~Schema.host_route(),~{==},~{==},~rr,book))
def guard_program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~Permit,~H,~B),book:B) -> B & GuardFamily(Permit,H):
  builder(GuardFamily,guard_grants(~Permit,~H,~B),book)
def guard_kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~Permit,~H,~B),book:B) -> B & GuardFamily(Permit,H):
  Build.framework_program(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~GuardFamily,~guard_program,~Permit,~token,~H,~B,~builder,book)
def guard_returned(~Permit:Data,~H:Type,local:GuardLocal,result:H & Service.Status<String>) -> Task.Task<Schema.Nominal,Permit,H & (GuardLocal & Sys.Completion<String,Bool>)>:
  match local result:
    case GuardLocal{token,checks},(scope,status):Task.TDone{(scope,(GuardLocal{token,U32.add(checks,1)},Service.required(~String,Layout.key(Schema.resources(),Schema.host_route()),status)))}
def optional_read(~Permit:Data,~H:Type,host:Access.ResourceRead<H,Service.Status<String>>,local:GuardLocal,result:H & String) -> Task.Task<Schema.Nominal,Permit,H & (GuardLocal & Sys.Completion<String,Bool>)>:
  match result:
    case (scope,_):guard_returned(~Permit,~H,local,Access.resource_read_field(~H,~Service.Status<String>,host)(scope))
def guard_caps(~Permit:Data,~H:Type,caps:GuardFamily(Unit,H),scope:H,local:GuardLocal) -> Task.Task<Schema.Nominal,Permit,H & (GuardLocal & Sys.Completion<String,Bool>)>:
  match caps:
    case Cap.Bundle{host,optional}:optional_read(~Permit,~H,host,local,Access.resource_read_field(~H,~String,optional)(scope))
def guard_body(~Permit:Data,~H:Type,~caps:GuardFamily(Permit,H),scope:H,local:GuardLocal) -> Task.Task<Schema.Nominal,Permit,H & (GuardLocal & Sys.Completion<String,Bool>)>:
  guard_caps(~Permit,~H,caps,scope,local)
def GuardOwner() -> Type:Sys.Owner<Schema.Nominal,Schema.Store(),Schema.Store(),Schema.Resources(),Unit,GuardFamily,GuardLocal,String,Bool,guard_kernel,guard_body>
def GuardCompilation() -> Type:D.Compilation<Schema.Nominal,Schema.Store(),Schema.Store(),Schema.Resources(),GuardFamily>
def guard_compiled() -> GuardCompilation():
  Program.compile_framework(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~GuardFamily,~guard_kernel)
def GuardBinding() -> Type:Scope.CompiledBinding<GuardCompilation(),GuardOwner()>
def MotionOwners() -> Type:Product.Owner<MotionNode(),MotionNode()>
def LabelsOwners() -> Type:Product.Owner<LabelsNode(),LabelsNode()>
def Owners() -> Type:Product.Owner<MotionOwners(),LabelsOwners()>
def Guards() -> Type:Reg.Product<GuardBinding(),GuardBinding()>
