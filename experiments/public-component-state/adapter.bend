import Base
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/component.bend as C

# Consumer defines the value vocabulary, equality and closed legal-edge enum.
# Runtime checks current==expected; graph admissibility is the typed Move boundary.
type Outcome<Value: Data> is Data:
  StateMoved{}
  StateMismatch{expected: Value,actual: Value}
  StateAccessRejected{access: C.Access<Value>}
def apply(~H: Type,~Value: Data,~write: Cap.Write<H,Value,Value>,+expected: Value,+target: Value,+actual: Value,owner: H,same: Bool) -> H & Outcome<Value>:
  match same:
    case False{}: (owner,StateMismatch{expected,actual})
    case True{}: (Cap.set(~H,~Value,~Value,~write,owner,target),StateMoved{})
def observed(~H: Type,~Value: Data,~equal: Value -> Value -> Bool,~write: Cap.Write<H,Value,Value>,+expected: Value,+target: Value,pair: H & C.Access<Value>) -> H & Outcome<Value>:
  match pair:
    case (owner,C.Found{+actual}): apply(~H,~Value,~write,expected,target,actual,owner,equal(actual,expected))
    case (owner,C.ComponentAbsent{}): (owner,StateAccessRejected{C.ComponentAbsent{}})
    case (owner,C.MissingEntity{}): (owner,StateAccessRejected{C.MissingEntity{}})
def compare_set(~H: Type,~Value: Data,~equal: Value -> Value -> Bool,~write: Cap.Write<H,Value,Value>,owner: H,+expected: Value,+target: Value) -> H & Outcome<Value>:
  observed(~H,~Value,~equal,~write,expected,target,Cap.get(~H,~Value,~Value,~write,owner))
def with_endpoints(~H: Type,~Value: Data,~equal: Value -> Value -> Bool,~write: Cap.Write<H,Value,Value>,owner: H,pair: Value & Value) -> H & Outcome<Value>:
  (+expected,+target) = pair
  compare_set(~H,~Value,~equal,~write,owner,expected,target)
def transition(~H: Type,~Value: Data,~Move: Data,~equal: Value -> Value -> Bool,~endpoints: Move -> Value & Value,~write: Cap.Write<H,Value,Value>,owner: H,move: Move) -> H & Outcome<Value>:
  with_endpoints(~H,~Value,~equal,~write,owner,endpoints(move))

type RawOutcome is Data:
  RawWritten{}
  RawRejected{}
def raw_observed(~H: Type,~Value: Data,~write: Cap.Write<H,Value,Value>,owner: H,decoded: Maybe<&2,Value>) -> H & RawOutcome:
  match decoded:
    case None{}: (owner,RawRejected{})
    case Some{value}: (Cap.set(~H,~Value,~Value,~write,owner,value),RawWritten{})
def set_raw(~H: Type,~Value: Data,~Raw: Data,~decode: Raw -> Maybe<&2,Value>,~write: Cap.Write<H,Value,Value>,owner: H,raw: Raw) -> H & RawOutcome:
  raw_observed(~H,~Value,~write,owner,decode(raw))

# Exact caller-error preservation; the caller's decoder validates its own Raw.
# Returning Raw on refusal retains the supplied finite input independently of
# whatever diagnostic representation the caller places inside Error.
type WriteStatus<WriteError: Data> is Data:
  WriteAccepted{}
  WriteRejected{error: WriteError}
type TypedRawOutcome<Raw: Data,Error: Data,WriteError: Data> is Data:
  TypedRawWritten{}
  TypedRawRejected{raw: Raw,error: Error}
  TypedRawWriteRejected{raw: Raw,error: WriteError}
def written_result(~H: Type,~Raw: Data,~Error: Data,~WriteError: Data,raw: Raw,pair: H & WriteStatus<WriteError>) -> H & TypedRawOutcome<Raw,Error,WriteError>:
  match pair:
    case (owner,WriteAccepted{}): (owner,TypedRawWritten{})
    case (owner,WriteRejected{error}): (owner,TypedRawWriteRejected{raw,error})
def result_observed(~H: Type,~Value: Data,~Raw: Data,~Error: Data,~WriteError: Data,~write: Cap.Request<H,Value,WriteStatus<WriteError>>,owner: H,raw: Raw,decoded: Result<&2,&1,Error,Value>) -> H & TypedRawOutcome<Raw,Error,WriteError>:
  match decoded:
    case Done{value}: written_result(~H,~Raw,~Error,~WriteError,raw,Cap.request(~H,~Value,~WriteStatus<WriteError>,~write,owner,value))
    case Fail{error}: (owner,TypedRawRejected{raw,error})
def result_raw_inner(~H: Type,~Value: Data,~Raw: Data,~Error: Data,~WriteError: Data,~decode: Raw -> Result<&2,&1,Error,Value>,~write: Cap.Request<H,Value,WriteStatus<WriteError>>,owner: H,+raw: Raw) -> H & TypedRawOutcome<Raw,Error,WriteError>:
  result_observed(~H,~Value,~Raw,~Error,~WriteError,~write,owner,raw,decode(raw))
def set_raw_result(~H: Type,~Value: Data,~Raw: Data,~Error: Data,~WriteError: Data,~decode: Raw -> Result<&2,&1,Error,Value>,~write: Cap.Request<H,Value,WriteStatus<WriteError>>,owner: H,raw: Raw) -> H & TypedRawOutcome<Raw,Error,WriteError>:
  match raw:
    case +raw: result_raw_inner(~H,~Value,~Raw,~Error,~WriteError,~decode,~write,owner,raw)
