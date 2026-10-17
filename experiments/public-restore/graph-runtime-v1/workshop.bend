import Base
import ./host.bend as Host
import ../basic-world-statefree-v1/factory.bend as Factory
def printed(text:String) -> IO(Unit):IO.print("Workshop\n" ++ text)
def main() -> IO(Unit):IO.bind(String,Unit,Host.run(~Factory.Workshop),printed)
