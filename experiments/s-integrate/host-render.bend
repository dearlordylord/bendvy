import Base
import ./types.bend as T
import ./storage.bend as S
import ./observations.bend as O
import ./dispatcher.bend as D
import ./host-observations.bend as H

# DRAFT renderer contract, not an approved general law/proof:
# JSON parsing retains every input Data field, constructor tag and list order.
# Four slots and metadata are emitted individually; absent values become null.
# Strings escape quote/backslash/control characters, never raw JSON newlines.
# Falsification fixtures: distinct 1/2/3/4 slots, distinct namespace/id, nested
# null/present branches, reversed FIFO, all controls 0..31, quote/backslash,
# non-ASCII. Perturb slot/order/escape implementations, compile and compare.

def render_boolean(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def render_hex(value: U32) -> String:
  match value:
    case 0: "0"
    case 1: "1"
    case 2: "2"
    case 3: "3"
    case 4: "4"
    case 5: "5"
    case 6: "6"
    case 7: "7"
    case 8: "8"
    case 9: "9"
    case 10: "a"
    case 11: "b"
    case 12: "c"
    case 13: "d"
    case 14: "e"
    case 15: "f"
    case _: "?"
def render_escaped_other(+code: U32,control: Bool) -> String:
  match control:
    case True{}: "\\u00" ++ render_hex((code / 16 : U32)) ++ render_hex((code % 16 : U32))
    case False{}: SCon{Char.from_u32(code),SNil{}}
def render_escaped_code(+code: U32) -> String:
  match code:
    case 34: "\\\""
    case 92: "\\\\"
    case _: render_escaped_other(code,(code < 32 : U32))
def render_escape(value: String) -> String:
  match value:
    case SNil{}: ""
    case SCon{head,tail}: render_escaped_code(Char.to_u32(head)) ++ render_escape(tail)
def render_string(value: String) -> String:
  "\"" ++ render_escape(value) ++ "\""
def render_list_items(~A: Data,~render: A -> String,values: List<&2,A>) -> List<&2,String>:
  match values:
    case Nil{}: []
    case Con{head,tail}: render(head) <> render_list_items(~A,~render,tail)
def render_list(~A: Data,~render: A -> String,values: List<&2,A>) -> String:
  "[" ++ String.join(render_list_items(~A,~render,values),",") ++ "]"
def render_optional(~A: Data,~render: A -> String,value: Maybe<&2,A>) -> String:
  match value:
    case None{}: "null"
    case Some{value}: render(value)

def render_four(value: T.Four) -> String:
  match value:
    case T.Four{a,b,c,d}: "{\"a\":" ++ U32.show(a) ++ ",\"b\":" ++ U32.show(b) ++ ",\"c\":" ++ U32.show(c) ++ ",\"d\":" ++ U32.show(d) ++ "}"

def render_position(value: T.PositionView) -> String:
  match value:
    case T.PositionView{coordinates,frame}: "{\"coordinates\":" ++ render_four(coordinates) ++ ",\"frame\":" ++ U32.show(frame) ++ "}"

def render_vitals(value: T.VitalsView) -> String:
  match value:
    case T.VitalsView{levels,reserve,class}: "{\"levels\":" ++ render_four(levels) ++ ",\"reserve\":" ++ U32.show(reserve) ++ ",\"class\":" ++ U32.show(class) ++ "}"

def render_velocity(value: T.VelocityView) -> String:
  match value:
    case T.VelocityView{rates,moving}: "{\"rates\":" ++ render_four(rates) ++ ",\"moving\":" ++ render_boolean(moving) ++ "}"

def render_armor(value: T.ArmorView) -> String:
  match value:
    case T.ArmorView{layers,grade}: "{\"layers\":" ++ render_four(layers) ++ ",\"grade\":" ++ U32.show(grade) ++ "}"

def render_ledger(value: T.LedgerView) -> String:
  match value:
    case T.LedgerView{totals,epoch}: "{\"totals\":" ++ render_four(totals) ++ ",\"epoch\":" ++ U32.show(epoch) ++ "}"

def render_boundary(value: T.ReadBoundary) -> String:
  match value:
    case T.ReadBoundary{since,streamSince,thisRun}: "{\"since\":" ++ U32.show(since) ++ ",\"streamSince\":" ++ U32.show(streamSince) ++ ",\"thisRun\":" ++ U32.show(thisRun) ++ "}"

def render_motion_mode(value: T.MotionMode) -> String:
  match value:
    case T.MotionOn{}: "\"MotionOn\""
    case T.MotionOff{}: "\"MotionOff\""

def render_health_mode(value: T.HealthMode) -> String:
  match value:
    case T.HealthOn{}: "\"HealthOn\""
    case T.HealthOff{}: "\"HealthOff\""

def render_selected(value: T.Selected) -> String:
  match value:
    case T.Selected{group}: "{\"group\":" ++ U32.show(group) ++ "}"

def render_tracked(value: T.Tracked) -> String:
  match value:
    case T.Tracked{group}: "{\"group\":" ++ U32.show(group) ++ "}"

def render_motion_ping(value: T.MotionPing) -> String:
  match value:
    case T.MotionPing{code}: "{\"code\":" ++ U32.show(code) ++ "}"

def render_health_ping(value: T.HealthPing) -> String:
  match value:
    case T.HealthPing{code}: "{\"code\":" ++ U32.show(code) ++ "}"

def render_main_view(value: T.MainView) -> String:
  match value:
    case T.MotionMain{position}: "{\"kind\":\"MotionMain\",\"position\":" ++ render_position(position) ++ "}"
    case T.HealthMain{vitals}: "{\"kind\":\"HealthMain\",\"vitals\":" ++ render_vitals(vitals) ++ "}"

def render_access(~A: Data,~render: A -> String,value: T.Access<A>) -> String:
  match value:
    case T.Found{value}: "{\"kind\":" ++ "\"Found\"" ++ ",\"value\":" ++ render(value) ++ "}"
    case T.Mismatch{}: "{\"kind\":" ++ "\"Mismatch\"" ++ "}"
    case T.Missing{}: "{\"kind\":" ++ "\"Missing\"" ++ "}"

def render_handle(-Schema: Data,value: S.Handle<Schema>) -> String:
  match value:
    case S.Handle{namespace,id}: "{\"namespace\":" ++ U32.show(namespace) ++ ",\"id\":" ++ U32.show(id) ++ "}"

def render_outcome(value: T.Outcome) -> String:
  match value:
    case T.Success{}: "{\"kind\":" ++ "\"Success\"" ++ "}"
    case T.Failure{code}: "{\"kind\":" ++ "\"Failure\"" ++ ",\"code\":" ++ U32.show(code) ++ "}"

def render_requirement(value: D.Requirement) -> String:
  match value:
    case D.ResourceRequired{name}: "{\"kind\":" ++ "\"ResourceRequired\"" ++ ",\"name\":" ++ render_string(name) ++ "}"
    case D.ServiceRequired{name}: "{\"kind\":" ++ "\"ServiceRequired\"" ++ ",\"name\":" ++ render_string(name) ++ "}"
    case D.StateRequired{name}: "{\"kind\":" ++ "\"StateRequired\"" ++ ",\"name\":" ++ render_string(name) ++ "}"

def render_dispatch_outcome(value: D.DispatchOutcome) -> String:
  match value:
    case D.SetupRejected{reason}: "{\"kind\":" ++ "\"SetupRejected\"" ++ ",\"reason\":" ++ render_string(reason) ++ "}"
    case D.Complete{}: "{\"kind\":" ++ "\"Complete\"" ++ "}"
    case D.SystemFailure{system,code}: "{\"kind\":" ++ "\"SystemFailure\"" ++ ",\"system\":" ++ render_string(system) ++ ",\"code\":" ++ U32.show(code) ++ "}"
    case D.MissingRuntimeRequirements{requirements}: "{\"kind\":" ++ "\"MissingRuntimeRequirements\"" ++ ",\"requirements\":" ++ render_list(~D.Requirement,~render_requirement,requirements) ++ "}"

def render_count(value: H.Count) -> String:
  match value:
    case H.Count{system,value}: "{\"system\":" ++ render_string(system) ++ ",\"value\":" ++ render_four(value) ++ "}"

def render_own_view(value: H.OwnView) -> String:
  match value:
    case H.Main{value}: "{\"kind\":" ++ "\"Main\"" ++ ",\"value\":" ++ render_access(~T.MainView,~render_main_view,value) ++ "}"
    case H.ReservedLookup{value}: "{\"kind\":" ++ "\"ReservedLookup\"" ++ ",\"value\":" ++ render_access(~T.MainView,~render_main_view,value) ++ "}"
    case H.Ledger{value}: "{\"kind\":" ++ "\"Ledger\"" ++ ",\"value\":" ++ render_optional(~T.LedgerView,~render_ledger,value) ++ "}"

def render_bundle(~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,value: O.BundleView<V,AV,F>) -> String:
  match value:
    case O.BundleView{main,aux,flag}: "{\"main\":" ++ render_optional(~V,~v,main) ++ ",\"aux\":" ++ render_optional(~AV,~av,aux) ++ ",\"flag\":" ++ render_optional(~F,~f,flag) ++ "}"

def render_row(~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,value: O.RowView<V,AV,F>) -> String:
  match value:
    case O.RowView{id,main,aux,flag,added,changed}: "{\"id\":" ++ U32.show(id) ++ ",\"main\":" ++ render_optional(~V,~v,main) ++ ",\"aux\":" ++ render_optional(~AV,~av,aux) ++ ",\"flag\":" ++ render_optional(~F,~f,flag) ++ ",\"added\":" ++ U32.show(added) ++ ",\"changed\":" ++ U32.show(changed) ++ "}"

def render_query(~Schema: Data,~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,value: O.QueryRow<Schema,V,AV,F>) -> String:
  match value:
    case O.QueryRow{handle,main,aux,flag}: "{\"handle\":" ++ render_handle(Schema,handle) ++ ",\"main\":" ++ v(main) ++ ",\"aux\":" ++ render_optional(~AV,~av,aux) ++ ",\"flag\":" ++ render_optional(~F,~f,flag) ++ "}"

def render_pending(~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,value: O.PendingView<V,AV,F>) -> String:
  match value:
    case O.SpawnView{id,bundle}: "{\"kind\":" ++ "\"SpawnView\"" ++ ",\"id\":" ++ U32.show(id) ++ ",\"bundle\":" ++ render_bundle(~V,~AV,~F,~v,~av,~f,bundle) ++ "}"
    case O.MainView{id,main}: "{\"kind\":" ++ "\"MainView\"" ++ ",\"id\":" ++ U32.show(id) ++ ",\"main\":" ++ v(main) ++ "}"
    case O.FlagView{id,flag}: "{\"kind\":" ++ "\"FlagView\"" ++ ",\"id\":" ++ U32.show(id) ++ ",\"flag\":" ++ f(flag) ++ "}"
    case O.RemoveMainView{id}: "{\"kind\":" ++ "\"RemoveMainView\"" ++ ",\"id\":" ++ U32.show(id) ++ "}"
    case O.RemoveFlagView{id}: "{\"kind\":" ++ "\"RemoveFlagView\"" ++ ",\"id\":" ++ U32.show(id) ++ "}"
    case O.DespawnView{id}: "{\"kind\":" ++ "\"DespawnView\"" ++ ",\"id\":" ++ U32.show(id) ++ "}"

def render_world(~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,~LV: Data,~Mode: Data,~lv: LV -> String,~mode_json: Mode -> String,value: O.WorldView<V,AV,F,LV,Mode>) -> String:
  match value:
    case O.WorldView{namespace,next,rows,pending,ledger,mode}: "{\"namespace\":" ++ U32.show(namespace) ++ ",\"next\":" ++ U32.show(next) ++ ",\"rows\":" ++ render_list(~O.RowView<V,AV,F>,~render_row(~V,~AV,~F,~v,~av,~f),rows) ++ ",\"pending\":" ++ render_list(~O.PendingView<V,AV,F>,~render_pending(~V,~AV,~F,~v,~av,~f),pending) ++ ",\"ledger\":" ++ render_optional(~LV,~lv,ledger) ++ ",\"mode\":" ++ mode_json(mode) ++ "}"

def render_lookup(~Schema: Data,~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,value: H.Lookup<Schema,V,AV,F>) -> String:
  match value:
    case H.Lookup{label,handle,result}: "{\"label\":" ++ render_string(label) ++ ",\"handle\":" ++ render_handle(Schema,handle) ++ ",\"result\":" ++ render_access(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),result) ++ "}"

