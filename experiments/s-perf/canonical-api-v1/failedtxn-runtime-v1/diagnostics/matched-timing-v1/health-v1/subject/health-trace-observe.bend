import Base
import /tmp/bendvy-failedtxn-health-matched-method/src/ecs/trace-facts.bend as T
import health-observe.bend as O

def category(observed:T.Category) -> String:
  match observed:
    case T.ComponentValue{}:"ComponentValue{" ++ "}"
    case T.ResourceValue{}:"ResourceValue{" ++ "}"
    case T.EventValue{}:"EventValue{" ++ "}"
    case T.NextStateValue{}:"NextStateValue{" ++ "}"
    case T.DeferredCommand{}:"DeferredCommand{" ++ "}"
    case T.RelationOperation{}:"RelationOperation{" ++ "}"
    case T.TransitionHandler{}:"TransitionHandler{" ++ "}"
    case T.MissedValue{}:"MissedValue{" ++ "}"

def operation(observed:T.Operation) -> String:
  match observed:
    case T.ReadOperation{}:"ReadOperation{" ++ "}"
    case T.WriteOperation{}:"WriteOperation{" ++ "}"
    case T.RemoveOperation{}:"RemoveOperation{" ++ "}"
    case T.SendOperation{}:"SendOperation{" ++ "}"
    case T.StageOperation{}:"StageOperation{" ++ "}"
    case T.ApplyOperation{}:"ApplyOperation{" ++ "}"
    case T.HandlerOperation{}:"HandlerOperation{" ++ "}"

def factresult(observed:T.FactResult) -> String:
  match observed:
    case T.Attempted{}:"Attempted{" ++ "}"
    case T.Applied{}:"Applied{" ++ "}"
    case T.Refused{x_reason}:"Refused{" ++ O.audit_effect(x_reason) ++ "}"
    case T.RolledBack{}:"RolledBack{" ++ "}"

def value(observed:T.Value) -> String:
  match observed:
    case T.OpaqueValue{}:"OpaqueValue{" ++ "}"
    case T.UnavailableValue{}:"UnavailableValue{" ++ "}"
    case T.DisplayedValue{x_text}:"DisplayedValue{" ++ O.audit_effect(x_text) ++ "}"

def handlevalue(observed:T.HandleValue) -> String:
  match observed:
    case T.HandleValue{x_namespace,x_index,x_generation}:"HandleValue{" ++ U32.show(x_namespace) ++ ";" ++ U32.show(x_index) ++ ";" ++ U32.show(x_generation) ++ "}"

def relationkind(observed:T.RelationKind) -> String:
  match observed:
    case T.OrdinaryRelation{}:"OrdinaryRelation{" ++ "}"
    case T.HierarchyRelation{}:"HierarchyRelation{" ++ "}"

def relationidentity(observed:T.RelationIdentity) -> String:
  match observed:
    case T.RelationIdentity{x_id,x_name,x_inverseName,x_kind}:"RelationIdentity{" ++ U32.show(x_id) ++ ";" ++ O.audit_effect(x_name) ++ ";" ++ O.audit_effect(x_inverseName) ++ ";" ++ relationkind(x_kind) ++ "}"

def relationaction(observed:T.RelationAction) -> String:
  match observed:
    case T.RelateAction{x_target}:"RelateAction{" ++ handlevalue(x_target) ++ "}"
    case T.UnrelateAction{}:"UnrelateAction{" ++ "}"
    case T.ReorderAction{x_children}:"ReorderAction{" ++ List.show(&2,T.HandleValue,handlevalue,x_children) ++ "}"

def handlerphase(observed:T.HandlerPhase) -> String:
  match observed:
    case T.ExitPhase{}:"ExitPhase{" ++ "}"
    case T.TransitionPhase{}:"TransitionPhase{" ++ "}"
    case T.EnterPhase{}:"EnterPhase{" ++ "}"
    case T.InitialEnterPhase{}:"InitialEnterPhase{" ++ "}"

def boundary(observed:T.Boundary) -> String:
  match observed:
    case T.PhaseBoundary{x_name}:"PhaseBoundary{" ++ O.audit_effect(x_name) ++ "}"
    case T.BarrierEntered{}:"BarrierEntered{" ++ "}"
    case T.BarrierFinished{}:"BarrierFinished{" ++ "}"

def maybe_string(observed:Maybe<&2,String>) -> String:
  match observed:
    case None{}:"None"
    case Some{text}:"Some{" ++ O.audit_effect(text) ++ "}"

def fact(observed:T.Fact) -> String:
  match observed:
    case T.ReaderFact{x_namespace,x_id,x_name,x_readerId,x_domain,x_lagged}:"ReaderFact{" ++ U32.show(x_namespace) ++ ";" ++ U32.show(x_id) ++ ";" ++ O.audit_effect(x_name) ++ ";" ++ U32.show(x_readerId) ++ ";" ++ O.audit_effect(x_domain) ++ ";" ++ Bool.show(x_lagged) ++ "}"
    case T.BoundaryFact{x_boundary}:"BoundaryFact{" ++ boundary(x_boundary) ++ "}"
    case T.Fact{x_category,x_key,x_operation,x_subject,x_before,x_after,x_result}:"Fact{" ++ category(x_category) ++ ";" ++ O.audit_effect(x_key) ++ ";" ++ operation(x_operation) ++ ";" ++ maybe_string(x_subject) ++ ";" ++ value(x_before) ++ ";" ++ value(x_after) ++ ";" ++ factresult(x_result) ++ "}"
    case T.RelationFact{x_identity,x_operation,x_source,x_action,x_result}:"RelationFact{" ++ relationidentity(x_identity) ++ ";" ++ operation(x_operation) ++ ";" ++ handlevalue(x_source) ++ ";" ++ relationaction(x_action) ++ ";" ++ factresult(x_result) ++ "}"
    case T.HandlerFact{x_namespace,x_id,x_name,x_ordinal,x_phase,x_from,x_to,x_result}:"HandlerFact{" ++ U32.show(x_namespace) ++ ";" ++ U32.show(x_id) ++ ";" ++ O.audit_effect(x_name) ++ ";" ++ U32.show(x_ordinal) ++ ";" ++ handlerphase(x_phase) ++ ";" ++ value(x_from) ++ ";" ++ value(x_to) ++ ";" ++ factresult(x_result) ++ "}"
    case T.TransitionFact{x_key,x_from,x_to,x_result}:"TransitionFact{" ++ O.audit_effect(x_key) ++ ";" ++ value(x_from) ++ ";" ++ value(x_to) ++ ";" ++ factresult(x_result) ++ "}"

def state(observed:T.State) -> String:
  match observed:
    case T.Off{}:"Off{" ++ "}"
    case T.On{x_reverseFacts}:"On{" ++ List.show(&2,T.Fact,fact,x_reverseFacts) ++ "}"
