import Base
import ./pooled-constructors.bend as Pool
import ./extended-declarations.bend as Schema
import ./extended-admission.bend as Admission
import ./extended-execution.bend as Execution
import ./extended-restore.bend as Restore
import ./extended-target.bend as Target
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-restore-stage.bend as Stage
import ../../src/ecs/execution-restore-receiver.bend as Receiver
import ../../src/ecs/restore-world.bend as Progress
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/persistence-declaration.bend as Decl
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/execution-composer-layout.bend as Layout

def PoolColumns(~S:Data) -> Type:Layout.columns(~S,Schema.components(~S))

type Outcome<-S:Data> is Type:
  Pending{schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Execution.Application(~S),buffers:List<Array<U32>>}
  InputRefused{app:Execution.Application(~S),buffers:List<Array<U32>>,result:Admission.Prepared<S>}
  NamespaceRefused{schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Execution.Application(~S),buffers:List<Array<U32>>}
  ReceiverRefused{schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Execution.Application(~S),buffers:List<Array<U32>>,reason:Receiver.Reason}
  CapacityRefused{schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Execution.Application(~S),buffers:List<Array<U32>>}
  Staged{schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Execution.Application(~S),state:Pool.State(~S)}
  ConstructorRefused{schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Execution.Application(~S),state:Pool.State(~S),error:R.Error<Pool.Error>}
def staged(~S:Data,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Execution.Application(~S),result:Pool.State(~S) & (Saved.Snapshot<S> & Maybe<&2,R.Error<Pool.Error>>)) -> Outcome<S>:
  match result:
    case (state,(_,None{})):Staged{schema,input,app,state}
    case (state,(_,Some{error})):ConstructorRefused{schema,input,app,state,error}
def construct(~S:Data,schema:Admission.Recipes(~S),+input:Extended.Snapshot<S>,app:Execution.Application(~S),buffers:List<Array<U32>>) -> Outcome<S>:
  match schema:
    case Plan.Schema{Product.Owner{Decl.Constructed{+codec},transient},resources}:staged(~S,Plan.Schema{Product.Owner{Decl.Constructed{codec},transient},resources},input,app,Stage.admitted(~S,~Pool.State(~S),~Pool.Error,~Pool.field(~S),~Pool.release(~S),Pool.empty(~S,Decl.Constructed{codec},buffers),Restore.basic(~S,input)))
def room(~S:Data,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,held:Execution.Held<S>,buffers:List<Array<U32>>,result:Schema.World(~S) & Bool) -> Outcome<S>:
  match result:
    case (world,True{}):construct(~S,schema,input,Execution.rejoin(~S,held,world),buffers)
    case (world,False{}):CapacityRefused{schema,input,Execution.rejoin(~S,held,world),buffers}
def receiver(~S:Data,schema:Admission.Recipes(~S),+input:Extended.Snapshot<S>,held:Execution.Held<S>,buffers:List<Array<U32>>,result:Receiver.Prepared<S,Schema.components(~S),Schema.Resources(~S),Unit>) -> Outcome<S>:
  match result:
    case Receiver.Ready{world,_}:room(~S,schema,input,held,buffers,Progress.room(~S,~PoolColumns(~S),~Schema.Resources(~S),~Unit,world,Restore.floor(~S,input),Restore.count(~S,input)))
    case Receiver.Refused{world,reason}:ReceiverRefused{schema,input,Execution.rejoin(~S,held,world),buffers,reason}
def namespaces(~S:Data,schema:Admission.Recipes(~S),+input:Extended.Snapshot<S>,held:Execution.Held<S>,buffers:List<Array<U32>>,result:Schema.World(~S) & Bool) -> Outcome<S>:
  match result:
    case (world,True{}):receiver(~S,schema,input,held,buffers,Receiver.prepare(~S,~Schema.components(~S),~Schema.Resources(~S),~Unit,Restore.count(~S,input),world))
    case (world,False{}):NamespaceRefused{schema,input,Execution.rejoin(~S,held,world),buffers}
def admitted(~S:Data,app:Execution.Application(~S),buffers:List<Array<U32>>,result:Admission.Prepared<S>) -> Outcome<S>:
  match app result:
    case Schedule.Scheduled{App.State{world,owners,guard,handler,stateBindings},plan,appBindings,rules,deferred} Admission.Prepared{schema,input,_,_}:namespaces(~S,schema,input,Execution.Held{owners,guard,handler,stateBindings,plan,appBindings,rules,deferred},buffers,Target.namespaces(~S,world))
    case app result:InputRefused{app,buffers,result}
def checked(~S:Data,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,buffers:List<Array<U32>>,result:Execution.Application(~S) & Bool) -> Outcome<S>:
  match result:
    case (app,True{}):Pending{schema,input,app,buffers}
    case (app,False{}):admitted(~S,app,buffers,Admission.prepare(~S,schema,input))
# Application provisioning is a real resource-limited constructor domain. All
# admission/receiver checks precede allocation; no receiver publication occurs
# until caller inspection of the complete staged result. Refusal releases every
# prior staged Actor through its actual undo, preserving every buffer owner.
def prepare(~S:Data,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Execution.Application(~S),buffers:List<Array<U32>>) -> Outcome<S>:checked(~S,schema,input,buffers,Execution.pending(~S,app))
