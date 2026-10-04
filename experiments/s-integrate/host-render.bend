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

# Tail-recursive chunk flattening: each character enters the reversed builder
# once, followed by one tail-recursive reversal. No Base.append/Join recursion.
def render_push(value: String,acc: String) -> String:
  match value:
    case SNil{}: acc
    case SCon{head,tail}: render_push(tail,SCon{head,acc})
def render_chunks(values: List<&2,String>,acc: String) -> String:
  match values:
    case Nil{}: String.reverse(acc)
    case Con{head,tail}: render_chunks(tail,render_push(head,acc))
def render_concat(values: List<&2,String>) -> String:
  render_chunks(values,"")

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
    case True{}: render_concat(["\\u00", render_hex((code / 16 : U32)), render_hex((code % 16 : U32))])
    case False{}: SCon{Char.from_u32(code),SNil{}}
def render_escaped_code(+code: U32) -> String:
  match code:
    case 34: "\\\""
    case 92: "\\\\"
    case _: render_escaped_other(code,(code < 32 : U32))
def render_escape_tail(value: String,acc: String) -> String:
  match value:
    case SNil{}: String.reverse(acc)
    case SCon{head,tail}: render_escape_tail(tail,render_push(render_escaped_code(Char.to_u32(head)),acc))
def render_escape(value: String) -> String:
  render_escape_tail(value,"")
def render_string(value: String) -> String:
  render_concat(["\"", render_escape(value), "\""])
def render_list_piece(value: String,acc: List<&2,String>,first: Bool) -> List<&2,String>:
  match first:
    case True{}: value <> acc
    case False{}: value <> "," <> acc
def render_list_tail(~A: Data,~render: A -> String,values: List<&2,A>,acc: List<&2,String>,first: Bool) -> List<&2,String>:
  match values:
    case Nil{}: List.reverse(&2,String,acc)
    case Con{head,tail}: render_list_tail(~A,~render,tail,render_list_piece(render(head),acc,first),False{})
def render_list(~A: Data,~render: A -> String,values: List<&2,A>) -> String:
  render_concat(["[",render_concat(render_list_tail(~A,~render,values,[],True{})),"]"])
def render_optional(~A: Data,~render: A -> String,value: Maybe<&2,A>) -> String:
  match value:
    case None{}: "null"
    case Some{value}: render(value)

def render_four(value: T.Four) -> String:
  match value:
    case T.Four{a,b,c,d}: render_concat(["{\"a\":", U32.show(a), ",\"b\":", U32.show(b), ",\"c\":", U32.show(c), ",\"d\":", U32.show(d), "}"])

def render_position(value: T.PositionView) -> String:
  match value:
    case T.PositionView{coordinates,frame}: render_concat(["{\"coordinates\":", render_four(coordinates), ",\"frame\":", U32.show(frame), "}"])

def render_vitals(value: T.VitalsView) -> String:
  match value:
    case T.VitalsView{levels,reserve,class}: render_concat(["{\"levels\":", render_four(levels), ",\"reserve\":", U32.show(reserve), ",\"class\":", U32.show(class), "}"])

def render_velocity(value: T.VelocityView) -> String:
  match value:
    case T.VelocityView{rates,moving}: render_concat(["{\"rates\":", render_four(rates), ",\"moving\":", render_boolean(moving), "}"])

def render_armor(value: T.ArmorView) -> String:
  match value:
    case T.ArmorView{layers,grade}: render_concat(["{\"layers\":", render_four(layers), ",\"grade\":", U32.show(grade), "}"])

def render_ledger(value: T.LedgerView) -> String:
  match value:
    case T.LedgerView{totals,epoch}: render_concat(["{\"totals\":", render_four(totals), ",\"epoch\":", U32.show(epoch), "}"])

def render_boundary(value: T.ReadBoundary) -> String:
  match value:
    case T.ReadBoundary{since,streamSince,thisRun}: render_concat(["{\"since\":", U32.show(since), ",\"streamSince\":", U32.show(streamSince), ",\"thisRun\":", U32.show(thisRun), "}"])

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
    case T.Selected{group}: render_concat(["{\"group\":", U32.show(group), "}"])

def render_tracked(value: T.Tracked) -> String:
  match value:
    case T.Tracked{group}: render_concat(["{\"group\":", U32.show(group), "}"])

