import Base
import ./core.bend as Core

def main() -> IO(Unit):
  IO.print(U32.show(Core.answer(6)))
