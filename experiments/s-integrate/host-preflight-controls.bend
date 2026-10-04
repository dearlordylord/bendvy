import Base
import ./types.bend as T
import ./storage.bend as W
import ./host.bend as H
import ./dispatcher.bend as D
import ./schedule.bend as Q
import ./capture.bend as C
import ./host-fixture.bend as F
import ./host-preflight.bend as P
import ./host-preflight-observer.bend as V

def motion_e2(+systems:List<&2,Q.System>) -> List<&2,Q.Node>:
  F.nodes(systems,[F.Call{"A",Q.Normal{}},F.Call{"Fast",Q.Observe{}},F.Nested{[F.Call{"B",Q.BFail{}},F.Call{"TailInner",Q.Normal{}}]},F.Call{"TailOuter",Q.Normal{}}])
def motion_observed(+label:String,+before:String,observed:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>> & String) -> IO(D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>):
  match observed:
    case (returned,+after):
      do IO<D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>>:
        IO.print("PREFLIGHT-ORIGINAL:" ++ label ++ ":" ++ Bool.show(String.eq(before,after)))
        IO.print("PREFLIGHT-BEFORE:" ++ before)
        IO.print("PREFLIGHT-AFTER:" ++ after)
        return returned
def motion_done(label:String,before:String,result:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>> & D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>) -> IO(D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>):
  match result:
    case (original,D.Dispatched{fresh,outcome}): motion_observed(label,before,V.motion_observe(original))
def motion_captured(+label:String,nodes:List<&2,Q.Node>,fresh:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,observed:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>> & String) -> IO(D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>):
  match observed:
    case (original,+before): IO.bind(D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>> & D.Dispatched<H.MotionHost(),W.Handle<T.MotionSchema>>,D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,P.motion_exchange(label,nodes,original,fresh),result => motion_done(label,before,result))
def motion_case(label:String,nodes:List<&2,Q.Node>,original:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,fresh:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>) -> IO(D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>):
  motion_captured(label,nodes,fresh,V.motion_observe(original))
def motion_cases(original:D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,+systems:List<&2,Q.System>,fresh:Maybe<F.MotionLane>) -> IO(Unit):
  match fresh:
    case None{}: IO.print("SETUP-REJECTED")
    case Some{F.MotionLane{first,second,_,_}}:
      IO.bind(D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,Unit,motion_case("missing-ledger",motion_e2(systems),original,P.motion_without_ledger(first)),returned => IO.bind(D.Runtime<H.MotionHost(),W.Handle<T.MotionSchema>>,Unit,motion_case("missing-audit",motion_e2(systems),returned,P.motion_without_audit(second)),_ => IO.pure(Unit,Unit{})))
def motion_primed(lane:F.MotionLane) -> IO(Unit):
  match lane:
    case F.MotionLane{original,_,systems,_}: motion_cases(original,systems,F.motion_initial(C.Returned{}))
def motion_start(maybe:Maybe<F.MotionLane>) -> IO(Unit):
  match maybe:
    case None{}: IO.print("SETUP-REJECTED")
    case Some{lane}: IO.bind(F.MotionLane,Unit,F.motion_run([F.Frame{False{},False{},"prime",False{},[F.Call{"Fast",Q.Observe{}},F.Call{"B",Q.Observe{}}]}],lane),motion_primed)

def health_e2(+systems:List<&2,Q.System>) -> List<&2,Q.Node>:
  F.nodes(systems,[F.Call{"A",Q.Normal{}},F.Call{"Fast",Q.Observe{}},F.Nested{[F.Call{"B",Q.BFail{}},F.Call{"TailInner",Q.Normal{}}]},F.Call{"TailOuter",Q.Normal{}}])
def health_observed(+label:String,+before:String,observed:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>> & String) -> IO(D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>):
  match observed:
    case (returned,+after):
      do IO<D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>>:
        IO.print("PREFLIGHT-ORIGINAL:" ++ label ++ ":" ++ Bool.show(String.eq(before,after)))
        IO.print("PREFLIGHT-BEFORE:" ++ before)
        IO.print("PREFLIGHT-AFTER:" ++ after)
        return returned
def health_done(label:String,before:String,result:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>> & D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>) -> IO(D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>):
  match result:
    case (original,D.Dispatched{fresh,outcome}): health_observed(label,before,V.health_observe(original))
def health_captured(+label:String,nodes:List<&2,Q.Node>,fresh:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,observed:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>> & String) -> IO(D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>):
  match observed:
    case (original,+before): IO.bind(D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>> & D.Dispatched<H.HealthHost(),W.Handle<T.HealthSchema>>,D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,P.health_exchange(label,nodes,original,fresh),result => health_done(label,before,result))
def health_case(label:String,nodes:List<&2,Q.Node>,original:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,fresh:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>) -> IO(D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>):
  health_captured(label,nodes,fresh,V.health_observe(original))
def health_cases(original:D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,+systems:List<&2,Q.System>,fresh:Maybe<F.HealthLane>) -> IO(Unit):
  match fresh:
    case None{}: IO.print("SETUP-REJECTED")
    case Some{F.HealthLane{first,second,_,_}}:
      IO.bind(D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,Unit,health_case("missing-ledger",health_e2(systems),original,P.health_without_ledger(first)),returned => IO.bind(D.Runtime<H.HealthHost(),W.Handle<T.HealthSchema>>,Unit,health_case("missing-audit",health_e2(systems),returned,P.health_without_audit(second)),_ => IO.pure(Unit,Unit{})))
def health_primed(lane:F.HealthLane) -> IO(Unit):
  match lane:
    case F.HealthLane{original,_,systems,_}: health_cases(original,systems,F.health_initial(C.Returned{}))
def health_start(maybe:Maybe<F.HealthLane>) -> IO(Unit):
  match maybe:
    case None{}: IO.print("SETUP-REJECTED")
    case Some{lane}: IO.bind(F.HealthLane,Unit,F.health_run([F.Frame{False{},False{},"prime",False{},[F.Call{"Fast",Q.Observe{}},F.Call{"B",Q.Observe{}}]}],lane),health_primed)
def main() -> IO(Unit):
  do IO<Unit>:
    motion_start(F.motion_initial(C.Returned{}))
    health_start(F.health_initial(C.Returned{}))
    return Unit{}
