import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

type RegistryView is Data:
  RegistryView{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32}
type PlannedStep<S:Data> is Data:
  PlannedStep{step:Sch.Step,requirements:List<&2,SP.Requirement<S>>}
type Description<S:Data> is Data:
  Description{namespace:U32,name:String,steps:List<&2,PlannedStep<S>>,systems:List<&2,RegistryView>}
type Pack<S:Data,C:Type,R:Type,E:Data,-one:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,-two:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Pack{first:Sys.Registry<S,C,R,E,Unit,String,Unit,one>,second:Sys.Registry<S,C,R,E,Unit,String,Unit,two>}
type Application<S:Data,C:Type,R:Type,E:Data,-one:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,-two:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Application{world:W.World<S,C,R,E>,operational:SP.Plan<S>,schedule:SP.Provisioned<S,C,R,E,Pack<S,C,R,E,one,two>>,enabled:Bool}
type Build<S:Data,C:Type,R:Type,E:Data,-one:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,-two:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>> is Type:
  Built{app:Application<S,C,R,E,one,two>}
  Invalid{world:W.World<S,C,R,E>,owners:Pack<S,C,R,E,one,two>}
def planned(~S:Data,plan:SP.Plan<S>) -> List<&2,PlannedStep<S>>:
  match plan:
    case SP.Empty{}:[]
    case SP.Entry{step,needs}:[PlannedStep{step,needs}]
    case SP.Sequence{left,right}:List.append(&2,PlannedStep<S>,planned(~S,left),planned(~S,right))
def built(~S:Data,~C:Type,~R:Type,~E:Data,~one:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~two:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,world:W.World<S,C,R,E>,plan:SP.Plan<S>,enabled:Bool,result:SP.Build<S,C,R,E,Pack<S,C,R,E,one,two>>) -> Build<S,C,R,E,one,two>:
  match result:
    case SP.Invalid{owners}:Invalid{world,owners}
    case SP.Built{schedule}:Built{Application{world,plan,schedule,enabled}}
def build_plan(~S:Data,~C:Type,~R:Type,~E:Data,~one:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~two:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,world:W.World<S,C,R,E>,name:String,enabled:Bool,owners:Pack<S,C,R,E,one,two>,namespace:U32,+id1:U32,+id2:U32,+plan:SP.Plan<S>) -> Build<S,C,R,E,one,two>:
  built(~S,~C,~R,~E,~one,~two,world,plan,enabled,SP.build(~S,~C,~R,~E,~Pack<S,C,R,E,one,two>,namespace,name,plan,[id1,id2],owners))
def build(~S:Data,~C:Type,~R:Type,~E:Data,~one:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~two:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~plan:U32 -> U32 -> SP.Plan<S>,world:W.World<S,C,R,E>,name:String,enabled:Bool,owners:Pack<S,C,R,E,one,two>) -> Build<S,C,R,E,one,two>:
  match owners:
    case Pack{Sys.Registry{+ns,+id1,name1,access1,cursor1},Sys.Registry{ns2,+id2,name2,access2,cursor2}}:
      build_plan(~S,~C,~R,~E,~one,~two,world,name,enabled,Pack{Sys.Registry{ns,id1,name1,access1,cursor1},Sys.Registry{ns2,id2,name2,access2,cursor2}},ns,id1,id2,plan(id1,id2))
def described(~S:Data,~C:Type,~R:Type,~E:Data,~one:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~two:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,world:W.World<S,C,R,E>,+plan:SP.Plan<S>,+namespace:U32,+name:String,+steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,owners:Pack<S,C,R,E,one,two>) -> Application<S,C,R,E,one,two> & Maybe<&2,Description<S>>:
  match owners:
    case Pack{Sys.Registry{+n1,+i1,+s1,+a1,+c1},Sys.Registry{+n2,+i2,+s2,+a2,+c2}}:
      (Application{world,plan,SP.Provisioned{Sch.Schedule{namespace,name,steps,Pack{Sys.Registry{n1,i1,s1,a1,c1},Sys.Registry{n2,i2,s2,a2,c2}}},needs},True{}},Some{Description{namespace,name,planned(~S,plan),[RegistryView{n1,i1,s1,a1,c1},RegistryView{n2,i2,s2,a2,c2}]}})
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~one:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~two:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,app:Application<S,C,R,E,one,two>) -> Application<S,C,R,E,one,two> & Maybe<&2,Description<S>>:
  match app:
    case Application{world,plan,schedule,False{}}:(Application{world,plan,schedule,False{}},None{})
    case Application{world,plan,SP.Provisioned{Sch.Schedule{namespace,name,steps,owners},needs},True{}}:described(~S,~C,~R,~E,~one,~two,world,plan,namespace,name,steps,needs,owners)
def enable(~S:Data,~C:Type,~R:Type,~E:Data,~one:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~two:W.World<S,C,R,E> -> Unit -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,app:Application<S,C,R,E,one,two>,enabled:Bool) -> Application<S,C,R,E,one,two>:
  match app:
    case Application{world,plan,schedule,_}:Application{world,plan,schedule,enabled}
