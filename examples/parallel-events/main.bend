import Base
import ./scheduled.bend as Scenario

type SchemaA is Data:SchemaA{}
type SchemaB is Data:SchemaB{}
def affine(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def duplicated(+value:U32) -> U32 & U32:(value,value)
def reusable(value:U32) -> U32 & U32:duplicated(value)
def run_affine(~S:Data,native:Bool) -> IO(String):Scenario.run(~S,~Array<U32>,~affine,native,ALeaf{90},[ALeaf{101},ALeaf{102},ALeaf{103},ALeaf{104}])
def run_data(~S:Data,native:Bool) -> IO(String):Scenario.run(~S,~U32,~reusable,native,90,[101,102,103,104])
def a_affine_serial() -> IO(Unit):IO.bind(String,Unit,run_affine(~SchemaA,False{}),value=>IO.print("A-affine-serial=" ++ value))
def a_affine_native() -> IO(Unit):IO.bind(String,Unit,run_affine(~SchemaA,True{}),value=>IO.print("A-affine-native=" ++ value))
def b_affine_serial() -> IO(Unit):IO.bind(String,Unit,run_affine(~SchemaB,False{}),value=>IO.print("B-affine-serial=" ++ value))
def b_affine_native() -> IO(Unit):IO.bind(String,Unit,run_affine(~SchemaB,True{}),value=>IO.print("B-affine-native=" ++ value))
def a_data_serial() -> IO(Unit):IO.bind(String,Unit,run_data(~SchemaA,False{}),value=>IO.print("A-data-serial=" ++ value))
def a_data_native() -> IO(Unit):IO.bind(String,Unit,run_data(~SchemaA,True{}),value=>IO.print("A-data-native=" ++ value))
def b_data_serial() -> IO(Unit):IO.bind(String,Unit,run_data(~SchemaB,False{}),value=>IO.print("B-data-serial=" ++ value))
def b_data_native() -> IO(Unit):IO.bind(String,Unit,run_data(~SchemaB,True{}),value=>IO.print("B-data-native=" ++ value))
def data_runs() -> IO(Unit):IO.bind(Unit,Unit,a_data_serial(),_=>IO.bind(Unit,Unit,a_data_native(),_=>IO.bind(Unit,Unit,b_data_serial(),_=>b_data_native())))
def affine_runs() -> IO(Unit):IO.bind(Unit,Unit,a_affine_serial(),_=>IO.bind(Unit,Unit,a_affine_native(),_=>IO.bind(Unit,Unit,b_affine_serial(),_=>IO.bind(Unit,Unit,b_affine_native(),_=>data_runs()))))
def main() -> IO(Unit):affine_runs()
