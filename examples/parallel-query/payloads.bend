import Base

type Input is Type:
  Input{token:Array<U32>,step:U32}
type Output is Type:
  Output{token:Array<U32>,value:U32}
type Resource is Type:
  Resource{token:Array<U32>}
def read(owner:Input) -> Input & U32:
  match owner:
    case Input{token,+step}: (Input{token,step},step)
def failure(failed:Bool) -> Maybe<&2,String>:
  match failed:
    case False{}: None{}
    case True{}: Some{"after-write"}
def updated(+value:U32,result:Array<U32> & U32) -> Output & Maybe<&2,String>:
  match result:
    case (token,id): (Output{Array.set(U32,token,0,U32.add(id,1)),value},failure(U32.is_eq(value,16)))
def update(index:U32,step:U32,owner:Output) -> Output & Maybe<&2,String>:
  match owner:
    case Output{token,value}: updated(U32.add(value,step),Array.get(U32,token,0))
def input_projected(+step:U32,result:Array<U32> & U32) -> Input & String:
  match result:
    case (token,id): (Input{token,step},U32.show(id) ++ ":" ++ U32.show(step))
def input(owner:Input) -> Input & String:
  match owner:
    case Input{token,step}: input_projected(step,Array.get(U32,token,0))
def output_projected(+value:U32,result:Array<U32> & U32) -> Output & String:
  match result:
    case (token,id): (Output{token,value},U32.show(id) ++ ":" ++ U32.show(value))
def output(owner:Output) -> Output & String:
  match owner:
    case Output{token,value}: output_projected(value,Array.get(U32,token,0))
