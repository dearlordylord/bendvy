import Base
import ./extended-declarations.bend as Schema
import ./extended-population.bend as Population
import ./extended-save.bend as Save
import ./extended-restore.bend as Restore
import ./extended-admission.bend as Admission
import ./extended-target.bend as Target
import ./extended-machine-history.bend as History
import ./extended-target-history.bend as TargetHistory
import ./extended-scope-setup.bend as ScopeSetup
import ../../src/ecs/execution-lifetime-scope-store.bend as ScopeStore
import ../parallel-machines/declarations.bend as Modes
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/execution-relation-world-publication.bend as Relation
import ../../src/ecs/execution-relation-operation.bend as Operation
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-provider.bend as Provider
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/world.bend as W
import ../../src/ecs/world-io.bend as WorldIO
import ../../src/ecs/change-tick.bend as Tick

type Outcome<-S:Data> is Type:
  SourceRefused{result:WorldIO.Creation<S,Layout.columns(~S,Schema.components(~S)),Schema.Resources(~S),Unit>}
  PopulationRefused{result:Population.Population<S>}
  ScopeRefused{world:Schema.World(~S),previous:Population.Previous(~S),parent:W.Handle<S>,child:W.Handle<S>,receipt:ScopeStore.Assignment<S>}
  RelationRefused{world:Schema.World(~S),previous:Population.Previous(~S),receipt:Store.Receipt<S>}
  SaveRefused{schema:Admission.Recipes(~S),source:Schema.World(~S),previous:Population.Previous(~S),result:Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>}
  TargetRefused{schema:Admission.Recipes(~S),source:Schema.World(~S),previous:Population.Previous(~S),input:Extended.Snapshot<S>,result:WorldIO.Creation<S,Layout.columns(~S,Schema.components(~S)),Schema.Resources(~S),Unit>}
  TargetPopulationRefused{schema:Admission.Recipes(~S),source:Schema.World(~S),previous:Population.Previous(~S),input:Extended.Snapshot<S>,reader:Maybe<&1,Target.Reader(~S)>,result:Population.Population<S>}
  Prepared{source:Schema.World(~S),previous:Population.Previous(~S),reader:Maybe<&1,Target.Reader(~S)>,receipt:Store.Receipt<S>,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,target:Schema.World(~S)}
  Restored{source:Schema.World(~S),previous:Population.Previous(~S),reader:Maybe<&1,Target.Reader(~S)>,receipt:Store.Receipt<S>,result:Restore.Outcome<S>}
def target_prepared(~S:Data,schema:Admission.Recipes(~S),source:Schema.World(~S),previous:Population.Previous(~S),input:Extended.Snapshot<S>,reader:Maybe<&1,Target.Reader(~S)>,result:TargetHistory.Prepared<S>) -> Outcome<S>:
  match result:
    case TargetHistory.Prepared{world,targetPrevious,receipt}:Prepared{source,List.append(&1,Bundle.Payload(Schema.components(~S)),previous,targetPrevious),reader,receipt,schema,input,world}
    case TargetHistory.Refused{result}:TargetPopulationRefused{schema,source,previous,input,reader,result}
def target_registered(~S:Data,schema:Admission.Recipes(~S),source:Schema.World(~S),previous:Population.Previous(~S),input:Extended.Snapshot<S>,result:Schema.World(~S) & Maybe<&1,Target.Reader(~S)>) -> Outcome<S>:
  match result:
    case (world,reader):target_prepared(~S,schema,source,previous,input,reader,TargetHistory.prepare(~S,world))
def target(~S:Data,schema:Admission.Recipes(~S),source:Schema.World(~S),previous:Population.Previous(~S),input:Extended.Snapshot<S>,result:WorldIO.Creation<S,Layout.columns(~S,Schema.components(~S)),Schema.Resources(~S),Unit>) -> Outcome<S>:
  match result:
    case WorldIO.Created{world}:target_registered(~S,schema,source,previous,input,Target.register(~S,History.receiver(~S,world)))
    case other:TargetRefused{schema,source,previous,input,other}
