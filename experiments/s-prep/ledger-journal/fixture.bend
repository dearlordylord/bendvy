import Base
import ../../s-integrate/types.bend as T
import ./original.bend as O
import ./journal.bend as N

type World is Type:
  World{main: Array<U32>, ledger: Maybe<Array<U32>>}
def main_written(ledger: Maybe<Array<U32>>,result: Array<U32> & U32) -> World & T.Access<U32>:
  match result:
    case (main,old): (World{main,ledger},T.Found{old})
def write_main(world: World,id: U32,value: U32) -> World & T.Access<U32>:
  match world:
    case World{main,ledger}: main_written(ledger,Array.swap(U32,main,id,value))
def ledger_written(main: Array<U32>,result: Array<U32> & U32) -> World & Maybe<&2,U32>:
  match result:
    case (ledger,old): (World{main,Some{ledger}},Some{old})
def write_ledger(world: World,value: U32) -> World & Maybe<&2,U32>:
  match world:
    case World{main,None{}}: (World{main,None{}},None{})
    case World{main,Some{ledger}}: ledger_written(main,Array.swap(U32,ledger,0,value))
def ledger_read(main: Array<U32>,result: Array<U32> & U32) -> World & Maybe<&2,U32>:
  match result:
    case (ledger,value): (World{main,Some{ledger}},Some{value})
def read_ledger(world: World) -> World & Maybe<&2,U32>:
  match world:
    case World{main,None{}}: (World{main,None{}},None{})
    case World{main,Some{ledger}}: ledger_read(main,Array.get(U32,ledger,0))
def restored_main(result: World & T.Access<U32>) -> World:
  match result:
    case (world,_): world
def restore_main(world: World,id: U32,value: U32) -> World:
  restored_main(write_main(world,id,value))
def restored_ledger(result: World & Maybe<&2,U32>) -> World:
  match result:
    case (world,_): world
def restore_ledger(world: World,value: U32) -> World:
  restored_ledger(write_ledger(world,value))
def maybe_show(value: Maybe<&2,U32>) -> String:
  match value:
    case None{}: "none"
    case Some{value}: U32.show(value)
def dump_ledger(prefix: String,ledger: Maybe<Array<U32>>) -> String:
  match ledger:
    case None{}: prefix ++ "none"
    case Some{ledger}: prefix ++ List.show(&1,U32,U32.show,Array.to_list(U32,ledger))
def dump(world: World) -> String:
  match world:
    case World{main,ledger}: dump_ledger(List.show(&1,U32,U32.show,Array.to_list(U32,main)) ++ ":",ledger)
def o_select(owner: O.Tx<World,U32,U32>,id: U32) -> O.Tx<World,U32,U32>:
  match owner:
    case O.Tx{world,_,undo,commands,pings,marks}: O.Tx{world,id,undo,commands,pings,marks}
def o_finished(trace: String,result: O.Finished<World,U32,U32>) -> String:
  match result:
    case O.Committed{world,commands,pings,marks}: trace ++ ":" ++ dump(world) ++ ":" ++ List.show(&2,U32,U32.show,marks) ++ ":" ++ List.show(&1,U32,U32.show,commands) ++ ":" ++ List.show(&2,U32,U32.show,pings)
    case O.Reverted{world}: trace ++ ":" ++ dump(world) ++ ":[]:[]:[]"
def o_finish(fail: Bool,trace: String,owner: O.Tx<World,U32,U32>) -> String:
  match fail:
    case False{}: o_finished(trace,O.tx_finish_success(World,U32,U32,owner))
    case True{}: o_finished(trace,O.tx_finish_failure(World,U32,U32,restore_main,restore_ledger,owner))
def o_read2(fail: Bool,trace: String,result: O.Tx<World,U32,U32> & Maybe<&2,U32>) -> String:
  match result:
    case (owner,value): o_finish(fail,trace ++ "," ++ maybe_show(value),O.tx_set_main0(World,U32,U32,write_main,o_select(owner,0),44))
def o_read1(fail: Bool,result: O.Tx<World,U32,U32> & Maybe<&2,U32>) -> String:
  match result:
    case (owner,value): o_read2(fail,maybe_show(value),O.tx_read_ledger(World,U32,U32,U32,read_ledger,O.tx_set_ledger0(World,U32,U32,write_ledger,O.tx_set_main0(World,U32,U32,write_main,o_select(O.tx_set_ledger0(World,U32,U32,write_ledger,owner,202),1),22),303)))
