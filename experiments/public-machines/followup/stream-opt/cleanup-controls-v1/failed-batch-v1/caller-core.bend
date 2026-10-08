import Base
import ../../../../provider.bend as P
import ../../../../application.bend as A
import ../../../../readers.bend as R
import ../../../../slots.bend as Slots
import ../../../observations.bend as F
import ../../../../../../src/ecs/world.bend as W
import ../caller-core.bend as B

type Scene<S: Data> is Type:
  Scene{a: F.Observed<S>,b: F.Observed<S>,first: R.Instance<S,(world => input => R.runner(~S,world,input))>,survivor: R.Instance<S,(world => input => R.runner(~S,world,input))>,rows: List<&2,String>}
def record_parts(~S: Data,label: String,a: F.Observed<S>,b: F.Observed<S>,rows: List<&2,String>,left: R.Instance<S,(world => input => R.runner(~S,world,input))> & String,right: R.Instance<S,(world => input => R.runner(~S,world,input))> & String) -> Scene<S>:
  (first,f)=left
  (survivor,s)=right
  Scene{a,b,first,survivor,List.append(&2,String,rows,[label ++ "|first=" ++ f ++ "|survivor=" ++ s])}
def record(~S: Data,+label: String,+status: String,scene: Scene<S>) -> Scene<S>:
  match scene:
    case Scene{F.Observed{ao,aw,ar},F.Observed{bo,bw,br},first,survivor,rows}:
      record_parts(~S,label,F.checkpoint(~S,label,ar,A.FrameResult{ao,aw,status}),F.checkpoint(~S,label,br,A.FrameResult{bo,bw,status}),rows,B.instance_view(~S,first),B.instance_view(~S,survivor))
def final_cleanup(~S: Data,b: F.Observed<S>,ao: A.Owners<S>,ar: List<&2,String>,rows: List<&2,String>,result: B.Cleanup<S>) -> String:
  match b result:
    case F.Observed{bo,bw,br} B.Cleaned{aw}:
      B.finish_pair(~S,F.checkpoint(~S,"survivor-owned-cleanup",ar,A.FrameResult{ao,aw,"cleaned"}),F.checkpoint(~S,"survivor-owned-cleanup",br,A.FrameResult{bo,bw,"cleaned"}),List.append(&2,String,rows,["survivor-owned-cleanup|first=disposed|survivor=disposed"]))
    case _ _: "UNEXPECTED_SURVIVOR_DISPOSAL_REJECTION"
def cleanup_survivor(~S: Data,a: F.Observed<S>,b: F.Observed<S>,rows: List<&2,String>,pair: R.Instance<S,(world => input => R.runner(~S,world,input))> & String) -> String:
  match a pair:
    case F.Observed{ao,aw,ar}, (survivor,view): final_cleanup(~S,b,ao,ar,List.append(&2,String,rows,["same-world-survivor-read|first=disposed|survivor=" ++ view]),B.cleanup(~S,survivor,aw))
def survivor_returned(~S: Data,ao: A.Owners<S>,ar: List<&2,String>,b: F.Observed<S>,rows: List<&2,String>,result: R.Returned<S,(world => input => R.runner(~S,world,input))>) -> String:
  match b result:
    case F.Observed{bo,bw,br} R.Returned{survivor,aw,delivery,+status}:
      cleanup_survivor(~S,F.checkpoint(~S,"same-world-survivor-read",ar,A.FrameResult{ao,aw,status}),F.checkpoint(~S,"same-world-survivor-read",br,A.FrameResult{bo,bw,status}),List.append(&2,String,rows,["survivor-delivery=" ++ B.delivery_view(delivery)]),B.instance_view(~S,survivor))
def invoke_survivor(~S: Data,a: F.Observed<S>,b: F.Observed<S>,rows: List<&2,String>,pair: R.Instance<S,(world => input => R.runner(~S,world,input))> & String) -> String:
  match a pair:
    case F.Observed{ao,aw,ar}, (survivor,view): survivor_returned(~S,ao,ar,b,List.append(&2,String,rows,["first-owned-cleanup|first=disposed|survivor=" ++ view]),R.invoke(~S,~(world => input => R.runner(~S,world,input)),survivor,aw,False{}))
