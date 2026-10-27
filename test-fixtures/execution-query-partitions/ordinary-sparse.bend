import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-program.bend as ResourceProgram
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-generalized-root-application.bend as Application
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import Base
import ./schema.bend as S
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as Store
import ../../src/ecs/execution-command-buffer.bend as Commands
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-reservation-task.bend as Effect

def WC() -> Type:L.columns(~S.SchemaA,S.layout_a())
def HStore() -> Type:Store.Storage<S.SchemaA,S.layout_a()>
def HResources() -> Type:ResourceStore.Storage<S.SchemaA,L.EmptyLayout{}>
def World() -> Type:W.World<S.SchemaA,WC(),Unit,Unit>
def Caps(H:Type) -> Type:Q.GeneralWriter<S.SchemaA,H,S.Position,U32>
def Ops(Permit:Data,H:Type) -> Type:Caps(H)
def any(value:Maybe<&2,U32>) -> Bool:True{}
def selection(~bound:Recipe.Bound,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~HStore(),~HResources(),~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~HStore(),~HResources(),~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~HStore(),~HResources(),~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~HStore(),~HResources(),~H,~B),~query:Build.Query(~S.SchemaA,~WC(),~HStore(),~HResources(),~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~HStore(),~HResources(),~H,~B),book:B) -> B & Ops(Permit,H):
  Build.general_query(~S.SchemaA,~WC(),~HStore(),~HResources(),~S.layout_a(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Sparse{},~{==},~Recipe.WriteRows{},~bound,~Match.Optional{},~any,~H,~B,~query,book)
def program(~bound:Recipe.Bound,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~HResources(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  builder(Ops,selection(~bound,~Permit,~H,~B),book)
def left_program(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~HResources(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  program(~Recipe.With{L.InRight{L.AtLeaf{}}},~Permit,~H,~B,~builder,book)
def right_program(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~HResources(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  program(~Recipe.Without{L.InRight{L.AtLeaf{}}},~Permit,~H,~B,~builder,book)
type Token is Type:
  Token{array:Array<U32>}
  DeferredToken{transform:S.Position -> S.Position & Array<U32>}
type Local is Type:
  Local{target:W.Handle<S.SchemaA>,token:Token,queue:Commands.Buffer<S.SchemaA,S.Position,Unit>}
def moved(token:Array<U32>,owner:S.Position) -> S.Position & Array<U32>:
  match owner:
    case S.Position{values}:(S.Position{Array.set(U32,values,0,999)},token)
def completed(fail:Bool,lookup:Q.GeneralLookup<U32>) -> Sys.Completion<String,Q.GeneralLookup<U32>>:
  match fail:
    case False{}:Sys.Success{lookup}
    case True{}:Sys.BodyError{"retained-body-error",lookup}
def observed(~fail:Bool,~H:Type,local:Local,result:H & Q.GeneralLookup<U32>) -> H & (Local & Sys.Completion<String,Q.GeneralLookup<U32>>):
  match result:
    case (scope,lookup):(scope,(local,completed(fail,lookup)))
def edited(~fail:Bool,~H:Type,get:H -> W.Handle<S.SchemaA> -> H & Q.GeneralLookup<U32>,+target:W.Handle<S.SchemaA>,queue:Commands.Buffer<S.SchemaA,S.Position,Unit>,result:H & Q.GeneralEdit<S.Position,Array<U32>>) -> H & (Local & Sys.Completion<String,Q.GeneralLookup<U32>>):
  match result:
    case (scope,Q.GeneralEdited{token}):observed(~fail,~H,Local{target,Token{token},queue},get(scope,target))
    case (scope,Q.GeneralUnchanged{unused}):observed(~fail,~H,Local{target,DeferredToken{unused},queue},get(scope,target))
def run_caps(~fail:Bool,~H:Type,caps:Caps(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,Q.GeneralLookup<U32>>):
  match caps local:
    case Q.GeneralWriter{Q.GeneralReader{_,get},modify} Local{+target,Token{token},queue}:edited(~fail,~H,get,target,queue,modify(Array<U32>,scope,target,owner=>moved(token,owner)))
    case _ local:(scope,(local,Sys.BodyError{"unavailable-or-deferred",Q.LookupRefused{}}))
def body(~fail:Bool,~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Local) -> Effect.Task<S.SchemaA,Permit,H & (Local & Sys.Completion<String,Q.GeneralLookup<U32>>)>:
  Effect.TDone{run_caps(~fail,~H,caps,scope,local)}
def left_body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Local) -> Effect.Task<S.SchemaA,Permit,H & (Local & Sys.Completion<String,Q.GeneralLookup<U32>>)>:body(~True{},~Permit,~H,~caps,scope,local)
def right_body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Local) -> Effect.Task<S.SchemaA,Permit,H & (Local & Sys.Completion<String,Q.GeneralLookup<U32>>)>:body(~False{},~Permit,~H,~caps,scope,local)
def LeftOwner() -> Type:Sys.Owner<S.SchemaA,WC(),HStore(),HResources(),Unit,Ops,Local,String,Q.GeneralLookup<U32>,left_program,left_body>
def RightOwner() -> Type:Sys.Owner<S.SchemaA,WC(),HStore(),HResources(),Unit,Ops,Local,String,Q.GeneralLookup<U32>,right_program,right_body>
def Compilation() -> Type:D.Compilation<S.SchemaA,WC(),HStore(),HResources(),Ops>
def left_compiled() -> Compilation():ResourceProgram.compile_framework(~S.SchemaA,~WC(),~HStore(),~HResources(),~Ops,~left_program)
def right_compiled() -> Compilation():ResourceProgram.compile_framework(~S.SchemaA,~WC(),~HStore(),~HResources(),~Ops,~right_program)
def LeftNode() -> Type:Leaf.node_type(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~Q.GeneralLookup<U32>,~Ops,~Local,~left_program,~left_body)
def RightNode() -> Type:Leaf.node_type(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~Q.GeneralLookup<U32>,~Ops,~Local,~right_program,~right_body)
def Nodes() -> Type:Product.Owner<LeftNode(),RightNode()>
def RegisteredLeft() -> Type:Scope.CompiledBinding<Compilation(),LeftOwner()>
def RegisteredRight() -> Type:Scope.CompiledBinding<Compilation(),RightOwner()>
def Scheduled() -> Type:Root.Scheduled<App.State<Application.Storage<S.SchemaA,S.layout_a(),L.EmptyLayout{},Unit>,Nodes(),Unit,U32>>
type WorldResult is Type:
  WorldReturned{storage:Application.Storage<S.SchemaA,S.layout_a(),L.EmptyLayout{},Unit>,nodes:Nodes(),handler:U32,report:App.Report<String,Q.GeneralLookup<U32>>}
  TargetsRefused{world:World()}
  LeftDefinitionRefused{world:World(),compilation:Compilation(),left:Local,right:Local}
  RightDefinitionRefused{world:World(),left:RegisteredLeft(),compilation:Compilation(),right:Local}
def dispatch(nodes:Nodes(),world:World(),ids:List<&2,U32>) -> IO(Execution.RunResult<S.SchemaA,S.layout_a(),L.EmptyLayout{},Unit,Nodes(),String,Q.GeneralLookup<U32>>):
  match nodes:
    case Product.Owner{left,right}:Tree.run_generalized(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~Q.GeneralLookup<U32>,LeftNode(),RightNode(),ids,world,Tree.GeneralizedPair{Tree.compile_retained_generalized_leaf(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~Q.GeneralLookup<U32>,~Ops,~Local,~left_program,~left_body,~left_compiled(),left),Tree.compile_retained_generalized_leaf(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~Q.GeneralLookup<U32>,~Ops,~Local,~right_program,~right_body,~right_compiled(),right)})
def publish(_:List<&2,U32>,world:World(),nodes:Nodes()) -> World() & (Nodes() & List<&2,U32>):(world,(nodes,[]))
def handle(count:U32,_:String) -> U32 & Exec.Handling:(U32.add(count,1),Exec.Continue{})
def available(_:String) -> Bool:True{}
def finished(result:Scheduled() & App.Report<String,Q.GeneralLookup<U32>>) -> WorldResult:
  match result:
    case (Root.Scheduled{App.State{storage,nodes,Unit{},handler,_},_,_,_,_},report):WorldReturned{storage,nodes,handler,report}
def registered(world:World(),left:RegisteredLeft(),right:RegisteredRight()) -> IO(WorldResult):
  IO.bind(Scheduled() & App.Report<String,Q.GeneralLookup<U32>>,WorldResult,Application.run(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~Nodes(),~Unit,~U32,~String,~Q.GeneralLookup<U32>,~dispatch,~Conditions.empty_dispatch(~World(),~String),~handle,~publish,Application.build(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~Nodes(),~Unit,~U32,~String,~Conditions.empty_dispatch(~World(),~String),~available,world,Tree.generalized_pair_facts(LeftNode(),RightNode(),Tree.generalized_leaf_facts(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~Q.GeneralLookup<U32>,~Ops,~Local,~left_program,~left_body,left),Tree.generalized_leaf_facts(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~Q.GeneralLookup<U32>,~Ops,~Local,~right_program,~right_body,right)),Conditions.compile_empty(~String,~World()),0,[],[])),value=>IO.pure(WorldResult,finished(value)))
def right_defined(left:RegisteredLeft(),result:Compilation() & Sys.Defined<World(),RightOwner(),Local>) -> IO(WorldResult):
  match result:
    case (compilation,Sys.Defined{world,owner}):registered(world,left,Scope.CompiledBinding{compilation,owner})
    case (compilation,Sys.DefinitionRefused{world,local}):IO.pure(WorldResult,RightDefinitionRefused{world,left,compilation,local})
def left_defined(right:Local,result:Compilation() & Sys.Defined<World(),LeftOwner(),Local>) -> IO(WorldResult):
  match result:
    case (compilation,Sys.Defined{world,owner}):right_defined(Scope.CompiledBinding{compilation,owner},Task.define_with_compilation(~S.SchemaA,~WC(),~HStore(),~HResources(),~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~right_program,~right_body,~Unit,right_compiled(),world,"general-right",right))
    case (compilation,Sys.DefinitionRefused{world,local}):IO.pure(WorldResult,LeftDefinitionRefused{world,compilation,local,right})
def seeded_columns(_:Unit) -> WC():S.full_a()
def reserved(result:W.World<S.SchemaA,WC(),Unit,Unit> & W.Reservation<S.SchemaA>) -> W.World<S.SchemaA,WC(),Unit,Unit>:
  match result:
    case (world,W.Reserved{handle}):W.discard_status(~S.SchemaA,~WC(),~Unit,~Unit,W.activate(~S.SchemaA,~WC(),~Unit,~Unit,world,handle))
    case (world,W.ReservationRejected{_}):world
def live(fuel:Nat,world:W.World<S.SchemaA,WC(),Unit,Unit>) -> W.World<S.SchemaA,WC(),Unit,Unit>:
  match fuel:
    case 0n:world
    case 1n+rest:live(rest,reserved(W.reserve_id(~S.SchemaA,~WC(),~Unit,~Unit,world)))
type Seeded is Type:
  Seeded{factory:W.Factory,world:W.World<S.SchemaA,WC(),Unit,Unit>}
  SeedRefused{factory:W.Factory,resource:Unit}
def created(result:W.Creation<S.SchemaA,WC(),Unit,Unit>) -> Seeded:
  match result:
    case W.Created{factory,world}:Seeded{factory,live(20n,world)}
    case W.CreateRejected{factory,resource}:SeedRefused{factory,resource}
def seeded(factory:W.Factory) -> Seeded:
  created(W.create(~S.SchemaA,~WC(),~Unit,~Unit,~seeded_columns,factory,Unit{}))
def target_local(+handle:W.Handle<S.SchemaA>,+token:U32) -> Local:
  Local{handle,Token{[token : U32^1n]},Commands.insert(~S.SchemaA,~S.Position,~Unit,Commands.empty(~S.SchemaA,~S.Position,~Unit),handle,S.Position{[U32.add(token,100) : U32^1n]})}
def chosen(handle:W.Handle<S.SchemaA>,rest:Maybe<&2,W.Handle<S.SchemaA>>,selected:Bool) -> Maybe<&2,W.Handle<S.SchemaA>>:
  match selected:
    case False{}:rest
    case True{}:Some{handle}
def choose(+key:U32,handles:List<&2,W.Handle<S.SchemaA>>) -> Maybe<&2,W.Handle<S.SchemaA>>:
  match handles:
    case []:None{}
    case +handle <> rest:chosen(handle,choose(key,rest),U32.is_eq(key,W.handle_index(~S.SchemaA,handle)))
def targets(world:World(),left:Maybe<&2,W.Handle<S.SchemaA>>,right:Maybe<&2,W.Handle<S.SchemaA>>) -> IO(WorldResult):
  match left right:
    case Some{lh} Some{rh}:left_defined(target_local(rh,202),Task.define_with_compilation(~S.SchemaA,~WC(),~HStore(),~HResources(),~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~left_program,~left_body,~Unit,left_compiled(),world,"general-left",target_local(lh,101)))
    case _ _:IO.pure(WorldResult,TargetsRefused{world})
def captured(result:W.World<S.SchemaA,WC(),Unit,Unit> & List<&2,W.Handle<S.SchemaA>>) -> IO(WorldResult):
  match result:
    case (world,+handles):targets(world,choose(1,handles),choose(20,handles))
def run_world(world:W.World<S.SchemaA,WC(),Unit,Unit>) -> IO(WorldResult):
  captured(W.handles(~S.SchemaA,~WC(),~Unit,~Unit,world))
type SeedRun is Type:
  SeedRun{factory:W.Factory,result:WorldResult}
  SeedRunRefused{factory:W.Factory,resource:Unit}
def run_seeded(result:Seeded) -> IO(SeedRun):
  match result:
    case Seeded{factory,world}:IO.bind(WorldResult,SeedRun,run_world(world),result => IO.pure(SeedRun,SeedRun{factory,result}))
    case SeedRefused{factory,resource}:IO.pure(SeedRun,SeedRunRefused{factory,resource})
def run(factory:W.Factory) -> IO(SeedRun):
  run_seeded(seeded(factory))
type TargetMode is Data:
  Target{key:U32}
  ForeignTarget{}
  StaleTarget{}
  ZeroTarget{}
  OutsideTarget{}
def changed_target(value:Maybe<&2,W.Handle<S.SchemaA>>,mode:TargetMode) -> Maybe<&2,W.Handle<S.SchemaA>>:
  match value mode:
    case None{} _:None{}
    case Some{W.Handle{namespace,Key.EntityKey{key,generation}}} ForeignTarget{}:Some{W.Handle{U32.add(namespace,1),Key.EntityKey{key,generation}}}
    case Some{W.Handle{namespace,Key.EntityKey{key,generation}}} StaleTarget{}:Some{W.Handle{namespace,Key.EntityKey{key,U32.add(generation,1)}}}
    case Some{W.Handle{namespace,Key.EntityKey{_,generation}}} ZeroTarget{}:Some{W.Handle{namespace,Key.EntityKey{0,generation}}}
    case Some{W.Handle{namespace,Key.EntityKey{_,generation}}} OutsideTarget{}:Some{W.Handle{namespace,Key.EntityKey{131073,generation}}}
    case value _:value
def requested(+mode:TargetMode,handles:List<&2,W.Handle<S.SchemaA>>) -> Maybe<&2,W.Handle<S.SchemaA>>:
  match mode:
    case Target{key}:choose(key,handles)
    case mode:changed_target(choose(20,handles),mode)
def captured_mode(mode:TargetMode,result:W.World<S.SchemaA,WC(),Unit,Unit> & List<&2,W.Handle<S.SchemaA>>) -> IO(WorldResult):
  match result:
    case (world,+handles):targets(world,choose(1,handles),requested(mode,handles))
def run_world_mode(world:W.World<S.SchemaA,WC(),Unit,Unit>,mode:TargetMode) -> IO(WorldResult):
  captured_mode(mode,W.handles(~S.SchemaA,~WC(),~Unit,~Unit,world))
def run_seeded_mode(mode:TargetMode,result:Seeded) -> IO(SeedRun):
  match result:
    case Seeded{factory,world}:IO.bind(WorldResult,SeedRun,run_world_mode(world,mode),result => IO.pure(SeedRun,SeedRun{factory,result}))
    case SeedRefused{factory,resource}:IO.pure(SeedRun,SeedRunRefused{factory,resource})
def run_mode(factory:W.Factory,mode:TargetMode) -> IO(SeedRun):
  run_seeded_mode(mode,seeded(factory))
