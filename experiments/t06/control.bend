import Base
import ./core.bend as A
import ./systems.bend as S
import ./driver.bend as D
import ./setup.bend as I

def start(result: A.Store & String) -> IO(Unit):
  match result:
    case (s, text): D.execute("committed:" ++ text, "second:result", "final", A.prepare_two(~S.step, S.control_first(), S.control_second(), s))
def main() -> IO(Unit):
  start(A.observe(I.good()))
