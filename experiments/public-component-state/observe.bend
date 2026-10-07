import Base
import state.bend as V
import schema.bend as S
import ../../src/ecs/component.bend as C
import ../../src/ecs/world.bend as W

def phase(value: C.Access<V.Phase>) -> String:
  match value:
    case C.Found{value}: U32.show(V.phase_code(value))
    case _: "null"
def mode(value: C.Access<V.Mode>) -> String:
  match value:
    case C.Found{value}: U32.show(V.mode_code(value))
    case _: "null"
def cells(values: List<&2,U32>) -> String:
  match values:
    case []: ""
    case value <> []: U32.show(value)
    case value <> rest: U32.show(value) ++ "," ++ cells(rest)
def neighbor(value: C.Access<S.NeighborView>) -> String:
  match value:
    case C.Found{S.NeighborView{values}}: "[" ++ cells(values) ++ "]"
    case _: "null"
def row_neighbor(~Schema: Data,+p: String,+m: String,observed: W.World<Schema,S.Store<Schema>,Unit,Unit> & C.Access<S.NeighborView>) -> W.World<Schema,S.Store<Schema>,Unit,Unit> & String:
  (world,value) = observed
  (world,"[" ++ p ++ "," ++ m ++ "," ++ neighbor(value) ++ "]")
def row_mode(~Schema: Data,+handle: W.Handle<Schema>,+p: String,observed: W.World<Schema,S.Store<Schema>,Unit,Unit> & C.Access<V.Mode>) -> W.World<Schema,S.Store<Schema>,Unit,Unit> & String:
  (world,value) = observed
  row_neighbor(~Schema,p,mode(value),S.get_neighbor(~Schema,world,handle))
def row_phase(~Schema: Data,+handle: W.Handle<Schema>,observed: W.World<Schema,S.Store<Schema>,Unit,Unit> & C.Access<V.Phase>) -> W.World<Schema,S.Store<Schema>,Unit,Unit> & String:
  (world,value) = observed
  row_mode(~Schema,handle,phase(value),S.get_mode(~Schema,world,handle))
def row(~Schema: Data,world: W.World<Schema,S.Store<Schema>,Unit,Unit>,+handle: W.Handle<Schema>) -> W.World<Schema,S.Store<Schema>,Unit,Unit> & String:
  row_phase(~Schema,handle,S.get_phase(~Schema,world,handle))
def rows_tail(~Schema: Data,+namespace: U32,+first: String,observed: W.World<Schema,S.Store<Schema>,Unit,Unit> & String) -> W.World<Schema,S.Store<Schema>,Unit,Unit> & String:
  (world,+second) = observed
  (world,"[" ++ first ++ "," ++ second ++ "]")
def rows_head(~Schema: Data,+namespace: U32,observed: W.World<Schema,S.Store<Schema>,Unit,Unit> & String) -> W.World<Schema,S.Store<Schema>,Unit,Unit> & String:
  (world,+first) = observed
  rows_tail(~Schema,namespace,first,row(~Schema,world,W.Handle{namespace,2}))
def rows_namespace(~Schema: Data,observed: W.World<Schema,S.Store<Schema>,Unit,Unit> & U32) -> W.World<Schema,S.Store<Schema>,Unit,Unit> & String:
  (world,+namespace) = observed
  rows_head(~Schema,namespace,row(~Schema,world,W.Handle{namespace,1}))
def rows(~Schema: Data,world: W.World<Schema,S.Store<Schema>,Unit,Unit>) -> W.World<Schema,S.Store<Schema>,Unit,Unit> & String:
  rows_namespace(~Schema,W.namespace(~Schema,~S.Store<Schema>,~Unit,~Unit,world))
