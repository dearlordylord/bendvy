import Base
import ../../src/ecs/chunk-column.bend as C
import ../../src/ecs/chunk-query.bend as Q
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as L

type First is Data:
  First{}
type Second is Data:
  Second{}
type Input is Type:
  Input{token:Array<U32>,step:U32}
type Output is Type:
  Output{token:Array<U32>,value:U32}
def project(owner:Input) -> Input & U32:
  match owner:
    case Input{token,+step}: (Input{token,step},step)
def error(failed:Bool) -> Maybe<&2,String>:
  match failed:
    case True{}: Some{"handled"}
    case False{}: None{}
def updated(index:U32,value:U32,result:Array<U32> & U32) -> Output & Maybe<&2,String>:
  match result:
    case (token,id): (Output{Array.set(U32,token,0,U32.add(id,1)),value},error(U32.is_eq(index,1)))
def body(index:U32,step:U32,owner:Output) -> Output & Maybe<&2,String>:
  match owner:
    case Output{token,value}: updated(index,U32.add(value,step),Array.get(U32,token,0))
def input_inserted(~S:Data,result:C.SwapOutcome<S,Input>) -> C.Column<S,Input>:
  match result:
    case C.Accepted{column,_}: column
    case C.Rejected{column,_}: column
def output_inserted(~S:Data,result:C.SwapOutcome<S,Output>) -> C.Column<S,Output>:
  match result:
    case C.Accepted{column,_}: column
    case C.Rejected{column,_}: column
def inputs(~S:Data) -> C.Column<S,Input>:
  input_inserted(~S,C.swap(~S,~Input,input_inserted(~S,C.swap(~S,~Input,C.ensure(~S,~Input,C.empty(~S,~Input),32),1,Some{Input{ALeaf{501},3}})),17,Some{Input{ALeaf{502},5}}))
def outputs(~S:Data) -> C.Column<S,Output>:
  output_inserted(~S,C.swap(~S,~Output,output_inserted(~S,C.swap(~S,~Output,output_inserted(~S,C.swap(~S,~Output,C.ensure(~S,~Output,C.empty(~S,~Output),32),1,Some{Output{ALeaf{101},10}})),17,Some{Output{ALeaf{202},20}})),31,Some{Output{ALeaf{303},30}}))
def output_projected(+value:U32,result:Array<U32> & U32) -> Output & String:
  match result:
    case (token,+id): (Output{token,value},U32.show(id) ++ ":" ++ U32.show(value))
def output_project(owner:Output) -> Output & String:
  match owner:
    case Output{token,value}: output_projected(value,Array.get(U32,token,0))
def input_projected(+step:U32,result:Array<U32> & U32) -> Input & String:
  match result:
    case (token,+id): (Input{token,step},U32.show(id) ++ ":" ++ U32.show(step))
def input_project(owner:Input) -> Input & String:
  match owner:
    case Input{token,step}: input_projected(step,Array.get(U32,token,0))
def text(value:Maybe<&2,String>) -> String:
  match value:
    case None{}: "empty"
    case Some{value}: value
def tick_text(value:Maybe<&2,Tick.Tick>) -> String:
  match value:
    case None{}: "absent"
    case Some{tick}: U32.show(Tick.low(tick))
def stamp_text(value:Maybe<&2,L.Stamp>) -> String:
  match value:
    case None{}: "out-of-range"
    case Some{L.Stamp{added,changed}}: tick_text(added) ++ "/" ++ tick_text(changed)
def final_stamp(~S:Data,prefix:String,result:C.Column<S,Output> & Maybe<&2,L.Stamp>) -> String:
  match result:
    case (_,stamp): prefix ++ "|stamp=" ++ stamp_text(stamp)
def final_empty(~S:Data,prefix:String,result:C.Column<S,Output> & Maybe<&2,String>) -> String:
  match result:
    case (column,value): final_stamp(~S,prefix ++ "," ++ text(value),C.lifecycle(~S,~Output,column,1))
def final_third(~S:Data,prefix:String,result:C.Column<S,Output> & Maybe<&2,String>) -> String:
  match result:
    case (column,value): final_empty(~S,prefix ++ "," ++ text(value),C.view(~S,~Output,~String,~output_project,column,8))
def final_second(~S:Data,prefix:String,result:C.Column<S,Output> & Maybe<&2,String>) -> String:
  match result:
    case (column,value): final_third(~S,prefix ++ "," ++ text(value),C.view(~S,~Output,~String,~output_project,column,31))
def final_first(~S:Data,prefix:String,result:C.Column<S,Output> & Maybe<&2,String>) -> String:
  match result:
    case (column,value): final_second(~S,prefix ++ "|write=" ++ text(value),C.view(~S,~Output,~String,~output_project,column,17))
def error_text(error:Q.Error<String>) -> String:
  match error:
    case Q.Error{index,value}: U32.show(index) ++ ":" ++ value
def final_read(~S:Data,prefix:String,write:C.Column<S,Output>,result:C.Column<S,Input> & Maybe<&2,String>) -> String:
  match result:
    case (_,value): final_first(~S,prefix ++ "|read=" ++ text(value),C.view(~S,~Output,~String,~output_project,write,1))
def final(~S:Data,result:Q.Run<S,Input,Output,String>) -> String:
  match result:
    case Q.Run{read,write,errors,aligned}: final_read(~S,"aligned=" ++ Bool.show(aligned) ++ "|errors=" ++ List.show(&2,Q.Error<String>,error_text,errors),write,C.view(~S,~Input,~String,~input_project,read,1))
def repeated(~S:Data,parallel:Bool,result:Q.Run<S,Input,Output,String>) -> String:
  match parallel result:
    case False{} Q.Run{read,write,_,_}: final(~S,Q.serial(~S,~Input,~Output,~U32,~String,~project,~body,read,write,0,Tick.Tick{0n,2}))
    case True{} Q.Run{read,write,_,_}: final(~S,Q.parallel(~S,~Input,~Output,~U32,~String,~project,~body,read,write,0,Tick.Tick{0n,2}))
def scenario(~S:Data,+parallel:Bool) -> String:
  match parallel:
    case False{}: repeated(~S,parallel,Q.serial(~S,~Input,~Output,~U32,~String,~project,~body,inputs(~S),outputs(~S),0,Tick.Tick{0n,1}))
    case True{}: repeated(~S,parallel,Q.parallel(~S,~Input,~Output,~U32,~String,~project,~body,inputs(~S),outputs(~S),0,Tick.Tick{0n,1}))
def refused() -> String:
  final(~First,Q.parallel(~First,~Input,~Output,~U32,~String,~project,~body,inputs(~First),output_inserted(~First,C.swap(~First,~Output,C.empty(~First,~Output),1,Some{Output{ALeaf{900},99}})),0,Tick.Tick{0n,1}))
def main() -> IO(Unit):
  IO.print(scenario(~First,False{}) ++ "\n" ++ scenario(~First,True{}) ++ "\n" ++ scenario(~Second,True{}) ++ "\n" ++ refused())
