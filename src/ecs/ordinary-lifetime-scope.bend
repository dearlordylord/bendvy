import Base
import ./lifetime-scope.bend as Sc
import ./lifetime-scope-world-spawn.bend as Spawn
import ./world.bend as W
import ./ordinary-schema.bend as Schema
import ./ordinary-schema-provision.bend as Provision
import ./relation-commands.bend as A
import ./relation-types.bend as G
import ./relation-failure-reader.bend as Rel
import ./ordinary-app-linked-cleanup.bend as LC
import ./ordinary-app-linked-cleanup-system.bend as LCS
import ./ordinary-component-clear-declaration.bend as Clear
import ./column.bend as Col
import ./ordinary-component-binding.bend as Binding
import ./capabilities.bend as Cap
import ./transaction.bend as T
import ./commands.bend as Cmd
import ./system.bend as Sys

# Scope metadata does not add a component/schema entry. Original owners survive.
# Trusted schema adapter: build an empty component store with scope membership
# and relation-graph wrappers. Component payload C may contain affine owners;
# empty constructs C once. Scope membership adds no component schema entry.
def empty_store(~S:Data,~C:Type,~empty:Unit -> C,unit:Unit) -> A.Store<S,Sc.Store<S,C>>:
  A.empty(~S,~Sc.Store<S,C>,Sc.empty(~S,~C,empty(unit)))
def counted(~S:Data,~C:Type,members:List<&2,Sc.Member>,graph:G.Graph<S>,seen:C & List<&2,Maybe<&2,U32>>) -> A.Store<S,Sc.Store<S,C>> & List<&2,Maybe<&2,U32>>:
  match seen:
    case (components,counts):(A.Store{Sc.Store{components,members},graph},counts)
# Trusted provisioning adapter: run the original component counter through the
# scope/relation wrappers. Returns the wrapped store with its membership and
# graph owners threaded back; counting does not assign scopes or delete entities.
def count_store(~S:Data,~C:Type,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,store:A.Store<S,Sc.Store<S,C>>,handles:List<&2,W.Handle<S>>) -> A.Store<S,Sc.Store<S,C>> & List<&2,Maybe<&2,U32>>:
  match store:
    case A.Store{Sc.Store{components,members},graph}:counted(~S,~C,members,graph,count(components,handles))
# Lift an ordinary schema to the scope/relation-wrapped Store type.
# Preserves the existing entries and resource schema; no synthetic scope component
# is registered. Use this during setup, not to change a live World's schema.
def schema(~S:Data,~C:Type,~R:Type,value:Schema.Schema<S,C,R>) -> Schema.Schema<S,A.Store<S,Sc.Store<S,C>>,R>:
  match value:
    case Schema.Schema{entries}:Schema.Schema{entries}
# Lift the matching schema provision with its empty/count adapters.
# The component/resource entries remain unchanged while the Store gains scope
# membership and relation state. Pass the result to ordinary-lifetime-scope-io.create.
# Concrete setup: test-fixtures/public-scopes/feature-timing-v1/fixture.bend:
# provision, create and scoped_binding; main.bend exercises deferred cleanup.
def provision(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,value:Provision.Provision<S,C,R,empty,count>) -> Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,empty_store(~S,~C,~empty),count_store(~S,~C,~count)>:
  match value:
    case Provision.Provision{value}:Provision.Provision{schema(~S,~C,~R,value)}
# Reuse the canonical Type-result request; rejected payloads are not forced to Data.
# Capabilities a lifetime-scope system body receives for payload type P.
# spawn consumes a scope/payload request and returns an owning SpawnResult;
# cleanup queues scope cleanup and returns QueueStatus. The opaque owner H must
# be threaded through both. P may be affine Type; a scope is metadata, not an
# entity owner or evidence that any member is currently live.
type Ops<-H:Type,-S:Data,-P:Type> is Type:
  Ops{spawn:Cap.OwnedRequest<H,Sc.Scope<S> & P,Sc.SpawnResult<S,P>>,cleanup:Cap.Request<H,Sc.Scope<S>,A.QueueStatus>}
# Advanced capability projection: consume Ops and obtain its owned spawn
# request operation. Normal system bodies use spawn to thread their opaque owner.
def spawn_cap(~H:Type,~S:Data,~P:Type,ops:Ops<H,S,P>) -> Cap.OwnedRequest<H,Sc.Scope<S> & P,Sc.SpawnResult<S,P>>:
  match ops:
    case Ops{spawn,_}:spawn
# Advanced capability projection: consume Ops and obtain its cleanup request.
# Normal system bodies use cleanup; projection alone queues no work.
def cleanup_cap(~H:Type,~S:Data,~P:Type,ops:Ops<H,S,P>) -> Cap.Request<H,Sc.Scope<S>,A.QueueStatus>:
  match ops:
    case Ops{_,cleanup}:cleanup
