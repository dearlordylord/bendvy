import Base
import ./occupancy.bend as O
import ./storage.bend as W
import ./transaction.bend as X
import ./types.bend as T
import ./payload.bend as P

def World() -> Type: W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>
def Tx() -> Type: X.Tx<World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>>
def position(+v: U32) -> T.Position: T.Position{[v : U32^2n],7}
def world(rows: W.Rows<T.Position,T.Velocity,T.Selected>) -> World():
  W.World{7,2,rows,[W.InsertMain{1,position(99)}],Some{T.MotionLedger{[50 : U32^2n],8}},T.MotionOff{}}
def initial_placed(result: W.Placement<T.Position,T.Velocity,T.Selected>) -> World():
  match result:
    case W.Placed{rows}: world(rows)
    case W.Rejected{rows,_}: world(rows)
def initial() -> World():
  initial_placed(W.rows_place(T.Position,T.Velocity,T.Selected,W.rows_empty(T.Position,T.Velocity,T.Selected),W.Row{1,Some{position(10)},Some{T.Velocity{[3 : U32^2n],True{}}},Some{T.Selected{1}},1,1}))
def write_main(world: World(),handle: W.Handle<T.MotionSchema>,value: U32) -> World() & T.Access<U32>:
  X.storage_set_main0(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,P.position_swap,world,handle,value)
def write_ledger(world: World(),value: U32) -> World() & Maybe<&2,U32>:
  X.storage_set_ledger0(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,P.motion_ledger_swap,world,value)
def restore_main(world: World(),handle: W.Handle<T.MotionSchema>,value: U32) -> World():
  X.storage_restore_main0(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,P.position_swap,world,handle,value)
def restore_ledger(world: World(),value: U32) -> World():
  X.storage_restore_ledger0(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,P.motion_ledger_swap,world,value)
def tx_world_done(label: String,stats: O.TxStats,selected: W.Handle<T.MotionSchema>,undo: List<&2,X.Inverse<W.Handle<T.MotionSchema>>>,commands: List<W.Command<T.Position,T.Velocity,T.Selected>>,pings: List<&2,U32>,marks: List<&2,W.Handle<T.MotionSchema>>,result: World() & O.WorldStats) -> IO(Tx()):
  match result:
    case (world,ws):
      do IO<Tx()>:
        IO.print("metric:" ++ label ++ ":world=" ++ O.format_world(ws) ++ "|tx=" ++ O.format_tx(stats))
        return X.Tx{world,selected,undo,commands,pings,marks}
def tx_done(label: String,result: Tx() & O.TxStats) -> IO(Tx()):
  match result:
    case (X.Tx{world,selected,undo,commands,pings,marks},stats): tx_world_done(label,stats,selected,undo,commands,pings,marks,O.inspect_world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world))
def snapshot_tx(label: String,tx: Tx()) -> IO(Tx()):
  tx_done(label,O.inspect_tx(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,tx))
def world_done(label: String,result: World() & O.WorldStats) -> IO(World()):
  match result:
    case (world,stats):
      do IO<World()>:
        IO.print("metric:" ++ label ++ ":world=" ++ O.format_world(stats))
        return world
def snapshot_world(label: String,world: World()) -> IO(World()):
  world_done(label,O.inspect_world(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world))
def finished(result: X.Finished<World(),W.Command<T.Position,T.Velocity,T.Selected>,W.Handle<T.MotionSchema>>) -> World() & List<&2,U32>:
  X.storage_commit(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,result,20)
def finish_print(label: String,result: World() & List<&2,U32>) -> IO(World()):
  match result:
    case (world,pings):
      do IO<World()>:
        IO.print("trace:" ++ label ++ ":pings=" ++ U32.show(O.length(U32,pings)))
        return world
def read_main(world: World()) -> World() & T.Access<T.PositionView>:
  W.with_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.PositionView,world,W.Handle{7,1},P.position_get)
def position_text(view: T.PositionView) -> String:
  match view:
    case T.PositionView{T.Four{a,b,c,d},frame}: U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ ":" ++ U32.show(frame)
def view_text(view: T.Access<T.PositionView>) -> String:
  match view:
    case T.Found{view}: position_text(view)
    case _: "missing"
def read_print(label: String,result: World() & T.Access<T.PositionView>) -> IO(World()):
  match result:
    case (world,view):
      do IO<World()>:
        IO.print("trace:" ++ label ++ ":" ++ view_text(view))
        return world
def main() -> IO(Unit):
  do IO<Unit>:
    world : World() = initial()
    world : World() <- snapshot_world("initial",world)
    tx : Tx() = X.tx_begin(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,world,W.Handle{7,1})
    tx : Tx() <- snapshot_tx("begin",tx)
    tx : Tx() = X.tx_set_main0(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,write_main,tx,20)
    tx : Tx() <- snapshot_tx("write1",tx)
    tx : Tx() = X.tx_set_main0(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,write_main,tx,30)
    tx : Tx() <- snapshot_tx("write2",tx)
    tx : Tx() = X.tx_set_ledger0(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,write_ledger,tx,60)
    tx : Tx() <- snapshot_tx("ledger",tx)
    tx : Tx() = X.tx_stage_command(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,tx,W.InsertMain{1,position(100)})
    tx : Tx() <- snapshot_tx("command1",tx)
    tx : Tx() = X.tx_stage_command(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,tx,W.InsertMain{1,position(101)})
    tx : Tx() <- snapshot_tx("command2",tx)
    tx : Tx() = X.tx_stage_ping(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,tx,1)
    tx : Tx() <- snapshot_tx("ping1",tx)
    tx : Tx() = X.tx_stage_ping(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,tx,2)
    tx : Tx() <- snapshot_tx("ping2",tx)
    tx : Tx() = X.tx_stage_ping(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,tx,3)
    tx : Tx() <- snapshot_tx("before-failure",tx)
    world : World() <- finish_print("failure",finished(X.tx_finish_failure(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,restore_main,restore_ledger,tx)))
    world : World() <- snapshot_world("after-failure",world)
    world : World() <- read_print("restored",read_main(world))
    tx : Tx() = X.tx_begin(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,world,W.Handle{7,1})
    tx : Tx() = X.tx_stage_command(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,tx,W.InsertMain{1,position(200)})
    tx : Tx() = X.tx_stage_ping(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,tx,4)
    tx : Tx() <- snapshot_tx("before-success",tx)
    world : World() <- finish_print("success",finished(X.tx_finish_success(World(),W.Handle<T.MotionSchema>,W.Command<T.Position,T.Velocity,T.Selected>,tx)))
    world : World() <- snapshot_world("published",world)
    world : World() <- read_print("before-barrier",read_main(world))
    return Unit{}
