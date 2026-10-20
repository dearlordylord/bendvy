import Base
import ./trace-facts.bend as TraceFacts
import ./resource-field-binding.bend as B
import ./resource-field.bend as Field
import ./ordinary-schema.bend as Schema
import ./ordinary-query-declaration.bend as Q
import ./ordinary-resource-system.bend as Whole
import ./owner-product.bend as Product
import ./world.bend as W
import ./system.bend as Sys
import ./transaction.bend as T
import ./capabilities.bend as Cap
# Descriptor identity is retained in each operation type, including equal payloads.
# Identity-indexed selected-resource read grant for detached V and opaque H.
# Equal payload types do not erase the retained resource identity.
type Read<-S:Data,-P:Type,-identity:Schema.Resource<S,P>,-H:Type,-V:Data> is Type:
  Read{operation:Cap.ValueRead<H,V>}
# Identity-indexed selected-resource read/replacement grant. Consumes actual P
# while siblings remain behind the canonical lens; no incoming recovery receipt.
type Write<-S:Data,-P:Type,-identity:Schema.Resource<S,P>,-H:Type,-V:Data> is Type:
  Write{operation:Cap.ValueWrite<H,P,V>}
# Advanced projection of the closed read operation, without invoking it.
def read_field(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,cap:Read<S,P,identity,H,V>) -> H -> H & V:
  match cap:
    case Read{operation}:Cap.value_read_field(~H,~V,operation)
# Read detached V through the declared selected-field grant and return actual H.
def read_value(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,~cap:Read<S,P,identity,H,V>,owner:H) -> H & V:
  read_field(~S,~P,~identity,~H,~V,cap)(owner)
# Advanced projection of the read operation from a selected-field write grant.
def get_field(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,cap:Write<S,P,identity,H,V>) -> H -> H & V:
  match cap:
    case Write{operation}:Cap.value_write_read_field(~H,~P,~V,operation)
# Read detached V through a write-capable field grant without replacing P.
def get(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,~cap:Write<S,P,identity,H,V>,owner:H) -> H & V:
  get_field(~S,~P,~identity,~H,~V,cap)(owner)
# Advanced projection of the consuming selected-field setter.
def set_field(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,cap:Write<S,P,identity,H,V>) -> H -> P -> H:
  match cap:
    case Write{operation}:Cap.value_write_field(~H,~P,~V,operation)
# Consume replacement P and return H through the bound setter. Adds no extra
# validation, transaction finish or owned refusal result beyond that operation.
def set(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,~cap:Write<S,P,identity,H,V>,owner:H,replacement:P) -> H:
  set_field(~S,~P,~identity,~H,~V,cap)(owner,replacement)
# Operational grants and ordered resource clauses retained together. Canonical
# builders bind identity to the selected lens; forged raw values are trusted setup.
type Declaration<-S:Data,-H:Type,-Ops:Type> is Type:
  Declaration{grant:Ops,clauses:List<&2,Q.Clause<S>>}
# Build a selected-field read declaration from its canonical binding and view.
# view must return actual P with detached V; canonical lenses preserve siblings.
def read(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~identity:Schema.Resource<S,P>,~binding:B.Binding<S,R,P,Rest,lens,identity>,~view:P -> P & V) -> Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Read<S,P,identity,T.Tx<W.World<S,C,R,E>,E>,V>>:
  Declaration{Read{Field.read(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view)},[Q.Clause{Schema.resource_key(~S,~P,identity),Q.Read{}}]}
# Build a selected-P replacement declaration with canonical binding identity.
# Ordinary inverse journaling restores old P on failure; successful setters consume
# replacement P without returning displaced payloads as a recovery receipt.
def write(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~identity:Schema.Resource<S,P>,~binding:B.Binding<S,R,P,Rest,lens,identity>,~view:P -> P & V) -> Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Write<S,P,identity,T.Tx<W.World<S,C,R,E>,E>,V>>:
  Declaration{Write{Field.write(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view)},[Q.Clause{Schema.resource_key(~S,~P,identity),Q.Write{}}]}
# Compose grants and clauses left before right, retaining both operations. This
# does not deduplicate clauses or add a new alias/overlap policy.
def pair(~S:Data,~H:Type,~L:Type,~R:Type,left:Declaration<S,H,L>,right:Declaration<S,H,R>) -> Declaration<S,H,Cap.Bundle<L,R>>:
  match left right:
    case Declaration{l,lc} Declaration{r,rc}:Declaration{Cap.Bundle{l,r},List.append(&2,Q.Clause<S>,lc,rc)}
