import Base
import ./trace-facts.bend as TraceFacts
import ./ordinary-schema.bend as Schema
import ./ordinary-query-declaration.bend as Query
import ./world.bend as W
import ./system.bend as Sys
import ./resource-legacy.bend as Res
import ./transaction.bend as T
import ./commands.bend as Cmd
import ./capabilities.bend as Cap
# Static declaration: one ordinary identity supplies operational grant and metadata.
# Current resource operations replace the entire Resources owner, not one field.
# Retained whole-resource identity, access mode and operational grant. R may be
# affine Type; this declaration does not narrow replacement to a selected field.
# Raw declaration/adapters remain trusted, rather than authority created by strings.
type Declaration<-S:Data,-R:Type,-H:Type,-Ops:Type> is Type:
  Declaration{identity:Schema.Resource<S,R>,kind:Query.Mode,grant:Ops}
# Build whole-resource read declaration exposing detached V through an owner-
# returning projector. This supplies no setter and does not copy the actual R.
def read(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V,identity:Schema.Resource<S,R>) -> Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Cap.ValueRead<T.Tx<W.World<S,C,R,E>,E>,V>>:
  Declaration{identity,Query.Read{},Cap.ValueRead{Res.tx_get(~S,~C,~R,~E,~V,~project)}}
# Build whole-R read/replacement declaration. Setter consumes incoming R and
# journals displaced R for ordinary rollback; it returns no recovery receipt.
def write(~S:Data,~C:Type,~R:Type,~E:Data,~V:Data,~project:R -> R & V,identity:Schema.Resource<S,R>) -> Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Cap.ValueWrite<T.Tx<W.World<S,C,R,E>,E>,R,V>>:
  Declaration{identity,Query.Write{},Cap.ValueWrite{Res.tx_get(~S,~C,~R,~E,~V,~project),Res.tx_replace(~S,~C,~R,~E)}}
# Advanced declaration projection of operational caps; does not invoke them.
def grant(~S:Data,~R:Type,~H:Type,~Ops:Type,declaration:Declaration<S,R,H,Ops>) -> Ops:
  match declaration:
    case Declaration{_,_,grant}:grant
# Derive the resource key/mode clause from the same retained declaration.
def clause(~S:Data,~R:Type,~H:Type,~Ops:Type,declaration:Declaration<S,R,H,Ops>) -> Query.Clause<S>:
  match declaration:
    case Declaration{identity,kind,_}:Query.Clause{Schema.resource_key(~S,~R,identity),kind}
# Project the declared read/write mode without inspecting resource storage.
def mode(~S:Data,~R:Type,~H:Type,~Ops:Type,declaration:Declaration<S,R,H,Ops>) -> Query.Mode:
  match declaration:
    case Declaration{_,kind,_}:kind
# Description allocation is explicit observation work, not registration work.
# Presentation adapter expanding access names into same-mode detached clauses.
# Does not validate grants, allocate a registry or invoke a resource operation.
def descriptions(~S:Data,+kind:Query.Mode,names:List<&2,String>) -> List<&2,Query.Clause<S>>:
  match names:
    case []:[]
    case name <> rest:Query.Clause{name,kind} <> descriptions(~S,kind,rest)
# Project the singleton operational resource name used for registration metadata.
def access(~S:Data,value:Query.Clause<S>) -> List<&2,String>:
  match value:
    case Query.Clause{name,_}:[name]
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Type,output:Out,result:T.Returned<W.World<S,C,R,E>,Error>) -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>:
  match result:
    case T.Returned{world,T.Success{}}:Sys.Succeeded{world,output}
    case T.Returned{world,T.Failure{error}}:Sys.Failed{world,error}
def finished(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Type,result:T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Error> & Out)) -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>:
  match result:
    case (tx,(outcome,output)):returned(~S,~C,~R,~E,~Error,~Out,output,Cmd.tx_finish(~S,~C,~R,~E,~Error,tx,outcome))
