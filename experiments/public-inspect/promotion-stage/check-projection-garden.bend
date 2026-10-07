import Base
import condition.bend as Check
import ../bend-candidate/query-consumer.bend as A
import check-state-garden.bend as R
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/string-equality.bend as SE

# Diagnostic projection is separate from the public Bool callback boundary.
# The actual detached snapshot is supplied as callback args; no expected
# literals are used to produce or validate these rows or resource cells.
type Reads<H:Type> is Type:
  Reads{rows:Cap.ValueRead<H,List<&2,Check.Row<A.Schema,List<&2,U32>>>>,score:Cap.ValueRead<H,List<&2,U32>>}
type Snapshot is Data:
  Snapshot{rows:List<&2,Check.Row<A.Schema,List<&2,U32>>>,score:List<&2,U32>}
def Ops(H:Type) -> Type:
  Reads<H>
def rows(~H:Type,caps:Reads<H>) -> Cap.ValueRead<H,List<&2,Check.Row<A.Schema,List<&2,U32>>>>:
  match caps:
    case Reads{rows,_}:rows
def score(~H:Type,caps:Reads<H>) -> Cap.ValueRead<H,List<&2,U32>>:
  match caps:
    case Reads{_,score}:score
def grants() -> Reads<Check.Frame<A.Schema,A.Store,R.Resources,U32>>:
  Reads{Check.query_grant(~A.Schema,~A.Store,~R.Resources,~U32,~Unit,~A.Payload,~List<&2,U32>,~A.Token,~A.take,~A.put,~A.project,~A.family(),~Check.Required{}),Check.resource_grant(~A.Schema,~A.Store,~R.Resources,~U32,~List<&2,U32>,~R.project_score)}
def required(world:W.World<A.Schema,A.Store,R.Resources,U32>) -> W.World<A.Schema,A.Store,R.Resources,U32> & List<&2,String>:
  R.required(world)
def plan() -> Check.Plan<A.Schema,A.Store,R.Resources,U32,Ops>:
  Check.Plan{required,grants()}
def scored(~H:Type,rows:List<&2,Check.Row<A.Schema,List<&2,U32>>>,result:H & List<&2,U32>) -> H & Snapshot:
  (owner,score)=result
  (owner,Snapshot{rows,score})
def queried(~H:Type,~caps:Reads<H>,result:H & List<&2,Check.Row<A.Schema,List<&2,U32>>>) -> H & Snapshot:
  (owner,rows)=result
  scored(~H,rows,Cap.value_read(~H,~List<&2,U32>,~score(~H,caps),owner))
def project(~H:Type,~caps:Reads<H>,owner:H) -> H & Snapshot:
  queried(~H,~caps,Cap.value_read(~H,~List<&2,Check.Row<A.Schema,List<&2,U32>>>,~rows(~H,caps),owner))
def access(value:C.Access<List<&2,U32>>) -> String:
  match value:
    case C.Found{values}:List.show(&2,U32,U32.show,values)
    case C.ComponentAbsent{}:"absent"
    case C.MissingEntity{}:"missing"
def row(value:Check.Row<A.Schema,List<&2,U32>>) -> String:
  match value:
    case Check.Row{W.Handle{namespace,id},value}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ access(value)
def shown(value:Snapshot) -> String:
  match value:
    case Snapshot{rows,score}:"rows=" ++ List.show(&2,Check.Row<A.Schema,List<&2,U32>>,row,rows) ++ "|score=" ++ List.show(&2,U32,U32.show,score)
def compared(~H:Type,snapshot:Snapshot,result:H & Snapshot) -> H & Bool:
  (owner,actual)=result
  (owner,SE.equal(shown(snapshot),shown(actual)))
def body(~H:Type,~caps:Reads<H>,snapshot:Snapshot,owner:H) -> H & Bool:
  compared(~H,snapshot,project(~H,~caps,owner))
def detached(result:Check.Frame<A.Schema,A.Store,R.Resources,U32> & Snapshot) -> W.World<A.Schema,A.Store,R.Resources,U32> & Snapshot:
  match result:
    case (Check.Frame{world},snapshot):(world,snapshot)
def observe(world:W.World<A.Schema,A.Store,R.Resources,U32>) -> W.World<A.Schema,A.Store,R.Resources,U32> & Snapshot:
  detached(project(~Check.Frame<A.Schema,A.Store,R.Resources,U32>,~grants(),Check.Frame{world}))
def run(snapshot:Snapshot,world:W.World<A.Schema,A.Store,R.Resources,U32>) -> Check.Checked<A.Schema,A.Store,R.Resources,U32>:
  Check.run(~A.Schema,~A.Store,~R.Resources,~U32,~Ops,~Snapshot,~body,~plan(),snapshot,world)
