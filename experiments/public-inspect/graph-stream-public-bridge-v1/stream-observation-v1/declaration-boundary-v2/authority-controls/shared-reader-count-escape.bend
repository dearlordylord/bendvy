import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import ../failures.bend as Fail
def selected(~S:Data,~H:Type,owner:H,view:Fail.FailureView<S,U32>) -> H & List<&2,Ev.ReaderStatus>:
  match view:
    case Fail.FailureView{_,_,retained,_,_}:(owner,retained)
def escaped(~S:Data,~H:Type,observed:H & Fail.FailureView<S,U32>) -> H & List<&2,Ev.ReaderStatus>:
  (owner,view)=observed
  selected(~S,~H,owner,view)
def body(~S:Data,~H:Type,~cap:Cap.ValueRead<H,Fail.FailureView<S,U32>>,args:Unit,owner:H) -> H & List<&2,Ev.ReaderStatus>:
  escaped(~S,~H,Cap.value_read(~H,~Fail.FailureView<S,U32>,~cap,owner))
