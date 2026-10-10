import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector-stream-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/inspector-transition-projection.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/inspector-failure-projection.bend as Fail
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St

type Values<S:Data,K:Data,V:Data,E:Data> is Data:
  Values{transitions:T.TransitionLog<S,K,V>,failures:Fail.FailureView<S,E>}
type Description<S:Data,K:Data,V:Data,E:Data> is Data:
  Description{name:String,values:Values<S,K,V,E>}
def transition_name(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & St.Stream<V>,declaration:T.Declaration<S,K,V,R,take>) -> String:
  match declaration:
    case T.Declaration{name}:name
type Application<S:Data,K:Data,V:Data,C:Type,R:Type,E:Data,H:Type,-take:R -> R & St.Stream<V>,-transition:T.Declaration<S,K,V,R,take>,-failure:Fail.Declaration<S>> is Type:
  Application{runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>,owners:H,cursor:U32,debug:Bool}
def failure_done(~S:Data,~K:Data,~V:Data,~E:Data,~H:Type,transitions:T.TransitionLog<S,K,V>,returned:H & Fail.FailureView<S,E>) -> H & Values<S,K,V,E>:
  (owner,failures)=returned
  (owner,Values{transitions,failures})
def transition_done(~S:Data,~K:Data,~V:Data,~E:Data,~H:Type,~grant:Cap.ValueRead<H,Fail.FailureView<S,E>>,returned:H & T.TransitionLog<S,K,V>) -> H & Values<S,K,V,E>:
  (owner,transitions)=returned
  failure_done(~S,~K,~V,~E,~H,transitions,Cap.value_read(~H,~Fail.FailureView<S,E>,~grant,owner))
def transition_grant(~S:Data,~K:Data,~V:Data,~E:Data,~H:Type,grants:Cap.ValueRead<H,T.TransitionLog<S,K,V>> & Cap.ValueRead<H,Fail.FailureView<S,E>>) -> Cap.ValueRead<H,T.TransitionLog<S,K,V>>:
  (transition,_)=grants
  transition
def failure_grant(~S:Data,~K:Data,~V:Data,~E:Data,~H:Type,grants:Cap.ValueRead<H,T.TransitionLog<S,K,V>> & Cap.ValueRead<H,Fail.FailureView<S,E>>) -> Cap.ValueRead<H,Fail.FailureView<S,E>>:
  (_,failure)=grants
  failure
def selected(~S:Data,~K:Data,~V:Data,~E:Data,~H:Type,~grants:Cap.ValueRead<H,T.TransitionLog<S,K,V>> & Cap.ValueRead<H,Fail.FailureView<S,E>>,args:Unit,owner:H) -> H & Values<S,K,V,E>:
  transition_done(~S,~K,~V,~E,~H,~failure_grant(~S,~K,~V,~E,~H,grants),Cap.value_read(~H,~T.TransitionLog<S,K,V>,~transition_grant(~S,~K,~V,~E,~H,grants),owner))
def bind(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~H:Type,~take:R -> R & St.Stream<V>,~transition:T.Declaration<S,K,V,R,take>,~failure:Fail.Declaration<S>,runtime:Ev.Runtime<S,C,R,A.Notice<S,E>>,owners:H,cursor:U32) -> Application<S,K,V,C,R,E,H,take,transition,failure>:
  Application{runtime,owners,cursor,False{}}
def read_finished(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~H:Type,~take:R -> R & St.Stream<V>,~transition:T.Declaration<S,K,V,R,take>,~failure:Fail.Declaration<S>,owners:H,debug:Bool,returned:F.Frame<S,C,R,E> & Values<S,K,V,E>) -> Application<S,K,V,C,R,E,H,take,transition,failure> & Values<S,K,V,E>:
  match returned:
    case (F.Frame{runtime,cursor},values):(Application{runtime,owners,cursor,debug},values)
