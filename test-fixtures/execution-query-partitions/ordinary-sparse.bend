import Base
import ./schema.bend as S
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as Store
import ../../src/ecs/execution-query-interpreter.bend as Interpret
import ../../src/ecs/execution-query-preparation.bend as General
import ../../src/ecs/execution-query-partition.bend as Partition
import ../../src/ecs/execution-command-buffer.bend as Commands
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-state.bend as State
import ../../src/ecs/execution-parallel-schedule.bend as Ready
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-query-schema.bend as Schema
import ../../src/ecs/execution-prepared.bend as Prep

def WC() -> Type:L.columns(~S.SchemaA,S.layout_a())
def HStore() -> Type:Store.Storage<S.SchemaA,S.layout_a()>
def Ops(H:Type) -> Type:Q.GeneralWriter<S.SchemaA,H,S.Position,U32>
def any(value:Maybe<&2,U32>) -> Bool:True{}
def selection(~bound:Recipe.Bound,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~HStore(),~Unit,~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~HStore(),~Unit,~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~HStore(),~Unit,~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~HStore(),~Unit,~H,~B),~query:Build.Query(~S.SchemaA,~WC(),~HStore(),~Unit,~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~HStore(),~Unit,~H,~B),book:B) -> B & Ops(H):
  Build.general_query(~S.SchemaA,~WC(),~HStore(),~Unit,~S.layout_a(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Sparse{},~{==},~Recipe.WriteRows{},~bound,~Match.Optional{},~any,~H,~B,~query,book)
def program(~bound:Recipe.Bound,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~Unit,~H,~B),book:B) -> B & Ops(H):
  builder(Ops,selection(~bound,~H,~B),book)
def left_program(~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~Unit,~H,~B),book:B) -> B & Ops(H):
  program(~Recipe.With{L.InRight{L.AtLeaf{}}},~H,~B,~builder,book)
def right_program(~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~Unit,~H,~B),book:B) -> B & Ops(H):
  program(~Recipe.Without{L.InRight{L.AtLeaf{}}},~H,~B,~builder,book)
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
def run_caps(~fail:Bool,~H:Type,caps:Ops(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,Q.GeneralLookup<U32>>):
  match caps local:
    case Q.GeneralWriter{Q.GeneralReader{_,get},modify} Local{+target,Token{token},queue}:edited(~fail,~H,get,target,queue,modify(Array<U32>,scope,target,owner=>moved(token,owner)))
    case _ local:(scope,(local,Sys.BodyError{"unavailable-or-deferred",Q.LookupRefused{}}))
def body(~fail:Bool,~H:Type,~caps:Ops(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,Q.GeneralLookup<U32>>):
  run_caps(~fail,~H,caps,scope,local)
def left_body(~H:Type,~caps:Ops(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,Q.GeneralLookup<U32>>):body(~True{},~H,~caps,scope,local)
def right_body(~H:Type,~caps:Ops(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,Q.GeneralLookup<U32>>):body(~False{},~H,~caps,scope,local)
def LeftOwner() -> Type:Sys.Owner<S.SchemaA,WC(),HStore(),Unit,Unit,Ops,Local,String,Q.GeneralLookup<U32>,left_program,left_body>
def RightOwner() -> Type:Sys.Owner<S.SchemaA,WC(),HStore(),Unit,Unit,Ops,Local,String,Q.GeneralLookup<U32>,right_program,right_body>
def LeftEvidence() -> Data:General.Evidence<S.SchemaA,S.layout_a(),HStore(),Unit,Ops,left_program>
def RightEvidence() -> Data:General.Evidence<S.SchemaA,S.layout_a(),HStore(),Unit,Ops,right_program>
def LeftBinding() -> Type:General.Binding<W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),LeftEvidence(),S.SchemaA,WC()>
def RightBinding() -> Type:General.Binding<W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),RightEvidence(),S.SchemaA,WC()>
def define_left(world:W.World<S.SchemaA,WC(),Unit,Unit>,local:Local) -> Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),Local>:
  General.define(~S.SchemaA,~S.layout_a(),~HStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~left_program,~left_body,world,"general-left",local)
def define_right(world:W.World<S.SchemaA,WC(),Unit,Unit>,local:Local) -> Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),Local>:
  General.define(~S.SchemaA,~S.layout_a(),~HStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~right_program,~right_body,world,"general-right",local)
