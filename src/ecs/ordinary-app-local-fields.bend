import Base
import ./ordinary-app-execution-recipe.bend as Exec
import ./ordinary-app-execution-run.bend as ExecuteRun
import ./execution-context.bend as Ctx
import ./trace-facts.bend as Facts
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
import ./captured-schedule-composition.bend as Choice
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-records.bend as Pair
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./local.bend as Local
import ./world.bend as W
import ./ordinary-app-registration-fields.bend as Fields
import ./ordinary-query-declaration.bend as Query
import ./ordinary-resource-system.bend as P
import ./transaction.bend as T
import ./commands.bend as Cmd
import ./capabilities.bend as Cap
# One ordinary declaration indexes the runner and registration owner. Local is
# returned separately from body Out on both transaction success and failure.
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Error:Data,~Out:Type,local:L,output:Out,result:T.Returned<W.World<S,C,R,E>,Error>) -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>:
  match result:
    case T.Returned{world,T.Success{}}:Local.Succeeded{world,local,output}
    case T.Returned{world,T.Failure{error}}:Local.Failed{world,local,error}
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Error:Data,~Out:Type,result:T.Tx<W.World<S,C,R,E>,E> & (L & (T.Outcome<Error> & Out))) -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>:
  match result:
    case (tx,(local,(outcome,output))):returned(~S,~C,~R,~E,~L,~Error,~Out,local,output,Cmd.tx_finish(~S,~C,~R,~E,~Error,tx,outcome))
# Execute one resource declaration/body with opaque Tx capabilities and actual L.
# Finish the ECS transaction using the returned outcome. Body-returned Local
# persists on success AND failure; failed Out is discarded, not returned as recovery.
# Args is consumed by the callback. This is Local execution, not captured-query
# state rollback, and arbitrary external callback effects are not transactional.
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),world:W.World<S,C,R,E>,local:L,args:Args) -> Local.Outcome<W.World<S,C,R,E>,L,Error,Out>:
  finished(~S,~C,~R,~E,~L,~Error,~Out,body(T.Tx<W.World<S,C,R,E>,E>,P.grant(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration),local,args,T.begin(~W.World<S,C,R,E>,~E,world)))
# Affine owner of the actual Local.Instance, indexed by declaration and body.
# No copied Local payload is retained in registration metadata.
type Owner<-S:Data,-C:Type,-R:Type,-E:Data,-L:Type,-Args:Type,-Error:Data,-Out:Type,-Ops:Type -> Type,-declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,-body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))> is Type:
  Owner{instance:Local.Instance<S,C,R,E,L,Args,Error,Out,runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)>}
# Registration success retains Local in owner; refusal returns actual World and
# incoming L separately, without running the callback.
type Registration<-World:Type,-Owned:Type,-L:Type> is Type:
  Registered{world:World,owner:Owned}
  Rejected{world:World,local:L}
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),result:Local.Registered<S,C,R,E,L,Args,Error,Out,runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)>) -> Registration<W.World<S,C,R,E>,Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,L>:
  match result:
    case Local.Registered{world,instance}:Registered{world,Owner{instance}}
    case Local.RegistrationRejected{world,local}:Rejected{world,local}
# Register the Local runner using access derived from the same resource declaration.
# Returns Registration with actual owners; does not execute the body or fabricate
# a query reader. Closed declarations/projections remain trusted provisioning.
def define(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),world:W.World<S,C,R,E>,name:String,local:L) -> Registration<W.World<S,C,R,E>,Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,L>:
  registered(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,Local.register(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body),world,name,P.access(~S,P.clause(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration)),local))
# Run the retained Local instance after actual registration/World validation.
# Completed returns the updated instance and Done(Out) or Fail(Error); callback
# failure still retains its returned Local. Refused returns World, instance and
# unconsumed Args. No implicit barrier, skip processing or disposal is performed.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,world:W.World<S,C,R,E>,args:Args) -> Local.Run<S,C,R,E,L,Args,Error,Out,runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)>:
  match value:
    case Owner{instance}:Local.run(~S,~C,~R,~E,~L,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body),instance,world,args)
