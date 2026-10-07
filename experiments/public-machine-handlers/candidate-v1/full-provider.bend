import Base
import event-stream.bend as ES
import ../../../src/ecs/local.bend as Local
import ../../public-machines/machine.bend as M
import ../../public-machines/stream.bend as St
import ../../public-machines/world.bend as MW
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/transaction.bend as Tx
import ../../public-machines/conditions.bend as Cond

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
type FlowToken is Data:
  FlowToken{}
type LevelToken is Data:
  LevelToken{}
type CellsToken is Data:
  CellsToken{}
type Flow is Data:
  Boot{}
  Play{}
  Pause{}
type Level is Data:
  Low{}
  Middle{}
  High{}
type Ping is Data:
  Ping{handler:U32,attempt:U32}
type LocalEntry is Type:
  LocalEntry{namespace:U32,id:U32,cell:Local.Cell<Array<U32>>}
type Aux is Type:
  Aux{locals:List<&1,LocalEntry>,ping:ES.Stream<Ping>,attempts:List<&2,String>,deliveries:List<&2,String>,failurePhase:U32,failurePosition:U32,enabled:Bool}
type Store<S: Data> is Type:
  Store{cells: Col.Column<S,Array<U32>>}
type Resources<S: Data> is Type:
  Resources{owned: Maybe<&1,Array<U32>>,flow: M.Slot<S,FlowToken,Flow>,level: M.Slot<S,LevelToken,Level>,flowStream: St.Stream<Flow>,levelStream: St.Stream<Level>,frame: Nat,tick: Nat,trace: List<&2,String>,aux: Aux}
def flow_same(a: Flow,b: Flow) -> Bool:
  match a b:
    case Boot{} Boot{}: True{}
    case Play{} Play{}: True{}
    case Pause{} Pause{}: True{}
    case _ _: False{}

def level_same(a: Level,b: Level) -> Bool:
  match a b:
    case Low{} Low{}: True{}
    case Middle{} Middle{}: True{}
    case High{} High{}: True{}
    case _ _: False{}

def flow_take_resource(~S: Data,resources: Resources<S>) -> Resources<S> & M.Slot<S,FlowToken,Flow>:
  match resources:
    case Resources{owned,+flow,level,flowStream,levelStream,frame,tick,trace,aux}:
      (Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,aux},flow)

def flow_put_resource(~S: Data,resources: Resources<S>,flow: M.Slot<S,FlowToken,Flow>) -> Resources<S>:
  match resources:
    case Resources{owned,_,level,flowStream,levelStream,frame,tick,trace,aux}:
      Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,aux}

def level_take_resource(~S: Data,resources: Resources<S>) -> Resources<S> & M.Slot<S,LevelToken,Level>:
  match resources:
    case Resources{owned,flow,+level,flowStream,levelStream,frame,tick,trace,aux}:
      (Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,aux},level)

def level_put_resource(~S: Data,resources: Resources<S>,level: M.Slot<S,LevelToken,Level>) -> Resources<S>:
  match resources:
    case Resources{owned,flow,_,flowStream,levelStream,frame,tick,trace,aux}:
      Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,aux}

def flow_take(~S: Data,world: W.World<S,Store<S>,Resources<S>,Ping>) -> W.World<S,Store<S>,Resources<S>,Ping> & M.Slot<S,FlowToken,Flow>:
  MW.take(~S,~FlowToken,~Flow,~Store<S>,~Resources<S>,~Ping,~(r => flow_take_resource(~S,r)),world)

def flow_put(~S: Data,world: W.World<S,Store<S>,Resources<S>,Ping>,slot: M.Slot<S,FlowToken,Flow>) -> W.World<S,Store<S>,Resources<S>,Ping>:
  MW.put(~S,~FlowToken,~Flow,~Store<S>,~Resources<S>,~Ping,~(r => s => flow_put_resource(~S,r,s)),world,slot)

def level_take(~S: Data,world: W.World<S,Store<S>,Resources<S>,Ping>) -> W.World<S,Store<S>,Resources<S>,Ping> & M.Slot<S,LevelToken,Level>:
  MW.take(~S,~LevelToken,~Level,~Store<S>,~Resources<S>,~Ping,~(r => level_take_resource(~S,r)),world)

def level_put(~S: Data,world: W.World<S,Store<S>,Resources<S>,Ping>,slot: M.Slot<S,LevelToken,Level>) -> W.World<S,Store<S>,Resources<S>,Ping>:
  MW.put(~S,~LevelToken,~Level,~Store<S>,~Resources<S>,~Ping,~(r => s => level_put_resource(~S,r,s)),world,slot)

def empty_store(~S: Data,_: Unit) -> Store<S>:
  Store{Col.Column{ALeaf{None{}},[]}}

def initial_resources(~S: Data) -> Resources<S>:
  Resources{Some{ANode{ALeaf{3},ALeaf{13}}},M.Present{Boot{},M.NoPending{},None{},False{}},M.Present{Low{},M.NoPending{},None{},False{}},St.empty(~Flow),St.empty(~Level),0n,0n,[],Aux{[],ES.empty(~Ping),[],[],0,0,False{}}}

