import Base
import ../scheduled.bend as Scenario
import ../payloads.bend as P

def run(native:Bool) -> IO(String):Scenario.run(~P.SchemaA,~Array<U32>,~P.affine,native,ALeaf{90},[ALeaf{101},ALeaf{102},ALeaf{103},ALeaf{104}])
def serial() -> IO(Unit):IO.bind(String,Unit,run(False{}),value=>IO.print("A-affine-serial=" ++ value))
def native() -> IO(Unit):IO.bind(String,Unit,run(True{}),value=>IO.print("A-affine-native=" ++ value))
def main() -> IO(Unit):IO.bind(Unit,Unit,serial(),_=>native())
