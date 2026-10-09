import Base
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/reader-domains.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-inspect/bend-candidate/events.bend as I
def read_done(~S:Data,~C:Type,~R:Type,~E:Data,result:I.Frame<S,C,R,E> & Ev.Reading<E>) -> Ev.Runtime<S,C,R,E> & Ev.Reading<E>:
  match result:
    case (I.Frame{world,events,_,_},value):(D.attach(~S,~C,~R,~E,events,world),value)
def detached(~S:Data,~C:Type,~R:Type,~E:Data,result:D.Detached<S,C,R,E>) -> Ev.Runtime<S,C,R,E> & Ev.Reading<E>:
  match result:
    case D.Detached{world,events}:read_done(~S,~C,~R,~E,I.read(~S,~C,~R,~E,I.Frame{world,events,0n,0n}))
def read(~S:Data,~C:Type,~R:Type,~E:Data,runtime:Ev.Runtime<S,C,R,E>) -> Ev.Runtime<S,C,R,E> & Ev.Reading<E>:
  detached(~S,~C,~R,~E,D.detach(~S,~C,~R,~E,runtime,[]))
