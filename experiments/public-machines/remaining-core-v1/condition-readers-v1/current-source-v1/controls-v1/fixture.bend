import Base
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/system.bend as Sys
import ../../../../../../src/ecs/machine.bend as M
import ../../../../../../src/ecs/ordinary-machine-initialization.bend as Init
import ../../../../../../src/ecs/ordinary-machine-declaration.bend as OD
import ../../../../../../src/ecs/ordinary-machine-condition.bend as Changed
import ../../../../../../src/ecs/ordinary-condition-composition.bend as Comp
import ../../../../../../src/ecs/schedule.bend as Sch

type SchemaA is Data: SchemaA{}
type SchemaB is Data: SchemaB{}
type MachineKey<-S:Data> is Data: MachineKey{}
type Resources<S:Data> is Type:
  Resources{state:Init.State<S,MachineKey<S>,U32>,affine:Unit -> Unit}
def take(~S:Data,resources:Resources<S>) -> Resources<S> & Init.State<S,MachineKey<S>,U32>:
  match resources:
    case Resources{+state,affine}:(Resources{state,affine},state)
def put(~S:Data,resources:Resources<S>,state:Init.State<S,MachineKey<S>,U32>) -> Resources<S>:
  match resources:
    case Resources{_,affine}:Resources{state,affine}
def world_type(~S:Data) -> Type:W.World<S,Array<U32>,Resources<S>,String>
def changed_type(~S:Data) -> Type:Changed.Instance<S,MachineKey<S>,U32,Array<U32>,Resources<S>,String,take(~S),put(~S)>
def declaration(~S:Data) -> OD.Declaration<S,MachineKey<S>,U32,Resources<S>,Init.take_slot(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S))>:
  Init.declared(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S),"State",[0,1])
def guard_type(~S:Data) -> Type:Comp.Condition<world_type(~S),changed_type(~S),Comp.changed_run(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S),~Array<U32>,~String)>
def composed_type(~S:Data) -> Type:Comp.Condition<world_type(~S),U32 & changed_type(~S),Comp.and_run(~world_type(~S),~U32,~changed_type(~S),~Comp.current_run(~S,~MachineKey<S>,~U32,~Resources<S>,~Init.take_slot(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S)),~Array<U32>,~String,~U32.is_eq),~Comp.changed_run(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S),~Array<U32>,~String))>
def binding_owner(~S:Data) -> Type:Comp.BoundOwner<(U32 & changed_type(~S))>
def bindings_type(~S:Data) -> Type:Comp.Bindings<world_type(~S),Comp.BoundOwner<(U32 & changed_type(~S))>,Comp.bound_run(~world_type(~S),~(U32 & changed_type(~S)),~Comp.and_run(~world_type(~S),~U32,~changed_type(~S),~Comp.current_run(~S,~MachineKey<S>,~U32,~Resources<S>,~Init.take_slot(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S)),~Array<U32>,~String,~U32.is_eq),~Comp.changed_run(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S),~Array<U32>,~String)))>
def changed(~S:Data,instance:changed_type(~S)) -> guard_type(~S):Comp.state_changed(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S),~Array<U32>,~String,instance)
def composed(~S:Data,instance:changed_type(~S)) -> composed_type(~S):
  Comp.and_then(~world_type(~S),~U32,~changed_type(~S),~Comp.current_run(~S,~MachineKey<S>,~U32,~Resources<S>,~Init.take_slot(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S)),~Array<U32>,~String,~U32.is_eq),~Comp.changed_run(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S),~Array<U32>,~String),Comp.in_state(~S,~MachineKey<S>,~U32,~Resources<S>,~Init.take_slot(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S)),~Array<U32>,~String,~U32.is_eq,~declaration(~S),1),changed(~S,instance))
def bindings(~S:Data,id:U32,instance:changed_type(~S)) -> bindings_type(~S):Comp.bind(~world_type(~S),~(U32 & changed_type(~S)),~Comp.and_run(~world_type(~S),~U32,~changed_type(~S),~Comp.current_run(~S,~MachineKey<S>,~U32,~Resources<S>,~Init.take_slot(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S)),~Array<U32>,~String,~U32.is_eq),~Comp.changed_run(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S),~Array<U32>,~String)),id,composed(~S,instance))
def body(~S:Data,world:world_type(~S),_:Unit) -> Sys.Outcome<world_type(~S),Unit,Unit>:Sys.Succeeded{world,Unit{}}
def registry_type(~S:Data) -> Type:Sys.Registry<S,Array<U32>,Resources<S>,String,Unit,Unit,Unit,body(~S)>
type Gameplay<S:Data> is Type:Gameplay{registry:registry_type(~S),affine:Unit -> Unit}
def dispatched(~S:Data,affine:Unit -> Unit,result:Sys.RunResult<S,Array<U32>,Resources<S>,String,Unit,Unit,Unit,body(~S)>) -> Gameplay<S> & Sys.Outcome<world_type(~S),Unit,Unit>:
  match result:
    case Sys.Completed{registry,outcome}:(Gameplay{registry,affine},outcome)
    case Sys.RegistrationRejected{registry,world,_}:(Gameplay{registry,affine},Sys.Failed{world,Unit{}})
