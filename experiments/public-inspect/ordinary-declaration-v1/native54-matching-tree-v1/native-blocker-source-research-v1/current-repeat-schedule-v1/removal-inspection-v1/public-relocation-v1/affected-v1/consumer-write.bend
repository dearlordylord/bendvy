import Base
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-removal-provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-removal.bend as Access
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-removal.bend as Operation
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/removals.bend as Rm
import /workspace/formal-proofs/bendvy/src/ecs/structural.bend as St
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd

type A is Data:A{}
type Other is Data:Other{}
type Token is Data:Token{}
type Payload is Type:Payload{array:Array<U32>}
def view_return(result:Array<U32> & U32) -> Payload & U32:
  (array,value)=result
  (Payload{array},value)
def view(value:Payload) -> Payload & U32:
  match value:
    case Payload{array}:view_return(Array.get(U32,array,0))
def take_left(~S:Data,value:Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>) -> Col.Column<S,Payload> & Col.Column<S,Payload>:
  match value:
    case Product.Owner{first,second}:(second,first)
def put_left(~S:Data,second:Col.Column<S,Payload>,first:Col.Column<S,Payload>) -> Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>:Product.Owner{first,second}
def take_right(~S:Data,value:Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>) -> Col.Column<S,Payload> & Col.Column<S,Payload>:
  match value:
    case Product.Owner{first,second}:(first,second)
def put_right(~S:Data,first:Col.Column<S,Payload>,second:Col.Column<S,Payload>) -> Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>:Product.Owner{first,second}
def binding(~S:Data) -> B.Binding<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Col.Column<S,Payload>,Payload,U32,Token,take_left(~S),put_left(~S),view>:
  B.bind(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Col.Column<S,Payload>,~Payload,~U32,~Token,~take_left(~S),~put_left(~S),~view,Identity.component(~S,~Payload,"Position"))
def other_binding(~S:Data) -> B.Binding<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Col.Column<S,Payload>,Payload,U32,Token,take_right(~S),put_right(~S),view>:
  B.bind(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Col.Column<S,Payload>,~Payload,~U32,~Token,~take_right(~S),~put_right(~S),~view,Identity.component(~S,~Payload,"OtherPosition"))
def selection(~S:Data) -> Provision.Selection<S,Payload,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,Provision.left_inject(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_inject(~S,~Payload)),Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload))>:
  Provision.left(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_inject(~S,~Payload),~Provision.leaf_select(~S,~Payload),Provision.leaf(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Col.Column<S,Payload>,~Payload,~U32,~Token,~take_left(~S),~put_left(~S),~view,binding(~S)))
def inspection(~S:Data) -> Cap.ValueRead<W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>,Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>>>:
  Access.bind(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,~Payload,~Provision.left_inject(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_inject(~S,~Payload)),~Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload)),Access.write(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Col.Column<S,Payload>,~Payload,~U32,~Token,~take_left(~S),~put_left(~S),~view,binding(~S)),selection(~S))
type Fixture<S:Data> is Type:
  CreateRejected{factory:W.Factory,resource:Array<U32>}
  Fixture{factory:W.Factory,world:W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>,reader:Rm.Reader<S,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,Identity.Declaration<S,Payload>,Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload))>,projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>>,status:String,output:String}
  Refused{factory:W.Factory,world:W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>,reader:Maybe<&1,Rm.Reader<S,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,Identity.Declaration<S,Payload>,Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload))>>,incoming:Maybe<&1,Payload>,reason:String}
def empty(~S:Data,_:Unit) -> Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>:Product.Owner{Col.empty(~S,~Payload),Col.empty(~S,~Payload)}
def registered(~S:Data,factory:W.Factory,result:Rm.Registered<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,Identity.Declaration<S,Payload>,Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload))>) -> Fixture<S>:
  match result:
    case Rm.Registered{world,reader}:Fixture{factory,world,reader,None{},"Ready",""}
    case Rm.Rejected{world}:Refused{factory,world,None{},None{},"Registration"}
def second_seeded(~S:Data,factory:W.Factory,result:Cmp.Replacement<W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>,Payload>) -> Fixture<S>:
  match result:
    case Cmp.Replaced{world,_}:registered(~S,factory,Rm.register(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,~Identity.Declaration<S,Payload>,~Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload)),world,"PositionRemovals"))
    case Cmp.ReplaceRejected{world,incoming,_}:Refused{factory,world,None{},incoming,"SecondSeed"}
def first_seeded(~S:Data,factory:W.Factory,+handle:W.Handle<S>,result:Cmp.Replacement<W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>,Payload>) -> Fixture<S>:
  match result:
    case Cmp.Replaced{world,_}:second_seeded(~S,factory,Cmp.replace(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,~Col.Column<S,Payload>,~Payload,~U32,~Token,~take_right(~S),~put_right(~S),~view,B.family(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Col.Column<S,Payload>,~Payload,~U32,~Token,~take_right(~S),~put_right(~S),~view,other_binding(~S)),world,handle,Some{Payload{Array.new(U32,0n,43)}}))
    case Cmp.ReplaceRejected{world,incoming,_}:Refused{factory,world,None{},incoming,"FirstSeed"}
def activated(~S:Data,factory:W.Factory,+handle:W.Handle<S>,result:W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>> & W.Status) -> Fixture<S>:
  match result:
    case (world,W.Accepted{}):first_seeded(~S,factory,handle,Cmp.replace(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,~Col.Column<S,Payload>,~Payload,~U32,~Token,~take_left(~S),~put_left(~S),~view,B.family(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Col.Column<S,Payload>,~Payload,~U32,~Token,~take_left(~S),~put_left(~S),~view,binding(~S)),world,handle,Some{Payload{Array.new(U32,0n,42)}}))
    case (world,W.Rejected{_}):Refused{factory,world,None{},None{},"Activate"}
