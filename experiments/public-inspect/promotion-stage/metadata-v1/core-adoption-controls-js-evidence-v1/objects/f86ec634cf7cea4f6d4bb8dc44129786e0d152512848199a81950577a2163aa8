import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/removals.bend as Rm

# Experimental publication boundary. Closed schema cleanup must use actual typed
# Column.clear operations; it returns notices only for components actually removed.
# This module never copies Store/Resource/pending closure owners.
type Notice<S:Data,F:Data> is Data:
  Notice{tick:U32,record:Rm.Record<S,F>}
def stamp(~S:Data,~F:Data,+tick:U32,records:List<&2,Rm.Record<S,F>>) -> List<&2,Notice<S,F>>:
  match records:
    case []:[]
    case record <> rest:Notice{tick,record} <> stamp(~S,~F,tick,rest)
def encode_all(~S:Data,~F:Data,~E:Data,~encode:Notice<S,F> -> E,notices:List<&2,Notice<S,F>>) -> List<&2,E>:
  match notices:
    case []:[]
    case notice <> rest:encode(notice) <> encode_all(~S,~F,~E,~encode,rest)
def published(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~encode:Notice<S,F> -> E,+tick:U32,cleaned:W.World<S,Store,R,E> & List<&2,Rm.Record<S,F>>) -> W.World<S,Store,R,E>:
  (world,records)=cleaned
  W.event_publish(~S,~Store,~R,~E,world,encode_all(~S,~F,~E,~encode,stamp(~S,~F,tick,records)))
def at_clock(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~clear:Store -> W.Handle<S> -> Store & List<&2,Rm.Record<S,F>>,~encode:Notice<S,F> -> E,+handle:W.Handle<S>,clocked:W.World<S,Store,R,E> & U32) -> W.World<S,Store,R,E>:
  (world,+tick)=clocked
  published(~S,~Store,~R,~E,~F,~encode,tick,W.with_store(~S,~Store,~R,~E,~List<&2,Rm.Record<S,F>>,store => clear(store,handle),world))
def checked(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~clear:Store -> W.Handle<S> -> Store & List<&2,Rm.Record<S,F>>,~encode:Notice<S,F> -> E,+handle:W.Handle<S>,valid:W.World<S,Store,R,E> & Bool) -> W.World<S,Store,R,E>:
  match valid:
    case (world,False{}):world
    case (world,True{}):at_clock(~S,~Store,~R,~E,~F,~clear,~encode,handle,W.clock(~S,~Store,~R,~E,world))
def remove(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~clear:Store -> W.Handle<S> -> Store & List<&2,Rm.Record<S,F>>,~encode:Notice<S,F> -> E,world:W.World<S,Store,R,E>,+handle:W.Handle<S>) -> W.World<S,Store,R,E>:
  checked(~S,~Store,~R,~E,~F,~clear,~encode,handle,W.valid(~S,~Store,~R,~E,world,handle))
# The actual deferred application reads its publication tick when executed,
# rather than when queued or later transported by ReaderDomains.collect.
def queued(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~clear:Store -> W.Handle<S> -> Store & List<&2,Rm.Record<S,F>>,~encode:Notice<S,F> -> E,+handle:W.Handle<S>,valid:W.World<S,Store,R,E> & Bool) -> W.World<S,Store,R,E>:
  match valid:
    case (world,False{}):world
    case (world,True{}):W.enqueue(~S,~Store,~R,~E,world,w => remove(~S,~Store,~R,~E,~F,~clear,~encode,w,handle))
def enqueue(~S:Data,~Store:Type,~R:Type,~E:Data,~F:Data,~clear:Store -> W.Handle<S> -> Store & List<&2,Rm.Record<S,F>>,~encode:Notice<S,F> -> E,world:W.World<S,Store,R,E>,+handle:W.Handle<S>) -> W.World<S,Store,R,E>:
  queued(~S,~Store,~R,~E,~F,~clear,~encode,handle,W.valid(~S,~Store,~R,~E,world,handle))
def barrier_clock(~S:Data,~Store:Type,~R:Type,~E:Data,advanced:W.World<S,Store,R,E> & U32) -> W.World<S,Store,R,E>:
  (world,_)=advanced
  W.barrier(~S,~Store,~R,~E,world)
def barrier(~S:Data,~Store:Type,~R:Type,~E:Data,world:W.World<S,Store,R,E>) -> W.World<S,Store,R,E>:
  barrier_clock(~S,~Store,~R,~E,W.advance_clock(~S,~Store,~R,~E,world))