def prepare_left(ids:List<&2,U32>,world:W.World<S.SchemaA,WC(),Unit,Unit>,owner:LeftOwner()) -> General.Preparation<W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),LeftEvidence(),S.SchemaA,WC()>:
  General.prepare(~S.SchemaA,~S.layout_a(),~HStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~left_program,~left_body,ids,world,owner)
def LeftInvocation() -> Type:General.Invocation<State.Scope<S.SchemaA,HStore(),Unit>,W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),LeftEvidence(),S.SchemaA,WC(),List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>>
def invoke_left(scope:State.Scope<S.SchemaA,HStore(),Unit>,binding:LeftBinding()) -> LeftInvocation():
  General.invoke_sparse(~S.SchemaA,~S.layout_a(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~left_program,~left_body,scope,binding)
def prepare_right(ids:List<&2,U32>,world:W.World<S.SchemaA,WC(),Unit,Unit>,owner:RightOwner()) -> General.Preparation<W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),RightEvidence(),S.SchemaA,WC()>:
  General.prepare(~S.SchemaA,~S.layout_a(),~HStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~right_program,~right_body,ids,world,owner)
def RightInvocation() -> Type:General.Invocation<State.Scope<S.SchemaA,HStore(),Unit>,W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),RightEvidence(),S.SchemaA,WC(),List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>>
def invoke_right(scope:State.Scope<S.SchemaA,HStore(),Unit>,binding:RightBinding()) -> RightInvocation():
  General.invoke_sparse(~S.SchemaA,~S.layout_a(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~right_program,~right_body,scope,binding)
type Partitioned is Type:
  Partitioned{partition:Partition.Split<S.SchemaA,S.layout_a()>,left:LeftBinding(),right:RightBinding()}
def split(scope:State.Scope<S.SchemaA,WC(),Unit>,left:LeftBinding(),right:RightBinding()) -> Partitioned:
  match left right:
    case General.Binding{lp,+le} General.Binding{rp,+re}:Partitioned{Partition.split(~S.SchemaA,~S.layout_a(),~Ops,~Ops,~left_program,~right_program,scope,le,re),General.Binding{lp,le},General.Binding{rp,re}}
type Invoked is Type:
  Invoked{left:LeftInvocation(),right:RightInvocation(),join:Partition.Join<S.SchemaA,S.layout_a()>}
def invoke_pair(left:State.Scope<S.SchemaA,HStore(),Unit>,right:State.Scope<S.SchemaA,HStore(),Unit>,join:Partition.Join<S.SchemaA,S.layout_a()>,lp:LeftBinding(),rp:RightBinding()) -> Invoked:
  l r = invoke_left(left,lp) invoke_right(right,rp)
  Invoked{l,r,join}
type Finished is Type:
  Finished{joined:Partition.Joined<S.SchemaA,S.layout_a()>,left:LeftBinding(),right:RightBinding(),leftStatus:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>,rightStatus:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>}
  InventoryRefused{left:LeftInvocation(),right:RightInvocation(),join:Partition.Join<S.SchemaA,S.layout_a()>}
def finish_returned(left:State.Scope<S.SchemaA,HStore(),Unit>,right:State.Scope<S.SchemaA,HStore(),Unit>,join:Partition.Join<S.SchemaA,S.layout_a()>,lp:LeftBinding(),rp:RightBinding(),ls:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>,rs:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>) -> Finished:
  Finished{Partition.join(~S.SchemaA,~S.layout_a(),left,right,join),lp,rp,ls,rs}
def finish(left:LeftInvocation(),right:RightInvocation(),join:Partition.Join<S.SchemaA,S.layout_a()>) -> Finished:
  match left right:
    case General.Invoked{left,lp,ls} General.Invoked{right,rp,rs}:finish_returned(left,right,join,lp,rp,ls,rs)
    case General.Invoked{left,lp,ls} General.InvocationRefused{right,rp,rs}:finish_returned(left,right,join,lp,rp,ls,rs)
    case General.InvocationRefused{left,lp,ls} General.Invoked{right,rp,rs}:finish_returned(left,right,join,lp,rp,ls,rs)
    case General.InvocationRefused{left,lp,ls} General.InvocationRefused{right,rp,rs}:finish_returned(left,right,join,lp,rp,ls,rs)
    case left right:InventoryRefused{left,right,join}
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
type Pipeline is Type:
  TargetsRefused{world:W.World<S.SchemaA,WC(),Unit,Unit>}
  LeftDefinitionRefused{world:W.World<S.SchemaA,WC(),Unit,Unit>,left:Local,right:Local}
  RightDefinitionRefused{world:W.World<S.SchemaA,WC(),Unit,Unit>,left:LeftOwner(),right:Local}
  LeftPreparationRefused{world:W.World<S.SchemaA,WC(),Unit,Unit>,left:LeftOwner(),right:RightOwner()}
  RightPreparationRefused{world:W.World<S.SchemaA,WC(),Unit,Unit>,left:LeftBinding(),right:RightOwner()}
  GroupPartitionRefused{admin:State.Administration<S.SchemaA,WC(),Unit,Unit>,partition:Partitioned}
  GroupReturned{admin:State.Administration<S.SchemaA,WC(),Unit,Unit>,finished:Finished}
def pair_returned(admin:State.Administration<S.SchemaA,WC(),Unit,Unit>,result:Invoked) -> Pipeline:
  match result:
    case Invoked{left,right,join}:GroupReturned{admin,finish(left,right,join)}
def partition_returned(admin:State.Administration<S.SchemaA,WC(),Unit,Unit>,result:Partitioned) -> Pipeline:
  match result:
    case Partitioned{Partition.Split{left,right,join},lp,rp}:pair_returned(admin,invoke_pair(left,right,join,lp,rp))
    case partition:GroupPartitionRefused{admin,partition}
def separated(lp:LeftBinding(),rp:RightBinding(),result:State.Administration<S.SchemaA,WC(),Unit,Unit> & State.Scope<S.SchemaA,WC(),Unit>) -> Pipeline:
  match result:
    case (admin,scope):partition_returned(admin,split(scope,lp,rp))
def clocked(lp:LeftBinding(),rp:RightBinding(),result:W.World<S.SchemaA,WC(),Unit,Unit> & Tick.Tick) -> Pipeline:
  match result:
    case (world,tick):separated(lp,rp,State.separate(~S.SchemaA,~WC(),~Unit,~Unit,world,tick))
def right_prepared(lp:LeftBinding(),result:General.Preparation<W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),RightEvidence(),S.SchemaA,WC()>) -> Pipeline:
  match result:
    case General.PreparationRefused{world,right}:RightPreparationRefused{world,lp,right}
    case General.Prepared{world,rp}:clocked(lp,rp,W.execution_clock(~S.SchemaA,~WC(),~Unit,~Unit,world))
