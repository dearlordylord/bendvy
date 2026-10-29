import Base
import ../../src/ecs/execution-reservation-task.bend as Effect
import ./payloads.bend as P
import ./declarations.bend as D
import ./output-declaration.bend as Decl
import ./body.bend as Body
import ./command-row.bend as Row
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-system.bend as Sys

type User is Type:
  User{token:Array<U32>,runs:U32}
def completed(~H:Type,~O:Type,token:Array<U32>,runs:U32,result:H & (O & Q.Report<String>)) -> H & (O & (User & Sys.Completion<String,String>)):
  match result:
    case (scope,(output,Q.Completed{errors})):(scope,(output,(User{token,runs},Body.completion(errors))))
    case (scope,(output,Q.LayoutRefused{})):(scope,(output,(User{token,runs},Sys.BodyError{"query-refused","not-invoked"})))
def counted(~S:Data,~Permit:Data,~H:Type,~O:Type,~caps:Decl.Ops(~S,Permit,H,O),~commands:Local.Commands<O,S,P.Output>,scope:H,output:O,runs:U32,result:Array<U32> & U32) -> Effect.Task<S,Permit,H & (O & (User & Sys.Completion<String,String>))>:
  match result:
    case (token,id):Effect.TBind{H & (O & Q.Report<String>),Q.each_task_output(~S,~Permit,~H,~O,~String,caps)(scope,output),result=>Effect.TDone{completed(~H,~O,Array.set(U32,token,0,U32.add(id,1)),U32.add(runs,1),result)}}
def run(~S:Data,~Permit:Data,~H:Type,~O:Type,~caps:Decl.Ops(~S,Permit,H,O),~commands:Local.Commands<O,S,P.Output>,scope:H,output:O,user:User) -> Effect.Task<S,Permit,H & (O & (User & Sys.Completion<String,String>))>:
  match user:
    case User{token,runs}:counted(~S,~Permit,~H,~O,~caps,~commands,scope,output,runs,Array.get(U32,token,0))
