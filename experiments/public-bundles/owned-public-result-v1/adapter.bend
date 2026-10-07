import Base
import ../production-candidate/transactions/batch.bend as BT
import ../constructor-stage.bend as CS
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/schema-fragments.bend as SF

type Input<S:Data,Raw:Type> is Type:
  Input{target:W.Handle<S>,raw:Raw}
type Refusal<Error:Data> is Data:
  ConstructionRefused{positions:List<&2,Maybe<&2,Error>>}
  EntityRefused{error:W.WorldError}
  DeclarationRefused{error:SF.Error}
type Output<Raw:Type,Error:Data> is Type:
  Accepted{}
  Refused{raw:Raw,error:Refusal<Error>}
type Owner<S:Data,Store:Type,R:Type,E:Data,Packet:Type,Context:Type> is Type:
  Owner{batch:BT.Batch<S,Store,R,E,Packet>,context:Context}
def inserted(~S:Data,~Store:Type,~R:Type,~E:Data,~Packet:Type,~Context:Type,~Raw:Type,~Error:Data,~unpack:Packet -> Raw,context:Context,result:BT.Inserted<S,Store,R,E,Packet>) -> Owner<S,Store,R,E,Packet,Context> & Output<Raw,Error>:
  match result:
    case BT.Inserted{batch}: (Owner{batch,context},Accepted{})
    case BT.Refused{batch,packet,error}: (Owner{batch,context},Refused{unpack(packet),EntityRefused{error}})
def constructed(~S:Data,~Store:Type,~R:Type,~E:Data,~Packet:Type,~Context:Type,~Raw:Type,~Cooked:Type,~Error:Data,~pack:Cooked -> (Cooked -> Raw) -> Packet,~unpack:Packet -> Raw,batch:BT.Batch<S,Store,R,E,Packet>,target:W.Handle<S>,result:CS.Staged<Context,Raw,Cooked,Error>) -> Owner<S,Store,R,E,Packet,Context> & Output<Raw,Error>:
  match result:
    case CS.Failed{context,raw,positions}: (Owner{batch,context},Refused{raw,ConstructionRefused{positions}})
    case CS.Valid{context,cooked,undo,positions}: inserted(~S,~Store,~R,~E,~Packet,~Context,~Raw,~Error,~unpack,context,BT.insert(~S,~Store,~R,~E,~Packet,batch,target,pack(cooked,undo)))
def request(~S:Data,~Store:Type,~R:Type,~E:Data,~Packet:Type,~Context:Type,~Raw:Type,~Cooked:Type,~Error:Data,~construct:Context -> Raw -> CS.Staged<Context,Raw,Cooked,Error>,~pack:Cooked -> (Cooked -> Raw) -> Packet,~unpack:Packet -> Raw,owner:Owner<S,Store,R,E,Packet,Context>,input:Input<S,Raw>) -> Owner<S,Store,R,E,Packet,Context> & Output<Raw,Error>:
  match owner input:
    case Owner{batch,context} Input{target,raw}: constructed(~S,~Store,~R,~E,~Packet,~Context,~Raw,~Cooked,~Error,~pack,~unpack,batch,target,construct(context,raw))
