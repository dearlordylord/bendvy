import Base
import ./api.bend as A
import ./success-system.bend as S

def report(owned: Maybe<&1, A.Cell> & (Maybe<&1, A.Service> & A.Outcome)) -> IO(Maybe<&1, A.Cell> & Maybe<&1, A.Service>):
  match owned:
    case (r, (s, result)):
      do IO<Maybe<&1, A.Cell> & Maybe<&1, A.Service>>:
        IO.print(A.show(result))
        return (r, s)

def again(pair: Maybe<&1, A.Cell> & Maybe<&1, A.Service>) -> IO(Unit):
  match pair:
    case (r, s):
      do IO<Unit>:
        owned : Maybe<&1, A.Cell> & (Maybe<&1, A.Service> & A.Outcome) <- A.provision(~S.schedule, r, s)
        _ : Maybe<&1, A.Cell> & Maybe<&1, A.Service> <- report(owned)
        return Unit{}

def main() -> IO(Unit):
  do IO<Unit>:
    owned : Maybe<&1, A.Cell> & (Maybe<&1, A.Service> & A.Outcome) <- A.provision(~S.schedule, Some{A.Cell{42}}, Some{A.Service{}})
    pair : Maybe<&1, A.Cell> & Maybe<&1, A.Service> <- report(owned)
    again(pair)
    owned : Maybe<&1, A.Cell> & (Maybe<&1, A.Service> & A.Outcome) <- A.provision(~S.schedule, None{}, Some{A.Service{}})
    _ : Maybe<&1, A.Cell> & Maybe<&1, A.Service> <- report(owned)
    owned : Maybe<&1, A.Cell> & (Maybe<&1, A.Service> & A.Outcome) <- A.provision(~S.schedule, Some{A.Cell{42}}, None{})
    _ : Maybe<&1, A.Cell> & Maybe<&1, A.Service> <- report(owned)
    return Unit{}
