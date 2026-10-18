import Base
import tx-metrics.bend as Metrics
import health-domain.bend as D
import health-systems.bend as S
import health-stream.bend as Stream
import health-stream-scenario.bend as Scenario
import health-reader.bend as Reader
import health-events.bend as E

def kind(value:U32) -> String:
  match value:
    case 0:"spawn"
    case 1:"update"
    case 2:"dispose"
    case _:"seed"
def fact(value:D.TxFacts) -> Metrics.Sample:
  match value:
    case D.TxFacts{operation,undo,commands,events,_,_}:Metrics.Sample{kind(operation),undo,commands,List.length(&2,E.event_type(),events)}
def facts(values:List<&2,D.TxFacts>) -> List<&2,Metrics.Sample>:
  match values:
    case []:[]
    case head <> tail:fact(head) <> facts(tail)
def frame(value:D.Frame) -> List<&2,Metrics.Sample>:
  match value:
    case D.Frame{_,_,_,_,values}:facts(values)
def local(value:S.LocalCall) -> List<&2,Metrics.Sample>:
  match value:
    case S.LocalCall{_,_,_,Some{value}}:frame(value)
    case _:[]
def locals_go(values:List<&2,S.LocalCall>) -> List<&2,Metrics.Sample>:
  match values:
    case []:[]
    case head <> tail:List.append(&2,Metrics.Sample,local(head),locals_go(tail))
def read(value:S.ReadCall) -> List<&2,Metrics.Sample>:
  match value:
    case S.ReadCall{_,_,_,Some{Reader.Read{_,_,sample}},_,_}:[sample]
    case _:[]
def reads_go(values:List<&2,S.ReadCall>) -> List<&2,Metrics.Sample>:
  match values:
    case []:[]
    case head <> tail:List.append(&2,Metrics.Sample,read(head),reads_go(tail))
def owner(value:Stream.OwnerView) -> List<&2,Metrics.Sample>:
  match value:
    case Stream.OwnerView{_,_,_,_,_,_,_,_,_,_,locals,reads}:List.append(&2,Metrics.Sample,locals_go(locals),reads_go(reads))
def state(value:Stream.StateView) -> List<&2,Metrics.Sample>:
  match value:
    case Stream.StateView{_,_,_,owners,_}:owner(owners)
def report(value:Scenario.Prepared) -> String:
  match value:
    case Scenario.Ready{_,view,_,_,seed}:Metrics.report(List.append(&2,Metrics.Sample,facts(seed),state(view)))
    case _:Metrics.report([])
