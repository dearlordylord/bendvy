import Base
import machine.bend as M
import provider.bend as P
import stream.bend as St
import ../../src/ecs/world.bend as W
import ../../src/ecs/column.bend as Col
import ../../src/ecs/lifecycle.bend as L
import ../../src/ecs/event-runtime.bend as Ev

def bool(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def flow(value: P.Flow) -> String:
  match value:
    case P.Boot{}: "Boot"
    case P.Play{}: "Play"
    case P.Pause{}: "Pause"
def level(value: P.Level) -> String:
  match value:
    case P.Low{}: "0"
    case P.Middle{}: "1"
    case P.High{}: "2"
def pending(~V: Data,~show: V -> String,value: M.Pending<V>) -> String:
  match value:
    case M.NoPending{}: "none"
    case M.Queued{value,skip}: show(value) ++ ":" ++ bool(skip)
def previous(~V: Data,~show: V -> String,value: Maybe<&2,V>) -> String:
  match value:
    case None{}: "none"
    case Some{value}: show(value)
def slot(~S: Data,~K: Data,~V: Data,~show: V -> String,value: M.Slot<S,K,V>) -> String:
  match value:
    case M.Missing{}: "missing"
    case M.Present{current,next,last,changed}: show(current) ++ "(pending=" ++ pending(~V,~show,next) ++ ",previous=" ++ previous(~V,~show,last) ++ ",changed=" ++ bool(changed) ++ ")"
def transition(~V: Data,~show: V -> String,value: M.Transition<V>) -> String:
  match value:
    case M.Transition{from,to}: show(from) ++ ">" ++ show(to)
def batch(~V: Data,~show: V -> String,value: Ev.Batch<M.Transition<V>>) -> String:
  match value:
    case Ev.Batch{tick,values}: Nat.show(tick) ++ ":" ++ List.show(&2,M.Transition<V>,value => transition(~V,~show,value),values)
def position(value: Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}: U32.show(id) ++ ":" ++ Nat.show(cursor) ++ ":" ++ Nat.show(registered)
def stream(~V: Data,~show: V -> String,value: St.Stream<V>) -> String:
  match value:
    case St.Stream{batches,positions,dropped,frameStart}: "batches=" ++ List.show(&2,Ev.Batch<M.Transition<V>>,value => batch(~V,~show,value),batches) ++ ",positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ",dropped=" ++ Nat.show(dropped) ++ ",frameStart=" ++ Nat.show(frameStart)
def entry(value: L.Entry) -> String:
  match value:
    case L.Entry{id,L.Stamp{added,changed}}: U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def owner_view_join(pair: Array<U32> & List<&2,U32>) -> Array<U32> & String:
  (owner,values)=pair
  (owner,List.show(&2,U32,U32.show,values))
def owner_view(owner: Array<U32>) -> Array<U32> & String:
  owner_view_join(P.array_view(owner))
def cell_view_join(value: Array<U32> & String) -> Maybe<&1,Array<U32>> & String:
  (owner,text)=value
  (Some{owner},text)
def cell_view(value: Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & String:
  match value:
    case None{}: (None{},"none")
    case Some{owner}: cell_view_join(owner_view(owner))

def cells_leaf(pair: Maybe<&1,Array<U32>> & String) -> Array<Maybe<&1,Array<U32>>> & List<&2,String>:
  (owner,text)=pair
  (ALeaf{owner},[text])
def cells_join(left: Array<Maybe<&1,Array<U32>>> & List<&2,String>,right: Array<Maybe<&1,Array<U32>>> & List<&2,String>) -> Array<Maybe<&1,Array<U32>>> & List<&2,String>:
  (left,a)=left
  (right,b)=right
  (ANode{left,right},List.append(&2,String,a,b))
def cells_view(values: Array<Maybe<&1,Array<U32>>>) -> Array<Maybe<&1,Array<U32>>> & List<&2,String>:
  match values:
    case ALeaf{owner}: cells_leaf(cell_view(owner))
    case ANode{left,right}: cells_join(cells_view(left),cells_view(right))
def text(value: String) -> String: value
def column_join(~S: Data,pair: Array<Maybe<&1,Array<U32>>> & List<&2,String>,+stamps: List<&2,L.Entry>) -> Col.Column<S,Array<U32>> & String:
  (values,views)=pair
  (Col.Column{values,stamps},List.show(&2,String,text,views) ++ ":stamps=" ++ List.show(&2,L.Entry,entry,stamps))
def store_join(~S: Data,pair: Col.Column<S,Array<U32>> & String) -> P.Store<S> & String:
  (column,view)=pair
  (P.Store{column},view)
def column_view(~S: Data,column: Col.Column<S,Array<U32>>) -> Col.Column<S,Array<U32>> & String:
  match column:
    case Col.Column{values,stamps}: column_join(~S,cells_view(values),stamps)
    case column: (column,"UNSUPPORTED_COLUMN_ROUTE")
def store_view(~S: Data,store: P.Store<S>) -> P.Store<S> & String:
  match store:
    case P.Store{column}: store_join(~S,column_view(~S,column))

def resources_join(~S: Data,pair: Array<U32> & String,+a: M.Slot<S,P.FlowToken,P.Flow>,+b: M.Slot<S,P.LevelToken,P.Level>,+flowStream: St.Stream<P.Flow>,+levelStream: St.Stream<P.Level>,+frame: Nat,+tick: Nat,+trace: List<&2,String>) -> P.Resources<S> & String:
  (owned,view)=pair
  (P.Resources{owned,a,b,flowStream,levelStream,frame,tick,trace},"owned=" ++ view ++ ";flow=" ++ slot(~S,~P.FlowToken,~P.Flow,~flow,a) ++ ";level=" ++ slot(~S,~P.LevelToken,~P.Level,~level,b) ++ ";flowStream=" ++ stream(~P.Flow,~flow,flowStream) ++ ";levelStream=" ++ stream(~P.Level,~level,levelStream) ++ ";frame=" ++ Nat.show(frame) ++ ";tick=" ++ Nat.show(tick) ++ ";hooks=" ++ List.show(&2,String,text,trace))
def resources_view(~S: Data,resources: P.Resources<S>) -> P.Resources<S> & String:
  match resources:
    case P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace}: resources_join(~S,owner_view(owned),flow,level,flowStream,levelStream,frame,tick,trace)

def live_join(left: Array<Bool> & List<&2,Bool>,right: Array<Bool> & List<&2,Bool>) -> Array<Bool> & List<&2,Bool>:
  (left,a)=left
  (right,b)=right
  (ANode{left,right},List.append(&2,Bool,a,b))
def live_view(live: Array<Bool>) -> Array<Bool> & List<&2,Bool>:
  match live:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: live_join(live_view(left),live_view(right))
def queue_join(~W: Type,command: W -> W,pair: List<&1,(W -> W)> & Nat) -> List<&1,(W -> W)> & Nat:
  (rest,count)=pair
  (command <> rest,1n+count)
def queue_view(~W: Type,commands: List<&1,(W -> W)>) -> List<&1,(W -> W)> & Nat:
  match commands:
    case Nil{}: ([],0n)
    case Con{command,rest}: queue_join(~W,command,queue_view(~W,rest))
def registration(value: W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}: U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access)