def o_run(fail: Bool,world: World) -> String:
  o_read1(fail,O.tx_read_ledger(World,U32,U32,U32,read_ledger,O.tx_set_ledger0(World,U32,U32,write_ledger,O.tx_set_main0(World,U32,U32,write_main,O.tx_stage_ping(World,U32,U32,O.tx_stage_command(World,U32,U32,O.tx_begin(World,U32,U32,world,0),9),7),11),101)))
def n_select(owner: N.Journal<World,U32,U32>,id: U32) -> N.Journal<World,U32,U32>:
  match owner:
    case N.Journal{N.Tx{world,_,undo,commands,pings,marks},saved}: N.Journal{N.Tx{world,id,undo,commands,pings,marks},saved}
def n_finished(trace: String,result: N.Finished<World,U32,U32>) -> String:
  match result:
    case N.Committed{world,commands,pings,marks}: trace ++ ":" ++ dump(world) ++ ":" ++ List.show(&2,U32,U32.show,marks) ++ ":" ++ List.show(&1,U32,U32.show,commands) ++ ":" ++ List.show(&2,U32,U32.show,pings)
    case N.Reverted{world}: trace ++ ":" ++ dump(world) ++ ":[]:[]:[]"
def n_finish(fail: Bool,trace: String,owner: N.Journal<World,U32,U32>) -> String:
  match fail:
    case False{}: n_finished(trace,N.j_success(World,U32,U32,owner))
    case True{}: n_finished(trace,N.j_failure(World,U32,U32,restore_main,restore_ledger,owner))
def n_read2(fail: Bool,trace: String,result: N.Journal<World,U32,U32> & Maybe<&2,U32>) -> String:
  match result:
    case (owner,value): n_finish(fail,trace ++ "," ++ maybe_show(value),N.j_main(World,U32,U32,write_main,n_select(owner,0),44))
def n_read1(fail: Bool,result: N.Journal<World,U32,U32> & Maybe<&2,U32>) -> String:
  match result:
    case (owner,value): n_read2(fail,maybe_show(value),N.j_read_ledger(World,U32,U32,U32,read_ledger,N.j_ledger(World,U32,U32,write_ledger,N.j_main(World,U32,U32,write_main,n_select(N.j_ledger(World,U32,U32,write_ledger,owner,202),1),22),303)))
def n_run(fail: Bool,world: World) -> String:
  n_read1(fail,N.j_read_ledger(World,U32,U32,U32,read_ledger,N.j_ledger(World,U32,U32,write_ledger,N.j_main(World,U32,U32,write_main,N.j_ping(World,U32,U32,N.j_command(World,U32,U32,N.j_begin(World,U32,U32,world,0),9),7),11),101)))
def world(present: Bool) -> World:
  match present:
    case False{}: World{ANode{ANode{ALeaf{1},ALeaf{2}},ANode{ALeaf{3},ALeaf{4}}},None{}}
    case True{}: World{ANode{ANode{ALeaf{1},ALeaf{2}},ANode{ALeaf{3},ALeaf{4}}},Some{ANode{ANode{ALeaf{5},ALeaf{6}},ANode{ALeaf{7},ALeaf{8}}}}}
def cross_read(id: U32,value: U32,result: World & Maybe<&2,U32>) -> World:
  match result:
    case (world,None{}): restore_main(world,id,value)
    case (world,Some{ledger}): restore_main(world,id,U32.add(value,ledger))
def restore_main_cross(world: World,id: U32,value: U32) -> World:
  cross_read(id,value,read_ledger(world))

def oc_select(owner: O.Tx<World,U32,U32>,id: U32) -> O.Tx<World,U32,U32>:
  match owner:
    case O.Tx{world,_,undo,commands,pings,marks}: O.Tx{world,id,undo,commands,pings,marks}
def oc_finished(trace: String,result: O.Finished<World,U32,U32>) -> String:
  match result:
    case O.Committed{world,commands,pings,marks}: trace ++ ":" ++ dump(world) ++ ":" ++ List.show(&2,U32,U32.show,marks) ++ ":" ++ List.show(&1,U32,U32.show,commands) ++ ":" ++ List.show(&2,U32,U32.show,pings)
    case O.Reverted{world}: trace ++ ":" ++ dump(world) ++ ":[]:[]:[]"
