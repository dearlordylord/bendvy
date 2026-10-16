import Base
import ./model.bend as M
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/owned-event-storage.bend as Store
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/owned-event-runtime.bend as Read

def bool(x:Bool) -> String:
  match x:
    case True{}: "true"
    case False{}: "false"
def nums(xs:List<&2,U32>) -> String:
  match xs:
    case Nil{}: "[]"
    case Con{x,t}: U32.show(x) ++ "," ++ nums(t)
def nats(xs:List<&2,Nat>) -> String:
  match xs:
    case Nil{}: "[]"
    case Con{x,t}: Nat.show(x) ++ "," ++ nats(t)
def strings(xs:List<&2,String>) -> String:
  match xs:
    case Nil{}: "[]"
    case Con{x,t}: x ++ "," ++ strings(t)
def uarray(a:Array<U32>) -> Array<U32> & String:
  match a:
    case ALeaf{+x}: (ALeaf{x},U32.show(x))
    case ANode{a,b}:
      M.bind(Array<U32>,String,Array<U32> & String,uarray(a),a => sa => (
        M.bind(Array<U32>,String,Array<U32> & String,uarray(b),b => sb => (
          (ANode{a,b},"[" ++ sa ++ "," ++ sb ++ "]")
        ))
      ))
def barray(a:Array<Bool>) -> Array<Bool> & String:
  match a:
    case ALeaf{+x}: (ALeaf{x},bool(x))
    case ANode{a,b}:
      M.bind(Array<Bool>,String,Array<Bool> & String,barray(a),a => sa => (
        M.bind(Array<Bool>,String,Array<Bool> & String,barray(b),b => sb => (
          (ANode{a,b},"[" ++ sa ++ "," ++ sb ++ "]")
        ))
      ))
def manifest(p:M.Manifest) -> M.Manifest & String:
  M.Manifest{+code,slots} = p
  M.bind(Array<U32>,String,M.Manifest & String,uarray(slots),slots => s => (
    (M.Manifest{code,slots},"manifest(" ++ U32.show(code) ++ "," ++ s ++ ")")
  ))
def payloads(xs:List<M.Manifest>) -> List<M.Manifest> & String:
  match xs:
    case Nil{}: ([],"[]")
    case Con{x,t}:
      M.bind(M.Manifest,String,List<M.Manifest> & String,manifest(x),x => sx => (
        M.bind(List<M.Manifest>,String,List<M.Manifest> & String,payloads(t),t => st => (
          (x <> t,sx ++ "," ++ st)
        ))
      ))
def rows(xs:List<Log.Row<M.Manifest>>) -> List<Log.Row<M.Manifest>> & String:
  match xs:
    case Nil{}: ([],"[]")
    case Con{Log.Row{+id,payload},t}:
      M.bind(M.Manifest,String,List<Log.Row<M.Manifest>> & String,manifest(payload),payload => sp => (
        M.bind(List<Log.Row<M.Manifest>>,String,List<Log.Row<M.Manifest>> & String,rows(t),t => st => (
          (Log.Row{id,payload} <> t,"row(" ++ Nat.show(id) ++ "," ++ sp ++ ")," ++ st)
        ))
      ))
def seen_text(xs:List<&2,List<&2,U32>>) -> String:
  match xs:
    case Nil{}: "[]"
    case Con{x,t}: "[" ++ nums(x) ++ "]," ++ seen_text(t)
def reader_args(a:M.ReaderArgs) -> M.ReaderArgs & String:
  M.ReaderArgs{+fail,+values,scratch} = a
  M.bind(Array<U32>,String,M.ReaderArgs & String,uarray(scratch),scratch => s => (
    (M.ReaderArgs{fail,values,scratch},"args(" ++ bool(fail) ++ "," ++ seen_text(values) ++ "," ++ s ++ ")")
  ))
def outcome(x:T.Outcome<U32>) -> String:
  match x:
    case T.Success{}: "success"
    case T.Failure{error}: "failure(" ++ U32.show(error) ++ ")"
