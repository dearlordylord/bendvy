import Base
import events.bend as E
import motion-callbacks.bend as Callback
import /tmp/bendvy-failedtxn-matched-method/src/ecs/world.bend as W
import /tmp/bendvy-failedtxn-matched-method/src/ecs/component.bend as Cmp
import /tmp/bendvy-failedtxn-matched-method/src/ecs/commands.bend as Cmd
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/payload.bend as P
import motion.bend as F
import motion-resources.bend as R
import motion-audit.bend as Audit
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-service-request.bend as Request
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-service-declaration.bend as Service
import /tmp/bendvy-failedtxn-matched-method/src/ecs/schedule-provision.bend as Provision
import /tmp/bendvy-failedtxn-matched-method/src/ecs/resource-field.bend as Field
import /tmp/bendvy-failedtxn-matched-method/src/ecs/transaction.bend as Tx
import /tmp/bendvy-failedtxn-matched-method/src/ecs/capabilities.bend as Cap

def Owner() -> Type:Tx.Tx<F.World(),E.event_type()>
def ledger() -> Cap.ValueWrite<Owner(),T.MotionLedger,T.LedgerView>:
  Field.write(~T.MotionSchema,~F.Store(),~R.Resources(),~E.event_type(),~T.MotionLedger,~Service.Slot<R.Audit>,~T.LedgerView,~R.ledger_lens(),~P.motion_ledger_get)
def audit() -> Audit.Grant(~Owner()):
  Request.grant(~F.Store(),~E.event_type(),~T.MotionSchema,~R.Resources(),~R.Audit,~T.MotionLedger,~String,~Unit,~Audit.identity(),~R.take_audit,~R.put_audit,~R.record,~Audit.declaration())
def required() -> Provision.Requirement<T.MotionSchema>:
  Request.declaration_requirement(~T.MotionSchema,~R.Resources(),~R.Audit,~T.MotionLedger,~String,~Unit,~Audit.identity(),~R.take_audit,~R.put_audit,~R.record,Audit.declaration())
def scan(world:F.World()) -> F.World() & List<&2,Service.Status<T.MotionSchema>>:
  Request.world_observed(~F.Store(),~E.event_type(),~T.MotionSchema,~R.Resources(),~R.Audit,~T.MotionLedger,~String,~Unit,~Audit.identity(),~R.take_audit,~R.put_audit,~R.record,~Audit.declaration(),world)
def setup() -> Service.Setup<T.MotionSchema,F.Store(),R.Resources(),E.event_type(),Request.world_observed(~F.Store(),~E.event_type(),~T.MotionSchema,~R.Resources(),~R.Audit,~T.MotionLedger,~String,~Unit,~Audit.identity(),~R.take_audit,~R.put_audit,~R.record,~Audit.declaration())>:
  Request.setup(~F.Store(),~E.event_type(),~T.MotionSchema,~R.Resources(),~R.Audit,~T.MotionLedger,~String,~Unit,~Audit.identity(),~R.take_audit,~R.put_audit,~R.record,~Audit.declaration())

def main_read(owner:Owner(),target:W.Handle<T.MotionSchema>) -> Owner() & Cmp.Access<T.PositionView>:
  Cmp.tx_get(~T.MotionSchema,~F.Store(),~R.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_family(),owner,target)
def main_write(owner:Owner(),target:W.Handle<T.MotionSchema>,payload:T.Position) -> Cmp.SetResult<Owner(),T.Position>:
  Cmp.tx_set(~T.MotionSchema,~F.Store(),~R.Resources(),~E.event_type(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_family(),owner,target,payload)
def populate(world:F.World(),target:W.Handle<T.MotionSchema>,payload:T.Position) -> F.World():F.populate(world,target,F.Payload{payload,None{},None{}})
def spawn(owner:Owner(),payload:T.Position) -> Owner() & W.Reservation<T.MotionSchema>:
  Cmd.tx_spawn(~T.MotionSchema,~F.Store(),~R.Resources(),~E.event_type(),~T.Position,~populate,owner,payload)
def ops() -> Callback.Ops<Owner(),E.event_type()>:
  Callback.Ops{(main_read,main_write),ledger(),Cap.Request{spawn},Cap.Send{Tx.emit(~F.World(),~E.event_type())},audit()}