def field_values(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),instance:Local.Instance<S,C,R,E,L,Args,Error,Out,runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)>,clause:Query.Clause<S>) -> Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Fields.Fields<S>:
  match instance clause:
    case Local.Instance{+namespace,+id,+name,+access,local} Query.Clause{+slot,+mode}:(Owner{Local.Instance{namespace,id,name,access,local}},Fields.Fields{namespace,id,name,access,None{},slot,[Query.Clause{slot,mode}],Fields.ResourceKind{mode}})
# Local has no retained query reader cursor; None marks this nonreader metadata.
# Project registration fields while returning Owner. Resource slot/mode/access
# come from the operational declaration; Local payload remains opaque. The absent cursor
# is metadata, not a live lifecycle/event reader position.
def fields(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) -> Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Fields.Fields<S>:
  match value:
    case Owner{instance}:field_values(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,instance,P.clause(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration))
def fields_list_returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),result:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Fields.Fields<S>) -> Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & List<&2,Fields.Fields<S>>:
  match result:
    case (value,field):(value,[field])
# Advanced singleton registration fold retaining Owner and its actual Local.
# Produces metadata only, not an additional resource grant or gameplay invocation.
def fold(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) -> Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & List<&2,Fields.Fields<S>>:
  fields_list_returned(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,fields(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,value))
# Registration into an App either returns the extended App or the prior App shape
# with actual incoming Local. No automatic destructor runs on AppendRejected.
type Appended<-Before:Type,-After:Type,-L:Type> is Type:
  Appended{app:After}
  AppendRejected{app:Before,local:L}
# Ordinary registration composes the derived fold itself; application authors
# provide only operational declaration/body and Local, never metadata adapters.
def appended(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,previous:Previous,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,result:Registration<W.World<S,C,R,E>,Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,L>) -> Appended<Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold>,Build.Registered<S,W.World<S,C,R,E>,Previous & Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,Rows,observe,Pair.fold_pair(~S,~Previous,~Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,~previousFold,~fold(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body))>,L>:
  match result:
    case Rejected{world,local}:AppendRejected{Build.Registered{world,previous,recipe,debug},local}
    case Registered{world,owner}:Appended{Build.Registered{world,(previous,owner),recipe,debug}}
# Register into a composer App, deriving the metadata fold and retaining prior
# owners/observer/debug. On refusal return prior App shape and Local; does not run
# body. See test-fixtures/public-schedules/named-app-v1/matched-feature-v1/fixture.bend.
def register(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Type,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,app:Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold>,name:String,local:L) -> Appended<Build.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold>,Build.Registered<S,W.World<S,C,R,E>,Previous & Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,Rows,observe,Pair.fold_pair(~S,~Previous,~Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,~previousFold,~fold(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body))>,L>:
  match app:
    case Build.Registered{world,previous,recipe,debug}:appended(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,~Previous,~Rows,~observe,~previousFold,previous,recipe,debug,define(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,world,name,local))

# Schedule-facing distinction between callback transaction failure and refused
# registration/routing. Neither branch implies Local was rolled back.
type ExecutionError<Error:Data> is Data:
  CallbackFailure{error:Error}
  RegistrationRefused{}
# Executable invocation retaining actual Local owner and reusable Data Args.
# It stores no Out: schedule execution discards successful Out after completion.
type Invocation<-S:Data,-C:Type,-R:Type,-E:Data,-L:Type,-Args:Data,-Error:Data,-Out:Type,-Ops:Type -> Type,-declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,-body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out))> is Type:
  Invocation{owner:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,args:Args}
def execution_folded(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),args:Args,result:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & List<&2,Fields.Fields<S>>) -> Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & List<&2,Fields.Fields<S>>:
  match result:
    case (owner,fields):(Invocation{owner,args},fields)
# Advanced owner-returning fold of invocation metadata, retaining stored Args.
def execution_fields(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) -> Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & List<&2,Fields.Fields<S>>:
  match value:
    case Invocation{owner,args}:execution_folded(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,args,fold(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,owner))
def execution_planned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),args:Args,result:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Fields.Fields<S>) -> Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & SP.Plan<S>:
  match result:
    case (owner,Fields.Fields{_,id,_,_,_,_,_,_}):(Invocation{owner,args},SP.Entry{Sch.System{id,0},[]})
