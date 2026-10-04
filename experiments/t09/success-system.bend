import Base
import ./api.bend as A

def fail(-R: Type, -S: Type, r: R, s: S) -> IO(R & (S & A.Outcome)):
  IO.pure(R & (S & A.Outcome), (r, (s, A.Complete{})))

def notified(-R: Type, -S: Type, emit: S -> String -> IO(S), pair: R & U32, s: S) -> IO(R & (S & A.Outcome)):
  match pair:
    case (r, x):
      do IO<R & (S & A.Outcome)>:
        s : S <- emit(s, "Notify:" ++ U32.show(x))
        result : R & (S & A.Outcome) <- fail(R, S, r, s)
        return result

# Nested child declares resource-read and service-emit requirements.
def nested(-R: Type, -S: Type, read: R -> A.Token -> R & U32, emit: S -> String -> IO(S), r: R, s: S) -> IO(R & (S & A.Outcome)):
  notified(R, S, emit, read(r, A.Resource{}), s)

def after(-R: Type, -S: Type, r: R, s: S, result: A.Outcome) -> IO(R & (S & A.Outcome)):
  match result:
    case A.Complete{}:
      do IO<R & (S & A.Outcome)>:
        IO.print("After")
        return (r, (s, A.Complete{}))
    case result: IO.pure(R & (S & A.Outcome), (r, (s, result)))

def continue_schedule(-R: Type, -S: Type, owned: R & (S & A.Outcome)) -> IO(R & (S & A.Outcome)):
  match owned:
    case (r, (s, result)): after(R, S, r, s, result)

# The parent has exactly the requirements of its child. No World argument.
def schedule(-R: Type, -S: Type, read: R -> A.Token -> R & U32, emit: S -> String -> IO(S), r: R, s: S) -> IO(R & (S & A.Outcome)):
  do IO<R & (S & A.Outcome)>:
    IO.print("Begin")
    owned : R & (S & A.Outcome) <- nested(R, S, read, emit, r, s)
    output : R & (S & A.Outcome) <- continue_schedule(R, S, owned)
    return output
