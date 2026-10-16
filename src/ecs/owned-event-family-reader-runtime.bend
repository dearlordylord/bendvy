import Base
import ./world.bend as W
import ./system.bend as Sys
import ./event-runtime.bend as Ev
import ./transaction.bend as T
import ./capabilities.bend as Cap
import ./owned-event-log.bend as Log
import ./owned-event-family-storage.bend as Storage
import ./owner-product.bend as Product
import ./event-stream.bend as Stream
import ./event-family-routing.bend as Route
import ./ordinary-owned-event.bend as Ord

# One declared reader folds its unread payloads through a confined request cap.
# Providers are trusted schema provisioning; payload ownership stays in the log.
type Failure<Error:Data> is Data:
  BodyFailed{error:Error}
  MissingPayload{}
type Reply<Error:Data,Args:Type> is Type:
  Reply{outcome:T.Outcome<Failure<Error>>,args:Args,lagged:Bool}
def stopped(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Args:Type,~Error:Data,world:W.World<S,C,R,E>,args:Args,outcome:T.Outcome<Failure<Error>>,lagged:Bool) -> W.World<S,C,R,E> & Reply<Error,Args>:
  (world,Reply{outcome,args,lagged})
def visited(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Args:Type,~Error:Data,lagged:Bool,next:W.World<S,C,R,E> -> Args -> W.World<S,C,R,E> & Reply<Error,Args>,result:W.World<S,C,R,E> & Log.ReadResult<Args,T.Outcome<Error> & Args>) -> W.World<S,C,R,E> & Reply<Error,Args>:
  match result:
    case (world,Log.Missing{args}):stopped(~S,~C,~R,~P,~Rest,~E,~path,~Args,~Error,world,args,T.Failure{MissingPayload{}},lagged)
    case (world,Log.Found{(T.Failure{error},args)}):stopped(~S,~C,~R,~P,~Rest,~E,~path,~Args,~Error,world,args,T.Failure{BodyFailed{error}},lagged)
    case (world,Log.Found{(T.Success{},args)}):next(world,args)
def fold_rows(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),keys:List<&2,Nat>,world:W.World<S,C,R,E>,args:Args,+lagged:Bool) -> W.World<S,C,R,E> & Reply<Error,Args>:
  match keys:
    case []:stopped(~S,~C,~R,~P,~Rest,~E,~path,~Args,~Error,world,args,T.Success{},lagged)
    case key <> remaining:visited(~S,~C,~R,~P,~Rest,~E,~path,~Args,~Error,lagged,nextWorld => nextArgs => fold_rows(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body,remaining,nextWorld,nextArgs,lagged),Storage.read(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~(T.Outcome<Error> & Args),~at,~body,world,key,args))
def transported(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Args:Type,~Error:Data,result:W.World<S,C,R,E> & Reply<Error,Args>) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Error,Args>>:
  match result:
    case (world,reply):Sys.Succeeded{world,reply}
def runner(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),world:W.World<S,C,R,E>,input:Ev.Input<Nat,Args>) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Reply<Error,Args>>:
  match input:
    case Ev.Input{keys,lagged,args}:transported(~S,~C,~R,~P,~Rest,~E,~path,~Args,~Error,fold_rows(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body,keys,world,args,lagged))

# The closed runner retains affine Args even on semantic failure. Route.run must
# see transport success; reconcile its selected stream to the exact existing
# failed-reader activation rule afterward, without changing other streams.
def restored_stream(~S:Data,old:List<&2,Ev.Position>,id:U32,tick:Nat,stream:Stream.Stream<S,Nat>) -> Stream.Stream<S,Nat>:
  match stream:
    case Stream.Stream{domain,batches,_,nextReader,frameStart,boundary,capacity,dropped}:Stream.Stream{domain,batches,Ev.activate(old,id,Nat.sub(tick,1n)),nextReader,frameStart,boundary,capacity,dropped}