def reserved(~S:Data,factory:W.Factory,result:W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>> & W.Reservation<S>) -> Fixture<S>:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,factory,handle,W.activate(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,world,handle))
    case (world,W.ReservationRejected{_}):Refused{factory,world,None{},None{},"Reserve"}
def created(~S:Data,result:W.Creation<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>) -> Fixture<S>:
  match result:
    case W.Created{factory,world}:reserved(~S,factory,W.reserve_id(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,world))
    case W.CreateRejected{factory,resource}:CreateRejected{factory,resource}
def setup(~S:Data) -> Fixture<S>:created(~S,W.create(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,~empty(~S),W.factory(),Array.new(U32,0n,17)))
def inspected(~S:Data,factory:W.Factory,reader:Rm.Reader<S,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,Identity.Declaration<S,Payload>,Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload))>,status:String,output:String,result:W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>> & Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>>) -> Fixture<S>:
  (world,projection)=result
  Fixture{factory,world,reader,projection,status,output}
def inspect(~S:Data,value:Fixture<S>) -> Fixture<S>:
  match value:
    case Fixture{factory,world,reader,_,status,output}:inspected(~S,factory,reader,status,output,Cap.value_read(~W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>,~Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>>,~inspection(~S),world))
    case value: value

def committed(~S:Data,factory:W.Factory,reader:Rm.Reader<S,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,Identity.Declaration<S,Payload>,Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload))>,projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>>,result:Tx.Returned<W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>,Unit>) -> Fixture<S>:
  match result:
    case Tx.Returned{world,_}:Fixture{factory,W.barrier(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,world),reader,projection,"Removed",""}
def removed(~S:Data,factory:W.Factory,reader:Rm.Reader<S,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,Identity.Declaration<S,Payload>,Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload))>,projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>>,result:Operation.Returned<Tx.Tx<W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>,Payload>) -> Fixture<S>:
  match result:
    case Operation.Queued{St.Queued{tx}}:committed(~S,factory,reader,projection,Cmd.tx_finish(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,~Unit,tx,Tx.Success{}))
    case Operation.Queued{St.QueueRejected{Tx.Tx{world,_,_,_},incoming,_}}:Refused{factory,world,Some{reader},incoming,"StructuralRejected"}
    case Operation.SelectionRejected{Tx.Tx{world,_,_,_}}:Refused{factory,world,Some{reader},None{},"SelectionRejected"}
def remove_named(~S:Data,factory:W.Factory,reader:Rm.Reader<S,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,Identity.Declaration<S,Payload>,Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload))>,projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>>,named:W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>> & U32) -> Fixture<S>:
  (world,namespace)=named
  removed(~S,factory,reader,projection,Operation.remove(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,~Col.Column<S,Payload>,~Payload,~U32,~Token,~take_left(~S),~put_left(~S),~view,~Provision.left_inject(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_inject(~S,~Payload)),~Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload)),~binding(~S),~selection(~S),Tx.begin(~W.World<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,world),W.Handle{namespace,1}))
def remove(~S:Data,value:Fixture<S>) -> Fixture<S>:
  match value:
    case Fixture{factory,world,reader,projection,_,_}:remove_named(~S,factory,reader,projection,W.namespace(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,world))
    case value:value

def record_text(~S:Data,value:Rm.Record<S,Identity.Declaration<S,Payload>>) -> String:
  match value:
    case Rm.Removed{W.Handle{ns,id},Identity.Declaration{key}}:"Removed{" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ key ++ "}"
    case Rm.Despawned{W.Handle{ns,id}}:"Despawned{" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "}"
def consume(~S:Data,values:List<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>) -> Result<&2,&1,Unit,String>:
  Done{List.show(~&2,~Rm.Record<S,Identity.Declaration<S,Payload>>,~record_text(~S),values)}
def reader_returned(~S:Data,factory:W.Factory,projection:Maybe<&2,List<&2,Rm.Record<S,Identity.Declaration<S,Payload>>>>,result:Rm.Run<S,Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,Array<U32>,Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,Identity.Declaration<S,Payload>,Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload)),Unit,String>) -> Fixture<S>:
  match result:
    case Rm.Completed{reader,Sys.Succeeded{world,output}}:Fixture{factory,world,reader,projection,"ReadSucceeded",output}
    case Rm.Completed{reader,Sys.Failed{world,_}}:Fixture{factory,world,reader,projection,"ReadFailed",""}
    case Rm.Invalid{reader,world}:Fixture{factory,world,reader,projection,"ReaderInvalid",""}
def read(~S:Data,value:Fixture<S>) -> Fixture<S>:
  match value:
    case Fixture{factory,world,reader,projection,_,_}:reader_returned(~S,factory,projection,Rm.run(~S,~Product.Owner<Col.Column<S,Payload>,Col.Column<S,Payload>>,~Array<U32>,~Provision.Publication<Rm.Record<S,Identity.Declaration<S,Payload>>,Rm.Record<S,Identity.Declaration<S,Payload>>>,~Identity.Declaration<S,Payload>,~Provision.left_select(~S,~Payload,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Rm.Record<S,Identity.Declaration<S,Payload>>,~Provision.leaf_select(~S,~Payload)),~Unit,~String,~consume(~S),reader,world))
    case value:value
