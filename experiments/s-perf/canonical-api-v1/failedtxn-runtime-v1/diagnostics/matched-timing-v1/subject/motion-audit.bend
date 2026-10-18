import Base
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import motion-resources.bend as R
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-service-request.bend as Request

def identity() -> Request.Identity<T.MotionSchema,String,Unit>:Request.Identity{1,"Audit"}
def Declaration() -> Type:Request.Declaration<T.MotionSchema,R.Resources(),R.Audit,T.MotionLedger,String,Unit,identity(),R.take_audit,R.put_audit,R.record>
def declaration() -> Declaration():
  Request.declare(~T.MotionSchema,~R.Resources(),~R.Audit,~T.MotionLedger,~String,~Unit,~identity(),~R.take_audit,~R.put_audit,~R.record)
def Grant(~H:Type) -> Type:Request.Grant<T.MotionSchema,String,Unit,identity(),H>
def key() -> String:Request.declaration_key(~T.MotionSchema,~R.Resources(),~R.Audit,~T.MotionLedger,~String,~Unit,~identity(),~R.take_audit,~R.put_audit,~R.record,declaration())
