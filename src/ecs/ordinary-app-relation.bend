import Base
import entity-key-render.bend as KeyText
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
import ./ordinary-app-registration-fields.bend as Fields
import ./world.bend as W
import ./inspector.bend as I
import ./relation-failure-reader.bend as Ord
import ./relation-types.bend as G
import ./relation-commands.bend as A
import ./relation-query.bend as RQ
import ./relation-providers.bend as P
import ./inspector-relation-projection.bend as IR
import ./inspector-query.bend as IQ
import ./inspector-query-projection.bend as Select
import ./transaction.bend as T
import ./commands.bend as Cmd

# One trusted ordinary relation declaration drives operational grants and view.
# Trusted setup projection of the retained relation declaration. The descriptor
# selects operational authority; presentation strings do not create another grant.
def descriptor(~S:Data,declaration:Ord.Declaration<S>) -> G.Descriptor<S>:
  match declaration:
    case Ord.Declaration{value}:value
def kind(value:G.RelationKind) -> String:
  match value:
    case G.Ordinary{}:"Ordinary"
    case G.Hierarchy{}:"Hierarchy"
def descriptor_text(~S:Data,value:G.Descriptor<S>) -> String:
  match value:
    case G.Descriptor{key,name,inverseName,tag}:"Relation{key=" ++ U32.show(key) ++ "|name=" ++ name ++ "|inverse=" ++ inverseName ++ "|kind=" ++ kind(tag) ++ "}"
def declared_spec(~S:Data,+value:G.Descriptor<S>) -> RQ.Spec<S>:
  match value:
    case G.Descriptor{+key,+name,+inverseName,+tag}:RQ.Spec{[RQ.optional_relation(~S,name,G.Descriptor{key,name,inverseName,tag}),RQ.optional_related(~S,inverseName,G.Descriptor{key,name,inverseName,tag})]}
# Inspector setup for optional outgoing and inverse cells of this declaration.
# Optional cells retain unlinked entities rather than requiring an existing edge.
def spec(~S:Data,declaration:Ord.Declaration<S>) -> RQ.Spec<S>:
  match declaration:
    case Ord.Declaration{+value}:declared_spec(~S,value)
# Advanced storage projection: relation edges wrap C and relation notices wrap E.
# The World remains an affine owner threaded through every App operation.
def World(~S:Data,~C:Type,~R:Type,~E:Data) -> Type:
  W.World<S,A.Store<S,C>,R,A.Notice<S,E>>
# Detached inspector row containing an entity handle and optional relation cells.
def Row(~S:Data) -> Data:
  IQ.ProjectedRow<S,Select.Product<Unit,List<&2,RQ.Cell<S>>>>
# Detached relation observation: the declared descriptor and ordered inspector rows.
# This Data value does not grant access to the underlying World or inverse storage.
type View<S:Data> is Data:
  View{descriptor:G.Descriptor<S>,rows:List<&2,Row(~S)>}
# Advanced observation shape pairing prior rows with the added relation view.
def ObservedRows(~S:Data,~Rows:Data) -> Data:
  DTO.Product<Rows,View<S>>
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{ns,id}:U32.show(ns) ++ ":" ++ KeyText.show(id)
def relation_value(~S:Data,value:RQ.Value<S>) -> String:
  match value:
    case RQ.Missing{}:"Missing"
    case RQ.Target{target}:"Target:" ++ handle(~S,target)
    case RQ.Sources{targets}:"Sources:" ++ List.show(&2,W.Handle<S>,handle(~S),targets)
def end(value:RQ.End) -> String:
  match value:
    case RQ.Outgoing{}:"Outgoing"
    case RQ.Incoming{}:"Incoming"
def cell(~S:Data,value:RQ.Cell<S>) -> String:
  match value:
    case RQ.Cell{key,direction,value}:key ++ ":" ++ end(direction) ++ ":" ++ relation_value(~S,value)
# Default textual presentation of a detached row; it does not perform a query.
def builtin_row(~S:Data,value:Row(~S)) -> String:
  match value:
    case IQ.ProjectedRow{entity,Select.Product{_,cells}}:handle(~S,entity) ++ ":" ++ List.show(&2,RQ.Cell<S>,cell(~S),cells)
def rendered(~S:Data,~render:Row(~S) -> String,rows:List<&2,Row(~S)>) -> List<&2,String>:
  match rows:
    case []:[]
    case first <> rest:render(first) <> rendered(~S,~render,rest)
