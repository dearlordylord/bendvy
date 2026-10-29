import Base
import ./execution-deferred-settings.bend as Settings
import ./execution-parallel-schedule.bend as Ready
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec

type BoundaryKind is Data:
  Sync{ids:List<&2,U32>}
  Final{}
type Boundary is Data:
  ApplyEntered{kind:BoundaryKind,requested:List<&2,U32>}
  ApplyReturned{kind:BoundaryKind,remaining:List<&2,U32>}
type TraceState is Data:
  Off{}
  On{reverse:List<&2,Boundary>}
type Context<-Actual:Type> is Type:
  Context{state:Actual,unapplied:List<&2,U32>,syncs:List<&2,U32>,trace:TraceState}
type Rules<BaseRules:Data> is Data:
  Rules{base:BaseRules,syncs:List<&2,U32>}
type Outcome<-Actual:Type,Error:Data,Out:Data> is Type:
  Outcome{result:Exec.ExecutionResult<Actual,String,Error,Out>,unapplied:List<&2,U32>}
type Observed<-Actual:Type,-Error:Data,-Out:Data> is Type:
  Observed{outcome:Outcome<Actual,Error,Out>,boundaries:List<&2,Boundary>}
def record(state:TraceState,boundary:Boundary) -> TraceState:
  match state:
    case Off{}:Off{}
    case On{reverse}:On{boundary <> reverse}
def boundaries(state:TraceState) -> List<&2,Boundary>:
  match state:
    case Off{}:[]
    case On{reverse}:List.reverse(&2,Boundary,reverse)
def include(+id:U32,+ids:List<&2,U32>) -> List<&2,U32>:
  Bool.pick(List<&2,U32>,Settings.member(id,ids),ids,id <> ids)
def admitted_one(~Error:Data,~Out:Data,value:Ready.Completed<Error,Out>,ids:List<&2,U32>) -> List<&2,U32>:
  match value:
    case Ready.Completed{id,Exec.Completed{_}}:include(id,ids)
    case Ready.Completed{id,Exec.BodyError{_,_}}:include(id,ids)
    case Ready.Completed{_,Exec.AdmissionRefused{}}:ids
def admitted(~Error:Data,~Out:Data,completed:List<&2,Ready.Completed<Error,Out>>,ids:List<&2,U32>) -> List<&2,U32>:
  match completed:
    case []:ids
    case first <> rest:admitted(~Error,~Out,rest,admitted_one(~Error,~Out,first,ids))
def compatible_fields(~BaseRules:Data,~baseCompatible:BaseRules -> U32 -> U32 -> Bool,rules:Rules<BaseRules>,+left:U32,+right:U32) -> Bool:
  match rules:
    case Rules{base,+syncs}:Bool.and(Bool.not(Bool.or(Settings.member(left,syncs),Settings.member(right,syncs))),baseCompatible(base,left,right))
def compatible(~BaseRules:Data,~baseCompatible:BaseRules -> U32 -> U32 -> Bool,rules:Rules<BaseRules>,left:U32,right:U32) -> Bool:
  compatible_fields(~BaseRules,~baseCompatible,rules,left,right)
def condition_returned(~Actual:Type,~Error:Data,syncs:List<&2,U32>,unapplied:List<&2,U32>,trace:TraceState,result:Actual & Exec.Condition<Error>) -> Context<Actual> & Exec.Condition<Error>:
  match result:
    case (state,value):(Context{state,unapplied,syncs,trace},value)
def condition_selected(~Actual:Type,~Error:Data,~condition:Actual -> U32 -> IO(Actual & Exec.Condition<Error>),context:Context<Actual>,id:U32,isSync:Bool) -> IO(Context<Actual> & Exec.Condition<Error>):
  match context isSync:
    case context True{}:IO.pure(Context<Actual> & Exec.Condition<Error>,(context,Exec.Allowed{}))
    case Context{state,unapplied,syncs,trace} False{}:IO.bind(Actual & Exec.Condition<Error>,Context<Actual> & Exec.Condition<Error>,condition(state,id),result => IO.pure(Context<Actual> & Exec.Condition<Error>,condition_returned(~Actual,~Error,syncs,unapplied,trace,result)))
def condition_id(~Actual:Type,~Error:Data,~condition:Actual -> U32 -> IO(Actual & Exec.Condition<Error>),context:Context<Actual>,+id:U32) -> IO(Context<Actual> & Exec.Condition<Error>):
  match context:
    case Context{state,unapplied,+syncs,trace}:condition_selected(~Actual,~Error,~condition,Context{state,unapplied,syncs,trace},id,Settings.member(id,syncs))