def array_join(left: Array<U32> & List<&2,U32>,right: Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  (left,a)=left
  (right,b)=right
  (ANode{left,right},List.append(&2,U32,a,b))

def array_view(owner: Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: array_join(array_view(left),array_view(right))

def store_take(~S: Data,store: Store<S>) -> Unit & Col.Column<S,Array<U32>>:
  match store:
    case Store{column}: (Unit{},column)

def store_put(~S: Data,_: Unit,column: Col.Column<S,Array<U32>>) -> Store<S>:
  Store{column}

# The seeded cell has local ID 1; its namespace comes from the actual owner.
# Generic gameplay never receives this trusted declaration or concrete world.
def cells_set_world(~S: Data,world: W.World<S,Store<S>,Resources<S>,Ping>,undo: List<&1,(W.World<S,Store<S>,Resources<S>,Ping> -> W.World<S,Store<S>,Resources<S>,Ping>)>,commands: List<&1,(W.World<S,Store<S>,Resources<S>,Ping> -> W.World<S,Store<S>,Resources<S>,Ping>)>,events: List<&2,Ping>,owner: Array<U32>) -> Cmp.SetResult<Tx.Tx<W.World<S,Store<S>,Resources<S>,Ping>,Ping>,Array<U32>>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,resources,bus,pending,registrations,nextSystem,clock}:
      Cmp.tx_set(~S,~Store<S>,~Resources<S>,~Ping,~Unit,~Array<U32>,~List<&2,U32>,~CellsToken,~(store => store_take(~S,store)),~(rest => column => store_put(~S,rest,column)),~array_view,Cmp.Family{"cells"},Tx.Tx{W.World{ns,next,high,live,capacity,depth,store,resources,bus,pending,registrations,nextSystem,clock},undo,commands,events},W.Handle{ns,1},owner)

def cells_set(~S: Data,tx: Tx.Tx<W.World<S,Store<S>,Resources<S>,Ping>,Ping>,owner: Array<U32>) -> Cmp.SetResult<Tx.Tx<W.World<S,Store<S>,Resources<S>,Ping>,Ping>,Array<U32>>:
  match tx:
    case Tx.Tx{world,undo,commands,events}: cells_set_world(~S,world,undo,commands,events,owner)

def populate_error(~S: Data,world: W.World<S,Store<S>,Resources<S>,Ping>) -> W.World<S,Store<S>,Resources<S>,Ping>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,aux},events,commands,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,Resources{owned,flow,level,flowStream,levelStream,frame,tick,List.append(&2,String,trace,["POPULATE_REJECTED"]),aux},events,commands,registrations,nextSystem,clock}
def populated(~S: Data,result: Cmp.Replacement<W.World<S,Store<S>,Resources<S>,Ping>,Array<U32>>) -> W.World<S,Store<S>,Resources<S>,Ping>:
  match result:
    case Cmp.Replaced{world,_}: world
    case Cmp.ReplaceRejected{world,_,_}: populate_error(~S,world)
def populate_cells(~S: Data,world: W.World<S,Store<S>,Resources<S>,Ping>,handle: W.Handle<S>,owner: Array<U32>) -> W.World<S,Store<S>,Resources<S>,Ping>:
  populated(~S,Cmp.replace(~S,~Store<S>,~Resources<S>,~Ping,~Unit,~Array<U32>,~List<&2,U32>,~CellsToken,~(store => store_take(~S,store)),~(rest => column => store_put(~S,rest,column)),~array_view,Cmp.Family{"cells"},world,handle,Some{owner}))

def map_resources(~S: Data,effect: Resources<S> -> Resources<S>,world: W.World<S,Store<S>,Resources<S>,Ping>) -> W.World<S,Store<S>,Resources<S>,Ping>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,effect(resources),events,commands,registrations,nextSystem,clock}
def pulse_resources(~S: Data,resources: Resources<S>) -> Resources<S>:
  match resources:
    case Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace,aux}:
      Resources{owned,flow,level,flowStream,levelStream,frame,1n+tick,trace,aux}
def pulse(~S: Data,world: W.World<S,Store<S>,Resources<S>,Ping>) -> W.World<S,Store<S>,Resources<S>,Ping>:
  map_resources(~S,resources => pulse_resources(~S,resources),world)
def frame_aux(aux:Aux,tick:Nat) -> Aux:
  match aux:
    case Aux{locals,ping,attempts,deliveries,phase,position,enabled}: Aux{locals,ES.frame(~Ping,ping,tick),attempts,deliveries,phase,position,enabled}
def frame_resources(~S: Data,resources: Resources<S>) -> Resources<S>:
  match resources:
    case Resources{owned,flow,level,flowStream,levelStream,frame,+tick,trace,aux}:
      Resources{owned,flow,level,St.frame(~Flow,flowStream,tick),St.frame(~Level,levelStream,tick),1n+frame,tick,trace,frame_aux(aux,tick)}
def frame(~S: Data,world: W.World<S,Store<S>,Resources<S>,Ping>) -> W.World<S,Store<S>,Resources<S>,Ping>:
  map_resources(~S,resources => frame_resources(~S,resources),world)