def render_motion_ping(value: T.MotionPing) -> String:
  match value:
    case T.MotionPing{code}: render_concat(["{\"code\":", U32.show(code), "}"])

def render_health_ping(value: T.HealthPing) -> String:
  match value:
    case T.HealthPing{code}: render_concat(["{\"code\":", U32.show(code), "}"])

def render_main_view(value: T.MainView) -> String:
  match value:
    case T.MotionMain{position}: render_concat(["{\"kind\":\"MotionMain\",\"position\":", render_position(position), "}"])
    case T.HealthMain{vitals}: render_concat(["{\"kind\":\"HealthMain\",\"vitals\":", render_vitals(vitals), "}"])

def render_access(~A: Data,~render: A -> String,value: T.Access<A>) -> String:
  match value:
    case T.Found{value}: render_concat(["{\"kind\":", "\"Found\"", ",\"value\":", render(value), "}"])
    case T.Mismatch{}: render_concat(["{\"kind\":", "\"Mismatch\"", "}"])
    case T.Missing{}: render_concat(["{\"kind\":", "\"Missing\"", "}"])

def render_handle(-Schema: Data,value: S.Handle<Schema>) -> String:
  match value:
    case S.Handle{namespace,id}: render_concat(["{\"namespace\":", U32.show(namespace), ",\"id\":", U32.show(id), "}"])

def render_outcome(value: T.Outcome) -> String:
  match value:
    case T.Success{}: render_concat(["{\"kind\":", "\"Success\"", "}"])
    case T.Failure{code}: render_concat(["{\"kind\":", "\"Failure\"", ",\"code\":", U32.show(code), "}"])

def render_requirement(value: D.Requirement) -> String:
  match value:
    case D.ResourceRequired{name}: render_concat(["{\"kind\":", "\"ResourceRequired\"", ",\"name\":", render_string(name), "}"])
    case D.ServiceRequired{name}: render_concat(["{\"kind\":", "\"ServiceRequired\"", ",\"name\":", render_string(name), "}"])
    case D.StateRequired{name}: render_concat(["{\"kind\":", "\"StateRequired\"", ",\"name\":", render_string(name), "}"])

def render_dispatch_outcome(value: D.DispatchOutcome) -> String:
  match value:
    case D.SetupRejected{reason}: render_concat(["{\"kind\":", "\"SetupRejected\"", ",\"reason\":", render_string(reason), "}"])
    case D.Complete{}: render_concat(["{\"kind\":", "\"Complete\"", "}"])
    case D.SystemFailure{system,code}: render_concat(["{\"kind\":", "\"SystemFailure\"", ",\"system\":", render_string(system), ",\"code\":", U32.show(code), "}"])
    case D.MissingRuntimeRequirements{requirements}: render_concat(["{\"kind\":", "\"MissingRuntimeRequirements\"", ",\"requirements\":", render_list(~D.Requirement,~render_requirement,requirements), "}"])

def render_count(value: H.Count) -> String:
  match value:
    case H.Count{system,value}: render_concat(["{\"system\":", render_string(system), ",\"value\":", render_four(value), "}"])

def render_own_view(value: H.OwnView) -> String:
  match value:
    case H.Main{value}: render_concat(["{\"kind\":", "\"Main\"", ",\"value\":", render_access(~T.MainView,~render_main_view,value), "}"])
    case H.ReservedLookup{value}: render_concat(["{\"kind\":", "\"ReservedLookup\"", ",\"value\":", render_access(~T.MainView,~render_main_view,value), "}"])
    case H.Ledger{value}: render_concat(["{\"kind\":", "\"Ledger\"", ",\"value\":", render_optional(~T.LedgerView,~render_ledger,value), "}"])

def render_bundle(~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,value: O.BundleView<V,AV,F>) -> String:
  match value:
    case O.BundleView{main,aux,flag}: render_concat(["{\"main\":", render_optional(~V,~v,main), ",\"aux\":", render_optional(~AV,~av,aux), ",\"flag\":", render_optional(~F,~f,flag), "}"])

def render_row(~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,value: O.RowView<V,AV,F>) -> String:
  match value:
    case O.RowView{id,main,aux,flag,added,changed}: render_concat(["{\"id\":", U32.show(id), ",\"main\":", render_optional(~V,~v,main), ",\"aux\":", render_optional(~AV,~av,aux), ",\"flag\":", render_optional(~F,~f,flag), ",\"added\":", U32.show(added), ",\"changed\":", U32.show(changed), "}"])

