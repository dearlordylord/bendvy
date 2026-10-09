import Base
import ../../../reader-factory.bend as Factory
import public-cleanup-v1/adapter.bend as GC
import public-cleanup-v1/ports.bend as Ports
import ../../../provider.bend as P
import ../../../gameplay.bend as G
import ../../../context.bend as Ctx
import ../../../application.bend as A
import ../../../catalog.bend as Cat
import ../../../hooks.bend as H
import ../../../readers.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St
import ../../../slots.bend as Slots
import ../../observations.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

# Trusted fixture assembly only. No new public reader-disposal contract.
type Scene<S: Data> is Type:
  Scene{a: F.Observed<S>,b: F.Observed<S>,aReader: Factory.Instance<S>,bReader: Factory.Instance<S>,instances: List<&2,String>}

def plans(~S: Data) -> List<&2,A.FramePlan<S>>:
  [A.FramePlan{"seeded",[A.Body{1,"seed",G.Seed{}},A.Deferred{}]},A.FramePlan{"published",[A.Body{2,"publish",G.PlayRequest{}},A.Marker{False{}}]}]
type Initialized<S: Data> is Type:
  Initialized{value: F.Observed<S>}
  InitializationFailed{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>}
  CreationRefused{resource: P.Resources<S>}

def initialized(~S: Data,result: H.Provision<S,(world => operation => Ctx.hook_runner(~S,world,operation))>) -> Initialized<S>:
  match result:
    case H.Provisioned{world,hooks}: Initialized{F.frames(~S,plans(~S),F.Observed{A.Owners{Cat.Catalog{[]},hooks,[],[],[],[],[]},world,[]})}
    case H.ProvisionFailed{world}: InitializationFailed{world}

def delivery_view(value: Maybe<&2,R.Delivery>) -> String:
  match value:
    case None{}: "none"
    case Some{value}: List.show(&2,String,(x => x),A.delivery("actual",Some{value},[]))

def instance_view(~S: Data,instance: Factory.Instance<S>) -> Factory.Instance<S> & String:
  Factory.view(~S,instance)
def record_parts(~S: Data,label: String,a: F.Observed<S>,b: F.Observed<S>,rows: List<&2,String>,left: Factory.Instance<S> & String,right: Factory.Instance<S> & String) -> Scene<S>:
  (aReader,av)=left
  (bReader,bv)=right
  Scene{a,b,aReader,bReader,List.append(&2,String,rows,[label ++ "|A=" ++ av ++ "|B=" ++ bv])}
def record(~S: Data,+label: String,+status: String,scene: Scene<S>) -> Scene<S>:
  match scene:
    case Scene{F.Observed{ao,aw,ar},F.Observed{bo,bw,br},aReader,bReader,rows}:
      record_parts(~S,label,F.checkpoint(~S,label,ar,A.FrameResult{ao,aw,status}),F.checkpoint(~S,label,br,A.FrameResult{bo,bw,status}),rows,instance_view(~S,aReader),instance_view(~S,bReader))
def foreign_returned(~S: Data,a: F.Observed<S>,bOwners: A.Owners<S>,bRows: List<&2,String>,bReader: Factory.Instance<S>,rows: List<&2,String>,result: Factory.Returned<S>) -> Scene<S>:
  match result:
    case Factory.Returned{aReader,bWorld,delivery,status}:
      record(~S,"foreign-A-on-B",status,Scene{a,F.Observed{bOwners,bWorld,bRows},aReader,bReader,List.append(&2,String,rows,["foreign-delivery=" ++ delivery_view(delivery)])})
def foreign(~S: Data,scene: Scene<S>) -> Scene<S>:
  match scene:
    case Scene{a,F.Observed{bo,bw,br},aReader,bReader,rows}:
      foreign_returned(~S,a,bo,br,bReader,rows,Factory.invoke_owned(~S,aReader,bw,False{}))
def local_a_returned(~S: Data,aOwners: A.Owners<S>,aRows: List<&2,String>,b: F.Observed<S>,bReader: Factory.Instance<S>,rows: List<&2,String>,result: Factory.Returned<S>) -> Scene<S>:
  match result:
    case Factory.Returned{aReader,aWorld,delivery,status}:
      record(~S,"A-legitimate-retry",status,Scene{F.Observed{aOwners,aWorld,aRows},b,aReader,bReader,List.append(&2,String,rows,["A-delivery=" ++ delivery_view(delivery)])})
