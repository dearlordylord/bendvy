import Base
import ./execution-save-plan.bend as Plan
import ./execution-save-traversal.bend as Traverse
import ./execution-save-rows.bend as Rows
import ./execution-save-data.bend as Saved
import ./execution-save-recipe.bend as Recipe
import ./execution-save-metadata.bend as Metadata
import ./execution-save-gate.bend as Gate
import ./execution-composer-layout.bend as Layout
import ./snapshot-data.bend as Legacy
import ./world.bend as W
import ./entity-allocator.bend as Alloc
import ./clock-state.bend as Clock
import ./execution-lifecycle-notices.bend as Notice
import ./deferred-command.bend as Deferred

type Remainder<-S:Data,-C:Type,-R:Type,-E:Data> is Type:
  Remainder{namespace:U32,allocator:Alloc.Allocator,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,journal:Notice.Journal<S>}
def assembled(~S:Data,~C:Type,~R:Type,~E:Data,rest:Remainder<S,C,R,E>,columns:C,resources:R) -> W.World<S,C,R,E>:
  match rest:
    case Remainder{namespace,allocator,events,pending,registrations,nextSystemId,clock,journal}:W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystemId,clock,journal}
def exported(~S:Data,~cp:Plan.Plan,~rp:Plan.Plan,~E:Data,componentRecipes:Plan.Recipes(~S,cp),columns:Layout.columns(~S,Plan.layout(cp)),rest:Remainder<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E>,metadata:Metadata.Metadata<S>,rows:List<&2,Saved.Entity>,result:Plan.Recipes(~S,rp) & (Layout.resources(~S,Plan.layout(rp)) & Saved.Fields)) -> Plan.Schema<S,cp,rp> & (W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  match result:
    case (resourceRecipes,(resources,Saved.Fields{_,Some{error}})):(Plan.Schema{componentRecipes,resourceRecipes},(assembled(~S,~Layout.columns(~S,Plan.layout(cp)),~Layout.resources(~S,Plan.layout(rp)),~E,rest,columns,resources),Gate.Refused{error}))
    case (resourceRecipes,(resources,Saved.Fields{fields,None{}})):(Plan.Schema{componentRecipes,resourceRecipes},(assembled(~S,~Layout.columns(~S,Plan.layout(cp)),~Layout.resources(~S,Plan.layout(rp)),~E,rest,columns,resources),Gate.Saved{Saved.Snapshot{2,metadata,rows,fields}}))
def rows_returned(~S:Data,~cp:Plan.Plan,~rp:Plan.Plan,~E:Data,resourceRecipes:Plan.Recipes(~S,rp),resources:Layout.resources(~S,Plan.layout(rp)),rest:Remainder<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E>,metadata:Metadata.Metadata<S>,result:Plan.Recipes(~S,cp) & (Layout.columns(~S,Plan.layout(cp)) & (List<&2,Saved.Entity> & Maybe<&2,Recipe.Refusal>))) -> Plan.Schema<S,cp,rp> & (W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  match result:
    case (componentRecipes,(columns,(_,Some{error}))):(Plan.Schema{componentRecipes,resourceRecipes},(assembled(~S,~Layout.columns(~S,Plan.layout(cp)),~Layout.resources(~S,Plan.layout(rp)),~E,rest,columns,resources),Gate.Refused{error}))
    case (componentRecipes,(columns,(rows,None{}))):exported(~S,~cp,~rp,~E,componentRecipes,columns,rest,metadata,rows,Traverse.resources(~S,rp)(resourceRecipes,resources))
def handles_returned(~S:Data,~cp:Plan.Plan,~rp:Plan.Plan,~E:Data,schema:Plan.Schema<S,cp,rp>,metadata:Metadata.Metadata<S>,result:W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & List<&2,W.Handle<S>>) -> Plan.Schema<S,cp,rp> & (W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  match schema result:
    case Plan.Schema{componentRecipes,resourceRecipes}, (W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystemId,clock,journal},handles):rows_returned(~S,~cp,~rp,~E,resourceRecipes,resources,Remainder{namespace,allocator,events,pending,registrations,nextSystemId,clock,journal},metadata,Rows.rows(~S,~cp,handles,componentRecipes,columns))
def metadata_returned(~S:Data,~cp:Plan.Plan,~rp:Plan.Plan,~E:Data,schema:Plan.Schema<S,cp,rp>,result:W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Metadata.Metadata<S>) -> Plan.Schema<S,cp,rp> & (W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  match result:
    case (world,metadata):handles_returned(~S,~cp,~rp,~E,schema,metadata,W.handles(~S,~Layout.columns(~S,Plan.layout(cp)),~Layout.resources(~S,Plan.layout(rp)),~E,world))
def unique(valid:Bool) -> Maybe<&2,Recipe.Refusal>:
  match valid:
    case True{}:None{}
    case False{}:Some{Recipe.DescriptorMismatch{"unique layout keys","duplicate key"}}
def eligibility_result(result:Maybe<&2,String>,valid:Bool) -> Maybe<&2,Recipe.Refusal>:
  match result:
    case Some{key}:Some{Recipe.PlainUnserializable{key}}
    case None{}:unique(valid)
def eligibility(~cp:Plan.Plan,~rp:Plan.Plan) -> Maybe<&2,Recipe.Refusal>:
  eligibility_result(Plan.first(Plan.ineligible(cp),Plan.ineligible(rp)),Bool.and(Layout.unique(Plan.layout(cp)),Layout.unique(Plan.layout(rp))))
def eligible(~S:Data,~cp:Plan.Plan,~rp:Plan.Plan,~E:Data,schema:Plan.Schema<S,cp,rp>,world:W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E>,error:Maybe<&2,Recipe.Refusal>) -> Plan.Schema<S,cp,rp> & (W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  match error:
    case Some{error}:(schema,(world,Gate.Refused{error}))
    case None{}:metadata_returned(~S,~cp,~rp,~E,schema,Metadata.capture(~S,~Layout.columns(~S,Plan.layout(cp)),~Layout.resources(~S,Plan.layout(rp)),~E,world))
def ready(~S:Data,~cp:Plan.Plan,~rp:Plan.Plan,~E:Data,schema:Plan.Schema<S,cp,rp>,result:W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Bool) -> Plan.Schema<S,cp,rp> & (W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  match result:
    case (world,False{}):(schema,(world,Gate.RefusedPending{}))
    case (world,True{}):eligible(~S,~cp,~rp,~E,schema,world,eligibility(~cp,~rp))
# Internal World phase. Ordinary applications must first inventory their actual
# command owners with execution-save-gate; legacy World.pending is additional.
# Eligibility of the entire closed schema precedes metadata and field projection.
def save(~S:Data,~cp:Plan.Plan,~rp:Plan.Plan,~E:Data,schema:Plan.Schema<S,cp,rp>,world:W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E>) -> Plan.Schema<S,cp,rp> & (W.World<S,Layout.columns(~S,Plan.layout(cp)),Layout.resources(~S,Plan.layout(rp)),E> & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  ready(~S,~cp,~rp,~E,schema,Legacy.ready(~S,~Layout.columns(~S,Plan.layout(cp)),~Layout.resources(~S,Plan.layout(rp)),~E,world))
