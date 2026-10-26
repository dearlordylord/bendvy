import Base
import ../../../../src/ecs/ordinary-app-access.bend as Access
import ./fixture.bend as F
import ../../../../src/ecs/ordinary-app-schedules.bend as N
import ../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../src/ecs/ordinary-app-local-fields.bend as LF
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/ordinary-app-schedule.bend as Single
import ../../../../src/ecs/ordinary-app-schedule-description.bend as Detail
import ../../../../src/ecs/ordinary-query-declaration.bend as Q
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/schedule-provision.bend as SP
import ../../../../src/ecs/schedule.bend as Sch

def quoted(value:String) -> String:
  "\""++value++"\""
def bool(value:Bool) -> String:
  match value:
    case False{}:"false"
    case True{}:"true"
def join(items:List<&2,String>) -> String:
  match items:
    case []:""
    case value <> []:value
    case value <> rest:value++","++join(rest)
def quoted_items(items:List<&2,String>) -> List<&2,String>:
  match items:
    case []:[]
    case value <> rest:quoted(value) <> quoted_items(rest)
def strings(items:List<&2,String>) -> String:
  "["++join(quoted_items(items))++"]"
def ids(~S:Data,steps:List<&2,Single.PlannedStep<S>>) -> List<&2,String>:
  match steps:
    case []:[]
    case Single.PlannedStep{Sch.System{id,_},_} <> rest:U32.show(id) <> ids(~S,rest)
    case _ <> rest:ids(~S,rest)
def guarded(~S:Data,steps:List<&2,Single.PlannedStep<S>>) -> Bool:
  match steps:
    case []:False{}
    case Single.PlannedStep{Sch.System{_,condition},_} <> rest:Bool.or(Bool.not(U32.is_eq(condition,0)),guarded(~S,rest))
    case _ <> rest:guarded(~S,rest)
def barrier(~S:Data,steps:List<&2,Single.PlannedStep<S>>) -> Bool:
  match steps:
    case []:False{}
    case Single.PlannedStep{Sch.Barrier{},_} <> _:True{}
    case _ <> rest:barrier(~S,rest)
def plan(~S:Data,+value:SP.Plan<S>) -> String:
  "{\"ids\":["++join(ids(~S,Single.planned(~S,value)))++"],\"skip\":"++bool(guarded(~S,Single.planned(~S,value)))++",\"barrier\":"++bool(barrier(~S,Single.planned(~S,value)))++"}"
def maybe_plan(~S:Data,value:Maybe<&2,SP.Plan<S>>) -> String:
  match value:
    case None{}:"null"
    case Some{item}:plan(~S,item)
def named(~S:Data,item:N.Named<S>) -> String:
  match item:
    case N.Named{label,+value}:"{\"label\":"++quoted(label)++",\"ids\":["++join(ids(~S,Single.planned(~S,value)))++"],\"skip\":"++bool(guarded(~S,Single.planned(~S,value)))++",\"barrier\":"++bool(barrier(~S,Single.planned(~S,value)))++"}"
def named_items(~S:Data,items:List<&2,N.Named<S>>) -> List<&2,String>:
  match items:
    case []:[]
    case value <> rest:named(~S,value) <> named_items(~S,rest)
def state_raw(~S:Data,value:F.application(~S),counter:U32) -> F.application(~S) & String:
  match value:
    case N.Application{App.Application{schema,Build.Registered{W.World{namespace,nextId,highWater,live,capacity,depth,store,F.Resources{resourceValue},events,pending,registrations,nextSystemId,clock,lifecycle},(((unit,LF.Owner{Local.Instance{ns1,id1,name1,access1,F.Memory{values1,+count1}}}),LF.Owner{Local.Instance{ns2,id2,name2,access2,F.Memory{values2,+count2}}}),reader),recipe,debug}},+plans}:(N.Application{App.Application{schema,Build.Registered{W.World{namespace,nextId,highWater,live,capacity,depth,store,F.Resources{resourceValue},events,pending,registrations,nextSystemId,clock,lifecycle},(((unit,LF.Owner{Local.Instance{ns1,id1,name1,access1,F.Memory{values1,count1}}}),LF.Owner{Local.Instance{ns2,id2,name2,access2,F.Memory{values2,count2}}}),reader),recipe,debug}},plans},"\"memory\":["++U32.show(count1)++","++U32.show(count2)++"],\"counter\":"++U32.show(counter)++",\"plans\":["++join(named_items(~S,plans))++"]")
def observed_state(~S:Data,schema:Schema.Schema<S,F.Store,F.Resources>,owners:F.Owners(~S),recipe:Tree.Recipe<W.World<S,F.Store,F.Resources,Unit>,F.Rows(),F.observe(~S)>,debug:Bool,plans:List<&2,N.Named<S>>,result:W.World<S,F.Store,F.Resources,Unit> & DTO.Observation<F.Rows()>) -> F.application(~S) & String:
  match result:
    case (world,DTO.Observation{DTO.Product{_,counter},_}):state_raw(~S,N.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plans},counter)
def state(~S:Data,value:F.application(~S)) -> F.application(~S) & String:
  match value:
    case N.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plans}:observed_state(~S,schema,owners,recipe,debug,plans,F.observe(~S)(world))
def name(id:U32) -> String:
  match id:
    case 1:"Shared"
    case 2:"Independent"
    case 3:"Reader"
    case _:"unknown"
def ran(items:List<&2,Sch.Observation>) -> List<&2,String>:
  match items:
    case []:[]
    case Sch.Ran{id} <> rest:name(id) <> ran(rest)
    case _ <> rest:ran(rest)