# Invoke the opaque-owner body in one fresh ECS transaction with declaration caps.
# Args and Out may own Type payloads. Success returns Out; failure rolls back
# recorded ECS edits and discards Out. Deferred commands require a later barrier;
# ordinary rollback is not owned recovery or reversal of external callback effects.
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~declaration:Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,args:Args) -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>:
  finished(~S,~C,~R,~E,~Error,~Out,Cap.invoke_owned(~Ops,~Args,~(T.Outcome<Error> & Out),~body,~T.Tx<W.World<S,C,R,E>,E>,~grant(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration),args,T.begin(~W.World<S,C,R,E>,~E,world)))
# Affine registry owner plus presentation slot, indexed by declared access mode.
# Resource payload remains in World, not copied into this registration metadata.
type Owner<-S:Data,-Registry:Type,-kind:Query.Mode> is Type:
  Owner{registry:Registry,slot:String}
# Registration result returning World in both branches; Defined retains registry
# in Owner and Rejected has no newly allocated runner owner.
type Defined<-S:Data,-World:Type,-Registry:Type,-kind:Query.Mode> is Type:
  Defined{world:World,owner:Owner<S,Registry,kind>}
  Rejected{world:World}
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~run:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,slot:String,result:Sys.RegistrationResult<S,C,R,E,Args,Error,Out,run>) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,Args,Error,Out,run>,kind>:
  match result:
    case Sys.RegistrationFailed{world}:Rejected{world}
    case Sys.Registered{world,registry}:Defined{world,Owner{registry,slot}}
# Register the declaration-bound runner with its derived access. slot is retained
# for presentation and does not change operational resource authority. No body runs
# at registration. See the named-app matched-feature fixture under test-fixtures.
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~declaration:Declaration<S,R,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,name:String,slot:String) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,Args,Error,Out,runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~declaration,~body)>,mode(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration)>:
  registered(~S,~C,~R,~E,~Args,~Error,~Out,~mode(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration),~runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~declaration,~body),slot,Sys.register(~S,~C,~R,~E,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~declaration,~body),world,name,access(~S,clause(~S,~R,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration))))
# Registry's existing namespace and registration checks remain authoritative.
# Run tracked registration, returning its full success/refusal result plus slot.
# Refusal retains actual registry, World and Args under Sys.RunResult; successful
# execution returns callback Out, while callback failure does not return Out.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,owner:Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>,world:W.World<S,C,R,E>,args:Args) -> Sys.RunResult<S,C,R,E,Args,Error,Out,runner> & String:
  match owner:
    case Owner{registry,slot}:(Sys.run(~S,~C,~R,~E,~Args,~Error,~Out,~runner,registry,world,args),slot)

# Called by an enabled debug bridge; actual Registry is borrowed and reconstructed.
# Enabled-observation adapter returning actual Owner and detached access clauses.
# Does not inspect resource payloads or grant access from the presentation slot.
def describe(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~kind:Query.Mode,~runner:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,owner:Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind>) -> Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,runner>,kind> & List<&2,Query.Clause<S>>:
  match owner:
    case Owner{Sys.Registry{namespace,id,name,+access,cursor},slot}:
      (Owner{Sys.Registry{namespace,id,name,access,cursor},slot},descriptions(~S,kind,access))

def returned_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Type,output:Out,result:T.Returned<W.World<S,C,R,E>,Error> & TraceFacts.State) -> Sys.Outcome<W.World<S,C,R,E>,Error,Out> & TraceFacts.State:
  match result:
    case (value,trace):(returned(~S,~C,~R,~E,~Error,~Out,output,value),trace)
# Same user body and grants, with detached transaction facts returned beside it.
# Advanced runner finish adapter retaining detached transaction facts separately
# from World outcome. Same commit/rollback and failure-Out disposal as runner;
# attempted facts are not evidence that failed transaction writes committed.
def finished_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Type,result:T.Tx<W.World<S,C,R,E>,E> & (T.Outcome<Error> & Out)) -> Sys.Outcome<W.World<S,C,R,E>,Error,Out> & TraceFacts.State:
  match result:
    case (tx,(outcome,output)):returned_observed(~S,~C,~R,~E,~Error,~Out,output,T.finish_observed(~W.World<S,C,R,E>,~E,~Error,~Cmd.enqueue(~S,~C,~R,~E),~Cmd.publish(~S,~C,~R,~E),tx,outcome))
