import Base
import state.bend as V
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T
import ../../src/ecs/commands.bend as Cmd

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
type Neighbor is Type:
  Neighbor{array: Array<U32>}
type NeighborView is Data:
  NeighborView{cells: List<&2,U32>}
def neighbor() -> Neighbor:
  Neighbor{ANode{ANode{ALeaf{11},ALeaf{22}},ANode{ALeaf{33},ALeaf{44}}}}
def view4(+a: U32,+b: U32,+c: U32,observed: Array<U32> & U32) -> Neighbor & NeighborView:
  (array,+d) = observed
  (Neighbor{array},NeighborView{[a,b,c,d]})
def view3(+a: U32,+b: U32,observed: Array<U32> & U32) -> Neighbor & NeighborView:
  (array,+c) = observed
  view4(a,b,c,Array.get(U32,array,3))
def view2(+a: U32,observed: Array<U32> & U32) -> Neighbor & NeighborView:
  (array,+b) = observed
  view3(a,b,Array.get(U32,array,2))
def view1(observed: Array<U32> & U32) -> Neighbor & NeighborView:
  (array,+a) = observed
  view2(a,Array.get(U32,array,1))
def project_neighbor(owner: Neighbor) -> Neighbor & NeighborView:
  match owner:
    case Neighbor{array}: view1(Array.get(U32,array,0))
def project_phase(phase: V.Phase) -> V.Phase & V.Phase:
  match phase:
    case V.Ready{}: (V.Ready{},V.Ready{})
    case V.Windup{}: (V.Windup{},V.Windup{})
    case V.Active{}: (V.Active{},V.Active{})
def project_mode(mode: V.Mode) -> V.Mode & V.Mode:
  match mode:
    case V.ModeZero{}: (V.ModeZero{},V.ModeZero{})
    case V.ModeOne{}: (V.ModeOne{},V.ModeOne{})
    case V.ModeTwo{}: (V.ModeTwo{},V.ModeTwo{})

type Store<S: Data> is Type:
  Store{phase: Col.Column<S,V.Phase>,mode: Col.Column<S,V.Mode>,neighbor: Col.Column<S,Neighbor>}

type PhaseToken is Data:
  PhaseToken{}
type PhaseRest<S: Data> is Type:
  PhaseRest{mode: Col.Column<S,V.Mode>,neighbor: Col.Column<S,Neighbor>}
def take_phase(~S: Data,store: Store<S>) -> PhaseRest<S> & Col.Column<S,V.Phase>:
  match store:
    case Store{phase,mode,neighbor}: (PhaseRest{mode,neighbor},phase)
def put_phase(~S: Data,rest: PhaseRest<S>,column: Col.Column<S,V.Phase>) -> Store<S>:
  match rest:
    case PhaseRest{mode,neighbor}: Store{column,mode,neighbor}
def phase_family(~S: Data) -> C.Family<S,Store<S>,PhaseRest<S>,V.Phase,V.Phase,PhaseToken,take_phase(~S),put_phase(~S),project_phase>:
  C.define(~S,~Store<S>,~Unit,~Unit,~PhaseRest<S>,~V.Phase,~V.Phase,~PhaseToken,~take_phase(~S),~put_phase(~S),~project_phase,"State/Phase")
def get_phase(~S: Data,world: W.World<S,Store<S>,Unit,Unit>,handle: W.Handle<S>) -> W.World<S,Store<S>,Unit,Unit> & C.Access<V.Phase>:
  C.get(~S,~Store<S>,~Unit,~Unit,~PhaseRest<S>,~V.Phase,~V.Phase,~PhaseToken,~take_phase(~S),~put_phase(~S),~project_phase,phase_family(~S),world,handle)

type ModeToken is Data:
  ModeToken{}
type ModeRest<S: Data> is Type:
  ModeRest{phase: Col.Column<S,V.Phase>,neighbor: Col.Column<S,Neighbor>}
def take_mode(~S: Data,store: Store<S>) -> ModeRest<S> & Col.Column<S,V.Mode>:
  match store:
    case Store{phase,mode,neighbor}: (ModeRest{phase,neighbor},mode)
def put_mode(~S: Data,rest: ModeRest<S>,column: Col.Column<S,V.Mode>) -> Store<S>:
  match rest:
    case ModeRest{phase,neighbor}: Store{phase,column,neighbor}
def mode_family(~S: Data) -> C.Family<S,Store<S>,ModeRest<S>,V.Mode,V.Mode,ModeToken,take_mode(~S),put_mode(~S),project_mode>:
  C.define(~S,~Store<S>,~Unit,~Unit,~ModeRest<S>,~V.Mode,~V.Mode,~ModeToken,~take_mode(~S),~put_mode(~S),~project_mode,"State/Mode")
def get_mode(~S: Data,world: W.World<S,Store<S>,Unit,Unit>,handle: W.Handle<S>) -> W.World<S,Store<S>,Unit,Unit> & C.Access<V.Mode>:
  C.get(~S,~Store<S>,~Unit,~Unit,~ModeRest<S>,~V.Mode,~V.Mode,~ModeToken,~take_mode(~S),~put_mode(~S),~project_mode,mode_family(~S),world,handle)

type NeighborToken is Data:
  NeighborToken{}
type NeighborRest<S: Data> is Type:
  NeighborRest{phase: Col.Column<S,V.Phase>,mode: Col.Column<S,V.Mode>}
def take_neighbor(~S: Data,store: Store<S>) -> NeighborRest<S> & Col.Column<S,Neighbor>:
  match store:
    case Store{phase,mode,neighbor}: (NeighborRest{phase,mode},neighbor)
