import Base
import ../private/src/ecs/ordinary-declaration.bend as Identity
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-domain.bend as D
import motion-family.bend as Family
import motion-reader.bend as Reader
import motion-parameters.bend as P
import motion-systems.bend as S
import ../private/src/ecs/local.bend as Local
import ../private/src/ecs/system.bend as Sys
import ../private/src/ecs/world.bend as W
import ../private/src/ecs/event-family-routing.bend as Route
import ../private/src/ecs/ordinary-reader-system.bend as O

type FailedLocals is Type:
  First{capture:Array<U32>}
  Second{spawn:S.Instance(),capture:Array<U32>}
  Third{spawn:S.Instance(),update:S.Instance(),capture:Array<U32>}
type Returned is Type:
  Ready{world:F.World(),owners:S.Owners}
  LocalRejected{world:F.World(),owners:FailedLocals}
  FastRejected{spawn:S.Instance(),update:S.Instance(),dispose:S.Instance(),result:Reader.Definition()}
  SlowRejected{spawn:S.Instance(),update:S.Instance(),dispose:S.Instance(),fast:Reader.Provider(),result:Reader.Definition()}
def capture(tag:U32) -> Array<U32>:ANode{ALeaf{0},ALeaf{tag}}
def local_register(world:F.World(),name:String,access:List<&2,String>,tag:U32) -> Local.Registered<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),Array<U32>,S.Args,Unit,D.Frame,S.local_runner>:
  Local.register(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~Array<U32>,~S.Args,~Unit,~D.Frame,~S.local_runner,world,name,access,capture(tag))
def completed(count:U32,spawn:S.Instance(),update:S.Instance(),dispose:S.Instance(),fast:Reader.Provider(),slow:Reader.Provider(),context:Family.Context()) -> Returned:
  match spawn update dispose fast slow context:
    case Local.Instance{ns0,+id0,name0,access0,cap0} Local.Instance{ns1,+id1,name1,access1,cap1} Local.Instance{ns2,+id2,name2,access2,cap2} O.Provider{Sys.Registry{ns3,+id3,name3,access3,cursor3},reader3,param3,decl3} O.Provider{Sys.Registry{ns4,+id4,name4,access4,cursor4},reader4,param4,decl4} Route.Runtime{world,meta,tick}:
      Ready{world,S.Owners{Local.Instance{ns0,id0,name0,access0,cap0},Local.Instance{ns1,id1,name1,access1,cap1},Local.Instance{ns2,id2,name2,access2,cap2},O.Provider{Sys.Registry{ns3,id3,name3,access3,cursor3},reader3,param3,decl3},O.Provider{Sys.Registry{ns4,id4,name4,access4,cursor4},reader4,param4,decl4},meta,tick,D.Frame{count,0,None{},[],[]},0,S.IDs{id0,id1,id2,id3,id4},[],[]}}
def slow_registered(count:U32,spawn:S.Instance(),update:S.Instance(),dispose:S.Instance(),fast:Reader.Provider(),result:Reader.Definition()) -> Returned:
  match result:
    case O.DefinitionRegistered{context,provider}:completed(count,spawn,update,dispose,fast,provider,context)
    case result:SlowRejected{spawn,update,dispose,fast,result}
def fast_registered(count:U32,spawn:S.Instance(),update:S.Instance(),dispose:S.Instance(),result:Reader.Definition()) -> Returned:
  match result:
    case O.DefinitionRegistered{context,provider}:slow_registered(count,spawn,update,dispose,provider,Reader.define(context,"Slow"))
    case result:FastRejected{spawn,update,dispose,result}
def dispose_registered(count:U32,spawn:S.Instance(),update:S.Instance(),result:Local.Registered<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),Array<U32>,S.Args,Unit,D.Frame,S.local_runner>) -> Returned:
  match result:
    case Local.Registered{world,owner}:fast_registered(count,spawn,update,owner,Reader.define(Family.start(world),"Fast"))
    case Local.RegistrationRejected{world,capture}:LocalRejected{world,Third{spawn,update,capture}}
def update_registered(count:U32,spawn:S.Instance(),result:Local.Registered<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),Array<U32>,S.Args,Unit,D.Frame,S.local_runner>) -> Returned:
  match result:
    case Local.Registered{world,owner}:dispose_registered(count,spawn,owner,local_register(world,"Dispose",[Identity.key(~T.MotionSchema,~T.Position,F.main_identity()),"command:remove","command:despawn"],103))
    case Local.RegistrationRejected{world,capture}:LocalRejected{world,Second{spawn,capture}}
def spawn_registered(count:U32,result:Local.Registered<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),Array<U32>,S.Args,Unit,D.Frame,S.local_runner>) -> Returned:
  match result:
    case Local.Registered{world,owner}:update_registered(count,owner,local_register(world,"Update",[Identity.key(~T.MotionSchema,~T.Position,F.main_identity()),"event:ping"],102))
    case Local.RegistrationRejected{world,capture}:LocalRejected{world,First{capture}}
def run(world:F.World(),count:U32) -> Returned:spawn_registered(count,local_register(world,"Spawn",["command:spawn"],101))
