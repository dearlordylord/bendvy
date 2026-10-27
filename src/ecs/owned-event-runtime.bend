import Base
import ./world.bend as W
import ./system.bend as Sys
import ./event-runtime.bend as Ev
import ./event-runtime-legacy.bend as LegacyEv
import ./transaction.bend as T
import ./capabilities.bend as Cap
import ./owned-event-log.bend as Log
import ./owned-event-storage.bend as Storage
import ./ordinary-owned-event.bend as Ord

# One declared reader folds its unread payloads through a confined request cap.
# Providers are trusted schema provisioning; payload ownership stays in the log.
type Failure<Error:Data> is Data:
  BodyFailed{error:Error}
  MissingPayload{}
type Reply<Error:Data,Args:Type> is Type:
  Reply{outcome:T.Outcome<Failure<Error>>,args:Args,lagged:Bool}
def stopped(~S:Data,~C:Type,~R:Type,~P:Type,~Args:Type,~Error:Data,world:W.World<S,C,Storage.Resources<R,P>,Nat>,args:Args,outcome:T.Outcome<Failure<Error>>,lagged:Bool) -> W.World<S,C,Storage.Resources<R,P>,Nat> & Reply<Error,Args>:
  (world,Reply{outcome,args,lagged})
def visited(~S:Data,~C:Type,~R:Type,~P:Type,~Args:Type,~Error:Data,lagged:Bool,next:W.World<S,C,Storage.Resources<R,P>,Nat> -> Args -> W.World<S,C,Storage.Resources<R,P>,Nat> & Reply<Error,Args>,result:W.World<S,C,Storage.Resources<R,P>,Nat> & Log.ReadResult<Args,T.Outcome<Error> & Args>) -> W.World<S,C,Storage.Resources<R,P>,Nat> & Reply<Error,Args>:
  match result:
    case (world,Log.Missing{args}):stopped(~S,~C,~R,~P,~Args,~Error,world,args,T.Failure{MissingPayload{}},lagged)
    case (world,Log.Found{(T.Failure{error},args)}):stopped(~S,~C,~R,~P,~Args,~Error,world,args,T.Failure{BodyFailed{error}},lagged)
    case (world,Log.Found{(T.Success{},args)}):next(world,args)
def fold_rows(~S:Data,~C:Type,~R:Type,~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~identity:Ord.Domain<S,P>,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),keys:List<&2,Nat>,world:W.World<S,C,Storage.Resources<R,P>,Nat>,args:Args,+lagged:Bool) -> W.World<S,C,Storage.Resources<R,P>,Nat> & Reply<Error,Args>:
  match keys:
    case []:stopped(~S,~C,~R,~P,~Args,~Error,world,args,T.Success{},lagged)
    case key <> remaining:visited(~S,~C,~R,~P,~Args,~Error,lagged,nextWorld => nextArgs => fold_rows(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body,remaining,nextWorld,nextArgs,lagged),Storage.read(~S,~C,~R,~P,~Request,~Projection,~Args,~(T.Outcome<Error> & Args),~at,~body,world,key,args))
def transported(~S:Data,~C:Type,~R:Type,~P:Type,~Args:Type,~Error:Data,result:W.World<S,C,Storage.Resources<R,P>,Nat> & Reply<Error,Args>) -> Sys.Outcome<W.World<S,C,Storage.Resources<R,P>,Nat>,Unit,Reply<Error,Args>>:
  match result:
    case (world,reply):Sys.Succeeded{world,reply}
def runner(~S:Data,~C:Type,~R:Type,~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~identity:Ord.Domain<S,P>,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),world:W.World<S,C,Storage.Resources<R,P>,Nat>,input:Ev.Input<Nat,Args>) -> Sys.Outcome<W.World<S,C,Storage.Resources<R,P>,Nat>,Unit,Reply<Error,Args>>:
  match input:
    case Ev.Input{keys,lagged,args}:transported(~S,~C,~R,~P,~Args,~Error,fold_rows(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body,keys,world,args,lagged))
