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
def declaration(~S:Data) -> Identity.Declaration<S,Values.Payload>:
  Identity.component(~S,~Values.Payload,"Payload")
def take(~S:Data,column:Col.Column<S,Values.Payload>) -> Unit & Col.Column<S,Values.Payload>:
  (Unit{},column)
def put(~S:Data,unit:Unit,column:Col.Column<S,Values.Payload>) -> Col.Column<S,Values.Payload>:
  column
def binding(~S:Data) -> Binding.Binding<S,Col.Column<S,Values.Payload>,Unit,Values.Payload,String,Unit,take(~S),put(~S),Values.show_payload>:
  Binding.bind(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~take(~S),~put(~S),~Values.show_payload,declaration(~S))
def removed(~S:Data,identity:Identity.Declaration<S,Values.Payload>,handle:W.Handle<S>) -> A.Notice<S,U32>:
  match handle:
    case W.Handle{_,id}:A.ComponentRemoved{id}
def clear_declaration(~S:Data) -> ClearDecl.Declaration<S,Col.Column<S,Values.Payload>,A.Notice<S,U32>,Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~take(~S),~put(~S),~Values.show_payload,~A.Notice<S,U32>,~removed(~S),~binding(~S))>:
  ClearDecl.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~take(~S),~put(~S),~Values.show_payload,~A.Notice<S,U32>,~removed(~S),~binding(~S))
def clear(~S:Data,components:Col.Column<S,Values.Payload>,handle:W.Handle<S>) -> Col.Column<S,Values.Payload> & List<&2,A.Notice<S,U32>>:
  Clear.leaf(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~take(~S),~put(~S),~Values.show_payload,~A.Notice<S,U32>,~removed(~S),~binding(~S))(components,handle)
def record(~S:Data,handle:W.Handle<S>) -> A.Notice<S,U32>:
  Values.record(~S,handle)
def provision(~S:Data) -> Prov.Provision<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,Ord.empty_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_empty(~S,~Values.Payload)),Ord.count_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_count(~S,~Values.Payload))>:
  Ord.provision(~S,~Col.Column<S,Values.Payload>,~Unit,~Prov.component_empty(~S,~Values.Payload),~Prov.component_count(~S,~Values.Payload),Prov.component_plain(~S,~Values.Payload,~declaration(~S),Persist.plain(~S,~Values.Payload,~declaration(~S))))
def create(~S:Data) -> IO(Prov.Provision<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,Ord.empty_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_empty(~S,~Values.Payload)),Ord.count_store(~S,~Col.Column<S,Values.Payload>,~Prov.component_count(~S,~Values.Payload))> & WI.Creation<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>):
  OrdIO.create(~S,~Col.Column<S,Values.Payload>,~Unit,~Prov.component_empty(~S,~Values.Payload),~Prov.component_count(~S,~Values.Payload),~U32,provision(~S),Unit{})
def populated(~S:Data,result:Col.SwapOutcome<S,Values.Payload>) -> Col.Column<S,Values.Payload>:
  match result:
    case Col.Accepted{column,_}:column
    case Col.Rejected{column,_}:column
def populate(~S:Data,column:Col.Column<S,Values.Payload>,handle:W.Handle<S>,payload:Values.Payload) -> Col.Column<S,Values.Payload>:
  match handle:
    case W.Handle{_,id}:populated(~S,Col.swap(~S,~Values.Payload,column,id,Some{payload}))
def stamp(entry:Life.Entry) -> String:
  match entry:
    case Life.Entry{id,Life.Stamp{added,changed}}:U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def column_returned(~S:Data,+stamps:List<&2,Life.Entry>,seen:Array<Maybe<&1,Values.Payload>> & String) -> Col.Column<S,Values.Payload> & String:
  match seen:
    case (values,text):(Col.Column{values,stamps},text ++ "/stamps=" ++ List.show(&2,Life.Entry,stamp,stamps))
def column(~S:Data,value:Col.Column<S,Values.Payload>) -> Col.Column<S,Values.Payload> & String:
  match value:
    case Col.Column{values,stamps}:column_returned(~S,stamps,Values.tree(~Maybe<&1,Values.Payload>,~Values.show_slot,values))
    case other:(other,"UnsupportedColumnShape")
def unit_view(value:Unit) -> Unit & String:
  (value,"Unit")
def show_kind(kind:G.RelationKind) -> String:
  match kind:
    case G.Ordinary{}:"ordinary"
    case G.Hierarchy{}:"hierarchy"
def show_descriptor(~S:Data,descriptor:G.Descriptor<S>) -> String:
  match descriptor:
    case G.Descriptor{key,name,inverse,kind}:U32.show(key) ++ ":" ++ name ++ ":" ++ inverse ++ ":" ++ show_kind(kind)
def show_edge(~S:Data,edge:G.Edge<S>) -> String:
  match edge:
    case G.Edge{descriptor,source,target}:show_descriptor(~S,descriptor) ++ ":" ++ U32.show(source) ++ ">" ++ U32.show(target)
def show_inverse(~S:Data,inverse:G.Inverse<S>) -> String:
  match inverse:
    case G.Inverse{descriptor,target,sources}:show_descriptor(~S,descriptor) ++ ":" ++ U32.show(target) ++ ":" ++ List.show(&2,U32,U32.show,sources)
def show_graph(~S:Data,graph:G.Graph<S>) -> String:
  match graph:
    case G.Graph{edges,inverses}:List.show(&2,G.Edge<S>,show_edge(~S),edges) ++ "/" ++ List.show(&2,G.Inverse<S>,show_inverse(~S),inverses)
