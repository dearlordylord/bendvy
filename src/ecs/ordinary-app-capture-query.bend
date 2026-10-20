import Base
import ./ordinary-app-execution-recipe.bend as Exec
import ./execution-context.bend as Ctx
import ./schedule-provision.bend as SP
import ./captured-schedule-composition.bend as Choice
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-records.bend as Leaf
import ./world.bend as W
import ./system.bend as Sys
import ./transaction.bend as T
import ./compose.bend as Q
import ./ordinary-capture-query.bend as O
import ./ordinary-query-declaration.bend as Decl
import ./ordinary-app-capture-query-fields.bend as Fields
import ./ordinary-app-observation-data.bend as DTO
import ./trace-facts.bend as Facts
import ./ordinary-app-recipe.bend as Tree

# The actual affine capture-query owner is the invocation token. Fields are
# refreshed from that owner after each execution, including its real cursor.
# The registered owner of a repeatable query with affine capture L.
# Retain the actual returned owner, including its capture and reader cursor;
# metadata alone cannot replace its authority. Normally stored in Invocation.
def Owned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))) -> Type:O.Owner<S,C,R,E,L,Ops,Args,Error,Out,query,body>
# An App-owned captured-query invocation: registered owner, repeatable Args,
# and latest row outputs. Thread the returned invocation through every update;
# use arguments, outputs and with_arguments rather than reconstructing tokens.
def Invocation(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))) -> Type:Exec.Invocation<S,Owned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),Args,Out>
# Failure of this captured App leaf. CallbackFailure wraps the query's access
# or user error; RegistrationRefused reports rejected execution authority.
# A failure result still returns the context and captured-query owner.
type ExecutionError<Error:Data> is Data:
  CallbackFailure{error:Q.Error<Error>}
  RegistrationRefused{}
def execution_extracted(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),args:Args,outputs:List<&2,Out>,outcome:Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,ExecutionError<Error>,Unit>,result:Owned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body) & Records.Fields<S>) -> Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body) & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,ExecutionError<Error>,Unit>:
  match result:
    case (owner,fields):(Exec.Invocation{Leaf.Record{owner,fields},args,outputs},outcome)
def execution_returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),args:Args,trace:Facts.State,result:O.Run<W.World<S,C,R,E>,Owned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),Args,Q.Error<Error>,Out>) -> Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body) & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,ExecutionError<Error>,Unit>:
  match result:
    case O.Completed{world,owner,Done{outputs}}:execution_extracted(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,args,outputs,Sys.Succeeded{Ctx.Context{world,trace},Unit{}},Fields.fields(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,owner))
    case O.Completed{world,owner,Fail{error}}:execution_extracted(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,args,[],Sys.Failed{Ctx.Context{world,trace},CallbackFailure{error}},Fields.fields(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,owner))
    case O.Refused{world,owner,returnedArgs}:execution_extracted(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,returnedArgs,[],Sys.Failed{Ctx.Context{world,trace},RegistrationRefused{}},Fields.fields(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,owner))
def execution_allowed(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),allowed:Bool,invocation:Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),context:Ctx.Context<W.World<S,C,R,E>>) -> Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body) & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,ExecutionError<Error>,Unit>:
  match allowed invocation context:
    case False{} invocation context:(invocation,Sys.Failed{context,RegistrationRefused{}})
    case True{} Exec.Invocation{Leaf.Record{owner,_},+args,_} Ctx.Context{world,trace}:execution_returned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,args,trace,O.run(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,owner,world,args))
def execution_run(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),invocation:Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),context:Ctx.Context<W.World<S,C,R,E>>,id:U32) -> Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body) & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,ExecutionError<Error>,Unit>:
  match invocation:
    case Exec.Invocation{Leaf.Record{owner,+fields},args,outputs}:execution_allowed(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,U32.is_eq(id,Exec.registration_id(~S,fields)),Exec.Invocation{Leaf.Record{owner,fields},args,outputs},context)
