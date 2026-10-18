import Base
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import motion-resources.bend as R
import ../../../../src/ecs/ordinary-service-request.bend as Request

def identity() -> Request.Identity<T.MotionSchema,String,Unit>:Request.Identity{1,"Audit"}
def Declaration() -> Type:Request.Declaration<T.MotionSchema,R.Resources(),R.Audit,T.MotionLedger,String,Unit,identity(),R.take_audit,R.put_audit,R.record>
def declaration() -> Declaration():
  Request.declare(~T.MotionSchema,~R.Resources(),~R.Audit,~T.MotionLedger,~String,~Unit,~identity(),~R.take_audit,~R.put_audit,~R.record)
def Grant(~H:Type) -> Type:Request.Grant<T.MotionSchema,String,Unit,identity(),H>
def key() -> String:Request.declaration_key(~T.MotionSchema,~R.Resources(),~R.Audit,~T.MotionLedger,~String,~Unit,~identity(),~R.take_audit,~R.put_audit,~R.record,declaration())
