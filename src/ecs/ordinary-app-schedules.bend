import Base
import ./ordinary-app-access.bend as Access
import ./ordinary-app-schedule-access.bend as SelectedAccess
import ./ordinary-schema.bend as Schema
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-schema.bend as App
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-schedule.bend as Single
import ./ordinary-app-schedule-description.bend as Detail
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
import ./string-equality.bend as Text
# Named plans are Data; one App retains the World and registered owners.
# Detached label and operational plan. Labels select plans in one App; they do
# not own or duplicate the registered systems referenced by those plans.
type Named<S:Data> is Data:
  Named{label:String,plan:SP.Plan<S>}
# One schema App and actual World/registration owners shared by all named plans.
# Plans are Data; running or replacing one does not allocate an independent Local
# or capture state for each name.
type Application<S:Data,C:Type,R:Type,E:Data,H:Type,Rows:Data,-observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,-fold:H -> H & List<&2,Records.Fields<S>>> is Type:
  Application{app:App.Application<S,C,R,E,H,Rows,observe,fold>,plans:List<&2,Named<S>>}
# Insert/replace result returning App in both branches. Inserted returns the
# previous plan for that label (None for a new label); Invalid preserves old plans.
type Insertion<-A:Type,-S:Data> is Type:
  Inserted{app:A,previous:Maybe<&2,SP.Plan<S>>}
  Invalid{app:A}
# Named lookup result: Unknown returns App without execution. Executed contains
# the complete single-schedule result, including retained App on failure/refusal.
type RunResult<-A:Type,-S:Data,-Error:Data> is Type:
  Executed{result:Single.RunResult<A,S,Error>}
  Unknown{app:A}
# Detached shared application description plus ordered named-plan placements.
# This is observation metadata, not a second registry or executable owner bundle.
type Description<S:Data,Rows:Data> is Data:
  Description{application:App.Description<S,Rows>,plans:List<&2,Detail.Description<S,Rows>>}
def lookup_next(~S:Data,found:Bool,plan:SP.Plan<S>,next:Maybe<&2,SP.Plan<S>>) -> Maybe<&2,SP.Plan<S>>:
  match found:
    case True{}:Some{plan}
    case False{}:next
def lookup(~S:Data,+label:String,plans:List<&2,Named<S>>) -> Maybe<&2,SP.Plan<S>>:
  match plans:
    case []:None{}
    case Named{name,plan} <> rest:lookup_next(~S,Text.equal(label,name),plan,lookup(~S,label,rest))
def replace_next(~S:Data,same:Bool,label:String,plan:SP.Plan<S>,old:Named<S>,rest:List<&2,Named<S>>,next:List<&2,Named<S>>) -> List<&2,Named<S>>:
  match same:
    case True{}:Named{label,plan} <> rest
    case False{}:old <> next
def replace(~S:Data,+label:String,+plan:SP.Plan<S>,plans:List<&2,Named<S>>) -> List<&2,Named<S>>:
  match plans:
    case []:[Named{label,plan}]
    case Named{+name,+old} <> +rest:replace_next(~S,Text.equal(label,name),label,plan,Named{name,old},rest,replace(~S,label,plan,rest))
def remove_next(~S:Data,same:Bool,old:Named<S>,rest:List<&2,Named<S>>,next:List<&2,Named<S>>) -> List<&2,Named<S>>:
  match same:
    case True{}:rest
    case False{}:old <> next
def without(~S:Data,+label:String,plans:List<&2,Named<S>>) -> List<&2,Named<S>>:
  match plans:
    case []:[]
    case Named{+name,+plan} <> +rest:remove_next(~S,Text.equal(label,name),Named{name,plan},rest,without(~S,label,rest))
# Wrap an existing schema App with an empty named-plan list. Does not register
# or dispose systems and does not enable debug.
def create(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,app:App.Application<S,C,R,E,H,Rows,observe,fold>) -> Application<S,C,R,E,H,Rows,observe,fold>:
  Application{app,[]}
# Return App and the exact stored plan for label, or None; does not attach/run it.
def get(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,H,Rows,observe,fold>,+label:String) -> Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,SP.Plan<S>>:
  match value:
    case Application{app,+plans}:(Application{app,plans},lookup(~S,label,plans))