def show_member(member:Sc.Member) -> String:
  match member:
    case Sc.Member{name,id}:name ++ ":" ++ U32.show(id)
def store_components(~S:Data,+members:List<&2,Sc.Member>,+graph:G.Graph<S>,observed:Col.Column<S,Values.Payload> & String) -> A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>> & String:
  (components,text)=observed
  (A.Store{Sc.Store{components,members},graph},text ++ "/graph=" ++ show_graph(~S,graph) ++ "/scopes=" ++ List.show(&2,Sc.Member,show_member,members))
def show_store(~S:Data,store:A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>) -> A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>> & String:
  match store:
    case A.Store{Sc.Store{components,members},graph}:store_components(~S,members,graph,column(~S,components))
def show_notice(~S:Data,notice:A.Notice<S,U32>) -> String:
  match notice:
    case A.Original{value}:"original:" ++ U32.show(value)
    case A.ComponentRemoved{id}:"removed:" ++ U32.show(id)
    case A.RelationFailed{failure}:"failure"
    case A.CleanupPaused{frames}:"paused"
def show_registration(registration:W.RegistrationMeta) -> String:
  match registration:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,value => value,access)
def live_done(~S:Data,+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,store:A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,resource:Unit,+events:List<&2,A.Notice<S,U32>>,pending:List<(W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,pendingCount:U32,storeText:String,resourceText:String,observed:Array<Bool> & String) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  (live,text)=observed
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock},"world=" ++ U32.show(namespace) ++ "," ++ U32.show(nextId) ++ "," ++ U32.show(highWater) ++ "," ++ text ++ "," ++ U32.show(capacity) ++ "," ++ Nat.show(depth) ++ "/" ++ storeText ++ "/resource=" ++ resourceText ++ "/events=" ++ List.show(&2,A.Notice<S,U32>,show_notice(~S),events) ++ "/pending=" ++ U32.show(pendingCount) ++ "/regs=" ++ List.show(&2,W.RegistrationMeta,show_registration,registrations) ++ "/nextSystem=" ++ U32.show(nextSystemId) ++ "/clock=" ++ U32.show(clock))
def live_observe(~S:Data,pendingCount:U32,storeText:String,resourceText:String,world:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  match world:
    case W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock}:live_done(~S,namespace,nextId,highWater,capacity,depth,store,resource,events,pending,registrations,nextSystemId,clock,pendingCount,storeText,resourceText,Values.tree(~Bool,~Values.boolean,live))
def resource_observed(~S:Data,pendingCount:U32,storeText:String,observed:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  (world,text)=observed
  live_observe(~S,pendingCount,storeText,text,world)
def store_observed(~S:Data,pendingCount:U32,observed:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  (world,text)=observed
  resource_observed(~S,pendingCount,text,W.observe_resource(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~String,~unit_view,world))
def pending_observed(~S:Data,observed:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & U32) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  (world,count)=observed
  store_observed(~S,count,W.with_store(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~String,show_store(~S),world))
def observe(~S:Data,world:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>> & String:
  pending_observed(~S,W.pending_count(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,world))
def scoped_binding(~S:Data) -> Binding.Binding<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Ord.ComponentRest<S,Unit>,Values.Payload,String,Unit,Ord.take_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~take(~S)),Ord.put_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~put(~S)),Values.show_payload>:
  Ord.component_binding(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~String,~Unit,~take(~S),~put(~S),~Values.show_payload,binding(~S))
def replace_returned(~S:Data,seen:Cmp.Replacement<W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Values.Payload>) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>:
  match seen:
    case Cmp.Replaced{world,_}:world
    case Cmp.ReplaceRejected{world,_,_}:world
def populate_world(~S:Data,world:W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,handle:W.Handle<S>,payload:Values.Payload) -> W.World<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>:
  replace_returned(~S,Cmp.replace(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Unit,~A.Notice<S,U32>,~Ord.ComponentRest<S,Unit>,~Values.Payload,~String,~Unit,~Ord.take_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~take(~S)),~Ord.put_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~put(~S)),~Values.show_payload,Binding.family(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Ord.ComponentRest<S,Unit>,~Values.Payload,~String,~Unit,~Ord.take_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~take(~S)),~Ord.put_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~put(~S)),~Values.show_payload,scoped_binding(~S)),world,handle,Some{payload}))
def query(~S:Data) -> Query.Declaration<S,Compose.Frame<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Cap.Read<Compose.Frame<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,String>,Inspect.Frame<S,A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,Unit,A.Notice<S,U32>>,Cmp.Access<String>>:
  Query.read(~S,~A.Store<S,Sc.Store<S,Col.Column<S,Values.Payload>>>,~Ord.ComponentRest<S,Unit>,~Values.Payload,~String,~Unit,~Ord.take_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~take(~S)),~Ord.put_column(~S,~Col.Column<S,Values.Payload>,~Unit,~Values.Payload,~put(~S)),~Values.show_payload,~Unit,~A.Notice<S,U32>,~scoped_binding(~S))
def read_body_returned(~H:Type,seen:H & Cmp.Access<String>) -> H & (T.Outcome<Unit> & String):
  match seen:
    case (owner,Cmp.Found{text}):(owner,(T.Success{},text))
    case (owner,_):(owner,(T.Success{},"MissingQueryPayload"))
def read_body(~H:Type,~caps:Cap.Read<H,String>,args:Unit,owner:H) -> H & (T.Outcome<Unit> & String):
  read_body_returned(~H,Cap.read(~H,~String,~caps,owner))
