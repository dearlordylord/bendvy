import Base
import ../../src/ecs/execution-reservation-task.bend as Effect
import ./payloads.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-command-local.bend as Local

def command_error(index:U32) -> Maybe<&2,String>:
  match index:
    case 1:Some{"after-enqueue"}
    case _:None{}
def authored(~S:Data,~O:Type,~commands:Local.Commands<O,S,P.Output>,+handle:W.Handle<S>,output:O,result:P.Output & Maybe<&2,String>) -> P.Output & (O & Maybe<&2,String>):
  match result:
    case (owner,_):(owner,(Local.insert_field(~O,~S,~P.Output,commands)(output,handle,P.Output{ALeaf{U32.add(1000,W.handle_index(~S,handle))},U32.add(600,W.handle_index(~S,handle))}),command_error(W.handle_index(~S,handle))))
def indexed(~S:Data,+handle:W.Handle<S>) -> W.Handle<S> & U32:(handle,W.handle_index(~S,handle))
def row_indexed(~S:Data,~O:Type,~commands:Local.Commands<O,S,P.Output>,step:U32,owner:P.Output,output:O,result:W.Handle<S> & U32) -> P.Output & (O & Maybe<&2,String>):
  match result:
    case (handle,index):authored(~S,~O,~commands,handle,output,P.update(index,step,owner))
def row(~S:Data,~Permit:Data,~O:Type,~commands:Local.Commands<O,S,P.Output>,handle:W.Handle<S>,step:U32,owner:P.Output,output:O) -> Effect.Task<S,Permit,P.Output & (O & Maybe<&2,String>)>:
  Effect.TDone{row_indexed(~S,~O,~commands,step,owner,output,indexed(~S,handle))}
