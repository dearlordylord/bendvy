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
import ../../src/ecs/execution-compiled-binding.bend as Binding
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-reservation-task.bend as Effect
import ../../src/ecs/execution-reservation-authority.bend as RuntimePermit
import ../../src/ecs/execution-reservation-driver.bend as Driver

def WC() -> Type:L.columns(~S.SchemaA,S.layout_a())
def HStore() -> Type:Store.Storage<S.SchemaA,S.layout_a()>
def Caps(H:Type) -> Type:Q.GeneralWriter<S.SchemaA,H,S.Position,U32>
def Ops(Permit:Data,H:Type) -> Type:Caps(H)
def any(value:Maybe<&2,U32>) -> Bool:True{}
def selection(~bound:Recipe.Bound,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~HStore(),~Unit,~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~HStore(),~Unit,~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~HStore(),~Unit,~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~HStore(),~Unit,~H,~B),~query:Build.Query(~S.SchemaA,~WC(),~HStore(),~Unit,~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~HStore(),~Unit,~H,~B),book:B) -> B & Ops(Permit,H):
  Build.general_query(~S.SchemaA,~WC(),~HStore(),~Unit,~S.layout_a(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Sparse{},~{==},~Recipe.WriteRows{},~bound,~Match.Optional{},~any,~H,~B,~query,book)
def program(~bound:Recipe.Bound,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~Unit,~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  builder(Ops,selection(~bound,~Permit,~H,~B),book)
def left_program(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~Unit,~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  program(~Recipe.With{L.InRight{L.AtLeaf{}}},~Permit,~H,~B,~builder,book)
def right_program(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~Unit,~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
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
def LeftOwner() -> Type:Sys.Owner<S.SchemaA,WC(),HStore(),Unit,Unit,Ops,Local,String,Q.GeneralLookup<U32>,left_program,left_body>
def RightOwner() -> Type:Sys.Owner<S.SchemaA,WC(),HStore(),Unit,Unit,Ops,Local,String,Q.GeneralLookup<U32>,right_program,right_body>
def Compilation() -> Type:D.Compilation<S.SchemaA,WC(),HStore(),Unit,Ops>
def left_compiled() -> Compilation():Build.compile_framework_with_general(~S.SchemaA,~WC(),~HStore(),~Unit,~Interpret.provider_dictionary(~S.SchemaA,~WC(),~HStore(),~Unit),~Ops,~left_program)
def right_compiled() -> Compilation():Build.compile_framework_with_general(~S.SchemaA,~WC(),~HStore(),~Unit,~Interpret.provider_dictionary(~S.SchemaA,~WC(),~HStore(),~Unit),~Ops,~right_program)
def LeftEvidence() -> Data:Maybe<&2,General.Evidence<S.SchemaA,S.layout_a(),HStore(),Unit,Ops,left_program>>
def RightEvidence() -> Data:Maybe<&2,General.Evidence<S.SchemaA,S.layout_a(),HStore(),Unit,Ops,right_program>>
def LeftBinding() -> Type:Binding.Binding<Compilation(),W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),LeftEvidence(),Prep.Permit<S.SchemaA,WC()>>
def RightBinding() -> Type:Binding.Binding<Compilation(),W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),RightEvidence(),Prep.Permit<S.SchemaA,WC()>>
def LeftPreparation() -> Type:Binding.Preparation<Compilation(),W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),LeftEvidence(),Prep.Permit<S.SchemaA,WC()>>
def RightPreparation() -> Type:Binding.Preparation<Compilation(),W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),RightEvidence(),Prep.Permit<S.SchemaA,WC()>>
def define_left(world:W.World<S.SchemaA,WC(),Unit,Unit>,local:Local) -> Compilation() & Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),Local>:
  General.define_with_compilation(~S.SchemaA,~S.layout_a(),~HStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~left_program,~left_body,left_compiled(),world,"general-left",local)
def define_right(world:W.World<S.SchemaA,WC(),Unit,Unit>,local:Local) -> Compilation() & Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),Local>:
  General.define_with_compilation(~S.SchemaA,~S.layout_a(),~HStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~right_program,~right_body,right_compiled(),world,"general-right",local)
