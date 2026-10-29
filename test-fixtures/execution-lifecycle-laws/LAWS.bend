import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-app.bend as Single
import ../../src/ecs/execution-parallel-app.bend as Pair
import ../../src/ecs/execution-parallel-run.bend as Run
import ../../src/ecs/execution-parallel.bend as Parallel
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-state.bend as State
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-lifecycle-access.bend as Access
import ../../src/ecs/execution-lifecycle-maintenance.bend as Maintenance
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/execution-command-publication.bend as Publication
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/chunk-column.bend as Column

# DRAFT ONLY: these exact statements are not approved and have no proofs.
# Erased symbolic binders describe actual affine Type owners in equations;
# they do not authorize duplicating those owners in executable Bend.
# No Data model substitutes for World, Scope, Local, Reader or App.State.
# Conditional public-run laws pin continuation after the stated actual result;
# they do not independently prove admission, the body's behavior, or host IO.
# Current ABI: declarations are FrameworkProgram, bodies are permit-indexed
# Task programs, and run/kernel wrappers return IO. Conditional IO equations
# below require exact IO.pure terms; arbitrary effect traces remain outside them.

# Guarantees: Single.run forwards an assumed executed result and maintains its World.
# Why it matters: the actual returned owner/completion survive success or error.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs#L145-L159
# Bevy behavior: update runs the default schedule before clearing trackers.
# Bend limit: this conditional equation assumes the actual Sys.run result;
# it does not assert a body error was rolled back or prove that invocation.
law single_run_forwards_executed_result_with_maintenance:
  for -S:Data
  for -C:Type
  for -R:Type
  for -E:Data
  for -Ops:Data -> Type -> Type
  for -Local:Type
  for -Error:Data
  for -Out:Data
  for -declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops)
  for -body:Sys.Body(~S,~Ops,~Local,~Error,~Out)
  for -before:W.World<S,C,R,E>
  for -after:W.World<S,C,R,E>
  for -owner:Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>
  for -returned:Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>
  for -completion:Sys.Completion<Error,Out>
  for executed:{Sys.run(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner,before) == IO.pure(Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>,Sys.Executed{after,returned,completion}) : IO(Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>)}
  {Single.run(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Single.Application{before,owner}) == IO.pure(Single.Application<S,C,R,E,Ops,Local,Error,Out,declaration,body> & Single.Status<Error,Out>,(Single.Application{W.maintain_lifecycle(~S,~C,~R,~E,after),returned},Single.Ran{completion})) : IO(Single.Application<S,C,R,E,Ops,Local,Error,Out,declaration,body> & Single.Status<Error,Out>)}

# Guarantees: Single.run forwards an assumed exact refused World/system result.
# Why it matters: this wrapper must not rotate history after that assumed result.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/function_system.rs#L400-L419
# Bevy behavior: persistent SystemState validates its initializing WorldId.
# Bend adaptation: explicit returned refusal replaces that Rust mismatch panic;
# the equation assumes actual Sys.run refusal, not a synthetic namespace model.
law single_run_forwards_refused_result:
  for -S:Data
  for -C:Type
  for -R:Type
  for -E:Data
  for -Ops:Data -> Type -> Type
  for -Local:Type
  for -Error:Data
  for -Out:Data
  for -declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops)
  for -body:Sys.Body(~S,~Ops,~Local,~Error,~Out)
  for -world:W.World<S,C,R,E>
  for -owner:Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>
  for refused:{Sys.run(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,owner,world) == IO.pure(Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>,Sys.Refused{world,owner}) : IO(Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>)}
  {Single.run(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Single.Application{world,owner}) == IO.pure(Single.Application<S,C,R,E,Ops,Local,Error,Out,declaration,body> & Single.Status<Error,Out>,(Single.Application{world,owner},Single.AdmissionRefused{})) : IO(Single.Application<S,C,R,E,Ops,Local,Error,Out,declaration,body> & Single.Status<Error,Out>)}

