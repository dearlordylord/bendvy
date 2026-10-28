import Base
import ../../src/ecs/execution-reservation-task.bend as Effect
import ./payloads.bend as P
import ../../src/ecs/world.bend as W

def command_error(index:U32) -> Maybe<&2,String>:
  match index:
    case 1:Some{"after-enqueue"}
    case _:None{}
def finished(~S:Data,~Permit:Data,~O:Type,output:O,error:Maybe<&2,String>,result:P.Output & Maybe<&2,String>) -> Effect.Task<S,Permit,P.Output & (O & Maybe<&2,String>)>:
  match result:
    case (owner,_):Effect.TDone{(owner,(output,error))}
def indexed(~S:Data,+handle:W.Handle<S>) -> W.Handle<S> & U32:(handle,W.handle_index(~S,handle))
def row_indexed(~S:Data,~Permit:Data,~O:Type,~insert:O -> W.Handle<S> -> P.Output -> O,~remove:O -> W.Handle<S> -> O,~despawn:O -> W.Handle<S> -> O,step:U32,owner:P.Output,output:O,result:W.Handle<S> & U32) -> Effect.Task<S,Permit,P.Output & (O & Maybe<&2,String>)>:
  match result:
    case (+handle,+index):
      match index:
        case 1:finished(~S,~Permit,~O,insert(remove(output,handle),handle,P.Output{ALeaf{1001},601}),command_error(index),P.update(index,step,owner))
        case 17:finished(~S,~Permit,~O,insert(despawn(insert(output,handle,P.Output{ALeaf{1017},617}),handle),handle,P.Output{ALeaf{2017},717}),command_error(index),P.update(index,step,owner))
        case _:finished(~S,~Permit,~O,insert(output,handle,P.Output{ALeaf{U32.add(1000,index)},U32.add(600,index)}),command_error(index),P.update(index,step,owner))
def row(~S:Data,~Permit:Data,~O:Type,~insert:O -> W.Handle<S> -> P.Output -> O,~remove:O -> W.Handle<S> -> O,~despawn:O -> W.Handle<S> -> O,handle:W.Handle<S>,step:U32,owner:P.Output,output:O) -> Effect.Task<S,Permit,P.Output & (O & Maybe<&2,String>)>:
  row_indexed(~S,~Permit,~O,~insert,~remove,~despawn,step,owner,output,indexed(~S,handle))
