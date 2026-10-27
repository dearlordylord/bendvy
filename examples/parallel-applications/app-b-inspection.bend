import Base
import ./app-b-schema.bend as D
import ./app-b-commands.bend as Author
import ./app-b-application.bend as App
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/inspector-query.bend as Query
import ../../src/ecs/inspector-query-projection.bend as Rows
import ../../src/ecs/component.bend as Component
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-inspector.bend as Modern
import ../../src/ecs/execution-inspector-component.bend as Columns
import ../../src/ecs/execution-inspector-application.bend as Passive
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/machine.bend as M
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/world.bend as W

def Parent() -> Data:Store.View<D.Scene,D.parent()>
def Link() -> Data:Store.View<D.Scene,D.link()>
def Phase() -> Data:State.View<D.Scene,D.PhaseToken,U32>
type Reads<-H:Type> is Type:
  Reads{parent:Cap.ValueRead<H,Parent()>,link:Cap.ValueRead<H,Link()>,phase:Cap.ValueRead<H,Phase()>,arrays:Query.ReadQuery<H,D.Scene,List<&2,U32>>,scalars:Query.ReadQuery<H,D.Scene,U32>}
def Ops(H:Type) -> Type:Reads<H>
def plan() -> I.Plan<D.Scene,App.Columns(),App.Resources(),Unit,Ops>:
  I.Plan{Reads{Modern.resource_grant(~I.Frame<D.Scene,App.Columns(),App.Resources(),Unit>,~Parent(),Modern.resource(~D.Scene,~App.Columns(),~App.Resources(),~Unit,~Author.resources(),~L.InLeft{L.AtLeaf{}},~{==},~{==})),Modern.resource_grant(~I.Frame<D.Scene,App.Columns(),App.Resources(),Unit>,~Link(),Modern.resource(~D.Scene,~App.Columns(),~App.Resources(),~Unit,~Author.resources(),~L.InRight{L.InLeft{L.AtLeaf{}}},~{==},~{==})),Modern.resource_grant(~I.Frame<D.Scene,App.Columns(),App.Resources(),Unit>,~Phase(),Modern.resource(~D.Scene,~App.Columns(),~App.Resources(),~Unit,~Author.resources(),~L.InRight{L.InRight{L.InLeft{L.AtLeaf{}}}},~{==},~{==})),Columns.query(~D.Scene,~App.Columns(),~App.Resources(),~Unit,~D.components(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Rows.Optional{}),Columns.query(~D.Scene,~App.Columns(),~App.Resources(),~Unit,~D.components(),~L.InRight{L.AtLeaf{}},~{==},~{==},~Rows.Optional{})}}
def key(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def handle(value:W.Handle<D.Scene>) -> String:
  match value:
    case W.Handle{namespace,entity}:U32.show(namespace) ++ "/" ++ key(entity)
def edge(value:T.Edge<D.Scene>) -> String:
  match value:
    case T.Edge{_,source,target}:key(source) ++ "->" ++ key(target)
def inverse(value:T.Inverse<D.Scene>) -> String:
  match value:
    case T.Inverse{_,target,sources}:key(target) ++ "<-" ++ List.show(&2,Key.Key,key,sources)
def graph(value:T.Graph<D.Scene>) -> String:
  match value:
    case T.Graph{edges,inverses}:List.show(&2,T.Edge<D.Scene>,edge,edges) ++ "/" ++ List.show(&2,T.Inverse<D.Scene>,inverse,inverses)
def current(value:M.CurrentView<D.Scene,D.PhaseToken,U32>) -> String:
  match value:
    case M.Unavailable{}:"unavailable"
    case M.Current{value}:U32.show(value)
def next(value:M.NextView<D.Scene,D.PhaseToken,U32>) -> String:
  match value:
    case M.NoNext{}:"none"
    case M.Next{value}:U32.show(value)
def phase(value:Phase()) -> String:
  match value:
    case State.View{value,pending,revision,_,_,_}:current(value) ++ "/" ++ next(pending) ++ "/revision=" ++ Nat.show(revision)
def values(values:List<&2,U32>) -> String:List.show(&2,U32,U32.show,values)
def array_access(value:Component.Access<List<&2,U32>>) -> String:
  match value:
    case Component.Found{value}:values(value)
    case Component.ComponentAbsent{}:"absent"
    case Component.MissingEntity{}:"missing"
def scalar_access(value:Component.Access<U32>) -> String:
  match value:
    case Component.Found{value}:U32.show(value)
    case Component.ComponentAbsent{}:"absent"
    case Component.MissingEntity{}:"missing"
def array_row(value:Rows.Row<D.Scene,List<&2,U32>>) -> String:
  match value:
    case Rows.Row{entity,I.Value{value,added,changed}}:handle(entity) ++ "=" ++ array_access(value) ++ "/" ++ Bool.show(added) ++ "/" ++ Bool.show(changed)
def scalar_row(value:Rows.Row<D.Scene,U32>) -> String:
  match value:
    case Rows.Row{entity,I.Value{value,added,changed}}:handle(entity) ++ "=" ++ scalar_access(value) ++ "/" ++ Bool.show(added) ++ "/" ++ Bool.show(changed)
def scalar_read(-H:Type,text:String,result:H & List<&2,Rows.Row<D.Scene,U32>>) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,rows):(owner,Done{text ++ ";scalars=" ++ List.show(&2,Rows.Row<D.Scene,U32>,scalar_row,rows)})
def arrays_read(~H:Type,~scalars:Query.ReadQuery<H,D.Scene,U32>,text:String,result:H & List<&2,Rows.Row<D.Scene,List<&2,U32>>>) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,rows):scalar_read(H,text ++ ";arrays=" ++ List.show(&2,Rows.Row<D.Scene,List<&2,U32>>,array_row,rows),Cap.value_read(~H,~List<&2,Rows.Row<D.Scene,U32>>,~Query.rows_field(~H,~D.Scene,~U32,scalars),owner))
def phase_read(~H:Type,~arrays:Query.ReadQuery<H,D.Scene,List<&2,U32>>,~scalars:Query.ReadQuery<H,D.Scene,U32>,text:String,result:H & Phase()) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,value):arrays_read(~H,~scalars,text ++ ";phase=" ++ phase(value),Cap.value_read(~H,~List<&2,Rows.Row<D.Scene,List<&2,U32>>>,~Query.rows_field(~H,~D.Scene,~List<&2,U32>,arrays),owner))
def link_read(~H:Type,~phase:Cap.ValueRead<H,Phase()>,~arrays:Query.ReadQuery<H,D.Scene,List<&2,U32>>,~scalars:Query.ReadQuery<H,D.Scene,U32>,text:String,result:H & Link()) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,Store.View{namespace,value}):phase_read(~H,~arrays,~scalars,text ++ ";Link=" ++ U32.show(namespace) ++ "/" ++ graph(value),Cap.value_read(~H,~Phase(),~phase,owner))
def parent_read(~H:Type,~link:Cap.ValueRead<H,Link()>,~phase:Cap.ValueRead<H,Phase()>,~arrays:Query.ReadQuery<H,D.Scene,List<&2,U32>>,~scalars:Query.ReadQuery<H,D.Scene,U32>,result:H & Parent()) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,Store.View{namespace,value}):link_read(~H,~phase,~arrays,~scalars,"Parent=" ++ U32.show(namespace) ++ "/" ++ graph(value),Cap.value_read(~H,~Link(),~link,owner))
def parent_cap(-H:Type,caps:Reads<H>) -> Cap.ValueRead<H,Parent()>:
  match caps:
    case Reads{parent,_,_,_,_}:parent
