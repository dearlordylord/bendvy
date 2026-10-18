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
def empty_store(~S:Data,~C:Type,~empty:Unit -> C,unit:Unit) -> A.Store<S,Sc.Store<S,C>>:
  A.empty(~S,~Sc.Store<S,C>,Sc.empty(~S,~C,empty(unit)))
def counted(~S:Data,~C:Type,members:List<&2,Sc.Member>,graph:G.Graph<S>,seen:C & List<&2,Maybe<&2,U32>>) -> A.Store<S,Sc.Store<S,C>> & List<&2,Maybe<&2,U32>>:
  match seen:
    case (components,counts):(A.Store{Sc.Store{components,members},graph},counts)
def count_store(~S:Data,~C:Type,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,store:A.Store<S,Sc.Store<S,C>>,handles:List<&2,W.Handle<S>>) -> A.Store<S,Sc.Store<S,C>> & List<&2,Maybe<&2,U32>>:
  match store:
    case A.Store{Sc.Store{components,members},graph}:counted(~S,~C,members,graph,count(components,handles))
def schema(~S:Data,~C:Type,~R:Type,value:Schema.Schema<S,C,R>) -> Schema.Schema<S,A.Store<S,Sc.Store<S,C>>,R>:
  match value:
    case Schema.Schema{entries}:Schema.Schema{entries}
def provision(~S:Data,~C:Type,~R:Type,~empty:Unit -> C,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,value:Provision.Provision<S,C,R,empty,count>) -> Provision.Provision<S,A.Store<S,Sc.Store<S,C>>,R,empty_store(~S,~C,~empty),count_store(~S,~C,~count)>:
  match value:
    case Provision.Provision{value}:Provision.Provision{schema(~S,~C,~R,value)}
# Reuse the canonical Type-result request; rejected payloads are not forced to Data.
type Ops<-H:Type,-S:Data,-P:Type> is Type:
  Ops{spawn:Cap.OwnedRequest<H,Sc.Scope<S> & P,Sc.SpawnResult<S,P>>,cleanup:Cap.Request<H,Sc.Scope<S>,A.QueueStatus>}
def spawn_cap(~H:Type,~S:Data,~P:Type,ops:Ops<H,S,P>) -> Cap.OwnedRequest<H,Sc.Scope<S> & P,Sc.SpawnResult<S,P>>:
  match ops:
    case Ops{spawn,_}:spawn
def cleanup_cap(~H:Type,~S:Data,~P:Type,ops:Ops<H,S,P>) -> Cap.Request<H,Sc.Scope<S>,A.QueueStatus>:
  match ops:
    case Ops{_,cleanup}:cleanup
def spawn(~H:Type,~S:Data,~P:Type,~ops:Ops<H,S,P>,owner:H,scope:Sc.Scope<S>,payload:P) -> H & Sc.SpawnResult<S,P>:
  Cap.owned_request(~H,~(Sc.Scope<S> & P),~Sc.SpawnResult<S,P>,~spawn_cap(~H,~S,~P,ops),owner,(scope,payload))
def cleanup(~H:Type,~S:Data,~P:Type,~ops:Ops<H,S,P>,owner:H,scope:Sc.Scope<S>) -> H & A.QueueStatus:
  Cap.request(~H,~Sc.Scope<S>,~A.QueueStatus,~cleanup_cap(~H,~S,~P,ops),owner,scope)
def spawn_request(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,owner:T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,input:Sc.Scope<S> & P) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & Sc.SpawnResult<S,P>:
  match input:
    case (scope,payload):Spawn.tx_spawn_in(~S,~C,~R,~E,~P,~populate,owner,scope,payload)
def cleanup_request(~S:Data,~C:Type,~R:Type,~E:Data,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~declarations:List<&2,Rel.Declaration<S>>,owner:T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,scope:Sc.Scope<S>) -> T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  Sc.tx_cleanup(~S,~C,~R,~E,~clear,~record,~LC.descriptors(~S,declarations),owner,scope)
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
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~declarations:List<&2,Rel.Declaration<S>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-ops:Ops<H,S,P> -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,args:Args) -> Sys.Outcome<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,Error,Out>:
  invoked(~S,~C,~R,~E,~Error,~Out,body(T.Tx<W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,A.Notice<S,E>>,provide(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations),args,T.begin(~W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,~A.Notice<S,E>,world)))
