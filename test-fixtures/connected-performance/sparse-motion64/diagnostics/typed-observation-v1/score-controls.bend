import Base
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-scans.bend as S
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/motion-logical.bend as L
import ../../consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../src/ecs/inspector-query-projection.bend as P
import ../../../../../src/ecs/component.bend as C
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/entity-key.bend as K

def row(index:U32,aux:C.Access<T.VelocityView>) -> IQ.ProjectedRow<T.MotionSchema,L.Value()>:
  IQ.ProjectedRow{W.Handle{1,K.EntityKey{index,3}},P.Product{C.ComponentAbsent{},P.Product{aux,C.ComponentAbsent{}}}}
def absent(index:U32) -> IQ.ProjectedRow<T.MotionSchema,L.Value()>:row(index,C.ComponentAbsent{})
def rows() -> L.Rows():[absent(10),row(20,C.Found{T.VelocityView{T.Four{0,0,0,0},False{}}}),absent(30)]
def four(value:T.Four) -> String:
  match value:
    case T.Four{a,b,c,d}:U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d)
def main_text(value:C.Access<T.PositionView>) -> String:
  match value:
    case C.MissingEntity{}:"M"
    case C.ComponentAbsent{}:"A"
    case C.Found{T.PositionView{cells,frame}}:"F(" ++ four(cells) ++ "/" ++ U32.show(frame) ++ ")"
def bool_text(value:Bool) -> String:
  match value:
    case False{}:"0"
    case True{}:"1"
def aux_text(value:C.Access<T.VelocityView>) -> String:
  match value:
    case C.MissingEntity{}:"M"
    case C.ComponentAbsent{}:"A"
    case C.Found{T.VelocityView{cells,moving}}:"F(" ++ four(cells) ++ "/" ++ bool_text(moving) ++ ")"
def flag_text(value:C.Access<T.Selected>) -> String:
  match value:
    case C.MissingEntity{}:"M"
    case C.ComponentAbsent{}:"A"
    case C.Found{T.Selected{group}}:"F(" ++ U32.show(group) ++ ")"
def row_text(value:IQ.ProjectedRow<T.MotionSchema,L.Value()>) -> String:
  match value:
    case IQ.ProjectedRow{W.Handle{namespace,K.EntityKey{index,generation}},P.Product{main,P.Product{aux,flag}}}:U32.show(namespace) ++ "/" ++ U32.show(index) ++ "/" ++ U32.show(generation) ++ ":" ++ main_text(main) ++ ":" ++ aux_text(aux) ++ ":" ++ flag_text(flag)
def observed(name:String,result:L.Rows() & U32) -> IO(Unit):
  match result:
    case (rows,score):IO.print(name ++ ":" ++ U32.show(score) ++ "|" ++ List.show(~&2,~IQ.ProjectedRow<T.MotionSchema,L.Value()>,~(row => row_text(row)),rows))
def main() -> IO(Unit):
  do IO<Unit>:
    observed("all",S.score_rows(rows(),0,2,7,[absent(90)]))
    observed("present",S.score_rows(rows(),1,2,7,[absent(90)]))
    observed("absent",S.score_rows(rows(),2,2,7,[absent(90)]))
    observed("other",S.score_rows(rows(),7,2,7,[absent(90)]))
    observed("empty",S.score_rows([],2,4294967295,2,[absent(90),absent(80)]))
    observed("wrap",S.score_rows([absent(10),row(20,C.Found{T.VelocityView{T.Four{0,0,0,0},False{}}})],0,4294967295,4294967295,[]))
    observed("present-wrap",S.score_rows(rows(),1,4294967295,4294967295,[]))
