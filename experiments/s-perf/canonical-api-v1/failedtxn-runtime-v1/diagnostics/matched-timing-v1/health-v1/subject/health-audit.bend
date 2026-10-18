import Base
import /tmp/bendvy-failedtxn-health-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import health-resources.bend as R
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/ordinary-service-request.bend as Request

def identity() -> Request.Identity<T.HealthSchema,String,Unit>:Request.Identity{1,"Audit"}
def Declaration() -> Type:Request.Declaration<T.HealthSchema,R.Resources(),R.Audit,T.HealthLedger,String,Unit,identity(),R.take_audit,R.put_audit,R.record>
def declaration() -> Declaration():
  Request.declare(~T.HealthSchema,~R.Resources(),~R.Audit,~T.HealthLedger,~String,~Unit,~identity(),~R.take_audit,~R.put_audit,~R.record)
def Grant(~H:Type) -> Type:Request.Grant<T.HealthSchema,String,Unit,identity(),H>
def key() -> String:Request.declaration_key(~T.HealthSchema,~R.Resources(),~R.Audit,~T.HealthLedger,~String,~Unit,~identity(),~R.take_audit,~R.put_audit,~R.record,declaration())
