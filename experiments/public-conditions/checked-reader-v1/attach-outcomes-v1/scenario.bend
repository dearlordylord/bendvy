import Base
import ../fixture.bend as F
import ../observe.bend as Obs
import /workspace/formal-proofs/bendvy/experiments/public-conditions/relation-query-check-v1/observe.bend as Prior
import /workspace/formal-proofs/bendvy/experiments/public-recovery/automatic-app-v1/observe.bend as Common
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-family-schedule.bend as Checked
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-schedule.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-bindings.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch

def Bindings(~S:Data) -> Type:B.Bindings<F.World(~S),F.Guards(~S),F.select(~S)>
type Session<S:Data> is Type:Session{app:F.Registered(~S),bindings:Bindings(~S)}
def recovered(~S:Data,value:F.Application(~S)) -> Session<S>:
  match value:
    case Checked.Application{Old.Application{Single.Application{SchemaApp.Application{schema,Build.Registered{world,(owners,(family,tick)),recipe,debug}},_,_,_,_,_},bindings}}:Session{App.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug},bindings}
def snapshot_view(~S:Data,value:Maybe<&2,SchemaApp.Description<S,F.Rows()>>) -> String:
  match value:
    case None{}:"None"
    case Some{SchemaApp.Description{entries,DTO.Product{bindings,DTO.Observation{DTO.Product{DTO.Product{Unit{},Unit{}},Unit{}},rendered}}}}:"Some{schema=" ++ List.show(&2,Fragment.Entry<S>,Prior.schema_entry(~S),entries) ++ ";bindings=" ++ List.show(&2,DTO.Binding<S>,Common.binding(~S),bindings) ++ ";rows=Product{Product{Unit,Unit},Unit};rendered=" ++ Prior.strings(rendered) ++ "}"
def checkpoint_snapshot(~S:Data,bindings:Bindings(~S),text:String,value:F.Registered(~S) & Maybe<&2,SchemaApp.Description<S,F.Rows()>>) -> Session<S> & String:
  match value:
    case (app,view):(Session{app,bindings},text ++ "\nsnapshot=" ++ snapshot_view(~S,view) ++ "\n")
def checkpoint_join(~S:Data,label:String,+entries:List<&2,Fragment.Entry<S>>,+debug:Bool,recipe:Tree.Recipe<F.World(~S),F.Rows(),F.observe(~S)>,a:F.World(~S) & String,b:F.Packed(~S) & String,c:Bindings(~S) & String) -> Session<S> & String:
  (world,wt)=a
  ((owners,(family,tick)),ot)=b
  (bindings,bt)=c
  checkpoint_snapshot(~S,bindings,label ++ "\noriginal{schema=" ++ List.show(&2,Fragment.Entry<S>,Prior.schema_entry(~S),entries) ++ ";debug=" ++ Bool.show(debug) ++ ";recipe=Recipe;" ++ wt ++ ";" ++ ot ++ ";" ++ bt ++ "}",App.snapshot(~S,~Array<U32>,~F.Resources(~S),~U32,~F.FamilyState(~S),~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),App.Application{Schema.Schema{entries},Route.Runtime{world,family,tick},owners,recipe,debug}))
def checkpoint(~S:Data,label:String,value:Session<S>) -> Session<S> & String:
  match value:
    case Session{App.Application{Schema.Schema{entries},Route.Runtime{world,family,tick},owners,recipe,debug},bindings}:checkpoint_join(~S,label,entries,debug,recipe,Obs.world(~S,world),Obs.packed(~S,(owners,(family,tick))),Obs.guards(~S,bindings))
def result(~S:Data,value:Checked.Attachment<F.Registered(~S),Bindings(~S),F.Application(~S)>) -> Session<S> & String:
  match value:
    case Checked.Invalid{app,bindings}:(Session{app,bindings},"Invalid\n")
    case Checked.Attached{app}:(recovered(~S,app),"UnexpectedAttached\n")
def attempt(~S:Data,plan:SP.Plan<S>,value:Session<S>) -> Session<S> & String:
  match value:
    case Session{app,bindings}:result(~S,Checked.attach(~S,~Array<U32>,~F.Resources(~S),~U32,~F.FamilyState(~S),~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),~F.Guards(~S),~F.select(~S),app,"attempt",plan,bindings))
def named_bindings(~S:Data,first:U32,second:U32) -> Bindings(~S):B.pair(~F.World(~S),~F.Bound(~S),~F.Bound(~S),~F.leaf_select(~S),~F.leaf_select(~S),B.bind(~F.World(~S),~(Bool & Unit),~F.guard_run(~S),first,F.guard_value(~S,False{})),B.bind(~F.World(~S),~(Bool & Unit),~F.guard_run(~S),second,F.guard_value(~S,True{})))
def replace_bindings(~S:Data,first:U32,second:U32,value:Session<S>) -> Session<S>:
  match value:
    case Session{app,_}:Session{app,named_bindings(~S,first,second)}
type Action is Data:
  Checkpoint{label:String}
  UnsupportedPlan{}
  BindingAttempt{}
  Bindings{first:U32,second:U32}
def action(~S:Data,step:Action,value:Session<S>) -> Session<S> & String:
  match step:
    case Checkpoint{label}:checkpoint(~S,label,value)
    case UnsupportedPlan{}:attempt(~S,SP.Entry{Sch.System{99,0},[]},value)
    case BindingAttempt{}:attempt(~S,F.plan(~S),value)
    case Bindings{first,second}:(replace_bindings(~S,first,second,value),"BindingsReplaced\n")
def continued(~S:Data,next:Session<S> -> String,value:Session<S> & String) -> String:
  match value:
    case (session,text):text ++ next(session)
def actions(~S:Data,steps:List<&2,Action>,session:Session<S>) -> String:
  match steps:
    case []:""
    case head <> tail:continued(~S,(session=>actions(~S,tail,session)),action(~S,head,session))
def program() -> List<&2,Action>:
  [Checkpoint{"before-unsupported-plan"},UnsupportedPlan{},Checkpoint{"unsupported-plan-returned"},UnsupportedPlan{},Checkpoint{"unsupported-plan-repeat"},Bindings{1,99},Checkpoint{"before-missing-member"},BindingAttempt{},Checkpoint{"missing-member-returned"},BindingAttempt{},Checkpoint{"missing-member-repeat"},Bindings{1,1},Checkpoint{"before-duplicate-binding"},BindingAttempt{},Checkpoint{"duplicate-binding-returned"},BindingAttempt{},Checkpoint{"terminal-duplicate-repeat"}]
def run(~S:Data,value:Maybe<&1,F.Application(~S)>) -> String:
  match value:
    case None{}:"initial-registration-refused\n"
    case Some{app}:actions(~S,program(),recovered(~S,F.enabled(~S,app,True{})))
