import Base
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/ordinary-query-observable.bend as Query
import ../../../src/ecs/ordinary-system.bend as QuerySys
import ../../../src/ecs/compose.bend as Compose
import ../../../src/ecs/inspector.bend as Inspect
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/ordinary-lifetime-scope.bend as Ord
import ../../../src/ecs/ordinary-lifetime-scope-io.bend as OrdIO
import ../../../src/ecs/lifetime-scope.bend as Sc
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/lifecycle.bend as Life
import ../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../src/ecs/ordinary-component-clear-declaration.bend as ClearDecl
import ../../../src/ecs/ordinary-component-despawn.bend as Clear
import ../../../src/ecs/persistence-declaration.bend as Persist
import ../../../src/ecs/ordinary-schema-provision.bend as Prov
import ../../../src/ecs/relation-commands.bend as A
import ../../../src/ecs/relation-types.bend as G
import ../ordinary-v1/fixture.bend as Values
import ./payload-view.bend as V
def declaration(~S:Data) -> Identity.Declaration<S,Values.Payload>:
  Identity.component(~S,~Values.Payload,"Payload")

def take(~S:Data,column:Col.Column<S,Values.Payload>) -> Unit & Col.Column<S,Values.Payload>:
  (Unit{},column)

def put(~S:Data,unit:Unit,column:Col.Column<S,Values.Payload>) -> Col.Column<S,Values.Payload>:
  column

def binding(~S:Data) -> Binding.Binding<S,Col.Column<S,Values.Payload>,Unit,Values.Payload,List<&2,U32>,Unit,take(~S),put(~S),V.project>:
  Binding.bind(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~List<&2,U32>,~Unit,~take(~S),~put(~S),~V.project,declaration(~S))

def removed(~S:Data,identity:Identity.Declaration<S,Values.Payload>,handle:W.Handle<S>) -> A.Notice<S,U32>:
  match handle:
    case W.Handle{_,id}:A.ComponentRemoved{id}

def clear_declaration(~S:Data) -> ClearDecl.Declaration<S,Col.Column<S,Values.Payload>,A.Notice<S,U32>,Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~List<&2,U32>,~Unit,~take(~S),~put(~S),~V.project,~A.Notice<S,U32>,~removed(~S),~binding(~S))>:
  ClearDecl.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~List<&2,U32>,~Unit,~take(~S),~put(~S),~V.project,~A.Notice<S,U32>,~removed(~S),~binding(~S))

def clear(~S:Data,components:Col.Column<S,Values.Payload>,handle:W.Handle<S>) -> Col.Column<S,Values.Payload> & List<&2,A.Notice<S,U32>>:
  Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~List<&2,U32>,~Unit,~take(~S),~put(~S),~V.project,~A.Notice<S,U32>,~removed(~S),~binding(~S))(components,handle)

def record(~S:Data,handle:W.Handle<S>) -> A.Notice<S,U32>:
  Values.record(~S,handle)

def provision(~S:Data) -> Prov.Provision<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,Ord.empty_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_empty(~S,~Values.Payload)),Ord.count_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_count(~S,~Values.Payload))>:
  Ord.provision(~S,~Col.Column<S,Values.Payload>,~Unit,~Prov.component_empty(~S,~Values.Payload),~Prov.component_count(~S,~Values.Payload),Prov.component_plain(~S,~Values.Payload,~declaration(~S),Persist.plain(~S,~Values.Payload,~declaration(~S))))

def create(~S:Data) -> IO(Prov.Provision<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,Ord.empty_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_empty(~S,~Values.Payload)),Ord.count_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_count(~S,~Values.Payload))> & WI.Creation<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>):
  OrdIO.create(~S,~Col.Column<S,Values.Payload>,~Unit,~Prov.component_empty(~S,~Values.Payload),~Prov.component_count(~S,~Values.Payload),~U32,provision(~S),Unit{})

def scoped_binding(~S:Data) -> Binding.Binding<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Ord.ComponentRest<S,Unit>,Values.Payload,List<&2,U32>,Unit,Ord.take_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~take(~S)),Ord.put_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~put(~S)),V.project>:
  Ord.component_binding(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~List<&2,U32>,~Unit,~take(~S),~put(~S),~V.project,binding(~S))

def replace_returned(~S:Data,seen:Cmp.Replacement<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Values.Payload>) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>:
  match seen:
    case Cmp.Replaced{world,_}:world
    case Cmp.ReplaceRejected{world,_,_}:world

def populate_world(~S:Data,world:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,handle:W.Handle<S>,payload:Values.Payload) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>:
  replace_returned(~S,Cmp.replace(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Ord.ComponentRest<S,Unit>,~Values.Payload,~List<&2,U32>,~Unit,~Ord.take_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~take(~S)),~Ord.put_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~put(~S)),~V.project,Binding.family(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Ord.ComponentRest<S,Unit>,~Values.Payload,~List<&2,U32>,~Unit,~Ord.take_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~take(~S)),~Ord.put_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~put(~S)),~V.project,scoped_binding(~S)),world,handle,Some{payload}))

def query(~S:Data) -> Query.Declaration<S,Compose.Frame<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Cap.Read<Compose.Frame<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,List<&2,U32>>,Inspect.Frame<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Cmp.Access<List<&2,U32>>>:
  Query.read(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Ord.ComponentRest<S,Unit>,~Values.Payload,~List<&2,U32>,~Unit,~Ord.take_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~take(~S)),~Ord.put_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~put(~S)),~V.project,~Unit,~A.Notice<S,U32>,~scoped_binding(~S))
