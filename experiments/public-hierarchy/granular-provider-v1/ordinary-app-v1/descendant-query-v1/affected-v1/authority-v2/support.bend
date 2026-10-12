import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-hierarchy-query.bend as Visit
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx

type Alpha is Data: Alpha{}
type Beta is Data: Beta{}
def hierarchy(~S:Data) -> G.HierarchyDescriptor<S>:
  G.HierarchyDescriptor{1,"Parent","Children"}
def World(~S:Data) -> Type:
  W.World<S,A.Store<S,Array<U32>>,Array<U32>,A.Notice<S,U32>>
def prior(~S:Data,world:World(~S)) -> World(~S) & DTO.Observation<Unit>:
  (world,DTO.Observation{Unit{},[]})
def fold(~S:Data,owners:Array<U32>) -> Array<U32> & List<&2,Fields.Fields<S>>:
  (owners,[])
def Application(~S:Data) -> Type:
  App.Application(~S,~Array<U32>,~Array<U32>,~U32,~hierarchy(~S),~Array<U32>,~Unit,~prior(~S),~fold(~S))
def Ops(~S:Data,H:Type) -> Type:
  Cap.ValueRead<H,W.Handle<S>>
def query(~S:Data) -> Query.Declaration<S,Q.Frame<S,A.Store<S,Array<U32>>,Array<U32>,A.Notice<S,U32>>,Ops(~S,Q.Frame<S,A.Store<S,Array<U32>>,Array<U32>,A.Notice<S,U32>>)>:
  Query.Declaration{Q.handle_read(~S,~A.Store<S,Array<U32>>,~Array<U32>,~A.Notice<S,U32>),Q.all(~S,~A.Store<S,Array<U32>>,~Array<U32>,~A.Notice<S,U32>),[]}
def returned(~S:Data,~H:Type,result:H & W.Handle<S>) -> H & (Tx.Outcome<Unit> & U32):
  match result:
    case (owner,W.Handle{_,id}):(owner,(Tx.Success{},id))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),_:Unit,owner:H) -> H & (Tx.Outcome<Unit> & U32):
  returned(~S,~H,Cap.value_read(~H,~W.Handle<S>,~caps,owner))
