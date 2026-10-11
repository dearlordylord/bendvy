import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
# Names derive only from the retained actual Registry namespace/id. A missing
# binding stays None; this adapter never invents a label or condition name.
type Placement<S:Data> is Data:
  System{position:Nat,namespace:U32,id:U32,name:Maybe<&2,String>,condition:U32,requirements:List<&2,SP.Requirement<S>>}
  Phase{position:Nat,name:String,requirements:List<&2,SP.Requirement<S>>}
  Barrier{position:Nat,requirements:List<&2,SP.Requirement<S>>}
type Description<S:Data,Rows:Data> is Data:
  Description{original:Schedule.Description<S,Rows>,placements:List<&2,Placement<S>>}
def selected(same:Bool,name:String,next:Maybe<&2,String>) -> Maybe<&2,String>:
  match same:
    case False{}:next
    case True{}:None{}
def binding_name(~S:Data,+namespace:U32,+id:U32,bindings:List<&2,DTO.Binding<S>>) -> Maybe<&2,String>:
  match bindings:
    case []:None{}
    case DTO.Binding{otherNamespace,otherId,name,_,_,_,_} <> rest:selected(Bool.and(U32.is_eq(namespace,otherNamespace),U32.is_eq(id,otherId)),name,binding_name(~S,namespace,id,rest))
def step(~S:Data,+namespace:U32,bindings:List<&2,DTO.Binding<S>>,position:Nat,planned:Schedule.PlannedStep<S>) -> Placement<S>:
  match planned:
    case Schedule.PlannedStep{Sch.System{+id,condition},requirements}:System{position,namespace,id,binding_name(~S,namespace,id,bindings),condition,requirements}
    case Schedule.PlannedStep{Sch.Phase{name},requirements}:Phase{position,name,requirements}
    case Schedule.PlannedStep{Sch.Barrier{},requirements}:Barrier{position,requirements}
def placed(~S:Data,steps:List<&2,Schedule.PlannedStep<S>>,+namespace:U32,+bindings:List<&2,DTO.Binding<S>>,+position:Nat) -> List<&2,Placement<S>>:
  match steps:
    case []:[]
    case first <> rest:step(~S,namespace,bindings,position,first) <> placed(~S,rest,namespace,bindings,1n+position)
def described(~S:Data,~Rows:Data,+description:Schedule.Description<S,Rows>) -> Description<S,Rows>:
  match description:
    case Schedule.Description{SchemaApp.Description{_,DTO.Product{bindings,_}},namespace,_,steps}:Description{description,placed(~S,steps,namespace,bindings,0n)}
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,result:Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Schedule.Description<S,Rows>>) -> Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match result:
    case (app,None{}):(app,None{})
    case (app,Some{view}):(app,Some{described(~S,~Rows,view)})
# The existing snapshot's disabled branch returns before fold/observe and before
# this adapter derives any placements. No new observation callback is accepted.
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,app:Schedule.Application<S,C,R,E,H,Rows,observe,fold>) -> Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,Schedule.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app))