def render_query(~Schema: Data,~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,value: O.QueryRow<Schema,V,AV,F>) -> String:
  match value:
    case O.QueryRow{handle,main,aux,flag}: render_concat(["{\"handle\":", render_handle(Schema,handle), ",\"main\":", v(main), ",\"aux\":", render_optional(~AV,~av,aux), ",\"flag\":", render_optional(~F,~f,flag), "}"])

def render_pending(~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,value: O.PendingView<V,AV,F>) -> String:
  match value:
    case O.SpawnView{id,bundle}: render_concat(["{\"kind\":", "\"SpawnView\"", ",\"id\":", U32.show(id), ",\"bundle\":", render_bundle(~V,~AV,~F,~v,~av,~f,bundle), "}"])
    case O.MainView{id,main}: render_concat(["{\"kind\":", "\"MainView\"", ",\"id\":", U32.show(id), ",\"main\":", v(main), "}"])
    case O.FlagView{id,flag}: render_concat(["{\"kind\":", "\"FlagView\"", ",\"id\":", U32.show(id), ",\"flag\":", f(flag), "}"])
    case O.RemoveMainView{id}: render_concat(["{\"kind\":", "\"RemoveMainView\"", ",\"id\":", U32.show(id), "}"])
    case O.RemoveFlagView{id}: render_concat(["{\"kind\":", "\"RemoveFlagView\"", ",\"id\":", U32.show(id), "}"])
    case O.DespawnView{id}: render_concat(["{\"kind\":", "\"DespawnView\"", ",\"id\":", U32.show(id), "}"])

def render_world(~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,~LV: Data,~Mode: Data,~lv: LV -> String,~mode_json: Mode -> String,value: O.WorldView<V,AV,F,LV,Mode>) -> String:
  match value:
    case O.WorldView{namespace,next,rows,pending,ledger,mode}: render_concat(["{\"namespace\":", U32.show(namespace), ",\"next\":", U32.show(next), ",\"rows\":", render_list(~O.RowView<V,AV,F>,~render_row(~V,~AV,~F,~v,~av,~f),rows), ",\"pending\":", render_list(~O.PendingView<V,AV,F>,~render_pending(~V,~AV,~F,~v,~av,~f),pending), ",\"ledger\":", render_optional(~LV,~lv,ledger), ",\"mode\":", mode_json(mode), "}"])

def render_lookup(~Schema: Data,~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,value: H.Lookup<Schema,V,AV,F>) -> String:
  match value:
    case H.Lookup{label,handle,result}: render_concat(["{\"label\":", render_string(label), ",\"handle\":", render_handle(Schema,handle), ",\"result\":", render_access(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),result), "}"])

