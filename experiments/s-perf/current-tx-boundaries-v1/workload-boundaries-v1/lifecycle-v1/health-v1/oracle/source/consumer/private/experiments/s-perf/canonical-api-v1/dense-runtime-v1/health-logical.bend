import Base
import health.bend as F
import types.bend as T
import payload.bend as P
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-query-observable.bend as O
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-component-binding.bend as Binding
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/inspector-query-projection.bend as Projection
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/inspector-query.bend as IQ
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/inspector.bend as I
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/component.bend as Cmp
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/compose.bend as Q
import ../../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/capabilities.bend as Cap

def Frame() -> Type:Q.Frame<T.HealthSchema,F.Store(),F.Resources(),Nat>
def InspectFrame() -> Type:I.Frame<T.HealthSchema,F.Store(),F.Resources(),Nat>
def Ops(H:Type) -> Type:Cap.Read<H,T.VitalsView> & (Cap.Read<H,T.ArmorView> & Cap.Read<H,T.Tracked>)
def Value() -> Data:Projection.Product<Cmp.Access<T.VitalsView>,Projection.Product<Cmp.Access<T.ArmorView>,Cmp.Access<T.Tracked>>>
def main() -> O.Declaration<T.HealthSchema,Frame(),Cap.Read<Frame(),T.VitalsView>,InspectFrame(),Cmp.Access<T.VitalsView>>:
  O.read(~T.HealthSchema,~F.Store(),~F.Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~F.take_main,~F.put_main,~P.vitals_get,~F.Resources(),~Nat,~Binding.bind(~T.HealthSchema,~F.Store(),~F.Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~F.take_main,~F.put_main,~P.vitals_get,F.main_identity()))
def aux() -> O.Declaration<T.HealthSchema,Frame(),Cap.Read<Frame(),T.ArmorView>,InspectFrame(),Cmp.Access<T.ArmorView>>:
  O.optional(~T.HealthSchema,~F.Store(),~F.AuxRest(),~T.Armor,~T.ArmorView,~T.ArmorToken,~F.take_aux,~F.put_aux,~P.armor_get,~F.Resources(),~Nat,~Binding.bind(~T.HealthSchema,~F.Store(),~F.AuxRest(),~T.Armor,~T.ArmorView,~T.ArmorToken,~F.take_aux,~F.put_aux,~P.armor_get,F.aux_identity()))
def flag() -> O.Declaration<T.HealthSchema,Frame(),Cap.Read<Frame(),T.Tracked>,InspectFrame(),Cmp.Access<T.Tracked>>:
  O.optional(~T.HealthSchema,~F.Store(),~F.FlagRest(),~T.Tracked,~T.Tracked,~T.Tracked,~F.take_flag,~F.put_flag,~F.flag_view,~F.Resources(),~Nat,~Binding.bind(~T.HealthSchema,~F.Store(),~F.FlagRest(),~T.Tracked,~T.Tracked,~T.Tracked,~F.take_flag,~F.put_flag,~F.flag_view,F.flag_identity()))
def tail() -> O.Declaration<T.HealthSchema,Frame(),Cap.Read<Frame(),T.ArmorView> & Cap.Read<Frame(),T.Tracked>,InspectFrame(),Projection.Product<Cmp.Access<T.ArmorView>,Cmp.Access<T.Tracked>>>:
  O.pair(~T.HealthSchema,~Frame(),~Cap.Read<Frame(),T.ArmorView>,~Cap.Read<Frame(),T.Tracked>,~InspectFrame(),~Cmp.Access<T.ArmorView>,~Cmp.Access<T.Tracked>,~aux(),~flag())
def declaration() -> O.Declaration<T.HealthSchema,Frame(),Ops(Frame()),InspectFrame(),Value()>:
  O.pair(~T.HealthSchema,~Frame(),~Cap.Read<Frame(),T.VitalsView>,~(Cap.Read<Frame(),T.ArmorView> & Cap.Read<Frame(),T.Tracked>),~InspectFrame(),~Cmp.Access<T.VitalsView>,~Projection.Product<Cmp.Access<T.ArmorView>,Cmp.Access<T.Tracked>>,~main(),~tail())
def Rows() -> Data:List<&2,IQ.ProjectedRow<T.HealthSchema,Value()>>
def unpack(observed:InspectFrame() & Rows()) -> F.World() & Rows():
  match observed:
    case (I.Frame{world,_},rows):(world,rows)
def rows(world:F.World()) -> F.World() & Rows():unpack(IQ.each_composed(~InspectFrame(),~T.HealthSchema,~Value(),~O.inspect_query(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Frame(),~Ops(Frame()),~Value(),~declaration()),I.Frame{world,0}))
