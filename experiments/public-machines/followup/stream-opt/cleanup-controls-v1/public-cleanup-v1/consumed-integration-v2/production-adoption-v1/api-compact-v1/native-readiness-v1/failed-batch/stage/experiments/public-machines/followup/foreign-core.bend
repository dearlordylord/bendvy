import Base
import stream-opt/cleanup-controls-v1/public-cleanup-v1/adapter.bend as G
import stream-opt/cleanup-controls-v1/public-cleanup-v1/ports.bend as Ports
import ../provider.bend as P
import ../gameplay.bend as G
import ../context.bend as Ctx
import ../application.bend as A
import ../catalog.bend as Cat
import ../hooks.bend as H
import ../readers.bend as R
import stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine-stream.bend as St
import ../slots.bend as Slots
import observations.bend as F
import stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/world.bend as W
import stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/system.bend as Sys

# Trusted fixture assembly only. No new public reader-disposal contract.
type Scene<S: Data> is Type:
  Scene{a: F.Observed<S>,b: F.Observed<S>,aReader: R.Instance<S,(world => input => R.runner(~S,world,input))>,bReader: R.Instance<S,(world => input => R.runner(~S,world,input))>,instances: List<&2,String>}

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

# The successful branch uses the actual returned Registry and both reader caps.
def instance_view_returned(~S: Data,pair: Slots.Entry<R.Instance<S,(world => input => R.runner(~S,world,input))>> & String) -> R.Instance<S,(world => input => R.runner(~S,world,input))> & String:
  match pair:
    case (Slots.Entry{_,instance},view): (instance,view)
def instance_view(~S: Data,instance: R.Instance<S,(world => input => R.runner(~S,world,input))>) -> R.Instance<S,(world => input => R.runner(~S,world,input))> & String:
  instance_view_returned(~S,F.reader(~S,Slots.Entry{99,instance}))
def record_parts(~S: Data,label: String,a: F.Observed<S>,b: F.Observed<S>,rows: List<&2,String>,left: R.Instance<S,(world => input => R.runner(~S,world,input))> & String,right: R.Instance<S,(world => input => R.runner(~S,world,input))> & String) -> Scene<S>:
  (aReader,av)=left
  (bReader,bv)=right
  Scene{a,b,aReader,bReader,List.append(&2,String,rows,[label ++ "|A=" ++ av ++ "|B=" ++ bv])}
def record(~S: Data,+label: String,+status: String,scene: Scene<S>) -> Scene<S>:
  match scene:
    case Scene{F.Observed{ao,aw,ar},F.Observed{bo,bw,br},aReader,bReader,rows}:
      record_parts(~S,label,F.checkpoint(~S,label,ar,A.FrameResult{ao,aw,status}),F.checkpoint(~S,label,br,A.FrameResult{bo,bw,status}),rows,instance_view(~S,aReader),instance_view(~S,bReader))
def foreign_returned(~S: Data,a: F.Observed<S>,bOwners: A.Owners<S>,bRows: List<&2,String>,bReader: R.Instance<S,(world => input => R.runner(~S,world,input))>,rows: List<&2,String>,result: R.Returned<S,(world => input => R.runner(~S,world,input))>) -> Scene<S>:
  match result:
    case R.Returned{aReader,bWorld,delivery,status}:
      record(~S,"foreign-A-on-B",status,Scene{a,F.Observed{bOwners,bWorld,bRows},aReader,bReader,List.append(&2,String,rows,["foreign-delivery=" ++ delivery_view(delivery)])})
def foreign(~S: Data,scene: Scene<S>) -> Scene<S>:
  match scene:
    case Scene{a,F.Observed{bo,bw,br},aReader,bReader,rows}:
      foreign_returned(~S,a,bo,br,bReader,rows,R.invoke(~S,~(world => input => R.runner(~S,world,input)),aReader,bw,False{}))
