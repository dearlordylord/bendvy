import Base

type Token is Data:
  Resource{}
type OtherToken is Data:
  OtherResource{}
type Cell is Type:
  Cell{x: U32}
type Service is Type:
  Service{}
type Failure is Data:
  Rejected{code: U32}
type Outcome is Data:
  Complete{}
  SystemFailure{system: String, error: Failure}
  MissingResource{}
  MissingService{}

def read(c: Cell, token: Token) -> Cell & U32:
  match c token:
    case Cell{+x} Resource{}: (Cell{x}, x)
def write(c: Cell, token: Token, x: U32) -> Cell:
  match c token:
    case Cell{_} Resource{}: Cell{x}
def emit(s: Service, text: String) -> IO(Service):
  match s:
    case Service{}:
      do IO<Service>:
        IO.print(text)
        return Service{}

def wrap(owned: Cell & (Service & Outcome)) -> Maybe<&1, Cell> & (Maybe<&1, Service> & Outcome):
  match owned:
    case (r, (s, result)): (Some{r}, (Some{s}, result))

def provision(~system: @-R: Type -> @-S: Type -> (R -> Token -> R & U32) -> (S -> String -> IO(S)) -> R -> S -> IO(R & (S & Outcome)), r: Maybe<&1, Cell>, s: Maybe<&1, Service>) -> IO(Maybe<&1, Cell> & (Maybe<&1, Service> & Outcome)):
  match r s:
    case None{} s: IO.pure(Maybe<&1, Cell> & (Maybe<&1, Service> & Outcome), (None{}, (s, MissingResource{})))
    case Some{r} None{}: IO.pure(Maybe<&1, Cell> & (Maybe<&1, Service> & Outcome), (Some{r}, (None{}, MissingService{})))
    case Some{r} Some{s}:
      do IO<Maybe<&1, Cell> & (Maybe<&1, Service> & Outcome)>:
        owned : Cell & (Service & Outcome) <- system(Cell, Service, read, emit, r, s)
        return wrap(owned)

def show(result: Outcome) -> String:
  match result:
    case Complete{}: "complete"
    case SystemFailure{name, Rejected{code}}: "failure:" ++ name ++ ":" ++ U32.show(code)
    case MissingResource{}: "missing-resource"
    case MissingService{}: "missing-service"