# Guarantees: returned body error retains the actual Scope payload and affine Local.
# Why it matters: the completed owner gets the captured tick, never a prior Local.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L137-L163
# Bevy behavior: returned failure reaches the handler without a rollback step.
# Bend limit: this pins actual result reassembly; it does not prove arbitrary
# body writes, host exception cleanup, or the handler's continuation policy.
law body_error_reassembles_actual_type_owners:
  for -S:Data
  for -C:Type
  for -R:Type
  for -E:Data
  for -Ops:Data -> Type -> Type
  for -Local:Type
  for -Error:Data
  for -Out:Data
  for -declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops)
  for -body:Sys.Body(~S,~Ops,~Local,~Error,~Out)
  for -admin:State.Administration<S,C,R,E>
  for -scope:State.Scope<S,C,R>
  for -local:Local
  for -namespace:U32
  for -id:U32
  for -name:String
  for -access:List<&2,String>
  for -tick:Tick.Tick
  for -error:Error
  for -out:Out
  {Sys.returned(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,admin,namespace,id,name,access,tick,(scope,(local,Sys.BodyError{error,out}))) == Sys.Executed{W.leave_run(~S,~C,~R,~E,State.reassemble(~S,~C,~R,~E,admin,scope)),Sys.Owner{namespace,id,name,access,Some{tick},local},Sys.BodyError{error,out}} : Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>}

# Guarantees: actual Finished App state maintains only its returned World.
# Why it matters: affine owners, guards and handler are the returned values.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs#L145-L159
# Bevy behavior: tracker maintenance follows a completed schedule update.
# Bend limit: callers must reach this once after final-deferred policy; this law
# alone does not establish caller placement or the semantics of Notice.maintain.
law finished_maintains_actual_app_state:
  for -S:Data
  for -C:Type
  for -R:Type
  for -E:Data
  for -Owners:Type
  for -Guards:Type
  for -Handler:Type
  for -Error:Data
  for -Out:Data
  for -world:W.World<S,C,R,E>
  for -owners:Owners
  for -guards:Guards
  for -handler:Handler
  for -bindings:List<&2,App.Binding>
  for -events:List<&2,Exec.Observation<Error,Out>>
  {Maintenance.completed(~S,~C,~R,~E,~Owners,~Guards,~Handler,~Error,~Out,Exec.Finished{App.State{world,owners,guards,handler,bindings},events}) == Exec.Finished{App.State{W.maintain_lifecycle(~S,~C,~R,~E,world),owners,guards,handler,bindings},events} : Exec.ExecutionResult<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>,String,Error,Out>}

# Guarantees: escalated Stop retains the actual affine App state without rotation.
# Why it matters: retained writes do not falsely claim a completed App update.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs#L145-L159
# Bevy behavior: clear_trackers follows return from run_default_schedule.
# Bend adaptation: explicit Stopped is incomplete and is not Rust panic handling.
law stopped_preserves_actual_app_state:
  for -S:Data
  for -C:Type
  for -R:Type
  for -E:Data
  for -Owners:Type
  for -Guards:Type
  for -Handler:Type
  for -Error:Data
  for -Out:Data
  for -state:App.State<W.World<S,C,R,E>,Owners,Guards,Handler>
  for -error:Error
  for -events:List<&2,Exec.Observation<Error,Out>>
  {Maintenance.completed(~S,~C,~R,~E,~Owners,~Guards,~Handler,~Error,~Out,Exec.Stopped{state,error,events}) == Exec.Stopped{state,error,events} : Exec.ExecutionResult<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>,String,Error,Out>}

# Guarantees: Invalid preserves actual App state and reason without rotation.
# Why it matters: invalid planning cannot erase retained affine payload owners.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/schedule.rs#L1261-L1279
# Bevy behavior: schedule construction rejects graph errors before execution.
# Bend adaptation: exact returned state/reason is this API's contract, not a claim
# that Bevy schedule construction never modifies its own World.
law invalid_preserves_actual_app_state:
  for -S:Data
  for -C:Type
  for -R:Type
  for -E:Data
  for -Owners:Type
  for -Guards:Type
  for -Handler:Type
  for -Error:Data
  for -Out:Data
  for -state:App.State<W.World<S,C,R,E>,Owners,Guards,Handler>
  for -reason:Plan.Invalid<String>
  {Maintenance.completed(~S,~C,~R,~E,~Owners,~Guards,~Handler,~Error,~Out,Exec.Invalid{state,reason}) == Exec.Invalid{state,reason} : Exec.ExecutionResult<App.State<W.World<S,C,R,E>,Owners,Guards,Handler>,String,Error,Out>}

