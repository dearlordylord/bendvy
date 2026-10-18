import Base
import metric-owner.bend as MO
import tx-metrics.bend as Metrics
import health-codec-values.bend as V
import ../../../../dense-runtime-v1/health.bend as F
import ../../../../dense-runtime-v1/health-logical.bend as Logical
import ../../../../dense-runtime-v1/health-observe.bend as O
import ../../../../dense-runtime-v1/payload.bend as P
import ../../../../dense-runtime-v1/types.bend as Types
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../src/ecs/commands.bend as Cmd
import ../../../../../../../src/ecs/structural.bend as Structural
import ../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../src/ecs/component.bend as Component
import ../../../../../../../src/ecs/compose.bend as Q
import ../../../../../../../src/ecs/query-contract.bend as Contract
import ../../../../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../../../src/ecs/ordinary-query-observable.bend as Observable
import ../../../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../../../../src/ecs/inspector.bend as Inspect
import ../../../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../../../src/ecs/entity-key.bend as Key
import ../../../../../../../src/ecs/owner-product.bend as Product
import ../../../../../../../src/ecs/local.bend as Local

type Operation is Data:
  Select{}
  Reserve{}
  Dispose{}
  Observe{}
type Frame is Data:
  Frame{count:U32,iteration:U32,phase:U32,target:Maybe<&2,W.Handle<Types.HealthSchema>>,pending:Maybe<&2,W.Handle<Types.HealthSchema>>,foreign:W.Handle<Types.HealthSchema>,stale:List<&2,W.Handle<Types.HealthSchema>>,reservations:List<&2,W.Reservation<Types.HealthSchema>>}
type Seen is Data:
  Seen{handle:W.Handle<Types.HealthSchema>,kind:U32}
type Boundary is Data:
  Boundary{frame:Frame,rows:Logical.Rows(),ledger:Types.LedgerView,lookups:Types.Four,stale:List<&2,Seen>,before:V.World,after:V.World}
type Output is Data:
  Output{frame:Frame,boundary:Maybe<&2,Boundary>}
def World() -> Type:F.World()
def Store() -> Type:F.Store()
def Resources() -> Type:F.Resources()
def main_key() -> String:Identity.key(~Types.HealthSchema,~Types.Vitals,F.main_identity())
def access(kind:Operation) -> List<&2,String>:
  match kind:
    case Select{}:[main_key()]
    case Reserve{}:["command:spawn"]
    case Dispose{}:[main_key(),"command:remove","command:despawn"]
    case Observe{}:[main_key(),Identity.key(~Types.HealthSchema,~Types.Armor,F.aux_identity()),Identity.key(~Types.HealthSchema,~Types.Tracked,F.flag_identity()),Schema.resource_key(~Types.HealthSchema,~Types.HealthLedger,F.ledger_identity())]
def bump(owner:MO.Owner) -> MO.Owner:MO.bump(owner)
def ReadOps(H:Type) -> Type:Cap.Read<H,Types.VitalsView>
def main_read() -> Decl.Declaration<Types.HealthSchema,Q.Frame<Types.HealthSchema,Store(),Resources(),Nat>,Cap.Read<Q.Frame<Types.HealthSchema,Store(),Resources(),Nat>,Types.VitalsView>>:
  Decl.read(~Types.HealthSchema,~Types.Vitals,~Store(),~Resources(),~Nat,~F.Rest(),~Types.VitalsView,~Types.VitalsToken,~F.main_identity(),~P.vitals_get,~F.take_main,~F.put_main)
def select_plan() -> Q.Plan<Types.HealthSchema,Store(),Resources(),Nat,ReadOps>:
  Q.Plan{Decl.grant(~Types.HealthSchema,~Q.Frame<Types.HealthSchema,Store(),Resources(),Nat>,~ReadOps(Q.Frame<Types.HealthSchema,Store(),Resources(),Nat>),main_read()),Decl.selector(~Types.HealthSchema,~Q.Frame<Types.HealthSchema,Store(),Resources(),Nat>,~ReadOps(Q.Frame<Types.HealthSchema,Store(),Resources(),Nat>),main_read())}
def index(kind:U32,count:U32) -> U32:
  match kind:
    case 0:0
    case 1:U32.div(count,2)
    case _:U32.sub(count,1)