# Advanced projection of stored operational caps, without invocation.
def grant(~S:Data,~H:Type,~Ops:Type,value:Declaration<S,H,Ops>) -> Ops:
  match value:
    case Declaration{grant,_}:grant
# Advanced projection of detached clauses derived alongside the operational caps.
def clauses(~S:Data,~H:Type,~Ops:Type,value:Declaration<S,H,Ops>) -> List<&2,Q.Clause<S>>:
  match value:
    case Declaration{_,clauses}:clauses
# Ordered clause-name projection for registration, preserving duplicates/order.
# No string normalization grants additional field authority.
def access(~S:Data,clauses:List<&2,Q.Clause<S>>) -> List<&2,String>:
  match clauses:
    case []:[]
    case Q.Clause{name,_} <> rest:name <> access(~S,rest)
# Execute body once with opaque Tx caps from this field declaration and finish
# the ECS transaction. Failure restores recorded fields, discards Out and suppresses
# staged work; canonical lenses preserve siblings. No implicit structural barrier.
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~declaration:Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,args:Args) -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>:
  Whole.finished(~S,~C,~R,~E,~Error,~Out,Cap.invoke_owned(~Ops,~Args,~(T.Outcome<Error> & Out),~body,~T.Tx<W.World<S,C,R,E>,E>,~grant(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration),args,T.begin(~W.World<S,C,R,E>,~E,world)))
# Only actual Registry is runtime-owned; clauses are an erased generated index.
# Actual registry owner indexed by erased generated field clauses; no copied
# resource payload or independent runtime clause registry is stored.
type Owner<-S:Data,-Registry:Type,-clauses:List<&2,Q.Clause<S>>> is Type:
  Owner{registry:Registry}
# Registration result returning World on success/refusal, with Owner only after
# successful registry creation. This does not execute the resource body.
type Defined<-S:Data,-World:Type,-Registry:Type,-clauses:List<&2,Q.Clause<S>>> is Type:
  Defined{world:World,owner:Owner<S,Registry,clauses>}
  Rejected{world:World}
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~run:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~clauses:List<&2,Q.Clause<S>>,result:Sys.RegistrationResult<S,C,R,E,Args,Error,Out,run>) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,Args,Error,Out,run>,clauses>:
  match result:
    case Sys.RegistrationFailed{world}:Rejected{world}
    case Sys.Registered{world,registry}:Defined{world,Owner{registry}}
# Register the field declaration/body using ordered derived access clauses.
# Bindings, lenses and view functions are trusted setup, not arbitrary metadata
# validation. Higher-level ordinary App resource-field declarations expose this.
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~declaration:Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,name:String) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,Args,Error,Out,runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~declaration,~body)>,clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration)>:
  registered(~S,~C,~R,~E,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~declaration,~body),~clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration),Sys.register(~S,~C,~R,~E,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~declaration,~body),world,name,access(~S,clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration))))
# Run the actual registry through Sys.run. Full refusal returns registry,
# World and unconsumed Args; normal completion retains the returned registry and
# World. This wrapper does not execute the deferred command barrier.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~run:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~clauses:List<&2,Q.Clause<S>>,owner:Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,run>,clauses>,world:W.World<S,C,R,E>,args:Args) -> Sys.RunResult<S,C,R,E,Args,Error,Out,run>:
  match owner:
    case Owner{registry}:Sys.run(~S,~C,~R,~E,~Args,~Error,~Out,~run,registry,world,args)

# Trace-aware counterpart of runner with supplied/returned fact state. Same caps,
# transaction decision and output disposal; observation adds no resource authority
# and does not make attempted writes committed.
def runner_observed(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~declaration:Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),trace:TraceFacts.State,world:W.World<S,C,R,E>,args:Args) -> Sys.Outcome<W.World<S,C,R,E>,Error,Out> & TraceFacts.State:
  Whole.finished_observed(~S,~C,~R,~E,~Error,~Out,Cap.invoke_owned(~Ops,~Args,~(T.Outcome<Error> & Out),~body,~T.Tx<W.World<S,C,R,E>,E>,~grant(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration),args,T.begin_with_trace(~W.World<S,C,R,E>,~E,world,trace)))
