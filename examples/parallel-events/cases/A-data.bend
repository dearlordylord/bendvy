import Base
import ../scheduled.bend as Scenario
import ../payloads.bend as P

def run(native:Bool) -> IO(String):Scenario.run(~P.SchemaA,~U32,~P.reusable,native,90,[101,102,103,104])
def serial() -> IO(Unit):IO.bind(String,Unit,run(False{}),value=>IO.print("A-data-serial=" ++ value))
def native() -> IO(Unit):IO.bind(String,Unit,run(True{}),value=>IO.print("A-data-native=" ++ value))
def main() -> IO(Unit):IO.bind(Unit,Unit,serial(),_=>native())
