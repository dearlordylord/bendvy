import Base
# Detached operation data. Affine ECS owners never enter this journal.
type Category is Data:
  ComponentValue{}
  ResourceValue{}
  EventValue{}
  NextStateValue{}
  DeferredCommand{}
  RelationOperation{}
  TransitionHandler{}
  MissedValue{}
type Operation is Data:
  ReadOperation{}
  WriteOperation{}
  RemoveOperation{}
  SendOperation{}
  StageOperation{}
  ApplyOperation{}
  HandlerOperation{}
type FactResult is Data:
  Attempted{}
  Applied{}
  Refused{reason:String}
  RolledBack{}
type Value is Data:
  OpaqueValue{}
  UnavailableValue{}
  DisplayedValue{text:String}
type HandleValue is Data:
  HandleValue{namespace:U32,index:U32,generation:U32}
type RelationKind is Data:
  OrdinaryRelation{}
  HierarchyRelation{}
type RelationIdentity is Data:
  RelationIdentity{id:U32,name:String,inverseName:String,kind:RelationKind}
type RelationAction is Data:
  RelateAction{target:HandleValue}
  UnrelateAction{}
  ReorderAction{children:List<&2,HandleValue>}
type HandlerPhase is Data:
  ExitPhase{}
  TransitionPhase{}
  EnterPhase{}
  InitialEnterPhase{}
type Boundary is Data:
  PhaseBoundary{name:String}
  BarrierEntered{}
  BarrierFinished{}
type Fact is Data:
  ReaderFact{namespace:U32,id:U32,name:String,readerId:U32,domain:String,lagged:Bool}
  BoundaryFact{boundary:Boundary}
  Fact{category:Category,key:String,operation:Operation,subject:Maybe<&2,String>,before:Value,after:Value,result:FactResult}
  RelationFact{identity:RelationIdentity,operation:Operation,source:HandleValue,action:RelationAction,result:FactResult}
  HandlerFact{namespace:U32,id:U32,name:String,ordinal:U32,phase:HandlerPhase,from:Value,to:Value,result:FactResult}
  TransitionFact{key:String,from:Value,to:Value,result:FactResult}
type State is Data:
  Off{}
  On{reverseFacts:List<&2,Fact>}
def enabled(state:State) -> Bool:
  match state:
    case Off{}:False{}
    case On{_}:True{}
def append(state:State,fact:Fact) -> State:
  match state:
    case Off{}:Off{}
    case On{facts}:On{fact <> facts}
def facts(state:State) -> List<&2,Fact>:
  match state:
    case Off{}:[]
    case On{facts}:List.reverse(&2,Fact,facts)
def annotate_newest(state:State,before:Value,after:Value) -> State:
  match state:
    case Off{}:Off{}
    case On{[]}:On{[]}
    case On{Fact{category,key,operation,subject,_,_,result} <> rest}:On{Fact{category,key,operation,subject,before,after,result} <> rest}
    case On{RelationFact{identity,operation,source,action,result} <> rest}:On{RelationFact{identity,operation,source,action,result} <> rest}
    case On{HandlerFact{namespace,id,name,ordinal,phase,_,_,result} <> rest}:On{HandlerFact{namespace,id,name,ordinal,phase,before,after,result} <> rest}
    case On{TransitionFact{key,_,_,result} <> rest}:On{TransitionFact{key,before,after,result} <> rest}
    case On{ReaderFact{namespace,id,name,readerId,domain,lagged} <> rest}:On{ReaderFact{namespace,id,name,readerId,domain,lagged} <> rest}
    case On{BoundaryFact{boundary} <> rest}:On{BoundaryFact{boundary} <> rest}
def settled_result(result:FactResult,committed:Bool) -> FactResult:
  match result committed:
    case Attempted{} True{}:Applied{}
    case Attempted{} False{}:RolledBack{}
    case result _:result
def settle_facts(facts:List<&2,Fact>,+committed:Bool) -> List<&2,Fact>:
  match facts:
    case []:[]
    case ReaderFact{namespace,id,name,readerId,domain,lagged} <> rest:ReaderFact{namespace,id,name,readerId,domain,lagged} <> settle_facts(rest,committed)
    case BoundaryFact{boundary} <> rest:BoundaryFact{boundary} <> settle_facts(rest,committed)
    case Fact{category,key,operation,subject,before,after,result} <> rest:Fact{category,key,operation,subject,before,after,settled_result(result,committed)} <> settle_facts(rest,committed)
    case RelationFact{identity,operation,source,action,result} <> rest:RelationFact{identity,operation,source,action,settled_result(result,committed)} <> settle_facts(rest,committed)
    case HandlerFact{namespace,id,name,ordinal,phase,from,to,result} <> rest:HandlerFact{namespace,id,name,ordinal,phase,from,to,settled_result(result,committed)} <> settle_facts(rest,committed)
    case TransitionFact{key,from,to,result} <> rest:TransitionFact{key,from,to,settled_result(result,committed)} <> settle_facts(rest,committed)
def settle(state:State,committed:Bool) -> State:
  match state:
    case Off{}:Off{}
    case On{facts}:On{settle_facts(facts,committed)}

def phase_boundary(state:State,name:String) -> State:
  match state:
    case Off{}:Off{}
    case On{facts}:On{BoundaryFact{PhaseBoundary{name}} <> facts}
def barrier_entered(state:State) -> State:
  match state:
    case Off{}:Off{}
    case On{facts}:On{BoundaryFact{BarrierEntered{}} <> facts}
def barrier_finished(state:State) -> State:
  match state:
    case Off{}:Off{}
    case On{facts}:On{BoundaryFact{BarrierFinished{}} <> facts}
