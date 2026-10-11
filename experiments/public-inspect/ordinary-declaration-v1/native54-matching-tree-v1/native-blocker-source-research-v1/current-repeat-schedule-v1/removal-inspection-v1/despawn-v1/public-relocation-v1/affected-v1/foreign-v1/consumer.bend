import Base
import ../../consumer-public.bend as C
import ../../observer-public.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-removal-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/removals.bend as Rm
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-despawn.bend as Clear
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
type First<S:Data> is Type:First{world:W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,reader:Rm.Reader<S,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Identity.Declaration<S,C.Payload>,Provision.left_select(~S,~C.Payload,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.left_select(~S,~C.Payload,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.leaf_select(~S,~C.Payload)))>,projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,status:String,output:String}
type Scene<S:Data> is Type:Scene{first:First<S>,second:C.Fixture<S>,handle:W.Handle<S>}
def second_reserved(~S:Data,first:First<S>,factory:W.Factory,result:W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> & W.Reservation<S>) -> Scene<S>:
  match result:
    case (world,W.Reserved{+handle}):Scene{first,C.activated(~S,factory,handle,True{},W.activate(~S,~Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,~Array<U32>,~Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,world,handle)),handle}
    case (world,W.ReservationRejected{_}):Scene{first,C.Refused{factory,world,None{},None{},"SecondReserve"},W.Handle{0,0}}
def second_created(~S:Data,first:First<S>,result:W.Creation<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>) -> Scene<S>:
  match result:
    case W.Created{factory,world}:second_reserved(~S,first,factory,W.reserve_id(~S,~Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,~Array<U32>,~Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,world))
    case W.CreateRejected{factory,resource}:Scene{first,C.CreateRejected{factory,resource},W.Handle{0,0}}
type Setup<S:Data> is Type:
  Ready{scene:Scene<S>}
  Failed{owner:C.Fixture<S>}
def setup_first(~S:Data,value:C.Fixture<S>) -> Setup<S>:
  match value:
    case C.Fixture{factory,world,reader,projection,status,output}:Ready{second_created(~S,First{world,reader,projection,status,output},W.create(~S,~Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,~Array<U32>,~Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,~C.empty(~S),factory,Array.new(U32,0n,17)))}
    case value:Failed{value}
def inspect_first_returned(~S:Data,reader:Rm.Reader<S,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Identity.Declaration<S,C.Payload>,Provision.left_select(~S,~C.Payload,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.left_select(~S,~C.Payload,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.leaf_select(~S,~C.Payload)))>,status:String,output:String,result:W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> & Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>) -> First<S>:
  (world,projection)=result
  First{world,reader,projection,status,output}
def inspect_first(~S:Data,first:First<S>) -> First<S>:
  match first:
    case First{world,reader,_,status,output}:inspect_first_returned(~S,reader,status,output,Cap.value_read(~W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,~Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,~C.inspection(~S),world))
def error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def status(value:W.Status) -> String:
  match value:
    case W.Accepted{}:"Accepted"
    case W.Rejected{reason}:"Rejected{" ++ error(reason) ++ "}"
def finished(~S:Data,reader:Rm.Reader<S,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Identity.Declaration<S,C.Payload>,Provision.left_select(~S,~C.Payload,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.left_select(~S,~C.Payload,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.leaf_select(~S,~C.Payload)))>,projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,message:String,result:Tx.Returned<W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,Unit>) -> First<S>:
  match result:
    case Tx.Returned{world,_}:First{world,reader,projection,message,""}
def counted(~S:Data,reader:Rm.Reader<S,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Identity.Declaration<S,C.Payload>,Provision.left_select(~S,~C.Payload,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.left_select(~S,~C.Payload,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.leaf_select(~S,~C.Payload)))>,projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,message:String,world:W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,undo:List<(W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> -> W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>)> & U32,commands:List<(W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> -> W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>)> & U32,events:List<&2,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> & U32) -> First<S>:
  (undo,u)=undo
  (commands,c)=commands
  (events,e)=events
  finished(~S,reader,projection,message ++ ";undo=" ++ U32.show(u) ++ ";commands=" ++ U32.show(c) ++ ";events=" ++ U32.show(e),Cmd.tx_finish(~S,~Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,~Array<U32>,~Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,~Unit,Tx.Tx{world,undo,commands,events},Tx.Success{}))
