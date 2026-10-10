import Base
import provider.bend as P
import observe.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
import ../marker-phases-v1/apply-retention-v1/consumer.bend as Tree
def cell_join(pair:Array<U32> & String) -> Maybe<&1,Array<U32>> & String:
  (owner,text)=pair
  (Some{owner},"some:" ++ text)
def cell(value:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & String:
  match value:
    case None{}:(None{},"none")
    case Some{owner}:cell_join(Tree.tree(~U32,~Tree.number,owner))
def column_join(~S:Data,+stamps:List<&2,L.Entry>,pair:Array<Maybe<&1,Array<U32>>> & String) -> P.Store<S> & String:
  (values,text)=pair
  (P.Store{Col.Column{values,stamps}},text ++ ":stamps=" ++ List.show(&2,L.Entry,O.entry,stamps))
def store(~S:Data,store:P.Store<S>) -> P.Store<S> & String:
  match store:
    case P.Store{Col.Column{values,stamps}}:column_join(~S,stamps,Tree.tree(~Maybe<&1,Array<U32>>,~cell,values))
    case store:(store,"unsupported-column-fixture")
def resource_join(~S:Data,+flow: M.Slot<S,P.FlowToken,P.Flow>,+level:M.Slot<S,P.LevelToken,P.Level>,+flowStream:St.Stream<P.Flow>,+levelStream:St.Stream<P.Level>,+frame:Nat,+tick:Nat,+trace:List<&2,String>,pair:Array<U32> & String) -> P.Resources<S> & String:
  (owned,text)=pair
  (P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace},text)
def resource(~S:Data,resource:P.Resources<S>) -> P.Resources<S> & String:
  match resource:
    case P.Resources{owned,flow,level,flowStream,levelStream,frame,tick,trace}:resource_join(~S,flow,level,flowStream,levelStream,frame,tick,trace,Tree.tree(~U32,~Tree.number,owned))
def physical_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,Unit>,pending:List<&1,(W.World<S,P.Store<S>,P.Resources<S>,Unit> -> W.World<S,P.Store<S>,P.Resources<S>,Unit>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,pairLive:Array<Bool> & String,pairStore:P.Store<S> & String,pairResource:P.Resources<S> & String) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  match pairLive pairStore pairResource:
    case (live,a),(store,b),(resource,c):(W.World{ns,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,clock},"live=" ++ a ++ "/cells=" ++ b ++ "/owned=" ++ c ++ "/bus=" ++ List.show(&2,Unit,u => "Unit",events))
def physical(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  match world:
    case W.World{ns,next,high,live,capacity,depth,payload,resources,events,pending,registrations,nextSystem,clock}:physical_join(~S,ns,next,high,capacity,depth,events,pending,registrations,nextSystem,clock,Tree.tree(~Bool,~Tree.boolean,live),store(~S,payload),resource(~S,resources))
def joined(~S:Data,prior:String,pair:W.World<S,P.Store<S>,P.Resources<S>,Unit> & String) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  (world,text)=pair
  (world,text ++ "/physical=" ++ prior)
def old_observed(~S:Data,pair:W.World<S,P.Store<S>,P.Resources<S>,Unit> & String) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:
  (world,text)=pair
  joined(~S,text,O.world(~S,world))
def world(~S:Data,world:W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit> & String:old_observed(~S,physical(~S,world))
