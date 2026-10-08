import Base
import fixture-driver.bend as Driver
import fixture-phase.bend as Phase
import fixture-phase-format.bend as F
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/relation-commands.bend as A
import fixture-schema.bend as D

def instance_cursor(~S:Data,instance:I.Instance<S>) -> I.Instance<S> & U32:
  match instance:
    case I.Fresh{}:(I.Fresh{},0)
    case I.Active{+cursor,registeredAt}:(I.Active{cursor,registeredAt},cursor)
def phases(~S:Data,values:List<&2,Phase.Phase<S>>,name:String,worldClock:U32,inspectorCursor:U32,errors:String) -> String:
  match values:
    case [+initial,+queued,+barrier]:"{\"schema\":\"" ++ name ++ "\",\"phases\":[" ++ F.phase(~S,"initial",initial) ++ "," ++ F.phase(~S,"queued",queued) ++ "," ++ F.phase(~S,"barrier",barrier) ++ "],\"finalInspectorCursor\":" ++ U32.show(inspectorCursor) ++ ",\"finalWorldClock\":" ++ U32.show(worldClock) ++ ",\"errors\":\"" ++ errors ++ "\",\"retainedInitialInverse\":" ++ F.inverse(~S,2,initial) ++ ",\"currentInverse2\":" ++ F.inverse(~S,2,barrier) ++ ",\"currentInverse4\":" ++ F.inverse(~S,4,barrier) ++ "}"
    case _:"{\"error\":\"IncompletePhases\"}"
def clocked(~S:Data,name:String,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,instance:I.Instance<S>,+values:List<&2,Phase.Phase<S>>,+errors:String,inspectorCursor:U32,observed:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & U32) -> Driver.Delivery<S> & String:
  (world,worldClock)=observed
  (Driver.Delivered{factory,world,foreign,instance,values,errors},phases(~S,values,name,worldClock,inspectorCursor,errors))
def cursored(~S:Data,name:String,factory:W.Factory,foreign:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,world:W.World<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,values:List<&2,Phase.Phase<S>>,errors:String,observed:I.Instance<S> & U32) -> Driver.Delivery<S> & String:
  (instance,cursor)=observed
  clocked(~S,name,factory,foreign,instance,values,errors,cursor,W.clock(~S,~A.Store<S,D.Components<S>>,~D.Resources,~A.Notice<S,D.FixtureEvent>,world))
def render(~S:Data,name:String,delivery:Driver.Delivery<S>) -> Driver.Delivery<S> & String:
  match delivery:
    case Driver.Delivered{factory,world,foreign,instance,values,errors}:cursored(~S,name,factory,foreign,world,values,errors,instance_cursor(~S,instance))
    case Driver.SetupRefused{setup}:(Driver.SetupRefused{setup},"{\"error\":\"SetupRefused\"}")
def workshop() -> Driver.Delivery<D.Workshop> & String:
  render(~D.Workshop,"Workshop",Driver.workshop())
def garden() -> Driver.Delivery<D.Garden> & String:
  render(~D.Garden,"Garden",Driver.garden())
# Fixture final boundary disposes owners only after every detached phase is read.
def last(result:Driver.Delivery<D.Garden> & String,first:String) -> String:
  (_,second)=result
  "{\"schemas\":[" ++ first ++ "," ++ second ++ "],\"scope\":\"finite relation Inspector development fixture; no full55 qualification\"}"
def first(result:Driver.Delivery<D.Workshop> & String) -> String:
  (_,value)=result
  last(garden(),value)
def output() -> String:
  first(workshop())
