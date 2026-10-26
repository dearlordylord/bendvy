import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/change-tick.bend as Tick

type Schema is Data: Schema{}
type Token is Data: Token{}
type Payload is Type: Payload{token: Array<U32>,calls: U32}
type Resource is Type: Resource{token: Array<U32>}
type View is Data: View{value: U32,calls: U32}
def Store() -> Type: Col.Column<Schema,Payload>
def World() -> Type: W.World<Schema,Store(),Resource,Unit>
def empty(_: Unit) -> Store(): Col.empty_indexed(~Schema,~Payload)
def take(column: Store()) -> Unit & Store(): (Unit{},column)
def put(_: Unit,column: Store()) -> Store(): column
def projected(+calls: U32,result: Array<U32> & U32) -> Payload & View:
  match result:
    case (token,value): (Payload{token,U32.add(calls,1)},View{value,U32.add(calls,1)})
def project(payload: Payload) -> Payload & View:
  match payload:
    case Payload{token,calls}: projected(calls,Array.get(U32,token,0))
def family() -> C.Family<Schema,Store(),Unit,Payload,View,Token,take,put,project>: C.Family{"Counted"}

type State is Type: State{factory: W.Factory,world: World(),old: Maybe<&2,W.Handle<Schema>>,fresh: Maybe<&2,W.Handle<Schema>>,foreign: Maybe<&2,W.Handle<Schema>>,log: String}
type Command is Data:
  Reserve{slot: U32}
  Foreign{}
  Read{slot: U32,label: String}
  Edit{operation: U32,slot: U32,value: U32}
def chosen(slot: U32,old: Maybe<&2,W.Handle<Schema>>,fresh: Maybe<&2,W.Handle<Schema>>,foreign: Maybe<&2,W.Handle<Schema>>) -> Maybe<&2,W.Handle<Schema>>:
  match slot:
    case 0: old
    case 1: fresh
    case _: foreign
def key_text(handle: W.Handle<Schema>) -> String:
  match handle:
    case W.Handle{_,Key.EntityKey{index,generation}}: U32.show(index) ++ ":" ++ U32.show(generation)
def access_text(value: C.Access<View>) -> String:
  match value:
    case C.MissingEntity{}: "MissingEntity"
    case C.ComponentAbsent{}: "ComponentAbsent"
    case C.Found{View{value,calls}}: "Found(" ++ U32.show(value) ++ "," ++ U32.show(calls) ++ ")"
def read_done(factory: W.Factory,old: Maybe<&2,W.Handle<Schema>>,fresh: Maybe<&2,W.Handle<Schema>>,foreign: Maybe<&2,W.Handle<Schema>>,log: String,label: String,result: World() & C.Access<View>) -> State:
  match result:
    case (world,value): State{factory,world,old,fresh,foreign,log ++ label ++ "=" ++ access_text(value) ++ "\n"}
def read_selected(label: String,state: State,handle: Maybe<&2,W.Handle<Schema>>) -> State:
  match state handle:
    case State{factory,world,old,fresh,foreign,log} Some{handle}: read_done(factory,old,fresh,foreign,log,label,C.get(~Schema,~Store(),~Resource,~Unit,~Unit,~Payload,~View,~Token,~take,~put,~project,family(),world,handle))
    case State{factory,world,old,fresh,foreign,log} None{}: State{factory,world,old,fresh,foreign,log ++ label ++ "=missing-handle\n"}
def replaced(result: C.Replacement<World(),Payload>) -> World():
  match result:
    case C.Replaced{world,_}: world
    case C.ReplaceRejected{world,_,_}: world

def cleared(result: Col.SwapOutcome<Schema,Payload>) -> Store() & Unit:
  match result:
    case Col.Accepted{column,_}: (column,Unit{})
    case Col.Rejected{column,_}: (column,Unit{})
def clear_column(id: U32,column: Store()) -> Store() & Unit: cleared(Col.clear(~Schema,~Payload,column,id))
def clear_done(result: World() & Unit) -> World():
  match result:
    case (world,_): world
def edit_world(operation: U32,value: U32,handle: W.Handle<Schema>,world: World()) -> World():
  match operation:
    case 0: replaced(C.structural_replace(~Schema,~Store(),~Resource,~Unit,~Unit,~Payload,~View,~Token,~take,~put,~project,family(),world,handle,Some{Payload{ALeaf{value},0}}))
    case 1: W.discard_status(~Schema,~Store(),~Resource,~Unit,W.activate(~Schema,~Store(),~Resource,~Unit,world,handle))
    case 2: W.discard_status(~Schema,~Store(),~Resource,~Unit,W.deactivate(~Schema,~Store(),~Resource,~Unit,world,handle))
    case 3: clear_done(W.with_store(~Schema,~Store(),~Resource,~Unit,~Unit,clear_column(W.handle_index(~Schema,handle)),world))
    case 4: W.release_cleared(~Schema,~Store(),~Resource,~Unit,world,handle)
    case _: W.mark_pending(~Schema,~Store(),~Resource,~Unit,world,handle)
