import Base
import ./execution-trace.bend as Trace
import ./ordinary-app-schedule.bend as Single
import ./ordinary-app-schema.bend as App
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-schema.bend as Schema
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP

# A detached batch is returned only after its actual ECS run has completed.
type Run<A:Type,S:Data,Error:Data> is Type:
  Run{result:Single.RunResult<A,S,Error>,batch:Trace.Batch<Error>}
type Journal<Error:Data> is Data:
  Journal{catalog:List<&2,Trace.Identity>,events:List<&2,Trace.TraceEvent<Error>>}
def catalog(~S:Data,fields:List<&2,Records.Fields<S>>) -> List<&2,Trace.Identity>:
  match fields:
    case []:[]
    case Records.Fields{namespace,id,name,_,_,_,_,_} <> rest:Trace.Identity{namespace,id,Some{name}} <> catalog(~S,rest)
def named(found:Bool,name:Maybe<&2,String>,next:Unit -> Maybe<&2,String>) -> Maybe<&2,String>:
  match found:
    case True{}:name
    case False{}:next(Unit{})
def registration_name(items:List<&2,Trace.Identity>,+id:U32) -> Maybe<&2,String>:
  match items:
    case []:None{}
    case Trace.Identity{_,candidate,name} <> rest:named(U32.is_eq(candidate,id),name,_ => registration_name(rest,id))
def identity_clock(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,id:U32,name:Maybe<&2,String>,observed:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & (Trace.Identity & U32):
  match observed:
    case (world,clock):(world,(Trace.Identity{namespace,id,name},clock))
def identity_namespace(~S:Data,~C:Type,~R:Type,~E:Data,id:U32,name:Maybe<&2,String>,observed:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & (Trace.Identity & U32):
  match observed:
    case (world,namespace):identity_clock(~S,~C,~R,~E,namespace,id,name,W.clock(~S,~C,~R,~E,world))
def identity(~S:Data,~C:Type,~R:Type,~E:Data,~Error:Data,journal:Journal<Error>,world:W.World<S,C,R,E>,+id:U32) -> W.World<S,C,R,E> & (Trace.Identity & U32):
  match journal:
    case Journal{catalog,_}:identity_namespace(~S,~C,~R,~E,id,registration_name(catalog,id),W.namespace(~S,~C,~R,~E,world))
def record(~Error:Data,event:Trace.TraceEvent<Error>,journal:Journal<Error>) -> Journal<Error>:
  match journal:
    case Journal{catalog,events}:Journal{catalog,event <> events}
def succeeded(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,owners:H,fact:Trace.Identity,before:U32,journal:Journal<Error>,observed:W.World<S,C,R,E> & U32) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match observed:
    case (world,after):((owners,record(~Error,Trace.SystemCompleted{fact,before,after,Trace.SystemOk{}},journal)),Sys.Succeeded{world,Unit{}})
def failed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,owners:H,fact:Trace.Identity,before:U32,journal:Journal<Error>,+error:Error,observed:W.World<S,C,R,E> & U32) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match observed:
    case (world,after):((owners,record(~Error,Trace.SystemCompleted{fact,before,after,Trace.SystemError{error}},journal)),Sys.Failed{world,error})
def dispatched(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,fact:Trace.Identity,before:U32,journal:Journal<Error>,result:H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match result:
    case (owners,Sys.Succeeded{world,_}):succeeded(~S,~C,~R,~E,~H,~Error,owners,fact,before,journal,W.clock(~S,~C,~R,~E,world))
    case (owners,Sys.Failed{world,error}):failed(~S,~C,~R,~E,~H,~Error,owners,fact,before,journal,error,W.clock(~S,~C,~R,~E,world))
def identified(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,owners:H,journal:Journal<Error>,+id:U32,result:W.World<S,C,R,E> & (Trace.Identity & U32)) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match result:
    case (world,(fact,before)):dispatched(~S,~C,~R,~E,~H,~Error,fact,before,journal,dispatch(owners,world,id))
def dispatch_id(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,owners:H & Journal<Error>,world:W.World<S,C,R,E>,+id:U32) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match owners:
    case (owners,+journal):identified(~S,~C,~R,~E,~H,~Error,~dispatch,owners,journal,id,identity(~S,~C,~R,~E,~Error,journal,world,id))
def dispatch_recorded(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,owners:H & Journal<Error>,world:W.World<S,C,R,E>,id:U32) -> (H & Journal<Error>) & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  dispatch_id(~S,~C,~R,~E,~H,~Error,~dispatch,owners,world,id)
# Sch.Ran supplies position only. The completion/error comes from the actual
# dispatch result above, never from a guessed interpretation of Ran.
def merge(~Error:Data,observations:List<&2,Sch.Observation>,journal:List<&2,Trace.TraceEvent<Error>>) -> List<&2,Trace.TraceEvent<Error>>:
  match observations journal:
    case [], journal:journal
    case Sch.Entered{name} <> rest, journal:Trace.PhaseEntered{name} <> merge(~Error,rest,journal)
    case Sch.Skipped{id} <> rest, journal:Trace.SystemSkipped{id} <> merge(~Error,rest,journal)
    case Sch.Applied{} <> rest, journal:Trace.DeferredApplied{} <> merge(~Error,rest,journal)
    case Sch.Ran{_} <> rest, []:merge(~Error,rest,[])
    case Sch.Ran{_} <> rest, event <> tail:event <> merge(~Error,rest,tail)
def batch(~Error:Data,namespace:U32,name:String,observations:List<&2,Sch.Observation>,journal:Journal<Error>,outcome:Trace.Completion<Error>) -> Trace.Batch<Error>:
  match journal:
    case Journal{_,events}:Trace.Ready{Trace.ScheduleStarted{namespace,name} <> List.append(&2,Trace.TraceEvent<Error>,merge(~Error,observations,List.reverse(&2,Trace.TraceEvent<Error>,events)),[Trace.ScheduleEnded{outcome}])}
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>) -> Single.Application<S,C,R,E,H,Rows,observe,fold>:
  Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs}
