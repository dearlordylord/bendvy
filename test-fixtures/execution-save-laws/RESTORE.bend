import Base
import ../../src/ecs/execution-restore-receiver.bend as Receiver
import ../../src/ecs/execution-restore-publication.bend as Publish
import ../../src/ecs/execution-restore-clear.bend as Clear
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

# DRAFT, UNAPPROVED, UNPROVED. These are exact actual-owner helper equations;
# they do not establish complete restore, fresh-allocation or lifecycle laws.
law receiver_pending_keeps_actual_world:
  for -S:Data
  for -layout:Layout.Layout
  for -R:Type
  for -E:Data
  for -needed:Nat
  for -world:W.World<S,Layout.columns(~S,layout),R,E>
  {Receiver.ready(~S,~layout,~R,~E,needed,(world,False{})) == Receiver.Refused{world,Receiver.PendingWork{}} : Receiver.Prepared<S,layout,R,E>}

law publish_empty_keeps_actual_world:
  for -S:Data
  for -layout:Layout.Layout
  for -R:Type
  for -E:Data
  for -world:W.World<S,Layout.columns(~S,layout),R,E>
  for -tick:Tick.Tick
  {Publish.publish(~S,~layout,~R,~E,[],world,tick) == Publish.Published{world,[],[],True{}} : Publish.Published<S,layout,R,E>}

law clear_empty_keeps_actual_world:
  for -S:Data
  for -layout:Layout.Layout
  for -route:Layout.Route
  for -R:Type
  for -E:Data
  for -world:W.World<S,Layout.columns(~S,layout),R,E>
  for -tick:Tick.Tick
  {Clear.clear(~S,~layout,~route,~R,~E,[],world,tick) == Clear.Cleared{world,[]} : Clear.Cleared<S,layout,route,R,E>}