def register(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~declarations:List<&2,Rel.Declaration<S>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-ops:Ops<H,S,P> -> Args -> H -> H & (T.Outcome<Error> & Out),~clearDeclaration:Clear.Declaration<S,C,A.Notice<S,E>,clear>,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,name:String) -> Sys.RegistrationResult<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>,Args,Error,Out,runner(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations,~Args,~Error,~Out,~body)>:
  Sys.register(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations,~Args,~Error,~Out,~body),world,name,List.append(&2,String,LCS.writes(Clear.keys(~S,~C,~A.Notice<S,E>,~clear,clearDeclaration)),List.append(&2,String,LCS.relation_accesses(~S,declarations),["LifetimeScope:write"])))
def run(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~populate:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>> -> W.Handle<S> -> P -> W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,~clear:C -> W.Handle<S> -> C & List<&2,A.Notice<S,E>>,~record:W.Handle<S> -> A.Notice<S,E>,~declarations:List<&2,Rel.Declaration<S>>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-ops:Ops<H,S,P> -> Args -> H -> H & (T.Outcome<Error> & Out),owner:Sys.Registry<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>,Args,Error,Out,runner(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations,~Args,~Error,~Out,~body)>,world:W.World<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>>,args:Args) -> Sys.RunResult<S,A.Store<S,Sc.Store<S,C>>,R,A.Notice<S,E>,Args,Error,Out,runner(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations,~Args,~Error,~Out,~body)>:
  Sys.run_tracked(~S,~A.Store<S,Sc.Store<S,C>>,~R,~A.Notice<S,E>,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~P,~populate,~clear,~record,~declarations,~Args,~Error,~Out,~body),owner,world,args)

# Project ordinary families through the metadata wrapper without changing owners.
type ComponentRest<S:Data,Rest:Type> is Type:
  ComponentRest{rest:Rest,members:List<&2,Sc.Member>,graph:G.Graph<S>}
def taken_column(~S:Data,~C:Type,~Rest:Type,~P:Type,members:List<&2,Sc.Member>,graph:G.Graph<S>,seen:Rest & Col.Column<S,P>) -> ComponentRest<S,Rest> & Col.Column<S,P>:
  match seen:
    case (rest,column):(ComponentRest{rest,members,graph},column)
def take_column(~S:Data,~C:Type,~Rest:Type,~P:Type,~take:C -> Rest & Col.Column<S,P>,store:A.Store<S,Sc.Store<S,C>>) -> ComponentRest<S,Rest> & Col.Column<S,P>:
  match store:
    case A.Store{Sc.Store{components,members},graph}:taken_column(~S,~C,~Rest,~P,members,graph,take(components))
def put_column(~S:Data,~C:Type,~Rest:Type,~P:Type,~put:Rest -> Col.Column<S,P> -> C,rest:ComponentRest<S,Rest>,column:Col.Column<S,P>) -> A.Store<S,Sc.Store<S,C>>:
  match rest:
    case ComponentRest{rest,members,graph}:A.Store{Sc.Store{put(rest,column),members},graph}
def component_binding(~S:Data,~C:Type,~Rest:Type,~P:Type,~V:Data,~Token:Data,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,~view:P -> P & V,binding:Binding.Binding<S,C,Rest,P,V,Token,take,put,view>) -> Binding.Binding<S,A.Store<S,Sc.Store<S,C>>,ComponentRest<S,Rest>,P,V,Token,take_column(~S,~C,~Rest,~P,~take),put_column(~S,~C,~Rest,~P,~put),view>:
  Binding.bind(~S,~A.Store<S,Sc.Store<S,C>>,~ComponentRest<S,Rest>,~P,~V,~Token,~take_column(~S,~C,~Rest,~P,~take),~put_column(~S,~C,~Rest,~P,~put),~view,Binding.identity(~S,~C,~Rest,~P,~V,~Token,~take,~put,~view,binding))