def presented(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,result:I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>> & List<&2,Row(~S)>) -> World(~S,~C,~R,~E) & DTO.Observation<View<S>>:
  match result:
    case (I.Frame{world,_},+rows):(world,DTO.Observation{View{descriptor(~S,declaration),rows},descriptor_text(~S,descriptor(~S,declaration)) <> rendered(~S,~render,rows)})
# Read a fresh relation inspector view while returning the World owner.
# Uses a fresh inspector cursor; it does not advance a registered gameplay reader
# or apply queued commands. The renderer consumes detached rows only.
def observe(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,world:World(~S,~C,~R,~E)) -> World(~S,~C,~R,~E) & DTO.Observation<View<S>>:
  presented(~S,~C,~R,~E,~declaration,~render,IQ.each_composed(~I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,~S,~Select.Product<Unit,List<&2,RQ.Cell<S>>>,~IR.grant(~S,~C,~R,~E,~Unit,~Select.empty(~I.Frame<S,A.Store<S,C>,R,A.Notice<S,E>>,~S),~spec(~S,declaration)),I.Frame{world,0}))
# Advanced recipe adapter: retain the prior observation, then append this view.
# The shared World owner is passed through both observers in that order.
def observation(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<ObservedRows(~S,~Rows)>:
  Tree.observe_pair(~World(~S,~C,~R,~E),~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~declaration,~render))
# Advanced App type with a caller-supplied detached-row renderer. World,
# registration owners and the combined observation recipe remain inside the App.
def presented_Application(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Build.Registered<S,World(~S,~C,~R,~E),Owners,ObservedRows(~S,~Rows),Tree.observe_pair(~World(~S,~C,~R,~E),~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~declaration,~render)),fold>
# Advanced recipe type for prior rows followed by the custom relation view.
def presented_Recipe(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  Tree.Recipe<World(~S,~C,~R,~E),ObservedRows(~S,~Rows),Tree.observe_pair(~World(~S,~C,~R,~E),~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~declaration,~render))>
# Install the custom relation observation recipe, preserving World, registration
# owners and debug state. This does not create edges or register a gameplay system.
def presented_install(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,World(~S,~C,~R,~E),Owners,Rows,prior,fold>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold):
  match app:
    case Build.Registered{world,owners,_,debug}:Build.Registered{world,owners,Tree.Recipe{},debug}
# Set observation enablement from flag, then snapshot through the installed recipe.
# Returns the App in both cases; disabled observation returns None.
def presented_snapshot_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),flag:Bool) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<ObservedRows(~S,~Rows)>>>:
  Build.snapshot(~S,~World(~S,~C,~R,~E),~Owners,~ObservedRows(~S,~Rows),~Tree.observe_pair(~World(~S,~C,~R,~E),~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~declaration,~render)),~fold,Build.enabled(~S,~World(~S,~C,~R,~E),~Owners,~ObservedRows(~S,~Rows),~Tree.observe_pair(~World(~S,~C,~R,~E),~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~declaration,~render)),~fold,app,flag))
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,owners:Owners,recipe:presented_Recipe(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),debug:Bool,result:T.Returned<World(~S,~C,~R,~E),Error>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Error>:
  match result:
    case T.Returned{world,status}:(Build.Registered{world,owners,recipe,debug},status)
def queue_finished(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,status:A.QueueStatus,result:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Error>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  match result:
    case (app,outcome):(app,DTO.Product{status,outcome})
def queued(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,owners:Owners,recipe:presented_Recipe(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),debug:Bool,outcome:T.Outcome<Error>,result:T.Tx<World(~S,~C,~R,~E),A.Notice<S,E>> & A.QueueStatus) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  match result:
    case (frame,+status):queue_finished(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,~Error,status,returned(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,~Error,owners,recipe,debug,Cmd.tx_finish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Error,frame,outcome)))
