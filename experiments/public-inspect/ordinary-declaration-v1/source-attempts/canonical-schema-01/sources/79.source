import Base
import bundle-insert-adapter.bend as AD
import bundle-construction.bend as CS
import bundle-batch.bend as BT
import world.bend as W

# Additive command route: nominal public handles remain fixed before abstract H.
type Operation<S:Data> is Data:
  Spawn{}
  Insert{target:W.Handle<S>}
type Input<S:Data,Raw:Type> is Type:
  Input{operation:Operation<S>,raw:Raw}
type Output<S:Data,Raw:Type,Error:Data> is Type:
  Accepted{target:W.Handle<S>,spawned:Bool}
  Refused{raw:Raw,error:AD.Refusal<Error>}
def inserted(~S:Data,~Store:Type,~R:Type,~E:Data,~Packet:Type,~Context:Type,~Raw:Type,~Error:Data,~unpack:Packet -> Raw,context:Context,target:W.Handle<S>,result:BT.Inserted<S,Store,R,E,Packet>) -> AD.Owner<S,Store,R,E,Packet,Context> & Output<S,Raw,Error>:
  match result:
    case BT.Inserted{batch}: (AD.Owner{batch,context},Accepted{target,False{}})
    case BT.Refused{batch,packet,error}: (AD.Owner{batch,context},Refused{unpack(packet),AD.EntityRefused{error}})
def spawned(~S:Data,~Store:Type,~R:Type,~E:Data,~Packet:Type,~Context:Type,~Raw:Type,~Error:Data,~unpack:Packet -> Raw,context:Context,result:BT.Spawned<S,Store,R,E,Packet>) -> AD.Owner<S,Store,R,E,Packet,Context> & Output<S,Raw,Error>:
  match result:
    case BT.Spawned{batch,target}: (AD.Owner{batch,context},Accepted{target,True{}})
    case BT.SpawnRefused{batch,packet,error}: (AD.Owner{batch,context},Refused{unpack(packet),AD.EntityRefused{error}})
def enqueue(~S:Data,~Store:Type,~R:Type,~E:Data,~Packet:Type,~Context:Type,~Raw:Type,~Error:Data,~unpack:Packet -> Raw,batch:BT.Batch<S,Store,R,E,Packet>,context:Context,operation:Operation<S>,packet:Packet) -> AD.Owner<S,Store,R,E,Packet,Context> & Output<S,Raw,Error>:
  match operation:
    case Spawn{}: spawned(~S,~Store,~R,~E,~Packet,~Context,~Raw,~Error,~unpack,context,BT.spawn(~S,~Store,~R,~E,~Packet,batch,packet))
    case Insert{+target}: inserted(~S,~Store,~R,~E,~Packet,~Context,~Raw,~Error,~unpack,context,target,BT.insert(~S,~Store,~R,~E,~Packet,batch,target,packet))
def constructed(~S:Data,~Store:Type,~R:Type,~E:Data,~Packet:Type,~Context:Type,~Raw:Type,~Cooked:Type,~Error:Data,~pack:Cooked -> (Cooked -> Raw) -> Packet,~unpack:Packet -> Raw,batch:BT.Batch<S,Store,R,E,Packet>,operation:Operation<S>,result:CS.Staged<Context,Raw,Cooked,Error>) -> AD.Owner<S,Store,R,E,Packet,Context> & Output<S,Raw,Error>:
  match result:
    case CS.Failed{context,raw,positions}: (AD.Owner{batch,context},Refused{raw,AD.ConstructionRefused{positions}})
    case CS.Valid{context,cooked,undo,positions}: enqueue(~S,~Store,~R,~E,~Packet,~Context,~Raw,~Error,~unpack,batch,context,operation,pack(cooked,undo))
def request(~S:Data,~Store:Type,~R:Type,~E:Data,~Packet:Type,~Context:Type,~Raw:Type,~Cooked:Type,~Error:Data,~construct:Context -> Raw -> CS.Staged<Context,Raw,Cooked,Error>,~pack:Cooked -> (Cooked -> Raw) -> Packet,~unpack:Packet -> Raw,owner:AD.Owner<S,Store,R,E,Packet,Context>,input:Input<S,Raw>) -> AD.Owner<S,Store,R,E,Packet,Context> & Output<S,Raw,Error>:
  match owner input:
    case AD.Owner{batch,context} Input{operation,raw}: constructed(~S,~Store,~R,~E,~Packet,~Context,~Raw,~Cooked,~Error,~pack,~unpack,batch,operation,construct(context,raw))
