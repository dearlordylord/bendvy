import Base
import ./host-batch-invoker.bend as B
import ./types.bend as T
import ./storage.bend as W
import ./identity.bend as I
import ./host.bend as H
import ./host-observations.bend as E
import ./host-render.bend as J
import ./dispatcher.bend as D
import ./schedule.bend as K
import ./readers.bend as R
import ./capture.bend as LC
import ./storage-stage-fixture.bend as F

# Exact public E11 input matrix; each frame invokes the real closed dispatcher.
# These are fixture commands, not Q.BodyKind or a replacement dispatcher.
# Every RetFrame must become one real D.tick, including empty frames.
type RetFrame is Data:
  RetFrame{label: String,ops: List<&2,B.RetOp>}
type RetLane is Data:
  RetMessage{}
  RetRemoved{}
  RetDespawned{}
  RetUnheld{}
  RetMarks{}

def message_frames() -> List<&2,RetFrame>:
  [RetFrame{"seed-payload",[B.RetSpawn{1,10},B.RetBarrier{}]},
   RetFrame{"prime-fast",[B.RetRead{B.RetFast{},False{}}]},RetFrame{"prime-B",[B.RetRead{B.RetB{},False{}}]},
   RetFrame{"publish-full",[B.RetEmit{0,65536}]},RetFrame{"fast-full",[B.RetRead{B.RetFast{},False{}}]},
   RetFrame{"publish-one",[B.RetEmit{65536,1}]},RetFrame{"trim-full",[]},
   RetFrame{"B-first-post-drop-fails",[B.RetRead{B.RetB{},True{}}]},RetFrame{"B-same-instance-retry",[B.RetRead{B.RetB{},False{}}]},
   RetFrame{"independent-fast",[B.RetRead{B.RetFast{},False{}}]},RetFrame{"publish-oversized",[B.RetEmit{65537,65537}]},
   RetFrame{"trim-oversized",[]},RetFrame{"B-oversized-empty-lag",[B.RetRead{B.RetB{},False{}}]},
   RetFrame{"Fast-oversized-empty-lag",[B.RetRead{B.RetFast{},False{}}]},RetFrame{"late-registration-no-historical-lag",[B.RetRead{B.RetLate{},False{}}]}]
def lifecycle_frames(delete: B.RetOp) -> List<&2,RetFrame>:
  [RetFrame{"prime-fast",[B.RetRead{B.RetFast{},False{}}]},RetFrame{"prime-B",[B.RetRead{B.RetB{},False{}}]},
   RetFrame{"spawn-capacity-plus-one",[B.RetSpawn{65537,10},B.RetBarrier{}]},
   RetFrame{"Fast-all-added-full-fields",[B.RetRead{B.RetFast{},False{}}]},RetFrame{"B-all-added-full-fields",[B.RetRead{B.RetB{},False{}}]},
   RetFrame{"Fast-removals-before-trim",[delete,B.RetBarrier{},B.RetRead{B.RetFast{},False{}}]},RetFrame{"capacity-trim",[]},
   RetFrame{"late-registration-retained-records-no-historical-lag",[B.RetRead{B.RetLate{},False{}}]},
   RetFrame{"B-first-post-drop-fails",[B.RetRead{B.RetB{},True{}}]},RetFrame{"B-same-instance-retry",[B.RetRead{B.RetB{},False{}}]},
   RetFrame{"independent-fast-empty-not-lagged",[B.RetRead{B.RetFast{},False{}}]}]
def unheld_frames() -> List<&2,RetFrame>:
  [RetFrame{"spawn-unheld",[B.RetSpawn{2,10},B.RetBarrier{}]},RetFrame{"delete-unheld",[B.RetRemoveFirstDespawnSecond{},B.RetBarrier{}]},
   RetFrame{"empty1",[]},RetFrame{"empty2",[]},RetFrame{"empty3",[]},RetFrame{"first-Fast-no-history-or-lag",[B.RetRead{B.RetFast{},False{}}]}]
def marks_frames() -> List<&2,RetFrame>:
  [RetFrame{"prime-fast",[B.RetRead{B.RetFast{},False{}}]},RetFrame{"spawn",[B.RetSpawn{1,10},B.RetBarrier{}]},
   RetFrame{"Fast-seed",[B.RetRead{B.RetFast{},False{}}]},RetFrame{"write-slot0",[B.RetWriteMain0{11}]},
   RetFrame{"empty1",[]},RetFrame{"empty2",[]},RetFrame{"empty3",[]},RetFrame{"first-B-old-surviving-marks",[B.RetRead{B.RetB{},False{}}]}]