def local_a_returned(~S: Data,aOwners: A.Owners<S>,aRows: List<&2,String>,b: F.Observed<S>,bReader: R.Instance<S,(world => input => R.runner(~S,world,input))>,rows: List<&2,String>,result: R.Returned<S,(world => input => R.runner(~S,world,input))>) -> Scene<S>:
  match result:
    case R.Returned{aReader,aWorld,delivery,status}:
      record(~S,"A-legitimate-retry",status,Scene{F.Observed{aOwners,aWorld,aRows},b,aReader,bReader,List.append(&2,String,rows,["A-delivery=" ++ delivery_view(delivery)])})
def local_a(~S: Data,scene: Scene<S>) -> Scene<S>:
  match scene:
    case Scene{F.Observed{ao,aw,ar},b,aReader,bReader,rows}: local_a_returned(~S,ao,ar,b,bReader,rows,R.invoke(~S,~(world => input => R.runner(~S,world,input)),aReader,aw,False{}))
def local_b_returned(~S: Data,a: F.Observed<S>,bOwners: A.Owners<S>,bRows: List<&2,String>,aReader: R.Instance<S,(world => input => R.runner(~S,world,input))>,rows: List<&2,String>,result: R.Returned<S,(world => input => R.runner(~S,world,input))>) -> Scene<S>:
  match result:
    case R.Returned{bReader,bWorld,delivery,status}: record(~S,"B-independent-instance",status,Scene{a,F.Observed{bOwners,bWorld,bRows},aReader,bReader,List.append(&2,String,rows,["B-delivery=" ++ delivery_view(delivery)])})
def local_b(~S: Data,scene: Scene<S>) -> Scene<S>:
  match scene:
    case Scene{a,F.Observed{bo,bw,br},aReader,bReader,rows}: local_b_returned(~S,a,bo,br,aReader,rows,R.invoke(~S,~(world => input => R.runner(~S,world,input)),bReader,bw,False{}))

def dispose_streams(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,flowId: U32,levelId: U32) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match world:
    case W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,fs,ls,frame,tick,trace},events,commands,regs,nextSystem,clock}:
      W.World{ns,next,high,live,capacity,depth,store,P.Resources{owned,flow,level,St.dispose(~P.Flow,fs,flowId),St.dispose(~P.Level,ls,levelId),frame,tick,trace},events,commands,regs,nextSystem,clock}
type Cleanup<S: Data> is Type:
  Cleaned{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>}
  CleanupRejected{world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,instance: R.Instance<S,(world => input => R.runner(~S,world,input))>}
def remove_ports(~S: Data,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>,ports: Ports.Two<S,P.FlowToken,P.LevelToken>) -> W.World<S,P.Store<S>,P.Resources<S>,Unit>:
  match ports:
    case Ports.Two{St.Reader{_,id},St.Reader{_,jd}}: dispose_streams(~S,world,id,jd)
def generic_cleanup_returned(~S: Data,result: G.Cleanup<S,P.Store<S>,P.Resources<S>,Unit,R.Input,R.Failure,R.Delivery,(world => input => R.runner(~S,world,input)),Ports.Two<S,P.FlowToken,P.LevelToken>>) -> Cleanup<S>:
  match result:
    case G.Cleaned{world}: Cleaned{world}
    case G.CleanupRejected{world,G.Instance{registry,Ports.Two{flow,level}}}: CleanupRejected{world,R.Instance{registry,flow,level}}
def cleanup(~S: Data,instance: R.Instance<S,(world => input => R.runner(~S,world,input))>,world: W.World<S,P.Store<S>,P.Resources<S>,Unit>) -> Cleanup<S>:
  match instance:
    case R.Instance{registry,flow,level}:
      generic_cleanup_returned(~S,G.cleanup(~S,~P.Store<S>,~P.Resources<S>,~Unit,~R.Input,~R.Failure,~R.Delivery,~(world => input => R.runner(~S,world,input)),~Ports.Two<S,P.FlowToken,P.LevelToken>,~(ports => namespace => id => Ports.validate_two(~S,~P.FlowToken,~P.LevelToken,ports,namespace,id)),~(world => ports => remove_ports(~S,world,ports)),G.Instance{registry,Ports.Two{flow,level}},world))

