import Base
import ./main.bend as Scenario

def main() -> IO(Unit):
  do IO<Unit>:
    text : String <- Scenario.run(1n)
    IO.print(text)