# Stage source-to-target replacement under this declaration, then finish the
# transaction with the supplied outcome. Return the App, queue status and outcome
# separately: Queued is not barrier application success. Failure discards staged
# commands; barrier-time structural rejection is reported through relation notices.
def presented_relate_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),targets:P.Targets<S>,outcome:T.Outcome<Error>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:queued(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,~Error,owners,recipe,debug,outcome,P.relate(~T.Tx<World(~S,~C,~R,~E),A.Notice<S,E>>,~S,~P.provide_write(~S,~C,~R,~E,~descriptor(~S,declaration)),T.begin(~World(~S,~C,~R,~E),~A.Notice<S,E>,world),targets))
# Stage removal of this source relation and finish with the supplied outcome.
# Returns App plus queue status and transaction outcome; successful staging remains
# invisible to graph reads until a barrier, and transaction failure discards it.
def presented_unrelate_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),source:W.Handle<S>,outcome:T.Outcome<Error>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:queued(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,~Error,owners,recipe,debug,outcome,P.unrelate(~T.Tx<World(~S,~C,~R,~E),A.Notice<S,E>>,~S,~P.provide_write(~S,~C,~R,~E,~descriptor(~S,declaration)),T.begin(~World(~S,~C,~R,~E),~A.Notice<S,E>,world),source))
def inverse_finished(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,value:Maybe<&2,List<&2,W.Handle<S>>>,result:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & T.Outcome<Unit>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,List<&2,W.Handle<S>>>:
  match result:
    case (app,_):(app,value)
def inverse_taken(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,owners:Owners,recipe:presented_Recipe(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),debug:Bool,result:T.Tx<World(~S,~C,~R,~E),A.Notice<S,E>> & Maybe<&2,List<&2,W.Handle<S>>>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,List<&2,W.Handle<S>>>:
  match result:
    case (frame,value):inverse_finished(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,value,returned(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,~Unit,owners,recipe,debug,Cmd.tx_finish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Unit,frame,T.Success{})))
# Read the current inverse list in stored order and return the App owner. None
# denotes an invalid target; Some may contain an empty list. Pending commands are
# not applied, and this read does not offer direct inverse-list mutation.
def presented_inverse_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold),target:W.Handle<S>) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,List<&2,W.Handle<S>>>:
  match app:
    case Build.Registered{world,owners,recipe,debug}:inverse_taken(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold,owners,recipe,debug,P.read(~T.Tx<World(~S,~C,~R,~E),A.Notice<S,E>>,~S,~P.provide_read(~S,~C,~R,~E,~descriptor(~S,declaration)),T.begin(~World(~S,~C,~R,~E),~A.Notice<S,E>,world),target))
# Apply the World structural barrier, returning the App with its owners and recipe.
# This drains pending World commands, not only commands for this declaration;
# structural relation failures are published as notices by their command handlers.
def presented_barrier_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~render:Row(~S) -> String,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold)) -> presented_Application(~S,~C,~R,~E,~declaration,~render,~Owners,~Rows,~prior,~fold):
  match app:
    case Build.Registered{world,owners,recipe,debug}:Build.Registered{W.barrier(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world),owners,recipe,debug}
# Ordinary relation App using builtin_row presentation and the retained declaration.
def Application(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  presented_Application(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold)

# Advanced default-renderer recipe projection for composing typed App adapters.
def Recipe(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>) -> Type:
  presented_Recipe(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold)

# Install the default relation observer without changing graph edges or owners.
# Typical order: install, relate_app with a successful outcome, barrier_app, then
# inverse_app or snapshot_app. See docs/parity/relations.md for accepted scenarios.
def install(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Build.Registered<S,World(~S,~C,~R,~E),Owners,Rows,prior,fold>) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold):
  presented_install(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,app)

# Default-renderer snapshot; flag controls observation and the App is returned
# even when the observation is disabled (None). Does not apply pending commands.
def snapshot_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold),flag:Bool) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<ObservedRows(~S,~Rows)>>>:
  presented_snapshot_app(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,app,flag)

# Default-renderer source-to-target request. Returns queue status separately from
# the supplied transaction outcome; call barrier_app before expecting graph changes.
def relate_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold),targets:P.Targets<S>,outcome:T.Outcome<Error>) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  presented_relate_app(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,~Error,app,targets,outcome)

# Default-renderer source removal request. The App is returned on refusal or
# transaction failure; staging and barrier-time relation validity remain distinct.
def unrelate_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,~Error:Data,app:Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold),source:W.Handle<S>,outcome:T.Outcome<Error>) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold) & DTO.Product<A.QueueStatus,T.Outcome<Error>>:
  presented_unrelate_app(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,~Error,app,source,outcome)

# Default-renderer inverse read, returning the App and Maybe ordered source handles.
# Reads the current graph; pending additions and removals require a barrier first.
def inverse_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold),target:W.Handle<S>) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold) & Maybe<&2,List<&2,W.Handle<S>>>:
  presented_inverse_app(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,app,target)

# Default-renderer structural barrier for all pending commands in this World.
def barrier_app(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~Owners:Type,~Rows:Data,~prior:World(~S,~C,~R,~E) -> World(~S,~C,~R,~E) & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold)) -> Application(~S,~C,~R,~E,~declaration,~Owners,~Rows,~prior,~fold):
  presented_barrier_app(~S,~C,~R,~E,~declaration,~builtin_row(~S),~Owners,~Rows,~prior,~fold,app)
