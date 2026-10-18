import Base
import ./world.bend as W
import ./system.bend as Sys
import ./system-instance.bend as SI
import ./system-cleanup.bend as Cleanup
import ./machine.bend as M
import ./machine-stream.bend as St
import ./event-runtime.bend as Ev
import ./ordinary-machine-initialization.bend as Resource
import ./ordinary-machine-declaration.bend as Machine

# One schema-owned declaration binds the actual stream lens and descriptive name.
type Declaration<-S:Data,-K:Data,-V:Data,-R:Type,-take:R -> R & St.Stream<V>,-put:R -> St.Stream<V> -> R> is Data:
  Declaration{name:String}
type Input<V:Data,A:Type> is Type:
  Input{reading:Ev.Reading<M.Transition<V>>,args:A}
type Completion<Error:Data,Out:Type> is Type:
  CallbackSucceeded{output:Out}
  CallbackFailed{error:Error}
type ReadResult<-World:Type,-Reader:Type,-Args:Type,-Error:Data,-Out:Type,-V:Data> is Type:
  ReadSucceeded{world:World,reader:Reader,output:Out,reading:Ev.Reading<M.Transition<V>>}
  ReadFailed{world:World,reader:Reader,error:Error,reading:Ev.Reading<M.Transition<V>>}
  ReadRejected{world:World,reader:Reader,args:Args}

def validate(~S:Data,~K:Data,reader:St.Reader<S,K>,namespace:U32,id:U32) -> St.Reader<S,K> & Bool:
  match reader:
    case St.Reader{+actual,+key}:(St.Reader{actual,key},Bool.and(U32.is_eq(actual,namespace),U32.is_eq(key,id)))
def create(~S:Data,~K:Data,~C:Type,~R:Type,~E:Data,namespace:U32,id:U32,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & St.Reader<S,K>:
  (world,St.Reader{namespace,id})
def stream_set_result(~S:Data,~C:Type,~R:Type,~E:Data,result:W.World<S,C,R,E> & Unit) -> W.World<S,C,R,E>:
  match result:
    case (world,_):world
def stream_set_resource(~V:Data,~R:Type,~put:R -> St.Stream<V> -> R,stream:St.Stream<V>,resource:R) -> R & Unit:
  (put(resource,stream),Unit{})
def stream_set(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~put:R -> St.Stream<V> -> R,world:W.World<S,C,R,E>,stream:St.Stream<V>) -> W.World<S,C,R,E>:
  stream_set_result(~S,~C,~R,~E,Resource.with_resource(~S,~C,~R,~E,~Unit,(resource => stream_set_resource(~V,~R,~put,stream,resource)),world))
def removed(~S:Data,~V:Data,~C:Type,~R:Type,~E:Data,~put:R -> St.Stream<V> -> R,id:U32,result:W.World<S,C,R,E> & St.Stream<V>) -> W.World<S,C,R,E>:
  match result:
    case (world,stream):stream_set(~S,~V,~C,~R,~E,~put,world,St.dispose(~V,stream,id))
def remove(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,world:W.World<S,C,R,E>,reader:St.Reader<S,K>) -> W.World<S,C,R,E>:
  match reader:
    case St.Reader{_,id}:removed(~S,~V,~C,~R,~E,~put,id,W.observe_resource(~S,~C,~R,~E,~St.Stream<V>,~take,world))

# Initializer declarations supply the same operational state cell and name.
def initialized_taken(~S:Data,~K:Data,~V:Data,~R:Type,~put:R -> Resource.State<S,K,V> -> R,result:R & Resource.State<S,K,V>) -> R & St.Stream<V>:
  match result:
    case (resource,Resource.State{slot,+stream,revision}):(put(resource,Resource.State{slot,stream,revision}),stream)
def initialized_take(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Resource.State<S,K,V>,~put:R -> Resource.State<S,K,V> -> R,resource:R) -> R & St.Stream<V>:
  initialized_taken(~S,~K,~V,~R,~put,take(resource))
def initialized_put_taken(~S:Data,~K:Data,~V:Data,~R:Type,~put:R -> Resource.State<S,K,V> -> R,stream:St.Stream<V>,result:R & Resource.State<S,K,V>) -> R:
  match result:
    case (resource,Resource.State{slot,_,revision}):put(resource,Resource.State{slot,stream,revision})
def initialized_put(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Resource.State<S,K,V>,~put:R -> Resource.State<S,K,V> -> R,resource:R,stream:St.Stream<V>) -> R:
  initialized_put_taken(~S,~K,~V,~R,~put,stream,take(resource))
def from_initialization(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & Resource.State<S,K,V>,~put:R -> Resource.State<S,K,V> -> R,~declaration:Machine.Declaration<S,K,V,R,Resource.take_slot(~S,~K,~V,~R,~take,~put)>) -> Declaration<S,K,V,R,initialized_take(~S,~K,~V,~R,~take,~put),initialized_put(~S,~K,~V,~R,~take,~put)>:
  Declaration{Machine.name(~S,~K,~V,~R,~Resource.take_slot(~S,~K,~V,~R,~take,~put),declaration)}

def instance_type(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>) -> Type:SI.Instance<S,C,R,E,Input<V,A>,Error,Out,callback,St.Reader<S,K>,validate(~S,~K),remove(~S,~K,~V,~C,~R,~E,~take,~put)>
def registration_type(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>) -> Type:SI.Registration<S,C,R,E,Input<V,A>,Error,Out,callback,St.Reader<S,K>,validate(~S,~K),remove(~S,~K,~V,~C,~R,~E,~take,~put)>
def disposal_type(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>) -> Type:SI.Disposal<S,C,R,E,Input<V,A>,Error,Out,callback,St.Reader<S,K>,validate(~S,~K),remove(~S,~K,~V,~C,~R,~E,~take,~put)>
def access(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,value:Declaration<S,K,V,R,take,put>) -> List<&2,String>:
  match value:
    case Declaration{name}:["machine." ++ name ++ ".transition.read"]
def register(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,~declaration:Declaration<S,K,V,R,take,put>,world:W.World<S,C,R,E>,name:String) -> registration_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback):
  SI.register(~S,~C,~R,~E,~Input<V,A>,~Error,~Out,~callback,~St.Reader<S,K>,~validate(~S,~K),~remove(~S,~K,~V,~C,~R,~E,~take,~put),~create(~S,~K,~C,~R,~E),world,name,access(~S,~K,~V,~R,~take,~put,declaration))
