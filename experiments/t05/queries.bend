import Base
import ./fixture.bend as F

def digit(s: String) -> U32:
  match s:
    case SNil{}: 0
    case SCon{Chr{code}, _}: U32.sub(code, 48)
def run(args: List<String>) -> IO(Unit):
  match args:
    case Con{_, Con{stage, Con{mode, Con{entity, _}}}}: IO.print(F.query(digit(mode), F.setup(digit(stage))))
    case _: IO.print("invalid-arguments")
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    run(args)
