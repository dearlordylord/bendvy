import Base
import fixture-state.bend as State
import fixture-consumer.bend as Consumer
import fixture-dump.bend as Dump
import root-source/world.bend as W

# Separate direct-adapter observation, not instrumentation of Sch.run callback.
# Whole owner-preserving text snapshots remain detached Data after the read.
type Boundary is Data:
  Boundary{condition:U32,allowed:Bool,before:String,after:String}
def after(~S:Data,id:U32,before:String,allowed:Bool,observed:W.World<S,State.Store<S>,State.Resources<S>,U32> & String) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Boundary:
  (world,text)=observed
  (world,Boundary{id,allowed,before,text})
def checked(~S:Data,id:U32,before:String,observed:W.World<S,State.Store<S>,State.Resources<S>,U32> & Bool) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Boundary:
  (world,allowed)=observed
  after(~S,id,before,allowed,Dump.world(~S,world))
def before(~S:Data,+id:U32,observed:W.World<S,State.Store<S>,State.Resources<S>,U32> & String) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Boundary:
  (world,text)=observed
  checked(~S,id,text,Consumer.raw_condition(~S,world,id))
def observe(~S:Data,world:W.World<S,State.Store<S>,State.Resources<S>,U32>,id:U32) -> W.World<S,State.Store<S>,State.Resources<S>,U32> & Boundary:
  before(~S,id,Dump.world(~S,world))