# Request a deferred spawn in a scope from this World's namespace.
# Returns the updated opaque owner and either Spawned{handle}, a reserved handle
# not yet live, or SpawnRejected{payload,error}, returning the incoming affine P.
# A foreign-world scope is refused; reservation exhaustion also returns payload.
# Accepted requests retain P in deferred work. At an explicit command barrier,
# activation/populate precede membership assignment; the body does not see a live
# entity merely because this request succeeded. Only immediate refusal promises
# that payload result: a later failed system discards its Out and staged work,
# so placing rejected P inside Out does not make it a failed-system recovery API.
def spawn(~H:Type,~S:Data,~P:Type,~ops:Ops<H,S,P>,owner:H,scope:Sc.Scope<S>,payload:P) -> H & Sc.SpawnResult<S,P>:
  Cap.owned_request(~H,~(Sc.Scope<S> & P),~Sc.SpawnResult<S,P>,~spawn_cap(~H,~S,~P,ops),owner,(scope,payload))
# Queue cleanup of the given scope, threading the opaque owner back.
# Queued means accepted deferred work, not completed deletion; a foreign scope
# returns MissingEntity without queuing cleanup. Membership is observed when the
# command is applied at an explicit barrier, so same-world/name scopes refer to
# the same group rather than distinct owners.
# Cleanup uses the supplied linked-relation descriptors and component clear route.
# An unscoped persistent entity survives only outside the linked deletion closure;
# an unscoped linked descendant can still be deleted, while ordinary links from
# survivors to removed targets are cleared. Queuing cleanup does not flush commands.
# See docs/parity/scopes.md for the qualified survivor and relation boundary.
def cleanup(~H:Type,~S:Data,~P:Type,~ops:Ops<H,S,P>,owner:H,scope:Sc.Scope<S>) -> H & A.QueueStatus:
  Cap.request(~H,~Sc.Scope<S>,~A.QueueStatus,~cleanup_cap(~H,~S,~P,ops),owner,scope)
def spawn_request(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,owner:T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,input:Sc.Scope<S> & P) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & Sc.SpawnResult<S,P>:
  match input:
    case (scope,payload):Spawn.tx_spawn_in(~S,~C,~R,~E,~P,~populate,owner,scope,payload)
def cleanup_request(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~declarations:List<&2,Rel.Declaration<S>>,owner:T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,scope:Sc.Scope<S>) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  Sc.tx_cleanup(~S,~C,~R,~E,~clear,~record,~LC.descriptors(~S,declarations),owner,scope)
# Trusted system-construction adapter for the canonical transaction owner.
# Supplies spawn/cleanup operations using the closed populate, clear, record and
# relation declarations. populate receives the full World at deferred application;
# clear must match its Clear declaration, and relation declarations must cover the
# links cleanup is expected to maintain. These callbacks are schema/engine setup,
# not extra runtime authority exposed to the polymorphic gameplay body.
def provide(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~declarations:List<&2,Rel.Declaration<S>>) -> Ops<T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,S,P>:
  Ops{Cap.OwnedRequest{spawn_request(~S,~C,~R,~E,~P,~populate)},Cap.Request{cleanup_request(~S,~C,~R,~E,~clear,~record,~declarations)}}
# Sys failure retains World/error only; body output is discarded by that existing
# contract. Request-level rejected payload recovery does not imply failed-Out recovery.
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Type,output:Out,result:T.Returned<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,Error>) -> Sys.Outcome<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,Error,Out>:
  match result:
    case T.Returned{world,T.Success{}}:Sys.Succeeded{world,output}
    case T.Returned{world,T.Failure{error}}:Sys.Failed{world,error}
def invoked(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,~Out:Type,seen:T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & (T.Outcome<Error> & Out)) -> Sys.Outcome<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,Error,Out>:
  match seen:
    case (tx,(outcome,output)):returned(~S,~C,~R,~E,~Error,~Out,output,Cmd.tx_finish(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,~Error,tx,outcome))
# Execute one body with lifetime capabilities inside an ordinary transaction.
# Threads World through transaction finish: success returns Out; failure returns
# World/error and discards Out, including any affine payload stored only there.
# Failed staged spawns/cleanup are not published. Successful completion still
# leaves structural work pending until the caller applies an explicit barrier.
# Host IO and arbitrary trusted callback effects are not made reversible here.
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~declarations:List<&2,Rel.Declaration<S>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-ops:Ops<H,S,P> -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,args:Args) -> Sys.Outcome<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,Error,Out>:
  invoked(~S,~C,~R,~E,~Error,~Out,body(T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,provide(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations),args,T.begin(~W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,~A.Notice<S,E>,world)))
