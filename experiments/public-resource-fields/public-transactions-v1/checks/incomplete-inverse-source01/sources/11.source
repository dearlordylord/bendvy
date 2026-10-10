import Base
import ../../../../../src/ecs/resource-field-binding.bend as B
import field.bend as Field
import ../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../src/ecs/ordinary-query-declaration.bend as Q
import ../../../../../src/ecs/ordinary-resource-system.bend as Whole
import ../../../../../src/ecs/owner-product.bend as Product
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/transaction.bend as T
import ../../../../../src/ecs/capabilities.bend as Cap
# Descriptor identity is retained in each operation type, including equal payloads.
type Read<-S:Data,-P:Type,-identity:Schema.Resource<S,P>,-H:Type,-V:Data> is Type:
  Read{operation:Cap.ValueRead<H,V>}
type Write<-S:Data,-P:Type,-identity:Schema.Resource<S,P>,-H:Type,-V:Data> is Type:
  Write{operation:Cap.ValueWrite<H,P,V>}
def read_field(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,cap:Read<S,P,identity,H,V>) -> H -> H & V:
  match cap:
    case Read{operation}:Cap.value_read_field(~H,~V,operation)
def read_value(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,~cap:Read<S,P,identity,H,V>,owner:H) -> H & V:
  read_field(~S,~P,~identity,~H,~V,cap)(owner)
def get_field(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,cap:Write<S,P,identity,H,V>) -> H -> H & V:
  match cap:
    case Write{operation}:Cap.value_write_read_field(~H,~P,~V,operation)
def get(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,~cap:Write<S,P,identity,H,V>,owner:H) -> H & V:
  get_field(~S,~P,~identity,~H,~V,cap)(owner)
def set_field(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,cap:Write<S,P,identity,H,V>) -> H -> P -> H:
  match cap:
    case Write{operation}:Cap.value_write_field(~H,~P,~V,operation)
def set(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~H:Type,~V:Data,~cap:Write<S,P,identity,H,V>,owner:H,replacement:P) -> H:
  set_field(~S,~P,~identity,~H,~V,cap)(owner,replacement)
type Declaration<-S:Data,-H:Type,-Ops:Type> is Type:
  Declaration{grant:Ops,clauses:List<&2,Q.Clause<S>>}
def read(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~identity:Schema.Resource<S,P>,~binding:B.Binding<S,R,P,Rest,lens,identity>,~view:P -> P & V) -> Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Read<S,P,identity,T.Tx<W.World<S,C,R,E>,E>,V>>:
  Declaration{Read{Field.read(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view)},[Q.Clause{Schema.resource_key(~S,~P,identity),Q.Read{}}]}
def write(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~lens:Product.Lens<R,P,Rest>,~identity:Schema.Resource<S,P>,~binding:B.Binding<S,R,P,Rest,lens,identity>,~view:P -> P & V) -> Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Write<S,P,identity,T.Tx<W.World<S,C,R,E>,E>,V>>:
  Declaration{Write{Field.write(~S,~C,~R,~E,~P,~Rest,~V,~lens,~view)},[Q.Clause{Schema.resource_key(~S,~P,identity),Q.Write{}}]}
def pair(~S:Data,~H:Type,~L:Type,~R:Type,left:Declaration<S,H,L>,right:Declaration<S,H,R>) -> Declaration<S,H,Cap.Bundle<L,R>>:
  match left right:
    case Declaration{l,lc} Declaration{r,rc}:Declaration{Cap.Bundle{l,r},List.append(&2,Q.Clause<S>,lc,rc)}
def grant(~S:Data,~H:Type,~Ops:Type,value:Declaration<S,H,Ops>) -> Ops:
  match value:
    case Declaration{grant,_}:grant
def clauses(~S:Data,~H:Type,~Ops:Type,value:Declaration<S,H,Ops>) -> List<&2,Q.Clause<S>>:
  match value:
    case Declaration{_,clauses}:clauses
def access(~S:Data,clauses:List<&2,Q.Clause<S>>) -> List<&2,String>:
  match clauses:
    case []:[]
    case Q.Clause{name,_} <> rest:name <> access(~S,rest)
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~declaration:Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,args:Args) -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>:
  Whole.finished(~S,~C,~R,~E,~Error,~Out,Cap.invoke_owned(~Ops,~Args,~(T.Outcome<Error> & Out),~body,~T.Tx<W.World<S,C,R,E>,E>,~grant(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration),args,T.begin(~W.World<S,C,R,E>,~E,world)))
# Only actual Registry is runtime-owned; clauses are an erased generated index.
type Owner<-S:Data,-Registry:Type,-clauses:List<&2,Q.Clause<S>>> is Type:
  Owner{registry:Registry}
type Defined<-S:Data,-World:Type,-Registry:Type,-clauses:List<&2,Q.Clause<S>>> is Type:
  Defined{world:World,owner:Owner<S,Registry,clauses>}
  Rejected{world:World}
def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~run:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~clauses:List<&2,Q.Clause<S>>,result:Sys.RegistrationResult<S,C,R,E,Args,Error,Out,run>) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,Args,Error,Out,run>,clauses>:
  match result:
    case Sys.RegistrationFailed{world}:Rejected{world}
    case Sys.Registered{world,registry}:Defined{world,Owner{registry}}
def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Error:Data,~Out:Type,~declaration:Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,R,E>,name:String) -> Defined<S,W.World<S,C,R,E>,Sys.Registry<S,C,R,E,Args,Error,Out,runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~declaration,~body)>,clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration)>:
  registered(~S,~C,~R,~E,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~declaration,~body),~clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration),Sys.register(~S,~C,~R,~E,~Args,~Error,~Out,~runner(~S,~C,~R,~E,~Ops,~Args,~Error,~Out,~declaration,~body),world,name,access(~S,clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),declaration))))
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Type,~Error:Data,~Out:Type,~run:W.World<S,C,R,E> -> Args -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~clauses:List<&2,Q.Clause<S>>,owner:Owner<S,Sys.Registry<S,C,R,E,Args,Error,Out,run>,clauses>,world:W.World<S,C,R,E>,args:Args) -> Sys.RunResult<S,C,R,E,Args,Error,Out,run>:
  match owner:
    case Owner{registry}:Sys.run_tracked(~S,~C,~R,~E,~Args,~Error,~Out,~run,registry,world,args)
