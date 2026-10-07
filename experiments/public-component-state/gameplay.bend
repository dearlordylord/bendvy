import Base
import ../../src/ecs/state.bend as A
import ../../src/ecs/world.bend as W
import error-decoders.bend as Decode
import ../public-decode/typed.bend as D
import state.bend as V
import schema.bend as S
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as C
import ../../src/ecs/transaction.bend as T

type Error is Data:
  Rejected{}
type Action is Data:
  Advance{}
  Finish{}
  Reset{}
  Same{}
  FailAction{}
  RawLegal{}
  RawInvalid{}
  ModeRawLegal{}
  ModeRawInvalid{}
type Ops<-H: Type> is Type:
  Ops{phase: Cap.Write<H,V.Phase,V.Phase>,mode: Cap.Write<H,V.Mode,V.Mode>,neighbor: Cap.Read<H,S.NeighborView>,phaseRaw: Cap.Request<H,V.Phase,A.WriteStatus<W.WorldError>>,modeRaw: Cap.Request<H,V.Mode,A.WriteStatus<W.WorldError>>}
def Caps(H: Type) -> Type: Ops<H>
def phase(~H: Type,ops: Ops<H>) -> Cap.Write<H,V.Phase,V.Phase>:
  match ops:
    case Ops{phase,_,_,_,_}: phase
def mode(~H: Type,ops: Ops<H>) -> Cap.Write<H,V.Mode,V.Mode>:
  match ops:
    case Ops{_,mode,_,_,_}: mode
def neighbor(~H: Type,ops: Ops<H>) -> Cap.Read<H,S.NeighborView>:
  match ops:
    case Ops{_,_,neighbor,_,_}: neighbor
def phase_raw_cap(~H: Type,ops: Ops<H>) -> Cap.Request<H,V.Phase,A.WriteStatus<W.WorldError>>:
  match ops:
    case Ops{_,_,_,cap,_}: cap
def mode_raw_cap(~H: Type,ops: Ops<H>) -> Cap.Request<H,V.Mode,A.WriteStatus<W.WorldError>>:
  match ops:
    case Ops{_,_,_,_,cap}: cap
def moved(result: V.Moved) -> String:
  match result:
    case V.Moved{}: "moved"
    case V.Mismatch{expected,actual}: "mismatch:" ++ U32.show(V.phase_code(expected)) ++ ":" ++ U32.show(V.phase_code(actual))
    case V.Missing{}: "missing"
    case V.WriteRejected{_}: "write-rejected"
def done(~H: Type,observed: H & V.Moved) -> H & (T.Outcome<Error> & String):
  (owner,result) = observed
  (owner,(T.Success{},moved(result)))
def fail_mode(~H: Type,observed: H & V.ModeMoved) -> H & (T.Outcome<Error> & String):
  (owner,_) = observed
  (owner,(T.Failure{Rejected{}},"rejected"))
def failed_phase(~H: Type,~ops: Ops<H>,observed: H & V.Moved) -> H & (T.Outcome<Error> & String):
  (owner,_) = observed
  fail_mode(~H,V.mode_transition(~H,~mode(~H,ops),~mode_raw_cap(~H,ops),owner,V.ModeZero{},V.ModeTwo{}))
def advanced_mode(~H: Type,+result: String,observed: H & V.ModeMoved) -> H & (T.Outcome<Error> & String):
  (owner,_) = observed
  (owner,(T.Success{},result))
def advanced_phase(~H: Type,~ops: Ops<H>,observed: H & V.Moved) -> H & (T.Outcome<Error> & String):
  (owner,result) = observed
  advanced_mode(~H,moved(result),V.mode_transition(~H,~mode(~H,ops),~mode_raw_cap(~H,ops),owner,V.ModeZero{},V.ModeTwo{}))
def same_written(~H: Type,pair: H & A.Outcome<V.Phase,W.WorldError>) -> H & (T.Outcome<Error> & String):
  match pair:
    case (owner,A.StateMoved{}): (owner,(T.Success{},"same"))
    case (owner,_): (owner,(T.Failure{Rejected{}},"same-rejected"))
def same_observed(~H: Type,~ops: Ops<H>,observed: H & C.Access<V.Phase>) -> H & (T.Outcome<Error> & String):
  match observed:
    case (owner,C.Found{+value}): same_written(~H,A.compare_set(~H,~V.Phase,~W.WorldError,~V.phase_equal,~Cap.Read{Cap.write_read_field(~H,~V.Phase,~V.Phase,phase(~H,ops))},~phase_raw_cap(~H,ops),owner,value,value))
    case (owner,_): (owner,(T.Success{},"missing"))
