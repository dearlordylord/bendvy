import Base
import ../../../src/ecs/entity-key.bend as Key
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/event-stream.bend as Stream
import ./spec.bend as Spec

# PROPOSED / UNAPPROVED. These are pure Data helper equations, not World proofs.
law full_key_equality:
  for +left:Key.Key
  for +right:Key.Key
  {Key.equal(left,right) == Spec.key_equal(left,right) : Bool}
law selected_completion_positions:
  for +success:Bool
  for +values:List<&2,Ev.Position>
  for +id:U32
  for +tick:Nat
  {Stream.completed_positions(success,values,id,tick) == Spec.positions(success,values,id,tick) : List<&2,Ev.Position>}
law stream_completion_fields:
  for S:Data
  for E:Data
  for +value:Stream.Stream<S,E>
  for +id:U32
  for +tick:Nat
  for +success:Bool
  {Stream.completed(~S,~E,value,id,tick,success) == Spec.completed(~S,~E,value,id,tick,success) : Stream.Stream<S,E>}
law stream_explicit_advance:
  for S:Data
  for E:Data
  for +value:Stream.Stream<S,E>
  for +id:U32
  for +tick:Nat
  {Stream.advance(~S,~E,value,id,tick) == Spec.advanced(~S,~E,value,id,tick) : Stream.Stream<S,E>}