def restore_taken(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~put:F -> Stream.Stream<S,Nat> -> F,world:W.World<S,C,R,E>,+tick:Nat,old:List<&2,Ev.Position>,id:U32,returned:F & Stream.Stream<S,Nat>) -> Route.Runtime<S,C,R,E,F>:
  match returned:
    case (family,stream):Route.Runtime{world,put(family,restored_stream(~S,old,id,tick,stream)),tick}
def restore(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,old:List<&2,Ev.Position>,id:U32,runtime:Route.Runtime<S,C,R,E,F>) -> Route.Runtime<S,C,R,E,F>:
  match runtime:
    case Route.Runtime{world,family,tick}:restore_taken(~S,~C,~R,~E,~F,~put,world,tick,old,id,take(family))
def reconciled(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,old:List<&2,Ev.Position>,id:U32,result:Route.RunResult<S,C,R,E,Nat,F,Args,Unit,Reply<Error,Args>,take,put,runner(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body)>) -> Route.RunResult<S,C,R,E,Nat,F,Args,Unit,Reply<Error,Args>,take,put,runner(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body)>:
  match result:
    case Route.Ran{runtime,reader,registry,Ev.Succeeded{Reply{T.Failure{error},args,lagged}}}:Route.Ran{restore(~S,~C,~R,~E,~F,~take,~put,old,id,runtime),reader,registry,Ev.Succeeded{Reply{T.Failure{error},args,lagged}}}
    case result:result
def run_taken(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,~synchronize:W.World<S,C,R,E> -> F -> Nat -> W.World<S,C,R,E> & F,world:W.World<S,C,R,E>,tick:Nat,reader:Route.Reader<S,Nat,F,take,put>,registry:Sys.Registry<S,C,R,E,Ev.Input<Nat,Args>,Unit,Reply<Error,Args>,runner(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body)>,args:Args,returned:F & Stream.Stream<S,Nat>) -> Route.RunResult<S,C,R,E,Nat,F,Args,Unit,Reply<Error,Args>,take,put,runner(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body)>:
  match reader returned:
    case Route.Reader{namespace,+id,registryId}, (family,Stream.Stream{_,_,positions,_,_,_,_,_}):reconciled(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body,~F,~take,~put,positions,id,Route.run(~S,~C,~R,~E,~Nat,~F,~Args,~Unit,~Reply<Error,Args>,~take,~put,~runner(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body),~synchronize,Route.Runtime{world,family,tick},Route.Reader{namespace,id,registryId},registry,args))
def run(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,~synchronize:W.World<S,C,R,E> -> F -> Nat -> W.World<S,C,R,E> & F,runtime:Route.Runtime<S,C,R,E,F>,reader:Route.Reader<S,Nat,F,take,put>,registry:Sys.Registry<S,C,R,E,Ev.Input<Nat,Args>,Unit,Reply<Error,Args>,runner(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body)>,args:Args) -> Route.RunResult<S,C,R,E,Nat,F,Args,Unit,Reply<Error,Args>,take,put,runner(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body)>:
  match runtime:
    case Route.Runtime{world,family,tick}:run_taken(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body,~F,~take,~put,~synchronize,world,tick,reader,registry,args,take(family))
def register(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~Request:Type,~Projection:Data,~Args:Type,~Error:Data,~at:P -> Request -> P & Projection,~body:@-H:Type -> @-read:Cap.Request<H,Request,Projection> -> H -> Args -> H & (T.Outcome<Error> & Args),~F:Type,~take:F -> F & Stream.Stream<S,Nat>,~put:F -> Stream.Stream<S,Nat> -> F,runtime:Route.Runtime<S,C,R,E,F>,name:String) -> Route.Registration<S,C,R,E,Nat,F,Args,Unit,Reply<Error,Args>,take,put,runner(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body)>:
  Route.register(~S,~C,~R,~E,~Nat,~F,~Args,~Unit,~Reply<Error,Args>,~take,~put,~runner(~S,~C,~R,~P,~Rest,~E,~path,~Request,~Projection,~Args,~Error,~at,~body),runtime,name)