def phase_error(~H: Type,owner: H,+raw: String,error: D.Error) -> H & (T.Outcome<Error> & String):
  match error:
    case D.Invalid{path,expected,D.Text{actual}}: (owner,(T.Success{},"raw:false|raw=" ++ raw ++ "|path=" ++ path ++ "|expected=" ++ expected ++ "|actual=" ++ actual))
    case _: (owner,(T.Success{},"unexpected-phase-error"))
def mode_error(~H: Type,owner: H,+raw: U32,error: D.Error) -> H & (T.Outcome<Error> & String):
  match error:
    case D.Invalid{path,expected,D.Number{actual}}: (owner,(T.Success{},"raw:false|raw=" ++ U32.show(raw) ++ "|path=" ++ path ++ "|expected=" ++ expected ++ "|actual=" ++ U32.show(actual)))
    case _: (owner,(T.Success{},"unexpected-mode-error"))
def phase_raw_done(~H: Type,pair: H & A.TypedRawOutcome<String,D.Error,W.WorldError>) -> H & (T.Outcome<Error> & String):
  match pair:
    case (owner,A.TypedRawWritten{}): (owner,(T.Success{},"raw:true"))
    case (owner,A.TypedRawRejected{raw,error}): phase_error(~H,owner,raw,error)
    case (owner,A.TypedRawWriteRejected{_,_}): (owner,(T.Failure{Rejected{}},"raw:write-rejected"))
def mode_raw_done(~H: Type,pair: H & A.TypedRawOutcome<U32,D.Error,W.WorldError>) -> H & (T.Outcome<Error> & String):
  match pair:
    case (owner,A.TypedRawWritten{}): (owner,(T.Success{},"raw:true"))
    case (owner,A.TypedRawRejected{raw,error}): mode_error(~H,owner,raw,error)
    case (owner,A.TypedRawWriteRejected{_,_}): (owner,(T.Failure{Rejected{}},"raw:write-rejected"))
def body(~H: Type,~ops: Ops<H>,action: Action,owner: H) -> H & (T.Outcome<Error> & String):
  match action:
    case Advance{}: advanced_phase(~H,~ops,V.transition(~H,~phase(~H,ops),~phase_raw_cap(~H,ops),owner,V.ReadyWindup{}))
    case Finish{}: done(~H,V.transition(~H,~phase(~H,ops),~phase_raw_cap(~H,ops),owner,V.WindupActive{}))
    case Reset{}: done(~H,V.transition(~H,~phase(~H,ops),~phase_raw_cap(~H,ops),owner,V.ActiveReady{}))
    case Same{}: same_observed(~H,~ops,Cap.get(~H,~V.Phase,~V.Phase,~phase(~H,ops),owner))
    case FailAction{}: failed_phase(~H,~ops,V.transition(~H,~phase(~H,ops),~phase_raw_cap(~H,ops),owner,V.ReadyWindup{}))
    case RawLegal{}: phase_raw_done(~H,A.set_raw_result(~H,~V.Phase,~String,~D.Error,~W.WorldError,~Decode.phase,~phase_raw_cap(~H,ops),owner,"ready"))
    case RawInvalid{}: phase_raw_done(~H,A.set_raw_result(~H,~V.Phase,~String,~D.Error,~W.WorldError,~Decode.phase,~phase_raw_cap(~H,ops),owner,"sleeping"))
    case ModeRawLegal{}: mode_raw_done(~H,A.set_raw_result(~H,~V.Mode,~U32,~D.Error,~W.WorldError,~Decode.mode,~mode_raw_cap(~H,ops),owner,1))
    case ModeRawInvalid{}: mode_raw_done(~H,A.set_raw_result(~H,~V.Mode,~U32,~D.Error,~W.WorldError,~Decode.mode,~mode_raw_cap(~H,ops),owner,9))


def ReadCaps(H: Type) -> Type: Cap.Read<H,V.Phase>
def watched(~H: Type,observed: H & C.Access<V.Phase>) -> H & (T.Outcome<Error> & String):
  match observed:
    case (owner,C.Found{value}): (owner,(T.Success{},U32.show(V.phase_code(value))))
    case (owner,_): (owner,(T.Success{},"null"))
def watch_body(~H: Type,~read: Cap.Read<H,V.Phase>,unit: Unit,owner: H) -> H & (T.Outcome<Error> & String):
  watched(~H,Cap.read(~H,~V.Phase,~read,owner))

def ModeReadCaps(H: Type) -> Type: Cap.Read<H,V.Mode>
def mode_watched(~H: Type,pair: H & C.Access<V.Mode>) -> H & (T.Outcome<Error> & String):
  match pair:
    case (owner,C.Found{value}): (owner,(T.Success{},U32.show(V.mode_code(value))))
    case (owner,_): (owner,(T.Success{},"null"))
def mode_watch_body(~H: Type,~read: Cap.Read<H,V.Mode>,unit: Unit,owner: H) -> H & (T.Outcome<Error> & String):
  mode_watched(~H,Cap.read(~H,~V.Mode,~read,owner))
