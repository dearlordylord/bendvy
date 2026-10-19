import Base
import motion.bend as F
import motion-logical.bend as Logical
import ../../../../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/test-fixtures/connected-performance/dense-motion64/consumer/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../../../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/inspector-query.bend as IQ
import ../../../../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/inspector-query-projection.bend as P
import ../../../../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/component.bend as Cmp
import ../../../../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/world.bend as W
import ../../../../../../../../../../../bendvy21-occupancy-history-transport/test-fixtures/connected-performance/dense-health64/diagnostics/occupancy-v1/private/src/ecs/entity-key.bend as Key

type Scan is Data:
  Scan{rows:Logical.Rows(),included:Logical.Rows(),score:U32}
type Results is Data:
  Results{all:Scan,present:Scan,absent:Scan,weighted:U32}
def boolnum(value:Bool) -> U32:
  match value:
    case False{}:0
    case True{}:1
def main_sum(value:Cmp.Access<T.PositionView>) -> U32:
  match value:
    case Cmp.Found{T.PositionView{cells,frame}}:U32.add(F.sum(cells),frame)
    case _:0
def aux_sum(value:Cmp.Access<T.VelocityView>) -> U32:
  match value:
    case Cmp.Found{T.VelocityView{cells,moving}}:U32.add(F.sum(cells),U32.add(boolnum(moving),1))
    case _:0
def flag_sum(value:Cmp.Access<T.Selected>) -> U32:
  match value:
    case Cmp.Found{T.Selected{group}}:U32.add(group,1)
    case _:0
def has_aux(value:Cmp.Access<T.VelocityView>) -> Bool:
  match value:
    case Cmp.Found{_}:True{}
    case _:False{}
def row_sum(value:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>) -> U32:
  match value:
    case IQ.ProjectedRow{W.Handle{namespace,key},P.Product{main,P.Product{aux,flag}}}:U32.add(U32.add(namespace,Key.index(key)),U32.add(main_sum(main),U32.add(aux_sum(aux),flag_sum(flag))))
def included(kind:U32,value:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>) -> Bool:
  match kind value:
    case 1 IQ.ProjectedRow{_,P.Product{_,P.Product{aux,_}}}:has_aux(aux)
    case 2 IQ.ProjectedRow{_,P.Product{_,P.Product{aux,_}}}:Bool.not(has_aux(aux))
    case _ _:True{}
def include_step(next:U32 -> U32 -> Logical.Rows() -> Logical.Rows() & U32,keep:Bool,+row:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,+rank:U32,total:U32,reverseRows:Logical.Rows()) -> Logical.Rows() & U32:
  match keep:
    case False{}:next(rank,total,reverseRows)
    case True{}:next(U32.add(rank,1),U32.add(total,U32.mul(rank,row_sum(row))),row <> reverseRows)
def score_rows(rows:Logical.Rows(),+kind:U32,+rank:U32,total:U32,reverseRows:Logical.Rows()) -> Logical.Rows() & U32:
  match rows:
    case []:(List.reverse(&2,IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,reverseRows),U32.add(total,rank))
    case +row <> rest:include_step(r => t => xs => score_rows(rest,kind,r,t,xs),included(kind,row),row,rank,total,reverseRows)
def scored(rows:Logical.Rows(),observed:Logical.Rows() & U32) -> Scan:
  match observed:
    case (included,total):Scan{rows,included,total}
def scan(kind:U32,+rows:Logical.Rows()) -> Scan:scored(rows,score_rows(rows,kind,1,0,[]))
def score(value:Scan) -> U32:
  match value:
    case Scan{_,_,score}:score
def third_scored(world:F.World(),+all:Scan,+present:Scan,+absent:Scan) -> F.World() & Results:
  (world,Results{all,present,absent,U32.add(score(all),U32.add(U32.mul(3,score(present)),U32.mul(5,score(absent))))})
def third(+all:Scan,+present:Scan,observed:F.World() & Logical.Rows()) -> F.World() & Results:
  match observed:
    case (world,rows):third_scored(world,all,present,scan(2,rows))
def second(all:Scan,observed:F.World() & Logical.Rows()) -> F.World() & Results:
  match observed:
    case (world,rows):third(all,scan(1,rows),Logical.rows(world))
def first(observed:F.World() & Logical.Rows()) -> F.World() & Results:
  match observed:
    case (world,rows):second(scan(0,rows),Logical.rows(world))
def run(world:F.World()) -> F.World() & Results:first(Logical.rows(world))

def weighted(value:Results) -> U32:
  match value:
    case Results{_,_,_,weighted}:weighted
