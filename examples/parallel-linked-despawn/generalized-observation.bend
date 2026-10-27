import Base
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/execution-lifetime-scope-command.bend as ScopeCommands
import ../parallel-relations/failure-message-text.bend as FailureText
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ./actor.bend as Actor
import ./scene.bend as Text
import ./setup.bend as Setup
import ./scheduled.bend as Scheduled
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-lifetime-scope-store.bend as ScopeStore
import ../../src/ecs/execution-lifetime-scope-description.bend as ScopeText
import ../../src/ecs/lifetime-scope.bend as Scope
import ../../src/ecs/change-tick.bend as Tick

def with_pair(-A:Type,-R:Type,result:A & String,next:A -> String -> R) -> R:
  match result:
    case (owner,text):next(owner,text)
def session(owner:Actor.Session) -> Actor.Session & String:
  match owner:
    case Actor.Session{+value}:(Actor.Session{value},U32.show(value))
def some(result:Actor.Session & String) -> Maybe<&1,Actor.Session> & String:
  match result:
    case (owner,text):(Some{owner},text)
def maybe(owner:Maybe<&1,Actor.Session>) -> Maybe<&1,Actor.Session> & String:
  match owner:
    case None{}:(None{},"none")
    case Some{owner}:some(session(owner))
def removed_returned(other:Unit,result:Maybe<&1,Actor.Session> & String) -> Removed.Removed(Actor.components()) & String:
  match result:
    case (owner,text):(Product.Owner{owner,other},text)
def removed(owner:Removed.Removed(Actor.components())) -> Removed.Removed(Actor.components()) & String:
  match owner:
    case Product.Owner{owner,other}:removed_returned(other,maybe(owner))
def rows_join(-P:Type,head:P & String,tail:List<P> & List<&2,String>) -> List<P> & List<&2,String>:
  match head tail:
    case (head,text), (tail,texts):(head <> tail,text <> texts)
def rows(~P:Type,~observe:P -> P & String,owners:List<P>) -> List<P> & List<&2,String>:
  match owners:
    case []:([],[])
    case head <> tail:rows_join(P,observe(head),rows(~P,~observe,tail))
def identity(value:String) -> String:value
def strings(texts:List<&2,String>) -> String:List.show(&2,String,identity,texts)
def component_receipt(+handle:W.Handle<Text.Schema>,kind:Bool,result:Maybe<&1,Actor.Session> & String) -> Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String:
  match kind result:
    case True{}, (owner,text):(Buffer.Applied{handle,owner},"component-applied:" ++ Text.handle(handle) ++ "/previous=" ++ text)
    case False{}, (owner,text):(Buffer.Refused{handle,owner},"component-refused:" ++ Text.handle(handle) ++ "/incoming=" ++ text)
def removed_receipt(+handle:W.Handle<Text.Schema>,kind:Bool,result:Removed.Removed(Actor.components()) & String) -> Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String:
  match kind result:
    case True{}, (owner,text):(Buffer.Despawned{handle,owner},"despawned:" ++ Text.handle(handle) ++ "/owner=" ++ text)
    case False{}, (owner,text):(Buffer.Spawned{handle,owner},"spawned:" ++ Text.handle(handle) ++ "/previous=" ++ text)
def receipt_join(head:Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String,tail:List<Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>> & String) -> List<Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>> & String:
  match head tail:
    case (head,text), (tail,texts):(head <> tail,text ++ ";" ++ texts)
def spawn_refused(+handle:W.Handle<Text.Schema>,+reason:Bundle.Refusal,result:Removed.Removed(Actor.components()) & String) -> Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String:
  match result:
    case (owner,text):(Buffer.SpawnRefused{handle,owner,reason},"spawn-refused:" ++ Text.handle(handle) ++ "/incoming=" ++ text)
def linked_receipt(+handle:W.Handle<Text.Schema>,+status:Buffer.LinkedStatus,+frames:List<&2,T.CleanupFrame<Text.Schema>>,result:List<Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>> & String) -> Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String:
  match result:
    case (nested,text):(Buffer.LinkedDespawn{handle,status,nested,frames},"linked-despawn:" ++ Text.handle(handle) ++ ":" ++ ScopeText.linked_status(status) ++ "{" ++ text ++ "}/frames=" ++ Nat.show(List.length(&2,T.CleanupFrame<Text.Schema>,frames)))
