import Base
import ./query.bend as Q
import ./cached-payload.bend as CP
import ./uncached-payload.bend as P
import ./storage.bend as S
import ./types.bend as T

def bad(~Owner:Type,~Aux:Type,~get:Owner -> T.PositionToken -> Owner & T.PositionView,~ag:Aux -> Aux & Maybe<&2,T.VelocityView>,handle:S.Handle<T.MotionSchema>,flag:Maybe<&2,T.Selected>,owner:Owner,aux:Aux) -> Owner & (Aux & U32):
  CP.prototype_slot_position_swap(owner,55)
def registration(world:S.World<T.MotionSchema,CP.PrototypeMotionMainSlot,T.Velocity,T.Selected,Unit,T.MotionMode>) -> S.World<T.MotionSchema,CP.PrototypeMotionMainSlot,T.Velocity,T.Selected,Unit,T.MotionMode> & List<&2,U32>:
  Q.each(T.MotionSchema,CP.PrototypeMotionMainSlot,T.Velocity,T.Selected,T.PositionToken,T.PositionView,T.VelocityView,U32,Unit,T.MotionMode,CP.prototype_slot_position_get,P.velocity_get,bad,Q.Required{},world)
