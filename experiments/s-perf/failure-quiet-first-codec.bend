import Base
import ./failure-quiet-overlay/experiments/s-integrate/types.bend as T
import ./failure-quiet-overlay/experiments/s-integrate/storage.bend as S
import ./failure-quiet-overlay/experiments/s-integrate/observations.bend as O
import ./failure-quiet-overlay/experiments/s-integrate/host-observations.bend as E
import ./failure-quiet-overlay/experiments/s-integrate/dispatcher.bend as D
import ./failure-quiet-overlay/experiments/s-integrate/host-render.bend as J

# A self-delimiting flat tuple of actual U32 values; schema+record tags fix field widths.
# Variable lists/strings carry their actual length. Option/access tags preserve absence.
def mix(acc:U32,value:U32) -> U32:
  U32.add(U32.mul(acc,33),value)
def fold(values:List<&2,U32>,acc:U32) -> U32:
  match values:
    case Nil{}: acc
    case Con{head,tail}: fold(tail,mix(acc,head))
def text_chars(value:String) -> List<&2,U32>:
  match value:
    case SNil{}: []
    case SCon{head,tail}: Char.to_u32(head) <> text_chars(tail)
def text(+value:String) -> List<&2,U32>:
  U32.from_nat(String.length(value)) <> text_chars(value)
def show(values:List<&2,U32>) -> String:
  J.render_list(~U32,~U32.show,values)
def bool(value:Bool) -> List<&2,U32>:
  match value:
    case False{}: [0]
    case True{}: [1]
def four(value:T.Four) -> List<&2,U32>:
  match value:
    case T.Four{a,b,c,d}: List.concat(&2,U32,[[a],[b],[c],[d]])
def position(value:T.PositionView) -> List<&2,U32>:
  match value:
    case T.PositionView{cells,frame}: List.concat(&2,U32,[four(cells),[frame]])
def vitals(value:T.VitalsView) -> List<&2,U32>:
  match value:
    case T.VitalsView{cells,reserve,class}: List.concat(&2,U32,[four(cells),[reserve],[class]])
def velocity(value:T.VelocityView) -> List<&2,U32>:
  match value:
    case T.VelocityView{cells,moving}: List.concat(&2,U32,[four(cells),bool(moving)])
def armor(value:T.ArmorView) -> List<&2,U32>:
  match value:
    case T.ArmorView{cells,grade}: List.concat(&2,U32,[four(cells),[grade]])
def selected(value:T.Selected) -> List<&2,U32>:
  match value:
    case T.Selected{group}: [group]
def tracked(value:T.Tracked) -> List<&2,U32>:
  match value:
    case T.Tracked{group}: [group]
def ledger(value:T.LedgerView) -> List<&2,U32>:
  match value:
    case T.LedgerView{cells,epoch}: List.concat(&2,U32,[four(cells),[epoch]])
def optional(~A:Data,~encode:A -> List<&2,U32>,value:Maybe<&2,A>) -> List<&2,U32>:
  match value:
    case None{}: List.concat(&2,U32,[[0]])
    case Some{value}: List.concat(&2,U32,[[1],encode(value)])
def access(~A:Data,~encode:A -> List<&2,U32>,value:T.Access<A>) -> List<&2,U32>:
  match value:
    case T.Missing{}: List.concat(&2,U32,[[0]])
    case T.Mismatch{}: List.concat(&2,U32,[[1]])
    case T.Found{value}: List.concat(&2,U32,[[2],encode(value)])
def handle(-Schema:Data,value:S.Handle<Schema>) -> List<&2,U32>:
  match value:
    case S.Handle{namespace,id}: List.concat(&2,U32,[[namespace],[id]])
def row(~Schema:Data,~V:Data,~AV:Data,~F:Data,~v:V -> List<&2,U32>,~av:AV -> List<&2,U32>,~f:F -> List<&2,U32>,value:O.QueryRow<Schema,V,AV,F>) -> List<&2,U32>:
  match value:
    case O.QueryRow{entity,main,aux,flag}: List.concat(&2,U32,[handle(Schema,entity),v(main),optional(~AV,~av,aux),optional(~F,~f,flag)])
def bundle(~V:Data,~AV:Data,~F:Data,~v:V -> List<&2,U32>,~av:AV -> List<&2,U32>,~f:F -> List<&2,U32>,value:O.BundleView<V,AV,F>) -> List<&2,U32>:
  match value:
    case O.BundleView{main,aux,flag}: List.concat(&2,U32,[optional(~V,~v,main),optional(~AV,~av,aux),optional(~F,~f,flag)])
def list_values(~A:Data,~encode:A -> List<&2,U32>,values:List<&2,A>) -> List<&2,U32>:
  match values:
    case Nil{}: []
    case Con{head,tail}: List.append(&2,U32,encode(head),list_values(~A,~encode,tail))