def prepare_left(compilation:Compilation(),ids:List<&2,U32>,world:W.World<S.SchemaA,WC(),Unit,Unit>,owner:LeftOwner()) -> LeftPreparation():
  General.prepare_with_compilation(~S.SchemaA,~S.layout_a(),~HStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~left_program,~left_body,compilation,ids,world,owner)
def LeftInvocation() -> Type:Binding.Invocation<Compilation(),State.Scope<S.SchemaA,HStore(),Unit>,W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),LeftEvidence(),Prep.Permit<S.SchemaA,WC()>,List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>>
def invoke_left(scope:State.Scope<S.SchemaA,HStore(),Unit>,binding:LeftBinding()) -> Effect.Task<S.SchemaA,RuntimePermit.Permit,LeftInvocation()>:
  General.invoke_sparse(~S.SchemaA,~S.layout_a(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~left_program,~left_body,~D.trusted_construction_caps(~S.SchemaA,~WC(),~HStore(),~Unit,~Ops,left_compiled()),~Scope.no_structural(~Ops(Effect.Granted,State.Scope<S.SchemaA,HStore(),Unit>)),scope,binding)
def prepare_right(compilation:Compilation(),ids:List<&2,U32>,world:W.World<S.SchemaA,WC(),Unit,Unit>,owner:RightOwner()) -> RightPreparation():
  General.prepare_with_compilation(~S.SchemaA,~S.layout_a(),~HStore(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~right_program,~right_body,compilation,ids,world,owner)
def RightInvocation() -> Type:Binding.Invocation<Compilation(),State.Scope<S.SchemaA,HStore(),Unit>,W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),RightEvidence(),Prep.Permit<S.SchemaA,WC()>,List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>>
def invoke_right(scope:State.Scope<S.SchemaA,HStore(),Unit>,binding:RightBinding()) -> Effect.Task<S.SchemaA,RuntimePermit.Permit,RightInvocation()>:
  General.invoke_sparse(~S.SchemaA,~S.layout_a(),~Unit,~Unit,~Unit,~Ops,~Local,~String,~Q.GeneralLookup<U32>,~right_program,~right_body,~D.trusted_construction_caps(~S.SchemaA,~WC(),~HStore(),~Unit,~Ops,right_compiled()),~Scope.no_structural(~Ops(Effect.Granted,State.Scope<S.SchemaA,HStore(),Unit>)),scope,binding)
type Partitioned is Type:
  Partitioned{partition:Partition.Split<S.SchemaA,S.layout_a()>,left:LeftBinding(),right:RightBinding()}
def split(scope:State.Scope<S.SchemaA,WC(),Unit>,left:LeftBinding(),right:RightBinding()) -> Partitioned:
  match left right:
    case Binding.Binding{lc,lp,Some{+le}} Binding.Binding{rc,rp,Some{+re}}:Partitioned{Partition.split(~S.SchemaA,~S.layout_a(),~Ops,~Ops,~left_program,~right_program,scope,le,re),Binding.Binding{lc,lp,Some{le}},Binding.Binding{rc,rp,Some{re}}}
    case left right:Partitioned{Partition.SplitRefused{scope},left,right}
type Invoked is Type:
  Invoked{left:LeftInvocation(),right:RightInvocation(),join:Partition.Join<S.SchemaA,S.layout_a()>}
def invoke_pair(left:State.Scope<S.SchemaA,HStore(),Unit>,right:State.Scope<S.SchemaA,HStore(),Unit>,join:Partition.Join<S.SchemaA,S.layout_a()>,lp:LeftBinding(),rp:RightBinding()) -> Effect.Task<S.SchemaA,RuntimePermit.Permit,Invoked>:
  Effect.TFork{LeftInvocation(),RightInvocation(),Effect.TRun{_ => invoke_left(left,lp)},Effect.TRun{_ => invoke_right(right,rp)},l => r => Effect.TDone{Invoked{l,r,join}}}
type Finished is Type:
  Finished{joined:Partition.Joined<S.SchemaA,S.layout_a()>,left:LeftBinding(),right:RightBinding(),leftStatus:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>,rightStatus:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>}
  InventoryRefused{left:LeftInvocation(),right:RightInvocation(),join:Partition.Join<S.SchemaA,S.layout_a()>}
def finish_returned(left:State.Scope<S.SchemaA,HStore(),Unit>,right:State.Scope<S.SchemaA,HStore(),Unit>,join:Partition.Join<S.SchemaA,S.layout_a()>,lp:LeftBinding(),rp:RightBinding(),ls:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>,rs:List<&2,Ready.Completed<String,Q.GeneralLookup<U32>>>) -> Finished:
  Finished{Partition.join(~S.SchemaA,~S.layout_a(),left,right,join),lp,rp,ls,rs}
def finish(left:LeftInvocation(),right:RightInvocation(),join:Partition.Join<S.SchemaA,S.layout_a()>) -> Finished:
  match left right:
    case Binding.Invoked{left,lp,ls} Binding.Invoked{right,rp,rs}:finish_returned(left,right,join,lp,rp,ls,rs)
    case Binding.Invoked{left,lp,ls} Binding.InvocationRefused{right,rp,rs}:finish_returned(left,right,join,lp,rp,ls,rs)
    case Binding.InvocationRefused{left,lp,ls} Binding.Invoked{right,rp,rs}:finish_returned(left,right,join,lp,rp,ls,rs)
    case Binding.InvocationRefused{left,lp,ls} Binding.InvocationRefused{right,rp,rs}:finish_returned(left,right,join,lp,rp,ls,rs)
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
  LeftDefinitionRefused{world:W.World<S.SchemaA,WC(),Unit,Unit>,compilation:Compilation(),left:Local,right:Local}
  RightDefinitionRefused{world:W.World<S.SchemaA,WC(),Unit,Unit>,leftCompilation:Compilation(),left:LeftOwner(),rightCompilation:Compilation(),right:Local}
  LeftPreparationRefused{result:LeftPreparation(),rightCompilation:Compilation(),right:RightOwner()}
  RightPreparationRefused{left:LeftBinding(),result:RightPreparation()}
  GroupPartitionRefused{admin:State.Administration<S.SchemaA,WC(),Unit,Unit>,partition:Partitioned}
  GroupReturned{admin:State.Administration<S.SchemaA,WC(),Unit,Unit>,finished:Finished}
def pair_returned(result:State.Administration<S.SchemaA,WC(),Unit,Unit> & Invoked) -> Pipeline:
  match result:
    case (admin,Invoked{left,right,join}):GroupReturned{admin,finish(left,right,join)}
def partition_returned(admin:State.Administration<S.SchemaA,WC(),Unit,Unit>,result:Partitioned) -> IO(Pipeline):
  match result:
    case Partitioned{Partition.Split{left,right,join},lp,rp}:IO.bind(State.Administration<S.SchemaA,WC(),Unit,Unit> & Invoked,Pipeline,Driver.run(~S.SchemaA,~WC(),~Unit,~Unit,Invoked,[],admin,invoke_pair(left,right,join,lp,rp)),result => IO.pure(Pipeline,pair_returned(result)))
    case partition:IO.pure(Pipeline,GroupPartitionRefused{admin,partition})
def separated(lp:LeftBinding(),rp:RightBinding(),result:State.Administration<S.SchemaA,WC(),Unit,Unit> & State.Scope<S.SchemaA,WC(),Unit>) -> IO(Pipeline):
  match result:
    case (admin,scope):partition_returned(admin,split(scope,lp,rp))
def clocked(lp:LeftBinding(),rp:RightBinding(),result:W.World<S.SchemaA,WC(),Unit,Unit> & Tick.Tick) -> IO(Pipeline):
  match result:
    case (world,tick):separated(lp,rp,State.separate(~S.SchemaA,~WC(),~Unit,~Unit,world,tick))
def right_prepared(lp:LeftBinding(),result:RightPreparation()) -> IO(Pipeline):
  match result:
    case Binding.Ready{world,rp}:clocked(lp,rp,W.execution_clock(~S.SchemaA,~WC(),~Unit,~Unit,world))
    case result:IO.pure(Pipeline,RightPreparationRefused{lp,result})
def left_prepared(compilation:Compilation(),+ids:List<&2,U32>,right:RightOwner(),result:LeftPreparation()) -> IO(Pipeline):
  match result:
    case Binding.Ready{world,lp}:right_prepared(lp,prepare_right(compilation,ids,world,right))
    case result:IO.pure(Pipeline,LeftPreparationRefused{result,compilation,right})
def right_defined(leftCompilation:Compilation(),left:LeftOwner(),result:Compilation() & Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,RightOwner(),Local>) -> IO(Pipeline):
  match left result:
    case left, (compilation,Sys.DefinitionRefused{world,right}):IO.pure(Pipeline,RightDefinitionRefused{world,leftCompilation,left,compilation,right})
    case Sys.Owner{ln,+lid,lt,la,lc,ll}, (compilation,Sys.Defined{world,Sys.Owner{rn,+rid,rt,ra,rc,rl}}):left_prepared(compilation,[lid,rid],Sys.Owner{rn,rid,rt,ra,rc,rl},prepare_left(leftCompilation,[lid,rid],world,Sys.Owner{ln,lid,lt,la,lc,ll}))
def left_defined(right:Local,result:Compilation() & Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,LeftOwner(),Local>) -> IO(Pipeline):
  match result:
    case (compilation,Sys.DefinitionRefused{world,left}):IO.pure(Pipeline,LeftDefinitionRefused{world,compilation,left,right})
    case (compilation,Sys.Defined{world,left}):right_defined(compilation,left,define_right(world,right))
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
def targets(world:W.World<S.SchemaA,WC(),Unit,Unit>,left:Maybe<&2,W.Handle<S.SchemaA>>,right:Maybe<&2,W.Handle<S.SchemaA>>) -> IO(Pipeline):
  match left right:
    case Some{lh} Some{rh}:left_defined(target_local(rh,202),define_left(world,target_local(lh,101)))
    case _ _:IO.pure(Pipeline,TargetsRefused{world})
def captured(result:W.World<S.SchemaA,WC(),Unit,Unit> & List<&2,W.Handle<S.SchemaA>>) -> IO(Pipeline):
  match result:
    case (world,+handles):targets(world,choose(1,handles),choose(20,handles))
def run_world(world:W.World<S.SchemaA,WC(),Unit,Unit>) -> IO(Pipeline):
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
    case Binding.Binding{lc,Prep.Prepared{ln,left,+lp,lt},le} Binding.Binding{rc,Prep.Prepared{rn,right,+rp,rt},re}:WorldReturned{Task.leave(~S.SchemaA,~WC(),~Unit,~Unit,entered(lp),Task.leave(~S.SchemaA,~WC(),~Unit,~Unit,entered(rp),world)),displaced,Binding.Binding{lc,Prep.Prepared{ln,left,lp,lt},le},Binding.Binding{rc,Prep.Prepared{rn,right,rp,rt},re},ls,rs}
def reassembled(pipeline:Pipeline) -> WorldResult:
  match pipeline:
    case GroupReturned{admin,Finished{Partition.Joined{scope,displaced},left,right,ls,rs}}:exited(State.reassemble(~S.SchemaA,~WC(),~Unit,~Unit,admin,scope),displaced,left,right,ls,rs)
    case pipeline:Unreassembled{pipeline}
type SeedRun is Type:
  SeedRun{factory:W.Factory,result:WorldResult}
  SeedRunRefused{factory:W.Factory,resource:Unit}
def run_seeded(result:Seeded) -> IO(SeedRun):
  match result:
    case Seeded{factory,world}:IO.bind(Pipeline,SeedRun,run_world(world),result => IO.pure(SeedRun,SeedRun{factory,reassembled(result)}))
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
def captured_mode(mode:TargetMode,result:W.World<S.SchemaA,WC(),Unit,Unit> & List<&2,W.Handle<S.SchemaA>>) -> IO(Pipeline):
  match result:
    case (world,+handles):targets(world,choose(1,handles),requested(mode,handles))
def run_world_mode(world:W.World<S.SchemaA,WC(),Unit,Unit>,mode:TargetMode) -> IO(Pipeline):
  captured_mode(mode,W.handles(~S.SchemaA,~WC(),~Unit,~Unit,world))
def run_seeded_mode(mode:TargetMode,result:Seeded) -> IO(SeedRun):
  match result:
    case Seeded{factory,world}:IO.bind(Pipeline,SeedRun,run_world_mode(world,mode),result => IO.pure(SeedRun,SeedRun{factory,reassembled(result)}))
    case SeedRefused{factory,resource}:IO.pure(SeedRun,SeedRunRefused{factory,resource})
def run_mode(factory:W.Factory,mode:TargetMode) -> IO(SeedRun):
  run_seeded_mode(mode,seeded(factory))