def dispose(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,reader:instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),world:W.World<S,C,R,E>) -> disposal_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback):
  SI.dispose(~S,~C,~R,~E,~Input<V,A>,~Error,~Out,~callback,~St.Reader<S,K>,~validate(~S,~K),~remove(~S,~K,~V,~C,~R,~E,~take,~put),reader,world)
# Unrun reader parameters neither activate nor consume unread transitions.
def skip(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,reader:instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),world:W.World<S,C,R,E>) -> instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback) & W.World<S,C,R,E>:(reader,world)

def delivered(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,reader:instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),world:W.World<S,C,R,E>,reading:Ev.Reading<M.Transition<V>>,completion:Completion<Error,Out>) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  match completion:
    case CallbackSucceeded{output}:ReadSucceeded{world,reader,output,reading}
    case CallbackFailed{error}:ReadFailed{world,reader,error,reading}
def finished(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,registry:Sys.Registry<S,C,R,E,Input<V,A>,Error,Out,callback>,world:W.World<S,C,R,E>,reading:Ev.Reading<M.Transition<V>>,completion:Completion<Error,Out>,result:St.Reader<S,K> & St.Stream<V>) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  match result:
    case (reader,stream):delivered(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,SI.Instance{Cleanup.Instance{registry,reader}},stream_set(~S,~V,~C,~R,~E,~put,world,stream),reading,completion)
def finishing(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,reader:instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),reading:Ev.Reading<M.Transition<V>>,tick:Nat,success:Bool,completion:Completion<Error,Out>,result:W.World<S,C,R,E> & St.Stream<V>) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  match reader result:
    case SI.Instance{Cleanup.Instance{registry,ports}}, (world,stream):finished(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,registry,world,reading,completion,St.finish(~S,~K,~V,ports,stream,tick,success))
