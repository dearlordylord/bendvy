import Base
import health-tx-observe.bend as Inspect
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/transaction.bend as Tx
import ../dense-runtime-v1/types.bend as T
import health-callbacks.bend as C
import health-local.bend as L
import health-reader.bend as Reader
import health-parameters.bend as P
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world.bend as W

def reservation(value:Maybe<&2,W.Reservation<T.HealthSchema>>) -> Maybe<&2,W.Handle<T.HealthSchema>>:
  match value:
    case Some{W.Reserved{handle}}:Some{handle}
    case _:None{}
def output(~R:Data,value:C.Output<R>) -> C.Output<R> & Maybe<&2,W.Handle<T.HealthSchema>>:
  match value:
    case C.Output{outcome,reading,+reserved,payload,writes,ledger,rejected,error,lookup}:(C.Output{outcome,reading,reserved,payload,writes,ledger,rejected,error,lookup},reservation(reserved))
def a_returned(outcome:Tx.Outcome<U32>,facts:Inspect.Facts,value:C.Output<Unit> & Maybe<&2,W.Handle<T.HealthSchema>>) -> L.Call & Maybe<&2,W.Handle<T.HealthSchema>>:
  match value:
    case (returned,handle):(L.ACall{outcome,returned,facts},handle)
def b_returned(status:U32,error:Maybe<&2,U32>,facts:Inspect.Facts,value:C.Output<P.ping_view()> & Maybe<&2,W.Handle<T.HealthSchema>>) -> L.Call & Maybe<&2,W.Handle<T.HealthSchema>>:
  match value:
    case (returned,handle):(L.BCall{status,error,Some{Reader.Read{returned,facts}}},handle)
def harvest(value:L.Call) -> L.Call & Maybe<&2,W.Handle<T.HealthSchema>>:
  match value:
    case L.ACall{outcome,returned,facts}:a_returned(outcome,facts,output(~Unit,returned))
    case L.BCall{status,error,Some{Reader.Read{returned,facts}}}:b_returned(status,error,facts,output(~P.ping_view(),returned))
    case L.BCall{status,error,None{}}:(L.BCall{status,error,None{}},None{})
