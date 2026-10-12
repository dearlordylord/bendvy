import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/domains.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Notice
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/event-notice-runtime.bend as Mixed
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query

# Retains the same operative declaration and the actual descriptor Reader/Registry.
type Owner<S:Data,Reader:Type> is Type:Owner{declaration:Decl.Declaration<S>,reader:Reader}
def OwnerType(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>) -> Type:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>
def fields(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,owner:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>) -> Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>> & List<&2,Fields.Fields<S>>:
  match owner:
    case Owner{Decl.Declaration{G.Descriptor{+key,+name,+inverse,+kind}},K.Reader{Sys.Registry{+namespace,+id,+systemName,+access,+cursor},+keys}}:(Owner{Decl.Declaration{G.Descriptor{key,name,inverse,kind}},K.Reader{Sys.Registry{namespace,id,systemName,access,cursor},keys}},[Fields.Fields{namespace,id,systemName,access,cursor,name,[Query.Clause{name,Query.Read{}}],Fields.EventKind{}}])
type Registration<S:Data,C:Type,R:Type,P:Data,F:Type,H:Type,Owner:Type> is Type:
  Registered{runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,owner:Owner}
  RegistrationFailed{runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>}
def registered(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,held:Family.State<P,F,H> & Nat,declaration:Decl.Declaration<S>,result:K.Registered<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>) -> Registration<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>>:
  match result:
    case K.RegistrationFailed{runtime}:RegistrationFailed{Mixed.failure_returned(~S,~C,~R,~P,~F,~H,held,runtime)}
    case K.Registered{runtime,reader}:Registered{Mixed.failure_returned(~S,~C,~R,~P,~F,~H,held,runtime),Owner{declaration,reader}}
def register_detached(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,+declaration:Decl.Declaration<S>,name:String,detached:K.Runtime<S,C,R,Notice.Notice<S,P>> & Family.State<P,F,H> & Nat) -> Registration<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>>:
  match detached:
    case (runtime,held):registered(~S,~C,~R,~P,~A,~Error,~Out,~runner,~F,~H,held,declaration,Decl.register(~S,~C,~R,~Notice.Notice<S,P>,~A,~Error,~Out,~runner,runtime,[declaration],name))
def register(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,declaration:Decl.Declaration<S>,name:String) -> Registration<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>>:register_detached(~S,~C,~R,~P,~A,~Error,~Out,~runner,~F,~H,declaration,name,Mixed.failure_runtime(~S,~C,~R,~P,~F,~H,runtime))
type RunResult<S:Data,C:Type,R:Type,P:Data,F:Type,H:Type,Owner:Type,Error:Data,Out:Type,A:Type> is Type:
  Ran{runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,owner:Owner,completion:K.Completion<Error,Out,A>}
def ran(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,declaration:Decl.Declaration<S>,held:Family.State<P,F,H> & Nat,result:K.RunResult<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>) -> RunResult<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,Error,Out,A>:
  match result:
    case K.Ran{runtime,reader,completion}:Ran{Mixed.failure_returned(~S,~C,~R,~P,~F,~H,held,runtime),Owner{declaration,reader},completion}
def completed_owner(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,held:Family.State<P,F,H> & Nat,runtime:K.Runtime<S,C,R,Notice.Notice<S,P>>,args:A,owner:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>) -> RunResult<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,Error,Out,A>:
  match owner:
    case Owner{declaration,reader}:ran(~S,~C,~R,~P,~A,~Error,~Out,~runner,~F,~H,declaration,held,K.run(~S,~C,~R,~Notice.Notice<S,P>,~A,~Error,~Out,~runner,~classify,runtime,reader,args))
def run_detached(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,owner:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,args:A,detached:K.Runtime<S,C,R,Notice.Notice<S,P>> & Family.State<P,F,H> & Nat) -> RunResult<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,Error,Out,A>:
  match detached:
    case (runtime,held):completed_owner(~S,~C,~R,~P,~A,~Error,~Out,~runner,~F,~H,~classify,held,runtime,args,owner)
def run(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~F:Type,~H:Type,~classify:Notice.Notice<S,P> -> Maybe<D.DescriptorKey<S>>,runtime:Route.Runtime<S,C,R,Notice.Notice<S,P>,Mixed.State<S,P,F,H>>,owner:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,args:A) -> RunResult<S,C,R,P,F,H,Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,Error,Out,A>:run_detached(~S,~C,~R,~P,~A,~Error,~Out,~runner,~F,~H,~classify,owner,args,Mixed.failure_runtime(~S,~C,~R,~P,~F,~H,runtime))
def observe(~S:Data,~C:Type,~R:Type,~P:Data,world:W.World<S,C,R,Notice.Notice<S,P>>) -> W.World<S,C,R,Notice.Notice<S,P>> & DTO.Observation<Unit>:(world,DTO.Observation{Unit{},[]})
def append(~S:Data,~C:Type,~R:Type,~P:Data,~A:Type,~Error:Data,~Out:Type,~runner:W.World<S,C,R,Notice.Notice<S,P>> -> K.Input<S,Notice.Notice<S,P>,A> -> Sys.Outcome<W.World<S,C,R,Notice.Notice<S,P>>,Error,Out>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,Notice.Notice<S,P>> -> W.World<S,C,R,Notice.Notice<S,P>> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,owner:Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,value:Build.Registered<S,W.World<S,C,R,Notice.Notice<S,P>>,Owners,Rows,prior,fold>) -> Build.Registered<S,W.World<S,C,R,Notice.Notice<S,P>>,Owners & Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,DTO.Product<Rows,Unit>,Tree.observe_pair(~W.World<S,C,R,Notice.Notice<S,P>>,~Rows,~Unit,~prior,~observe(~S,~C,~R,~P)),Records.fold_pair(~S,~Owners,~Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,~fold,~fields(~S,~C,~R,~P,~A,~Error,~Out,~runner))>:
  match value:
    case Build.Registered{world,owners,_,debug}:Build.appended(~S,~W.World<S,C,R,Notice.Notice<S,P>>,~Owners,~Rows,~prior,~fold,~Owner<S,K.Reader<S,C,R,Notice.Notice<S,P>,A,Error,Out,runner>>,~Unit,~observe(~S,~C,~R,~P),~fields(~S,~C,~R,~P,~A,~Error,~Out,~runner),world,owners,owner,debug)