def condition_adapter(~Actual:Type,~Error:Data,~condition:Actual -> U32 -> IO(Actual & Exec.Condition<Error>),context:Context<Actual>,id:U32) -> IO(Context<Actual> & Exec.Condition<Error>):
  condition_id(~Actual,~Error,~condition,context,id)
def group_returned(~Actual:Type,~Error:Data,~Out:Data,syncs:List<&2,U32>,unapplied:List<&2,U32>,trace:TraceState,result:Actual & List<&2,Ready.Completed<Error,Out>>) -> Context<Actual> & List<&2,Ready.Completed<Error,Out>>:
  match result:
    case (state,+completed):(Context{state,admitted(~Error,~Out,completed,unapplied),syncs,trace},completed)
def group_applied(~Actual:Type,~Error:Data,~Out:Data,syncs:List<&2,U32>,kind:BoundaryKind,trace:TraceState,result:Actual & List<&2,U32>) -> Context<Actual> & List<&2,Ready.Completed<Error,Out>>:
  match result:
    case (state,+unapplied):(Context{state,unapplied,syncs,record(trace,ApplyReturned{kind,unapplied})},[])
def group_selected(~Actual:Type,~Error:Data,~Out:Data,~group:Actual -> List<&2,U32> -> IO(Actual & List<&2,Ready.Completed<Error,Out>>),~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,context:Context<Actual>,+ids:List<&2,U32>,isSync:Bool) -> IO(Context<Actual> & List<&2,Ready.Completed<Error,Out>>):
  match context isSync:
    case Context{state,+unapplied,syncs,trace} True{}:IO.pure(Context<Actual> & List<&2,Ready.Completed<Error,Out>>,group_applied(~Actual,~Error,~Out,syncs,Sync{ids},record(trace,ApplyEntered{Sync{ids},unapplied}),apply(unapplied,state)))
    case Context{state,unapplied,syncs,trace} False{}:IO.bind(Actual & List<&2,Ready.Completed<Error,Out>>,Context<Actual> & List<&2,Ready.Completed<Error,Out>>,group(state,ids),result => IO.pure(Context<Actual> & List<&2,Ready.Completed<Error,Out>>,group_returned(~Actual,~Error,~Out,syncs,unapplied,trace,result)))
def group_adapter(~Actual:Type,~Error:Data,~Out:Data,~group:Actual -> List<&2,U32> -> IO(Actual & List<&2,Ready.Completed<Error,Out>>),~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,context:Context<Actual>,ids:List<&2,U32>) -> IO(Context<Actual> & List<&2,Ready.Completed<Error,Out>>):
  match context ids:
    case context, []:IO.pure(Context<Actual> & List<&2,Ready.Completed<Error,Out>>,(context,[]))
    case Context{state,unapplied,+syncs,trace}, +first <> +rest:group_selected(~Actual,~Error,~Out,~group,~apply,Context{state,unapplied,syncs,trace},first <> rest,Settings.member(first,syncs))
def handled(~Actual:Type,syncs:List<&2,U32>,unapplied:List<&2,U32>,trace:TraceState,result:Actual & Exec.Handling) -> Context<Actual> & Exec.Handling:
  match result:
    case (state,handling):(Context{state,unapplied,syncs,trace},handling)
def handler_adapter(~Actual:Type,~Error:Data,~handler:Actual -> Error -> Actual & Exec.Handling,context:Context<Actual>,error:Error) -> Context<Actual> & Exec.Handling:
  match context:
    case Context{state,unapplied,syncs,trace}:handled(~Actual,syncs,unapplied,trace,handler(state,error))
def final_applied(~Actual:Type,~Error:Data,~Out:Data,trace:TraceState,events:List<&2,Exec.Observation<Error,Out>>,result:Actual & List<&2,U32>) -> Observed<Actual,Error,Out>:
  match result:
    case (state,+unapplied):Observed{Outcome{Exec.Finished{state,events},unapplied},boundaries(record(trace,ApplyReturned{Final{},unapplied}))}
def finish(~Actual:Type,~Error:Data,~Out:Data,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,finalApply:Bool,state:Actual,+unapplied:List<&2,U32>,trace:TraceState,events:List<&2,Exec.Observation<Error,Out>>) -> Observed<Actual,Error,Out>:
  match finalApply:
    case False{}:Observed{Outcome{Exec.Finished{state,events},unapplied},boundaries(trace)}
    case True{}:final_applied(~Actual,~Error,~Out,record(trace,ApplyEntered{Final{},unapplied}),events,apply(unapplied,state))