def render_event(~Schema: Data,~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,~LV: Data,~Mode: Data,~lv: LV -> String,~mode_json: Mode -> String,~P: Data,~ping: P -> String,value: H.TraceEvent<Schema,V,AV,F,LV,Mode,P>) -> String:
  match value:
    case H.ForeignLookup{step,receiver,source,label,handle,result}: render_concat(["{\"kind\":\"ForeignLookup\",\"step\":",render_string(step),",\"receiver\":",render_string(receiver),",\"source\":",render_string(source),",\"label\":",render_string(label),",\"handle\":",render_handle(Schema,handle),",\"result\":",render_access(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),result),"}"])
    case H.Reserved{step,worldName,label,handle,components}: render_concat(["{\"kind\":", "\"Reserved\"", ",\"step\":", render_string(step), ",\"worldName\":", render_string(worldName), ",\"label\":", render_string(label), ",\"handle\":", render_handle(Schema,handle), ",\"components\":", render_bundle(~V,~AV,~F,~v,~av,~f,components), "}"])
    case H.Read{step,system,count,boundary,query,added,changed,removed,despawned,messages,messageLag,removedLag,despawnedLag}: render_concat(["{\"kind\":", "\"Read\"", ",\"step\":", render_string(step), ",\"system\":", render_string(system), ",\"count\":", U32.show(count), ",\"boundary\":", render_boundary(boundary), ",\"query\":", render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),query), ",\"added\":", render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),added), ",\"changed\":", render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),changed), ",\"removed\":", render_list(~S.Handle<Schema>,~render_handle(Schema),removed), ",\"despawned\":", render_list(~S.Handle<Schema>,~render_handle(Schema),despawned), ",\"messages\":", render_list(~P,~ping,messages), ",\"messageLag\":", render_boolean(messageLag), ",\"removedLag\":", render_boolean(removedLag), ",\"despawnedLag\":", render_boolean(despawnedLag), "}"])
    case H.Snapshot{step,worldName,prior,world,query,plus,minus,optional,lookups}: render_concat(["{\"kind\":", "\"Snapshot\"", ",\"step\":", render_string(step), ",\"worldName\":", render_string(worldName), ",\"prior\":", render_dispatch_outcome(prior), ",\"world\":", render_world(~V,~AV,~F,~v,~av,~f,~LV,~Mode,~lv,~mode_json,world), ",\"query\":", render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),query), ",\"plus\":", render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),plus), ",\"minus\":", render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),minus), ",\"optional\":", render_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),optional), ",\"lookups\":", render_list(~H.Lookup<Schema,V,AV,F>,~render_lookup(~Schema,~V,~AV,~F,~v,~av,~f),lookups), "}"])
    case H.Dispatch{step,worldName,tracked,outcome,clockTick,frame,counts}: render_concat(["{\"kind\":", "\"Dispatch\"", ",\"step\":", render_string(step), ",\"worldName\":", render_string(worldName), ",\"tracked\":", render_boolean(tracked), ",\"outcome\":", render_dispatch_outcome(outcome), ",\"clockTick\":", U32.show(clockTick), ",\"frame\":", U32.show(frame), ",\"counts\":", render_list(~H.Count,~render_count,counts), "}"])
    case H.ReadDone{step,system,frame,tick,outcome,messageLag,removedLag,despawnedLag}: render_concat(["{\"kind\":", "\"ReadDone\"", ",\"step\":", render_string(step), ",\"system\":", render_string(system), ",\"frame\":", U32.show(frame), ",\"tick\":", U32.show(tick), ",\"outcome\":", render_outcome(outcome), ",\"messageLag\":", render_boolean(messageLag), ",\"removedLag\":", render_boolean(removedLag), ",\"despawnedLag\":", render_boolean(despawnedLag), "}"])
    case H.OwnWrites{step,system,views}: render_concat(["{\"kind\":", "\"OwnWrites\"", ",\"step\":", render_string(step), ",\"system\":", render_string(system), ",\"views\":", render_list(~H.OwnView,~render_own_view,views), "}"])

def render_motion(value: H.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>) -> String:
  render_event(~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~render_position,~render_velocity,~render_selected,~T.LedgerView,~T.MotionMode,~render_ledger,~render_motion_mode,~T.MotionPing,~render_motion_ping,value)

def render_health(value: H.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>) -> String:
  render_event(~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~render_vitals,~render_armor,~render_tracked,~T.LedgerView,~T.HealthMode,~render_ledger,~render_health_mode,~T.HealthPing,~render_health_ping,value)

# Streaming variant retains one JSON line while bounding per-write strings.
# Existing String-returning entrypoints remain suitable for smaller values.
def write_separator(first: Bool) -> IO(Unit):
  match first:
    case True{}: IO.pure(Unit,Unit{})
    case False{}: IO.write(",")
def write_list_tail(~A: Data,~render: A -> String,values: List<&2,A>,first: Bool) -> IO(Unit):
  match values:
    case Nil{}: IO.write("]")
    case Con{head,tail}:
      do IO<Unit>:
        write_separator(first)
        IO.write(render(head))
        write_list_tail(~A,~render,tail,False{})
def write_list(~A: Data,~render: A -> String,values: List<&2,A>) -> IO(Unit):
  do IO<Unit>:
    IO.write("[")
    write_list_tail(~A,~render,values,True{})

