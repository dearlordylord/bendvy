import Base
import ../common/column-observation.bend as Observe
import ../../src/ecs/chunk-column.bend as C
import ../../src/ecs/chunk-query.bend as Q
import ../../src/ecs/change-tick.bend as Tick

type Schema is Data:
  Schema{}
type Output is Type:
  Output{tokens:List<Array<U32>>}
def split(output:Output) -> Output & Output:(output,Output{[]})
def merge(left:Output,right:Output) -> Output:
  match left right:
    case Output{left} Output{right}:Output{List.append(&1,Array<U32>,left,right)}
def project(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def failure(index:U32) -> Maybe<&2,String>:
  match index:
    case 1:Some{"after-write"}
    case _:None{}
def authored(+index:U32,step:U32,output:Output,result:Array<U32> & U32) -> Array<U32> & (Output & Maybe<&2,String>):
  match output result:
    case Output{tokens} Tuple{owner,value}:(Array.set(U32,owner,0,U32.add(value,step)),(Output{ALeaf{index} <> tokens},failure(index)))
def body(_:Unit,index:U32,step:U32,owner:Array<U32>,output:Output) -> Array<U32> & (Output & Maybe<&2,String>):
  authored(index,step,output,Array.get(U32,owner,0))
def inserted(result:C.SwapOutcome<Schema,Array<U32>>) -> C.Column<Schema,Array<U32>>:
  match result:
    case C.Accepted{column,_}:column
    case C.Rejected{column,_}:column
def read() -> C.Column<Schema,Array<U32>>:
  inserted(C.swap(~Schema,~Array<U32>,inserted(C.swap(~Schema,~Array<U32>,inserted(C.swap(~Schema,~Array<U32>,C.ensure(~Schema,~Array<U32>,C.empty(~Schema,~Array<U32>),16),1,Some{ALeaf{3}})),9,Some{ALeaf{5}})),2,Some{ALeaf{7}}))
def write() -> C.Column<Schema,Array<U32>>:
  inserted(C.swap(~Schema,~Array<U32>,inserted(C.swap(~Schema,~Array<U32>,inserted(C.swap(~Schema,~Array<U32>,C.ensure(~Schema,~Array<U32>,C.empty(~Schema,~Array<U32>),16),1,Some{ALeaf{10}})),9,Some{ALeaf{20}})),3,Some{ALeaf{30}}))
def run(parallel:Bool,selection:Q.Selection) -> Q.OutputRun<Schema,Array<U32>,Array<U32>,Output,String>:
  Q.with_output(~Schema,~Array<U32>,~Array<U32>,~Output,~U32,~Unit,~String,~project,~body,~split,~merge,Unit{},read(),write(),Output{[ALeaf{900}]},0,Tick.Tick{0n,7},selection,parallel)
def no_rows() -> Q.OutputRun<Schema,Array<U32>,Array<U32>,Output,String>:run(True{},Q.Selected{[]})
def missing() -> Q.OutputRun<Schema,Array<U32>,Array<U32>,Output,String>:run(True{},Q.Selected{[2,3]})
def handled_error() -> Q.OutputRun<Schema,Array<U32>,Array<U32>,Output,String>:run(True{},Q.Selected{[1,9]})
def refused() -> Q.OutputRun<Schema,Array<U32>,Array<U32>,Output,String>:
  Q.with_output(~Schema,~Array<U32>,~Array<U32>,~Output,~U32,~Unit,~String,~project,~body,~split,~merge,Unit{},read(),C.empty(~Schema,~Array<U32>),Output{[ALeaf{901}]},0,Tick.Tick{0n,7},Q.All{},True{})

def value_shown(result:Array<U32> & U32) -> Array<U32> & String:
  match result:
    case (owner,value):(owner,U32.show(value))
def value(owner:Array<U32>) -> Array<U32> & String:value_shown(Array.get(U32,owner,0))
def token(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def tokens(values:List<Array<U32>>) -> List<&2,String>:
  match values:
    case []:[]
    case owner <> rest:token(Array.get(U32,owner,0)) <> tokens(rest)
def error(value:Q.Error<String>) -> String:
  match value:
    case Q.Error{index,text}:U32.show(index) ++ ":" ++ text
def shown(result:Q.OutputRun<Schema,Array<U32>,Array<U32>,Output,String>) -> String:
  match result:
    case Q.OutputRun{read,write,Output{output},errors,aligned}:"read=" ++ Observe.capacity_done(~Schema,~Array<U32>,~value,C.capacity(~Schema,~Array<U32>,read)) ++ ";write=" ++ Observe.capacity_done(~Schema,~Array<U32>,~value,C.capacity(~Schema,~Array<U32>,write)) ++ ";output=" ++ List.show(&2,String,text=>text,tokens(output)) ++ ";errors=" ++ List.show(&2,Q.Error<String>,error,errors) ++ ";aligned=" ++ Bool.pick(String,aligned,"true","false")
def main() -> IO(Unit):
  IO.print("parallel=" ++ shown(handled_error()) ++ "\nserial=" ++ shown(run(False{},Q.Selected{[1,9]})) ++ "\nempty=" ++ shown(no_rows()) ++ "\nmissing=" ++ shown(missing()) ++ "\nrefused=" ++ shown(refused()))
