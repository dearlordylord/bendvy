import Base
import ./schedule.bend as S
def main() -> IO(Unit):
  IO.print(S.loop(S.inputs(), S.initial(), ""))
