import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/state.bend as A
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as C

type Phase is Data:
  Ready{}
  Windup{}
  Active{}
type Move is Data:
  ReadyWindup{}
  WindupActive{}
  WindupReady{}
  ActiveReady{}
type Mode is Data:
  ModeZero{}
  ModeOne{}
  ModeTwo{}
type Moved is Data:
  Moved{}
  Mismatch{expected: Phase,actual: Phase}
  Missing{}
  WriteRejected{error: W.WorldError}
type ModeMoved is Data:
  ModeMoved{}
  ModeMismatch{expected: Mode,actual: Mode}
  ModeMissing{}
  ModeWriteRejected{error: W.WorldError}
def phase_code(phase: Phase) -> U32:
  match phase:
    case Ready{}: 0
    case Windup{}: 1
    case Active{}: 2
def phase_decode(code: U32) -> Maybe<&2,Phase>:
  match code:
    case 0: Some{Ready{}}
    case 1: Some{Windup{}}
    case 2: Some{Active{}}
    case _: None{}
def mode_code(mode: Mode) -> U32:
  match mode:
    case ModeZero{}: 0
    case ModeOne{}: 1
    case ModeTwo{}: 2
def mode_decode(code: U32) -> Maybe<&2,Mode>:
  match code:
    case 0: Some{ModeZero{}}
    case 1: Some{ModeOne{}}
    case 2: Some{ModeTwo{}}
    case _: None{}
def endpoints(move: Move) -> Phase & Phase:
  match move:
    case ReadyWindup{}: (Ready{},Windup{})
    case WindupActive{}: (Windup{},Active{})
    case WindupReady{}: (Windup{},Ready{})
    case ActiveReady{}: (Active{},Ready{})
def phase_equal(a: Phase,b: Phase) -> Bool:
  U32.is_eq(phase_code(a),phase_code(b))
def phase_result(~H: Type,pair: H & A.Outcome<Phase,W.WorldError>) -> H & Moved:
  match pair:
    case (owner,A.StateMoved{}): (owner,Moved{})
    case (owner,A.StateMismatch{expected,actual}): (owner,Mismatch{expected,actual})
    case (owner,A.StateAccessRejected{_}): (owner,Missing{})
    case (owner,A.StateWriteRejected{error}): (owner,WriteRejected{error})
def transition(~H: Type,~write: Cap.Write<H,Phase,Phase>,~request: Cap.Request<H,Phase,A.WriteStatus<W.WorldError>>,owner: H,move: Move) -> H & Moved:
  phase_result(~H,A.transition(~H,~Phase,~Move,~W.WorldError,~phase_equal,~endpoints,~Cap.Read{Cap.write_read_field(~H,~Phase,~Phase,write)},~request,owner,move))
def mode_equal(a: Mode,b: Mode) -> Bool:
  U32.is_eq(mode_code(a),mode_code(b))
def mode_result(~H: Type,pair: H & A.Outcome<Mode,W.WorldError>) -> H & ModeMoved:
  match pair:
    case (owner,A.StateMoved{}): (owner,ModeMoved{})
    case (owner,A.StateMismatch{expected,actual}): (owner,ModeMismatch{expected,actual})
    case (owner,A.StateAccessRejected{_}): (owner,ModeMissing{})
    case (owner,A.StateWriteRejected{error}): (owner,ModeWriteRejected{error})
def mode_transition(~H: Type,~write: Cap.Write<H,Mode,Mode>,~request: Cap.Request<H,Mode,A.WriteStatus<W.WorldError>>,owner: H,+expected: Mode,+target: Mode) -> H & ModeMoved:
  mode_result(~H,A.compare_set(~H,~Mode,~W.WorldError,~mode_equal,~Cap.Read{Cap.write_read_field(~H,~Mode,~Mode,write)},~request,owner,expected,target))

def phase_raw_active(same: Bool) -> Maybe<&2,Phase>:
  match same:
    case True{}: Some{Active{}}
    case False{}: None{}
def phase_raw_windup(+raw: String,same: Bool) -> Maybe<&2,Phase>:
  match same:
    case True{}: Some{Windup{}}
    case False{}: phase_raw_active(String.eq(raw,"active"))
def phase_raw_ready(+raw: String,same: Bool) -> Maybe<&2,Phase>:
  match same:
    case True{}: Some{Ready{}}
    case False{}: phase_raw_windup(raw,String.eq(raw,"windup"))
def phase_raw(raw: String) -> Maybe<&2,Phase>:
  match raw:
    case +raw: phase_raw_ready(raw,String.eq(raw,"ready"))
