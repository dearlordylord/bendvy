import Base
import ../../../../../../bendvy/src/ecs/machine.bend as M
import stream.bend as St
import ../../../../../../bendvy/src/ecs/machine-world.bend as MW
import ../../../../../../bendvy/src/ecs/world.bend as W
import ../../../../../../bendvy/src/ecs/column.bend as Col
import ../../../../../../bendvy/src/ecs/component.bend as Cmp
import ../../../../../../bendvy/src/ecs/transaction.bend as Tx
import conditions.bend as Cond

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
type Store<S: Data> is Type:
  Store{cells: Col.Column<S,Array<U32>>}
type Resources<S: Data> is Type:
  Resources{owned: Array<U32>,flow: M.Slot<S,FlowToken,Flow>,level: M.Slot<S,LevelToken,Level>,flowStream: St.Stream<Flow>,levelStream: St.Stream<Level>,frame: Nat,tick: Nat,trace: List<&2,String>}
type Atom<S: Data> is Data:
  InFlow{value: Flow}
  InLevel{value: Level}
  FlowChanged{}
  LevelChanged{}
  FlowExists{}
  LevelExists{}
type ConditionEnv<S: Data> is Data:
  ConditionEnv{flow: M.Slot<S,FlowToken,Flow>,level: M.Slot<S,LevelToken,Level>}

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

def slot_exists(~S: Data,~Token: Data,~V: Data,slot: M.Slot<S,Token,V>) -> Bool:
  match slot:
    case M.Missing{}: False{}
    case M.Present{_,_,_,_}: True{}

def condition_leaf(~S: Data,atom: Atom<S>,env: ConditionEnv<S>) -> Bool:
  match atom env:
    case InFlow{value}, ConditionEnv{flow,_}: M.current_matches(~S,~FlowToken,~Flow,~flow_same,flow,value)
    case InLevel{value}, ConditionEnv{_,level}: M.current_matches(~S,~LevelToken,~Level,~level_same,level,value)
    case FlowChanged{}, ConditionEnv{flow,_}: M.changed(~S,~FlowToken,~Flow,flow)
    case LevelChanged{}, ConditionEnv{_,level}: M.changed(~S,~LevelToken,~Level,level)
    case FlowExists{}, ConditionEnv{flow,_}: slot_exists(~S,~FlowToken,~Flow,flow)
    case LevelExists{}, ConditionEnv{_,level}: slot_exists(~S,~LevelToken,~Level,level)
def atom_needs(~S: Data,atom: Atom<S>) -> List<&2,U32>:
  match atom:
    case InFlow{_}: [1]
    case InLevel{_}: [2]
    case FlowChanged{}: [1]
    case LevelChanged{}: [2]
    case FlowExists{}: [1]
    case LevelExists{}: [2]
def condition_needs(~S: Data,tree: Cond.Tree<Atom<S>>) -> List<&2,U32>:
  match tree:
    case Cond.Leaf{atom}: atom_needs(~S,atom)
    case Cond.Constant{_}: []
    case Cond.Negate{inner}: condition_needs(~S,inner)
    case Cond.Both{left,right}: List.append(&2,U32,condition_needs(~S,left),condition_needs(~S,right))
    case Cond.Either{left,right}: List.append(&2,U32,condition_needs(~S,left),condition_needs(~S,right))

def slot_present(~S: Data,~Token: Data,~V: Data,slot: M.Slot<S,Token,V>) -> Bool:
  match slot:
    case M.Missing{}: False{}
    case M.Present{_,_,_,_}: True{}

# Provisioning examines every declared leaf, independently of runtime Boolean
# short circuiting. A true disjunction cannot hide a missing machine provision.
def condition_provisioned(~S: Data,needs: List<&2,U32>,+env: ConditionEnv<S>) -> Bool:
  match needs env:
    case Nil{}, _: True{}
    case Con{1,rest}, ConditionEnv{+flow,level}:
      Bool.and(slot_present(~S,~FlowToken,~Flow,flow),condition_provisioned(~S,rest,ConditionEnv{flow,level}))
    case Con{2,rest}, ConditionEnv{flow,+level}:
      Bool.and(slot_present(~S,~LevelToken,~Level,level),condition_provisioned(~S,rest,ConditionEnv{flow,level}))
    case Con{_,_}, _: False{}