# Guarantees: a foreign reader operation preserves the exact reader and Scope.
# Why it matters: equal sequence numbers in another World cannot suppress notices.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/function_system.rs#L400-L419
# Bevy behavior: persistent SystemState is bound to its initializing WorldId.
# Bend adaptation: operation-level Reader namespace refusal returns the reader;
# it is not a proof of host namespace uniqueness or of whole-system admission.
law foreign_reader_preserves_actual_scope_and_reader:
  for -S:Data
  for -C:Type
  for -R:Type
  for -origin:Layout.Layout
  for -selector:Notice.Selector
  for -store:C
  for -resource:R
  for -handles:List<&2,W.Handle<S>>
  for -tick:Tick.Tick
  for -prior:Maybe<&2,Tick.Tick>
  for -namespace:U32
  for -actual:U32
  for -channels:List<&2,Notice.Channel<S>>
  for -active:List<&2,Notice.Active>
  for -id:U32
  for -cursor:Nat
  for foreign:{U32.is_eq(namespace,actual) == False{} : Bool}
  {Access.read(~S,~C,~R,~origin,~selector,State.Scope{store,resource,handles,tick,prior,Notice.View{namespace,channels,active}},Notice.Reader{actual,id,cursor}) == (State.Scope{store,resource,handles,tick,prior,Notice.View{namespace,channels,active}},Notice.ReadRefused{Notice.Reader{actual,id,cursor},Notice.ForeignWorld{}}) : State.Scope<S,C,R> & Notice.Reading<S,origin,selector>}

# Guarantees: Pair.run_when forwards an assumed Finished result with maintenance.
# Why it matters: a valid both-disabled update is not confused with refusal.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs#L145-L159
# Bevy behavior: an update without a selected default schedule still clears trackers.
# Bend limit: actual kernel Finished is a premise, including its gate/admission
# decision. This law does not independently establish that kernel classification.
# Current IO limit: the run-wrapper premises below require exact IO.pure terms.
# They do not quantify over arbitrary effectful Task/IO traces or prove driver IO.
law pair_run_forwards_finished_result_with_maintenance:
  for -S:Data
  for -CL:Type
  for -CR:Type
  for -RL:Type
  for -RR:Type
  for -E:Data
  for -LL:Type
  for -LR:Type
  for -EL:Data
  for -ER:Data
  for -OL:Data
  for -OR:Data
  for -OpsL:Data -> Type -> Type
  for -OpsR:Data -> Type -> Type
  for -dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL)
  for -dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR)
  for -bl:Sys.Body(~S,~OpsL,~LL,~EL,~OL)
  for -br:Sys.Body(~S,~OpsR,~LR,~ER,~OR)
  for -mode:Parallel.Mode
  for -gateLeft:Bool
  for -gateRight:Bool
  for -app:Pair.ParallelApp<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>>
  for -world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>
  for -left:Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>
  for -right:Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>
  for -lc:Maybe<&2,Sys.Completion<EL,OL>>
  for -rc:Maybe<&2,Sys.Completion<ER,OR>>
  for finished:{Pair.kernel_when(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,gateLeft,gateRight,app) == IO.pure(Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>,Run.Finished{world,left,right,lc,rc}) : IO(Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>)}
  {Pair.run_when(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,gateLeft,gateRight,app) == IO.pure(Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>,Run.Finished{W.maintain_lifecycle(~S,~Product.Owner<CL,CR>,~Product.Owner<RL,RR>,~E,world),left,right,lc,rc}) : IO(Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>)}

