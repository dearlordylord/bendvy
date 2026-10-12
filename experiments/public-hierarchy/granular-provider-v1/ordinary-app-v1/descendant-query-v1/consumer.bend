import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy-query.bend as Visit
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-traversal.bend as Traversal
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-provider.bend as Path
import ./fixture.bend as Seed
import ./owners.bend as O
import ./observer.bend as Obs

type Alpha is Data: Alpha{}
type Beta is Data: Beta{}
def hierarchy(~S:Data) -> G.HierarchyDescriptor<S>:
  G.HierarchyDescriptor{1,"Parent","Children"}
def World(~S:Data) -> Type:
  W.World<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>
def observed(~S:Data,result:World(~S) & String) -> World(~S) & DTO.Observation<String>:
  match result:
    case (world,+text):(world,DTO.Observation{text,[text]})
def resource_cells(resource:Array<U32>) -> Array<U32> & List<&2,U32>:
  O.project_cells(2n,resource,0)
def resource_finished(~S:Data,text:String,result:World(~S) & List<&2,U32>) -> World(~S) & String:
  match result:
    case (world,values):(world,text ++ "|resource-all=" ++ O.show_ids(values))
def prior_complete(~S:Data,result:World(~S) & String) -> World(~S) & DTO.Observation<String>:
  match result:
    case (world,text):observed(~S,resource_finished(~S,text,W.observe_resource(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~List<&2,U32>,~resource_cells,world)))
def prior(~S:Data,world:World(~S)) -> World(~S) & DTO.Observation<String>:
  prior_complete(~S,Obs.observe(~S,world))
def fold(~S:Data,owners:Array<U32>) -> Array<U32> & List<&2,Fields.Fields<S>>:
  (owners,[])
def Application(~S:Data) -> Type:
  App.Application(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S))
def texts(values:List<&2,String>) -> String:
  match values:
    case []:""
    case value <> rest:value ++ "\n" ++ texts(rest)
def AppObserved(~S:Data) -> Data:
  Relation.ObservedRows(~S,~String)
def snap_done(~S:Data,label:String,ownerText:String,result:Application(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<AppObserved(~S)>>>) -> Application(~S) & String:
  match result:
    case (app,None{}):(app,label ++ "|SNAPSHOT_DISABLED")
    case (app,Some{DTO.Product{_,DTO.Observation{_,values}}}):(app,label ++ "|owners=" ++ ownerText ++ "\n" ++ texts(values))
def owners_seen(~S:Data,label:String,world:World(~S),recipe:Relation.Recipe(~S,~O.Components<S>,~Array<U32>,~U32,~App.declaration(~S,hierarchy(~S)),~Array<U32>,~String,~prior(~S),~fold(~S)),debug:Bool,result:Array<U32> & List<&2,U32>) -> Application(~S) & String:
  match result:
    case (owners,values):snap_done(~S,label,O.show_ids(values),App.snapshot_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),Build.Registered{world,owners,recipe,debug},True{}))
def snapshot(~S:Data,label:String,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Build.Registered{world,owners,recipe,debug}:owners_seen(~S,label,world,recipe,debug,O.project_cells(2n,owners,0))
type Token is Data: Token{}
def take(~S:Data,store:A.Store<S,O.Components<S>>) -> G.Graph<S> & Col.Column<S,Array<U32>>:
  match store:
    case A.Store{O.Components{column},graph}:(graph,column)
def put(~S:Data,graph:G.Graph<S>,column:Col.Column<S,Array<U32>>) -> A.Store<S,O.Components<S>>:
  A.Store{O.Components{column},graph}
def Ops(~S:Data,H:Type) -> Type:
  (Cap.Write<H,Array<U32>,List<&2,U32>> & Cap.ValueRead<H,W.Handle<S>>)
def write_cap(~S:Data,~H:Type,caps:Ops(~S,H)) -> Cap.Write<H,Array<U32>,List<&2,U32>>:
  match caps:
    case (write,_):write
def handle_cap(~S:Data,~H:Type,caps:Ops(~S,H)) -> Cap.ValueRead<H,W.Handle<S>>:
  match caps:
    case (_,handle):handle
def query(~S:Data) -> Query.Declaration<S,Q.Frame<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,Ops(~S,Q.Frame<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>)>:
  Query.pair(~S,~Q.Frame<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,~Cap.Write<Q.Frame<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,Array<U32>,List<&2,U32>>,~Cap.ValueRead<Q.Frame<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,W.Handle<S>>,~Query.write(~S,~Array<U32>,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~G.Graph<S>,~List<&2,U32>,~Token,~Identity.component(~S,~Array<U32>,"Cells"),~O.project_payload,~take(~S),~put(~S)),~Query.Declaration{Q.handle_read(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>),Q.all(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>),[]})
def body_written(~S:Data,~H:Type,+fail:Bool,+id:U32,previous:List<&2,U32>,owner:H) -> H & (Tx.Outcome<U32> & String):
  match fail:
    case False{}:(owner,(Tx.Success{},U32.show(id) ++ ":before=" ++ O.show_ids(previous)))
    case True{}:(owner,(Tx.Failure{id},U32.show(id) ++ ":attempted=" ++ O.show_ids(previous)))
def body_value(~S:Data,~H:Type,~caps:Ops(~S,H),+fail:Bool,+id:U32,result:H & Cmp.Access<List<&2,U32>>) -> H & (Tx.Outcome<U32> & String):
  match result:
    case (owner,Cmp.Found{previous}):body_written(~S,~H,Bool.and(fail,U32.is_eq(id,4)),id,previous,Cap.set(~H,~Array<U32>,~List<&2,U32>,~write_cap(~S,~H,caps),owner,ANode{ALeaf{U32.add(id,100)},ALeaf{U32.add(id,200)}}))
    case (owner,_):(owner,(Tx.Failure{99},"UNEXPECTED_ACCESS"))
def body_handle(~S:Data,~H:Type,~caps:Ops(~S,H),fail:Bool,result:H & W.Handle<S>) -> H & (Tx.Outcome<U32> & String):
  match result:
    case (owner,W.Handle{_,+id}):body_value(~S,~H,~caps,fail,id,Cap.get(~H,~Array<U32>,~List<&2,U32>,~write_cap(~S,~H,caps),owner))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),fail:Bool,owner:H) -> H & (Tx.Outcome<U32> & String):
  body_handle(~S,~H,~caps,fail,Cap.value_read(~H,~W.Handle<S>,~handle_cap(~S,~H,caps),owner))
