import Base
import ./application.bend as Game
import ../heterogeneous-v1/schema.bend as Schema
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/lifecycle.bend as Life
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/ordinary-recovery-system.bend as System
import ../../../src/ecs/recoverable-component.bend as RC
import ../../../src/ecs/recoverable-array.bend as RA
import ../../../src/ecs/transaction.bend as T
def bind(~A:Type,~B:Type,~R:Type,result:A & B,next:A -> B -> R) -> R:
  match result:
    case (a,b):next(a,b)
# Every observer returns its original affine owner beside the complete text.
def number(value:U32) -> U32 & String:
  match value:
    case +v:(v,U32.show(v))
def boolean(value:Bool) -> Bool & String:
  match value:
    case True{}:(True{},"True")
    case False{}:(False{},"False")
def array(~P:Type,~observe:P -> P & String,values:Array<P>) -> Array<P> & String:
  match values:
    case ALeaf{value}:
      bind(~P,~String,~(Array<P> & String),observe(value),value => text => (
        (ALeaf{value},"L(" ++ text ++ ")")
      ))
    case ANode{left,right}:
      bind(~Array<P>,~String,~(Array<P> & String),array(~P,~observe,left),left => a => (
        bind(~Array<P>,~String,~(Array<P> & String),array(~P,~observe,right),right => b => (
          (ANode{left,right},"N(" ++ a ++ "," ++ b ++ ")")
        ))
      ))
def numbers(values:Array<U32>) -> Array<U32> & String:array(~U32,~number,values)
def matrix(values:Array<Array<U32>>) -> Array<Array<U32>> & String:array(~Array<U32>,~numbers,values)
def maybe(~P:Type,~observe:P -> P & String,value:Maybe<P>) -> Maybe<P> & String:
  match value:
    case None{}:(None{},"None")
    case Some{owner}:
      bind(~P,~String,~(Maybe<P> & String),observe(owner),owner => text => (
        (Some{owner},"Some(" ++ text ++ ")")
      ))
def maybe_text(value:Maybe<&2,String>) -> String:
  match value:
    case None{}:"None"
    case Some{text}:"Some(" ++ text ++ ")"
def stamp(value:Life.Stamp) -> String:
  match value:
    case Life.Stamp{added,changed}:"(" ++ U32.show(added) ++ "," ++ U32.show(changed) ++ ")"
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,id}:"(" ++ U32.show(namespace) ++ "," ++ U32.show(id) ++ ")"
def rows(~S:Data,~P:Type,~observe:P -> P & String,fuel:Nat,+id:U32,column:Col.Column<S,P>) -> Col.Column<S,P> & String:
  match fuel:
    case 0n:(column,"")
    case 1n+rest:
      bind(~Col.Column<S,P>,~Maybe<&2,String>,~(Col.Column<S,P> & String),Col.view(~S,~P,~String,~observe,column,id),column => payload => (
        bind(~Col.Column<S,P>,~Life.Stamp,~(Col.Column<S,P> & String),Col.lifecycle(~S,~P,column,id),column => life => (
          bind(~Col.Column<S,P>,~String,~(Col.Column<S,P> & String),rows(~S,~P,~observe,rest,(id + 1 : U32),column),column => tail => (
            (column,"row" ++ U32.show(id) ++ "=" ++ maybe_text(payload) ++ "@" ++ stamp(life) ++ ";" ++ tail)
          ))
        ))
      ))
def store(~S:Data,value:Schema.Store(~S)) -> Schema.Store(~S) & String:
  match value:
    case Product.Owner{first,second}:
      bind(~Col.Column<S,Array<Array<U32>>>,~String,~(Schema.Store(~S) & String),rows(~S,~Array<Array<U32>>,~matrix,4n,0,first),first => a => (
        bind(~Col.Column<S,Array<U32>>,~String,~(Schema.Store(~S) & String),rows(~S,~Array<U32>,~numbers,4n,0,second),second => b => (
          (Product.Owner{first,second},"first{" ++ a ++ "}second{" ++ b ++ "}")
        ))
      ))
def strings(values:List<&2,String>) -> String:
  match values:
    case Nil{}:"[]"
    case Con{head,tail}:"[" ++ head ++ "]" ++ strings(tail)