# Advanced owner-returning single-id plan at condition slot zero with no explicit
# requirements. Does not derive requirements from field metadata or run Local.
def execution_plan(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) -> Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & SP.Plan<S>:
  match value:
    case Invocation{owner,args}:execution_planned(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,args,fields(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,owner))
def execution_returned(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),args:Args,trace:Facts.State,result:Local.Run<S,C,R,E,L,Args,Error,Out,runner(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)>) -> Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,ExecutionError<Error>,Unit>:
  match result:
    case Local.Completed{world,instance,Done{_},_}:(Invocation{Owner{instance},args},Sys.Succeeded{Ctx.Context{world,trace},Unit{}})
    case Local.Completed{world,instance,Fail{error},_}:(Invocation{Owner{instance},args},Sys.Failed{Ctx.Context{world,trace},CallbackFailure{error}})
    case Local.Refused{world,instance,_}:(Invocation{Owner{instance},args},Sys.Failed{Ctx.Context{world,trace},RegistrationRefused{}})
def execution_allowed(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),valid:Bool,owner:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,args:Args,context:Ctx.Context<W.World<S,C,R,E>>) -> Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,ExecutionError<Error>,Unit>:
  match valid context:
    case False{} context:(Invocation{owner,args},Sys.Failed{context,RegistrationRefused{}})
    case True{} Ctx.Context{world,trace}:
      +actual=args
      execution_returned(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,actual,trace,run(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,owner,world,actual))
def execution_selected(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),args:Args,context:Ctx.Context<W.World<S,C,R,E>>,id:U32,result:Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Fields.Fields<S>) -> Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,ExecutionError<Error>,Unit>:
  match result:
    case (owner,fields):execution_allowed(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,U32.is_eq(id,Exec.registration_id(~S,fields)),owner,args,context)
# Advanced id-routed dispatch. Mismatched id returns invocation/context unchanged
# with RegistrationRefused. Matched execution preserves reusable Data Args and
# retains the returned Local instance; callback failure maps to CallbackFailure,
# while successful Out is discarded. Trace context is carried separately.
# This adapter installs no skip/cursor-advance or Local disposal callback.
def execution_run(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),value:Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,context:Ctx.Context<W.World<S,C,R,E>>,id:U32) -> Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body> & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,ExecutionError<Error>,Unit>:
  match value:
    case Invocation{owner,args}:execution_selected(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,args,context,id,fields(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,owner))