def list(~A:Data,~encode:A -> List<&2,U32>,+values:List<&2,A>) -> List<&2,U32>:
  U32.from_nat(List.length(&2,A,values)) <> list_values(~A,~encode,values)
def lookup(~Schema:Data,~V:Data,~AV:Data,~F:Data,~v:V -> List<&2,U32>,~av:AV -> List<&2,U32>,~f:F -> List<&2,U32>,value:E.Lookup<Schema,V,AV,F>) -> List<&2,U32>:
  match value:
    case E.Lookup{label,entity,result}: List.concat(&2,U32,[text(label),handle(Schema,entity),access(~O.QueryRow<Schema,V,AV,F>,~row(~Schema,~V,~AV,~F,~v,~av,~f),result)])
def main_view(value:T.MainView) -> List<&2,U32>:
  match value:
    case T.MotionMain{value}: List.concat(&2,U32,[[0],position(value)])
    case T.HealthMain{value}: List.concat(&2,U32,[[1],vitals(value)])
def own(value:E.OwnView) -> List<&2,U32>:
  match value:
    case E.Main{value}: List.concat(&2,U32,[[0],access(~T.MainView,~main_view,value)])
    case E.Ledger{value}: List.concat(&2,U32,[[1],optional(~T.LedgerView,~ledger,value)])
    case E.ReservedLookup{value}: List.concat(&2,U32,[[2],access(~T.MainView,~main_view,value)])
def outcome(value:D.DispatchOutcome) -> List<&2,U32>:
  match value:
    case D.Complete{}: List.concat(&2,U32,[[0]])
    case D.SystemFailure{system,code}: List.concat(&2,U32,[[1],text(system),[code]])
    case D.SetupRejected{reason}: List.concat(&2,U32,[[2],text(reason)])
    case D.MissingRuntimeRequirements{requirements}: List.concat(&2,U32,[[3],text(J.render_dispatch_outcome(D.MissingRuntimeRequirements{requirements}))])
def event(~Schema:Data,~V:Data,~AV:Data,~F:Data,~v:V -> List<&2,U32>,~av:AV -> List<&2,U32>,~f:F -> List<&2,U32>,~P:Data,~ping:P -> List<&2,U32>,~Mode:Data,~mode:Mode -> String,~vj:V -> String,~avj:AV -> String,~fj:F -> String,~pingj:P -> String,value:E.TraceEvent<Schema,V,AV,F,T.LedgerView,Mode,P>) -> List<&2,U32>:
  match value:
    case E.FailureObserved{schema,iteration,phase,rows,resource,lookups}:
      List.concat(&2,U32,[[0],text(schema),[iteration],text(phase),list(~O.QueryRow<Schema,V,AV,F>,~row(~Schema,~V,~AV,~F,~v,~av,~f),rows),optional(~T.LedgerView,~ledger,resource),list(~E.Lookup<Schema,V,AV,F>,~lookup(~Schema,~V,~AV,~F,~v,~av,~f),lookups)])
    case E.FailureRead{iteration,system,count,messages,lag,tick,frame}:
      List.concat(&2,U32,[[1,iteration],text(system),[count],list(~P,~ping,messages),bool(lag),[tick,frame]])
    case E.FailureResult{label,result}: List.concat(&2,U32,[[2],text(label),outcome(result)])
    case E.Reserved{step,name,label,entity,components}: List.concat(&2,U32,[[3],text(step),text(name),text(label),handle(Schema,entity),bundle(~V,~AV,~F,~v,~av,~f,components)])
    case E.OwnWrites{step,system,views}: List.concat(&2,U32,[[4],text(step),text(system),list(~E.OwnView,~own,views)])
    case other: List.concat(&2,U32,[[5],text(J.render_event(~Schema,~V,~AV,~F,~vj,~avj,~fj,~T.LedgerView,~Mode,~J.render_ledger,~mode,~P,~pingj,other))])
def motion_ping(value:T.MotionPing) -> List<&2,U32>:
  match value:
    case T.MotionPing{code}: [code]
def health_ping(value:T.HealthPing) -> List<&2,U32>:
  match value:
    case T.HealthPing{code}: [code]
def motion_event(value:E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>) -> List<&2,U32>:
  event(~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~position,~velocity,~selected,~T.MotionPing,~motion_ping,~T.MotionMode,~J.render_motion_mode,~J.render_position,~J.render_velocity,~J.render_selected,~J.render_motion_ping,value)
def health_event(value:E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>) -> List<&2,U32>:
  event(~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~vitals,~armor,~tracked,~T.HealthPing,~health_ping,~T.HealthMode,~J.render_health_mode,~J.render_vitals,~J.render_armor,~J.render_tracked,~J.render_health_ping,value)