def local_a(~S: Data,scene: Scene<S>) -> Scene<S>:
  match scene:
    case Scene{F.Observed{ao,aw,ar},b,aReader,bReader,rows}: local_a_returned(~S,ao,ar,b,bReader,rows,Factory.invoke_owned(~S,aReader,aw,False{}))
def local_b_returned(~S: Data,a: F.Observed<S>,bOwners: A.Owners<S>,bRows: List<&2,String>,aReader: Factory.Instance<S>,rows: List<&2,String>,result: Factory.Returned<S>) -> Scene<S>:
  match result:
    case Factory.Returned{bReader,bWorld,delivery,status}: record(~S,"B-independent-instance",status,Scene{a,F.Observed{bOwners,bWorld,bRows},aReader,bReader,List.append(&2,String,rows,["B-delivery=" ++ delivery_view(delivery)])})
def local_b(~S: Data,scene: Scene<S>) -> Scene<S>:
  match scene:
    case Scene{a,F.Observed{bo,bw,br},aReader,bReader,rows}: local_b_returned(~S,a,bo,br,aReader,rows,Factory.invoke_owned(~S,bReader,bw,False{}))

def dispose_streams(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,flowId: U32,levelId: U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,fs,ls,frame,tick,trace},events,commands,regs,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,St.dispose(~P.Flow,fs,flowId),St.dispose(~P.Level,ls,levelId),frame,tick,trace},events,commands,regs,nextSystem,clock}
type Cleanup<S: Data> is Type:
  Cleaned{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>}
  CleanupRejected{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,instance: Factory.Instance<S>}
