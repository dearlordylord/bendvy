import Base
import ./ordinary-optional-resource.bend as O
import ./ordinary-schema.bend as Schema
import ./owner-product.bend as Product
import ./ordinary-resource-field-system.bend as Field
import ./ordinary-app-resource-field-declaration.bend as AppField
import ./ordinary-query-declaration.bend as Query
import ./resource.bend as Resource
import ./world.bend as W
import ./transaction.bend as Tx
import ./check.bend as K
import ./system.bend as Sys
import ./capabilities.bend as Cap

# The grant names the original Resource<S,P>, while only its physical lens
# addresses Slot<S,P,identity>. The generated clause is not a second user list.
def Ops(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~V:Data,H:Type) -> Type:
  Field.Read<S,P,identity,H,Maybe<&2,V>>
def ordinary(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>) -> Field.Declaration<S,Tx.Tx<W.World<S,C,R,E>,E>,Ops(~S,~P,~identity,~V,~Tx.Tx<W.World<S,C,R,E>,E>)>:
  Field.Declaration{Field.Read{Cap.ValueRead{Resource.tx_get(~S,~C,~R,~E,~Maybe<&2,V>,~O.project(~S,~R,~P,~Rest,~V,~identity,~lens,~view))}},[Query.Clause{Schema.resource_key(~S,~P,identity),Query.Read{}}]}
def app_declaration(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>,~render:Maybe<&2,V> -> String) -> AppField.Declaration<S,C,R,E,Ops(~S,~P,~identity,~V),Maybe<&2,V>>:
  AppField.Declaration{ordinary(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration),O.observe(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration),render}
# Required registration uses the same field declaration and transaction body.
# The only added step precedes Tx.begin and the callback; no rollback change.
def preflighted(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Type,~Out:Type,~declaration:Field.Declaration<S,Tx.Tx<W.World<S,C,R,E>,E>,Ops(Tx.Tx<W.World<S,C,R,E>,E>)>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (Tx.Outcome<K.Error> & Out),args:Args,result:W.World<S,C,R,E> & List<&2,String>) -> Sys.Outcome<W.World<S,C,R,E>,K.Error,Out>:
  match result:
    case (world,[]):Field.runner(~S,~C,~R,~E,~Ops,~Args,~K.Error,~Out,~declaration,~body,world,args)
    case (world,missing):Sys.Failed{world,K.MissingRuntimeRequirements{missing}}
def required_runner(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~view:P -> P & V,~declaration:O.Declaration<S,R,P,Rest,V,identity,lens,view>,~Ops:Type -> Type,~operational:Field.Declaration<S,Tx.Tx<W.World<S,C,R,E>,E>,Ops(Tx.Tx<W.World<S,C,R,E>,E>)>,~Args:Type,~Out:Type,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (Tx.Outcome<K.Error> & Out),world:W.World<S,C,R,E>,args:Args) -> Sys.Outcome<W.World<S,C,R,E>,K.Error,Out>:
  preflighted(~S,~C,~R,~E,~Ops,~Args,~Out,~operational,~body,args,O.required(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~declaration,world))
