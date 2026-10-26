import Base
import ./payloads.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-command-local.bend as Local

def authored(~S:Data,~O:Type,~commands:Local.Commands<O,S,P.Output>,+handle:W.Handle<S>,output:O,result:P.Output & Maybe<&2,String>) -> P.Output & (O & Maybe<&2,String>):
  match result:
    case (owner,error):(owner,(Local.insert_field(~O,~S,~P.Output,commands)(output,handle,P.Output{ALeaf{U32.add(1000,W.handle_index(~S,handle))},U32.add(600,W.handle_index(~S,handle))}),error))
def indexed(~S:Data,+handle:W.Handle<S>) -> W.Handle<S> & U32:(handle,W.handle_index(~S,handle))
def row_indexed(~S:Data,~O:Type,~commands:Local.Commands<O,S,P.Output>,step:U32,owner:P.Output,output:O,result:W.Handle<S> & U32) -> P.Output & (O & Maybe<&2,String>):
  match result:
    case (handle,index):authored(~S,~O,~commands,handle,output,P.update(index,step,owner))
def row(~S:Data,~O:Type,~commands:Local.Commands<O,S,P.Output>,handle:W.Handle<S>,step:U32,owner:P.Output,output:O) -> P.Output & (O & Maybe<&2,String>):
  row_indexed(~S,~O,~commands,step,owner,output,indexed(~S,handle))
