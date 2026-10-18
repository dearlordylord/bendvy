import Base
import ../../../../src/ecs/ordinary-app-existing-execution.bend as Existing
import ../../../../src/ecs/ordinary-app-existing-adoption.bend as Adoption
import ../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/execution-context.bend as Ctx
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/trace-facts.bend as Facts

def World() -> Type:W.World<Unit,Unit,Unit,Unit>
type Shared is Type:
  Shared{token:Array<U32>,fail:Bool}
def bumped(amount:U32,result:Array<U32> & U32) -> Array<U32>:
  match result:
    case (owner,value):Array.set(U32,owner,0,U32.add(value,amount))
def bump(amount:U32,owner:Array<U32>) -> Array<U32>:bumped(amount,Array.get(U32,owner,0))
def local_ticked(local:Array<U32>,token:Array<U32>,observed:World() & U32) -> Local.Outcome<World(),Array<U32>,Empty,Array<U32>>:
  match observed:
    case (world,_):Local.Succeeded{world,bump(1,local),bump(2,token)}
def local_runner(world:World(),local:Array<U32>,token:Array<U32>) -> Local.Outcome<World(),Array<U32>,Empty,Array<U32>>:
  local_ticked(local,token,(world,0))
def L() -> Type:Local.Instance<Unit,Unit,Unit,Unit,Array<U32>,Array<U32>,Empty,Array<U32>,local_runner>
def system_ticked(token:Array<U32>,observed:World() & U32) -> Sys.Outcome<World(),Empty,Array<U32>>:
  match observed:
    case (world,_):Sys.Succeeded{world,bump(3,token)}
def system_runner(world:World(),token:Array<U32>) -> Sys.Outcome<World(),Empty,Array<U32>>:
  system_ticked(token,(world,0))
def R() -> Type:Sys.Registry<Unit,Unit,Unit,Unit,Array<U32>,Empty,Array<U32>,system_runner>
def Owners() -> Type:(L() & R()) & Shared
def completed(fail:Bool,world:World(),trace:Facts.State) -> Sys.Outcome<Ctx.Context<World()>,Unit,Unit>:
  match fail:
    case True{}:Sys.Failed{Ctx.Context{world,trace},Unit{}}
    case False{}:Sys.Succeeded{Ctx.Context{world,trace},Unit{}}
def l_returned(+fail:Bool,trace:Facts.State,result:Local.Run<Unit,Unit,Unit,Unit,Array<U32>,Array<U32>,Empty,Array<U32>,local_runner>) -> L() & (Shared & Sys.Outcome<Ctx.Context<World()>,Unit,Unit>):
  match result:
    case Local.Completed{world,instance,Done{token}}:(instance,(Shared{token,fail},completed(fail,world,trace)))
    case Local.Completed{_,_,Fail{impossible}}:Empty.absurd(L() & (Shared & Sys.Outcome<Ctx.Context<World()>,Unit,Unit>),impossible)
    case Local.Refused{world,instance,token}:(instance,(Shared{token,fail},completed(True{},world,trace)))
def l_invoke(owner:L(),shared:Shared,context:Ctx.Context<World()>) -> L() & (Shared & Sys.Outcome<Ctx.Context<World()>,Unit,Unit>):
  match shared context:
    case Shared{token,+fail},Ctx.Context{world,facts}:l_returned(fail,facts,Local.run(~Unit,~Unit,~Unit,~Unit,~Array<U32>,~Array<U32>,~Empty,~Array<U32>,~local_runner,owner,world,token))
def r_returned(fail:Bool,trace:Facts.State,result:Sys.RunResult<Unit,Unit,Unit,Unit,Array<U32>,Empty,Array<U32>,system_runner>) -> R() & (Shared & Sys.Outcome<Ctx.Context<World()>,Unit,Unit>):
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,token}}:(registry,(Shared{token,fail},completed(False{},world,trace)))
    case Sys.Completed{_,Sys.Failed{_,impossible}}:Empty.absurd(R() & (Shared & Sys.Outcome<Ctx.Context<World()>,Unit,Unit>),impossible)
    case Sys.RegistrationRejected{registry,world,token}:(registry,(Shared{token,fail},completed(True{},world,trace)))
def r_invoke(owner:R(),shared:Shared,context:Ctx.Context<World()>) -> R() & (Shared & Sys.Outcome<Ctx.Context<World()>,Unit,Unit>):
  match shared context:
    case Shared{token,fail},Ctx.Context{world,facts}:r_returned(fail,facts,Sys.run(~Unit,~Unit,~Unit,~Unit,~Array<U32>,~Empty,~Array<U32>,~system_runner,owner,world,token))