def read_app(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~H:Type,~take:R -> R & St.Stream<V>,~transition:T.Declaration<S,K,V,R,take>,~failure:Fail.Declaration<S>,app:Application<S,K,V,C,R,E,H,take,transition,failure>) -> Application<S,K,V,C,R,E,H,take,transition,failure> & Values<S,K,V,E>:
  match app:
    case Application{runtime,owners,cursor,debug}:read_finished(~S,~K,~V,~C,~R,~E,~H,~take,~transition,~failure,owners,debug,Cap.invoke(~(Owner => Cap.ValueRead<Owner,T.TransitionLog<S,K,V>> & Cap.ValueRead<Owner,Fail.FailureView<S,E>>),~Unit,~Values<S,K,V,E>,~selected(~S,~K,~V,~E),~F.Frame<S,C,R,E>,~(T.inspect(~S,~K,~V,~C,~R,~E,~take,~transition),Fail.inspect(~S,~C,~R,~E,~failure)),Unit{},F.Frame{runtime,cursor}))
def enabled(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~H:Type,~take:R -> R & St.Stream<V>,~transition:T.Declaration<S,K,V,R,take>,~failure:Fail.Declaration<S>,app:Application<S,K,V,C,R,E,H,take,transition,failure>,flag:Bool) -> Application<S,K,V,C,R,E,H,take,transition,failure>:
  match app:
    case Application{runtime,owners,cursor,_}:Application{runtime,owners,cursor,flag}
def snapshot_read(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~H:Type,~take:R -> R & St.Stream<V>,~transition:T.Declaration<S,K,V,R,take>,~failure:Fail.Declaration<S>,returned:Application<S,K,V,C,R,E,H,take,transition,failure> & Values<S,K,V,E>) -> Application<S,K,V,C,R,E,H,take,transition,failure> & Maybe<&2,Description<S,K,V,E>>:
  match returned:
    case (Application{runtime,owners,cursor,debug},values):(Application{runtime,owners,U32.add(cursor,1),debug},Some{Description{transition_name(~S,~K,~V,~R,~take,transition),values}})
def snapshot(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~H:Type,~take:R -> R & St.Stream<V>,~transition:T.Declaration<S,K,V,R,take>,~failure:Fail.Declaration<S>,app:Application<S,K,V,C,R,E,H,take,transition,failure>) -> Application<S,K,V,C,R,E,H,take,transition,failure> & Maybe<&2,Description<S,K,V,E>>:
  match app:
    case Application{runtime,owners,cursor,False{}}:(Application{runtime,owners,cursor,False{}},None{})
    case Application{runtime,owners,cursor,True{}}:snapshot_read(~S,~K,~V,~C,~R,~E,~H,~take,~transition,~failure,read_app(~S,~K,~V,~C,~R,~E,~H,~take,~transition,~failure,Application{runtime,owners,cursor,True{}}))
def with_runtime_finished(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~H:Type,~take:R -> R & St.Stream<V>,~transition:T.Declaration<S,K,V,R,take>,~failure:Fail.Declaration<S>,~O:Type,owners:H,cursor:U32,debug:Bool,returned:Ev.Runtime<S,C,R,A.Notice<S,E>> & O) -> Application<S,K,V,C,R,E,H,take,transition,failure> & O:
  (runtime,out)=returned
  (Application{runtime,owners,cursor,debug},out)
def with_runtime(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~H:Type,~take:R -> R & St.Stream<V>,~transition:T.Declaration<S,K,V,R,take>,~failure:Fail.Declaration<S>,~O:Type,effect:Ev.Runtime<S,C,R,A.Notice<S,E>> -> Ev.Runtime<S,C,R,A.Notice<S,E>> & O,app:Application<S,K,V,C,R,E,H,take,transition,failure>) -> Application<S,K,V,C,R,E,H,take,transition,failure> & O:
  match app:
    case Application{runtime,owners,cursor,debug}:with_runtime_finished(~S,~K,~V,~C,~R,~E,~H,~take,~transition,~failure,~O,owners,cursor,debug,effect(runtime))
