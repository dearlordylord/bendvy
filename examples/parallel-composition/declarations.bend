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
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-executor.bend as Exec

def motion_combined(~H:Type,~B:Type,component:Access.ComponentWrite<Schema.Nominal,H,Motion.Position,String>,result:B & Access.ResourceWrite<H,Motion.Counter,String>) -> B & Motion.Ops(~Schema.Nominal,H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def motion_component(~H:Type,~B:Type,~rw:Build.ResourceWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),result:B & Access.ComponentWrite<Schema.Nominal,H,Motion.Position,String>) -> B & Motion.Ops(~Schema.Nominal,H):
  match result:
    case (book,component):motion_combined(~H,~B,component,Build.basic_resource_write(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B,~Schema.resources(),~Schema.left(),~{==},~{==},~rw,book))
def motion_grants(~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~cw:Build.ComponentWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~rr:Build.ResourceRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~rw:Build.ResourceWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~query:Build.Query(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),~lifecycle:Build.Lifecycle(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),book:B) -> B & Motion.Ops(~Schema.Nominal,H):
  motion_component(~H,~B,~rw,cw(Schema.components(),Schema.left(),{==},{==},book))
def motion_program(~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),book:B) -> B & Motion.Ops(~Schema.Nominal,H):
  builder(Motion.Family(~Schema.Nominal),motion_grants(~H,~B),book)
def labels_combined(~H:Type,~B:Type,component:Access.ComponentWrite<Schema.Nominal,H,Labels.Label,String>,result:B & Access.ResourceWrite<H,Service.Slot<Labels.Host>,Service.Status<String>>) -> B & Labels.Ops(~Schema.Nominal,H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def labels_component(~H:Type,~B:Type,~rw:Build.ResourceWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),result:B & Access.ComponentWrite<Schema.Nominal,H,Labels.Label,String>) -> B & Labels.Ops(~Schema.Nominal,H):
  match result:
    case (book,component):labels_combined(~H,~B,component,Build.basic_resource_write(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B,~Schema.resources(),~Schema.host_route(),~{==},~{==},~rw,book))
def labels_grants(~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~cw:Build.ComponentWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~rr:Build.ResourceRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~rw:Build.ResourceWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~query:Build.Query(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),~lifecycle:Build.Lifecycle(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),book:B) -> B & Labels.Ops(~Schema.Nominal,H):
  labels_component(~H,~B,~rw,cw(Schema.components(),Schema.right(),{==},{==},book))
def labels_program(~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),book:B) -> B & Labels.Ops(~Schema.Nominal,H):
  builder(Labels.Family(~Schema.Nominal),labels_grants(~H,~B),book)
def GuardFamily(H:Type) -> Type:Cap.Bundle<Access.ResourceRead<H,Service.Status<String>>,Access.ResourceRead<H,String>>
type GuardLocal is Type:GuardLocal{token:Array<U32>,checks:U32}
def guard_combined(~H:Type,~B:Type,host:Access.ResourceRead<H,Service.Status<String>>,result:B & Access.ResourceRead<H,String>) -> B & GuardFamily(H):
  match result:
    case (book,optional):(book,Cap.Bundle{host,optional})
def guard_host(~H:Type,~B:Type,~rr:Build.ResourceRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),result:B & Access.ResourceRead<H,Service.Status<String>>) -> B & GuardFamily(H):
  match result:
    case (book,host):guard_combined(~H,~B,host,Build.basic_resource_read(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B,~Schema.resources(),~Schema.optional_route(),~{==},~{==},~rr,book))
def guard_grants(~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~cw:Build.ComponentWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~rr:Build.ResourceRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~rw:Build.ResourceWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~query:Build.Query(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),~lifecycle:Build.Lifecycle(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),book:B) -> B & GuardFamily(H):
  guard_host(~H,~B,~rr,Build.basic_resource_read(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B,~Schema.resources(),~Schema.host_route(),~{==},~{==},~rr,book))
def guard_program(~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),book:B) -> B & GuardFamily(H):
  builder(GuardFamily,guard_grants(~H,~B),book)
def guard_returned(~H:Type,local:GuardLocal,result:H & Service.Status<String>) -> H & (GuardLocal & Sys.Completion<String,Bool>):
  match local result:
    case GuardLocal{token,checks},(scope,status):(scope,(GuardLocal{token,U32.add(checks,1)},Service.required(~String,Layout.key(Schema.resources(),Schema.host_route()),status)))
def optional_read(~H:Type,~host:Access.ResourceRead<H,Service.Status<String>>,local:GuardLocal,result:H & String) -> H & (GuardLocal & Sys.Completion<String,Bool>):
  match result:
    case (scope,_):guard_returned(~H,local,Access.resource_read_field(~H,~Service.Status<String>,host)(scope))