def enabled(shared:Shared) -> Shared & Bool:(shared,True{})
def l_fold(value:L() & Shared) -> (L() & Shared) & List<&2,Fields.Fields<Unit>>:Adoption.local_fold(~Unit,~Unit,~Unit,~Unit,~Array<U32>,~Array<U32>,~Empty,~Array<U32>,~local_runner,~Shared)(value)
def l_plan(value:L() & Shared) -> (L() & Shared) & SP.Plan<Unit>:Adoption.local_plan(~Unit,~Unit,~Unit,~Unit,~Array<U32>,~Array<U32>,~Empty,~Array<U32>,~local_runner,~Shared,~enabled,~[])(value)
def l_dispatch(value:L() & Shared,context:Ctx.Context<World()>,id:U32) -> (L() & Shared) & Sys.Outcome<Ctx.Context<World()>,Unit,Unit>:Adoption.local_dispatch(~Unit,~Unit,~Unit,~Unit,~Array<U32>,~Array<U32>,~Empty,~Array<U32>,~local_runner,~Shared,~Unit,~l_invoke,~Unit{})(value,context,id)
def r_fold(value:R() & Shared) -> (R() & Shared) & List<&2,Fields.Fields<Unit>>:Adoption.system_fold(~Unit,~Unit,~Unit,~Unit,~Array<U32>,~Empty,~Array<U32>,~system_runner,~Shared)(value)
def r_plan(value:R() & Shared) -> (R() & Shared) & SP.Plan<Unit>:Adoption.system_plan(~Unit,~Unit,~Unit,~Unit,~Array<U32>,~Empty,~Array<U32>,~system_runner,~Shared,~enabled,~[])(value)
def r_dispatch(value:R() & Shared,context:Ctx.Context<World()>,id:U32) -> (R() & Shared) & Sys.Outcome<Ctx.Context<World()>,Unit,Unit>:Adoption.system_dispatch(~Unit,~Unit,~Unit,~Unit,~Array<U32>,~Empty,~Array<U32>,~system_runner,~Shared,~Unit,~r_invoke,~Unit{})(value,context,id)
def fold(value:Owners()) -> Owners() & List<&2,Fields.Fields<Unit>>:Existing.pair_fold(~Unit,~L(),~R(),~Shared,~l_fold,~r_fold,value)
def plan(value:Owners()) -> Owners() & SP.Plan<Unit>:Existing.pair_plan(~Unit,~L(),~R(),~Shared,~l_plan,~r_plan,value)
def dispatch(value:Owners(),context:Ctx.Context<World()>,id:U32) -> Owners() & Sys.Outcome<Ctx.Context<World()>,Unit,Unit>:Existing.pair_dispatch(~Unit,~World(),~L(),~R(),~Shared,~Unit,~l_fold,~l_dispatch,~r_dispatch,value,context,id)
def provide(world:World()) -> World() & List<&2,SP.Requirement<Unit>>:(world,[])
def Registered() -> Type:Exec.Registered<Unit,World(),Owners(),Unit,Build.empty_observe(~World()),fold,Unit,plan,dispatch,provide>
def Application() -> Type:Entry.Application<Unit,Unit,Unit,Unit,Owners(),Unit,Build.empty_observe(~World()),fold,Unit,plan,dispatch,provide>
def attach(world:World(),owners:Owners()) -> Schedule.Attachment<Registered(),Application()>:
  Entry.attach(~Unit,~Unit,~Unit,~Unit,~Owners(),~Unit,~Build.empty_observe(~World()),~fold,~Unit,~plan,~dispatch,~provide,Schema.Schema{[]},Existing.registered(~Unit,~World(),~Owners(),~fold,~Unit,~plan,~dispatch,~provide,world,owners),"existing",False{})
def run(app:Application()) -> Execution.Run<Application(),Unit,Unit>:Entry.run(~Unit,~Unit,~Unit,~Unit,~Owners(),~Unit,~Build.empty_observe(~World()),~fold,~Unit,~plan,~dispatch,~provide,app)
type Created is Type:
  Created{world:World(),owners:Owners()}
  Refused{}
def system_registered(local:L(),fail:Bool,result:Sys.RegistrationResult<Unit,Unit,Unit,Unit,Array<U32>,Empty,Array<U32>,system_runner>) -> Created:
  match result:
    case Sys.Registered{world,registry}:Created{world,((local,registry),Shared{Array.new(U32,1n,100),fail})}
    case _:Refused{}
