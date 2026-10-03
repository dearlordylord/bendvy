import Base
import ../rc1-query/api.bend as A
import ../rc1-query/schemas.bend as S
import ./payload.bend as V
import ./system.bend as C

def print_result(prefix: String, r: A.World<S.MotionToken, V.Payload> & String) -> IO(A.World<S.MotionToken, V.Payload>):
  match r:
    case (w, text):
      do IO<A.World<S.MotionToken, V.Payload>>:
        IO.print(prefix ++ text)
        return w
def observe(prefix: String, w: A.World<S.MotionToken, V.Payload>) -> IO(A.World<S.MotionToken, V.Payload>):
  print_result(prefix, A.query(~S.MotionToken, ~V.Payload, ~String, ~C.read, ~V.get, ~V.has, A.Required{}, w))
def main() -> IO(Unit):
  do IO<Unit>:
    w : A.World<S.MotionToken, V.Payload> <- observe("setup:", V.world())
    w : A.World<S.MotionToken, V.Payload> <- observe("read-again:", w)
    w : A.World<S.MotionToken, V.Payload> <- observe("step1:", V.writable(~C.step, w))
    w : A.World<S.MotionToken, V.Payload> <- observe("step2:", V.writable(~C.step, w))
    w : A.World<S.MotionToken, V.Payload> <- observe("step3:", V.writable(~C.step, w))
    w : A.World<S.MotionToken, V.Payload> <- observe("final-read:", w)
    return Unit{}
