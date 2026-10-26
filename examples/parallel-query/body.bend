import Base
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/chunk-query.bend as Rows
import ../../src/ecs/execution-system.bend as Sys

type Local is Type:
  Local{token:Array<U32>,runs:U32}
def error_text(error:Rows.Error<String>) -> String:
  match error:
    case Rows.Error{index,value}: U32.show(index) ++ ":" ++ value
def completion(errors:List<&2,Rows.Error<String>>) -> Sys.Completion<String,String>:
  match errors:
    case []: Sys.Success{"[]"}
    case first <> rest: Sys.BodyError{"query-body",List.show(&2,Rows.Error<String>,error_text,first <> rest)}
def completed(~H:Type,token:Array<U32>,runs:U32,result:H & Q.Report<String>) -> H & (Local & Sys.Completion<String,String>):
  match result:
    case (scope,Q.Completed{errors}): (scope,(Local{token,runs},completion(errors)))
    case (scope,Q.LayoutRefused{}): (scope,(Local{token,runs},Sys.BodyError{"query-refused","not-invoked"}))
def counted(~S:Data,~H:Type,~caps:Q.Each<S,H,String>,scope:H,runs:U32,result:Array<U32> & U32) -> H & (Local & Sys.Completion<String,String>):
  match result:
    case (token,id): completed(~H,Array.set(U32,token,0,U32.add(id,1)),U32.add(runs,1),Q.each(~S,~H,~String,caps)(scope))
def run(~S:Data,~H:Type,~caps:Q.Each<S,H,String>,scope:H,local:Local) -> H & (Local & Sys.Completion<String,String>):
  match local:
    case Local{token,runs}: counted(~S,~H,~caps,scope,runs,Array.get(U32,token,0))
