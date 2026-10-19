import Base
import ../../../../../../src/ecs/transaction.bend as Tx
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../consumer/motion-callbacks.bend as C
import motion-local.bend as L
import motion-reader.bend as Reader
import ../../../consumer/motion-parameters.bend as P
import ../../../../../../src/ecs/world.bend as W

def reservation(value:Maybe<&2,W.Reservation<T.MotionSchema>>) -> Maybe<&2,W.Handle<T.MotionSchema>>:
  match value:
    case Some{W.Reserved{handle}}:Some{handle}
    case _:None{}
def output(~R:Data,value:C.Output<R>) -> C.Output<R> & Maybe<&2,W.Handle<T.MotionSchema>>:
  match value:
    case C.Output{outcome,reading,+reserved,payload,writes,ledger,rejected,error,lookup}:(C.Output{outcome,reading,reserved,payload,writes,ledger,rejected,error,lookup},reservation(reserved))
def a_returned(outcome:Tx.Outcome<U32>,value:C.Output<Unit> & Maybe<&2,W.Handle<T.MotionSchema>>) -> L.Call & Maybe<&2,W.Handle<T.MotionSchema>>:
  match value:
    case (returned,handle):(L.ACall{outcome,returned},handle)
def b_returned(status:U32,error:Maybe<&2,U32>,value:C.Output<P.ping_view()> & Maybe<&2,W.Handle<T.MotionSchema>>) -> L.Call & Maybe<&2,W.Handle<T.MotionSchema>>:
  match value:
    case (returned,handle):(L.BCall{status,error,Some{Reader.Read{returned}}},handle)
def harvest(value:L.Call) -> L.Call & Maybe<&2,W.Handle<T.MotionSchema>>:
  match value:
    case L.ACall{outcome,returned}:a_returned(outcome,output(~Unit,returned))
    case L.BCall{status,error,Some{Reader.Read{returned}}}:b_returned(status,error,output(~P.ping_view(),returned))
    case L.BCall{status,error,None{}}:(L.BCall{status,error,None{}},None{})