def write_event(~Schema: Data,~V: Data,~AV: Data,~F: Data,~v: V -> String,~av: AV -> String,~f: F -> String,~LV: Data,~Mode: Data,~lv: LV -> String,~mode_json: Mode -> String,~P: Data,~ping: P -> String,value: H.TraceEvent<Schema,V,AV,F,LV,Mode,P>) -> IO(Unit):
  match value:
    case H.Read{step,system,count,boundary,query,added,changed,removed,despawned,messages,messageLag,removedLag,despawnedLag}:
      do IO<Unit>:
        IO.write("{\"kind\":\"Read\",\"step\":")
        IO.write(render_string(step))
        IO.write(",\"system\":")
        IO.write(render_string(system))
        IO.write(",\"count\":")
        IO.write(U32.show(count))
        IO.write(",\"boundary\":")
        IO.write(render_boundary(boundary))
        IO.write(",\"query\":")
        write_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),query)
        IO.write(",\"added\":")
        write_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),added)
        IO.write(",\"changed\":")
        write_list(~O.QueryRow<Schema,V,AV,F>,~render_query(~Schema,~V,~AV,~F,~v,~av,~f),changed)
        IO.write(",\"removed\":")
        write_list(~S.Handle<Schema>,~render_handle(Schema),removed)
        IO.write(",\"despawned\":")
        write_list(~S.Handle<Schema>,~render_handle(Schema),despawned)
        IO.write(",\"messages\":")
        write_list(~P,~ping,messages)
        IO.write(",\"messageLag\":")
        IO.write(render_boolean(messageLag))
        IO.write(",\"removedLag\":")
        IO.write(render_boolean(removedLag))
        IO.write(",\"despawnedLag\":")
        IO.write(render_boolean(despawnedLag))
        IO.print("}")
    case other: IO.print(render_event(~Schema,~V,~AV,~F,~v,~av,~f,~LV,~Mode,~lv,~mode_json,~P,~ping,other))

def write_motion(value: H.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>) -> IO(Unit):
  write_event(~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~render_position,~render_velocity,~render_selected,~T.LedgerView,~T.MotionMode,~render_ledger,~render_motion_mode,~T.MotionPing,~render_motion_ping,value)

def write_health(value: H.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>) -> IO(Unit):
  write_event(~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~render_vitals,~render_armor,~render_tracked,~T.LedgerView,~T.HealthMode,~render_ledger,~render_health_mode,~T.HealthPing,~render_health_ping,value)

# DRAFT E11-only compact contract agreed with retention integrator BEFORE body:
# derive template/namespace/id/x/metadata/aux/flag from actual first row; verify
# EVERY row has consecutive id/x (no wrap), all Four slots, metadata/aux/flag,
# same namespace. Slot0 follows x or one actual constant. Emit no success on
# mismatch. Empty -> []. All original Read scalar/boundary/lag fields retained.
type CompactCell is Data:
  CompactCell{namespace:U32,id:U32,a:U32,b:U32,c:U32,d:U32,meta1:U32,meta2:U32,aux:String,flag:String}
type CompactCheck is Data:
  CompactGood{count:U32,idLast:U32,xLast:U32}
  CompactBad{index:U32}
def compact_cell_four(namespace:U32,id:U32,meta1:U32,meta2:U32,aux:String,flag:String,value:T.Four) -> CompactCell:
  match value:
    case T.Four{a,b,c,d}: CompactCell{namespace,id,a,b,c,d,meta1,meta2,aux,flag}
def compact_motion_main(namespace:U32,id:U32,aux:String,flag:String,value:T.PositionView) -> CompactCell:
  match value:
    case T.PositionView{coordinates,frame}: compact_cell_four(namespace,id,frame,0,aux,flag,coordinates)
def compact_health_main(namespace:U32,id:U32,aux:String,flag:String,value:T.VitalsView) -> CompactCell:
  match value:
    case T.VitalsView{levels,reserve,class}: compact_cell_four(namespace,id,reserve,class,aux,flag,levels)
def compact_handle(~V:Data,~get:U32 -> U32 -> String -> String -> V -> CompactCell,main:V,aux:String,flag:String,handle:S.Handle<T.MotionSchema>) -> CompactCell:
  match handle:
    case S.Handle{namespace,id}: get(namespace,id,aux,flag,main)
def compact_motion(value:O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>) -> CompactCell:
  match value:
    case O.QueryRow{handle,main,aux,flag}: compact_handle(~T.PositionView,~compact_motion_main,main,render_optional(~T.VelocityView,~render_velocity,aux),render_optional(~T.Selected,~render_selected,flag),handle)
def compact_health_handle(main:T.VitalsView,aux:String,flag:String,handle:S.Handle<T.HealthSchema>) -> CompactCell:
  match handle:
    case S.Handle{namespace,id}: compact_health_main(namespace,id,aux,flag,main)