def outcome(value:Tx.Outcome<Q.Error<U32>>) -> String:
  match value:
    case Tx.Success{}:"Success"
    case Tx.Failure{Q.UserError{error}}:"UserError:" ++ U32.show(error)
    case Tx.Failure{Q.AccessError{_}}:"AccessError"
def execution(value:Maybe<&2,DTO.Product<Tx.Outcome<Q.Error<U32>>,List<&2,String>>>) -> String:
  match value:
    case None{}:"NOT_EXECUTED"
    case Some{DTO.Product{result,values}}:outcome(result) ++ "|values=" ++ List.show(&2,String,x => x,values)
def visit_done(~S:Data,label:String,result:Application(~S) & DTO.Product<Maybe<&2,Path.Path<S>>,Maybe<&2,DTO.Product<Tx.Outcome<Q.Error<U32>>,List<&2,String>>>>) -> Application(~S) & String:
  match result:
    case (app,DTO.Product{path,result}):(app,label ++ "|path=" ++ Seed.show_optional_path(~S,path) ++ "|" ++ execution(result))
def visit(~S:Data,label:String,app:Application(~S),order:Traversal.Order,fail:Bool) -> Application(~S) & String:
  visit_done(~S,label,Visit.visit_descendants_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),~Ops(~S),~Bool,~U32,~String,~query(~S),~body(~S),app,W.Handle{1,1},order,fail,0))
def queued(~S:Data,result:Application(~S) & DTO.Product<A.QueueStatus,Tx.Outcome<Unit>>) -> Application(~S):
  match result:
    case (app,_):app
def relate(~S:Data,app:Application(~S),source:W.Handle<S>,target:W.Handle<S>) -> Application(~S):
  queued(~S,App.relate_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),~Unit,app,P.Targets{source,target},Tx.Success{}))
def barrier(~S:Data,app:Application(~S)) -> Application(~S):
  App.barrier_app(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),app)
def finish(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (_,tail):text ++ "\n" ++ tail
def final(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (app,row):text ++ "\n" ++ row
def breadth(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (app,row):final(~S,text ++ "\n" ++ row,snapshot(~S,"FINAL",app))
def retry_snapshot(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (app,row):breadth(~S,text ++ "\n" ++ row,visit(~S,"BREADTH",app,Traversal.Breadth{}, False{}))
def retry(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (app,row):retry_snapshot(~S,text ++ "\n" ++ row,snapshot(~S,"AFTER_RETRY",app))
def failure_snapshot(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (app,row):retry(~S,text ++ "\n" ++ row,visit(~S,"RETRY_DEPTH",app,Traversal.Depth{}, False{}))
def failure(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (app,row):failure_snapshot(~S,text ++ "\n" ++ row,snapshot(~S,"AFTER_FAILURE",app))
def applied(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (app,row):failure(~S,text ++ "\n" ++ row,visit(~S,"FAILED_DEPTH",app,Traversal.Depth{}, True{}))
def pending_visit(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (app,row):applied(~S,text ++ "\n" ++ row,snapshot(~S,"APPLIED",barrier(~S,app)))
def pending(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (app,row):pending_visit(~S,text ++ "\n" ++ row,visit(~S,"PENDING_DEPTH",app,Traversal.Depth{}, False{}))
def before(~S:Data,text:String,result:Application(~S) & String) -> String:
  match result:
    case (app,row):pending(~S,text ++ "\n" ++ row,snapshot(~S,"PENDING",relate(~S,relate(~S,relate(~S,app,W.Handle{1,2},W.Handle{1,1}),W.Handle{1,3},W.Handle{1,1}),W.Handle{1,4},W.Handle{1,2})))
def seeded(~S:Data,state:World(~S) & List<&2,W.Handle<S>>) -> String:
  match state:
    case (world,_):before(~S,"",snapshot(~S,"BEFORE",App.install(~S,~O.Components<S>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~String,~prior(~S),~fold(~S),Build.Registered{world,ANode{ALeaf{901},ALeaf{902}},Tree.Recipe{},False{}})))
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}:seeded(~S,Seed.spawn(~S,4n,(world,[])))
    case _:"CREATE_FAILURE"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~Seed.empty(~S),W.factory(),ANode{ALeaf{17},ALeaf{18}}))
def main() -> IO(Unit):
  IO.print("DescendantQueryAlpha" ++ run(~Alpha) ++ "\nDescendantQueryBeta" ++ run(~Beta))