# Guarantees: Pair.run_when forwards an assumed refused result without maintenance.
# Why it matters: the wrapper must preserve the owners/completions already in it.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/function_system.rs#L400-L419
# Bevy behavior: system state validates its World identity before access.
# Bend adaptation: explicit partial pair refusal retains any executed sibling;
# this conditional law introduces no rollback and proves no host identity allocator.
law pair_run_forwards_refused_result:
  for -S:Data
  for -CL:Type
  for -CR:Type
  for -RL:Type
  for -RR:Type
  for -E:Data
  for -LL:Type
  for -LR:Type
  for -EL:Data
  for -ER:Data
  for -OL:Data
  for -OR:Data
  for -OpsL:Data -> Type -> Type
  for -OpsR:Data -> Type -> Type
  for -dl:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CL,~RL,~OpsL)
  for -dr:Build.FrameworkProgram(~S,~Product.Owner<CL,CR>,~CR,~RR,~OpsR)
  for -bl:Sys.Body(~S,~OpsL,~LL,~EL,~OL)
  for -br:Sys.Body(~S,~OpsR,~LR,~ER,~OR)
  for -mode:Parallel.Mode
  for -gateLeft:Bool
  for -gateRight:Bool
  for -app:Pair.ParallelApp<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>>
  for -world:W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>
  for -left:Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>
  for -right:Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>
  for -lc:Maybe<&2,Sys.Completion<EL,OL>>
  for -rc:Maybe<&2,Sys.Completion<ER,OR>>
  for refused:{Pair.kernel_when(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,gateLeft,gateRight,app) == IO.pure(Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>,Run.AdmissionRefused{world,left,right,lc,rc}) : IO(Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>)}
  {Pair.run_when(~S,~CL,~CR,~RL,~RR,~E,~LL,~LR,~EL,~ER,~OL,~OR,~OpsL,~OpsR,~dl,~dr,~bl,~br,mode,gateLeft,gateRight,app) == IO.pure(Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>,Run.AdmissionRefused{world,left,right,lc,rc}) : IO(Run.PairResult<W.World<S,Product.Owner<CL,CR>,Product.Owner<RL,RR>,E>,Sys.Owner<S,Product.Owner<CL,CR>,CL,RL,E,OpsL,LL,EL,OL,dl,bl>,Sys.Owner<S,Product.Owner<CL,CR>,CR,RR,E,OpsR,LR,ER,OR,dr,br>,EL,ER,OL,OR>)}

# Guarantees: reassembly returns actual Scope columns/resources and Admin owners.
# Why it matters: a worker's returned snapshot cannot replace authoritative journal.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/world/unsafe_world_cell.rs#L350-L360
# Bevy behavior: access to removed-component storage is World-owned metadata.
# Bend adaptation: split/reassembly explicitly carries affine administration;
# no Data projection or assumed final reassembly result appears in this law.
law reassembly_preserves_actual_owners_and_authoritative_journal:
  for -S:Data
  for -C:Type
  for -R:Type
  for -E:Data
  for -namespace:U32
  for -allocator:Allocator.Allocator
  for -store:C
  for -resource:R
  for -events:List<&2,E>
  for -pending:List<Deferred.Command<W.World<S,C,R,E>>>
  for -registrations:List<&2,W.RegistrationMeta>
  for -nextSystemId:U32
  for -clock:Clock.State
  for -journal:Notice.Journal<S>
  for -handles:List<&2,W.Handle<S>>
  for -tick:Tick.Tick
  for -prior:Maybe<&2,Tick.Tick>
  for -view:Notice.View<S>
  {State.reassemble(~S,~C,~R,~E,State.Administration{namespace,allocator,events,pending,registrations,nextSystemId,clock,journal},State.Scope{store,resource,handles,tick,prior,view}) == W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal} : W.World<S,C,R,E>}

