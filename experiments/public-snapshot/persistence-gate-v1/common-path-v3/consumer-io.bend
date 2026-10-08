import Base
import ./consumer.bend as Consumer
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(Consumer.output())