type ConditionCheck is Data:
  ConditionMissing{}
  ConditionValue{passes: Bool}

def condition_ready(~S: Data,ready: Bool,tree: Cond.Tree<Atom<S>>,env: ConditionEnv<S>) -> ConditionCheck:
  match ready:
    case False{}: ConditionMissing{}
    case True{}: ConditionValue{Cond.evaluate(~Atom<S>,~ConditionEnv<S>,~(atom => env => condition_leaf(~S,atom,env)),tree,env)}

def condition_check(~S: Data,+tree: Cond.Tree<Atom<S>>,+env: ConditionEnv<S>) -> ConditionCheck:
  ConditionValue{Cond.evaluate(~Atom<S>,~ConditionEnv<S>,~(atom => values => condition_leaf(~S,atom,values)),tree,env)}

# Boolean fixture projection only. The schedule boundary must match the full
# ConditionCheck so provisioning refusal is distinct from a normal skip.
def condition_value(result: ConditionCheck) -> Bool:
  match result:
    case ConditionMissing{}: False{}
    case ConditionValue{passes}: passes

def condition_from_env(~S: Data,tree: Cond.Tree<Atom<S>>,env: ConditionEnv<S>) -> Bool:
  condition_value(condition_check(~S,tree,env))

def condition_world(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,tree: Cond.Tree<Atom<S>>) -> W.World<S,Store<S>,Resources<S>,Unit> & ConditionCheck:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,+flow,+level,flowStream,levelStream,frame,tick,trace},events,commands,registrations,nextSystem,clock}:
      (W.World{ns,next,high,live,capacity,depth,store,Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace},events,commands,registrations,nextSystem,clock},condition_check(~S,tree,ConditionEnv{flow,level}))

def flow_take_resource(~S: Data,resources: Resources<S>) -> Resources<S> & M.Slot<S,FlowToken,Flow>:
  match resources:
    case Resources{owned,+flow,level,flowStream,levelStream,frame,tick,trace}:
      (Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace},flow)

def flow_put_resource(~S: Data,resources: Resources<S>,flow: M.Slot<S,FlowToken,Flow>) -> Resources<S>:
  match resources:
    case Resources{owned,_,level,flowStream,levelStream,frame,tick,trace}:
      Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace}

def level_take_resource(~S: Data,resources: Resources<S>) -> Resources<S> & M.Slot<S,LevelToken,Level>:
  match resources:
    case Resources{owned,flow,+level,flowStream,levelStream,frame,tick,trace}:
      (Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace},level)

def level_put_resource(~S: Data,resources: Resources<S>,level: M.Slot<S,LevelToken,Level>) -> Resources<S>:
  match resources:
    case Resources{owned,flow,_,flowStream,levelStream,frame,tick,trace}:
      Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace}

def flow_take(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>) -> W.World<S,Store<S>,Resources<S>,Unit> & M.Slot<S,FlowToken,Flow>:
  MW.take(~S,~FlowToken,~Flow,~Store<S>,~Resources<S>,~Unit,~(r => flow_take_resource(~S,r)),world)

