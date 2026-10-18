import Base
# Engine seam. Ordinary gameplay receives only canonical operation grants.
# Every action is invoked on both outcomes; no closure-held owner is discarded.
def Action(~State:Type,~Recovery:Type) -> Type:
  Bool -> State -> Recovery -> State & Recovery
def applied(~State:Type,~Recovery:Type,next:State -> Recovery -> State & Recovery,result:State & Recovery) -> State & Recovery:
  match result:
    case (state,recovery):next(state,recovery)
def finish(~State:Type,~Recovery:Type,journal:List<Action(~State,~Recovery)>,+success:Bool,state:State,recovery:Recovery) -> State & Recovery:
  match journal:
    case []:(state,recovery)
    case action <> rest:applied(~State,~Recovery,s => r => finish(~State,~Recovery,rest,success,s,r),action(success,state,recovery))