def compact_health(value:O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>) -> CompactCell:
  match value:
    case O.QueryRow{handle,main,aux,flag}: compact_health_handle(main,render_optional(~T.ArmorView,~render_armor,aux),render_optional(~T.Tracked,~render_tracked,flag),handle)
def compact_slot(+follows:Bool,+constant:U32,+x:U32) -> U32:
  match follows:
    case True{}: x
    case False{}: constant
def compact_same(+id:U32,+x:U32,follows:Bool,constant:U32,first:CompactCell,current:CompactCell) -> Bool:
  match first current:
    case CompactCell{ns,_,_,_,_,_,m1,m2,aux,flag} CompactCell{ns2,id2,a,b,c,d,n1,n2,aux2,flag2}:
      U32.is_eq(ns,ns2) && U32.is_eq(id,id2) && U32.is_eq(a,compact_slot(follows,constant,x)) && U32.is_eq(b,(x + 1 : U32)) && U32.is_eq(c,(x + 2 : U32)) && U32.is_eq(d,(x + 3 : U32)) && U32.is_eq(m1,n1) && U32.is_eq(m2,n2) && String.eq(aux,aux2) && String.eq(flag,flag2)
def compact_bad_index(index:U32,previous:U32,good:Bool) -> U32:
  match good:
    case True{}: previous
    case False{}: index
def compact_finish(count:U32,idLast:U32,xLast:U32,bad:U32) -> CompactCheck:
  match bad:
    case 4294967295: CompactGood{count,idLast,xLast}
    case _: CompactBad{bad}
def compact_rows(~A:Data,~project:A -> CompactCell,+first:CompactCell,values:List<&2,A>,+id:U32,+x:U32,+follows:Bool,+constant:U32,+index:U32,bad:U32) -> CompactCheck:
  match values:
    case Nil{}: compact_finish(index,(id - 1 : U32),(x - 1 : U32),bad)
    case Con{head,tail}: compact_rows(~A,~project,first,tail,(id + 1 : U32),(x + 1 : U32),follows,constant,(index + 1 : U32),
      compact_bad_index(index,bad,(id < 4294967295 : U32) && (x <= 4294967292 : U32) && (index < 4294967295 : U32) && compact_same(id,x,follows,constant,first,project(head))))
def compact_slot_json(follows:Bool,constant:U32) -> String:
  match follows:
    case True{}: "{\"mode\":\"x\"}"
    case False{}: render_concat(["{\"mode\":\"constant\",\"value\":",U32.show(constant),"}"])
def compact_result(template:String,namespace:U32,idFirst:U32,xFirst:U32,follows:Bool,constant:U32,result:CompactCheck) -> String:
  match result:
    case CompactBad{index}: render_concat(["{\"encoding\":\"unrepresentable\",\"reason\":\"row-fields-or-range\",\"index\":",U32.show(index),"}"])
    case CompactGood{count,idLast,xLast}: render_concat(["{\"encoding\":\"query-row-range\",\"template\":",template,",\"namespace\":",U32.show(namespace),",\"idFirst\":",U32.show(idFirst),",\"idLast\":",U32.show(idLast),",\"xFirst\":",U32.show(xFirst),",\"xLast\":",U32.show(xLast),",\"count\":",U32.show(count),",\"slot0\":",compact_slot_json(follows,constant),"}"])
def compact_start(~A:Data,~project:A -> CompactCell,template:String,+head:A,tail:List<&2,A>,+first:CompactCell) -> String:
  match first:
    case CompactCell{+ns,+id,+a,+b,+c,+d,+m1,+m2,+aux,+flag}:
      +x=(b - 1 : U32)
      compact_result(template,ns,id,x,U32.is_eq(a,x),a,compact_rows(~A,~project,CompactCell{ns,id,a,b,c,d,m1,m2,aux,flag},head <> tail,id,x,U32.is_eq(a,x),a,0,4294967295))
def compact_query(~A:Data,~project:A -> CompactCell,~render:A -> String,values:List<&2,A>) -> String:
  match values:
    case Nil{}: "[]"
    case Con{+head,tail}: compact_start(~A,~project,render(head),head,tail,project(head))

# Draft validated lifecycle range: inspect every actual namespace/id; reject
# noncontiguous/mixed/wrapped input. No setup expectations enter the encoder.
def compact_handle_valid(-Schema:Data,namespace:U32,+id:U32,value:S.Handle<Schema>) -> Bool:
  match value:
    case S.Handle{actualNs,actualId}: U32.is_eq(namespace,actualNs) && U32.is_eq(id,actualId) && (id < 4294967295 : U32)