def scope_receipt(+route:L.Route,+operation:ScopeCommands.Operation<Text.Schema>,+status:Buffer.ScopeStatus,+frames:List<&2,T.CleanupFrame<Text.Schema>>,result:List<Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>> & String) -> Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String:
  match result:
    case (nested,text):(Buffer.ScopePublished{route,operation,status,nested,frames},"scope:" ++ ScopeText.operation(~Text.Schema,operation) ++ ":" ++ ScopeText.status(status) ++ "{" ++ text ++ "}/frames=" ++ Nat.show(List.length(&2,T.CleanupFrame<Text.Schema>,frames)))
def receipts(owners:List<Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>>) -> List<Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>> & String:
  match owners:
    case []:([],"")
    case Buffer.Applied{handle,previous} <> rest:receipt_join(component_receipt(handle,True{},maybe(previous)),receipts(rest))
    case Buffer.Refused{handle,incoming} <> rest:receipt_join(component_receipt(handle,False{},maybe(incoming)),receipts(rest))
    case Buffer.Despawned{handle,owner} <> rest:receipt_join(removed_receipt(handle,True{},removed(owner)),receipts(rest))
    case Buffer.Spawned{handle,owner} <> rest:receipt_join(removed_receipt(handle,False{},removed(owner)),receipts(rest))
    case Buffer.SpawnRefused{handle,owner,reason} <> rest:receipt_join(spawn_refused(handle,reason,removed(owner)),receipts(rest))
    case Buffer.DespawnRefused{+handle} <> rest:receipt_join((Buffer.DespawnRefused{handle},"despawn-refused:" ++ Text.handle(handle)),receipts(rest))
    case Buffer.RelationPublished{+route,+value} <> rest:receipt_join((Buffer.RelationPublished{route,value},Text.receipts([Buffer.RelationPublished{route,value}])),receipts(rest))
    case Buffer.RelationUndeclared{+route,+value} <> rest:receipt_join((Buffer.RelationUndeclared{route,value},Text.receipts([Buffer.RelationUndeclared{route,value}])),receipts(rest))
    case Buffer.LinkedDespawn{handle,status,children,frames} <> rest:receipt_join(linked_receipt(handle,status,frames,receipts(children)),receipts(rest))
    case Buffer.ScopePublished{route,operation,status,children,frames} <> rest:receipt_join(scope_receipt(route,operation,status,frames,receipts(children)),receipts(rest))
    case Buffer.ScopeStoreApplied{+route,+request,+result} <> rest:receipt_join((Buffer.ScopeStoreApplied{route,request,result},"scope-store:" ++ ScopeText.request(~Text.Schema,request) ++ ":" ++ ScopeText.outcome(~Text.Schema,result)),receipts(rest))
def component_entry(+handle:W.Handle<Text.Schema>,result:Maybe<&1,Actor.Session> & String) -> Buffer.Entry<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String:
  match result:
    case (owner,text):(Buffer.Entry{handle,owner},"component:" ++ Text.handle(handle) ++ "/incoming=" ++ text)
def spawn_entry(+handle:W.Handle<Text.Schema>,result:Removed.Removed(Actor.components()) & String) -> Buffer.Entry<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String:
  match result:
    case (owner,text):(Buffer.Spawn{handle,owner},"spawn:" ++ Text.handle(handle) ++ "/incoming=" ++ text)
def entry(owner:Buffer.Entry<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>) -> Buffer.Entry<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String:
  match owner:
    case Buffer.Entry{handle,owner}:component_entry(handle,maybe(owner))
    case Buffer.Spawn{handle,owner}:spawn_entry(handle,removed(owner))
    case Buffer.Despawn{+handle}:(Buffer.Despawn{handle},"despawn:" ++ Text.handle(handle))
    case Buffer.Relation{+route,+operation}:(Buffer.Relation{route,operation},"relation:" ++ Text.route(route) ++ "/" ++ Text.operation(operation))
    case Buffer.LifetimeScope{+route,+operation}:(Buffer.LifetimeScope{route,operation},"scope:" ++ Text.route(route) ++ "/" ++ ScopeText.operation(~Text.Schema,operation))
