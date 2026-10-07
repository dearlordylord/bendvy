import Base
import application.bend as A

type Workshop is Data:
  Workshop{}
type Other is Data:
  Other{}
def main() -> IO(Unit):
  IO.print(A.run(~Workshop) ++ "\n" ++ A.run(~Other) ++ "\n" ++ A.invalid(~Workshop) ++ "\n" ++ A.invalid(~Other) ++ "\n" ++ A.undeclared(~Workshop) ++ "\n" ++ A.undeclared(~Other))
