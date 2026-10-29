import Base
import ./schema.bend as Schema
import ./declarations.bend as D
import ./feature-labels.bend as Labels
import ./group.bend as Group
import ../../src/ecs/feature.bend as Feature
import ../../src/ecs/execution-generalized-root-application.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-parallel-scope-registry.bend as Registry
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/execution-composer-schema.bend as Inventory
import ../../src/ecs/dependency-composer.bend as Compose
import ../../src/ecs/dependency-composer-program.bend as Scoped
import ../../src/ecs/dependency-application.bend as Dep
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-registration.bend as Reg

type Provisions is Type:Provisions{motion:Array<U32>,labels:Array<String>,host:Maybe<&1,Labels.Host>,refused:List<Labels.Host>}
type Handler is Type:Handler{token:Array<U32>,errors:List<&2,String>}
def handle(handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,List.append(&2,String,errors,[error])},Exec.Continue{})
def Storage() -> Type:Root.Storage<Schema.Nominal,Schema.components(),Schema.resources(),Unit>
def State() -> Type:Dep.State<Storage(),D.Owners(),D.Guards(),Handler>
def Scheduled() -> Type:Schedule.Scheduled<State()>
def Application() -> Type:Feature.Application<Scheduled(),Provisions>
def Report() -> Data:Feature.Report<Dep.Report<String,String>>
def groups() -> List<&2,Scoped.Nested>:
  [Scoped.Nested{[0],[Plan.Edge{1,2}]},Scoped.Nested{[1],[Plan.Edge{3,4}]},Scoped.Nested{[],[Plan.Edge{1,3},Plan.Edge{3,2}]}]
def guard_dispatch() -> D.GuardBinding() -> Schema.World() -> U32 -> IO(D.GuardBinding() & (Schema.World() & Exec.Invocation<String,Bool>)):
  Conditions.retained_leaf_dispatch(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~D.GuardFamily,~D.GuardLocal,~String,~D.guard_kernel,~D.guard_body,~D.guard_compiled())
def guards_dispatch() -> D.Guards() -> Schema.World() -> U32 -> IO(D.Guards() & (Schema.World() & Exec.Invocation<String,Bool>)):
  Conditions.paired_dispatch(~Schema.World(),~D.GuardBinding(),~D.GuardBinding(),~String,~guard_dispatch(),~guard_dispatch())
def guards(owners:D.Guards()) -> Conditions.Registry<Schema.World(),D.Guards(),String,guards_dispatch()>:
  match owners:
    case Reg.Product{left,right,_}:Conditions.compile_join(~String,~Schema.World(),~D.GuardBinding(),~D.GuardBinding(),~guard_dispatch(),~guard_dispatch(),Conditions.compile_retained_leaf(~String,~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~D.GuardFamily,~D.GuardLocal,~D.guard_kernel,~D.guard_body,~D.guard_compiled(),left),Conditions.compile_retained_leaf(~String,~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~Unit,~D.GuardFamily,~D.GuardLocal,~D.guard_kernel,~D.guard_body,~D.guard_compiled(),right))
def available(key:String) -> Bool:Compose.provides(~Schema.Nominal,Inventory.inventory(~Schema.Nominal,~Schema.components(),~Schema.resources()),key)
def assembly(a:D.MotionBinding(),b:D.MotionBinding(),c:D.LabelsBinding(),d:D.LabelsBinding()) -> Feature.Assembly<Schema.Nominal,D.Owners()>:
  Feature.pair(~Schema.Nominal,D.MotionOwners(),D.LabelsOwners(),Feature.from_facts(~Schema.Nominal,~Schema.components(),~Schema.resources(),D.MotionOwners(),"motion",Feature.Empty{},Registry.generalized_pair_facts(D.MotionNode(),D.MotionNode(),D.motion_facts(a),D.motion_facts(b))),Feature.from_facts(~Schema.Nominal,~Schema.components(),~Schema.resources(),D.LabelsOwners(),"labels",Feature.Empty{},Registry.generalized_pair_facts(D.LabelsNode(),D.LabelsNode(),D.labels_facts(c),D.labels_facts(d))))
def build_lowered(world:Schema.World(),conditions:D.Guards(),lowered:Feature.Lowered<D.Owners()>) -> Application():
  match lowered:
    case Feature.Lowered{facts,edges,invalid}:Feature.Application{Root.build(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~D.Owners(),~D.Guards(),~Handler,~String,~guards_dispatch(),~available,world,facts,guards(conditions),Handler{ALeaf{801},[]},edges,[Dep.Binding{3,5},Dep.Binding{4,6}]),Provisions{ALeaf{601},ALeaf{"PROVISION-602"},Some{Labels.Host{ALeaf{"HOST-901"},0}},[]},invalid}
def build(world:Schema.World(),a:D.MotionBinding(),b:D.MotionBinding(),c:D.LabelsBinding(),d:D.LabelsBinding(),conditions:D.Guards(),nesting:List<&2,Scoped.Nested>) -> Application():
  build_lowered(world,conditions,Feature.lower(~Schema.Nominal,~Schema.components(),~Schema.resources(),D.Owners(),nesting,assembly(a,b,c,d)))
def publish(ids:List<&2,U32>,world:Schema.World(),nodes:D.Owners()) -> Schema.World() & (D.Owners() & List<&2,U32>):(world,(nodes,[]))
def run_root(root:Scheduled()) -> IO(Scheduled() & Dep.Report<String,String>):
  Root.run(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~D.Owners(),~D.Guards(),~Handler,~String,~String,~Group.run,~guards_dispatch(),~handle,~publish,root)
def run(value:Application()) -> IO(Application() & Report()):
  Feature.run(Scheduled(),Provisions,Dep.Report<String,String>,run_root,value)
