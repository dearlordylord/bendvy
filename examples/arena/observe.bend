import Base
import ./schema.bend as D
import ./gameplay.bend as G
import ./root.bend as Root
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/inspector-query.bend as Query
import ../../src/ecs/inspector-query-projection.bend as Rows
import ../../src/ecs/execution-inspector-component.bend as Columns
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/component.bend as Component
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-parallel-root-application.bend as Scheduled
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/world.bend as W

def Ops(H:Type) -> Type:Query.ReadQuery<H,D.Schema,G.Body>
def plan() -> I.Plan<D.Schema,D.Columns(),D.Resources(),Unit,Ops>:
  I.Plan{Columns.query(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~D.components(),~L.AtLeaf{},~{==},~{==},~Rows.Required{})}
def values(rows:List<&2,Rows.Row<D.Schema,G.Body>>,found:List<&2,G.Body>) -> List<&2,G.Body>:
  match rows:
    case []:List.reverse(&2,G.Body,found)
    case Rows.Row{_,I.Value{Component.Found{body},_,_}} <> rest:values(rest,body <> found)
    case _ <> rest:values(rest,found)
def selected(~H:Type,result:H & List<&2,Rows.Row<D.Schema,G.Body>>) -> H & Result<&2,&2,Unit,List<&2,G.Body>>:
  match result:
    case (frame,rows):(frame,Done{values(rows,[])})
def read(~H:Type,caps:Ops(H)) -> H -> H & List<&2,Rows.Row<D.Schema,G.Body>>:
  match caps:
    case Query.ReadQuery{Cap.ValueRead{read},_,_}:read
def body(~H:Type,~caps:Ops(H),_:Unit,frame:H) -> H & Result<&2,&2,Unit,List<&2,G.Body>>:selected(~H,read(~H,caps)(frame))
def observed(rebuild:D.World() -> Root.Application(),result:I.Observed<D.Schema,D.Columns(),D.Resources(),Unit,Unit,List<&2,G.Body>>) -> Root.Application() & Result<&2,&2,Unit,List<&2,G.Body>>:
  match result:
    case I.Observed{world,_,result}:(rebuild(world),result)
def storage(rebuild:General.Storage<D.Schema,D.components(),D.resources(),Unit> -> Root.Application(),storage:General.Storage<D.Schema,D.components(),D.resources(),Unit>) -> Root.Application() & Result<&2,&2,Unit,List<&2,G.Body>>:
  match storage:
    case General.Present{world,displaced}:observed(world => rebuild(General.Present{world,displaced}),I.passive(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~Ops,~Unit,~Unit,~List<&2,G.Body>,~plan(),~body,I.Fresh{},Unit{},world))
    case storage:(rebuild(storage),Fail{Unit{}})
def snapshot(app:Root.Application()) -> Root.Application() & Result<&2,&2,Unit,List<&2,G.Body>>:
  match app:
    case Scheduled.Scheduled{App.State{world,nodes,guards,handler,stateBindings},plan,bindings,rules,deferred}:storage(world => Scheduled.Scheduled{App.State{world,nodes,guards,handler,stateBindings},plan,bindings,rules,deferred},world)