def remove_ports(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,ports: Ports.Two<S,P.FlowToken,P.LevelToken>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match ports:
    case Ports.Two{St.Reader{_,id},St.Reader{_,jd}}: dispose_streams(~S,world,id,jd)
def factory_cleanup_returned(~S: Data,result: Factory.Disposal<S>) -> Cleanup<S>:
  match result:
    case Factory.Cleaned{world}: Cleaned{world}
    case Factory.CleanupRejected{world,instance}: CleanupRejected{world,instance}
def cleanup(~S: Data,instance: Factory.Instance<S>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Cleanup<S>:
  factory_cleanup_returned(~S,Factory.dispose_owned(~S,instance,world))
def finish_pair(~S: Data,a: F.Observed<S>,b: F.Observed<S>,rows: List<&2,String>) -> String:
  "WORLD=A\n" ++ F.finish(~S,a) ++ "\nWORLD=B\n" ++ F.finish(~S,b) ++ "\nINSTANCES\n" ++ String.join(rows,"\n")
def b_cleaned(~S: Data,a: F.Observed<S>,bo: A.Owners<S>,br: List<&2,String>,rows: List<&2,String>,result: Cleanup<S>) -> String:
  match result:
    case Cleaned{world}: finish_pair(~S,a,F.checkpoint(~S,"B-owned-cleanup",br,A.FrameResult{bo,world,"cleaned"}),List.append(&2,String,rows,["B-owned-cleanup|B=disposed"]))
    case CleanupRejected{world,instance}: finish_pair(~S,a,F.checkpoint(~S,"B-cleanup-rejected",br,A.FrameResult{bo,world,"cleanup-rejected"}),List.append(&2,String,rows,["B-cleanup-rejected"]))
def survivor_observed(~S: Data,a: F.Observed<S>,b: F.Observed<S>,bReader: Factory.Instance<S>,rows: List<&2,String>) -> String:
  match b:
    case F.Observed{bo,bw,br}: b_cleaned(~S,a,bo,br,rows,cleanup(~S,bReader,bw))
def survivor_returned(~S: Data,a: F.Observed<S>,bo: A.Owners<S>,br: List<&2,String>,rows: List<&2,String>,result: Factory.Returned<S>) -> String:
  match a result:
    case F.Observed{ao,aw,ar} Factory.Returned{bReader,bw,delivery,+status}:
      survivor_observed(~S,F.checkpoint(~S,"B-survivor-empty",ar,A.FrameResult{ao,aw,status}),F.checkpoint(~S,"B-survivor-empty",br,A.FrameResult{bo,bw,status}),bReader,List.append(&2,String,rows,["B-survivor-delivery=" ++ delivery_view(delivery)]))
def survivor(~S: Data,a: F.Observed<S>,bo: A.Owners<S>,br: List<&2,String>,rows: List<&2,String>,bReader: Factory.Instance<S>,bw: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> String:
  survivor_returned(~S,a,bo,br,rows,Factory.invoke_owned(~S,bReader,bw,False{}))
def a_cleaned(~S: Data,ao: A.Owners<S>,ar: List<&2,String>,b: F.Observed<S>,bReader: Factory.Instance<S>,rows: List<&2,String>,result: Cleanup<S>) -> String:
  match b result:
    case F.Observed{bo,bw,br} Cleaned{world}: survivor(~S,F.checkpoint(~S,"A-owned-cleanup",ar,A.FrameResult{ao,world,"cleaned"}),bo,br,List.append(&2,String,rows,["A-owned-cleanup|A=disposed"]),bReader,bw)
    case b CleanupRejected{world,instance}: finish_pair(~S,F.checkpoint(~S,"A-cleanup-rejected",ar,A.FrameResult{ao,world,"cleanup-rejected"}),b,List.append(&2,String,rows,["A-cleanup-rejected"]))
def completed_local(~S: Data,scene: Scene<S>) -> String:
  match scene:
    case Scene{F.Observed{ao,aw,ar},b,aReader,bReader,rows}: a_cleaned(~S,ao,ar,b,bReader,rows,cleanup(~S,aReader,aw))
def foreign_cleanup_returned(~S: Data,a: F.Observed<S>,bo: A.Owners<S>,br: List<&2,String>,bReader: Factory.Instance<S>,rows: List<&2,String>,result: Cleanup<S>) -> String:
  match result:
    case CleanupRejected{bw,aReader}: completed_local(~S,record(~S,"foreign-disposal-rejected","cleanup-rejected",Scene{a,F.Observed{bo,bw,br},aReader,bReader,rows}))
    case Cleaned{bw}: "UNEXPECTED_FOREIGN_DISPOSAL_ACCEPTED"
def completed(~S: Data,scene: Scene<S>) -> String:
  match scene:
    case Scene{a,F.Observed{bo,bw,br},aReader,bReader,rows}: foreign_cleanup_returned(~S,a,bo,br,bReader,rows,cleanup(~S,aReader,bw))
def b_registered(~S: Data,a: F.Observed<S>,aReader: Factory.Instance<S>,bo: A.Owners<S>,br: List<&2,String>,result: Factory.Provision<S>) -> String:
  match result:
    case Factory.Provisioned{world,bReader}: completed(~S,local_b(~S,local_a(~S,foreign(~S,record(~S,"two-independent-instances","ok",Scene{a,F.Observed{bo,world,br},aReader,bReader,[]})))))
    case Factory.ProvisionFailed{world}: "READER_B_PROVISION_REJECTED"
def a_registered(~S: Data,ao: A.Owners<S>,ar: List<&2,String>,b: F.Observed<S>,result: Factory.Provision<S>) -> String:
  match b result:
    case F.Observed{bo,bw,br} Factory.Provisioned{world,aReader}: b_registered(~S,F.Observed{ao,world,ar},aReader,bo,br,Factory.provision(~S,bw,"shared-definition"))
    case b Factory.ProvisionFailed{world}: "READER_A_PROVISION_REJECTED"
def assembled(~S: Data,a: Initialized<S>,b: Initialized<S>) -> String:
  match a b:
    case Initialized{F.Observed{ao,aw,ar}} Initialized{b}: a_registered(~S,ao,ar,b,Factory.provision(~S,aw,"shared-definition"))
    case _ _: "INITIALIZATION_REJECTED"
def resource_selected(~S: Data,other: Bool,resources: P.Resources<S>) -> P.Resources<S>:
  match other resources:
    case False{} resources: resources
    case True{} P.Resources{_,flow,level,fs,ls,frame,tick,trace}: P.Resources{ANode{ALeaf{1030},ALeaf{1130}},flow,level,fs,ls,frame,tick,trace}

def resource(~S: Data,other: Bool) -> P.Resources<S>:
  resource_selected(~S,other,P.initial_resources(~S))
