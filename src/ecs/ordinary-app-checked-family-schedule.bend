import Base
import ./execution-context.bend as Ctx
import ./ordinary-app-execution.bend as Execution
import ./ordinary-app-event-family-runtime.bend as Family
import ./event-family-routing.bend as Route
import ./ordinary-app-checked-schedule.bend as Old
import ./ordinary-app-schedule.bend as Single
import ./ordinary-app-schema.bend as App
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Fields
import ./ordinary-checked-bindings.bend as B
import ./world.bend as W
import ./system.bend as Sys
import ./schedule-provision.bend as SP
import ./checked-condition-schedule.bend as Checked
# Family and tick are an opaque part of the existing scheduler owner.
# The existing reader-owner fold remains the sole metadata source.
def folded(~S:Data,~H:Type,~F:Type,held:F & Nat,value:H & List<&2,Fields.Fields<S>>) -> (H & (F & Nat)) & List<&2,Fields.Fields<S>>:
  match value:
    case (owners,fields):((owners,held),fields)
def fold_family(~S:Data,~H:Type,~F:Type,~fold:H -> H & List<&2,Fields.Fields<S>>,value:H & (F & Nat)) -> (H & (F & Nat)) & List<&2,Fields.Fields<S>>:
  match value:
    case (owners,held):folded(~S,~H,~F,held,fold(owners))
type Application<S:Data,C:Type,R:Type,E:Data,F:Type,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Fields.Fields<S>>,B:Type,-select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>> is Type:
  Application{app:Old.Application<S,C,R,E,(H & (F & Nat)),Rows,observe,fold_family(~S,~H,~F,~fold),B,select>}
type Attachment<-Original:Type,-Guards:Type,-Scheduled:Type> is Type:
  Attached{app:Scheduled}
  Invalid{app:Original,bindings:Guards}
def original(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,value:App.Application<S,C,R,E,(H & (F & Nat)),Rows,observe,fold_family(~S,~H,~F,~fold)>) -> Family.Application<S,C,R,E,F,H,Rows,observe,fold>:
  match value:
    case App.Application{schema,Build.Registered{world,(owners,(family,tick)),recipe,debug}}:Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}
def checked(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Old.Attachment<Single.Application<S,C,R,E,(H & (F & Nat)),Rows,observe,fold_family(~S,~H,~F,~fold)>,B.Bindings<W.World<S,C,R,E>,B,select>,Old.Application<S,C,R,E,(H & (F & Nat)),Rows,observe,fold_family(~S,~H,~F,~fold),B,select>>) -> Attachment<Family.Application<S,C,R,E,F,H,Rows,observe,fold>,B.Bindings<W.World<S,C,R,E>,B,select>,Application<S,C,R,E,F,H,Rows,observe,fold,B,select>>:
  match value:
    case Old.Attached{app}:Attached{Application{app}}
    case Old.Invalid{Single.Application{app,_,_,_,_,_},bindings}:Invalid{original(~S,~C,~R,~E,~F,~H,~Rows,~observe,~fold,app),bindings}