def put_neighbor(~S: Data,rest: NeighborRest<S>,column: Col.Column<S,Neighbor>) -> Store<S>:
  match rest:
    case NeighborRest{phase,mode}: Store{phase,mode,column}
def neighbor_family(~S: Data) -> C.Family<S,Store<S>,NeighborRest<S>,Neighbor,NeighborView,NeighborToken,take_neighbor(~S),put_neighbor(~S),project_neighbor>:
  C.define(~S,~Store<S>,~Unit,~Unit,~NeighborRest<S>,~Neighbor,~NeighborView,~NeighborToken,~take_neighbor(~S),~put_neighbor(~S),~project_neighbor,"State/Neighbor")
def get_neighbor(~S: Data,world: W.World<S,Store<S>,Unit,Unit>,handle: W.Handle<S>) -> W.World<S,Store<S>,Unit,Unit> & C.Access<NeighborView>:
  C.get(~S,~Store<S>,~Unit,~Unit,~NeighborRest<S>,~Neighbor,~NeighborView,~NeighborToken,~take_neighbor(~S),~put_neighbor(~S),~project_neighbor,neighbor_family(~S),world,handle)

def empty(~S: Data,unit: Unit) -> Store<S>:
  Store{Col.empty(~S,~V.Phase),Col.empty(~S,~V.Mode),Col.empty(~S,~Neighbor)}
def create(~S: Data,factory: W.Factory) -> W.Creation<S,Store<S>,Unit,Unit>:
  W.create(~S,~Store<S>,~Unit,~Unit,~empty(~S),factory,Unit{})
type Bundle is Type:
  Bundle{phase: Maybe<&1,V.Phase>,mode: Maybe<&1,V.Mode>,neighbor: Neighbor}
def replaced(~S: Data,~Owner: Type,result: C.Replacement<W.World<S,Store<S>,Unit,Unit>,Owner>) -> W.World<S,Store<S>,Unit,Unit>:
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world

def insert_phase(~S: Data,world: W.World<S,Store<S>,Unit,Unit>,handle: W.Handle<S>,incoming: Maybe<&1,V.Phase>) -> W.World<S,Store<S>,Unit,Unit>:
  replaced(~S,~V.Phase,C.structural_replace(~S,~Store<S>,~Unit,~Unit,~PhaseRest<S>,~V.Phase,~V.Phase,~PhaseToken,~take_phase(~S),~put_phase(~S),~project_phase,phase_family(~S),world,handle,incoming))

def insert_mode(~S: Data,world: W.World<S,Store<S>,Unit,Unit>,handle: W.Handle<S>,incoming: Maybe<&1,V.Mode>) -> W.World<S,Store<S>,Unit,Unit>:
  replaced(~S,~V.Mode,C.structural_replace(~S,~Store<S>,~Unit,~Unit,~ModeRest<S>,~V.Mode,~V.Mode,~ModeToken,~take_mode(~S),~put_mode(~S),~project_mode,mode_family(~S),world,handle,incoming))

def insert_neighbor(~S: Data,world: W.World<S,Store<S>,Unit,Unit>,handle: W.Handle<S>,incoming: Maybe<&1,Neighbor>) -> W.World<S,Store<S>,Unit,Unit>:
  replaced(~S,~Neighbor,C.structural_replace(~S,~Store<S>,~Unit,~Unit,~NeighborRest<S>,~Neighbor,~NeighborView,~NeighborToken,~take_neighbor(~S),~put_neighbor(~S),~project_neighbor,neighbor_family(~S),world,handle,incoming))

def populate_inner(~S: Data,world: W.World<S,Store<S>,Unit,Unit>,+handle: W.Handle<S>,bundle: Bundle) -> W.World<S,Store<S>,Unit,Unit>:
  match bundle:
    case Bundle{phase,mode,neighbor}: insert_neighbor(~S,insert_mode(~S,insert_phase(~S,world,handle,phase),handle,mode),handle,Some{neighbor})
def populate(~S: Data,world: W.World<S,Store<S>,Unit,Unit>,handle: W.Handle<S>,bundle: Bundle) -> W.World<S,Store<S>,Unit,Unit>:
  match handle:
    case W.Handle{+namespace,+id}: populate_inner(~S,world,W.Handle{namespace,id},bundle)
def spawned(~S: Data,pair: T.Tx<W.World<S,Store<S>,Unit,Unit>,Unit> & W.Reservation<S>) -> T.Tx<W.World<S,Store<S>,Unit,Unit>,Unit>:
  (tx,_) = pair
  tx
def committed(~S: Data,returned: T.Returned<W.World<S,Store<S>,Unit,Unit>,Unit>) -> W.World<S,Store<S>,Unit,Unit>:
  match returned:
    case T.Returned{world,_}: world
def seed(~S: Data,world: W.World<S,Store<S>,Unit,Unit>) -> W.World<S,Store<S>,Unit,Unit>:
  tx = T.begin(~W.World<S,Store<S>,Unit,Unit>,~Unit,world)
  tx = spawned(~S,Cmd.tx_spawn(~S,~Store<S>,~Unit,~Unit,~Bundle,~populate(~S),tx,Bundle{Some{V.Ready{}},Some{V.ModeZero{}},neighbor()}))
  tx = spawned(~S,Cmd.tx_spawn(~S,~Store<S>,~Unit,~Unit,~Bundle,~populate(~S),tx,Bundle{None{},None{},neighbor()}))
  committed(~S,Cmd.tx_finish(~S,~Store<S>,~Unit,~Unit,~Unit,tx,T.Success{}))