def first_cleaned(~S: Data,ao: A.Owners<S>,ar: List<&2,String>,b: F.Observed<S>,survivor: R.Instance<S,(world => input => R.runner(~S,world,input))>,rows: List<&2,String>,result: B.Cleanup<S>) -> String:
  match b result:
    case F.Observed{bo,bw,br} B.Cleaned{aw}:
      invoke_survivor(~S,F.checkpoint(~S,"first-owned-cleanup",ar,A.FrameResult{ao,aw,"cleaned"}),F.checkpoint(~S,"first-owned-cleanup",br,A.FrameResult{bo,bw,"cleaned"}),rows,B.instance_view(~S,survivor))
    case _ _: "UNEXPECTED_LOCAL_FIRST_DISPOSAL_REJECTION"
def local_cleanup(~S: Data,scene: Scene<S>) -> String:
  match scene:
    case Scene{F.Observed{ao,aw,ar},b,first,survivor,rows}: first_cleaned(~S,ao,ar,b,survivor,rows,B.cleanup(~S,first,aw))
def foreign_cleanup_returned(~S: Data,a: F.Observed<S>,bo: A.Owners<S>,br: List<&2,String>,survivor: R.Instance<S,(world => input => R.runner(~S,world,input))>,rows: List<&2,String>,result: B.Cleanup<S>) -> String:
  match result:
    case B.CleanupRejected{bw,first}: local_cleanup(~S,record(~S,"foreign-disposal-rejected","cleanup-rejected",Scene{a,F.Observed{bo,bw,br},first,survivor,rows}))
    case B.Cleaned{_}: "UNEXPECTED_FOREIGN_DISPOSAL_ACCEPTED"
def foreign_cleanup(~S: Data,scene: Scene<S>) -> String:
  match scene:
    case Scene{a,F.Observed{bo,bw,br},first,survivor,rows}: foreign_cleanup_returned(~S,a,bo,br,survivor,rows,B.cleanup(~S,first,bw))
def failed_returned(~S: Data,ao: A.Owners<S>,ar: List<&2,String>,b: F.Observed<S>,survivor: R.Instance<S,(world => input => R.runner(~S,world,input))>,rows: List<&2,String>,result: R.Returned<S,(world => input => R.runner(~S,world,input))>) -> String:
  match result:
    case R.Returned{first,aw,delivery,status}: foreign_cleanup(~S,record(~S,"reader-failed",status,Scene{F.Observed{ao,aw,ar},b,first,survivor,List.append(&2,String,rows,["failed-delivery=" ++ B.delivery_view(delivery)])}))
def fail_first(~S: Data,scene: Scene<S>) -> String:
  match scene:
    case Scene{F.Observed{ao,aw,ar},b,first,survivor,rows}: failed_returned(~S,ao,ar,b,survivor,rows,R.invoke(~S,~(world => input => R.runner(~S,world,input)),first,aw,True{}))
def survivor_registered(~S: Data,ao: A.Owners<S>,ar: List<&2,String>,b: F.Observed<S>,first: R.Instance<S,(world => input => R.runner(~S,world,input))>,result: R.Provision<S,(world => input => R.runner(~S,world,input))>) -> String:
  match result:
    case R.Provisioned{aw,survivor}: fail_first(~S,record(~S,"two-same-world-readers","ok",Scene{F.Observed{ao,aw,ar},b,first,survivor,[]}))
    case R.ProvisionFailed{_}: "SURVIVOR_PROVISION_REJECTED"
def first_registered(~S: Data,ao: A.Owners<S>,ar: List<&2,String>,b: F.Observed<S>,result: R.Provision<S,(world => input => R.runner(~S,world,input))>) -> String:
  match result:
    case R.Provisioned{aw,first}: survivor_registered(~S,ao,ar,b,first,R.provision(~S,~(world => input => R.runner(~S,world,input)),aw,"survivor"))
    case R.ProvisionFailed{_}: "FIRST_PROVISION_REJECTED"
def assembled(~S: Data,a: B.Initialized<S>,b: B.Initialized<S>) -> String:
  match a b:
    case B.Initialized{F.Observed{ao,aw,ar}} B.Initialized{b}: first_registered(~S,ao,ar,b,R.provision(~S,~(world => input => R.runner(~S,world,input)),aw,"failed-reader"))
    case _ _: "INITIALIZATION_REJECTED"