# Remove the named Data plan and return App plus its previous plan if present.
# Registered owners remain alive and shared; removal does not dispose a system.
def remove(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,H,Rows,observe,fold>,+label:String) -> Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,SP.Plan<S>>:
  match value:
    case Application{app,+plans}:(Application{app,without(~S,label,plans)},lookup(~S,label,plans))
def inserted(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,+plans:List<&2,Named<S>>,+label:String,+plan:SP.Plan<S>,result:Single.Attachment<App.Application<S,C,R,E,H,Rows,observe,fold>,Single.Application<S,C,R,E,H,Rows,observe,fold>>) -> Insertion<Application<S,C,R,E,H,Rows,observe,fold>,S>:
  match result:
    case Single.Invalid{app}:Invalid{Application{app,plans}}
    case Single.Attached{Single.Application{app,_,_,_,_,_}}:Inserted{Application{app,replace(~S,label,plan,plans)},lookup(~S,label,plans)}
# Validate plan attachment against the actual World registration catalog. Valid
# replacement retains the label's position; a new label appends. Return previous
# plan on success; invalid attachment leaves named plans unchanged. Does not run
# the plan, reset Local/capture owners or accept duplicate/unknown system ids.
# See test-fixtures/public-schedules/named-app-v1/matched-feature-v1/main.bend.
def insert(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,H,Rows,observe,fold>,+label:String,+plan:SP.Plan<S>) -> Insertion<Application<S,C,R,E,H,Rows,observe,fold>,S>:
  match value:
    case Application{app,plans}:inserted(~S,~C,~R,~E,~H,~Rows,~observe,~fold,plans,label,plan,Single.attach(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,label,plan))
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,plans:List<&2,Named<S>>,result:Single.RunResult<Single.Application<S,C,R,E,H,Rows,observe,fold>,S,Error>) -> RunResult<Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match result:
    case Single.Finished{Single.Application{app,_,_,_,_,_},observations}:Executed{Single.Finished{Application{app,plans},observations}}
    case Single.Failed{Single.Application{app,_,_,_,_,_},error,observations}:Executed{Single.Failed{Application{app,plans},error,observations}}
    case Single.Rejected{Single.Application{app,_,_,_,_,_}}:Executed{Single.Rejected{Application{app,plans}}}
    case Single.Missing{Single.Application{app,_,_,_,_,_},requirements}:Executed{Single.Missing{Application{app,plans},requirements}}
def attached(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,plans:List<&2,Named<S>>,result:Single.Attachment<App.Application<S,C,R,E,H,Rows,observe,fold>,Single.Application<S,C,R,E,H,Rows,observe,fold>>) -> RunResult<Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match result:
    case Single.Invalid{app}:Executed{Single.Rejected{Application{app,plans}}}
    case Single.Attached{app}:restored(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,plans,Single.run(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~condition,~provision,app))
def selected(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,app:App.Application<S,C,R,E,H,Rows,observe,fold>,plans:List<&2,Named<S>>,label:String,found:Maybe<&2,SP.Plan<S>>) -> RunResult<Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match found:
    case None{}:Unknown{Application{app,plans}}
    case Some{plan}:attached(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~condition,~provision,plans,Single.attach(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,label,plan))
# Look up label, reattach its plan against the current catalog, then run through
# the supplied single-schedule dispatch/condition/provision adapters. Unknown runs
# nothing; attachment rejection becomes Executed(Rejected). Restore the same named
# plan list around every run result, retaining actual returned World and shared
# runner owners. Prior successful systems are not rolled back as one named run.
# Callbacks remain trusted setup; barriers occur only at explicit plan steps.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,~Error:Data,~dispatch:H -> W.World<S,C,R,E> -> U32 -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~condition:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,~provision:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>,value:Application<S,C,R,E,H,Rows,observe,fold>,+label:String) -> RunResult<Application<S,C,R,E,H,Rows,observe,fold>,S,Error>:
  match value:
    case Application{app,+plans}:selected(~S,~C,~R,~E,~H,~Rows,~observe,~fold,~Error,~dispatch,~condition,~provision,app,plans,label,lookup(~S,label,plans))
# Set shared App observation enablement, preserving all named plans and owners.
def enabled(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,H,Rows,observe,fold>,flag:Bool) -> Application<S,C,R,E,H,Rows,observe,fold>:
  match value:
    case Application{app,plans}:Application{App.enabled(~S,~C,~R,~E,~H,~Rows,~observe,~fold,app,flag),plans}
