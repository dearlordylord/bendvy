import Base
import ./ordinary-condition-composition.bend as Comp
import ./ordinary-app-schedule.bend as Schedule
import ./ordinary-app-schema.bend as SchemaApp
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Fields
import ./world.bend as W
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
# Names derive only from the retained actual Registry namespace/id. A missing
# binding stays None; this adapter never invents a label or condition name.
# Detached zero-based plan placement retaining requirements and condition slot.
# System names are joined by actual namespace/id; missing bindings remain None.
# Phase/barrier entries remain in position order, not fabricated system metadata.
type Placement<S:Data> is Data:
  System{position:Nat,namespace:U32,id:U32,name:Maybe<&2,String>,condition:U32,requirements:List<&2,SP.Requirement<S>>}
  Phase{position:Nat,name:String,requirements:List<&2,SP.Requirement<S>>}
  Barrier{position:Nat,requirements:List<&2,SP.Requirement<S>>}
# Preserve the original single-schedule description with derived ordered
# placements. No new runtime state or gameplay capability is introduced.
type Description<S:Data,Rows:Data> is Data:
  Description{original:Schedule.Description<S,Rows>,placements:List<&2,Placement<S>>}
def selected(same:Bool,name:String,next:Maybe<&2,String>) -> Maybe<&2,String>:
  match same:
    case False{}:next
    case True{}:Some{name}
# Advanced metadata lookup by exact namespace/id; no fallback or invented label.
def binding_name(~S:Data,+namespace:U32,+id:U32,bindings:List<&2,DTO.Binding<S>>) -> Maybe<&2,String>:
  match bindings:
    case []:None{}
    case DTO.Binding{otherNamespace,otherId,name,_,_,_,_} <> rest:selected(Bool.and(U32.is_eq(namespace,otherNamespace),U32.is_eq(id,otherId)),name,binding_name(~S,namespace,id,rest))
def step(~S:Data,+namespace:U32,bindings:List<&2,DTO.Binding<S>>,position:Nat,planned:Schedule.PlannedStep<S>) -> Placement<S>:
  match planned:
    case Schedule.PlannedStep{Sch.System{+id,condition},requirements}:System{position,namespace,id,binding_name(~S,namespace,id,bindings),condition,requirements}
    case Schedule.PlannedStep{Sch.Phase{name},requirements}:Phase{position,name,requirements}
    case Schedule.PlannedStep{Sch.Barrier{},requirements}:Barrier{position,requirements}
# Advanced placement derivation over supplied planned steps, starting at position.
# Bindings are detached input metadata, not another registration authority.
def placed(~S:Data,steps:List<&2,Schedule.PlannedStep<S>>,+namespace:U32,+bindings:List<&2,DTO.Binding<S>>,+position:Nat) -> List<&2,Placement<S>>:
  match steps:
    case []:[]
    case first <> rest:step(~S,namespace,bindings,position,first) <> placed(~S,rest,namespace,bindings,1n+position)
# Derive placements from the original snapshot's retained plan and bindings,
# preserving that original complete description.
def described(~S:Data,~Rows:Data,+description:Schedule.Description<S,Rows>) -> Description<S,Rows>:
  match description:
    case Schedule.Description{SchemaApp.Description{_,DTO.Product{bindings,_}},namespace,_,steps}:Description{description,placed(~S,steps,namespace,bindings,0n)}
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,result:Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Schedule.Description<S,Rows>>) -> Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match result:
    case (app,None{}):(app,None{})
    case (app,Some{view}):(app,Some{described(~S,~Rows,view)})
# The existing snapshot's disabled branch returns before fold/observe and before
# this adapter derives any placements. No new observation callback is accepted.
# Observe the single-schedule App, then derive placements only for an enabled
# snapshot. Disabled returns App and None before observer/placement work.
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,app:Schedule.Application<S,C,R,E,H,Rows,observe,fold>) -> Schedule.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,Schedule.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app))

# Detached system position/id/slot plus optional condition description. Missing
# condition metadata stays None; the slot is not a newly evaluated condition.
type ConditionPlacement is Data:
  ConditionPlacement{position:Nat,namespace:U32,id:U32,slot:U32,condition:Maybe<&2,Comp.Description>}
# Preserve original placements and detached condition bindings with their system
# placements; no condition callback is invoked by description derivation.
type ConditionedDescription<S:Data,Rows:Data> is Data:
  ConditionedDescription{original:Description<S,Rows>,bindings:List<&2,Comp.BindingDescription>,placements:List<&2,ConditionPlacement>}
def condition_selected(chosen:Bool,facts:Comp.Description,rest:Maybe<&2,Comp.Description>) -> Maybe<&2,Comp.Description>:
  match chosen:
    case True{}:Some{facts}
    case False{}:rest
def condition_for(bindings:List<&2,Comp.BindingDescription>,+id:U32) -> Maybe<&2,Comp.Description>:
  match bindings:
    case []:None{}
    case Comp.BindingDescription{other,facts} <> rest:condition_selected(U32.is_eq(other,id),facts,condition_for(rest,id))
def condition_step(~S:Data,namespace:U32,bindings:List<&2,Comp.BindingDescription>,position:Nat,planned:Schedule.PlannedStep<S>) -> List<&2,ConditionPlacement>:
  match planned:
    case Schedule.PlannedStep{Sch.System{+id,slot},_}:[ConditionPlacement{position,namespace,id,slot,condition_for(bindings,id)}]
    case _ :[]
def condition_placements(~S:Data,steps:List<&2,Schedule.PlannedStep<S>>,+namespace:U32,+bindings:List<&2,Comp.BindingDescription>,+position:Nat) -> List<&2,ConditionPlacement>:
  match steps:
    case []:[]
    case first <> rest:List.append(&2,ConditionPlacement,condition_step(~S,namespace,bindings,position,first),condition_placements(~S,rest,namespace,bindings,1n+position))
# Advanced metadata adapter joining supplied condition descriptions to system ids
# and retaining the complete original schedule description.
def with_conditions(~S:Data,~Rows:Data,+original:Schedule.Description<S,Rows>,+bindings:List<&2,Comp.BindingDescription>) -> ConditionedDescription<S,Rows>:
  match original:
    case Schedule.Description{_,namespace,_,steps}:ConditionedDescription{described(~S,~Rows,original),bindings,condition_placements(~S,steps,namespace,bindings,0n)}
def conditions_returned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,observed:Schedule.ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,Schedule.ConditionDescription<S,Rows>>) -> Schedule.ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,ConditionedDescription<S,Rows>>:
  match observed:
    case (app,None{}):(app,None{})
    case (app,Some{Schedule.ConditionDescription{original,bindings}}):(app,Some{with_conditions(~S,~Rows,original,bindings)})
# The standard App snapshot decides debug before any condition placement work.
# Return the conditioned App and optional placement/condition description using
# its existing snapshot. Debug is checked before condition placement derivation;
# this does not execute conditions or change their actual owner state.
def snapshot_conditions(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> Comp.Evaluation<W.World<S,C,R,E>,B>,app:Schedule.ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select>) -> Schedule.ConditionedApplication<S,C,R,E,H,Rows,observe,fold,B,select> & Maybe<&2,ConditionedDescription<S,Rows>>:
  conditions_returned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,Schedule.snapshot_conditions(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~B,~select,app))