def flow_put(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,slot: M.Slot<S,FlowToken,Flow>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  MW.put(~S,~FlowToken,~Flow,~Store<S>,~Resources<S>,~Unit,~(r => s => flow_put_resource(~S,r,s)),world,slot)

def level_take(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>) -> W.World<S,Store<S>,Resources<S>,Unit> & M.Slot<S,LevelToken,Level>:
  MW.take(~S,~LevelToken,~Level,~Store<S>,~Resources<S>,~Unit,~(r => level_take_resource(~S,r)),world)

def level_put(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,slot: M.Slot<S,LevelToken,Level>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  MW.put(~S,~LevelToken,~Level,~Store<S>,~Resources<S>,~Unit,~(r => s => level_put_resource(~S,r,s)),world,slot)

def empty_store(~S: Data,_: Unit) -> Store<S>:
  Store{Col.Column{ALeaf{None{}},[]}}

def initial_resources(~S: Data) -> Resources<S>:
  Resources{ANode{ALeaf{30},ALeaf{130}},M.Present{Boot{},M.NoPending{},None{},False{}},M.Present{Low{},M.NoPending{},None{},False{}},St.empty(~Flow),St.empty(~Level),0n,0n,[]}

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
def cells_set_world(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,undo: List<&1,(W.World<S,Store<S>,Resources<S>,Unit> -> W.World<S,Store<S>,Resources<S>,Unit>)>,commands: List<&1,(W.World<S,Store<S>,Resources<S>,Unit> -> W.World<S,Store<S>,Resources<S>,Unit>)>,events: List<&2,Unit>,owner: Array<U32>) -> Cmp.SetResult<Tx.Tx<W.World<S,Store<S>,Resources<S>,Unit>,Unit>,Array<U32>>:
  match world:
    case W.World{+ns,next,high,live,capacity,depth,store,resources,bus,pending,registrations,nextSystem,clock}:
      Cmp.tx_set(~S,~Store<S>,~Resources<S>,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~CellsToken,~(store => store_take(~S,store)),~(rest => column => store_put(~S,rest,column)),~array_view,Cmp.Family{"cells"},Tx.Tx{W.World{ns,next,high,live,capacity,depth,store,resources,bus,pending,registrations,nextSystem,clock},undo,commands,events},W.Handle{ns,1},owner)

def cells_set(~S: Data,tx: Tx.Tx<W.World<S,Store<S>,Resources<S>,Unit>,Unit>,owner: Array<U32>) -> Cmp.SetResult<Tx.Tx<W.World<S,Store<S>,Resources<S>,Unit>,Unit>,Array<U32>>:
  match tx:
    case Tx.Tx{world,undo,commands,events}: cells_set_world(~S,world,undo,commands,events,owner)

def populate_error(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace},events,commands,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,Resources{owned,flow,level,flowStream,levelStream,frame,tick,List.append(&2,String,trace,["POPULATE_REJECTED"])},events,commands,registrations,nextSystem,clock}
def populated(~S: Data,result: Cmp.Replacement<W.World<S,Store<S>,Resources<S>,Unit>,Array<U32>>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  match result:
    case Cmp.Replaced{world,_}: world
    case Cmp.ReplaceRejected{world,_,_}: populate_error(~S,world)
def populate_cells(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>,handle: W.Handle<S>,owner: Array<U32>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  populated(~S,Cmp.replace(~S,~Store<S>,~Resources<S>,~Unit,~Unit,~Array<U32>,~List<&2,U32>,~CellsToken,~(store => store_take(~S,store)),~(rest => column => store_put(~S,rest,column)),~array_view,Cmp.Family{"cells"},world,handle,Some{owner}))

def map_resources(~S: Data,effect: Resources<S> -> Resources<S>,world: W.World<S,Store<S>,Resources<S>,Unit>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,resources,events,commands,registrations,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,effect(resources),events,commands,registrations,nextSystem,clock}
def pulse_resources(~S: Data,resources: Resources<S>) -> Resources<S>:
  match resources:
    case Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace}:
      Resources{owned,flow,level,flowStream,levelStream,frame,1n+tick,trace}
def pulse(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  map_resources(~S,resources => pulse_resources(~S,resources),world)
def frame_resources(~S: Data,resources: Resources<S>) -> Resources<S>:
  match resources:
    case Resources{owned,flow,level,flowStream,levelStream,frame,+tick,trace}:
      Resources{owned,M.clear_changed(~S,~FlowToken,~Flow,flow),M.clear_changed(~S,~LevelToken,~Level,level),St.frame(~Flow,flowStream,tick),St.frame(~Level,levelStream,tick),1n+frame,tick,trace}
def frame(~S: Data,world: W.World<S,Store<S>,Resources<S>,Unit>) -> W.World<S,Store<S>,Resources<S>,Unit>:
  map_resources(~S,resources => frame_resources(~S,resources),world)