def meta(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:"(" ++ U32.show(id) ++ "," ++ name ++ "," ++ strings(access) ++ ")"
def metas(values:List<&2,W.RegistrationMeta>) -> String:
  match values:
    case Nil{}:"[]"
    case Con{head,tail}:meta(head) ++ metas(tail)
def events(values:List<&2,Unit>) -> String:
  match values:
    case Nil{}:"[]"
    case Con{_,tail}:"Unit;" ++ events(tail)
def world(~S:Data,value:Game.World(~S)) -> Game.World(~S) & String:
  match value:
    case W.World{+namespace,+next,+high,live,+capacity,+depth,components,resource,+published,pending,+registrations,+sid,+clock}:
      bind(~Array<Bool>,~String,~(Game.World(~S) & String),array(~Bool,~boolean,live),live => l => (
        bind(~Schema.Store(~S),~String,~(Game.World(~S) & String),store(~S,components),components => c => (
          bind(~Array<Array<U32>>,~String,~(Game.World(~S) & String),matrix(resource),resource => r => (
            bind(~List<(Game.World(~S) -> Game.World(~S))>,~U32,~(Game.World(~S) & String),W.pending_length(~S,~Schema.Store(~S),~Array<Array<U32>>,~Unit,pending),pending => count => (
              text = "world(ns=" ++ U32.show(namespace) ++ ",next=" ++ U32.show(next) ++ ",high=" ++ U32.show(high) ++ ",live=" ++ l ++ ",capacity=" ++ U32.show(capacity) ++ ",depth=" ++ Nat.show(depth) ++ "," ++ c ++ ",resource=" ++ r ++ ",events=" ++ events(published) ++ ",pending=" ++ U32.show(count) ++ ",registrations=" ++ metas(registrations) ++ ",nextSystem=" ++ U32.show(sid) ++ ",clock=" ++ U32.show(clock) ++ ")"
              (W.World{namespace,next,high,live,capacity,depth,components,resource,published,pending,registrations,sid,clock},text)
            ))
          ))
        ))
      ))
def owner(~S:Data,value:Game.Instance(~S)) -> Game.Instance(~S) & String:
  match value:
    case System.Owner{Sys.Registry{+namespace,+id,+name,+access,+cursor},capture}:
      bind(~Array<Array<U32>>,~String,~(Game.Instance(~S) & String),matrix(capture),capture => text => (
        (System.Owner{Sys.Registry{namespace,id,name,access,cursor},capture},"owner(ns=" ++ U32.show(namespace) ++ ",id=" ++ U32.show(id) ++ ",name=" ++ name ++ ",access=" ++ strings(access) ++ ",cursor=" ++ U32.show(cursor) ++ ",capture=" ++ text ++ ")")
      ))
def component_records(~S:Data,~P:Type,~observe:P -> P & String,records:List<RC.Record<S,P>>) -> List<RC.Record<S,P>> & String:
  match records:
    case Nil{}:([],"[]")
    case Con{RC.Record{+entity,+life,payload},tail}:
      bind(~Maybe<P>,~String,~(List<RC.Record<S,P>> & String),maybe(~P,~observe,payload),payload => p => (
        bind(~List<RC.Record<S,P>>,~String,~(List<RC.Record<S,P>> & String),component_records(~S,~P,~observe,tail),tail => t => (
          (Con{RC.Record{entity,life,payload},tail},"record(" ++ handle(~S,entity) ++ "," ++ stamp(life) ++ "," ++ p ++ ");" ++ t)
        ))
      ))
def array_record(value:RA.Record<Array<U32>>) -> RA.Record<Array<U32>> & String:
  match value:
    case RA.Replaced{values}:
      bind(~Array<Array<U32>>,~String,~(RA.Record<Array<U32>> & String),matrix(values),values => text => (
        (RA.Replaced{values},"Replaced(" ++ text ++ ")")
      ))
    case RA.Swapped{+index,value}:
      bind(~Array<U32>,~String,~(RA.Record<Array<U32>> & String),numbers(value),value => text => (
        (RA.Swapped{index,value},"Swapped(" ++ U32.show(index) ++ "," ++ text ++ ")")
      ))
def array_records(records:List<RA.Record<Array<U32>>>) -> List<RA.Record<Array<U32>>> & String:
  match records:
    case Nil{}:([],"[]")
    case Con{head,tail}:
      bind(~RA.Record<Array<U32>>,~String,~(List<RA.Record<Array<U32>>> & String),array_record(head),head => h => (
        bind(~List<RA.Record<Array<U32>>>,~String,~(List<RA.Record<Array<U32>>> & String),array_records(tail),tail => t => (
          (Con{head,tail},h ++ ";" ++ t)
        ))
      ))
def recovery(~S:Data,value:Game.Recovery(~S)) -> Game.Recovery(~S) & String:
  match value:
    case Product.Owner{first,Product.Owner{second,Product.Owner{capture,resource}}}:
      bind(~List<RC.Record<S,Array<Array<U32>>>>,~String,~(Game.Recovery(~S) & String),component_records(~S,~Array<Array<U32>>,~matrix,first),first => a => (
        bind(~List<RC.Record<S,Array<U32>>>,~String,~(Game.Recovery(~S) & String),component_records(~S,~Array<U32>,~numbers,second),second => b => (
          bind(~List<RA.Record<Array<U32>>>,~String,~(Game.Recovery(~S) & String),array_records(capture),capture => c => (
            bind(~List<RA.Record<Array<U32>>>,~String,~(Game.Recovery(~S) & String),array_records(resource),resource => r => (
              (Product.Owner{first,Product.Owner{second,Product.Owner{capture,resource}}},"recovery(first=" ++ a ++ ",second=" ++ b ++ ",capture=" ++ c ++ ",resource=" ++ r ++ ")")
            ))
          ))
        ))
      ))
def output(value:Game.Output) -> Game.Output & String:
  match value:
    case Game.Output{+removed,refused}:
      bind(~Maybe<Array<Array<U32>>>,~String,~(Game.Output & String),maybe(~Array<Array<U32>>,~matrix,refused),refused => text => (
        (Game.Output{removed,refused},"output(removed=" ++ Bool.show(removed) ++ ",refused=" ++ text ++ ")")
      ))
def outcome(value:T.Outcome<Game.Error>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{Game.PolicyDeclined{}}:"Failure(PolicyDeclined)"
    case T.Failure{Game.MissingTarget{}}:"Failure(MissingTarget)"
