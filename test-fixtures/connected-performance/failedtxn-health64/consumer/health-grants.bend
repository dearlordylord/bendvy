import Base
import health-events.bend as E
import health-callbacks.bend as Callback
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/commands.bend as Cmd
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/payload.bend as P
import health.bend as F
import health-resources.bend as R
import health-audit.bend as Audit
import ../../../../src/ecs/ordinary-service-request.bend as Request
import ../../../../src/ecs/ordinary-service-declaration.bend as Service
import ../../../../src/ecs/schedule-provision.bend as Provision
import ../../../../src/ecs/resource-field.bend as Field
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/capabilities.bend as Cap

def Owner() -> Type:Tx.Tx<F.World(),E.event_type()>
def ledger() -> Cap.ValueWrite<Owner(),T.HealthLedger,T.LedgerView>:
  Field.write(~T.HealthSchema,~F.Store(),~R.Resources(),~E.event_type(),~T.HealthLedger,~Service.Slot<R.Audit>,~T.LedgerView,~R.ledger_lens(),~P.health_ledger_get)
def audit() -> Audit.Grant(~Owner()):
  Request.grant(~F.Store(),~E.event_type(),~T.HealthSchema,~R.Resources(),~R.Audit,~T.HealthLedger,~String,~Unit,~Audit.identity(),~R.take_audit,~R.put_audit,~R.record,~Audit.declaration())
def required() -> Provision.Requirement<T.HealthSchema>:
  Request.declaration_requirement(~T.HealthSchema,~R.Resources(),~R.Audit,~T.HealthLedger,~String,~Unit,~Audit.identity(),~R.take_audit,~R.put_audit,~R.record,Audit.declaration())
def scan(world:F.World()) -> F.World() & List<&2,Service.Status<T.HealthSchema>>:
  Request.world_observed(~F.Store(),~E.event_type(),~T.HealthSchema,~R.Resources(),~R.Audit,~T.HealthLedger,~String,~Unit,~Audit.identity(),~R.take_audit,~R.put_audit,~R.record,~Audit.declaration(),world)
def setup() -> Service.Setup<T.HealthSchema,F.Store(),R.Resources(),E.event_type(),Request.world_observed(~F.Store(),~E.event_type(),~T.HealthSchema,~R.Resources(),~R.Audit,~T.HealthLedger,~String,~Unit,~Audit.identity(),~R.take_audit,~R.put_audit,~R.record,~Audit.declaration())>:
  Request.setup(~F.Store(),~E.event_type(),~T.HealthSchema,~R.Resources(),~R.Audit,~T.HealthLedger,~String,~Unit,~Audit.identity(),~R.take_audit,~R.put_audit,~R.record,~Audit.declaration())

def main_read(owner:Owner(),target:W.Handle<T.HealthSchema>) -> Owner() & Cmp.Access<T.VitalsView>:
  Cmp.tx_get(~T.HealthSchema,~F.Store(),~R.Resources(),~E.event_type(),~F.Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~F.take_main,~F.put_main,~P.vitals_get,F.main_family(),owner,target)
def main_write(owner:Owner(),target:W.Handle<T.HealthSchema>,payload:T.Vitals) -> Cmp.SetResult<Owner(),T.Vitals>:
  Cmp.tx_set(~T.HealthSchema,~F.Store(),~R.Resources(),~E.event_type(),~F.Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~F.take_main,~F.put_main,~P.vitals_get,F.main_family(),owner,target,payload)
def populate(world:F.World(),target:W.Handle<T.HealthSchema>,payload:T.Vitals) -> F.World():F.populate(world,target,F.Payload{payload,None{},None{}})
def spawn(owner:Owner(),payload:T.Vitals) -> Owner() & W.Reservation<T.HealthSchema>:
  Cmd.tx_spawn(~T.HealthSchema,~F.Store(),~R.Resources(),~E.event_type(),~T.Vitals,~populate,owner,payload)
def ops() -> Callback.Ops<Owner(),E.event_type()>:
  Callback.Ops{(main_read,main_write),ledger(),Cap.Request{spawn},Cap.Send{Tx.emit(~F.World(),~E.event_type())},audit()}