def finish(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,reader:instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),world:W.World<S,C,R,E>,reading:Ev.Reading<M.Transition<V>>,tick:Nat,success:Bool,completion:Completion<Error,Out>) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  finishing(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,reader,reading,tick,success,completion,W.observe_resource(~S,~C,~R,~E,~St.Stream<V>,~take,world))
def callback_result(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,reading:Ev.Reading<M.Transition<V>>,tick:Nat,result:SI.RunResult<S,C,R,E,Input<V,A>,Error,Out,callback,St.Reader<S,K>,validate(~S,~K),remove(~S,~K,~V,~C,~R,~E,~take,~put)>) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  match result:
    case SI.Completed{reader,Sys.Succeeded{world,output}}:finish(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,reader,world,reading,tick,True{},CallbackSucceeded{output})
    case SI.Completed{reader,Sys.Failed{world,error}}:finish(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,reader,world,reading,tick,False{},CallbackFailed{error})
    case SI.RegistrationRejected{reader,world,Input{_,args}}:ReadRejected{world,reader,args}
def opened(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,registry:Sys.Registry<S,C,R,E,Input<V,A>,Error,Out,callback>,world:W.World<S,C,R,E>,args:A,tick:Nat,result:St.OpenResult<S,K,V>) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  match result:
    case St.ReaderRefused{reader,stream}:ReadRejected{stream_set(~S,~V,~C,~R,~E,~put,world,stream),SI.Instance{Cleanup.Instance{registry,reader}},args}
    case St.Opened{reader,stream,+reading}:callback_result(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,reading,tick,SI.run_tracked(~S,~C,~R,~E,~Input<V,A>,~Error,~Out,~callback,~St.Reader<S,K>,~validate(~S,~K),~remove(~S,~K,~V,~C,~R,~E,~take,~put),SI.Instance{Cleanup.Instance{registry,reader}},stream_set(~S,~V,~C,~R,~E,~put,world,stream),Input{reading,args}))
def opening(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,reader:instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),args:A,+tick:Nat,result:W.World<S,C,R,E> & St.Stream<V>) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  match reader result:
    case SI.Instance{Cleanup.Instance{registry,St.Reader{+namespace,id}}}, (world,stream):opened(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,registry,world,args,tick,St.open(~S,~K,~V,St.Reader{namespace,id},stream,namespace,tick))
def clocked(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,reader:instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),args:A,result:W.World<S,C,R,E> & U32) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  match result:
    case (world,tick):opening(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,reader,args,U32.to_nat(tick),W.observe_resource(~S,~C,~R,~E,~St.Stream<V>,~take,world))
def checked(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,allowed:Bool,reader:instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),args:A,result:W.World<S,C,R,E> & Bool) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  match allowed result:
    case False{}, (world,_):ReadRejected{world,reader,args}
    case True{}, (world,False{}):ReadRejected{world,reader,args}
    case True{}, (world,True{}):clocked(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,reader,args,W.clock(~S,~C,~R,~E,world))
def namespaced(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,reader:instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),args:A,result:W.World<S,C,R,E> & U32) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  match reader result:
    case SI.Instance{Cleanup.Instance{Sys.Registry{+namespace,+id,+name,+access,cursor},St.Reader{+owner,+key}}}, (world,actual):checked(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,Bool.and(U32.is_eq(namespace,actual),Bool.and(U32.is_eq(owner,namespace),U32.is_eq(key,id))),SI.Instance{Cleanup.Instance{Sys.Registry{namespace,id,name,access,cursor},St.Reader{owner,key}}},args,W.registration_matches(~S,~C,~R,~E,world,id,name,access))
# Namespace/registration checks precede activation, callback and any cursor change.
def read(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~A:Type,~Error:Data,~Out:Type,~take:R -> R & St.Stream<V>,~put:R -> St.Stream<V> -> R,~callback:W.World<S,C,R,E> -> Input<V,A> -> Sys.Outcome<W.World<S,C,R,E>,Error,Out>,reader:instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),world:W.World<S,C,R,E>,args:A) -> ReadResult<W.World<S,C,R,E>,instance_type(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback),A,Error,Out,V>:
  namespaced(~S,~K,~V,~C,~R,~E,~A,~Error,~Out,~take,~put,~callback,reader,args,W.namespace(~S,~C,~R,~E,world))