def saved(~S:Data,previous:Population.Previous(~S),result:Admission.Recipes(~S) & (Schema.World(~S) & Gate.Outcome<Extended.Snapshot<S>,Recipe.Refusal>)) -> IO(Outcome<S>):
  match result:
    case (schema,(source,Gate.Saved{input})):IO.bind(WorldIO.Creation<S,Layout.columns(~S,Schema.components(~S)),Schema.Resources(~S),Unit>,Outcome<S>,Schema.create(~S,Modes.Running{},99n),result => IO.pure(Outcome<S>,target(~S,schema,source,previous,input,result)))
    case (schema,(source,result)):IO.pure(Outcome<S>,SaveRefused{schema,source,previous,result})
def related(~S:Data,previous:Population.Previous(~S),result:Schema.World(~S) & (Context.Binding<S,Schema.Resources(~S),Schema.resource_layout(~S),{==},Layout.InLeft{Layout.AtLeaf{}},Schema.hierarchy(~S),{==},{==},{==}> & Store.Receipt<S>)) -> IO(Outcome<S>):
  match result:
    case (world,(_,Store.Applied{_})):saved(~S,previous,Save.save(~S,Schema.schema(~S),History.source(~S,world)))
    case (world,(_,receipt)):IO.pure(Outcome<S>,RelationRefused{world,previous,receipt})
def clocked(~S:Data,+parent:W.Handle<S>,child:W.Handle<S>,previous:Population.Previous(~S),result:Schema.World(~S) & Tick.Tick) -> IO(Outcome<S>):
  match parent result:
    case W.Handle{namespace,key}, (world,tick):related(~S,previous,Relation.apply(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,~Schema.resource_layout(~S),~{==},~Layout.InLeft{Layout.AtLeaf{}},~{==},~Schema.hierarchy(~S),~{==},~{==},~{==},Provider.bind(~S,~Schema.Resources(~S),~Schema.resource_layout(~S),~{==},~Layout.InLeft{Layout.AtLeaf{}},~{==},~Schema.hierarchy(~S),~{==},~{==},~{==},Context.Context{namespace}),world,Operation.Relate{child,W.Handle{namespace,key}},tick))
def scoped(~S:Data,parent:W.Handle<S>,child:W.Handle<S>,previous:Population.Previous(~S),result:Schema.World(~S) & ScopeStore.Assignment<S>) -> IO(Outcome<S>):
  match result:
    case (world,ScopeStore.Assigned{_,_}):clocked(~S,parent,child,previous,W.write_clock(~S,~Layout.columns(~S,Schema.components(~S)),~Schema.Resources(~S),~Unit,world))
    case (world,receipt):IO.pure(Outcome<S>,ScopeRefused{world,previous,parent,child,receipt})
def populated(~S:Data,result:Population.Population<S>) -> IO(Outcome<S>):
  match result:
    case Population.Populated{world,[+parent,child],previous}:scoped(~S,parent,child,previous,ScopeSetup.assign(~S,"working",parent,world))
    case other:IO.pure(Outcome<S>,PopulationRefused{other})
def created(~S:Data,result:WorldIO.Creation<S,Layout.columns(~S,Schema.components(~S)),Schema.Resources(~S),Unit>) -> IO(Outcome<S>):
  match result:
    case WorldIO.Created{world}:populated(~S,Population.source(~S,world))
    case other:IO.pure(Outcome<S>,SourceRefused{other})
def prepare(~S:Data) -> IO(Outcome<S>):IO.bind(WorldIO.Creation<S,Layout.columns(~S,Schema.components(~S)),Schema.Resources(~S),Unit>,Outcome<S>,Schema.create(~S,Modes.Waiting{},3n),result => created(~S,result))
def finish(~S:Data,result:Outcome<S>) -> Outcome<S>:
  match result:
    case Prepared{source,previous,reader,receipt,schema,input,world}:Restored{source,previous,reader,receipt,Restore.restore(~S,schema,input,world)}
    case result:result
def run(~S:Data) -> IO(Outcome<S>):IO.bind(Outcome<S>,Outcome<S>,prepare(~S),result => IO.pure(Outcome<S>,finish(~S,result)))