def compact_handles_scan(-Schema:Data,values:List<&2,S.Handle<Schema>>,+namespace:U32,+id:U32,+index:U32,bad:U32) -> CompactCheck:
  match values:
    case Nil{}: compact_finish(index,(id - 1 : U32),0,bad)
    case Con{head,tail}: compact_handles_scan(Schema,tail,namespace,(id + 1 : U32),(index + 1 : U32),compact_bad_index(index,bad,(index < 4294967295 : U32) && compact_handle_valid(Schema,namespace,id,head)))
def compact_handles_result(namespace:U32,first:U32,result:CompactCheck) -> String:
  match result:
    case CompactBad{index}: render_concat(["{\"encoding\":\"unrepresentable\",\"reason\":\"handle-namespace-or-range\",\"index\":",U32.show(index),"}"])
    case CompactGood{count,last,_}: render_concat(["{\"encoding\":\"handle-range\",\"namespace\":",U32.show(namespace),",\"first\":",U32.show(first),",\"last\":",U32.show(last),",\"count\":",U32.show(count),"}"])
def compact_handles_first(-Schema:Data,tail:List<&2,S.Handle<Schema>>,head:S.Handle<Schema>) -> String:
  match head:
    case S.Handle{+namespace,+id}: compact_handles_result(namespace,id,compact_handles_scan(Schema,S.Handle{namespace,id} <> tail,namespace,id,0,4294967295))
def compact_handles(-Schema:Data,values:List<&2,S.Handle<Schema>>) -> String:
  match values:
    case Nil{}: "[]"
    case Con{head,tail}: compact_handles_first(Schema,tail,head)

def compact_motion_event(value:H.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>) -> String:
  match value:
    case H.Read{step,system,count,boundary,query,added,changed,removed,despawned,messages,messageLag,removedLag,despawnedLag}:
      render_concat(["{\"kind\":\"Read\",\"step\":",render_string(step),",\"system\":",render_string(system),",\"count\":",U32.show(count),",\"boundary\":",render_boundary(boundary),",\"query\":",compact_query(~O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,~compact_motion,~render_query(~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~render_position,~render_velocity,~render_selected),query),",\"added\":",compact_query(~O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,~compact_motion,~render_query(~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~render_position,~render_velocity,~render_selected),added),",\"changed\":",compact_query(~O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,~compact_motion,~render_query(~T.MotionSchema,~T.PositionView,~T.VelocityView,~T.Selected,~render_position,~render_velocity,~render_selected),changed),",\"removed\":",compact_handles(T.MotionSchema,removed),",\"despawned\":",compact_handles(T.MotionSchema,despawned),",\"messages\":",render_list(~T.MotionPing,~render_motion_ping,messages),",\"messageLag\":",render_boolean(messageLag),",\"removedLag\":",render_boolean(removedLag),",\"despawnedLag\":",render_boolean(despawnedLag),"}"])
    case other: render_motion(other)

def compact_health_event(value:H.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>) -> String:
  match value:
    case H.Read{step,system,count,boundary,query,added,changed,removed,despawned,messages,messageLag,removedLag,despawnedLag}:
      render_concat(["{\"kind\":\"Read\",\"step\":",render_string(step),",\"system\":",render_string(system),",\"count\":",U32.show(count),",\"boundary\":",render_boundary(boundary),",\"query\":",compact_query(~O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,~compact_health,~render_query(~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~render_vitals,~render_armor,~render_tracked),query),",\"added\":",compact_query(~O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,~compact_health,~render_query(~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~render_vitals,~render_armor,~render_tracked),added),",\"changed\":",compact_query(~O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,~compact_health,~render_query(~T.HealthSchema,~T.VitalsView,~T.ArmorView,~T.Tracked,~render_vitals,~render_armor,~render_tracked),changed),",\"removed\":",compact_handles(T.HealthSchema,removed),",\"despawned\":",compact_handles(T.HealthSchema,despawned),",\"messages\":",render_list(~T.HealthPing,~render_health_ping,messages),",\"messageLag\":",render_boolean(messageLag),",\"removedLag\":",render_boolean(removedLag),",\"despawnedLag\":",render_boolean(despawnedLag),"}"])
    case other: render_health(other)