# Executable App type after appending a query with retained affine capture.
# The new invocation is paired with prior owners; earlier inspection rows remain.
# The polymorphic body receives declared Ops and must return both its opaque
# frame and capture on every branch. Args, Error and Out are repeatable Data.
# See examples/captured-query/app.bend for named aliases and a complete App.
def Application(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))) -> Type:
  Exec.Registered<S,W.World<S,C,R,E>,Owners & Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),Rows,observe,Leaf.fold_pair(~S,~Owners,~Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~fold,~Exec.invocation_fields(~S,~Owned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~Args,~Out)),Choice.Choice<PriorError,ExecutionError<Error>>,Exec.plan_pair(~S,~Owners,~Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~priorPlan,~Exec.invocation_plan(~S,~Owned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~Args,~Out)),Exec.dispatch_pair(~S,~W.World<S,C,R,E>,~Owners,~Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~PriorError,~ExecutionError<Error>,~fold,~priorDispatch,~execution_run(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body)),Exec.provision_pair(~S,~W.World<S,C,R,E>,~priorProvide,~Exec.empty_provide(~S,~W.World<S,C,R,E>))>
def added_extracted(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Output:Type,args:Args,done:Application(~S,~C,~R,~E,~Owners,~Rows,~observe,~fold,~PriorError,~priorPlan,~priorDispatch,~priorProvide,~L,~Ops,~Args,~Error,~Out,~query,~body) -> Output,world:W.World<S,C,R,E>,owners:Owners,result:Owned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body) & Records.Fields<S>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool) -> Output:
  match result:
    case (owner,fields):done(Exec.Registered{Build.Registered{world,(owners,Exec.Invocation{Leaf.Record{owner,fields},args,[]}),recipe,debug},Exec.Recipe{}})
def added(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Output:Type,args:Args,done:Application(~S,~C,~R,~E,~Owners,~Rows,~observe,~fold,~PriorError,~priorPlan,~priorDispatch,~priorProvide,~L,~Ops,~Args,~Error,~Out,~query,~body) -> Output,failed:Exec.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,fold,PriorError,priorPlan,priorDispatch,priorProvide> -> L -> Output,result:Fields.Appended<Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,fold>,Build.Registered<S,W.World<S,C,R,E>,Owners & Owned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),Rows,observe,Leaf.fold_pair(~S,~Owners,~Owned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~fold,~Fields.fold(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body))>,L>) -> Output:
  match result:
    case Fields.Appended{Build.Registered{world,(owners,owner),recipe,debug}}:added_extracted(~S,~C,~R,~E,~Owners,~Rows,~observe,~fold,~PriorError,~priorPlan,~priorDispatch,~priorProvide,~L,~Ops,~Args,~Error,~Out,~query,~body,~Output,args,done,world,owners,Fields.fields(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,owner),recipe,debug)
    case Fields.AppendRejected{app,capture}:failed(Exec.Registered{app,Exec.Recipe{}},capture)
# Register a captured query during App setup, consuming value and capture.
# On success done receives the extended App. On refusal failed receives the
# returned prior App AND capture, so the caller can recover or explicitly drop
# those affine owners. args is retained for future invocations; name follows
# the ordinary registry rules. No callback runs during this registration.
# During execution, failure rolls back transactional writes and clears row
# outputs, but retains the callback-returned capture: capture mutation is not
# ECS rollback. Failure/refusal do not advance the query reader cursor; success does.
# Deferred structural commands still need the ordinary explicit barrier.
# Runnable example: bash examples/captured-query/run.sh js (or native).
# Its app.bend:add_second shows add; body.bend returns all owners on failure.
def add(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Output:Type,done:Application(~S,~C,~R,~E,~Owners,~Rows,~observe,~fold,~PriorError,~priorPlan,~priorDispatch,~priorProvide,~L,~Ops,~Args,~Error,~Out,~query,~body) -> Output,failed:Exec.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,fold,PriorError,priorPlan,priorDispatch,priorProvide> -> L -> Output,value:Exec.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,fold,PriorError,priorPlan,priorDispatch,priorProvide>,args:Args,name:String,capture:L) -> Output:
  match value:
    case Exec.Registered{app,_}:added(~S,~C,~R,~E,~Owners,~Rows,~observe,~fold,~PriorError,~priorPlan,~priorDispatch,~priorProvide,~L,~Ops,~Args,~Error,~Out,~query,~body,~Output,args,done,failed,Fields.register(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body,~Owners,~Rows,~observe,~fold,app,name,capture))