def buffer_returned(pending:List<Buffer.Entry<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>> & List<&2,String>,values:List<Buffer.Receipt<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>> & String) -> Buffer.Buffer<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String:
  match pending values:
    case (pending,texts), (values,text):(Buffer.Buffer{pending,values},"pending=" ++ strings(List.reverse(&2,String,texts)) ++ ",receipts-storage=[" ++ text ++ "]")
def buffer(owner:Buffer.Buffer<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>) -> Buffer.Buffer<Text.Schema,Actor.Session,Removed.Removed(Actor.components())> & String:
  match owner:
    case Buffer.Buffer{pending,values}:buffer_returned(rows(~Buffer.Entry<Text.Schema,Actor.Session,Removed.Removed(Actor.components())>,~entry,pending),receipts(values))
def viewed_returned(+cache:U32,result:Actor.Session & String) -> L.Viewed<Actor.Session,U32> & String:
  match result:
    case (owner,text):(L.Viewed{owner,cache},text ++ "/" ++ U32.show(cache))
def viewed(owner:L.Viewed<Actor.Session,U32>) -> L.Viewed<Actor.Session,U32> & String:
  match owner:
    case L.Viewed{owner,cache}:viewed_returned(cache,session(owner))
def cell_returned(result:L.Viewed<Actor.Session,U32> & String) -> Maybe<&1,L.Viewed<Actor.Session,U32>> & String:
  match result:
    case (owner,text):(Some{owner},text)
def cell(owner:Maybe<&1,L.Viewed<Actor.Session,U32>>) -> Maybe<&1,L.Viewed<Actor.Session,U32>> & String:
  match owner:
    case None{}:(None{},"none")
    case Some{owner}:cell_returned(viewed(owner))
def cells_leaf(result:Maybe<&1,L.Viewed<Actor.Session,U32>> & String) -> Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String:
  match result:
    case (owner,text):(ALeaf{owner},text)
def cells_branch(left:Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String,right:Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String) -> Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String:
  match left right:
    case (left,a), (right,b):(ANode{left,right},"[" ++ a ++ "," ++ b ++ "]")
def cells(owners:Array<Maybe<&1,L.Viewed<Actor.Session,U32>>>) -> Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String:
  match owners:
    case ALeaf{owner}:cells_leaf(cell(owner))
    case ANode{left,right}:cells_branch(cells(left),cells(right))
def column_leaf(stamps:Array<Life.Stamp>,result:Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String) -> Column.Column<Text.Schema,L.Viewed<Actor.Session,U32>> & String:
  match result:
    case (values,text):(Column.Leaf{values,stamps},text)
def column_branch(size:U32,left:Column.Column<Text.Schema,L.Viewed<Actor.Session,U32>> & String,right:Column.Column<Text.Schema,L.Viewed<Actor.Session,U32>> & String) -> Column.Column<Text.Schema,L.Viewed<Actor.Session,U32>> & String:
  match left right:
    case (left,a), (right,b):(Column.Branch{size,left,right},"[" ++ a ++ "," ++ b ++ "]")
def column(owner:Column.Column<Text.Schema,L.Viewed<Actor.Session,U32>>) -> Column.Column<Text.Schema,L.Viewed<Actor.Session,U32>> & String:
  match owner:
    case Column.Leaf{values,stamps}:column_leaf(stamps,cells(values))
    case Column.Branch{size,left,right}:column_branch(size,column(left),column(right))
def components_returned(other:Unit,result:Column.Column<Text.Schema,L.Viewed<Actor.Session,U32>> & String) -> Scheduled.Columns(~Text.Schema) & String:
  match result:
    case (values,text):(Product.Owner{L.ColumnSlot{values},other},text)