# Register a scope system with access derived from the component-clear
# certificate, relation declarations and LifetimeScope:write. Returns the ordinary
# Registry registration result with the returned World on success or refusal.
# Registration runs no body and applies no spawn/cleanup. Supply the matching
# trusted populate/clear routes, then retain the actual returned Registry for run.
def register(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~declarations:List<&2,Rel.Declaration<S>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-ops:Ops<H,S,P> -> Args -> H -> H & (T.Outcome<Error> & Out),~clearDeclaration:Clear.Declaration<S,C,A.Notice<S,E>,clear>,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,name:String) -> Sys.RegistrationResult<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>,Args,Error,Out,runner(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations,~Args,~Error,~Out,~body)>:
  Sys.register(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations,~Args,~Error,~Out,~body),world,name,List.append(&2,String,LCS.writes(Clear.keys(~S,~C,~A.Notice<S,E>,~clear,clearDeclaration)),List.append(&2,String,LCS.relation_accesses(~S,declarations),["LifetimeScope:write"])))
# Run the registered scope system, consuming its Registry, World and Args.
# Returns the updated Registry/World and success output or typed system failure;
# registration refusal returns the ordinary rejected-run Args. Failure discards
# body Out rather than returning affine contents separately. Earlier committed
# systems remain, and successful queued work requires a later explicit barrier.
# Current consumer: test-fixtures/public-scopes/feature-timing-v1/main.bend.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~declarations:List<&2,Rel.Declaration<S>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-ops:Ops<H,S,P> -> Args -> H -> H & (T.Outcome<Error> & Out),owner:Sys.Registry<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>,Args,Error,Out,runner(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations,~Args,~Error,~Out,~body)>,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,args:Args) -> Sys.RunResult<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>,Args,Error,Out,runner(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations,~Args,~Error,~Out,~body)>:
  Sys.run_tracked(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations,~Args,~Error,~Out,~body),owner,world,args)

# Project ordinary families through the metadata wrapper without changing owners.
# Trusted storage-adapter remainder for a projected component column.
# Retains the original component rest, scope membership and relation graph while
# the selected column is out. Gameplay should use the derived binding instead
# of constructing or unpacking this storage wrapper.
type ComponentRest<S:Data,Rest:Type> is Type:
  ComponentRest{rest:Rest,members:List<&2,Sc.Member>,graph:G.Graph<S>}
def taken_column(~S:Data,~C:Type,~Rest:Type,~P:Type,members:List<&2,Sc.Member>,graph:G.Graph<S>,seen:Rest & Col.Column<S,P>) -> ComponentRest<S,Rest> & Col.Column<S,P>:
  match seen:
    case (rest,column):(ComponentRest{rest,members,graph},column)
# Trusted schema projection: take one component column through scope/relation
# wrappers, returning ComponentRest with every sibling and metadata owner.
# Pair it with put_column from the same original store projection.
def take_column(~S:Data,~C:Type,~Rest:Type,~P:Type,~take:C -> Rest & Col.Column<S,P>,store:A.Store<S,Sc.Store<S,C>>) -> ComponentRest<S,Rest> & Col.Column<S,P>:
  match store:
    case A.Store{Sc.Store{components,members},graph}:taken_column(~S,~C,~Rest,~P,members,graph,take(components))
# Trusted schema reconstruction: consume the matching ComponentRest and column
# to rebuild the wrapped Store, preserving membership and relation graph.
# It does not itself change scope membership or apply structural commands.
def put_column(~S:Data,~C:Type,~Rest:Type,~P:Type,~put:Rest -> Col.Column<S,P> -> C,rest:ComponentRest<S,Rest>,column:Col.Column<S,P>) -> A.Store<S,Sc.Store<S,C>>:
  match rest:
    case ComponentRest{rest,members,graph}:A.Store{Sc.Store{put(rest,column),members},graph}
# Derive a component binding for the wrapped Store from its original binding.
# Retains the schema identity, view and typed column path while adding scope and
# relation owners to the remainder. This adapts schema setup; it grants no new
# access merely from a component name. See fixture.bend:scoped_binding in the
# public-scopes/feature-timing-v1 consumer.
def component_binding(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>) -> Binding.Binding<S,A.Store<S,Sc.Store<S,C>>,ComponentRest<S,Rest>,P,V,Token,take_column(~S,~C,~Rest,~P,~take),put_column(~S,~C,~Rest,~P,~put),view>:
  Binding.bind(~S,~A.Store<S,Sc.Store<S,C>>,~ComponentRest<S,Rest>,~P,~V,~Token,~take_column(~S,~C,~Rest,~P,~take),~put_column(~S,~C,~Rest,~P,~put),~view,Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding))