def nth(handles:List<&2,W.Handle<Types.HealthSchema>>,index:U32) -> Maybe<&2,W.Handle<Types.HealthSchema>>:
  match handles index:
    case [] _:None{}
    case handle <> _ 0:Some{handle}
    case _ <> rest index:nth(rest,U32.sub(index,1))
def selected(owner:MO.Owner,frame:Frame,observed:Contract.Scanned<Types.HealthSchema,Store(),Resources(),Nat>) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  match frame observed:
    case Frame{+count,+iteration,phase,_,pending,foreign,stale,reservations}, Contract.Scanned{world,handles}:Local.Succeeded{world,owner,Output{Frame{count,iteration,phase,nth(handles,index(U32.mod(iteration,3),count)),pending,foreign,stale,reservations},None{}}}
def select(world:World(),owner:MO.Owner,frame:Frame) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  selected(owner,frame,Contract.scan(~Types.HealthSchema,~Store(),~Resources(),~Nat,~ReadOps,~select_plan(),world,0))
def populate(world:World(),handle:W.Handle<Types.HealthSchema>,main:Types.Vitals) -> World():F.populate(world,handle,F.Payload{main,None{},None{}})
def reserved_finished(owner:MO.Owner,frame:Frame,+reservation:W.Reservation<Types.HealthSchema>,result:Tx.Returned<World(),Unit>) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  match frame reservation result:
    case Frame{count,iteration,phase,target,_,foreign,stale,reservations} W.Reserved{+handle} Tx.Returned{world,Tx.Success{}}:Local.Succeeded{world,owner,Output{Frame{count,iteration,phase,target,Some{handle},foreign,stale,List.append(&2,W.Reservation<Types.HealthSchema>,reservations,[W.Reserved{handle}])},None{}}}
    case frame _ Tx.Returned{world,_}:Local.Failed{world,owner,Unit{}}
def reserved_observed(owner:MO.Owner,frame:Frame,reservation:W.Reservation<Types.HealthSchema>,observed:Tx.Tx<World(),Nat> & Metrics.Sample) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  match observed:
    case (tx,sample):reserved_finished(MO.add(owner,sample),frame,reservation,Cmd.tx_finish(~Types.HealthSchema,~Store(),~Resources(),~Nat,~Unit,tx,Tx.Success{}))
def reserved(owner:MO.Owner,frame:Frame,observed:Tx.Tx<World(),Nat> & W.Reservation<Types.HealthSchema>) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  match observed:
    case (tx,reservation):reserved_observed(owner,frame,reservation,Metrics.observe(~World(),~Nat,"reserve",tx))
def reserve(world:World(),owner:MO.Owner,frame:Frame) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  match frame:
    case Frame{count,+iteration,phase,target,pending,foreign,stale,reservations}:reserved(owner,Frame{count,iteration,phase,target,pending,foreign,stale,reservations},Cmd.tx_spawn(~Types.HealthSchema,~Store(),~Resources(),~Nat,~Types.Vitals,~populate,Tx.begin(~World(),~Nat,world),Types.Vitals{F.quad(iteration,U32.add(iteration,1),U32.add(iteration,2),U32.add(iteration,3)),9,2}))
def main_cleared(rest:F.Rest(),result:Col.SwapOutcome<Types.HealthSchema,Types.Vitals>) -> Store():
  match result:
    case Col.Accepted{column,_}:F.put_main(rest,column)
    case Col.Rejected{column,_}:F.put_main(rest,column)
def main_taken(handle:W.Handle<Types.HealthSchema>,observed:F.Rest() & Col.Column<Types.HealthSchema,Types.Vitals>) -> Store():
  match observed:
    case (rest,column):main_cleared(rest,Col.clear(~Types.HealthSchema,~Types.Vitals,column,W.handle_index(~Types.HealthSchema,handle)))
def clear_main(store:Store(),handle:W.Handle<Types.HealthSchema>) -> Store():main_taken(handle,F.take_main(store))

def aux_cleared(rest:F.AuxRest(),result:Col.SwapOutcome<Types.HealthSchema,Types.Armor>) -> Store():
  match result:
    case Col.Accepted{column,_}:F.put_aux(rest,column)
    case Col.Rejected{column,_}:F.put_aux(rest,column)
