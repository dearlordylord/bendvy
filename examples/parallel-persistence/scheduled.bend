import Base
import ./declarations.bend as Ordinary
import ./receiver.bend as Receiver
import ./restore.bend as Restore
import ./restore-receipt.bend as Receipt
import ./staging.bend as Stage
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-parallel-registration.bend as Part
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-plan.bend as Build
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product

def Application(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type) -> Type:Schedule.Scheduled<App.State<Receiver.World(~S),Owners,Guards,Handler>>
type Held<-Owners:Type,-Guards:Type,-Handler:Type> is Type:
  Held{owners:Owners,guards:Guards,handler:Handler,stateBindings:List<&2,App.Binding>,plan:Build.Build<String>,appBindings:List<&2,App.Binding>,rules:Part.Rules,deferred:Schedule.Deferred}
def rejoin(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,held:Held<Owners,Guards,Handler>,world:Receiver.World(~S)) -> Application(~S,~Owners,~Guards,~Handler):
  match held:
    case Held{owners,guards,handler,stateBindings,plan,appBindings,rules,deferred}:Schedule.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,appBindings,rules,deferred}
def saved(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,held:Held<Owners,Guards,Handler>,result:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Receiver.World(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Application(~S,~Owners,~Guards,~Handler) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  match result:
    case (schema,(world,outcome)):(schema,(rejoin(~S,~Owners,~Guards,~Handler,held,world),outcome))
def save_checked(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,result:Application(~S,~Owners,~Guards,~Handler) & Bool) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Application(~S,~Owners,~Guards,~Handler) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  match result:
    case (app,True{}):(schema,(app,Gate.RefusedPending{}))
    case (Schedule.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,appBindings,rules,deferred},False{}):saved(~S,~Owners,~Guards,~Handler,Held{owners,guards,handler,stateBindings,plan,appBindings,rules,deferred},Save.save(~S,~Ordinary.components(~S),~Ordinary.resources(~S),~Unit,schema,world))
def restored(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,held:Held<Owners,Guards,Handler>,result:Receiver.World(~S) & Receipt.Receipt<S>) -> Application(~S,~Owners,~Guards,~Handler) & Receipt.Receipt<S>:
  match result:
    case (world,receipt):(rejoin(~S,~Owners,~Guards,~Handler,held,world),receipt)
def restore_checked(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,input:Saved.Snapshot<S>,result:Application(~S,~Owners,~Guards,~Handler) & Bool) -> Application(~S,~Owners,~Guards,~Handler) & Receipt.Receipt<S>:
  match result:
    case (app,True{}):(app,Receipt.Receipt{Stage.empty(~S,schema),input,[],[],[],[],None{},[],Receipt.Pending{}})
    case (Schedule.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,appBindings,rules,deferred},False{}):restored(~S,~Owners,~Guards,~Handler,Held{owners,guards,handler,stateBindings,plan,appBindings,rules,deferred},Receipt.extract(~S,Restore.restore(~S,schema,input,world)))
def LeftColumn(~S:Data) -> Type:Layout.columns(~S,Layout.subtree(Receiver.Components(~S),Layout.InLeft{Layout.AtLeaf{}}))
def RightColumn(~S:Data) -> Type:Layout.columns(~S,Layout.subtree(Receiver.Components(~S),Layout.InRight{Layout.AtLeaf{}}))
def LeftResource(~S:Data) -> Type:Layout.resources(~S,Layout.subtree(Plan.layout(Ordinary.resources(~S)),Layout.InLeft{Layout.AtLeaf{}}))
def RightResource(~S:Data) -> Type:Layout.resources(~S,Layout.subtree(Plan.layout(Ordinary.resources(~S)),Layout.InRight{Layout.AtLeaf{}}))
# The trusted adapter binds the canonical fold over the actual compiled command
# owners. It never derives pending status from run history or a caller catalog.
def pending(~S:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Layout.columns(~S,Receiver.Components(~S)),~LeftColumn(~S),~LeftResource(~S),~Unit,~Plan.layout(Ordinary.resources(~S)),~String,~String,~L),~right:Tree.Selection(~S,~Layout.columns(~S,Receiver.Components(~S)),~RightColumn(~S),~RightResource(~S),~Unit,~Plan.layout(Ordinary.resources(~S)),~String,~String,~R),~Guards:Type,~Handler:Type,~guardDispatch:Guards -> Receiver.World(~S) -> U32 -> IO(Guards & (Receiver.World(~S) & Exec.Invocation<String,Bool>)),~guardSelection:Conditions.Selection(~Receiver.World(~S),~Guards,~String,~guardDispatch),~handle:Handler -> String -> Handler & Exec.Handling,app:Application(~S,~Product.Owner<L,R>,~Guards,~Handler)) -> Application(~S,~Product.Owner<L,R>,~Guards,~Handler) & Bool:
  Schedule.pending(~S,~LeftColumn(~S),~RightColumn(~S),~LeftResource(~S),~RightResource(~S),~Unit,~Plan.layout(Ordinary.resources(~S)),~{==},~String,~String,~L,~R,~left,~right,~Guards,~Handler,~guardDispatch,~guardSelection,~handle,app)
def save(~S:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Layout.columns(~S,Receiver.Components(~S)),~LeftColumn(~S),~LeftResource(~S),~Unit,~Plan.layout(Ordinary.resources(~S)),~String,~String,~L),~right:Tree.Selection(~S,~Layout.columns(~S,Receiver.Components(~S)),~RightColumn(~S),~RightResource(~S),~Unit,~Plan.layout(Ordinary.resources(~S)),~String,~String,~R),~Guards:Type,~Handler:Type,~guardDispatch:Guards -> Receiver.World(~S) -> U32 -> IO(Guards & (Receiver.World(~S) & Exec.Invocation<String,Bool>)),~guardSelection:Conditions.Selection(~Receiver.World(~S),~Guards,~String,~guardDispatch),~handle:Handler -> String -> Handler & Exec.Handling,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,app:Application(~S,~Product.Owner<L,R>,~Guards,~Handler)) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Application(~S,~Product.Owner<L,R>,~Guards,~Handler) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  save_checked(~S,~Product.Owner<L,R>,~Guards,~Handler,schema,pending(~S,~L,~R,~left,~right,~Guards,~Handler,~guardDispatch,~guardSelection,~handle,app))
def restore(~S:Data,~L:Type,~R:Type,~left:Tree.Selection(~S,~Layout.columns(~S,Receiver.Components(~S)),~LeftColumn(~S),~LeftResource(~S),~Unit,~Plan.layout(Ordinary.resources(~S)),~String,~String,~L),~right:Tree.Selection(~S,~Layout.columns(~S,Receiver.Components(~S)),~RightColumn(~S),~RightResource(~S),~Unit,~Plan.layout(Ordinary.resources(~S)),~String,~String,~R),~Guards:Type,~Handler:Type,~guardDispatch:Guards -> Receiver.World(~S) -> U32 -> IO(Guards & (Receiver.World(~S) & Exec.Invocation<String,Bool>)),~guardSelection:Conditions.Selection(~Receiver.World(~S),~Guards,~String,~guardDispatch),~handle:Handler -> String -> Handler & Exec.Handling,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,input:Saved.Snapshot<S>,app:Application(~S,~Product.Owner<L,R>,~Guards,~Handler)) -> Application(~S,~Product.Owner<L,R>,~Guards,~Handler) & Receipt.Receipt<S>:
  restore_checked(~S,~Product.Owner<L,R>,~Guards,~Handler,schema,input,pending(~S,~L,~R,~left,~right,~Guards,~Handler,~guardDispatch,~guardSelection,~handle,app))