# Guarantees: foreign identity makes actual Sys.run return exact original owners.
# Why it matters: admission refusal precedes tick capture, body and any maintenance.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/function_system.rs#L400-L419
# Bevy behavior: SystemState validates its WorldId before using stored parameters.
# Bend adaptation: mismatch is an owner-returning refusal, not a Rust panic.
# The sole premise is namespace inequality, NOT an assumed Sys.run result.
law single_foreign_admission_returns_exact_type_owners:
  for -S:Data
  for -C:Type
  for -R:Type
  for -E:Data
  for -Ops:Data -> Type -> Type
  for -Local:Type
  for -Error:Data
  for -Out:Data
  for -declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops)
  for -body:Sys.Body(~S,~Ops,~Local,~Error,~Out)
  for -namespace:U32
  for -allocator:Allocator.Allocator
  for -store:C
  for -resource:R
  for -events:List<&2,E>
  for -pending:List<Deferred.Command<W.World<S,C,R,E>>>
  for -registrations:List<&2,W.RegistrationMeta>
  for -nextSystemId:U32
  for -clock:Clock.State
  for -journal:Notice.Journal<S>
  for -ownerNamespace:U32
  for -id:U32
  for -name:String
  for -access:List<&2,String>
  for -prior:Maybe<&2,Tick.Tick>
  for -local:Local
  for foreign:{U32.is_eq(ownerNamespace,namespace) == False{} : Bool}
  {Sys.run(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,Sys.Owner{ownerNamespace,id,name,access,prior,local},W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal}) == IO.pure(Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>,Sys.Refused{W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},Sys.Owner{ownerNamespace,id,name,access,prior,local}}) : IO(Sys.RunResult<W.World<S,C,R,E>,Sys.Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>)}

# Guarantees: actual reader clamps to retained floor, reports lag, acknowledges item.
# Why it matters: arbitrary sleeping-reader lag is not success-only acknowledgement.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/message_cursor.rs#L130-L135
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/iterators.rs#L85-L101
# Bevy behavior: missed count measures oldest minus cursor; yielding advances it.
# Bend limit: this universally quantified retained one-item channel shape pins
# actual Access.read; broader multi-item search/retention still needs its own law.
law reader_lag_clamp_and_yield_preserve_actual_scope:
  for -S:Data
  for -C:Type
  for -R:Type
  for -origin:Layout.Layout
  for -selector:Notice.Selector
  for -store:C
  for -resource:R
  for -handles:List<&2,W.Handle<S>>
  for -tick:Tick.Tick
  for -prior:Maybe<&2,Tick.Tick>
  for -namespace:U32
  for -id:U32
  for -cursor:Nat
  for -lag:Nat
  for -entity:Notice.Identity<S>
  for -published:Tick.Tick
  {Access.read(~S,~C,~R,~origin,~selector,State.Scope{store,resource,handles,tick,prior,Notice.View{namespace,[Notice.Channel{selector,Nat.add(2n,Nat.add(cursor,lag)),[],[Notice.Row{Nat.add(1n,Nat.add(cursor,lag)),entity,published}],Nat.add(cursor,lag)}],[Notice.Active{id,selector}]}},Notice.Reader{namespace,id,cursor}) == (State.Scope{store,resource,handles,tick,prior,Notice.View{namespace,[Notice.Channel{selector,Nat.add(2n,Nat.add(cursor,lag)),[],[Notice.Row{Nat.add(1n,Nat.add(cursor,lag)),entity,published}],Nat.add(cursor,lag)}],[Notice.Active{id,selector}]}},Notice.Item{Notice.Reader{namespace,id,Nat.add(1n,Nat.add(cursor,lag))},Notice.Row{Nat.add(1n,Nat.add(cursor,lag)),entity,published},lag}) : State.Scope<S,C,R> & Notice.Reading<S,origin,selector>}

