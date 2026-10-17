import Base
import ./main.bend as Main
import ./fixture.bend as F
def printed(value:String) -> IO(Unit):IO.print(value)
def main() -> IO(Unit):IO.bind(String,Unit,Main.run(~F.Workshop),printed)