def link_cap(-H:Type,caps:Reads<H>) -> Cap.ValueRead<H,Link()>:
  match caps:
    case Reads{_,link,_,_,_}:link
def phase_cap(-H:Type,caps:Reads<H>) -> Cap.ValueRead<H,Phase()>:
  match caps:
    case Reads{_,_,phase,_,_}:phase
def arrays_cap(-H:Type,caps:Reads<H>) -> Query.ReadQuery<H,D.Scene,List<&2,U32>>:
  match caps:
    case Reads{_,_,_,arrays,_}:arrays
def scalars_cap(-H:Type,caps:Reads<H>) -> Query.ReadQuery<H,D.Scene,U32>:
  match caps:
    case Reads{_,_,_,_,scalars}:scalars
def read(~H:Type,~caps:Reads<H>,_:Unit,owner:H) -> H & Result<&2,&2,String,String>:
  parent_read(~H,~link_cap(H,caps),~phase_cap(H,caps),~arrays_cap(H,caps),~scalars_cap(H,caps),Cap.value_read(~H,~Parent(),~parent_cap(H,caps),owner))
def observed(context:Context.Context<D.Scene,App.Resources(),Author.resources(),{==}>,result:App.Application() & (I.Instance<D.Scene> & Result<&2,&2,String,String>)) -> App.Bound() & String:
  match result:
    case (application,(_,Done{text})):(Context.Bound{context,application},text)
    case (application,(_,Fail{error})):(Context.Bound{context,application},"inspection-error:" ++ error)
def observe(bound:App.Bound()) -> App.Bound() & String:
  match bound:
    case Context.Bound{context,application}:observed(context,Passive.passive(~D.Scene,~App.Columns(),~App.Resources(),~Unit,~App.Owners(),~Unit,~Unit,~Ops,~Unit,~String,~String,~plan(),~read,application,I.Fresh{},Unit{}))
