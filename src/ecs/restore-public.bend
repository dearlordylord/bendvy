import Base
import ./restore-data.bend as R
import ./restore-schema.bend as Schema
import ./restore-prepare.bend as Prepare
import ./restore-apply.bend as Apply
import ./world.bend as W
import ./snapshot-data.bend as Snapshot
import ./decode-data.bend as D

def prepare(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,state:State,input:Snapshot.Snapshot) -> R.Prepared<State,Custom>:
  Prepare.prepare(~State,~Custom,~stage,~release,state,input)
def apply(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,~emit:R.Change<S> -> E,schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,world:W.World<S,C,Resources,E>,prepared:R.Prepared<State,Custom>) -> Apply.ApplyResult<S,C,Resources,E,State,Custom>:
  Apply.apply(~S,~C,~Resources,~E,~State,~Custom,~release,~clear,~insert,~emit,world,prepared)
def restore(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,~emit:R.Change<S> -> E,+schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,world:W.World<S,C,Resources,E>,state:State,input:Snapshot.Snapshot) -> Apply.ApplyResult<S,C,Resources,E,State,Custom>:
  apply(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,~emit,schema,world,prepare(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,schema,state,input))
type Outcome<S:Data,Custom:Data> is Data:
  Restored{bindings:List<&2,R.Binding<S>>}
  RestoreRejected{input:Snapshot.Snapshot,error:R.Error<Custom>}
type Owner<-S:Data,-C:Type,-Resources:Type,-State:Type,-Custom:Data,-stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,-release:State -> State,-clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,-insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,-Recovery:Type,-commit:State -> State,-takeRecovery:State -> State & Recovery> is Type:
  Owner{schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,state:State}
def owned(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,state:State) -> Owner<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>:
  Owner{schema,state}
def recovered(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,world:W.World<S,C,Resources,E>,outcome:Outcome<S,Custom>,observed:State & Recovery) -> W.World<S,C,Resources,E> & (Owner<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery> & (Outcome<S,Custom> & Recovery)):
  match observed:
    case (state,recovery):(world,(Owner{schema,state},(outcome,recovery)))
def run_returned(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,schema:Schema.Schema<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,result:Apply.ApplyResult<S,C,Resources,E,State,Custom>) -> W.World<S,C,Resources,E> & (Owner<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery> & (Outcome<S,Custom> & Recovery)):
  match result:
    case Apply.Applied{world,state,bindings}:recovered(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,schema,world,Restored{bindings},takeRecovery(commit(state)))
    case Apply.Refused{world,state,input,error}:recovered(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,schema,world,RestoreRejected{input,error},takeRecovery(release(state)))
def run(~S:Data,~C:Type,~Resources:Type,~E:Data,~State:Type,~Custom:Data,~stage:State -> R.Position -> D.Field -> State & R.Dispatch<Custom>,~release:State -> State,~clear:C -> W.Handle<S> -> C & List<&2,R.Change<S>>,~insert:C -> Resources -> State -> List<&2,R.Binding<S>> -> U32 -> (C & Resources) & State,~Recovery:Type,~commit:State -> State,~takeRecovery:State -> State & Recovery,~emit:R.Change<S> -> E,owner:Owner<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery>,world:W.World<S,C,Resources,E>,input:Snapshot.Snapshot) -> W.World<S,C,Resources,E> & (Owner<S,C,Resources,State,Custom,stage,release,clear,insert,Recovery,commit,takeRecovery> & (Outcome<S,Custom> & Recovery)):
  match owner:
    case Owner{+schema,state}:run_returned(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,schema,restore(~S,~C,~Resources,~E,~State,~Custom,~stage,~release,~clear,~insert,~Recovery,~commit,~takeRecovery,~emit,schema,world,state,input))
# Explicit affine receipt disposal; no implicit destructor callback is invented.
def dispose_recovery(~Recovery:Type,recovery:Recovery) -> Unit:
  Unit{}