def frames(lane: RetLane) -> List<&2,RetFrame>:
  match lane:
    case RetMessage{}: message_frames()
    case RetRemoved{}: lifecycle_frames(B.RetRemoveAll{})
    case RetDespawned{}: lifecycle_frames(B.RetDespawnAll{})
    case RetUnheld{}: unheld_frames()
    case RetMarks{}: marks_frames()

type Actors is Data:
  Actors{batch:K.System,fast:K.System,b:K.System,late:K.System}
def registered_late(batch:K.System,fast:K.System,b:K.System,result:K.Registered) -> K.Registry & Actors:
  match result:
    case K.Registered{registry,late}: (registry,Actors{batch,fast,b,late})
def registered_b(batch:K.System,fast:K.System,result:K.Registered) -> K.Registry & Actors:
  match result:
    case K.Registered{registry,b}: registered_late(batch,fast,b,K.register(registry,"Late",K.ReadOnlyLate{},False{},False{},False{},True{}))
def registered_fast(batch:K.System,result:K.Registered) -> K.Registry & Actors:
  match result:
    case K.Registered{registry,fast}: registered_b(batch,fast,K.register(registry,"B",K.B{},False{},False{},False{},True{}))
def registered_batch(result:K.Registered) -> K.Registry & Actors:
  match result:
    case K.Registered{registry,batch}: registered_fast(batch,K.register(registry,"Fast",K.Fast{},False{},False{},False{},True{}))
def register() -> K.Registry & Actors:
  registered_batch(K.register(K.initial(),"Batch",K.Seed{},False{},False{},False{},False{}))
def actor(which:B.RetActor,actors:Actors) -> K.System:
  match which actors:
    case B.RetFast{} Actors{_,fast,_,_}: fast
    case B.RetB{} Actors{_,_,b,_}: b
    case B.RetLate{} Actors{_,_,_,late}: late
def read_mode(fails:Bool) -> K.Mode:
  match fails:
    case True{}: K.ObserveFail{}
    case False{}: K.Observe{}
def node(op:B.RetOp,+actors:Actors) -> K.Node:
  match op actors:
    case B.RetRead{who,fails} _: K.Call{actor(who,actors),read_mode(fails)}
    case B.RetBarrier{} _: K.Deferred{}
    case _ Actors{batch,_,_,_}: K.Call{batch,K.Normal{}}
def nodes(ops:List<&2,B.RetOp>,+actors:Actors) -> List<&2,K.Node>:
  match ops:
    case Nil{}: []
    case Con{head,tail}: node(head,actors) <> nodes(tail,actors)
def request(ops:List<&2,B.RetOp>) -> B.RetOp:
  match ops:
    case Nil{}: B.RetBarrier{}
    case Con{B.RetRead{_,_},tail}: request(tail)
    case Con{B.RetBarrier{},tail}: request(tail)
    case Con{head,_}: head
def lane_name(lane:RetLane) -> String:
  match lane:
    case RetMessage{}: "message"
    case RetRemoved{}: "removed"
    case RetDespawned{}: "despawned"
    case RetUnheld{}: "unheld"
    case RetMarks{}: "marks"
def reserve_summary(ok:Bool,namespace:U32,first:U32,last:U32,count:U32) -> String:
  match ok:
    case False{}: "{\"kind\":\"UnrepresentableReservations\"}"
    case True{}: "{\"kind\":\"Reservations\",\"namespace\":" ++ U32.show(namespace) ++ ",\"first\":" ++ U32.show(first) ++ ",\"last\":" ++ U32.show(last) ++ ",\"count\":" ++ U32.show(count) ++ "}"
def reserves(-Schema:Data,values:List<&2,E.Binding<Schema>>,+namespace:U32,+first:U32,+next:U32,+count:U32,ok:Bool) -> String:
  match values:
    case Nil{}: reserve_summary(ok,namespace,first,U32.sub(next,1),count)
    case Con{E.Binding{_,W.Handle{ns,id}},tail}: reserves(Schema,tail,namespace,first,U32.add(next,1),U32.add(count,1),Bool.and(ok,Bool.and(U32.is_eq(namespace,ns),U32.is_eq(next,id))))
