import Base
import ../main.bend as First
import ../../../../../public-schedules/named-app-v1/reader-provider-debug-v1/fixture.bend as Original
import beta/dump.bend as Second
import beta/fixture.bend as Beta
def second(_:Unit) -> IO(Unit):IO.print(Second.ready(Beta.setup()))
def main() -> IO(Unit):
  IO.bind(Unit,Unit,IO.print(First.ready(Original.setup())),second)
