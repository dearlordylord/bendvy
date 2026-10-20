import Base
import ../../../../../../../src/ecs/ordinary-query-builder.bend as Builder
import motion.bend as F
import types.bend as T
import payload.bend as P
import ../../../../../../../src/ecs/ordinary-query-observable.bend as O
import ../../../../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../../../src/ecs/inspector.bend as I
import ../../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../../src/ecs/compose.bend as Q
import ../../../../../../../src/ecs/capabilities.bend as Cap

def Frame() -> Type:Q.Frame<T.MotionSchema,F.Store(),F.Resources(),Nat>
def InspectFrame() -> Type:I.Frame<T.MotionSchema,F.Store(),F.Resources(),Nat>
def Ops(H:Type) -> Type:Cap.Read<H,T.PositionView> & (Cap.Read<H,T.VelocityView> & Cap.Read<H,T.Selected>)
def Value() -> Data:Projection.Product<Cmp.Access<T.PositionView>,Projection.Product<Cmp.Access<T.VelocityView>,Cmp.Access<T.Selected>>>
def main() -> Builder.Builder<T.MotionSchema,F.Store(),F.Resources(),Nat,Frame(),Cap.Read<Frame(),T.PositionView>,Cmp.Access<T.PositionView>>:
  Builder.read(~T.MotionSchema,~F.Store(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,~F.Resources(),~Nat,~Binding.bind(~T.MotionSchema,~F.Store(),~F.Rest(),~T.Position,~T.PositionView,~T.PositionToken,~F.take_main,~F.put_main,~P.position_get,F.main_identity()))
def aux() -> Builder.Builder<T.MotionSchema,F.Store(),F.Resources(),Nat,Frame(),Cap.Read<Frame(),T.VelocityView>,Cmp.Access<T.VelocityView>>:
  Builder.optional(~T.MotionSchema,~F.Store(),~F.AuxRest(),~T.Velocity,~T.VelocityView,~T.VelocityToken,~F.take_aux,~F.put_aux,~P.velocity_get,~F.Resources(),~Nat,~Binding.bind(~T.MotionSchema,~F.Store(),~F.AuxRest(),~T.Velocity,~T.VelocityView,~T.VelocityToken,~F.take_aux,~F.put_aux,~P.velocity_get,F.aux_identity()))
def flag() -> Builder.Builder<T.MotionSchema,F.Store(),F.Resources(),Nat,Frame(),Cap.Read<Frame(),T.Selected>,Cmp.Access<T.Selected>>:
  Builder.optional(~T.MotionSchema,~F.Store(),~F.FlagRest(),~T.Selected,~T.Selected,~T.Selected,~F.take_flag,~F.put_flag,~F.flag_view,~F.Resources(),~Nat,~Binding.bind(~T.MotionSchema,~F.Store(),~F.FlagRest(),~T.Selected,~T.Selected,~T.Selected,~F.take_flag,~F.put_flag,~F.flag_view,F.flag_identity()))
def tail() -> Builder.Builder<T.MotionSchema,F.Store(),F.Resources(),Nat,Frame(),Cap.Read<Frame(),T.VelocityView> & Cap.Read<Frame(),T.Selected>,Projection.Product<Cmp.Access<T.VelocityView>,Cmp.Access<T.Selected>>>:
  Builder.pair(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Frame(),~Cap.Read<Frame(),T.VelocityView>,~Cap.Read<Frame(),T.Selected>,~Cmp.Access<T.VelocityView>,~Cmp.Access<T.Selected>,~aux(),~flag())
def builder() -> Builder.Builder<T.MotionSchema,F.Store(),F.Resources(),Nat,Frame(),Ops(Frame()),Value()>:
  Builder.pair(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Frame(),~Cap.Read<Frame(),T.PositionView>,~(Cap.Read<Frame(),T.VelocityView> & Cap.Read<Frame(),T.Selected>),~Cmp.Access<T.PositionView>,~Projection.Product<Cmp.Access<T.VelocityView>,Cmp.Access<T.Selected>>,~main(),~tail())
def declaration() -> O.Declaration<T.MotionSchema,Frame(),Ops(Frame()),InspectFrame(),Value()>:
  Builder.finish(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Frame(),~Ops(Frame()),~Value(),~builder())
def Rows() -> Data:List<&2,IQ.ProjectedRow<T.MotionSchema,Value()>>
def unpack(observed:InspectFrame() & Rows()) -> F.World() & Rows():
  match observed:
    case (I.Frame{world,_},rows):(world,rows)
def rows(world:F.World()) -> F.World() & Rows():unpack(IQ.each_composed(~InspectFrame(),~T.MotionSchema,~Value(),~O.inspect_query(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Frame(),~Ops(Frame()),~Value(),~declaration()),I.Frame{world,None{}}))
