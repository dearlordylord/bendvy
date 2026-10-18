import Base
import events.bend as E
import motion.bend as F
import ../../../../dense-runtime-v1/types.bend as T
import ../../../../dense-runtime-v1/payload.bend as P
import ../../../../../../../src/ecs/ordinary-query-observable.bend as O
import ../../../../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../../../src/ecs/inspector.bend as I
import ../../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../../src/ecs/compose.bend as Q
import ../../../../../../../src/ecs/capabilities.bend as Cap

def Frame() -> Type:Q.Frame<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>
def InspectFrame() -> Type:I.Frame<T.MotionSchema,F.Store(),F.Resources(),E.event_type()>
def Ops(H:Type) -> Type:Cap.Read<H,T.PositionView> & (Cap.Read<H,T.VelocityView> & Cap.Read<H,T.Selected>)
def Value() -> Data:Projection.Product<Cmp.Access<T.PositionView>,Projection.Product<Cmp.Access<T.VelocityView>,Cmp.Access<T.Selected>>>
def main() -> O.Declaration<T.MotionSchema,Frame(),Cap.Read<Frame(),T.PositionView>,InspectFrame(),Cmp.Access<T.PositionView>>:
  O.read(~T.MotionSchema,~F.Store(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,~F.Resources(),~E.event_type(),~Binding.bind(~T.MotionSchema,~F.Store(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_identity()))
def aux() -> O.Declaration<T.MotionSchema,Frame(),Cap.Read<Frame(),T.VelocityView>,InspectFrame(),Cmp.Access<T.VelocityView>>:
  O.optional(~T.MotionSchema,~F.Store(),~F.AuxRest(),~T.Velocity,~T.VelocityView,~T.VelocityToken,~F.take_aux,~F.put_aux,~P.velocity_get,~F.Resources(),~E.event_type(),~Binding.bind(~T.MotionSchema,~F.Store(),~F.AuxRest(),~T.Velocity,~T.VelocityView,~T.VelocityToken,~F.take_aux,~F.put_aux,~P.velocity_get,F.aux_identity()))
def flag() -> O.Declaration<T.MotionSchema,Frame(),Cap.Read<Frame(),T.Selected>,InspectFrame(),Cmp.Access<T.Selected>>:
  O.optional(~T.MotionSchema,~F.Store(),~F.FlagRest(),~T.Selected,~T.Selected,~T.Selected,~F.take_flag,~F.put_flag,~F.flag_view,~F.Resources(),~E.event_type(),~Binding.bind(~T.MotionSchema,~F.Store(),~F.FlagRest(),~T.Selected,~T.Selected,~T.Selected,~F.take_flag,~F.put_flag,~F.flag_view,F.flag_identity()))
def tail() -> O.Declaration<T.MotionSchema,Frame(),Cap.Read<Frame(),T.VelocityView> & Cap.Read<Frame(),T.Selected>,InspectFrame(),Projection.Product<Cmp.Access<T.VelocityView>,Cmp.Access<T.Selected>>>:
  O.pair(~T.MotionSchema,~Frame(),~Cap.Read<Frame(),T.VelocityView>,~Cap.Read<Frame(),T.Selected>,~InspectFrame(),~Cmp.Access<T.VelocityView>,~Cmp.Access<T.Selected>,~aux(),~flag())
def declaration() -> O.Declaration<T.MotionSchema,Frame(),Ops(Frame()),InspectFrame(),Value()>:
  O.pair(~T.MotionSchema,~Frame(),~Cap.Read<Frame(),T.PositionView>,~(Cap.Read<Frame(),T.VelocityView> & Cap.Read<Frame(),T.Selected>),~InspectFrame(),~Cmp.Access<T.PositionView>,~Projection.Product<Cmp.Access<T.VelocityView>,Cmp.Access<T.Selected>>,~main(),~tail())
def Rows() -> Data:List<&2,IQ.ProjectedRow<T.MotionSchema,Value()>>
def unpack(observed:InspectFrame() & Rows()) -> F.World() & Rows():
  match observed:
    case (I.Frame{world,_},rows):(world,rows)
def rows(world:F.World()) -> F.World() & Rows():unpack(IQ.each_composed(~InspectFrame(),~T.MotionSchema,~Value(),~O.inspect_query(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~Frame(),~Ops(Frame()),~Value(),~declaration()),I.Frame{world,0}))

def main_binding() -> Binding.Binding<T.MotionSchema,F.Store(),F.Rest(),T.Position,T.PositionView,T.PositionToken,F.take_main,F.put_main,P.position_get>:
  Binding.bind(~T.MotionSchema,~F.Store(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_identity())
def added_filter() -> O.Declaration<T.MotionSchema,Frame(),Unit,InspectFrame(),Unit>:
  O.added(~T.MotionSchema,~F.Store(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,~F.Resources(),~E.event_type(),~main_binding())
def changed_filter() -> O.Declaration<T.MotionSchema,Frame(),Unit,InspectFrame(),Unit>:
  O.changed(~T.MotionSchema,~F.Store(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,~F.Resources(),~E.event_type(),~main_binding())
def added() -> O.Declaration<T.MotionSchema,Frame(),Unit & Ops(Frame()),InspectFrame(),Projection.Product<Unit,Value()>>:
  O.pair(~T.MotionSchema,~Frame(),~Unit,~Ops(Frame()),~InspectFrame(),~Unit,~Value(),~added_filter(),~declaration())
def changed() -> O.Declaration<T.MotionSchema,Frame(),Unit & Ops(Frame()),InspectFrame(),Projection.Product<Unit,Value()>>:
  O.pair(~T.MotionSchema,~Frame(),~Unit,~Ops(Frame()),~InspectFrame(),~Unit,~Value(),~changed_filter(),~declaration())