def oc_finish(fail: Bool,trace: String,owner: O.Tx<World,U32,U32>) -> String:
  match fail:
    case False{}: oc_finished(trace,O.tx_finish_success(World,U32,U32,owner))
    case True{}: oc_finished(trace,O.tx_finish_failure(World,U32,U32,restore_main_cross,restore_ledger,owner))
def oc_read2(fail: Bool,trace: String,result: O.Tx<World,U32,U32> & Maybe<&2,U32>) -> String:
  match result:
    case (owner,value): oc_finish(fail,trace ++ "," ++ maybe_show(value),O.tx_set_main0(World,U32,U32,write_main,oc_select(owner,0),44))
def oc_read1(fail: Bool,result: O.Tx<World,U32,U32> & Maybe<&2,U32>) -> String:
  match result:
    case (owner,value): oc_read2(fail,maybe_show(value),O.tx_read_ledger(World,U32,U32,U32,read_ledger,O.tx_set_ledger0(World,U32,U32,write_ledger,O.tx_set_main0(World,U32,U32,write_main,oc_select(O.tx_set_ledger0(World,U32,U32,write_ledger,owner,202),1),22),303)))
def oc_run(fail: Bool,world: World) -> String:
  oc_read1(fail,O.tx_read_ledger(World,U32,U32,U32,read_ledger,O.tx_set_ledger0(World,U32,U32,write_ledger,O.tx_set_main0(World,U32,U32,write_main,O.tx_stage_ping(World,U32,U32,O.tx_stage_command(World,U32,U32,O.tx_begin(World,U32,U32,world,0),9),7),11),101)))
def nc_select(owner: N.Journal<World,U32,U32>,id: U32) -> N.Journal<World,U32,U32>:
  match owner:
    case N.Journal{N.Tx{world,_,undo,commands,pings,marks},saved}: N.Journal{N.Tx{world,id,undo,commands,pings,marks},saved}
def nc_finished(trace: String,result: N.Finished<World,U32,U32>) -> String:
  match result:
    case N.Committed{world,commands,pings,marks}: trace ++ ":" ++ dump(world) ++ ":" ++ List.show(&2,U32,U32.show,marks) ++ ":" ++ List.show(&1,U32,U32.show,commands) ++ ":" ++ List.show(&2,U32,U32.show,pings)
    case N.Reverted{world}: trace ++ ":" ++ dump(world) ++ ":[]:[]:[]"
def nc_finish(fail: Bool,trace: String,owner: N.Journal<World,U32,U32>) -> String:
  match fail:
    case False{}: nc_finished(trace,N.j_success(World,U32,U32,owner))
    case True{}: nc_finished(trace,N.j_failure(World,U32,U32,restore_main_cross,restore_ledger,owner))
def nc_read2(fail: Bool,trace: String,result: N.Journal<World,U32,U32> & Maybe<&2,U32>) -> String:
  match result:
    case (owner,value): nc_finish(fail,trace ++ "," ++ maybe_show(value),N.j_main(World,U32,U32,write_main,nc_select(owner,0),44))
def nc_read1(fail: Bool,result: N.Journal<World,U32,U32> & Maybe<&2,U32>) -> String:
  match result:
    case (owner,value): nc_read2(fail,maybe_show(value),N.j_read_ledger(World,U32,U32,U32,read_ledger,N.j_ledger(World,U32,U32,write_ledger,N.j_main(World,U32,U32,write_main,nc_select(N.j_ledger(World,U32,U32,write_ledger,owner,202),1),22),303)))
def nc_run(fail: Bool,world: World) -> String:
  nc_read1(fail,N.j_read_ledger(World,U32,U32,U32,read_ledger,N.j_ledger(World,U32,U32,write_ledger,N.j_main(World,U32,U32,write_main,N.j_ping(World,U32,U32,N.j_command(World,U32,U32,N.j_begin(World,U32,U32,world,0),9),7),11),101)))
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(o_run(False{},world(True{})))
    IO.print(n_run(False{},world(True{})))
    IO.print(o_run(True{},world(True{})))
    IO.print(n_run(True{},world(True{})))
    IO.print(o_run(False{},world(False{})))
    IO.print(n_run(False{},world(False{})))
    IO.print(o_run(True{},world(False{})))
    IO.print(n_run(True{},world(False{})))
    IO.print(oc_run(True{},world(True{})))
    IO.print(nc_run(True{},world(True{})))