def aux_taken(handle:W.Handle<Types.HealthSchema>,observed:F.AuxRest() & Col.Column<Types.HealthSchema,Types.Armor>) -> Store():
  match observed:
    case (rest,column):aux_cleared(rest,Col.clear(~Types.HealthSchema,~Types.Armor,column,W.handle_index(~Types.HealthSchema,handle)))
def clear_aux(store:Store(),handle:W.Handle<Types.HealthSchema>) -> Store():aux_taken(handle,F.take_aux(store))

def flag_cleared(rest:F.FlagRest(),result:Col.SwapOutcome<Types.HealthSchema,Types.Tracked>) -> Store():
  match result:
    case Col.Accepted{column,_}:F.put_flag(rest,column)
    case Col.Rejected{column,_}:F.put_flag(rest,column)
def flag_taken(handle:W.Handle<Types.HealthSchema>,observed:F.FlagRest() & Col.Column<Types.HealthSchema,Types.Tracked>) -> Store():
  match observed:
    case (rest,column):flag_cleared(rest,Col.clear(~Types.HealthSchema,~Types.Tracked,column,W.handle_index(~Types.HealthSchema,handle)))
def clear_flag(store:Store(),handle:W.Handle<Types.HealthSchema>) -> Store():flag_taken(handle,F.take_flag(store))

def clear_copy(store:Store(),+handle:W.Handle<Types.HealthSchema>) -> Store():clear_flag(clear_aux(clear_main(store,handle),handle),handle)
def clear(store:Store(),handle:W.Handle<Types.HealthSchema>) -> Store():clear_copy(store,handle)
def disposed_finished(owner:MO.Owner,frame:Frame,result:Tx.Returned<World(),Unit>) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  match result:
    case Tx.Returned{world,Tx.Success{}}:Local.Succeeded{world,owner,Output{frame,None{}}}
    case Tx.Returned{world,_}:Local.Failed{world,owner,Unit{}}
def dispose_observed(owner:MO.Owner,frame:Frame,outcome:Tx.Outcome<Unit>,observed:Tx.Tx<World(),Nat> & Metrics.Sample) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  match observed:
    case (tx,sample):disposed_finished(MO.add(owner,sample),frame,Cmd.tx_finish(~Types.HealthSchema,~Store(),~Resources(),~Nat,~Unit,tx,outcome))
def finish_dispose(owner:MO.Owner,frame:Frame,outcome:Tx.Outcome<Unit>,tx:Tx.Tx<World(),Nat>) -> Local.Outcome<World(),MO.Owner,Unit,Output>:dispose_observed(owner,frame,outcome,Metrics.observe(~World(),~Nat,"dispose",tx))
def despawned(owner:MO.Owner,frame:Frame,observed:Tx.Tx<World(),Nat> & W.Status) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  match observed:
    case (tx,W.Accepted{}):finish_dispose(owner,frame,Tx.Success{},tx)
    case (tx,_):finish_dispose(owner,frame,Tx.Failure{Unit{}},tx)
def removed(owner:MO.Owner,frame:Frame,target:W.Handle<Types.HealthSchema>,result:Structural.Queued<Tx.Tx<World(),Nat>,Types.Vitals>) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  match result:
    case Structural.Queued{tx}:despawned(owner,frame,Cmd.tx_despawn_with(~Types.HealthSchema,~Store(),~Resources(),~Nat,~clear,tx,target))
    case Structural.QueueRejected{tx,_,_}:finish_dispose(owner,frame,Tx.Failure{Unit{}},tx)
def dispose(world:World(),owner:MO.Owner,frame:Frame) -> Local.Outcome<World(),MO.Owner,Unit,Output>:
  match frame:
    case Frame{count,iteration,phase,Some{+target},pending,foreign,stale,reservations}:removed(owner,Frame{count,iteration,phase,Some{target},pending,foreign,List.append(&2,W.Handle<Types.HealthSchema>,stale,[target]),reservations},target,Structural.tx_remove(~Types.HealthSchema,~Store(),~Resources(),~Nat,~F.Rest(),~Types.Vitals,~Types.VitalsView,~Types.VitalsToken,~F.take_main,~F.put_main,~P.vitals_get,F.main_family(),Tx.begin(~World(),~Nat,world),target))
    case _:Local.Failed{world,owner,Unit{}}
