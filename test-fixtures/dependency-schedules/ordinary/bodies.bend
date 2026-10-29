import Base
import ./schema.bend as Schema
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/execution-system.bend as Sys
import ../../../src/ecs/dependency-executor.bend as Exec

def writer_returned(~H:Type,local:Schema.Local,result:H & U32) -> H & (Schema.Local & Sys.Completion<String,U32>):
  match local result:
    case Schema.Local{token,runs}, (scope,value):(scope,(Schema.Local{token,U32.add(runs,1)},Sys.BodyError{"body",value}))
def writer(~H:Type,~caps:Schema.Write()(H),scope:H,local:Schema.Local) -> H & (Schema.Local & Sys.Completion<String,U32>):
  writer_returned(~H,local,Access.resource_modify_field(~H,~Schema.Counter,~U32,caps)(Schema.increment,scope))
def read_value(~H:Type,cap:Schema.Read()(H),scope:H) -> H & U32:
  match cap:
    case Access.ResourceRead{get}:get(scope)
def reader_returned(~H:Type,local:Schema.Local,result:H & U32) -> H & (Schema.Local & Sys.Completion<String,U32>):
  match local result:
    case Schema.Local{token,runs}, (scope,value):(scope,(Schema.Local{token,U32.add(runs,1)},Sys.Success{value}))
def reader(~H:Type,~caps:Schema.Read()(H),scope:H,local:Schema.Local) -> H & (Schema.Local & Sys.Completion<String,U32>):
  reader_returned(~H,local,read_value(~H,caps,scope))
def positive_returned(~H:Type,local:Schema.Local,result:H & U32) -> H & (Schema.Local & Sys.Completion<String,Bool>):
  match local result:
    case Schema.Local{token,runs}, (scope,value):(scope,(Schema.Local{token,U32.add(runs,1)},Sys.Success{U32.is_lt(0,value)}))
def positive(~H:Type,~caps:Schema.Read()(H),scope:H,local:Schema.Local) -> H & (Schema.Local & Sys.Completion<String,Bool>):
  positive_returned(~H,local,read_value(~H,caps,scope))
def changing_status(runs:U32) -> Sys.Completion<String,Bool>:
  match runs:
    case 0:Sys.Success{False{}}
    case 1:Sys.BodyError{"condition",False{}}
    case _ :Sys.Success{True{}}
def changing(~H:Type,~caps:Schema.Read()(H),scope:H,local:Schema.Local) -> H & (Schema.Local & Sys.Completion<String,Bool>):
  match local:
    case Schema.Local{token,+runs}:(scope,(Schema.Local{token,U32.add(runs,1)},changing_status(runs)))
def handle(owner:Schema.Handler,error:String) -> Schema.Handler & Exec.Handling:
  match owner:
    case Schema.Handler{token,errors}:(Schema.Handler{token,List.append(&2,String,errors,[error])},Exec.Continue{})
