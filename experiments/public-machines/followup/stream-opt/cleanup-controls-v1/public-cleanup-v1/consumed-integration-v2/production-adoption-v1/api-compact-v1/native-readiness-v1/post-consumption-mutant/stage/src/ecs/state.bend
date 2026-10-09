import Base
import capabilities.bend as Cap
import component.bend as C

# Consumer-owned vocabulary, equality, legal move enum and endpoints are trusted
# declarations. Local acceptance never commits the surrounding transaction.
type WriteStatus<WriteError: Data> is Data:
  WriteAccepted{}
  WriteRejected{error: WriteError}
type Outcome<Value: Data,WriteError: Data> is Data:
  StateMoved{}
  StateMismatch{expected: Value,actual: Value}
  StateAccessRejected{access: C.Access<Value>}
  StateWriteRejected{error: WriteError}
def move_written(~H: Type,~Value: Data,~WriteError: Data,pair: H & WriteStatus<WriteError>) -> H & Outcome<Value,WriteError>:
  match pair:
    case (owner,WriteAccepted{}): (owner,StateMoved{})
    case (owner,WriteRejected{error}): (owner,StateWriteRejected{error})
def apply(~H: Type,~Value: Data,~WriteError: Data,~write: Cap.Request<H,Value,WriteStatus<WriteError>>,+expected: Value,+target: Value,+actual: Value,owner: H,same: Bool) -> H & Outcome<Value,WriteError>:
  match same:
    case False{}: (owner,StateMismatch{expected,actual})
    case True{}: move_written(~H,~Value,~WriteError,Cap.request(~H,~Value,~WriteStatus<WriteError>,~write,owner,target))
def observed(~H: Type,~Value: Data,~WriteError: Data,~equal: Value -> Value -> Bool,~write: Cap.Request<H,Value,WriteStatus<WriteError>>,+expected: Value,+target: Value,pair: H & C.Access<Value>) -> H & Outcome<Value,WriteError>:
  match pair:
    case (owner,C.Found{+actual}): apply(~H,~Value,~WriteError,~write,expected,target,actual,owner,equal(actual,expected))
    case (owner,C.ComponentAbsent{}): (owner,StateAccessRejected{C.ComponentAbsent{}})
    case (owner,C.MissingEntity{}): (owner,StateAccessRejected{C.MissingEntity{}})
def compare_set(~H: Type,~Value: Data,~WriteError: Data,~equal: Value -> Value -> Bool,~read: Cap.Read<H,Value>,~write: Cap.Request<H,Value,WriteStatus<WriteError>>,owner: H,+expected: Value,+target: Value) -> H & Outcome<Value,WriteError>:
  observed(~H,~Value,~WriteError,~equal,~write,expected,target,Cap.read(~H,~Value,~read,owner))
def with_endpoints(~H: Type,~Value: Data,~WriteError: Data,~equal: Value -> Value -> Bool,~read: Cap.Read<H,Value>,~write: Cap.Request<H,Value,WriteStatus<WriteError>>,owner: H,pair: Value & Value) -> H & Outcome<Value,WriteError>:
  (+expected,+target) = pair
  compare_set(~H,~Value,~WriteError,~equal,~read,~write,owner,expected,target)
def transition(~H: Type,~Value: Data,~Move: Data,~WriteError: Data,~equal: Value -> Value -> Bool,~endpoints: Move -> Value & Value,~read: Cap.Read<H,Value>,~write: Cap.Request<H,Value,WriteStatus<WriteError>>,owner: H,move: Move) -> H & Outcome<Value,WriteError>:
  with_endpoints(~H,~Value,~WriteError,~equal,~read,~write,owner,endpoints(move))

# Exact caller-error preservation; the caller's decoder validates its own Raw.
# Returning Raw on refusal retains the supplied finite input independently of
# whatever diagnostic representation the caller places inside Error.
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