def Registry(~S:Data,~C:Type,~R:Type,~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~identity:Ord.Domain<S,P>,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args)) -> Type:Sys.Registry<S,C,Storage.Resources<R,P>,Nat,Ev.Input<Nat,Args>,Unit,Reply<Error,Args>,runner(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body)>
def define(~S:Data,~C:Type,~R:Type,~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~identity:Ord.Domain<S,P>,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),runtime:Ev.Runtime<S,C,Storage.Resources<R,P>,Nat>,name:String) -> LegacyEv.Registered<S,C,Storage.Resources<R,P>,Nat,Args,Unit,Reply<Error,Args>,runner(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body)>:
  LegacyEv.register(~S,~C,~Storage.Resources<R,P>,~Nat,~Args,~Unit,~Reply<Error,Args>,~runner(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body),runtime,name,[Ord.access(~S,~P,identity,":read")])
# LegacyEv.run performs the existing namespace + registration checks and lazy activation.
# The closed runner transports semantic failure separately so affine output is
# returned. Restore exactly LegacyEv.run_outcome's failed-reader position afterward.
def failed_positions(~S:Data,~C:Type,~R:Type,~P:Type,old:List<&2,Ev.Position>,id:U32,runtime:Ev.Runtime<S,C,Storage.Resources<R,P>,Nat>) -> Ev.Runtime<S,C,Storage.Resources<R,P>,Nat>:
  match runtime:
    case Ev.Runtime{world,namespace,batches,_,nextReader,+tick,frameStart,boundary,capacity,dropped}:
      Ev.Runtime{world,namespace,batches,Ev.activate(old,id,Nat.sub(tick,1n)),nextReader,tick,frameStart,boundary,capacity,dropped}
def reconciled(~S:Data,~C:Type,~R:Type,~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~identity:Ord.Domain<S,P>,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),old:List<&2,Ev.Position>,id:U32,result:LegacyEv.RunResult<S,C,Storage.Resources<R,P>,Nat,Args,Unit,Reply<Error,Args>,runner(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body)>) -> LegacyEv.RunResult<S,C,Storage.Resources<R,P>,Nat,Args,Unit,Reply<Error,Args>,runner(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body)>:
  match result:
    case LegacyEv.Ran{runtime,reader,registry,Ev.Succeeded{Reply{T.Failure{error},args,lagged}}}:
      LegacyEv.Ran{failed_positions(~S,~C,~R,~P,old,id,runtime),reader,registry,Ev.Succeeded{Reply{T.Failure{error},args,lagged}}}
    case result:result

def run(~S:Data,~C:Type,~R:Type,~P:Type,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~identity:Ord.Domain<S,P>,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),runtime:Ev.Runtime<S,C,Storage.Resources<R,P>,Nat>,reader:Ev.Reader<S>,registry:Sys.Registry<S,C,Storage.Resources<R,P>,Nat,Ev.Input<Nat,Args>,Unit,Reply<Error,Args>,runner(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body)>,args:Args) -> LegacyEv.RunResult<S,C,Storage.Resources<R,P>,Nat,Args,Unit,Reply<Error,Args>,runner(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body)>:
  match runtime reader:
    case Ev.Runtime{world,namespace,batches,+positions,nextReader,tick,frameStart,boundary,capacity,dropped} Ev.Reader{readerNamespace,+id,registryId}:
      reconciled(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body,positions,id,LegacyEv.run(~S,~C,~Storage.Resources<R,P>,~Nat,~Args,~Unit,~Reply<Error,Args>,~runner(~S,~C,~R,~P,~Request,~Projection,~Args,~Error,~identity,~at,~body),Ev.Runtime{world,namespace,batches,positions,nextReader,tick,frameStart,boundary,capacity,dropped},Ev.Reader{readerNamespace,id,registryId},registry,args))
