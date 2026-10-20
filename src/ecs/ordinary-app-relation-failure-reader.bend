import Base
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-records.bend as Records
import ./ordinary-app-recipe.bend as Tree
import ./internal/relation-failures/domains.bend as D
import ./world.bend as W
import ./system.bend as Sys
import ./relation-commands.bend as Notice
import ./relation-types.bend as G
import ./relation-failure-runtime.bend as K
import ./relation-failure-reader.bend as Decl
import ./event-notice-runtime.bend as Mixed
import ./event-family-runtime.bend as Family
import ./event-family-routing.bend as Route
import ./ordinary-app-registration-fields.bend as Fields
import ./ordinary-query-declaration.bend as Query

# Retains the same operative declaration and the actual descriptor Reader/Registry.
type Owner<S:Data,Reader:Type> is Type:Owner{declaration:Decl.Declaration<S>,reader:Reader}
# Specialize the affine reader owner to its world, argument and runner types.
def OwnerType(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>) -> Type:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>
# Return the same reader owner with detached registration/debug fields, including
# its current registry cursor and the declared relation read clause.
def fields(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,owner:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>) -> Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>> & List<&2,Fields.Fields<S>>:
  match owner:
    case Owner{Decl.Declaration{G.Descriptor{+key,+name,+inverse,+kind}},K.Reader{Sys.Registry{+namespace,+id,+systemName,+access,+cursor},+keys,readerId}}:(Owner{Decl.Declaration{G.Descriptor{key,name,inverse,kind}},K.Reader{Sys.Registry{namespace,id,systemName,access,cursor},keys,readerId}},[Fields.Fields{namespace,id,systemName,access,cursor,name,[Query.Clause{name,Query.Read{}}],Fields.EventKind{}}])
# Registration returns the mixed runtime on both branches; only Registered
# supplies a reader owner. Other event-family state is reattached on refusal.
type Registration<S:Data,C:Type,R:Type,P:Data,F:Type,H:Type,Owner:Type> is Type:
  Registered{runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,owner:Owner}
  RegistrationFailed{runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>}
def registered(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,held:Family.State<P,F,H> & Nat,declaration:Decl.Declaration<S>,result:K.Registered<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>) -> Registration<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>>:
  match result:
    case K.RegistrationFailed{runtime}:RegistrationFailed{Mixed.failure_returned(~S,~C,~R,~P,~F,~H,held,runtime)}
    case K.Registered{runtime,reader}:Registered{Mixed.failure_returned(~S,~C,~R,~P,~F,~H,held,runtime),Owner{declaration,reader}}
# Advanced registration from a detached failure runtime and held family state.
# Reattach that state on success or refusal; select the single declared relation.
def register_detached(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,+declaration:Decl.Declaration<S>,name:String,detached:K.Runtime<S,C,R,Notice.Notice<S,P>> & Family.State<P,F,H> & Nat) -> Registration<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>>:
  match detached:
    case (runtime,held):registered(~S,~C,~R,~P,~A,~Error,~Out,~runner,~F,~H,held,declaration,Decl.register(~S,~C,~R,~Notice.Notice<S,P>,~A,~Error,~Out,~runner,runtime,[declaration],name))
# Register an independent reader for this relation declaration in the mixed
# runtime. Return its owner on success, or RegistrationFailed with the runtime.
def register(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,declaration:Decl.Declaration<S>,name:String) -> Registration<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>>:register_detached(~S,~C,~R,~P,~A,~Error,~Out,~runner,~F,~H,declaration,name,Mixed.failure_runtime(~S,~C,~R,~P,~F,~H,runtime))
# Every completion returns the runtime and reader owner. Inspect completion
# for output, system failure or refusal rather than interpreting Ran as success.
type RunResult<S:Data,C:Type,R:Type,P:Data,F:Type,H:Type,Owner:Type,Error:Data,Out:Type,A:Type> is Type:
  Ran{runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,owner:Owner,completion:K.Completion<Error,Out,A>}
def ran(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,declaration:Decl.Declaration<S>,held:Family.State<P,F,H> & Nat,result:K.RunResult<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>) -> RunResult<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,Error,Out,A>:
  match result:
    case K.Ran{runtime,reader,completion}:Ran{Mixed.failure_returned(~S,~C,~R,~P,~F,~H,held,runtime),Owner{declaration,reader},completion}
def completed_owner(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,held:Family.State<P,F,H> & Nat,runtime:K.Runtime<S,C,R,Notice.Notice<S,P>>,args:A,owner:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>) -> RunResult<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,Error,Out,A>:
  match owner:
    case Owner{declaration,reader}:ran(~S,~C,~R,~P,~A,~Error,~Out,~runner,~F,~H,declaration,held,K.run(~S,~C,~R,~Notice.Notice<S,P>,~A,~Error,~Out,~runner,~classify,runtime,reader,args))
# Advanced execution with already detached failure/family state. Reattach the
# family state and return the reader owner for every underlying completion.
def run_detached(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,owner:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,args:A,detached:K.Runtime<S,C,R,Notice.Notice<S,P>> & Family.State<P,F,H> & Nat) -> RunResult<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,Error,Out,A>:
  match detached:
    case (runtime,held):completed_owner(~S,~C,~R,~P,~A,~Error,~Out,~runner,~F,~H,~classify,held,runtime,args,owner)
# Run this registered relation reader through the failure runtime, returning
# its updated owner and completion. The trusted classify callback identifies
# relation failures; use the same schema and notice classification as registration.
# Readings use this reader's independent position and report retained-history lag.
# Success acknowledges through the returned clock; failure does not acknowledge
# new notices, but may activate a missing position. Rejection returns args without
# advancing reader positions. World recovery follows the supplied runner contract.
# See relation-failure-runtime.bend for completion and retention details.
def run(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,owner:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,args:A) -> RunResult<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,Error,Out,A>:run_detached(~S,~C,~R,~P,~A,~Error,~Out,~runner,~F,~H,~classify,owner,args,Mixed.failure_runtime(~S,~C,~R,~P,~F,~H,runtime))
# Composer observation for a reader registration: preserve the world and emit
# Unit with no rows. This does not execute or acknowledge the reader.
def observe(~S:Data,~C:Type,~R:Type,~P:Data,world:W.World<S,C,R,Notice.Notice<S,P>>) -> W.World<S,C,R,Notice.Notice<S,P>> & DTO.Observation<Unit>:(world,DTO.Observation{Unit{},[]})
# Append an existing reader owner to an App registration product. Preserve
# previous observations, add Unit rows and fold this reader's debug fields;
# appending alone does not run the reader.
def append(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,Notice.Notice<S,P>> -> W.World<S,C,R,Notice.Notice<S,P>> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,owner:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,value:Build.Registered<S,W.World<S,C,R,Notice.Notice<S,P>>,Owners,Rows,prior,fold>) -> Build.Registered<S,W.World<S,C,R,Notice.Notice<S,P>>,Owners & Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,DTO.Product<Rows,Unit>,Tree.observe_pair(~W.World<S,C,R,Notice.Notice<S,P>>,~Rows,~Unit,~prior,~observe(~S,~C,~R,~P)),Records.fold_pair(~S,~Owners,~Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,~fold,~fields(~S,~C,~R,~P,~A,~Error,~Out,~runner))>:
  match value:
    case Build.Registered{world,owners,_,debug}:Build.appended(~S,~W.World<S,C,R,Notice.Notice<S,P>>,~Owners,~Rows,~prior,~fold,~Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,~Unit,~observe(~S,~C,~R,~P),~fields(~S,~C,~R,~P,~A,~Error,~Out,~runner),world,owners,owner,debug)