def finish_pair(~S: Data,a: F.Observed<S>,b: F.Observed<S>,rows: List<&2,String>) -> String:
  "WORLD=A\n" ++ F.finish(~S,a) ++ "\nWORLD=B\n" ++ F.finish(~S,b) ++ "\nINSTANCES\n" ++ String.join(rows,"\n")
def b_cleaned(~S: Data,a: F.Observed<S>,bo: A.Owners<S>,br: List<&2,String>,rows: List<&2,String>,result: Cleanup<S>) -> String:
  match result:
    case Cleaned{world}: finish_pair(~S,a,F.checkpoint(~S,"B-owned-cleanup",br,A.FrameResult{bo,world,"cleaned"}),List.append(&2,String,rows,["B-owned-cleanup|B=disposed"]))
    case CleanupRejected{world,instance}: finish_pair(~S,a,F.checkpoint(~S,"B-cleanup-rejected",br,A.FrameResult{bo,world,"cleanup-rejected"}),List.append(&2,String,rows,["B-cleanup-rejected"]))
def a_cleaned(~S: Data,ao: A.Owners<S>,ar: List<&2,String>,b: F.Observed<S>,bReader: R.Instance<S,(world => input => R.runner(~S,world,input))>,rows: List<&2,String>,result: Cleanup<S>) -> String:
  match b result:
    case F.Observed{bo,bw,br} Cleaned{world}: b_cleaned(~S,F.checkpoint(~S,"A-owned-cleanup",ar,A.FrameResult{ao,world,"cleaned"}),bo,br,List.append(&2,String,rows,["A-owned-cleanup|A=disposed"]),cleanup(~S,bReader,bw))
    case b CleanupRejected{world,instance}: finish_pair(~S,F.checkpoint(~S,"A-cleanup-rejected",ar,A.FrameResult{ao,world,"cleanup-rejected"}),b,List.append(&2,String,rows,["A-cleanup-rejected"]))
def completed(~S: Data,scene: Scene<S>) -> String:
  match scene:
    case Scene{F.Observed{ao,aw,ar},b,aReader,bReader,rows}: a_cleaned(~S,ao,ar,b,bReader,rows,cleanup(~S,aReader,aw))
def b_registered(~S: Data,a: F.Observed<S>,aReader: R.Instance<S,(world => input => R.runner(~S,world,input))>,bo: A.Owners<S>,br: List<&2,String>,result: R.Provision<S,(world => input => R.runner(~S,world,input))>) -> String:
  match result:
    case R.Provisioned{world,bReader}: completed(~S,local_b(~S,local_a(~S,foreign(~S,record(~S,"two-independent-instances","ok",Scene{a,F.Observed{bo,world,br},aReader,bReader,[]})))))
    case R.ProvisionFailed{world}: "READER_B_PROVISION_REJECTED"
def a_registered(~S: Data,ao: A.Owners<S>,ar: List<&2,String>,b: F.Observed<S>,result: R.Provision<S,(world => input => R.runner(~S,world,input))>) -> String:
  match b result:
    case F.Observed{bo,bw,br} R.Provisioned{world,aReader}: b_registered(~S,F.Observed{ao,world,ar},aReader,bo,br,R.provision(~S,~(world => input => R.runner(~S,world,input)),bw,"shared-definition"))
    case b R.ProvisionFailed{world}: "READER_A_PROVISION_REJECTED"
def assembled(~S: Data,a: Initialized<S>,b: Initialized<S>) -> String:
  match a b:
    case Initialized{F.Observed{ao,aw,ar}} Initialized{b}: a_registered(~S,ao,ar,b,R.provision(~S,~(world => input => R.runner(~S,world,input)),aw,"shared-definition"))
    case _ _: "INITIALIZATION_REJECTED"
def resource_selected(~S: Data,other: Bool,resources: P.Resources<S>) -> P.Resources<S>:
  match other resources:
    case False{} resources: resources
    case True{} P.Resources{_,flow,level,fs,ls,frame,tick,trace}: P.Resources{ANode{ALeaf{1030},ALeaf{1130}},flow,level,fs,ls,frame,tick,trace}

def resource(~S: Data,other: Bool) -> P.Resources<S>:
  resource_selected(~S,other,P.initial_resources(~S))