def guard_body(~H:Type,~caps:GuardFamily(H),scope:H,local:GuardLocal) -> H & (GuardLocal & Sys.Completion<String,Bool>):
  optional_read(~H,~Cap.first(~Access.ResourceRead<H,Service.Status<String>>,~Access.ResourceRead<H,String>,caps),local,Access.resource_read_field(~H,~String,Cap.second(~Access.ResourceRead<H,Service.Status<String>>,~Access.ResourceRead<H,String>,caps))(scope))
def MotionOwner() -> Type:Sys.Owner<Schema.Nominal,Schema.Store(),Schema.Store(),Schema.Resources(),Unit,Motion.Family(~Schema.Nominal),Motion.Local<Schema.Nominal>,String,String,motion_program,Motion.body(~Schema.Nominal)>
def LabelsOwner() -> Type:Sys.Owner<Schema.Nominal,Schema.Store(),Schema.Store(),Schema.Resources(),Unit,Labels.Family(~Schema.Nominal),Labels.Local<Schema.Nominal>,String,String,labels_program,Labels.body(~Schema.Nominal)>
def GuardOwner() -> Type:Sys.Owner<Schema.Nominal,Schema.Store(),Schema.Store(),Schema.Resources(),Unit,GuardFamily,GuardLocal,String,Bool,guard_program,guard_body>
def MotionOwners() -> Type:Reg.Product<MotionOwner(),MotionOwner()>
def LabelsOwners() -> Type:Reg.Product<LabelsOwner(),LabelsOwner()>
def Owners() -> Type:Reg.Product<MotionOwners(),LabelsOwners()>
def Guards() -> Type:Reg.Product<GuardOwner(),GuardOwner()>
def motion_dispatch() -> MotionOwners() -> Schema.World() -> U32 -> MotionOwners() & (Schema.World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~Schema.World(),~MotionOwner(),~MotionOwner(),~String,~String,~Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~motion_program,~Motion.body(~Schema.Nominal)),~Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~motion_program,~Motion.body(~Schema.Nominal)))
def labels_dispatch() -> LabelsOwners() -> Schema.World() -> U32 -> LabelsOwners() & (Schema.World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~Schema.World(),~LabelsOwner(),~LabelsOwner(),~String,~String,~Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~labels_program,~Labels.body(~Schema.Nominal)),~Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~labels_program,~Labels.body(~Schema.Nominal)))
def dispatch() -> Owners() -> Schema.World() -> U32 -> Owners() & (Schema.World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~Schema.World(),~MotionOwners(),~LabelsOwners(),~String,~String,~Reg.paired_dispatch(~Schema.World(),~MotionOwner(),~MotionOwner(),~String,~String,~Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~motion_program,~Motion.body(~Schema.Nominal)),~Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~motion_program,~Motion.body(~Schema.Nominal))),~Reg.paired_dispatch(~Schema.World(),~LabelsOwner(),~LabelsOwner(),~String,~String,~Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~labels_program,~Labels.body(~Schema.Nominal)),~Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~labels_program,~Labels.body(~Schema.Nominal))))
def guards_dispatch() -> Guards() -> Schema.World() -> U32 -> Guards() & (Schema.World() & Exec.Invocation<String,Bool>):Reg.paired_dispatch(~Schema.World(),~GuardOwner(),~GuardOwner(),~String,~Bool,~Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~GuardFamily,~GuardLocal,~String,~Bool,~guard_program,~guard_body),~Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~GuardFamily,~GuardLocal,~String,~Bool,~guard_program,~guard_body))
def motion_leaf(~F:Prog.Family(~String,~String),~leaf:Prog.Leaf(~String,~String,~F),~pair:Prog.Join(~String,~String,~F),~partition:Prog.Partition(~String,~String,~F),~rootcut:Prog.Rootcut(~String,~String,~F),~empty:Prog.Vacant(~String,~String,~F),owner:MotionOwner()) -> F(Schema.World(),MotionOwner(),Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~motion_program,~Motion.body(~Schema.Nominal))):
  leaf(Schema.Nominal,Schema.Store(),Schema.Resources(),Unit,Motion.Family(~Schema.Nominal),Motion.Local<Schema.Nominal>,motion_program,Motion.body(~Schema.Nominal),owner)
