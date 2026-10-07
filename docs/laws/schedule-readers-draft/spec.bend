import Base
import ../../../src/ecs/event-runtime.bend as Ev

# Independent direct recursive filters; no accumulator or production split.
def prepend(~E:Data,keep:Bool,value:E,rest:List<&2,E>) -> List<&2,E>:
  match keep:
    case True{}: value <> rest
    case False{}: rest
def selected(~E:Data,~select:E -> Bool,items:List<&2,E>) -> List<&2,E>:
  match items:
    case []: []
    case +head <> rest: prepend(~E,select(head),head,selected(~E,~select,rest))
def rejected(~E:Data,~select:E -> Bool,items:List<&2,E>) -> List<&2,E>:
  match items:
    case []: []
    case +head <> rest: prepend(~E,Bool.not(select(head)),head,rejected(~E,~select,rest))
def keep_batch(~E:Data,tick:Nat,items:List<&2,E>,rest:List<&2,Ev.Batch<E>>) -> List<&2,Ev.Batch<E>>:
  match items:
    case []: rest
    case items: Ev.Batch{tick,items} <> rest
def batches(~E:Data,~select:E -> Bool,items:List<&2,Ev.Batch<E>>) -> List<&2,Ev.Batch<E>>:
  match items:
    case []: []
    case Ev.Batch{tick,values} <> rest: keep_batch(~E,tick,selected(~E,~select,values),batches(~E,~select,rest))
def ticks(~E:Data,items:List<&2,Ev.Batch<E>>) -> List<&2,Nat>:
  match items:
    case []: []
    case Ev.Batch{tick,_} <> rest: tick <> ticks(~E,rest)