# Advanced execution-enabled App type with prior owners plus Local invocation.
# Uses prior observation unchanged and adds registration fields/plan/dispatch;
# this does not expose Local to unrelated systems or reset it on failed execution.
def Executable(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,~PriorError:Data,~priorPlan:Previous -> Previous & SP.Plan<S>,~priorDispatch:Previous -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Previous & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> Type:
  Exec.Registered<S,W.World<S,C,R,E>,Previous & Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,Rows,observe,Pair.fold_pair(~S,~Previous,~Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,~previousFold,~execution_fields(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)),Choice.Choice<PriorError,ExecutionError<Error>>,Exec.plan_pair(~S,~Previous,~Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,~priorPlan,~execution_plan(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)),Exec.dispatch_pair(~S,~W.World<S,C,R,E>,~Previous,~Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,~PriorError,~ExecutionError<Error>,~previousFold,~priorDispatch,~execution_run(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body)),Exec.provision_pair(~S,~W.World<S,C,R,E>,~priorProvide,~Exec.empty_provide(~S,~W.World<S,C,R,E>))>
def execution_added(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,~PriorError:Data,~priorPlan:Previous -> Previous & SP.Plan<S>,~priorDispatch:Previous -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Previous & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,args:Args,previous:Previous,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,result:Registration<W.World<S,C,R,E>,Owner<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,L>) -> Appended<Exec.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold,PriorError,priorPlan,priorDispatch,priorProvide>,Executable(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,~Previous,~Rows,~observe,~previousFold,~PriorError,~priorPlan,~priorDispatch,~priorProvide),L>:
  match result:
    case Rejected{world,local}:AppendRejected{Exec.Registered{Build.Registered{world,previous,recipe,debug},Exec.Recipe{}},local}
    case Registered{world,owner}:Appended{Exec.Registered{Build.Registered{world,(previous,Invocation{owner,args}),recipe,debug},Exec.Recipe{}}}
# Register Local and Data Args into an execution-enabled App, deriving composition
# from the declaration. Refusal returns prior App and actual L; success retains
# L and Args for later dispatch. No run, condition skip or disposal happens here.
# Explicit lifecycle cleanup remains in local.bend rather than an implicit finalizer.
def add(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,~PriorError:Data,~priorPlan:Previous -> Previous & SP.Plan<S>,~priorDispatch:Previous -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Previous & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Exec.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold,PriorError,priorPlan,priorDispatch,priorProvide>,name:String,local:L,args:Args) -> Appended<Exec.Registered<S,W.World<S,C,R,E>,Previous,Rows,observe,previousFold,PriorError,priorPlan,priorDispatch,priorProvide>,Executable(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,~Previous,~Rows,~observe,~previousFold,~PriorError,~priorPlan,~priorDispatch,~priorProvide),L>:
  match value:
    case Exec.Registered{Build.Registered{world,previous,recipe,debug},_}:execution_added(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,~Previous,~Rows,~observe,~previousFold,~PriorError,~priorPlan,~priorDispatch,~priorProvide,args,previous,recipe,debug,define(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body,world,name,local))
# Advanced type projection of prior owners paired with actual Local invocation.
def execution_owners(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,~PriorError:Data,~priorPlan:Previous -> Previous & SP.Plan<S>,~priorDispatch:Previous -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Previous & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> Type:
  Previous & Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>
# Advanced detached row projection: Local adds metadata, not observation rows.
def execution_rows(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,~PriorError:Data,~priorPlan:Previous -> Previous & SP.Plan<S>,~priorDispatch:Previous -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Previous & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> Data:
  Rows
# Advanced observer projection retaining the prior observer exactly; Local is
# not automatically rendered or inspected by this adapter.
def execution_observe(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,~PriorError:Data,~priorPlan:Previous -> Previous & SP.Plan<S>,~priorDispatch:Previous -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Previous & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>:
  observe
# Advanced closed fold of prior fields followed by Local invocation metadata.
def execution_fold(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,~PriorError:Data,~priorPlan:Previous -> Previous & SP.Plan<S>,~priorDispatch:Previous -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Previous & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> (Previous & Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) -> (Previous & Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) & List<&2,Fields.Fields<S>>:
  Pair.fold_pair(~S,~Previous,~Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,~previousFold,~execution_fields(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body))
# Advanced closed plan composition: prior plan then Local id, retaining owners.
def composed_plan(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,~PriorError:Data,~priorPlan:Previous -> Previous & SP.Plan<S>,~priorDispatch:Previous -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Previous & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> (Previous & Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) -> (Previous & Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) & SP.Plan<S>:
  Exec.plan_pair(~S,~Previous,~Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,~priorPlan,~execution_plan(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body))
# Advanced closed routing to prior or Local invocation with tagged error branches.
# Dispatch preserves actual owners; it is not a shared Local or capture transaction.
def execution_dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,~PriorError:Data,~priorPlan:Previous -> Previous & SP.Plan<S>,~priorDispatch:Previous -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Previous & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> (Previous & Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> (Previous & Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>) & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Choice.Choice<PriorError,ExecutionError<Error>>,Unit>:
  Exec.dispatch_pair(~S,~W.World<S,C,R,E>,~Previous,~Invocation<S,C,R,E,L,Args,Error,Out,Ops,declaration,body>,~PriorError,~ExecutionError<Error>,~previousFold,~priorDispatch,~execution_run(~S,~C,~R,~E,~L,~Args,~Error,~Out,~Ops,~declaration,~body))
# Advanced provisioning composition: preserve prior provisioning and add no
# extra requirements for this Local registration.
def execution_provide(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type,~Args:Data,~Error:Data,~Out:Type,~Ops:Type -> Type,~declaration:P.Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> L -> Args -> H -> H & (L & (T.Outcome<Error> & Out)),~Previous:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~previousFold:Previous -> Previous & List<&2,Fields.Fields<S>>,~PriorError:Data,~priorPlan:Previous -> Previous & SP.Plan<S>,~priorDispatch:Previous -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> Previous & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,PriorError,Unit>,~priorProvide:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>:
  Exec.provision_pair(~S,~W.World<S,C,R,E>,~priorProvide,~Exec.empty_provide(~S,~W.World<S,C,R,E>))