# All registered bindings remain in application; each placement references the
# same derived declaration inventory. Disabled App.snapshot returns before work.
def descriptions(~S:Data,~Rows:Data,+view:App.Description<S,Rows>,+namespace:U32,plans:List<&2,Named<S>>) -> List<&2,Detail.Description<S,Rows>>:
  match plans:
    case []:[]
    case Named{label,+plan} <> rest:Detail.described(~S,~Rows,Single.Description{view,namespace,label,Single.planned(~S,plan)}) <> descriptions(~S,~Rows,view,namespace,rest)
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,+plans:List<&2,Named<S>>,namespace:U32,result:App.Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,App.Description<S,Rows>>) -> Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match result:
    case (app,None{}):(Application{app,plans},None{})
    case (app,Some{+view}):(Application{app,plans},Some{Description{view,descriptions(~S,~Rows,view,namespace,plans)}})
def cataloged_snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,debug:Bool,plans:List<&2,Named<S>>,result:W.World<S,C,R,E> & U32) -> Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match result:
    case (world,namespace):observed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,plans,namespace,App.snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,App.Application{schema,Build.Registered{world,owners,recipe,debug}}))
# Return App with optional combined application/named-plan descriptions. Disabled
# returns None before fold/observe/placement work. Enabled uses one derived binding
# inventory for every placement; no system runs or command barrier is applied.
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,H,Rows,observe,fold>) -> Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Description<S,Rows>>:
  match value:
    case Application{App.Application{schema,Build.Registered{world,owners,recipe,False{}}},plans}:(Application{App.Application{schema,Build.Registered{world,owners,recipe,False{}}},plans},None{})
    case Application{App.Application{schema,Build.Registered{world,owners,recipe,True{}}},plans}:cataloged_snapshot(~S,~C,~R,~E,~H,~Rows,~observe,~fold,schema,owners,recipe,True{},plans,W.namespace(~S,~C,~R,~E,world))
# Detached grouped declared accesses for one stored label, selected by its plan.
type PlanIndex is Data:
  PlanIndex{label:String,entries:List<&2,Access.Entry>}
# Detached namespace, complete registration access inventory and named indexes.
# Inventory includes unplaced registrations; plans reference the shared owners.
type Index is Data:
  Index{namespace:U32,inventory:List<&2,Access.Entry>,plans:List<&2,PlanIndex>}
def plan_indexes(~S:Data,+namespace:U32,+records:List<&2,Records.Fields<S>>,plans:List<&2,Named<S>>) -> List<&2,PlanIndex>:
  match plans:
    case []:[]
    case Named{label,plan} <> rest:PlanIndex{label,Access.grouped(Access.fields(~S,SelectedAccess.placed(~S,Single.planned(~S,plan),namespace,records)),[])} <> plan_indexes(~S,namespace,records,rest)
def indexed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,world:W.World<S,C,R,E>,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,+plans:List<&2,Named<S>>,+namespace:U32,result:H & List<&2,Records.Fields<S>>) -> Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Index>:
  match result:
    case (owners,+records):(Application{App.Application{schema,Build.Registered{world,owners,recipe,True{}}},plans},Some{Index{namespace,Access.grouped(Access.fields(~S,records),[]),plan_indexes(~S,namespace,records,plans)}})
def index_named(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,owners:H,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,observe>,plans:List<&2,Named<S>>,result:W.World<S,C,R,E> & U32) -> Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Index>:
  match result:
    case (world,namespace):indexed(~S,~C,~R,~E,~H,~Rows,~observe,~fold,schema,world,recipe,plans,namespace,fold(owners))
# Return App and optional declared-access index. Disabled bypasses fold/index
# derivation. Enabled folds actual owners and selects each plan's namespace/id
# placements; this grants no execution authority and does not inspect payloads.
def index(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:H -> H & List<&2,Records.Fields<S>>,value:Application<S,C,R,E,H,Rows,observe,fold>) -> Application<S,C,R,E,H,Rows,observe,fold> & Maybe<&2,Index>:
  match value:
    case Application{App.Application{schema,Build.Registered{world,owners,recipe,False{}}},plans}:(Application{App.Application{schema,Build.Registered{world,owners,recipe,False{}}},plans},None{})
    case Application{App.Application{schema,Build.Registered{world,owners,recipe,True{}}},plans}:index_named(~S,~C,~R,~E,~H,~Rows,~observe,~fold,schema,owners,recipe,plans,W.namespace(~S,~C,~R,~E,world))
