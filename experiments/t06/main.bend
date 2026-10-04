import Base
import ./core.bend as A
import ./systems.bend as S
import ./driver.bend as D
import ./setup.bend as I

def start(result: A.Store & String) -> IO(Unit):
  match result:
    case (s, text): D.execute("committed:" ++ text, "fail:result", "restored", A.prepare_two(~S.step, S.fail_first(), S.fail_second(), s))
def main() -> IO(Unit):
  start(A.observe(I.good()))