def labels_leaf(~F:Prog.Family(~String,~String),~leaf:Prog.Leaf(~String,~String,~F),~pair:Prog.Join(~String,~String,~F),~partition:Prog.Partition(~String,~String,~F),~rootcut:Prog.Rootcut(~String,~String,~F),~empty:Prog.Vacant(~String,~String,~F),owner:LabelsOwner()) -> F(Schema.World(),LabelsOwner(),Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~labels_program,~Labels.body(~Schema.Nominal))):
  leaf(Schema.Nominal,Schema.Store(),Schema.Resources(),Unit,Labels.Family(~Schema.Nominal),Labels.Local<Schema.Nominal>,labels_program,Labels.body(~Schema.Nominal),owner)
def guard_leaf(~F:Prog.Family(~String,~Bool),~leaf:Prog.Leaf(~String,~Bool,~F),~pair:Prog.Join(~String,~Bool,~F),~partition:Prog.Partition(~String,~Bool,~F),~rootcut:Prog.Rootcut(~String,~Bool,~F),~empty:Prog.Vacant(~String,~Bool,~F),owner:GuardOwner()) -> F(Schema.World(),GuardOwner(),Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~GuardFamily,~GuardLocal,~String,~Bool,~guard_program,~guard_body)):
  leaf(Schema.Nominal,Schema.Store(),Schema.Resources(),Unit,GuardFamily,GuardLocal,guard_program,guard_body,owner)
def motion_selection(~F:Prog.Family(~String,~String),~leaf:Prog.Leaf(~String,~String,~F),~pair:Prog.Join(~String,~String,~F),~partition:Prog.Partition(~String,~String,~F),~rootcut:Prog.Rootcut(~String,~String,~F),~empty:Prog.Vacant(~String,~String,~F),owners:MotionOwners()) -> F(Schema.World(),MotionOwners(),motion_dispatch()):
  match owners:
    case Reg.Product{left,right,_}:pair(Schema.World(),MotionOwner(),MotionOwner(),Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~motion_program,~Motion.body(~Schema.Nominal)),Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~motion_program,~Motion.body(~Schema.Nominal)),motion_leaf(~F,~leaf,~pair,~partition,~rootcut,~empty,left),motion_leaf(~F,~leaf,~pair,~partition,~rootcut,~empty,right))
def labels_selection(~F:Prog.Family(~String,~String),~leaf:Prog.Leaf(~String,~String,~F),~pair:Prog.Join(~String,~String,~F),~partition:Prog.Partition(~String,~String,~F),~rootcut:Prog.Rootcut(~String,~String,~F),~empty:Prog.Vacant(~String,~String,~F),owners:LabelsOwners()) -> F(Schema.World(),LabelsOwners(),labels_dispatch()):
  match owners:
    case Reg.Product{left,right,_}:pair(Schema.World(),LabelsOwner(),LabelsOwner(),Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~labels_program,~Labels.body(~Schema.Nominal)),Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~labels_program,~Labels.body(~Schema.Nominal)),labels_leaf(~F,~leaf,~pair,~partition,~rootcut,~empty,left),labels_leaf(~F,~leaf,~pair,~partition,~rootcut,~empty,right))
def selection(~F:Prog.Family(~String,~String),~leaf:Prog.Leaf(~String,~String,~F),~pair:Prog.Join(~String,~String,~F),~partition:Prog.Partition(~String,~String,~F),~rootcut:Prog.Rootcut(~String,~String,~F),~empty:Prog.Vacant(~String,~String,~F),owners:Owners()) -> F(Schema.World(),Owners(),dispatch()):
  match owners:
    case Reg.Product{left,right,_}:pair(Schema.World(),MotionOwners(),LabelsOwners(),motion_dispatch(),labels_dispatch(),motion_selection(~F,~leaf,~pair,~partition,~rootcut,~empty,left),labels_selection(~F,~leaf,~pair,~partition,~rootcut,~empty,right))
def guards_selection(~F:Prog.Family(~String,~Bool),~leaf:Prog.Leaf(~String,~Bool,~F),~pair:Prog.Join(~String,~Bool,~F),~partition:Prog.Partition(~String,~Bool,~F),~rootcut:Prog.Rootcut(~String,~Bool,~F),~empty:Prog.Vacant(~String,~Bool,~F),owners:Guards()) -> F(Schema.World(),Guards(),guards_dispatch()):
  match owners:
    case Reg.Product{left,right,_}:pair(Schema.World(),GuardOwner(),GuardOwner(),Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~GuardFamily,~GuardLocal,~String,~Bool,~guard_program,~guard_body),Reg.leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~GuardFamily,~GuardLocal,~String,~Bool,~guard_program,~guard_body),guard_leaf(~F,~leaf,~pair,~partition,~rootcut,~empty,left),guard_leaf(~F,~leaf,~pair,~partition,~rootcut,~empty,right))
