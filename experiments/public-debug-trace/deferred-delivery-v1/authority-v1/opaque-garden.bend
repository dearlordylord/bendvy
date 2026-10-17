import Base
import ./opaque-host.bend as Host
import ../reader-query-context-v1/fixture.bend as F
def printed(value:String) -> IO(Unit):IO.print("Garden\n" ++ value)
def main() -> IO(Unit):IO.bind(String,Unit,Host.run(~F.Garden),printed)