# Guarantees: actual command entry refuses foreign ownership without publication.
# Why it matters: incoming raw affine payload and full World remain the originals.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/world/mod.rs#L1599-L1608
# Bevy behavior: structural entity operations validate the actual entity first.
# Bend adaptation: namespace is explicit and refusal returns raw payload owners.
# The premises validate route and foreign identity, not a final publication result.
# Historical pre-migration text follows. Its entry call is not the current ABI.
# The same full-World/incoming-owner subject is reauthored below with the actual
# resources, equality, Selection, Relations and Context arguments. Both texts
# remain unapproved and unproved; the old text is not a second candidate.
# BLOCKED: law foreign_family_entry_retains_world_and_incoming_owner:
# BLOCKED:   for -S:Data
# BLOCKED:   for -R:Type
# BLOCKED:   for -E:Data
# BLOCKED:   for -layout:Layout.Layout
# BLOCKED:   for -route:Layout.Route
# BLOCKED:   for valid:{Layout.grant_valid(~layout,~route) == True{} : Bool}
# BLOCKED:   for -permission:Permission.Permission
# BLOCKED:   for -namespace:U32
# BLOCKED:   for -allocator:Allocator.Allocator
# BLOCKED:   for -store:Layout.columns(~S,layout)
# BLOCKED:   for -resource:R
# BLOCKED:   for -events:List<&2,E>
# BLOCKED:   for -pending:List<Deferred.Command<W.World<S,Layout.columns(~S,layout),R,E>>>
# BLOCKED:   for -registrations:List<&2,W.RegistrationMeta>
# BLOCKED:   for -nextSystemId:U32
# BLOCKED:   for -clock:Clock.State
# BLOCKED:   for -journal:Notice.Journal<S>
# BLOCKED:   for -actual:U32
# BLOCKED:   for -key:Key.Key
# BLOCKED:   for -incoming:Maybe<&1,Layout.payload(layout,route)>
# BLOCKED:   for -tick:Tick.Tick
# BLOCKED:   for foreign:{U32.is_eq(namespace,actual) == False{} : Bool}
# BLOCKED:   {Publication.entry(~S,~R,~E,~layout,~route,permission,W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},Buffer.Entry{W.Handle{actual,key},incoming},tick) == (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},Buffer.Refused{W.Handle{actual,key},incoming}) : W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>}

# Guarantees: a foreign family entry returns the full World and incoming owner.
# Why it matters: a queued insert for another World cannot replace or lose them.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/world/mod.rs#L1599-L1612
# Bevy behavior: structural entity access validates the entity before mutation.
# Bend requirement: explicit namespace refusal returns these exact affine owners.
# The valid-route and namespace premises do not assume a publication result.
# Selection, relations and Context are the actual entry arguments, not Data
# summaries of World. This family branch does not exercise their graph/scope
# dispatch, verify Context admission, or prove ordinary Root/queue wiring.
# DRAFT, UNAPPROVED, UNPROVED. No proof definition accompanies this statement.
law foreign_family_entry_retains_world_and_incoming_owner:
  for -S:Data
  for -R:Type
  for -E:Data
  for -layout:Layout.Layout
  for -route:Layout.Route
  for valid:{Layout.grant_valid(~layout,~route) == True{} : Bool}
  for -resources:Layout.Layout
  for -sameWR:{R == Layout.resources(~S,resources) : Type}
  for -selection:Permission.Selection<S,resources>
  for -relations:Permission.Relations<S,resources>
  for -context:Context.Context<S,R,resources,sameWR>
  for -permission:Permission.Permission
  for -namespace:U32
  for -allocator:Allocator.Allocator
  for -store:Layout.columns(~S,layout)
  for -resource:R
  for -events:List<&2,E>
  for -pending:List<Deferred.Command<W.World<S,Layout.columns(~S,layout),R,E>>>
  for -registrations:List<&2,W.RegistrationMeta>
  for -nextSystemId:U32
  for -clock:Clock.State
  for -journal:Notice.Journal<S>
  for -actual:U32
  for -key:Key.Key
  for -incoming:Maybe<&1,Layout.payload(layout,route)>
  for -tick:Tick.Tick
  for foreign:{U32.is_eq(namespace,actual) == False{} : Bool}
  {Publication.entry(~S,~R,~E,~layout,~route,~resources,~sameWR,~selection,~relations,context,permission,W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},Buffer.Entry{W.Handle{actual,key},incoming},tick) == (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},Buffer.Refused{W.Handle{actual,key},incoming}) : W.World<S,Layout.columns(~S,layout),R,E> & Buffer.Receipt<S,Layout.payload(layout,route),Removed.Removed(layout)>}