# Advanced App-composition type projection: prior owners plus this Invocation.
# Use the complete matching execution_* family to name a composed App.
def execution_owners(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))) -> Type:
  Owners & Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body)
# Advanced App-composition type projection: prior inspection rows, unchanged.
# Captured row results are read with outputs, not added to inspection here.
def execution_rows(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))) -> Data:
  Rows
# Advanced App-composition projection: retain the prior World observer.
# This captured leaf does not add a separate inspection-query projection.
def execution_observe(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>:
  observe
# Advanced App-composition projection: collect live registration fields while
# returning every owner, including this query's actual reader cursor.
def execution_fold(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))) -> (Owners & Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body)) -> (Owners & Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body)) & List<&2,Records.Fields<S>>:
  Leaf.fold_pair(~S,~Owners,~Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~fold,~Exec.invocation_fields(~S,~Owned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~Args,~Out))
# Advanced App-composition projection: build the combined registration plan
# without consuming or executing the retained captures.
def execution_plan(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))) -> (Owners & Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body)) -> (Owners & Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body)) & SP.Plan<S>:
  Exec.plan_pair(~S,~Owners,~Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~priorPlan,~Exec.invocation_plan(~S,~Owned(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~Args,~Out))
# Advanced App-composition projection: dispatch a registered ID and return all
# owners/context on success or failure. Prefer App schedule/run in gameplay;
# use the library-generated registration IDs and reader cursors.
def execution_dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))) -> (Owners & Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body)) -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> (Owners & Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body)) & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Choice.Choice<PriorError,ExecutionError<Error>>,Unit>:
  Exec.dispatch_pair(~S,~W.World<S,C,R,E>,~Owners,~Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),~PriorError,~ExecutionError<Error>,~fold,~priorDispatch,~execution_run(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body))
# Advanced App-composition projection: combine prior provisioning requirements.
# This query leaf adds no host-service provisioner and returns the World owner.
def execution_provide(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~PriorError:Data,~priorPlan:Owners -> Owners & SP.Plan<S>,~priorDispatch:Owners -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Owners & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>:
  Exec.provision_pair(~S,~W.World<S,C,R,E>,~priorProvide,~Exec.empty_provide(~S,~W.World<S,C,R,E>))

# Read the repeatable arguments without losing the invocation.
# Returns (invocation, args); the affine capture remains inside the invocation.
def arguments(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body)) -> Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body) & Args:
  match value:
    case Exec.Invocation{record,+args,outputs}:(Exec.Invocation{record,args,outputs},args)
# Read this invocation's latest per-row outputs, preserving the invocation.
# A callback failure or Refused returned by the captured query runner clears
# outputs. An early ID-routing refusal returns the invocation and its previous
# outputs unchanged. Values are Data, not capture owners.
def outputs(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body)) -> Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body) & List<&2,Out>:
  match value:
    case Exec.Invocation{record,args,+outputs}:(Exec.Invocation{record,args,outputs},outputs)
# Replace repeatable invocation arguments, preserving capture, cursor and the
# stored output list. Does not run the query or reset failure visibility.
# See examples/captured-query/app.bend's retry path with Entry.update_owners.
def with_arguments(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~query:Decl.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body),args:Args) -> Invocation(~S,~C,~R,~E,~L,~Ops,~Args,~Error,~Out,~query,~body):
  match value:
    case Exec.Invocation{record,_,outputs}:Exec.Invocation{record,args,outputs}