def world_join(~S: Data,+ns: U32,+next: U32,+high: U32,+capacity: U32,+depth: Nat,pairLive: Array<Bool> & List<&2,Bool>,pairStore: P.Store<S> & String,pairResources: P.Resources<S> & String,+events: List<&2,Unit>,pairCommands: List<&1,(W.World<S,P.Store<S>,P.Resources<S>,Unit> -> W.World<S,P.Store<S>,P.Resources<S>,Unit>)> & Nat,+registrations: List<&2,W.RegistrationMeta>,+nextSystem: U32,+clock: U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  (live,liveValues)=pairLive
  (store,cells)=pairStore
  (resources,resourceText)=pairResources
  (commands,commandCount)=pairCommands
  (W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock},"ns=" ++ U32.show(ns) ++ ";next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";live=" ++ List.show(&2,Bool,bool,liveValues) ++ ";cells=" ++ cells ++ ";" ++ resourceText ++ ";queue=" ++ Nat.show(commandCount) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ ";nextSystem=" ++ U32.show(nextSystem) ++ ";componentClock=" ++ U32.show(clock) ++ ";busEvents=" ++ Nat.show(List.length(&2,Unit,events)))
def world(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:
      world_join(~S,ns,next,high,capacity,depth,live_view(live),store_view(~S,store),resources_view(~S,resources),events,queue_view(~W.World<S,P.Store<S>,P.Resources<S>,Unit>,commands),registrations,nextSystem,clock)
