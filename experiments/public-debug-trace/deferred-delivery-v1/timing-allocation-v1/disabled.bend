import Base
import ./host.bend as Host
import ../reader-query-context-v1/fixture.bend as F
def printed(value:String) -> IO(Unit):IO.print("Workshop\n" ++ value)
def main() -> IO(Unit):IO.bind(String,Unit,Host.run_mode(~F.Workshop,~False{}),printed)