def local_registered(fail:Bool,result:Local.Registered<Unit,Unit,Unit,Unit,Array<U32>,Array<U32>,Empty,Array<U32>,local_runner>) -> Created:
  match result:
    case Local.Registered{world,instance}:system_registered(instance,fail,Sys.register(~Unit,~Unit,~Unit,~Unit,~Array<U32>,~Empty,~Array<U32>,~system_runner,world,"R",[]))
    case _:Refused{}
def register(world:World(),fail:Bool) -> Created:local_registered(fail,Local.register(~Unit,~Unit,~Unit,~Unit,~Array<U32>,~Array<U32>,~Empty,~Array<U32>,~local_runner,world,"L",[],Array.new(U32,1n,10)))
def empty(_:Unit) -> Unit:Unit{}
def numbered(value:Array<U32> & U32) -> String:
  match value:
    case (_,number):U32.show(number)
def number(value:Array<U32>) -> String:numbered(Array.get(U32,value,0))
def observed(label:String,status:String,world:World(),owners:Owners()) -> String:
  match world owners:
    case W.World{_,_,_,_,_,_,registrations,next,clock},((Local.Instance{_,lid,_,_,local},Sys.Registry{_,rid,_,_,cursor}),Shared{token,_}):label ++ "=" ++ status ++ " local=" ++ number(local) ++ " token=" ++ number(token) ++ " clock=" ++ U32.show(clock) ++ " ids=" ++ U32.show(lid) ++ "," ++ U32.show(rid) ++ " next=" ++ U32.show(next) ++ " cursor=" ++ U32.show(cursor) ++ "\n"
def app_observed(label:String,status:String,app:Application()) -> String:
  match app:
    case Entry.Application{Schedule.Application{App.Application{_,Build.Registered{world,owners,_,_}},_,_,_,_,_},_}:observed(label,status,world,owners)
def ran(label:String,value:Execution.Run<Application(),Unit,Unit>) -> String:
  match value:
    case Execution.Run{Schedule.Finished{app,_},_}:app_observed(label,"Finished",app)
    case Execution.Run{Schedule.Failed{app,_,_},_}:app_observed(label,"Failed",app)
    case _:"ERROR run\n"
def attached(label:String,value:Schedule.Attachment<Registered(),Application()>) -> String:
  match value:
    case Schedule.Attached{app}:ran(label,run(app))
    case _:"ERROR attach\n"
def ordinary(label:String,value:Created) -> IO(Unit):
  match value:
    case Created{world,owners}:IO.write(attached(label,attach(world,owners)))
    case _:IO.die(Unit,1,"creation refused")
def normal(value:Created) -> IO(Unit):ordinary("normal",value)
def failing(value:Created) -> IO(Unit):ordinary("failure",value)
def wrong_returned(right:R(),result:(L() & Shared) & Sys.Outcome<Ctx.Context<World()>,Unit,Unit>) -> String:
  match result:
    case ((left,shared),Sys.Failed{Ctx.Context{world,_},_}):observed("wrong","Failed",world,((left,right),shared))
    case _:"ERROR wrong\n"
def wrong(value:Created) -> IO(Unit):
  match value:
    case Created{world,((left,Sys.Registry{ns,+id,name,access,cursor}),shared)}:IO.write(wrong_returned(Sys.Registry{ns,id,name,access,cursor},l_dispatch((left,shared),Ctx.Context{world,Facts.Off{}},id)))
    case _:IO.die(Unit,1,"creation refused")
def foreign_attached(distinct:Bool,colliding:Bool,value:Schedule.Attachment<Registered(),Application()>) -> String:
  match value:
    case Schedule.Invalid{Exec.Registered{Build.Registered{world,owners,_,_},_}}:"foreign distinct=" ++ Bool.show(distinct) ++ " colliding=" ++ Bool.show(colliding) ++ " " ++ observed("attach","Invalid",world,owners)
    case _:"ERROR foreign\n"
def foreign_pair(first:Created,second:Created) -> IO(Unit):
  match first second:
    case Created{W.World{+ns,a,c,r,e,p,regs,n,k},((Local.Instance{ln,+li,lname,la,local},leftR),shared)},Created{W.World{+actual,ba,bc,br,be,bp,bregs,bn,bk},((Local.Instance{_,+bi,_,_,_},_),_)}:IO.write(foreign_attached(Bool.not(U32.is_eq(ns,actual)),U32.is_eq(li,bi),attach(W.World{actual,ba,bc,br,be,bp,bregs,bn,bk},((Local.Instance{ln,li,lname,la,local},leftR),shared))))
    case _,_:IO.die(Unit,1,"foreign creation refused")