def dispatch(~S:Data,owner:Gameplay<S>,world:world_type(~S),_:U32) -> Gameplay<S> & Sys.Outcome<world_type(~S),Unit,Unit>:
  match owner:
    case Gameplay{registry,affine}:dispatched(~S,affine,Sys.run_tracked(~S,~Array<U32>,~Resources<S>,~String,~Unit,~Unit,~Unit,~body(~S),registry,world,Unit{}))
def result_type(~S:Data) -> Type:Sch.RunResult<S,Array<U32>,Resources<S>,String,Gameplay<S> & bindings_type(~S),Comp.Error<Unit>>
def attached(~S:Data,world:world_type(~S),result:Comp.Attachment<S,Array<U32>,Resources<S>,String,Gameplay<S>,Comp.BoundOwner<(U32 & changed_type(~S))>,Comp.bound_run(~world_type(~S),~(U32 & changed_type(~S)),~Comp.and_run(~world_type(~S),~U32,~changed_type(~S),~Comp.current_run(~S,~MachineKey<S>,~U32,~Resources<S>,~Init.take_slot(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S)),~Array<U32>,~String,~U32.is_eq),~Comp.changed_run(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S),~Array<U32>,~String)))>) -> result_type(~S):
  match result:
    case Comp.Attached{schedule}:Comp.run_schedule(~S,~Array<U32>,~Resources<S>,~String,~Gameplay<S>,~Comp.BoundOwner<(U32 & changed_type(~S))>,~Comp.bound_run(~world_type(~S),~(U32 & changed_type(~S)),~Comp.and_run(~world_type(~S),~U32,~changed_type(~S),~Comp.current_run(~S,~MachineKey<S>,~U32,~Resources<S>,~Init.take_slot(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S)),~Array<U32>,~String,~U32.is_eq),~Comp.changed_run(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S),~Array<U32>,~String))),~Unit,~dispatch(~S),schedule,world)
    case Comp.AttachmentRejected{Sch.Schedule{ns,name,steps,owner},bindings}:Sch.Rejected{Sch.Schedule{ns,name,steps,(owner,bindings)},world}
def namespaced(~S:Data,instance:changed_type(~S),registry:registry_type(~S),affine:Unit -> Unit,+id:U32,observed:world_type(~S) & U32) -> result_type(~S):
  match observed:
    case (world,ns):attached(~S,world,Comp.attach(~S,~Array<U32>,~Resources<S>,~String,~Gameplay<S>,~Comp.BoundOwner<(U32 & changed_type(~S))>,~Comp.bound_run(~world_type(~S),~(U32 & changed_type(~S)),~Comp.and_run(~world_type(~S),~U32,~changed_type(~S),~Comp.current_run(~S,~MachineKey<S>,~U32,~Resources<S>,~Init.take_slot(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S)),~Array<U32>,~String,~U32.is_eq),~Comp.changed_run(~S,~MachineKey<S>,~U32,~Resources<S>,~take(~S),~put(~S),~Array<U32>,~String))),Sch.Schedule{ns,"positive",[Sch.System{id,0}],Gameplay{registry,affine}},bindings(~S,id,instance)))
def identified(~S:Data,world:world_type(~S),instance:changed_type(~S),affine:Unit -> Unit,observed:registry_type(~S) & U32) -> result_type(~S):
  match observed:
    case (registry,id):namespaced(~S,instance,registry,affine,id,W.namespace(~S,~Array<U32>,~Resources<S>,~String,world))
def positive(~S:Data,world:world_type(~S),instance:changed_type(~S),owner:Gameplay<S>) -> result_type(~S):
  match owner:
    case Gameplay{registry,affine}:identified(~S,world,instance,affine,Sys.identity(~S,~Array<U32>,~Resources<S>,~String,~Unit,~Unit,~Unit,~body(~S),registry))
