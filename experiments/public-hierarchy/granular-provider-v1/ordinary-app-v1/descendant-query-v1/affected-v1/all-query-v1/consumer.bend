import Base
import ../../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy-query.bend as Visit
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/hierarchy-traversal.bend as Traversal
import ../../owners.bend as O
import ../../fixture.bend as Seed

def Ops(~S:Data,H:Type) -> Type:
  Cap.ValueRead<H,W.Handle<S>>
def query(~S:Data) -> Query.Declaration<S,Q.Frame<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>,Ops(~S,Q.Frame<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>)>:
  Query.Declaration{Q.handle_read(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>),Q.all(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>),[]}
def returned(~S:Data,~H:Type,result:H & W.Handle<S>) -> H & (Tx.Outcome<U32> & String):
  match result:
    case (owner,W.Handle{_,id}):(owner,(Tx.Success{},U32.show(id)))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),_:Unit,owner:H) -> H & (Tx.Outcome<U32> & String):
  returned(~S,~H,Cap.value_read(~H,~W.Handle<S>,~caps,owner))
def visit(~S:Data,label:String,app:C.Application(~S),order:Traversal.Order) -> C.Application(~S) & String:
  C.visit_done(~S,label,Visit.visit_descendants_app(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~C.prior(~S),~C.fold(~S),~Ops(~S),~Unit,~U32,~String,~query(~S),~body(~S),app,W.Handle{1,1},order,Unit{},0))
def world_error(error:W.WorldError) -> String:
  match error:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def dead_returned(~S:Data,owners:Array<U32>,recipe:Relation.Recipe(~S,~O.Components<S>,~Array<U32>,~U32,~App.declaration(~S,C.hierarchy(~S)),~Array<U32>,~String,~C.prior(~S),~C.fold(~S)),debug:Bool,result:C.World(~S) & W.Status) -> C.Application(~S) & String:
  match result:
    case (world,W.Accepted{}):(Build.Registered{world,owners,recipe,debug},"DEACTIVATE:Accepted")
    case (world,W.Rejected{error}):(Build.Registered{world,owners,recipe,debug},"DEACTIVATE:" ++ world_error(error))
def dead(~S:Data,app:C.Application(~S)) -> C.Application(~S) & String:
  match app:
    case Build.Registered{world,owners,recipe,debug}:dead_returned(~S,owners,recipe,debug,W.deactivate(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,world,W.Handle{1,4}))
def final(~S:Data,text:String,result:C.Application(~S) & String) -> String:
  match result:
    case (app,row):C.finish(~S,text ++ "\n" ++ row,C.snapshot(~S,"FINAL",app))
def dead_depth(~S:Data,text:String,result:C.Application(~S) & String) -> String:
  match result:
    case (app,row):final(~S,text ++ "\n" ++ row,visit(~S,"DEAD_BREADTH",app,Traversal.Breadth{}))
def dead_snapshot(~S:Data,text:String,result:C.Application(~S) & String) -> String:
  match result:
    case (app,row):dead_depth(~S,text ++ "\n" ++ row,visit(~S,"DEAD_DEPTH",app,Traversal.Depth{}))
def deactivated(~S:Data,text:String,result:C.Application(~S) & String) -> String:
  match result:
    case (app,row):dead_snapshot(~S,text ++ "\n" ++ row,C.snapshot(~S,"DEACTIVATED",app))
def breadth(~S:Data,text:String,result:C.Application(~S) & String) -> String:
  match result:
    case (app,row):deactivated(~S,text ++ "\n" ++ row,dead(~S,app))
def depth(~S:Data,text:String,result:C.Application(~S) & String) -> String:
  match result:
    case (app,row):breadth(~S,text ++ "\n" ++ row,visit(~S,"LIVE_BREADTH",app,Traversal.Breadth{}))
def applied(~S:Data,result:C.Application(~S) & String) -> String:
  match result:
    case (app,row):depth(~S,row,visit(~S,"LIVE_DEPTH",app,Traversal.Depth{}))
def seeded(~S:Data,state:C.World(~S) & List<&2,W.Handle<S>>) -> String:
  match state:
    case (world,_):applied(~S,C.snapshot(~S,"APPLIED",C.barrier(~S,C.relate(~S,C.relate(~S,C.relate(~S,App.install(~S,~O.Components<S>,~Array<U32>,~U32,~C.hierarchy(~S),~Array<U32>,~String,~C.prior(~S),~C.fold(~S),Build.Registered{world,ANode{ALeaf{901},ALeaf{902}},Tree.Recipe{},False{}}),W.Handle{1,2},W.Handle{1,1}),W.Handle{1,3},W.Handle{1,1}),W.Handle{1,4},W.Handle{1,2}))))
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,Array<U32>,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}:seeded(~S,Seed.spawn(~S,4n,(world,[])))
    case _:"CREATE_FAILURE"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~Array<U32>,~A.Notice<S,U32>,~Seed.empty(~S),W.factory(),ANode{ALeaf{17},ALeaf{18}}))
def main() -> IO(Unit):
  IO.print("AllQueryAlpha" ++ run(~C.Alpha) ++ "\nAllQueryBeta" ++ run(~C.Beta))
