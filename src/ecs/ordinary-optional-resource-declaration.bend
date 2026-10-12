import Base
import ./ordinary-optional-resource.bend as O
import ./optional-resource-binding.bend as B
import ./ordinary-schema.bend as Schema
import ./owner-product.bend as Product
import ./ordinary-resource-field-system.bend as Field
import ./ordinary-query-declaration.bend as Q
import ./world.bend as W
import ./resource.bend as Resource
import ./transaction.bend as T
import ./capabilities.bend as Cap
# One declaration carries actual operation, preflight and owner-return observer.
type Declaration<-S:Data,-C:Type,-R:Type,-E:Data,-Ops:Type -> Type,-V:Data> is Type:
  Declaration{ordinary:Field.Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>,required:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,String>,observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,render:V -> String}
def Ops(~S:Data,~P:Type,~identity:Schema.Resource<S,P>,~V:Data,H:Type) -> Type:
  Field.Read<S,P,identity,H,Maybe<&2,V>>
def provided(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,String>:
  (world,[])
def built(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~binding:B.Binding<S,R,P,Rest,identity,lens>,~view:P -> P & V,required:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,String>,render:Maybe<&2,V> -> String) -> Declaration<S,C,R,E,Ops(~S,~P,~identity,~V),Maybe<&2,V>>:
  Declaration{Field.Declaration{Field.Read{Cap.ValueRead{Resource.tx_get(~S,~C,~R,~E,~Maybe<&2,V>,~O.project(~S,~R,~P,~Rest,~V,~identity,~lens,~view))}},[Q.Clause{Schema.resource_key(~S,~P,identity),Q.Read{}}]},required,O.observe(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~O.Declaration{}),render}
def optional(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~binding:B.Binding<S,R,P,Rest,identity,lens>,~view:P -> P & V,render:Maybe<&2,V> -> String) -> Declaration<S,C,R,E,Ops(~S,~P,~identity,~V),Maybe<&2,V>>:
  built(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~binding,~view,provided(~S,~C,~R,~E),render)
def required(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~V:Data,~identity:Schema.Resource<S,P>,~lens:Product.Lens<R,O.Slot<S,P,identity>,Rest>,~binding:B.Binding<S,R,P,Rest,identity,lens>,~view:P -> P & V,render:Maybe<&2,V> -> String) -> Declaration<S,C,R,E,Ops(~S,~P,~identity,~V),Maybe<&2,V>>:
  built(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~binding,~view,O.required(~S,~C,~R,~E,~P,~Rest,~V,~identity,~lens,~view,~O.Declaration{}),render)
def PairOps(~L:Type -> Type,~Right:Type -> Type,H:Type) -> Type:
  Cap.Bundle<L(H),Right(H)>
# Extra operational grants describe distinct actual fields, not a metadata mirror.
def with(~S:Data,~C:Type,~R:Type,~E:Data,~L:Type -> Type,~Right:Type -> Type,~V:Data,left:Declaration<S,C,R,E,L,V>,right:Field.Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Right(T.Tx<W.World<S,C,R,E>,E>)>) -> Declaration<S,C,R,E,PairOps(~L,~Right),V>:
  match left:
    case Declaration{ordinary,required,observe,render}:Declaration{Field.pair(~S,~T.Tx<W.World<S,C,R,E>,E>,~L(T.Tx<W.World<S,C,R,E>,E>),~Right(T.Tx<W.World<S,C,R,E>,E>),ordinary,right),required,observe,render}
def ordinary(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> Field.Declaration<S,T.Tx<W.World<S,C,R,E>,E>,Ops(T.Tx<W.World<S,C,R,E>,E>)>:
  match declaration:
    case Declaration{ordinary,_,_,_}:ordinary
def preflight(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,String>:
  match declaration:
    case Declaration{_,required,_,_}:required(world)
def observer(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> W.World<S,C,R,E> -> W.World<S,C,R,E> & V:
  match declaration:
    case Declaration{_,_,observe,_}:observe
def presenter(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> V -> String:
  match declaration:
    case Declaration{_,_,_,render}:render
def names(~S:Data,clauses:List<&2,Q.Clause<S>>) -> String:
  match clauses:
    case []:""
    case Q.Clause{name,_} <> []:name
    case Q.Clause{name,_} <> rest:name ++ "," ++ names(~S,rest)
def name(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~V:Data,declaration:Declaration<S,C,R,E,Ops,V>) -> String:
  names(~S,Field.clauses(~S,~T.Tx<W.World<S,C,R,E>,E>,~Ops(T.Tx<W.World<S,C,R,E>,E>),ordinary(~S,~C,~R,~E,~Ops,~V,declaration)))
