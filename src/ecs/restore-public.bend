import Base
import ./change-tick.bend as Tick
import ./restore-data.bend as R
import ./restore-schema.bend as Schema
import ./restore-prepare.bend as Prepare
import ./restore-apply.bend as Apply
import ./world.bend as W
import ./snapshot-data.bend as Snapshot
import ./decode-data.bend as D

# Validate and stage a typed snapshot using the retained schema, without a World
# argument or live-world mutation. Check version, nextEntity bounds, duplicate saved
# keys, and schema field dispatch/construction before returning Ready or Refused.
# Refusal retains the input and staging State; staged owners are released through
# the schema adapter where preparation stops. This is typed input, not Raw parsing.
# Use schema-derived codecs/factories; arbitrary adapter behavior is trusted setup.
def prepare(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> Tick.Tick -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,state:State,input:Snapshot.Snapshot) -> R.Prepared<State,Custom>:
  Prepare.prepare(~State,~Custom,~stage,~release,state,input)
# Apply a prepared restore to the supplied World, returning Applied or Refused
# with the World and staging State. A preparation refusal returns World untouched;
# capacity admission precedes cleanup. Successful application cleans current live
# entities, allocates fresh target handles and inserts staged fields, returning
# saved-key-to-handle bindings rather than reusing saved keys as live identities.
# The emit adapter maps ordinary cleanup/spawn changes into E. This basic wrapper
# does not reset a complete App Runtime or reconstruct omitted runtime owners;
# use the runtime restore adapter when its stream/pending-work boundary is needed.
def apply(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> Tick.Tick -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,~emit:R.Change<S> -> E,schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,world:W.World<S,C,Resources,E>,prepared:R.Prepared<State,Custom>) -> Apply.ApplyResult<S,C,Resources,E,State,Custom>:
  Apply.apply(~S,~C,~Resources,~E,~State,~Custom,~release,~clear,~insert,~emit,world,prepared)
# Convenience prepare-then-apply on the same schema and staging State. Complete
# input preparation precedes application; returned State remains an owned result.
# For persistent constructor context and explicit recovery, use owned then run.
# See docs/parity/restore-basic.md and its ordinary Restore.restore consumer.
def restore(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> Tick.Tick -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,~emit:R.Change<S> -> E,+schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,world:W.World<S,C,Resources,E>,state:State,input:Snapshot.Snapshot) -> Apply.ApplyResult<S,C,Resources,E,State,Custom>:
  apply(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,~emit,schema,world,prepare(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,schema,state,input))
# Detached owned-run result. Restored carries full saved-key/actual-handle bindings;
# RestoreRejected carries the rejected typed input and its structured error.
# Actual affine recovery is returned separately, never hidden in this Data result.
type Outcome<S:Data,Custom:Data> is Data:
  Restored{bindings:List<&2,R.Binding<S>>}
  RestoreRejected{input:Snapshot.Snapshot,error:R.Error<Custom>}
# Affine restore context retaining the schema and actual constructor State across
# calls. Its stage/release/clear/insert/commit/recovery functions are schema-bound
# advanced adapters, not gameplay access to an arbitrary World or cloned payloads.
type Owner<-S:Data,-C:Type,-Resources:Type,-State:Type,-Custom:Data,-stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,-release:State -> State,-clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,-insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> Tick.Tick -> (C & Resources) & State,-Recovery:Type,-commit:State -> State,-takeRecovery:State -> State & Recovery> is Type:
  Owner{schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,state:State}
# Retain the supplied schema and actual staging context in a restore Owner.
# This setup step neither validates a snapshot nor changes a World.
def owned(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> Tick.Tick -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,state:State) -> Owner<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>:
  Owner{schema,state}
def recovered(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> Tick.Tick -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,world:W.World<S,C,Resources,E>,outcome:Outcome<S,Custom>,observed:State & Recovery) -> W.World<S,C,Resources,E> & (Owner<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery> & (Outcome<S,Custom> & Recovery)):
  match observed:
    case (state,recovery):(world,(Owner{schema,state},(outcome,recovery)))
def run_returned(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> Tick.Tick -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,result:Apply.ApplyResult<S,C,Resources,E,State,Custom>) -> W.World<S,C,Resources,E> & (Owner<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery> & (Outcome<S,Custom> & Recovery)):
  match result:
    case Apply.Applied{world,state,bindings}:recovered(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,schema,world,Restored{bindings},takeRecovery(commit(state)))
    case Apply.Refused{world,state,input,error}:recovered(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,schema,world,RestoreRejected{input,error},takeRecovery(release(state)))
# Consume and return the restore Owner with the World, detached Outcome and actual
# Recovery owner. Success commits staging before taking recovery; refusal releases
# staging before taking recovery. Follow the concrete schema recovery type: returned
# inputs are not duplicate copies of payloads installed into the World. No implicit
# destructor or full Runtime reset is supplied by this operation.
def run(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> Tick.Tick -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,~emit:R.Change<S> -> E,owner:Owner<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,world:W.World<S,C,Resources,E>,input:Snapshot.Snapshot) -> W.World<S,C,Resources,E> & (Owner<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery> & (Outcome<S,Custom> & Recovery)):
  match owner:
    case Owner{+schema,state}:run_returned(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,schema,restore(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,~emit,schema,world,state,input))
# Explicit affine receipt disposal; no implicit destructor callback is invented.
# Consume an unwanted recovery receipt explicitly and return Unit. This drops the
# owned value; it invokes no user destructor callback and restores nothing into
# World. Callers needing recovery contents must handle them before disposal.
def dispose_recovery(~Recovery:Type,recovery:Recovery) -> Unit:
  Unit{}
