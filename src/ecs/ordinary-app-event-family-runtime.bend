import Base
import ./ordinary-event-family.bend as Family
import ./event-family-runtime.bend as FamilyRuntime
import ./world.bend as W
import ./ordinary-schema.bend as Schema
import ./ordinary-app-schema.bend as SchemaApp
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-observation-data.bend as DTO
import ./event-family-routing.bend as Route
# Family is retained opaquely, including actual streams, journal and reader owners.
# Debug round-trips the sole World without synchronization, trim, frame or dispatch.
# Ordinary schema App with one actual family runtime, World and registration
# owners. F may contain affine streams/reader state; this wrapper does not clone
# that state or expose it through detached observation rows.
type Application<S:Data,C:Type,R:Type,P:Data,F:Type,Owners:Type,Rows:Data,-observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,-fold:Owners -> Owners & List<&2,Records.Fields<S>>> is Type:
  Application{schema:Schema.Schema<S,C,R>,runtime:Route.Runtime<S,C,R,P,F>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,P>,Rows,observe>,debug:Bool}
# Advanced attachment of an existing runtime family and tick to a schema App.
# Retains World/owners/recipe/debug without synchronization or frame advancement.
def attached(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,family:F,tick:Nat,value:SchemaApp.Application<S,C,R,P,Owners,Rows,observe,fold>) -> Application<S,C,R,P,F,Owners,Rows,observe,fold>:
  match value:
    case SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}:Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}
def returned(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~Out:Type,family:F,tick:Nat,result:SchemaApp.Application<S,C,R,P,Owners,Rows,observe,fold> & Out) -> Application<S,C,R,P,F,Owners,Rows,observe,fold> & Out:
  match result:
    case (SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}},output):(Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug},output)
# Advanced adapter temporarily exposing the schema App to an owner-returning
# action while retaining family state and tick. It does not automatically sync
# publications or repair arbitrary action effects; action is trusted integration.
def with_previous(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~Out:Type,action:SchemaApp.Application<S,C,R,P,Owners,Rows,observe,fold> -> SchemaApp.Application<S,C,R,P,Owners,Rows,observe,fold> & Out,value:Application<S,C,R,P,F,Owners,Rows,observe,fold>) -> Application<S,C,R,P,F,Owners,Rows,observe,fold> & Out:
  match value:
    case Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}:returned(~S,~C,~R,~P,~F,~Owners,~Rows,~observe,~fold,~Out,family,tick,action(SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}))
# Return the App with its ordinary schema description, preserving family and tick.
# Disabled observation bypasses fold/observe in SchemaApp.snapshot. No reader
# acknowledgement, trim, synchronization, dispatch or structural barrier is added.
def snapshot(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:Application<S,C,R,P,F,Owners,Rows,observe,fold>) -> Application<S,C,R,P,F,Owners,Rows,observe,fold> & Maybe<&2,SchemaApp.Description<S,Rows>>:
  with_previous(~S,~C,~R,~P,~F,~Owners,~Rows,~observe,~fold,~Maybe<&2,SchemaApp.Description<S,Rows>>,SchemaApp.snapshot(~S,~C,~R,~P,~Owners,~Rows,~observe,~fold),value)
# Initialize the supplied canonical family provision with capacity and actual event
# owners, retaining the schema App World/registrations/observer/debug. This starts
# family storage/journal state; it does not register or execute gameplay readers.
def start(~S:Data,~C:Type,~R:Type,~P:Data,~Domains:Data,~Leaves:Type,~EventOwners:Type,~make:Domains -> Nat -> Leaves,~sync:Leaves -> Nat -> List<&2,P> -> Leaves,~frame:Leaves -> Nat -> Leaves,~retain:Leaves -> Nat -> List<&2,P> -> Leaves & List<&2,P>,~inventory:Leaves -> Leaves & List<&2,String>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,provision:Family.Provision<S,P,Domains,Leaves,make,sync,frame,retain,inventory>,events:EventOwners,capacity:Nat,value:SchemaApp.Application<S,C,R,P,Owners,Rows,observe,fold>) -> Application<S,C,R,P,FamilyRuntime.State<P,Leaves,EventOwners>,Owners,Rows,observe,fold>:
  match value:
    case SchemaApp.Application{schema,Build.Registered{world,owners,recipe,debug}}:Application{schema,FamilyRuntime.setup(~S,~C,~R,~P,~Domains,~Leaves,~EventOwners,~make,~sync,~frame,~retain,~inventory,world,provision,events,capacity),owners,recipe,debug}
# Set only App observation enablement, retaining runtime and all actual owners.
def enabled(~S:Data,~C:Type,~R:Type,~P:Data,~F:Type,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:Application<S,C,R,P,F,Owners,Rows,observe,fold>,flag:Bool) -> Application<S,C,R,P,F,Owners,Rows,observe,fold>:
  match value:
    case Application{schema,runtime,owners,recipe,_}:Application{schema,runtime,owners,recipe,flag}
def inventory_returned(~S:Data,~C:Type,~R:Type,~P:Data,~Leaves:Type,~EventOwners:Type,~inventory:Leaves -> Leaves & List<&2,String>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,schema:Schema.Schema<S,C,R>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,P>,Rows,observe>,debug:Bool,result:Route.Runtime<S,C,R,P,FamilyRuntime.State<P,Leaves,EventOwners>> & Maybe<&2,List<&2,String>>) -> Application<S,C,R,P,FamilyRuntime.State<P,Leaves,EventOwners>,Owners,Rows,observe,fold> & Maybe<&2,List<&2,String>>:
  match result:
    case (runtime,names):(Application{schema,runtime,owners,recipe,debug},names)
# Return App and optional family inventory through its generated inventory adapter.
# Disabled returns None before deriving inventory; enabled returns detached names
# while threading actual runtime state. This is not payload reading or retention.
def inventory(~S:Data,~C:Type,~R:Type,~P:Data,~Leaves:Type,~EventOwners:Type,~inventory:Leaves -> Leaves & List<&2,String>,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,P> -> W.World<S,C,R,P> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,value:Application<S,C,R,P,FamilyRuntime.State<P,Leaves,EventOwners>,Owners,Rows,observe,fold>) -> Application<S,C,R,P,FamilyRuntime.State<P,Leaves,EventOwners>,Owners,Rows,observe,fold> & Maybe<&2,List<&2,String>>:
  match value:
    case Application{schema,runtime,owners,recipe,+debug}:inventory_returned(~S,~C,~R,~P,~Leaves,~EventOwners,~inventory,~Owners,~Rows,~observe,~fold,schema,owners,recipe,debug,FamilyRuntime.inventory_enabled(~S,~C,~R,~P,~Leaves,~EventOwners,~inventory,debug,runtime))
