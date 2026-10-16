import Base
import ./world.bend as W
import ./system.bend as Sys
import ./transaction.bend as T
import ./commands.bend as Cmd
import ./owned-event-storage.bend as Storage

# Ordinary identity derives publication metadata and the confined grant.
# Raw Frame and runner constructors are trusted engine administration.
type Domain<-S:Data,-P:Type> is Data:
  Domain{key:String}
def domain(~S:Data,~P:Type,key:String) -> Domain<S,P>:Domain{key}
def access(~S:Data,~P:Type,domain:Domain<S,P>,suffix:String) -> String:
  match domain:
    case Domain{key}:String.concat([key,suffix])
type Frame<World:Type,P:Type> is Type:
  Frame{tx:T.Tx<World,Nat>,newest:List<P>}
type Write<-S:Data,-P:Type,-identity:Domain<S,P>,-H:Type> is Type:
  Write{emit:H -> P -> H}
def emit_field(~S:Data,~P:Type,~identity:Domain<S,P>,~H:Type,grant:Write<S,P,identity,H>) -> H -> P -> H:
  match grant:
    case Write{emit}:emit
def emit(~S:Data,~P:Type,~identity:Domain<S,P>,~H:Type,~grant:Write<S,P,identity,H>,owner:H,payload:P) -> H:
  emit_field(~S,~P,~identity,~H,grant)(owner,payload)
def staged(~World:Type,~P:Type,owner:Frame<World,P>,payload:P) -> Frame<World,P>:
  match owner:
    case Frame{tx,newest}:Frame{tx,payload <> newest}
type Reply<Error:Data,Out:Type,P:Type> is Type:
  Reply{outcome:T.Outcome<Error>,output:Out,recovered:List<P>}
# Only available independently staged owners are recovered, after ECS rollback.
def finished(~S:Data,~C:Type,~R:Type,~P:Type,~Error:Data,~Out:Type,newest:List<P>,output:Out,result:T.Returned<W.World<S,C,Storage.Resources<R,P>,Nat>,Error>) -> Sys.Outcome<W.World<S,C,Storage.Resources<R,P>,Nat>,Unit,Reply<Error,Out,P>>:
  match result:
    case T.Returned{world,T.Success{}}:Sys.Succeeded{Storage.commit_owned(~S,~C,~R,~P,world,List.reverse(&1,P,newest)),Reply{T.Success{},output,[]}}
    case T.Returned{world,T.Failure{error}}:Sys.Succeeded{world,Reply{T.Failure{error},output,List.reverse(&1,P,newest)}}
def returned(~S:Data,~C:Type,~R:Type,~P:Type,~Error:Data,~Out:Type,result:Frame<W.World<S,C,Storage.Resources<R,P>,Nat>,P> & (T.Outcome<Error> & Out)) -> Sys.Outcome<W.World<S,C,Storage.Resources<R,P>,Nat>,Unit,Reply<Error,Out,P>>:
  match result:
    case (Frame{tx,newest},(outcome,output)):finished(~S,~C,~R,~P,~Error,~Out,newest,output,T.finish(~W.World<S,C,Storage.Resources<R,P>,Nat>,~Nat,~Error,~Cmd.enqueue(~S,~C,~Storage.Resources<R,P>,~Nat),~Cmd.publish(~S,~C,~Storage.Resources<R,P>,~Nat),tx,outcome))
def runner(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Domain<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-grant:Write<S,P,identity,H> -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,Storage.Resources<R,P>,Nat>,args:Args) -> Sys.Outcome<W.World<S,C,Storage.Resources<R,P>,Nat>,Unit,Reply<Error,Out,P>>:
  returned(~S,~C,~R,~P,~Error,~Out,body(Frame<W.World<S,C,Storage.Resources<R,P>,Nat>,P>,Write{staged(~W.World<S,C,Storage.Resources<R,P>,Nat>,~P)},args,Frame{T.begin(~W.World<S,C,Storage.Resources<R,P>,Nat>,~Nat,world),[]}))
def Registry(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Domain<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-grant:Write<S,P,identity,H> -> Args -> H -> H & (T.Outcome<Error> & Out)) -> Type:
  Sys.Registry<S,C,Storage.Resources<R,P>,Nat,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~R,~P,~identity,~Args,~Error,~Out,~body)>
def define(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Domain<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-grant:Write<S,P,identity,H> -> Args -> H -> H & (T.Outcome<Error> & Out),world:W.World<S,C,Storage.Resources<R,P>,Nat>,name:String) -> Sys.RegistrationResult<S,C,Storage.Resources<R,P>,Nat,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~R,~P,~identity,~Args,~Error,~Out,~body)>:
  Sys.register(~S,~C,~Storage.Resources<R,P>,~Nat,~Args,~Unit,~Reply<Error,Out,P>,~runner(~S,~C,~R,~P,~identity,~Args,~Error,~Out,~body),world,name,[access(~S,~P,identity,":write")])
def run(~S:Data,~C:Type,~R:Type,~P:Type,~identity:Domain<S,P>,~Args:Type,~Error:Data,~Out:Type,~body:@-H:Type -> @-grant:Write<S,P,identity,H> -> Args -> H -> H & (T.Outcome<Error> & Out),registry:Sys.Registry<S,C,Storage.Resources<R,P>,Nat,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~R,~P,~identity,~Args,~Error,~Out,~body)>,world:W.World<S,C,Storage.Resources<R,P>,Nat>,args:Args) -> Sys.RunResult<S,C,Storage.Resources<R,P>,Nat,Args,Unit,Reply<Error,Out,P>,runner(~S,~C,~R,~P,~identity,~Args,~Error,~Out,~body)>:
  Sys.run(~S,~C,~Storage.Resources<R,P>,~Nat,~Args,~Unit,~Reply<Error,Out,P>,~runner(~S,~C,~R,~P,~identity,~Args,~Error,~Out,~body),registry,world,args)