def executed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,needs:List<&2,SP.Requirement<S>>,result:Sch.RunResult<S,C,R,E,H & Journal<Error>,Error>) -> Run<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match result:
    case Sch.Finished{Sch.Schedule{+namespace,+name,steps,(owners,journal)},world,+observations}:Run{Single.Finished{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,debug,plan,namespace,name,steps,needs),observations},batch(~Error,namespace,name,observations,journal,Trace.EndOk{})}
    case Sch.Failed{Sch.Schedule{+namespace,+name,steps,(owners,journal)},world,+error,+observations}:Run{Single.Failed{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,debug,plan,namespace,name,steps,needs),error,observations},batch(~Error,namespace,name,observations,journal,Trace.EndFailed{error})}
    case Sch.Rejected{Sch.Schedule{+namespace,+name,steps,(owners,journal)},world}:Run{Single.Rejected{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,debug,plan,namespace,name,steps,needs)},Trace.Ready{[Trace.ScheduleAdmissionRefused{namespace,name,Trace.EndRejected{}}]}}
def provisioned(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,schema:Schema.Schema<S,C,R>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plan:SP.Plan<S>,result:SP.ProvisionResult<S,C,R,E,H & Journal<Error>,Error>) -> Run<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match result:
    case SP.Executed{result,needs}:executed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,recipe,debug,plan,needs,result)
    case SP.Missing{SP.Provisioned{Sch.Schedule{+namespace,+name,steps,(owners,journal)},needs},world,+missing}:Run{Single.Missing{restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,world,owners,recipe,debug,plan,namespace,name,steps,needs),missing},Trace.Ready{[Trace.ScheduleAdmissionRefused{namespace,name,Trace.EndMissing{}}]}}
def prepared(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,observed:H & List<&2,Records.Fields<S>>) -> Run<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match observed:
    case (owners,fields):provisioned(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,schema,recipe,True{},plan,SP.run(~S,~C,~R,~E,~(H & Journal<Error>),~Error,~dispatch_recorded(~S,~C,~R,~E,~H,~Error,~dispatch),~condition,~provision,SP.Provisioned{Sch.Schedule{namespace,name,steps,(owners,Journal{catalog(~S,fields),[]})},needs},world))
# Disabled runs use the old ordinary run directly: no identity/clock scan,
# completion journal, trace-event construction or subscriber delivery occurs.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Single.Application<S,C,R,E,H,Rows,observe,fold>) -> Run<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match value:
    case Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,False{}}},plan,namespace,name,steps,needs}:Run{Single.run(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~condition,~provision,Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,False{}}},plan,namespace,name,steps,needs}),Trace.Disabled{}}
    case Single.Application{App.Application{schema,Build.Registered{world,owners,recipe,True{}}},plan,namespace,name,steps,needs}:prepared(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~condition,~provision,schema,world,recipe,plan,namespace,name,steps,needs,fold(owners))
