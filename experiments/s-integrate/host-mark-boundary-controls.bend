import Base
import ./types.bend as T
import ./storage.bend as W
import ./observations.bend as O
import ./host.bend as H
import ./storage-stage-fixture.bend as F

def query() -> List<&2,O.QueryRow<T.MotionSchema,Bool,Bool,T.Selected>>:
  [O.QueryRow{W.Handle{1,1},True{},Some{True{}},Some{T.Selected{8}}},O.QueryRow{W.Handle{1,3},False{},None{},None{}},O.QueryRow{W.Handle{1,4},True{},Some{False{}},Some{T.Selected{9}}}]
def rows() -> List<&2,O.RowView<Bool,Bool,T.Selected>>:
  [O.RowView{1,Some{True{}},Some{True{}},Some{T.Selected{8}},1,5},O.RowView{2,None{},Some{False{}},None{},2,4},O.RowView{4,Some{True{}},Some{False{}},Some{T.Selected{9}},3,7}]
def row(value:O.QueryRow<T.MotionSchema,Bool,Bool,T.Selected>) -> String:
  match value:
    case O.QueryRow{W.Handle{ns,id},m,a,f}: U32.show(ns) ++ ":" ++ U32.show(id) ++ "|" ++ F.bool(m) ++ "|" ++ Maybe.show(&2,Bool,F.bool,a) ++ "|" ++ Maybe.show(&2,T.Selected,F.selected,f)
def show(changed:Bool,since:U32,now:U32) -> String:
  List.show(&2,O.QueryRow<T.MotionSchema,Bool,Bool,T.Selected>,row,H.filter_mark(T.MotionSchema,Bool,Bool,T.Selected,rows(),changed,since,now,query()))
def main() -> String:
  show(False{},1,5) ++ "\n" ++ show(True{},1,5) ++ "\n" ++ show(False{},0,2) ++ "\n" ++ show(True{},0,7) ++ "\n" ++ show(True{},5,7) ++ "\n" ++ show(False{},0,0)
