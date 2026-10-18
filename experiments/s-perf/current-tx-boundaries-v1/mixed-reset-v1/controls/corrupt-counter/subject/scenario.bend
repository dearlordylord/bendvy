import Base
import schema.bend as S
import runtime.bend as R
import application.bend as A
import observe.bend as Observe
import query.bend as Query
import sampler.bend as Sampler
import ../private/src/ecs/ordinary-app-run.bend as Entry
import ../private/src/ecs/ordinary-app-schema.bend as App
import ../private/src/ecs/ordinary-app-composer.bend as Build
import ../private/src/ecs/ordinary-app-schedule.bend as Schedule
import ../private/src/ecs/ordinary-app-execution.bend as Execution
import ../private/src/ecs/local.bend as Local
import ../private/src/ecs/query-contract.bend as Contract
import ../private/src/ecs/world.bend as W

type Case is Type:
  Case{world:S.World(),instance:R.Instance(),wire:String,reports:List<&2,Sampler.Sample>}
  Unexpected{wire:String}
def final_world(instance:R.Instance(),label:String,status:String,localText:String,registration:String,+reports:List<&2,Sampler.Sample>,+selected:List<&2,W.Handle<S.Schema>>,observed:S.World() & String) -> Case:
  match observed:
    case (world,text):Case{world,instance,label ++ "=" ++ status ++ "|local={" ++ localText ++ "}|instance={" ++ registration ++ "}|selected=" ++ List.show(&2,W.Handle<S.Schema>,Observe.handle,selected) ++ "|final={" ++ text ++ "}\n",reports}
def scanned(instance:R.Instance(),label:String,status:String,localText:String,registration:String,reports:List<&2,Sampler.Sample>,result:Contract.Scanned<S.Schema,S.Store(),Array<U32>,U32>) -> Case:
  match result:
    case Contract.Scanned{world,handles,discards}:final_world(instance,label,status,localText,registration,List.append(&2,Sampler.Sample,reports,discards),handles,Observe.world(world))
def local_observed(label:String,status:String,world:S.World(),value:R.Instance() & R.View) -> Case:
  match value:
    case (Local.Instance{+namespace,+id,+name,+access,local},R.View{text,reports}):scanned(Local.Instance{namespace,id,name,access,local},label,status,text,"namespace=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";cursor=not-applicable",reports,Query.scan(world))
def observed(label:String,status:String,world:S.World(),owners:A.Owners()) -> Case:
  match owners:
    case (instance,_):local_observed(label,status,world,Local.observe(~S.Schema,~S.Store(),~Array<U32>,~U32,~R.State,~Bool,~Unit,~Unit,~R.runner,~R.View,~R.project,instance))
def app_observed(label:String,status:String,app:A.Application()) -> Case:
  match app:
    case Entry.Application{Schedule.Application{App.Application{_,Build.Registered{world,owners,_,_}},_,_,_,_,_},_}:observed(label,status,world,owners)
def ran(label:String,value:Execution.Run<A.Application(),S.Schema,Unit>) -> Case:
  match value:
    case Execution.Run{Schedule.Finished{app,_},_}:app_observed(label,"Finished",app)
    case Execution.Run{Schedule.Failed{app,_,_},_}:app_observed(label,"Failed",app)
    case _:Unexpected{"ERROR run\n"}
def attached(label:String,value:Schedule.Attachment<A.Registered(),A.Application()>) -> Case:
  match value:
    case Schedule.Attached{app}:ran(label,A.run(app))
    case _:Unexpected{"ERROR attach\n"}
def registered(label:String,value:A.Created) -> Case:
  match value:
    case A.Created{world,owners}:attached(label,A.attach(world,owners))
    case _:Unexpected{"ERROR register\n"}
