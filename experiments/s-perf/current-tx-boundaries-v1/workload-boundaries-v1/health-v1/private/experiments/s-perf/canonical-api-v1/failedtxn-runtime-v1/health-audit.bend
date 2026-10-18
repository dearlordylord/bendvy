import Base
import ../dense-runtime-v1/types.bend as T
import health-resources.bend as R
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-service-request.bend as Request

def identity() -> Request.Identity<T.HealthSchema,String,Unit>:Request.Identity{1,"Audit"}
def Declaration() -> Type:Request.Declaration<T.HealthSchema,R.Resources(),R.Audit,T.HealthLedger,String,Unit,identity(),R.take_audit,R.put_audit,R.record>
def declaration() -> Declaration():
  Request.declare(~T.HealthSchema,~R.Resources(),~R.Audit,~T.HealthLedger,~String,~Unit,~identity(),~R.take_audit,~R.put_audit,~R.record)
def Grant(~H:Type) -> Type:Request.Grant<T.HealthSchema,String,Unit,identity(),H>
def key() -> String:Request.declaration_key(~T.HealthSchema,~R.Resources(),~R.Audit,~T.HealthLedger,~String,~Unit,~identity(),~R.take_audit,~R.put_audit,~R.record,declaration())