def render_event(~Schema: Data,~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,~LV: Data,~Mode: Data,~lv: LV -> String,~mode_json: Mode -> String,~P: Data,~ping: P -> String,value: H.TraceEvent<Schema,V,AV,F,LV,Mode,P>) -> String:
  match value:
    case H.Reserved{step,worldName,label,handle,components}: "{\"kind\":" ++ "\"Reserved\"" ++ ",\"step\":" ++ render_string(step) ++ ",\"worldName\":" ++ render_string(worldName) ++ ",\"label\":" ++ render_string(label) ++ ",\"handle\":" ++ render_handle(Schema,handle) ++ ",\"components\":" ++ render_bundle(~V,~AV,~F,~v,~av,~f,components) ++ "}"
    case H.Read{step,system,count,boundary,query,added,changed,removed,despawned,messages,messageLag,removedLag,despawnedLag}: "{\"kind\":" ++ "\"Read\"" ++ ",\"step\":" ++ render_string(step) ++ ",\"system\":" ++ render_string(system) ++ ",\"count\":" ++ U32.show(count) ++ ",\"boundary\":" ++ render_boundary(boundary) ++ ",\"query\":" ++ render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),query) ++ ",\"added\":" ++ render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),added) ++ ",\"changed\":" ++ render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),changed) ++ ",\"removed\":" ++ render_list(~S.Handle<Schema>,~render_handle(Schema),removed) ++ ",\"despawned\":" ++ render_list(~S.Handle<Schema>,~render_handle(Schema),despawned) ++ ",\"messages\":" ++ render_list(~P,~ping,messages) ++ ",\"messageLag\":" ++ render_boolean(messageLag) ++ ",\"removedLag\":" ++ render_boolean(removedLag) ++ ",\"despawnedLag\":" ++ render_boolean(despawnedLag) ++ "}"
    case H.Snapshot{step,worldName,prior,world,query,plus,minus,optional,lookups}: "{\"kind\":" ++ "\"Snapshot\"" ++ ",\"step\":" ++ render_string(step) ++ ",\"worldName\":" ++ render_string(worldName) ++ ",\"prior\":" ++ render_dispatch_outcome(prior) ++ ",\"world\":" ++ render_world(~V,~AV,~F,~v,~av,~f,~LV,~Mode,~lv,~mode_json,world) ++ ",\"query\":" ++ render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),query) ++ ",\"plus\":" ++ render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),plus) ++ ",\"minus\":" ++ render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),minus) ++ ",\"optional\":" ++ render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),optional) ++ ",\"lookups\":" ++ render_list(~H.Lookup<Schema,V,AV,F>,~render_lookup(~Schema,~V,~AV,~F,~v,~av,~f),lookups) ++ "}"
    case H.Dispatch{step,outcome,clockTick,frame,counts}: "{\"kind\":" ++ "\"Dispatch\"" ++ ",\"step\":" ++ render_string(step) ++ ",\"outcome\":" ++ render_dispatch_outcome(outcome) ++ ",\"clockTick\":" ++ U32.show(clockTick) ++ ",\"frame\":" ++ U32.show(frame) ++ ",\"counts\":" ++ render_list(~H.Count,~render_count,counts) ++ "}"
    case H.ReadDone{step,system,frame,tick,outcome,messageLag,removedLag,despawnedLag}: "{\"kind\":" ++ "\"ReadDone\"" ++ ",\"step\":" ++ render_string(step) ++ ",\"system\":" ++ render_string(system) ++ ",\"frame\":" ++ U32.show(frame) ++ ",\"tick\":" ++ U32.show(tick) ++ ",\"outcome\":" ++ render_outcome(outcome) ++ ",\"messageLag\":" ++ render_boolean(messageLag) ++ ",\"removedLag\":" ++ render_boolean(removedLag) ++ ",\"despawnedLag\":" ++ render_boolean(despawnedLag) ++ "}"
    case H.OwnWrites{step,system,views}: "{\"kind\":" ++ "\"OwnWrites\"" ++ ",\"step\":" ++ render_string(step) ++ ",\"system\":" ++ render_string(system) ++ ",\"views\":" ++ render_list(~H.OwnView,~render_own_view,views) ++ "}"

def render_motion(value: H.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>) -> String:
  render_event(~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~render_position,~render_velocity,~render_selected,~T.LedgerView,~T.MotionMode,~render_ledger,~render_motion_mode,~T.MotionPing,~render_motion_ping,value)

def render_health(value: H.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>) -> String:
  render_event(~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~render_vitals,~render_armor,~render_tracked,~T.LedgerView,~T.HealthMode,~render_ledger,~render_health_mode,~T.HealthPing,~render_health_ping,value)