def left_prepared(+ids:List<&2,U32>,right:RightOwner(),result:General.Preparation<W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),LeftEvidence(),S.SchemaA,WC()>) -> Pipeline:
  match result:
    case General.PreparationRefused{world,left}:LeftPreparationRefused{world,left,right}
    case General.Prepared{world,lp}:right_prepared(lp,prepare_right(ids,world,right))
def right_defined(left:LeftOwner(),result:Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),Local>) -> Pipeline:
  match left result:
    case left Sys.DefinitionRefused{world,right}:RightDefinitionRefused{world,left,right}
    case Sys.Owner{ln,+lid,lt,la,lc,ll} Sys.Defined{world,Sys.Owner{rn,+rid,rt,ra,rc,rl}}:left_prepared([lid,rid],Sys.Owner{rn,rid,rt,ra,rc,rl},prepare_left([lid,rid],world,Sys.Owner{ln,lid,lt,la,lc,ll}))
def left_defined(right:Local,result:Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),Local>) -> Pipeline:
  match result:
    case Sys.DefinitionRefused{world,left}:LeftDefinitionRefused{world,left,right}
    case Sys.Defined{world,left}:right_defined(left,define_right(world,right))
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
def targets(world:W.World<S.SchemaA,WC(),Unit,Unit>,left:Maybe<&2,W.Handle<S.SchemaA>>,right:Maybe<&2,W.Handle<S.SchemaA>>) -> Pipeline:
  match left right:
    case Some{lh} Some{rh}:left_defined(target_local(rh,202),define_left(world,target_local(lh,101)))
    case _ _:TargetsRefused{world}