def count_data_return(~E:Data,head:E,returned:List<&2,E> & U32) -> List<&2,E> & U32:
  (tail,count)=returned
  (head <> tail,(count + 1 : U32))
def count_data(~E:Data,values:List<&2,E>) -> List<&2,E> & U32:
  match values:
    case []:([],0)
    case head <> tail:count_data_return(~E,head,count_data(~E,tail))
def result(~S:Data,reader:Rm.Reader<S,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Identity.Declaration<S,C.Payload>,Provision.left_select(~S,~C.Payload,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.left_select(~S,~C.Payload,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.leaf_select(~S,~C.Payload)))>,projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,returned:Tx.Tx<W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> & W.Status) -> First<S>:
  match returned:
    case (Tx.Tx{world,undo,commands,events},value):counted(~S,reader,projection,status(value),world,O.count(~(W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> -> W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>),undo),O.count(~(W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> -> W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>),commands),count_data(~Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,events))
def attempt(~S:Data,scene:Scene<S>) -> Scene<S>:
  match scene:
    case Scene{First{world,reader,projection,_,_},second,+handle}:Scene{result(~S,reader,projection,Clear.despawn(~S,~Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,~Array<U32>,~Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,~C.clear(~S),~C.aggregate(~S),Tx.begin(~W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,~Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,world),handle)),second,handle}
def observed_first(~S:Data,reader:Rm.Reader<S,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Identity.Declaration<S,C.Payload>,Provision.left_select(~S,~C.Payload,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.left_select(~S,~C.Payload,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Rm.Record<S,Identity.Declaration<S,C.Payload>>,~Provision.leaf_select(~S,~C.Payload)))>,+projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,C.Payload>>>>,+status:String,+output:String,returned:W.World<S,Product.Owner<Col.Column<S,C.Payload>,Col.Column<S,C.Payload>>,Array<U32>,Provision.Publication<Provision.Publication<Rm.Record<S,Identity.Declaration<S,C.Payload>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>,Rm.Record<S,Identity.Declaration<S,C.Payload>>>> & String) -> First<S> & String:
  match reader:
    case Rm.Reader{+namespace,+id,+name,+cursor}:
      (world,text)=returned
      (First{world,Rm.Reader{namespace,id,name,cursor},projection,status,output},text ++ ";reader=" ++ U32.show(namespace) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ Nat.show(cursor) ++ ";projection=" ++ O.projection(~S,projection) ++ ";status=" ++ status ++ ";output=" ++ output)

def observe_first(~S:Data,first:First<S>) -> First<S> & String:
  match first:
    case First{world,reader,projection,status,output}:observed_first(~S,reader,projection,status,output,O.world_text(~S,world))
def handle_text(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,id}:"Handle{" ++ U32.show(namespace) ++ "," ++ U32.show(id) ++ "}"
def observed_scene(~S:Data,+handle:W.Handle<S>,a:First<S> & String,b:C.Fixture<S> & String) -> Scene<S> & String:
  (first,a)=a
  (second,b)=b
  (Scene{first,second,handle},"foreignHandle=" ++ handle_text(~S,handle) ++ "\ntarget=" ++ a ++ "\nforeignOwner=" ++ b)
def observe(~S:Data,scene:Scene<S>) -> Scene<S> & String:
  match scene:
    case Scene{first,second,handle}:observed_scene(~S,handle,observe_first(~S,inspect_first(~S,first)),O.observe(~S,C.inspect(~S,second)))
def after(~S:Data,before:String,returned:Scene<S> & String) -> Scene<S> & String:
  (scene,text)=returned
  (scene,"before=" ++ before ++ "\nafter=" ++ text)
def before(~S:Data,returned:Scene<S> & String) -> Scene<S> & String:
  (scene,text)=returned
  after(~S,text,observe(~S,attempt(~S,scene)))
def detached(~S:Data,returned:Scene<S> & String) -> String:
  (_,text)=returned
  text
def failed_detached(~S:Data,returned:C.Fixture<S> & String) -> String:
  (_,text)=returned
  "SetupFailed=" ++ text
def run(~S:Data,value:Setup<S>) -> String:
  match value:
    case Ready{scene}:detached(~S,before(~S,observe(~S,scene)))
    case Failed{owner}:failed_detached(~S,O.observe(~S,owner))