def edit_selected(operation: U32,value: U32,state: State,handle: Maybe<&2,W.Handle<Schema>>) -> State:
  match state handle:
    case State{factory,world,old,fresh,foreign,log} Some{handle}: State{factory,edit_world(operation,value,handle,world),old,fresh,foreign,log}
    case State{factory,world,old,fresh,foreign,log} None{}: State{factory,world,old,fresh,foreign,log ++ "edit=missing-handle\n"}
def reserved_slot(result: World() & W.Reservation<Schema>,slot: U32,factory: W.Factory,old: Maybe<&2,W.Handle<Schema>>,fresh: Maybe<&2,W.Handle<Schema>>,foreign: Maybe<&2,W.Handle<Schema>>,log: String) -> State:
  match result slot:
    case (world,W.Reserved{+handle}) 0: State{factory,world,Some{handle},fresh,foreign,log ++ "reserve0=" ++ key_text(handle) ++ "\n"}
    case (world,W.Reserved{+handle}) _: State{factory,world,old,Some{handle},foreign,log ++ "reserve1=" ++ key_text(handle) ++ "\n"}
    case (world,_) _: State{factory,world,old,fresh,foreign,log ++ "reserve=refused\n"}
def foreign_activated(result: World() & W.Status,state: State,+handle: W.Handle<Schema>) -> State:
  match result state:
    case (_,W.Accepted{}) State{factory,world,old,fresh,_,log}: State{factory,world,old,fresh,Some{handle},log ++ "foreign=" ++ key_text(handle) ++ "\n"}
    case (_,_) State{factory,world,old,fresh,foreign,log}: State{factory,world,old,fresh,foreign,log ++ "foreign=activation-refused\n"}
def foreign_reserved(state: State,result: World() & W.Reservation<Schema>) -> State:
  match result:
    case (world,W.Reserved{+handle}): foreign_activated(W.activate(~Schema,~Store(),~Resource,~Unit,world,handle),state,handle)
    case (world,_): state
def foreign_created(world: World(),old: Maybe<&2,W.Handle<Schema>>,fresh: Maybe<&2,W.Handle<Schema>>,foreign: Maybe<&2,W.Handle<Schema>>,log: String,result: W.Creation<Schema,Store(),Resource,Unit>) -> State:
  match result:
    case W.Created{factory,other}: foreign_reserved(State{factory,world,old,fresh,foreign,log},W.reserve_id(~Schema,~Store(),~Resource,~Unit,other))
    case W.CreateRejected{factory,_}: State{factory,world,old,fresh,foreign,log ++ "foreign=create-refused\n"}
def step(command: Command,state: State) -> State:
  match command state:
    case Reserve{slot} State{factory,world,old,fresh,foreign,log}: reserved_slot(W.reserve_id(~Schema,~Store(),~Resource,~Unit,world),slot,factory,old,fresh,foreign,log)
    case Foreign{} State{factory,world,old,fresh,foreign,log}: foreign_created(world,old,fresh,foreign,log,W.create(~Schema,~Store(),~Resource,~Unit,~empty,factory,Resource{ALeaf{999}}))
    case Read{slot,label} State{factory,world,+old,+fresh,+foreign,log}: read_selected(label,State{factory,world,old,fresh,foreign,log},chosen(slot,old,fresh,foreign))
    case Edit{operation,slot,value} State{factory,world,+old,+fresh,+foreign,log}: edit_selected(operation,value,State{factory,world,old,fresh,foreign,log},chosen(slot,old,fresh,foreign))
def resource_done(log: String,clock: Clock.State,result: Array<U32> & U32) -> String:
  match result:
    case (_,value): log ++ "resource=" ++ U32.show(value) ++ ";clock=" ++ Tick.show(Clock.now(clock))
def finish(state: State) -> String:
  match state:
    case State{_,W.World{_,_,_,Resource{token},_,_,_,_,clock},_,_,_,log}: resource_done(log,clock,Array.get(U32,token,0))
def run(commands: List<&2,Command>,state: State) -> String:
  match commands:
    case []: finish(state)
    case command <> rest: run(rest,step(command,state))
def commands() -> List<&2,Command>:
  [Reserve{0},Edit{5,0,0},Edit{0,0,41},Read{0,"pending"},Edit{1,0,0},Read{0,"live1"},Foreign{},Read{2,"foreign-read"},Read{0,"live2"},Edit{2,0,0},Read{0,"dead"},Edit{1,0,0},Read{0,"live3"},Edit{3,0,0},Read{0,"absent"},Edit{2,0,0},Edit{4,0,0},Reserve{1},Edit{5,1,0},Read{1,"pending-reuse"},Edit{0,1,99},Edit{1,1,0},Read{0,"stale1"},Read{1,"fresh1"},Read{0,"stale2"},Read{1,"fresh2"}]
def created(result: W.Creation<Schema,Store(),Resource,Unit>) -> String:
  match result:
    case W.Created{factory,world}: run(commands(),State{factory,world,None{},None{},None{},""})
    case W.CreateRejected{_,_}: "initial=create-refused"
def main() -> IO(Unit): IO.print(created(W.create(~Schema,~Store(),~Resource,~Unit,~empty,W.factory(),Resource{ALeaf{701}})))