def scheduled(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>,value:Single.Attachment<App.Application<S,C,R,E,(H & (F & Nat)),Rows,observe,fold_family(~S,~H,~F,~fold)>,Single.Application<S,C,R,E,(H & (F & Nat)),Rows,observe,fold_family(~S,~H,~F,~fold)>>) -> Attachment<Family.Application<S,C,R,E,F,H,Rows,observe,fold>,B.Bindings<W.World<S,C,R,E>,B,select>,Application<S,C,R,E,F,H,Rows,observe,fold,B,select>>:
  match value:
    case Single.Invalid{app}:Invalid{original(~S,~C,~R,~E,~F,~H,~Rows,~observe,~fold,app),bindings}
    case Single.Attached{app}:checked(~S,~C,~R,~E,~F,~H,~Rows,~observe,~fold,~B,~select,Old.attach(~S,~C,~R,~E,~(H & (F & Nat)),~Rows,~observe,~fold_family(~S,~H,~F,~fold),~B,~select,app,bindings))
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Family.Application<S,C,R,E,F,H,Rows,observe,fold>,name:String,plan:SP.Plan<S>,bindings:B.Bindings<W.World<S,C,R,E>,B,select>) -> Attachment<Family.Application<S,C,R,E,F,H,Rows,observe,fold>,B.Bindings<W.World<S,C,R,E>,B,select>,Application<S,C,R,E,F,H,Rows,observe,fold,B,select>>:
  match value:
    case Family.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}:scheduled(~S,~C,~R,~E,~F,~H,~Rows,~observe,~fold,~B,~select,bindings,Single.attach(~S,~C,~R,~E,~(H & (F & Nat)),~Rows,~observe,~fold_family(~S,~H,~F,~fold),App.Application{schema,Build.Registered{world,(owners,(family,tick)),recipe,debug}},name,plan))
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Application<S,C,R,E,F,H,Rows,observe,fold,B,select>,flag:Bool) -> Application<S,C,R,E,F,H,Rows,observe,fold,B,select>:
  match value:
    case Application{app}:Application{Old.enabled(~S,~C,~R,~E,~(H & (F & Nat)),~Rows,~observe,~fold_family(~S,~H,~F,~fold),~B,~select,app,flag)}
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Old.Application<S,C,R,E,(H & (F & Nat)),Rows,observe,fold_family(~S,~H,~F,~fold),B,select> & Maybe<&2,Old.Description<S,Rows>>) -> Application<S,C,R,E,F,H,Rows,observe,fold,B,select> & Maybe<&2,Old.Description<S,Rows>>:
  match value:
    case (app,view):(Application{app},view)
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,value:Application<S,C,R,E,F,H,Rows,observe,fold,B,select>) -> Application<S,C,R,E,F,H,Rows,observe,fold,B,select> & Maybe<&2,Old.Description<S,Rows>>:
  match value:
    case Application{app}:observed(~S,~C,~R,~E,~F,~H,~Rows,~observe,~fold,~B,~select,Old.snapshot(~S,~C,~R,~E,~(H & (F & Nat)),~Rows,~observe,~fold_family(~S,~H,~F,~fold),~B,~select,app))
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~Error:Data,value:Single.RunResult<Old.Application<S,C,R,E,(H & (F & Nat)),Rows,observe,fold_family(~S,~H,~F,~fold),B,select>,S,Checked.Error<Error>>) -> Single.RunResult<Application<S,C,R,E,F,H,Rows,observe,fold,B,select>,S,Checked.Error<Error>>:
  match value:
    case Single.Finished{app,observations}:Single.Finished{Application{app},observations}
    case Single.Failed{app,error,observations}:Single.Failed{Application{app},error,observations}
    case Single.Rejected{app}:Single.Rejected{Application{app}}
    case Single.Missing{app,requirements}:Single.Missing{Application{app},requirements}
def run_classic(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~Error:Data,~dispatch:(H & (F & Nat)) -> W.World<S,C,R,E> -> U32 -> (H & (F & Nat)) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,F,H,Rows,observe,fold,B,select>) -> Single.RunResult<Application<S,C,R,E,F,H,Rows,observe,fold,B,select>,S,Checked.Error<Error>>:
  match value:
    case Application{app}:returned(~S,~C,~R,~E,~F,~H,~Rows,~observe,~fold,~B,~select,~Error,Old.run_classic(~S,~C,~R,~E,~(H & (F & Nat)),~Rows,~observe,~fold_family(~S,~H,~F,~fold),~B,~select,~Error,~dispatch,~provision,app))

def returned_context(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~Error:Data,value:Execution.Run<Old.Application<S,C,R,E,(H & (F & Nat)),Rows,observe,fold_family(~S,~H,~F,~fold),B,select>,S,Checked.Error<Error>>) -> Execution.Run<Application<S,C,R,E,F,H,Rows,observe,fold,B,select>,S,Checked.Error<Error>>:
  match value:
    case Execution.Run{result,batch}:Execution.Run{returned(~S,~C,~R,~E,~F,~H,~Rows,~observe,~fold,~B,~select,~Error,result),batch}

def run(~S:Data,~C:Type,~R:Type,~E:Data,~F:Type,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Fields.Fields<S>>,~B:Type,~select:B -> W.World<S,C,R,E> -> U32 -> B.Selection<W.World<S,C,R,E>,B>,~Error:Data,~dispatch:(H & (F & Nat)) -> Ctx.Context<W.World<S,C,R,E>> -> U32 -> (H & (F & Nat)) & Sys.Outcome<Ctx.Context<W.World<S,C,R,E>>,Error,Unit>,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,F,H,Rows,observe,fold,B,select>) -> Execution.Run<Application<S,C,R,E,F,H,Rows,observe,fold,B,select>,S,Checked.Error<Error>>:
  match value:
    case Application{app}:returned_context(~S,~C,~R,~E,~F,~H,~Rows,~observe,~fold,~B,~select,~Error,Old.run(~S,~C,~R,~E,~(H & (F & Nat)),~Rows,~observe,~fold_family(~S,~H,~F,~fold),~B,~select,~Error,~dispatch,~provision,app))
