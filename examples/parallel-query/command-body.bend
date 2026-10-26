import Base
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
def counted(~S:Data,~H:Type,~O:Type,~caps:Decl.Ops(~S,H,O),~commands:Local.Commands<O,S,P.Output>,scope:H,output:O,runs:U32,result:Array<U32> & U32) -> H & (O & (User & Sys.Completion<String,String>)):
  match result:
    case (token,id):completed(~H,~O,Array.set(U32,token,0,U32.add(id,1)),U32.add(runs,1),Q.each_output(~S,~H,~O,~String,caps)(scope,output))
def run(~S:Data,~H:Type,~O:Type,~caps:Decl.Ops(~S,H,O),~commands:Local.Commands<O,S,P.Output>,scope:H,output:O,user:User) -> H & (O & (User & Sys.Completion<String,String>)):
  match user:
    case User{token,runs}:counted(~S,~H,~O,~caps,~commands,scope,output,runs,Array.get(U32,token,0))