def read_outcome(x:T.Outcome<Read.Failure<U32>>) -> String:
  match x:
    case T.Success{}: "success"
    case T.Failure{Read.BodyFailed{error}}: "body-failure(" ++ U32.show(error) ++ ")"
    case T.Failure{Read.MissingPayload{}}: "missing-payload"
def metadata(xs:List<&2,W.RegistrationMeta>) -> String:
  match xs:
    case Nil{}: "[]"
    case Con{W.RegistrationMeta{id,name,access},t}:
      "registration(" ++ U32.show(id) ++ "," ++ name ++ "," ++ strings(access) ++ ")," ++ metadata(t)
def pending(xs:List<(M.World() -> M.World())>) -> List<(M.World() -> M.World())> & Nat:
  match xs:
    case Nil{}: ([],0n)
    case Con{x,t}:
      M.bind(List<(M.World() -> M.World())>,Nat,List<(M.World() -> M.World())> & Nat,pending(t),t => n => (
        (x <> t,1n+n)
      ))
def world(w:M.World()) -> M.World() & String:
  W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,commands,+registrations,+nextSystemId,+clock} = w
  Store.Resources{sentinel,Log.Log{+next,owners}} = resource
  M.bind(Array<Bool>,String,M.World() & String,barray(live),live => slive => (
    M.bind(Array<U32>,String,M.World() & String,uarray(sentinel),sentinel => ssentinel => (
      M.bind(List<Log.Row<M.Manifest>>,String,M.World() & String,rows(owners),owners => sowners => (
        M.bind(List<(M.World() -> M.World())>,Nat,M.World() & String,pending(commands),commands => ncommands => (
          text = "world(" ++ U32.show(namespace) ++ "," ++ U32.show(nextId) ++ "," ++ U32.show(highWater) ++ "," ++ slive ++ "," ++ U32.show(capacity) ++ "," ++ Nat.show(depth) ++ ",unit," ++ ssentinel ++ ",log(" ++ Nat.show(next) ++ "," ++ sowners ++ "),events(" ++ nats(events) ++ "),pending(" ++ Nat.show(ncommands) ++ ")," ++ metadata(registrations) ++ "," ++ U32.show(nextSystemId) ++ "," ++ U32.show(clock) ++ ")"
          (W.World{namespace,nextId,highWater,live,capacity,depth,store,Store.Resources{sentinel,Log.Log{next,owners}},events,commands,registrations,nextSystemId,clock},text)
        ))
      ))
    ))
  ))
def batches(xs:List<&2,Ev.Batch<Nat>>) -> String:
  match xs:
    case Nil{}: "[]"
    case Con{Ev.Batch{tick,values},t}: "batch(" ++ Nat.show(tick) ++ "," ++ nats(values) ++ ")," ++ batches(t)
def positions(xs:List<&2,Ev.Position>) -> String:
  match xs:
    case Nil{}: "[]"
    case Con{Ev.Position{id,cursor,registeredAt},t}: "position(" ++ U32.show(id) ++ "," ++ Nat.show(cursor) ++ "," ++ Nat.show(registeredAt) ++ ")," ++ positions(t)
def runtime(r:M.Runtime()) -> M.Runtime() & String:
  Ev.Runtime{w,+namespace,+bs,+ps,+nextReader,+tick,+frameStart,+boundary,+capacity,+droppedThrough} = r
  M.bind(M.World(),String,M.Runtime() & String,world(w),w => sw => (
    text = sw ++ ";runtime(" ++ U32.show(namespace) ++ "," ++ batches(bs) ++ "," ++ positions(ps) ++ "," ++ U32.show(nextReader) ++ "," ++ Nat.show(tick) ++ "," ++ Nat.show(frameStart) ++ "," ++ Nat.show(boundary) ++ "," ++ Nat.show(capacity) ++ "," ++ Nat.show(droppedThrough) ++ ")"
    (Ev.Runtime{w,namespace,bs,ps,nextReader,tick,frameStart,boundary,capacity,droppedThrough},text)
  ))