def components(owner:Scheduled.Columns(~Text.Schema)) -> Scheduled.Columns(~Text.Schema) & String:
  match owner:
    case Product.Owner{L.ColumnSlot{values},other}:components_returned(other,column(values))
def graph_data(~family:T.Descriptor<Text.Schema>,value:T.Graph<Text.Schema>,cache:Store.View<Text.Schema,family>) -> String:
  match value cache:
    case T.Graph{edges,inverses} Store.View{namespace,T.Graph{cachedEdges,cachedInverses},_,_,_}:"edges=" ++ List.show(&2,T.Edge<Text.Schema>,Text.edge,edges) ++ ",inverse=" ++ List.show(&2,T.Inverse<Text.Schema>,Text.inverse,inverses) ++ ",cache=" ++ U32.show(namespace) ++ "/" ++ List.show(&2,T.Edge<Text.Schema>,Text.edge,cachedEdges) ++ "/" ++ List.show(&2,T.Inverse<Text.Schema>,Text.inverse,cachedInverses)
def graph(~family:T.Descriptor<Text.Schema>,owner:Store.Store<Text.Schema,family>,+cache:Store.View<Text.Schema,family>) -> Store.Store<Text.Schema,family> & String:
  match owner:
    case Store.Store{+namespace,+value,+failures,+sequence,+nextReader}:(Store.Store{namespace,value,failures,sequence,nextReader},"namespace=" ++ U32.show(namespace) ++ "," ++ graph_data(~family,value,cache) ++ ",failure-sequence=" ++ Nat.show(sequence) ++ "," ++ Text.channel(~family,failures) ++ ",failure-messages=" ++ List.show(&2,Message.Message<Text.Schema,family>,message => FailureText.message(Text.Schema,family,message),Text.failure_values(~family,failures)) ++ ",nextReader=" ++ U32.show(nextReader))
def resources_returned(parentCache:Store.View<Text.Schema,Setup.hierarchy(~Text.Schema)>,linkCache:Store.View<Text.Schema,Setup.link(~Text.Schema)>,parentStamp:Life.Stamp,linkStamp:Life.Stamp,+namespace:U32,+members:List<&2,Scope.Member>,scopeCache:ScopeStore.View<Text.Schema>,scopeStamp:Life.Stamp,stateStamp:Life.Stamp,parentResult:Store.Store<Text.Schema,Setup.hierarchy(~Text.Schema)> & String,linkResult:Store.Store<Text.Schema,Setup.link(~Text.Schema)> & String,stateResult:L.Viewed<Actor.Session,U32> & String) -> Scheduled.Resources(~Text.Schema) & String:
  match parentResult linkResult stateResult:
    case (parent,parentText), (link,linkText), (state,stateText):(Product.Owner{Product.Owner{L.ResourceSlot{L.Viewed{parent,parentCache},parentStamp},L.ResourceSlot{L.Viewed{link,linkCache},linkStamp}},Product.Owner{L.ResourceSlot{L.Viewed{ScopeStore.Store{namespace,members},scopeCache},scopeStamp},L.ResourceSlot{state,stateStamp}}},"parent={" ++ parentText ++ "},link={" ++ linkText ++ "},scope=" ++ U32.show(namespace) ++ "/" ++ List.show(&2,Scope.Member,Text.member,members) ++ ",resource=" ++ stateText)
def resources(owner:Scheduled.Resources(~Text.Schema)) -> Scheduled.Resources(~Text.Schema) & String:
  match owner:
    case Product.Owner{Product.Owner{L.ResourceSlot{L.Viewed{parent,+parentCache},parentStamp},L.ResourceSlot{L.Viewed{link,+linkCache},linkStamp}},Product.Owner{L.ResourceSlot{L.Viewed{ScopeStore.Store{namespace,members},scopeCache},scopeStamp},L.ResourceSlot{state,stateStamp}}}:resources_returned(parentCache,linkCache,parentStamp,linkStamp,namespace,members,scopeCache,scopeStamp,stateStamp,graph(~Setup.hierarchy(~Text.Schema),parent,parentCache),graph(~Setup.link(~Text.Schema),link,linkCache),viewed(state))
