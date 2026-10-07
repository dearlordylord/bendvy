import Base
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/relation-providers.bend as P
import ../../../../src/ecs/relation-reorder.bend as R
import ../../../../src/ecs/relation-commands.bend as A
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as X
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/capabilities.bend as Cap
import owned-world.bend as O
import ../../../../src/ecs/relation-query.bend as RQ
import query-client.bend as Q
import cleanup-client.bend as C

# Authored clients have only their declared abstract capabilities.
def relate_body(~S:Data,-H:Type,caps:P.Writable<H,S>,args:P.Targets<S>,owner:H) -> H & A.QueueStatus:
  P.relate_live(H,S,caps,owner,args)
def unrelate_body(~S:Data,-H:Type,caps:P.Writable<H,S>,args:P.Targets<S>,owner:H) -> H & A.QueueStatus:
  match caps args:
    case P.Writable{_,_,Cap.Request{remove}} P.Targets{source,_}: remove(owner,source)
def reorder_body(~S:Data,-H:Type,caps:R.Writable<H,S>,args:R.Args<S>,owner:H) -> H & A.QueueStatus:
  match caps:
    case R.Writable{Cap.Request{request}}: request(owner,args)
def hierarchy(~S:Data) -> G.HierarchyDescriptor<S>:
  G.HierarchyDescriptor{3,"Parent","Children"}
def discard(~S:Data,observed:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & A.QueueStatus) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  (tx,_) = observed
  tx
def component_done(~S:Data,result:Cmp.SetResult<X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,O.Payload>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  match result:
    case Cmp.Written{tx}: (tx,True{})
    case Cmp.WriteRejected{tx,_,_}: (tx,False{})
    case Cmp.WriteFailure{tx,_}: (tx,False{})
def component_body(-H:Type,caps:Cap.Request<H,O.Payload,Bool>,owner:H,incoming:O.Payload) -> H & Bool:
  match caps:
    case Cap.Request{set}: set(owner,incoming)
def component_join(~S:Data,result:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  (tx,_) = result
  tx
def observation_fields(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,text:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,fields) = result
  (world,text ++ "fields=" ++ fields ++ "\n")
def applied(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,phase:U32,text:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,value) = result
  (world,text ++ value)
def finish(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String) -> String:
  (_,text) = result
  text
def descriptors(~S:Data) -> List<&2,G.Descriptor<S>>:
  [Q.link(~S),Q.other(~S),R.descriptor(~S,hierarchy(~S))]
def relate(~S:Data,~descriptor:G.Descriptor<S>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,source:U32,target:U32) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  discard(~S,P.invoke_write(~S,~O.Components<S>,~U32,~U32,~descriptor,~A.QueueStatus,~relate_body(~S),P.Targets{W.Handle{1,source},W.Handle{1,target}},tx))
def unrelate(~S:Data,~descriptor:G.Descriptor<S>,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,source:U32) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  discard(~S,P.invoke_write(~S,~O.Components<S>,~U32,~U32,~descriptor,~A.QueueStatus,~unrelate_body(~S),P.Targets{W.Handle{1,source},W.Handle{1,0}},tx))
def reorder(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  discard(~S,R.invoke(~S,~O.Components<S>,~U32,~U32,~hierarchy(~S),~A.QueueStatus,~reorder_body(~S),R.Args{W.Handle{1,1},[W.Handle{1,3},W.Handle{1,2}]},tx))
def component_server(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,incoming:O.Payload) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>> & Bool:
  component_done(~S,Cmp.tx_set(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Q.Rest<S>,~O.Payload,~List<&2,U32>,~Q.Token<S>,~Q.take(~S),~Q.put(~S),~O.project_payload,Q.family(~S),tx,W.Handle{1,3},incoming))
def observation_done(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,name:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,rows) = result
  observation_fields(~S,C.observe(~S,world),name ++ "\n" ++ rows)
def component_write(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  component_join(~S,component_body(X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,Cap.Request{component_server(~S)},tx,O.Payload{ANode{ANode{ALeaf{130},ALeaf{131}},ANode{ALeaf{132},ALeaf{133}}},3300}))
def observed(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+name:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  observation_done(~S,Q.registered_world(~S,world,"query-" ++ name),name)
def operations(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,phase:U32) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  match phase:
    case 0: relate(~S,~R.descriptor(~S,hierarchy(~S)),relate(~S,~R.descriptor(~S,hierarchy(~S)),relate(~S,~R.descriptor(~S,hierarchy(~S)),tx,2,1),3,1),4,3)
    case 1: relate(~S,~Q.link(~S),unrelate(~S,~Q.other(~S),relate(~S,~Q.link(~S),component_write(~S,tx),3,2),4),2,2)
    case 2: reorder(~S,tx)
    case 3: discard(~S,C.invoked(~S,~descriptors(~S),tx,W.Handle{1,3}))
    case _: discard(~S,C.invoked(~S,~descriptors(~S),tx,W.Handle{1,1}))
def queued(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,+phase:U32,text:String) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,value) = result
  applied(~S,observed(~S,W.barrier(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,world),"applied-" ++ U32.show(phase)),phase,text ++ value)
def write_runner(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,phase:U32) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Unit>:
  Sys.Succeeded{O.commit(~S,operations(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),phase),X.Success{}),Unit{}}
def ran(~S:Data,result:Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,U32,U32,Unit,write_runner(~S)>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  match result:
    case Sys.Completed{_,Sys.Succeeded{world,_}}: world
    case Sys.Completed{_,Sys.Failed{world,_}}: world
    case Sys.RegistrationRejected{_,world,_}: world
def registered(~S:Data,result:Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,U32,U32,Unit,write_runner(~S)>,phase:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  match result:
    case Sys.Registered{world,registry}: ran(~S,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~U32,~U32,~Unit,~write_runner(~S),registry,world,phase))
    case Sys.RegistrationFailed{world}: world
def write(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+phase:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>:
  registered(~S,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~U32,~U32,~Unit,~write_runner(~S),world,"relation-write-" ++ U32.show(phase),["Link.write","OtherLink.write","Parent.write","Children.write","Payload.write"]),phase)
def step(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String,+phase:U32) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & String:
  (world,text) = result
  queued(~S,observed(~S,write(~S,world,phase),"queued-" ++ U32.show(phase)),phase,text)
def captured(~S:Data,result:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & List<&2,RQ.Row<S,List<&2,U32>>>) -> String:
  (world,retained) = result
  finish(~S,step(~S,step(~S,step(~S,step(~S,step(~S,observed(~S,world,"initial"),0),1),2),3),4)) ++ "retained=" ++ Q.show_rows(~S,retained)
def capture_rows(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  captured(~S,RQ.each(~S,~List<&2,U32>,~O.Components<S>,~U32,~U32,~RQ.Row<S,List<&2,U32>>,~Q.spec_optional(~S),~Q.component_selected(~S),~Q.read_body(~S),world))
def created(~S:Data,result:W.Creation<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>) -> String:
  match result:
    case W.Created{_,world}: capture_rows(~S,Q.seeded(~S,O.spawn(~S,5n,world)))
    case _: "CREATE_REJECTED"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Q.empty(~S),W.factory(),77))
def main() -> IO(Unit):
  IO.print("Workshop\n" ++ run(~O.Workshop) ++ "\nOther\n" ++ run(~O.Other))
