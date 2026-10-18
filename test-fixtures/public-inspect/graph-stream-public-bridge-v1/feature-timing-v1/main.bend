import Base
import ./app.bend as Scenario

def run(count:Nat) -> IO(String): Scenario.run(count)
def main() -> IO(Unit): IO.print(Scenario.report(Scenario.lifecycle(~True{})))