def skipped(items:List<&2,Sch.Observation>) -> List<&2,String>:
  match items:
    case []:[]
    case Sch.Skipped{id} <> rest:name(id) <> skipped(rest)
    case _ <> rest:skipped(rest)
def applied(items:List<&2,Sch.Observation>) -> Bool:
  match items:
    case []:False{}
    case Sch.Applied{} <> _:True{}
    case _ <> rest:applied(rest)
def outcome(status:String,+items:List<&2,Sch.Observation>) -> String:
  "{\"status\":"++quoted(status)++",\"ran\":"++strings(ran(items))++",\"skipped\":"++strings(skipped(items))++",\"barrier\":"++bool(applied(items))++"}"
def reads(~S:Data,clauses:List<&2,Q.Clause<S>>) -> List<&2,String>:
  match clauses:
    case []:[]
    case Q.Clause{name,Q.Read{}} <> rest:name <> reads(~S,rest)
    case _ <> rest:reads(~S,rest)
def select_reads(same:Bool,current:List<&2,String>,rest:List<&2,String>) -> List<&2,String>:
  match same:
    case True{}:current
    case False{}:rest
def binding_reads(~S:Data,+id:U32,bindings:List<&2,DTO.Binding<S>>) -> List<&2,String>:
  match bindings:
    case []:[]
    case DTO.Binding{_,other,_,_,_,_,clauses} <> rest:select_reads(U32.is_eq(id,other),reads(~S,clauses),binding_reads(~S,id,rest))
def writes(~S:Data,clauses:List<&2,Q.Clause<S>>) -> List<&2,String>:
  match clauses:
    case []:[]
    case Q.Clause{name,Q.Write{}} <> rest:name <> writes(~S,rest)
    case _ <> rest:writes(~S,rest)
def binding_writes(~S:Data,+id:U32,bindings:List<&2,DTO.Binding<S>>) -> List<&2,String>:
  match bindings:
    case []:[]
    case DTO.Binding{_,other,_,_,_,_,clauses} <> rest:select_reads(U32.is_eq(id,other),writes(~S,clauses),binding_writes(~S,id,rest))
def steps(~S:Data,items:List<&2,Detail.Placement<S>>) -> List<&2,String>:
  match items:
    case []:[]
    case Detail.System{_,_,_,Some{name},_,_} <> rest:name <> steps(~S,rest)
    case Detail.Barrier{_,_} <> rest:"barrier" <> steps(~S,rest)
    case _ <> rest:steps(~S,rest)
def system_reads(~S:Data,+bindings:List<&2,DTO.Binding<S>>,items:List<&2,Detail.Placement<S>>) -> List<&2,String>:
  match items:
    case []:[]
    case Detail.System{_,_,+id,Some{name},_,_} <> rest:("{\"name\":"++quoted(name)++",\"resources\":"++strings(binding_reads(~S,id,bindings))++",\"writes\":"++strings(binding_writes(~S,id,bindings))++"}") <> system_reads(~S,bindings,rest)
    case _ <> rest:system_reads(~S,bindings,rest)
def description(~S:Data,item:Detail.Description<S,F.Rows()>) -> String:
  match item:
    case Detail.Description{Single.Description{App.Description{_,DTO.Product{bindings,_}},_,label,_},+placements}:"{\"label\":"++quoted(label)++",\"steps\":"++strings(steps(~S,placements))++",\"reads\":["++join(system_reads(~S,bindings,placements))++"]}"
def descriptions(~S:Data,items:List<&2,Detail.Description<S,F.Rows()>>) -> List<&2,String>:
  match items:
    case []:[]
    case value <> rest:description(~S,value) <> descriptions(~S,rest)
def debug(~S:Data,value:Maybe<&2,N.Description<S,F.Rows()>>) -> String:
  match value:
    case None{}:"null"
    case Some{N.Description{_,plans}}:"["++join(descriptions(~S,plans))++"]"
def used_readers(uses:List<&2,Access.Use>) -> List<&2,String>:
  match uses:
    case []:[]
    case Access.Use{_,_,name,_,Access.Reader{}} <> rest:name <> used_readers(rest)
    case _ <> rest:used_readers(rest)
def used_writers(uses:List<&2,Access.Use>) -> List<&2,String>:
  match uses:
    case []:[]
    case Access.Use{_,_,name,_,Access.Writer{}} <> rest:name <> used_writers(rest)
    case _ <> rest:used_writers(rest)
def entries(items:List<&2,Access.Entry>) -> List<&2,String>:
  match items:
    case []:[]
    case Access.Entry{Access.Resources{},key,+uses} <> rest:("{\"name\":"++quoted(key)++",\"readers\":"++strings(used_readers(uses))++",\"writers\":"++strings(used_writers(uses))++"}") <> entries(rest)
    case _ <> rest:entries(rest)
def plan_indexes(items:List<&2,N.PlanIndex>) -> List<&2,String>:
  match items:
    case []:[]
    case N.PlanIndex{label,values} <> rest:("{\"label\":"++quoted(label)++",\"resources\":["++join(entries(values))++"]}") <> plan_indexes(rest)
def index(value:Maybe<&2,N.Index>) -> String:
  match value:
    case None{}:"null"
    case Some{N.Index{_,_,plans}}:"["++join(plan_indexes(plans))++"]"
def view(schedules:String,access:String) -> String:
  match schedules:
    case "null":"null"
    case _:"{\"schedules\":"++schedules++",\"access\":"++access++"}"