def reservations(-Schema:Data,values:List<&2,E.Binding<Schema>>) -> String:
  match values:
    case Nil{}: "{\"kind\":\"Reservations\",\"namespace\":null,\"first\":null,\"last\":null,\"count\":0}"
    case Con{E.Binding{_,W.Handle{+ns,+id}},tail}: reserves(Schema,tail,ns,id,U32.add(id,1),1,True{})

def motion_record_wrap(request:B.RetOp,result:D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>) -> D.Dispatched<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>:
  match result:
    case D.Dispatched{D.Runtime{host,registry,readers,clock,audit,style,escaped,observations,nextMode},outcome}:
      D.Dispatched{D.Runtime{B.Batch{host,request},registry,readers,clock,audit,style,escaped,observations,nextMode},outcome}
def motion_record(result:D.Dispatched<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>) -> D.Dispatched<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>:
  match result:
    case D.Dispatched{D.Runtime{B.Batch{host,request},registry,readers,clock,audit,style,escaped,observations,nextMode},outcome}:
      motion_record_wrap(request,H.dispatched(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,True{},D.Dispatched{D.Runtime{host,registry,readers,clock,audit,style,escaped,observations,nextMode},outcome}))
def motion_prepare(label:String,op:B.RetOp,runtime:D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>) -> D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>:
  match runtime:
    case D.Runtime{B.Batch{host,_},registry,readers,clock,audit,style,escaped,observations,nextMode}:
      D.Runtime{B.Batch{H.label(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,label,host),op},registry,readers,clock,audit,style,escaped,observations,nextMode}
def motion_resume(continuation:D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>> -> IO(D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>),result:D.Dispatched<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>) -> IO(D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>):
  match result:
    case D.Dispatched{runtime,_}: continuation(runtime)
def motion_frames(items:List<&2,RetFrame>,+actors:Actors,runtime:D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>) -> IO(D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>):
  match items:
    case Nil{}: IO.pure(D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>,runtime)
    case Con{RetFrame{label,+ops},tail}:
      IO.bind(D.Dispatched<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>,D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>,B.motion_tick(nodes(ops,actors),motion_prepare(label,request(ops),runtime)),result => motion_resume(rest => motion_frames(tail,actors,rest),motion_record(result)))
def motion_events(events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>) -> IO(Unit):
  match events:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{head,tail}:
      do IO<Unit>:
        IO.print(J.compact_motion_event(head))
        motion_events(tail)
def motion_finish(runtime:D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>>) -> IO(Unit):
  match runtime:
    case D.Runtime{B.Batch{H.Host{world,logs,bindings,worldName,step,prior,events},_},registry,readers,clock,audit,style,escaped,observations,nextMode}:
      do IO<Unit>:
        IO.print(reservations(T.MotionSchema,bindings))
        motion_events(events)
def motion_registered(+lane:RetLane,world:W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,result:K.Registry & Actors) -> IO(Unit):
  match result:
    case (registry,actors):
      do IO<Unit>:
        IO.print("{\"kind\":\"Lane\",\"schema\":\"Motion\",\"lane\":\"" ++ lane_name(lane) ++ "\"}")
        final : D.Runtime<B.Batch<H.MotionHost()>,W.Handle<T.MotionSchema>> <- motion_frames(frames(lane),actors,D.Runtime{B.Batch{H.initial(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,"alpha",world,65536),B.RetBarrier{}},registry,R.initial(),R.clock(),None{},LC.Returned{},[],[],None{}})
        motion_finish(final)
def motion_created(lane:RetLane,result:T.Creation<W.Factory,W.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>>) -> IO(Unit):
  match result:
    case T.CreateRejected{_}: IO.die(Unit,2,"unexpected factory exhaustion")
    case T.Created{factory,world}: motion_registered(lane,world,register())
def motion(lane:RetLane) -> IO(Unit):
  motion_created(lane,I.create(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,F.motion_ledger,I.factory(),T.MotionOn{}))

def health_record_wrap(request:B.RetOp,result:D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>) -> D.Dispatched<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>:
  match result:
    case D.Dispatched{D.Runtime{host,registry,readers,clock,audit,style,escaped,observations,nextMode},outcome}:
      D.Dispatched{D.Runtime{B.Batch{host,request},registry,readers,clock,audit,style,escaped,observations,nextMode},outcome}