def finished(~Actual:Type,~Error:Data,~Out:Data,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,finalApply:Bool,result:Exec.ExecutionResult<Context<Actual>,String,Error,Out>) -> Observed<Actual,Error,Out>:
  match result:
    case Exec.Finished{Context{state,unapplied,_,trace},events}:finish(~Actual,~Error,~Out,~apply,finalApply,state,unapplied,trace,events)
    case Exec.Stopped{Context{state,unapplied,_,trace},error,events}:Observed{Outcome{Exec.Stopped{state,error,events},unapplied},boundaries(trace)}
    case Exec.Invalid{Context{state,unapplied,_,trace},reason}:Observed{Outcome{Exec.Invalid{state,reason},unapplied},boundaries(trace)}

# Bevy ad678262 single_threaded.rs keeps admitted body-error buffers unapplied
# until a real sync, and applies final deferred work on normal completion.
# Sync nodes are exclusive library operations: no user condition/body dispatch,
# local/cursor update, or visible body event is generated for their private IDs.
# Reference executor: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs
def ready(nodes:List<&2,Plan.Node<String>>,edges:List<&2,Plan.Edge>) -> List<&2,Plan.Node<String>>:
  Plan.ready(~String,nodes,edges)
def run_mode(~BaseRules:Data,~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> IO(Actual & Exec.Condition<Error>),~group:Actual -> List<&2,U32> -> IO(Actual & List<&2,Ready.Completed<Error,Out>>),~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,~baseCompatible:BaseRules -> U32 -> U32 -> Bool,trace:TraceState,settings:Settings.Settings,+syncs:List<&2,U32>,rules:BaseRules,plan:Plan.Build<String>,state:Actual,unapplied:List<&2,U32>) -> IO(Observed<Actual,Error,Out>):
  match settings:
    case Settings.Settings{_,finalApply,_,_}:IO.bind(Exec.ExecutionResult<Context<Actual>,String,Error,Out>,Observed<Actual,Error,Out>,Ready.run(~Rules<BaseRules>,~Context<Actual>,~String,~Error,~Out,~condition_adapter(~Actual,~Error,~condition),~group_adapter(~Actual,~Error,~Out,~group,~apply),~handler_adapter(~Actual,~Error,~handler),~compatible(~BaseRules,~baseCompatible),~ready,Rules{rules,syncs},plan,Context{state,unapplied,syncs,trace}),result => IO.pure(Observed<Actual,Error,Out>,finished(~Actual,~Error,~Out,~apply,finalApply,result)))
def run_observed(~BaseRules:Data,~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> IO(Actual & Exec.Condition<Error>),~group:Actual -> List<&2,U32> -> IO(Actual & List<&2,Ready.Completed<Error,Out>>),~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,~baseCompatible:BaseRules -> U32 -> U32 -> Bool,settings:Settings.Settings,syncs:List<&2,U32>,rules:BaseRules,plan:Plan.Build<String>,state:Actual,unapplied:List<&2,U32>) -> IO(Observed<Actual,Error,Out>):
  run_mode(~BaseRules,~Actual,~Error,~Out,~condition,~group,~handler,~apply,~baseCompatible,On{[]},settings,syncs,rules,plan,state,unapplied)
def unobserved(~Actual:Type,~Error:Data,~Out:Data,value:Observed<Actual,Error,Out>) -> Outcome<Actual,Error,Out>:
  match value:
    case Observed{outcome,_}:outcome
def run(~BaseRules:Data,~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> IO(Actual & Exec.Condition<Error>),~group:Actual -> List<&2,U32> -> IO(Actual & List<&2,Ready.Completed<Error,Out>>),~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,~baseCompatible:BaseRules -> U32 -> U32 -> Bool,settings:Settings.Settings,syncs:List<&2,U32>,rules:BaseRules,plan:Plan.Build<String>,state:Actual,unapplied:List<&2,U32>) -> IO(Outcome<Actual,Error,Out>):
  IO.bind(Observed<Actual,Error,Out>,Outcome<Actual,Error,Out>,run_mode(~BaseRules,~Actual,~Error,~Out,~condition,~group,~handler,~apply,~baseCompatible,Off{},settings,syncs,rules,plan,state,unapplied),value=>IO.pure(Outcome<Actual,Error,Out>,unobserved(~Actual,~Error,~Out,value)))