def captured(result:W.World<S.SchemaA,WC(),Unit,Unit> & List<&2,W.Handle<S.SchemaA>>) -> Pipeline:
  match result:
    case (world,+handles):targets(world,choose(1,handles),choose(20,handles))
def run_world(world:W.World<S.SchemaA,WC(),Unit,Unit>) -> Pipeline:
  captured(W.handles(~S.SchemaA,~WC(),~Unit,~Unit,world))
type WorldResult is Type:
  WorldReturned{world:W.World<S.SchemaA,WC(),Unit,Unit>,displaced:Schema.displacements(~S.SchemaA,S.layout_a()),left:LeftBinding(),right:RightBinding(),leftStatus:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>,rightStatus:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>}
  Unreassembled{pipeline:Pipeline}
def entered(permits:List<&2,Prep.Permit<S.SchemaA,WC()>>) -> Bool:
  match permits:
    case []:False{}
    case Prep.Permit{_,_,allowed,_} <> rest:Bool.or(allowed,entered(rest))
def exited(world:W.World<S.SchemaA,WC(),Unit,Unit>,displaced:Schema.displacements(~S.SchemaA,S.layout_a()),left:LeftBinding(),right:RightBinding(),ls:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>,rs:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>) -> WorldResult:
  match left right:
    case General.Binding{Prep.Prepared{ln,left,+lp,lt},le} General.Binding{Prep.Prepared{rn,right,+rp,rt},re}:WorldReturned{Task.leave(~S.SchemaA,~WC(),~Unit,~Unit,entered(lp),Task.leave(~S.SchemaA,~WC(),~Unit,~Unit,entered(rp),world)),displaced,General.Binding{Prep.Prepared{ln,left,lp,lt},le},General.Binding{Prep.Prepared{rn,right,rp,rt},re},ls,rs}
def reassembled(pipeline:Pipeline) -> WorldResult:
  match pipeline:
    case GroupReturned{admin,Finished{Partition.Joined{scope,displaced},left,right,ls,rs}}:exited(State.reassemble(~S.SchemaA,~WC(),~Unit,~Unit,admin,scope),displaced,left,right,ls,rs)
    case pipeline:Unreassembled{pipeline}
type SeedRun is Type:
  SeedRun{factory:W.Factory,result:WorldResult}
  SeedRunRefused{factory:W.Factory,resource:Unit}
def run_seeded(result:Seeded) -> SeedRun:
  match result:
    case Seeded{factory,world}:SeedRun{factory,reassembled(run_world(world))}
    case SeedRefused{factory,resource}:SeedRunRefused{factory,resource}
def run(factory:W.Factory) -> SeedRun:
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
def captured_mode(mode:TargetMode,result:W.World<S.SchemaA,WC(),Unit,Unit> & List<&2,W.Handle<S.SchemaA>>) -> Pipeline:
  match result:
    case (world,+handles):targets(world,choose(1,handles),requested(mode,handles))
def run_world_mode(world:W.World<S.SchemaA,WC(),Unit,Unit>,mode:TargetMode) -> Pipeline:
  captured_mode(mode,W.handles(~S.SchemaA,~WC(),~Unit,~Unit,world))
def run_seeded_mode(mode:TargetMode,result:Seeded) -> SeedRun:
  match result:
    case Seeded{factory,world}:SeedRun{factory,reassembled(run_world_mode(world,mode))}
    case SeedRefused{factory,resource}:SeedRunRefused{factory,resource}
def run_mode(factory:W.Factory,mode:TargetMode) -> SeedRun:
  run_seeded_mode(mode,seeded(factory))
