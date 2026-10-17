import Base
import ./fixture.bend as F
import ./main.bend as Main

def printed(value:String) -> IO(Unit):IO.print("Workshop\n" ++ value)
def main() -> IO(Unit):IO.bind(String,Unit,Main.run(~F.Workshop),printed)
