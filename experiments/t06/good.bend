import Base
import ./core.bend as A
import ./systems.bend as S
import ./driver.bend as D
import ./setup.bend as I

def start(result: A.Store & String) -> IO(Unit):
  match result:
    case (s, text): D.execute("initial:" ++ text, "good:result", "committed", A.prepare_one(~S.step, S.good(), s))
def main() -> IO(Unit):
  start(A.observe(A.initial()))