def health_record(result:D.Dispatched<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>) -> D.Dispatched<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>:
  match result:
    case D.Dispatched{D.Runtime{B.Batch{host,request},registry,readers,clock,audit,style,escaped,observations,nextMode},outcome}:
      health_record_wrap(request,H.dispatched(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,True{},D.Dispatched{D.Runtime{host,registry,readers,clock,audit,style,escaped,observations,nextMode},outcome}))
def health_prepare(label:String,op:B.RetOp,runtime:D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>) -> D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>:
  match runtime:
    case D.Runtime{B.Batch{host,_},registry,readers,clock,audit,style,escaped,observations,nextMode}:
      D.Runtime{B.Batch{H.label(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,label,host),op},registry,readers,clock,audit,style,escaped,observations,nextMode}
def health_resume(continuation:D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>> -> IO(D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>),result:D.Dispatched<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>) -> IO(D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>):
  match result:
    case D.Dispatched{runtime,_}: continuation(runtime)
def health_frames(items:List<&2,RetFrame>,+actors:Actors,runtime:D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>) -> IO(D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>):
  match items:
    case Nil{}: IO.pure(D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>,runtime)
    case Con{RetFrame{label,+ops},tail}:
      IO.bind(D.Dispatched<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>,D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>,B.health_tick(nodes(ops,actors),health_prepare(label,request(ops),runtime)),result => health_resume(rest => health_frames(tail,actors,rest),health_record(result)))
def health_events(events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>) -> IO(Unit):
  match events:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{head,tail}:
      do IO<Unit>:
        IO.print(J.compact_health_event(head))
        health_events(tail)
def health_finish(runtime:D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>>) -> IO(Unit):
  match runtime:
    case D.Runtime{B.Batch{H.Host{world,logs,bindings,worldName,step,prior,events},_},registry,readers,clock,audit,style,escaped,observations,nextMode}:
      do IO<Unit>:
        IO.print(reservations(T.HealthSchema,bindings))
        health_events(events)
def health_registered(+lane:RetLane,world:W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,result:K.Registry & Actors) -> IO(Unit):
  match result:
    case (registry,actors):
      do IO<Unit>:
        IO.print("{\"kind\":\"Lane\",\"schema\":\"Health\",\"lane\":\"" ++ lane_name(lane) ++ "\"}")
        final : D.Runtime<B.Batch<H.HealthHost()>,W.Handle<T.HealthSchema>> <- health_frames(frames(lane),actors,D.Runtime{B.Batch{H.initial(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,"alpha",world,65536),B.RetBarrier{}},registry,R.initial(),R.clock(),None{},LC.Returned{},[],[],None{}})
        health_finish(final)
def health_created(lane:RetLane,result:T.Creation<W.Factory,W.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>>) -> IO(Unit):
  match result:
    case T.CreateRejected{_}: IO.die(Unit,2,"unexpected factory exhaustion")
    case T.Created{factory,world}: health_registered(lane,world,register())
def health(lane:RetLane) -> IO(Unit):
  health_created(lane,I.create(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,F.health_ledger,I.factory(),T.HealthOn{}))

def choose_schema(schema:U32,lane:RetLane) -> IO(Unit):
  match schema:
    case 0: motion(lane)
    case 1: health(lane)
    case _: IO.die(Unit,2,"schema outside finite setup")
def choose_lane(schema:U32,lane:U32) -> IO(Unit):
  match lane:
    case 0: choose_schema(schema,RetMessage{})
    case 1: choose_schema(schema,RetRemoved{})
    case 2: choose_schema(schema,RetDespawned{})
    case 3: choose_schema(schema,RetUnheld{})
    case 4: choose_schema(schema,RetMarks{})
    case _: IO.die(Unit,2,"lane outside finite setup")
def parsed(schema:Maybe<&2,U32>,lane:Maybe<&2,U32>) -> IO(Unit):
  match schema lane:
    case Some{s} Some{l}: choose_lane(s,l)
    case _ _: IO.die(Unit,2,"invalid arguments")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{lane,_}}}: parsed(U32.read(schema),U32.read(lane))
    case _: IO.die(Unit,2,"schema and lane required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
