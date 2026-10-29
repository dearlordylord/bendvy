import Base
import ./schema.bend as D
import ./components.bend as V
import ./root.bend as Root
import ../../src/ecs/world.bend as W
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
import ../../src/ecs/entity-key.bend as Key

type Reads<-H:Type> is Type:
  Reads{health:Query.ReadQuery<H,D.Schema,V.Health>,decay:I.Lookup<H,D.Schema,V.HealthDecay>}
type Snapshot is Data: Snapshot{selected:String,untouched:String,entities:String}
def Ops(H:Type) -> Type:Reads<H>
def plan() -> I.Plan<D.Schema,D.Columns(),D.Resources(),Unit,Ops>:
  I.Plan{Reads{Columns.query(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~D.components(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Rows.Required{}),Columns.lookup(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~D.components(),~L.InRight{L.AtLeaf{}},~{==},~{==})}}
def append(left:String,right:String) -> String:
  match left:
    case "":right
    case left:left ++ "," ++ right
def decay_read(~H:Type,caps:Ops(H)) -> H -> W.Handle<D.Schema> -> H & I.Value<V.HealthDecay>:
  match caps:
    case Reads{_,I.Lookup{read}}:read
def health_rows(~H:Type,caps:Ops(H)) -> H -> H & List<&2,Rows.Row<D.Schema,V.Health>>:
  match caps:
    case Reads{Query.ReadQuery{Cap.ValueRead{read},_,_},_}:read
def json(handle:W.Handle<D.Schema>,value:F32,decay:String) -> String:
  match handle:
    case W.Handle{_,id}:"{\"id\":" ++ U32.show(Key.index(id)) ++ ",\"health\":" ++ F32.show(value) ++ ",\"decay\":" ++ decay ++ "}"
def classified(~H:Type,next:H -> String -> String -> String -> H & Result<&2,&2,Unit,Snapshot>,handle:W.Handle<D.Schema>,+value:F32,selected:String,untouched:String,entities:String,result:H & I.Value<V.HealthDecay>) -> H & Result<&2,&2,Unit,Snapshot>:
  match result:
    case (frame,I.Value{Component.Found{V.HealthDecay{factor}},_,_}):next(frame,append(selected,F32.show(value)),untouched,append(entities,json(handle,value,F32.show(factor))))
    case (frame,I.Value{Component.ComponentAbsent{},_,_}):next(frame,selected,append(untouched,F32.show(value)),append(entities,json(handle,value,"null")))
    case (frame,_):(frame,Fail{Unit{}})
def values(~H:Type,~get:H -> W.Handle<D.Schema> -> H & I.Value<V.HealthDecay>,rows:List<&2,Rows.Row<D.Schema,V.Health>>,frame:H,selected:String,untouched:String,entities:String) -> H & Result<&2,&2,Unit,Snapshot>:
  match rows:
    case []:(frame,Done{Snapshot{selected,untouched,entities}})
    case Rows.Row{+handle,I.Value{Component.Found{V.Health{value}},_,_}} <> rest:classified(~H,frame => selected => untouched => entities => values(~H,~get,rest,frame,selected,untouched,entities),handle,value,selected,untouched,entities,get(frame,handle))
    case _ <> rest:values(~H,~get,rest,frame,selected,untouched,entities)
def selected(~H:Type,~get:H -> W.Handle<D.Schema> -> H & I.Value<V.HealthDecay>,result:H & List<&2,Rows.Row<D.Schema,V.Health>>) -> H & Result<&2,&2,Unit,Snapshot>:
  match result:
    case (frame,rows):values(~H,~get,rows,frame,"","","")
def body(~H:Type,~caps:Ops(H),_:Unit,frame:H) -> H & Result<&2,&2,Unit,Snapshot>:
  selected(~H,~decay_read(~H,caps),health_rows(~H,caps)(frame))
def observed(rebuild:D.World() -> Root.Application(),result:I.Observed<D.Schema,D.Columns(),D.Resources(),Unit,Unit,Snapshot>) -> Root.Application() & (I.Instance<D.Schema> & Result<&2,&2,Unit,Snapshot>):
  match result:
    case I.Observed{world,instance,result}:(rebuild(world),(instance,result))
def storage(rebuild:General.Storage<D.Schema,D.components(),D.resources(),Unit> -> Root.Application(),instance:I.Instance<D.Schema>,storage:General.Storage<D.Schema,D.components(),D.resources(),Unit>) -> Root.Application() & (I.Instance<D.Schema> & Result<&2,&2,Unit,Snapshot>):
  match storage:
    case General.Present{world,displaced}:observed(world => rebuild(General.Present{world,displaced}),I.passive(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~Ops,~Unit,~Unit,~(Snapshot),~plan(),~body,instance,Unit{},world))
    case storage:(rebuild(storage),(instance,Fail{Unit{}}))
def snapshot(app:Root.Application(),instance:I.Instance<D.Schema>) -> Root.Application() & (I.Instance<D.Schema> & Result<&2,&2,Unit,Snapshot>):
  match app:
    case Scheduled.Scheduled{App.State{world,nodes,guards,handler,stateBindings},plan,bindings,rules,deferred}:storage(world => Scheduled.Scheduled{App.State{world,nodes,guards,handler,stateBindings},plan,bindings,rules,deferred},instance,world)
