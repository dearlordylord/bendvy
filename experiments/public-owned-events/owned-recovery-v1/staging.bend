import Base
# Detached invocation-created or explicitly transferred surviving owners only.
# Internal newest-first list; every terminal receipt returns publication FIFO.
type Stage<-Payload:Type> is Type: Stage{newest:List<Payload>}
type Offered<-Payload:Type> is Type:
  Accepted{stage:Stage<Payload>}
  Refused{stage:Stage<Payload>,incoming:Payload}
type Committed<-Payload:Type> is Type: Committed{owners:List<Payload>}
type Aborted<-Payload:Type> is Type: Aborted{owners:List<Payload>}
def empty(~Payload:Type) -> Stage<Payload>:
  Stage{[]}
def offer(~Payload:Type,allowed:Bool,stage:Stage<Payload>,incoming:Payload) -> Offered<Payload>:
  match allowed stage:
    case True{} Stage{newest}: Accepted{Stage{incoming <> newest}}
    case False{} stage: Refused{stage,incoming}
def commit(~Payload:Type,stage:Stage<Payload>) -> Committed<Payload>:
  match stage:
    case Stage{newest}: Committed{List.reverse(&1,Payload,newest)}
def abort(~Payload:Type,stage:Stage<Payload>) -> Aborted<Payload>:
  match stage:
    case Stage{newest}: Aborted{List.reverse(&1,Payload,newest)}
