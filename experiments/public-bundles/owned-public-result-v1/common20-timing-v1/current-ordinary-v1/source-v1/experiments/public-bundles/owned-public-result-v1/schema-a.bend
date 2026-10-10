import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Owned
import /workspace/formal-proofs/bendvy/src/ecs/bundle-provider.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/bundle-insert-adapter.bend as AD
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as BPack
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/constructor-control.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as CS
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/combined-control.bend as A
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/production-candidate/schema-a.bend as Previous
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/source-v1/experiments/public-bundles/production-candidate/transactions/schema-a.bend as Existing
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as BT
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF

def Raw() -> Type: BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>
def Cooked() -> Type: BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>>
def Input() -> Type: AD.Input<A.Schema,Raw()>
def Output() -> Type: AD.Output<Raw(),String>
def Owner() -> Type: AD.Owner<A.Schema,A.Store,A.Mail,U32,A.Packet,K.Context>
def pack(cooked:Cooked(),undo:Cooked() -> Raw()) -> A.Packet: A.Packet{cooked,undo}
def unpack(packet:A.Packet) -> Raw():
  match packet:
    case A.Packet{cooked,undo}: undo(cooked)
def request(owner:Owner(),input:Input()) -> Owner() & Output():
  AD.request(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,~K.Context,~Raw(),~Cooked(),~String,~K.stage_0,~pack,~unpack,owner,input)

# The gameplay callback sees H abstractly, yet really owns returned Raw results.
type Args is Type:
  Args{input:Input(),retryTarget:W.Handle<A.Schema>,retry:Bool,declared:Bool}
type GameResult is Type:
  GameResult{result:Output(),first:Maybe<&2,AD.Refusal<String>>,returned:String}
def repaired(raw:Raw()) -> Raw():
  match raw:
    case BPack.Pack{K.Raw{_,a},BPack.Pack{K.Raw{_,v},BPack.Pack{K.Raw{_,tag},BPack.Pack{K.Raw{_,queue},Unit{}}}}}: BPack.Pack{K.Raw{True{},a},BPack.Pack{K.Raw{True{},v},BPack.Pack{K.Raw{True{},tag},BPack.Pack{K.Raw{True{},queue},Unit{}}}}}
def raw_3_seen(+valid:Bool,seen:K.QueueOwner & String) -> BPack.Pack<K.Raw<K.QueueOwner>,Unit> & String:
  match seen:
    case (owner,text): (BPack.Pack{K.Raw{valid,owner},Unit{}},Bool.show(valid) ++ ":" ++ text ++ "/end")
def raw_3(raw:BPack.Pack<K.Raw<K.QueueOwner>,Unit>) -> BPack.Pack<K.Raw<K.QueueOwner>,Unit> & String:
  match raw:
    case BPack.Pack{K.Raw{valid,owner},Unit{}}: raw_3_seen(valid,K.queue_read(owner))
def raw_2_seen(+valid:Bool,tag:K.Tag,seen:BPack.Pack<K.Raw<K.QueueOwner>,Unit> & String) -> BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>> & String:
  match seen:
    case (tail,text): (BPack.Pack{K.Raw{valid,tag},tail},Bool.show(valid) ++ ":tag/" ++ text)
def raw_2(raw:BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>) -> BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>> & String:
  match raw:
    case BPack.Pack{K.Raw{valid,tag},tail}: raw_2_seen(valid,tag,raw_3(tail))
def raw_1_seen(+valid:Bool,+value:U32,seen:BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>> & String) -> BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>> & String:
  match seen:
    case (tail,text): (BPack.Pack{K.Raw{valid,value},tail},Bool.show(valid) ++ ":" ++ U32.show(value) ++ "/" ++ text)
def raw_1(raw:BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>) -> BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>> & String:
  match raw:
    case BPack.Pack{K.Raw{valid,value},tail}: raw_1_seen(valid,value,raw_2(tail))
def raw_0_tail(+valid:Bool,array:Array<U32>,text:String,seen:BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>> & String) -> Raw() & String:
  match seen:
    case (tail,tailText): (BPack.Pack{K.Raw{valid,array},tail},Bool.show(valid) ++ ":" ++ text ++ "/" ++ tailText)
def raw_0_seen(+valid:Bool,tail:BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>,seen:Array<U32> & String) -> Raw() & String:
  match seen:
    case (array,text): raw_0_tail(valid,array,text,raw_1(tail))
def raw_0(raw:Raw()) -> Raw() & String:
  match raw:
    case BPack.Pack{K.Raw{valid,array},tail}: raw_0_seen(valid,tail,K.array_read(array))

def retry_done(~H:Type,first:AD.Refusal<String>,returned:String,result:H & Output()) -> H & GameResult:
  match result:
    case (ctx,out): (ctx,GameResult{out,Some{first},returned})
def retry_seen(~H:Type,~cap:Owned.OwnedRequest<H,Input(),Output()>,ctx:H,target:W.Handle<A.Schema>,retry:Bool,+error:AD.Refusal<String>,seen:Raw() & String) -> H & GameResult:
  match retry seen:
    case False{}, (raw,text): (ctx,GameResult{AD.Refused{raw,error},Some{error},text})
    case True{}, (raw,text): retry_done(~H,error,text,Owned.owned_request(~H,~Input(),~Output(),~cap,ctx,AD.Input{target,repaired(raw)}))
def requested(~H:Type,~cap:Owned.OwnedRequest<H,Input(),Output()>,target:W.Handle<A.Schema>,retry:Bool,result:H & Output()) -> H & GameResult:
  match result:
    case (ctx,AD.Accepted{}): (ctx,GameResult{AD.Accepted{},None{},""})
    case (ctx,AD.Refused{raw,error}): retry_seen(~H,~cap,ctx,target,retry,error,raw_0(raw))
def body(~H:Type,~cap:Owned.OwnedRequest<H,Input(),Output()>,args:Args,ctx:H) -> H & GameResult:
  match args:
    case Args{input,target,retry,_}: requested(~H,~cap,target,retry,Owned.owned_request(~H,~Input(),~Output(),~cap,ctx,input))
def provided(owners:Owner() & Args) -> Owner() & GameResult:
  match owners:
    case (owner,args): Public.provide_owned(~Owner(),~Input(),~Output(),~Args,~GameResult,~request,~body,args,owner)
def declaration_returned(owner:Owner(),+error:SF.Error,seen:Raw() & String) -> Owner() & GameResult:
  match seen:
    case (raw,text): (owner,GameResult{AD.Refused{raw,AD.DeclarationRefused{error}},Some{AD.DeclarationRefused{error}},text})
def bound(result:SF.Bound<A.Schema,Owner() & Args,Owner() & GameResult>) -> Owner() & GameResult:
  match result:
    case SF.Built{output}: output
    case SF.BindRejected{error,SF.Fragment{_,(owner,Args{AD.Input{_,raw},_,_,_})}}: declaration_returned(owner,error,raw_0(raw))
def declared_entries(declared:Bool) -> List<&2,SF.Entry<A.Schema>>:
  match declared:
    case True{}: Existing.available()
    case False{}: []
def invoked_declaration(owner:Owner(),args:Args,+declared:Bool) -> Owner() & GameResult:
  bound(Public.provision_declared(~A.Schema,~(Owner() & Args),~(Owner() & GameResult),~provided,SF.Fragment{declared_entries(declared),(owner,args)},Existing.required()))
def invoke(owner:Owner(),args:Args) -> Owner() & GameResult:
  match args:
    case Args{input,target,retry,+declared}: invoked_declaration(owner,Args{input,target,retry,declared},declared)

def packet_seen(undo:Cooked() -> Raw(),seen:Cooked() & String) -> A.Packet & String:
  match seen:
    case (cooked,text): (A.Packet{cooked,undo},text)
def packet_read(packet:A.Packet) -> A.Packet & String:
  match packet:
    case A.Packet{cooked,undo}: packet_seen(undo,K.cooked_read_0(cooked))
def prepared_packet(+target:W.Handle<A.Schema>,+position:Nat,tail:List<BT.Prepared<A.Schema,A.Packet>>,texts:List<&2,String>,seen:A.Packet & String) -> List<BT.Prepared<A.Schema,A.Packet>> & List<&2,String>:
  match seen:
    case (packet,text): (BT.Prepared{target,packet,position} <> tail,(Nat.show(position) ++ ":" ++ text) <> texts)
def prepared_head(head:BT.Prepared<A.Schema,A.Packet>,seen:List<BT.Prepared<A.Schema,A.Packet>> & List<&2,String>) -> List<BT.Prepared<A.Schema,A.Packet>> & List<&2,String>:
  match head seen:
    case BT.ReservationReceipt{+target}, (tail,texts): (BT.ReservationReceipt{target} <> tail,"receipt" <> texts)
    case BT.Prepared{+target,packet,+position}, (tail,texts): prepared_packet(target,position,tail,texts,packet_read(packet))
def prepared_read(owners:List<BT.Prepared<A.Schema,A.Packet>>) -> List<BT.Prepared<A.Schema,A.Packet>> & List<&2,String>:
  match owners:
    case []: ([],[])
    case head <> tail: prepared_head(head,prepared_read(tail))
type Delivery is Type:
  Delivery{context:K.Context,result:GameResult,prepared:List<&2,String>}
def finished(result:BT.Finished<A.Schema,A.Store,A.Mail,U32,A.Packet,Unit>,context:K.Context,output:GameResult,prepared:List<&2,String>) -> Sy.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Delivery>:
  match result:
    case BT.Committed{world}: Sy.Succeeded{world,Delivery{context,output,prepared}}
    case BT.Failed{world,packets,error}: Sy.Failed{world,error}
def prepared_finish(tx:T.Tx<W.World<A.Schema,A.Store,A.Mail,U32>,U32>,context:K.Context,output:GameResult,seen:List<BT.Prepared<A.Schema,A.Packet>> & List<&2,String>) -> Sy.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Delivery>:
  match seen:
    case (prepared,texts): finished(BT.finish(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,~Unit,~Previous.attempt,~Previous.recover,BT.Batch{tx,prepared},T.Success{}),context,output,texts)
def invoked(result:Owner() & GameResult) -> Sy.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Delivery>:
  match result:
    case (AD.Owner{BT.Batch{tx,prepared},context},output): prepared_finish(tx,context,output,prepared_read(prepared))
def runner(world:W.World<A.Schema,A.Store,A.Mail,U32>,args:Args) -> Sy.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Delivery>:
  invoked(invoke(AD.Owner{Existing.begin(world),K.context()},args))

def queued_result(~Out:Type,next:List<Array<U32>> -> List<&2,String> -> Out,result:List<Array<U32>> & List<&2,String>) -> Out:
  match result:
    case (owners,texts): next(owners,texts)
def installed_result(~Out:Type,next:List<A.Installed> -> List<&2,String> -> Out,result:List<A.Installed> & List<&2,String>) -> Out:
  match result:
    case (owners,texts): next(owners,texts)
def installed_head(head:A.Installed,result:List<A.Installed> & List<&2,String>) -> List<A.Installed> & List<&2,String>:
  match head result:
    case A.Installed{inverse,queued,undo}, (tail,texts): queued_result(~(List<A.Installed> & List<&2,String>),owners => values => (A.Installed{inverse,owners,undo} <> tail,List.show(&2,String,K.string_identity,values) <> texts),K.list_read(queued))
def installed_read(owners:List<A.Installed>) -> List<A.Installed> & List<&2,String>:
  match owners:
    case []: ([],[])
    case head <> tail: installed_head(head,installed_read(tail))
def inspected(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32> & String:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},events,pending,regs,system,clock}:
      installed_result(~(W.World<A.Schema,A.Store,A.Mail,U32> & String),owners => texts => (W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,owners,quarantine,errors},events,pending,regs,system,clock},List.show(&2,String,K.string_identity,texts)),installed_read(installed))
def registration(meta:W.RegistrationMeta) -> String:
  match meta:
    case W.RegistrationMeta{id,name,access}: U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,K.string_identity,access)
def world_meta(world:W.World<A.Schema,A.Store,A.Mail,U32>,queues:String) -> String:
  match world:
    case W.World{ns,next,high,live,cap,+depth,store,resource,events,pending,+regs,+system,clock}: A.snapshot(W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}) ++ "|installed-queues=" ++ queues ++ "|depth=" ++ Nat.show(depth) ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,registration,regs) ++ "|nextSystem=" ++ U32.show(system)
def world_seen(seen:W.World<A.Schema,A.Store,A.Mail,U32> & String) -> String:
  match seen:
    case (world,queues): world_meta(world,queues)
def world_snapshot(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  world_seen(inspected(world))
def world_error(error:W.WorldError) -> String:
  match error:
    case W.MissingEntity{}: "MissingEntity"
    case W.CapacityExceeded{}: "CapacityExceeded"
    case W.NamespaceExhausted{}: "NamespaceExhausted"
    case W.SystemIdExhausted{}: "SystemIdExhausted"
def kind(kind:SF.RegistryKind) -> String:
  match kind:
    case SF.Component{}: "component"
    case SF.Resource{}: "resource"
    case SF.Event{}: "event"
    case SF.Relation{}: "relation"
    case SF.Service{}: "service"
def declaration_error(error:SF.Error) -> String:
  match error:
    case SF.UndeclaredDescriptor{k,key,name}: "UndeclaredDescriptor:" ++ kind(k) ++ ":" ++ key ++ ":" ++ name
    case SF.DuplicateKey{k,key}: "DuplicateKey:" ++ kind(k) ++ ":" ++ key
    case SF.DuplicateName{k,name}: "DuplicateName:" ++ kind(k) ++ ":" ++ name
def refusal(error:AD.Refusal<String>) -> String:
  match error:
    case AD.EntityRefused{error}: world_error(error)
    case AD.ConstructionRefused{positions}: "ConstructionRefused:" ++ List.show(&2,Maybe<&2,String>,K.error_view,positions)
    case AD.DeclarationRefused{error}: declaration_error(error)
def first(first:Maybe<&2,AD.Refusal<String>>) -> String:
  match first:
    case None{}: "none"
    case Some{error}: refusal(error)
def outcome(result:Output()) -> String:
  match result:
    case AD.Accepted{}: "accepted"
    case AD.Refused{raw,error}: "refused:" ++ refusal(error) ++ ":" ++ K.raw_0(raw)
def delivered(delivery:Delivery) -> String:
  match delivery:
    case Delivery{context,GameResult{result,error,returned},prepared}: "result=" ++ outcome(result) ++ "|first=" ++ first(error) ++ "|returned=" ++ returned ++ "|caller-context=" ++ A.context_text(context) ++ "|prepared=" ++ List.show(&2,String,K.string_identity,prepared)
def transform(mode:Nat,world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match mode:
    case 0n: world
    case 1n: W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,world)
    case _: A.unwind(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,world))
def ran(mode:Nat,result:Sy.RunResult<A.Schema,A.Store,A.Mail,U32,Args,Unit,Delivery,runner>) -> String:
  match result:
    case Sy.Completed{Sy.Registry{namespace,id,name,access,cursor},Sy.Succeeded{world,delivery}}: world_snapshot(transform(mode,world)) ++ "|registry=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,K.string_identity,access) ++ ":" ++ U32.show(cursor) ++ "|" ++ delivered(delivery)
    case _: "UNEXPECTED_REGISTERED_RUN_RESULT"
def registered(mode:Nat,args:Args,result:Sy.RegistrationResult<A.Schema,A.Store,A.Mail,U32,Args,Unit,Delivery,runner>) -> String:
  match result:
    case Sy.Registered{world,registry}: ran(mode,Sy.run_tracked(~A.Schema,~A.Store,~A.Mail,~U32,~Args,~Unit,~Delivery,~runner,registry,world,args))
    case _: "UNEXPECTED_REGISTRATION_REFUSAL"
def launch(world:W.World<A.Schema,A.Store,A.Mail,U32>,args:Args,mode:Nat) -> String:
  registered(mode,args,Sy.register(~A.Schema,~A.Store,~A.Mail,~U32,~Args,~Unit,~Delivery,~runner,world,"owned-request",["write:a","write:front","write:b","write:tag","write:value","bundle.insert"]))
def input_selected(mode:Nat,invalid:Bool,retry:Bool,declared:Bool,world:W.World<A.Schema,A.Store,A.Mail,U32>,target:W.Handle<A.Schema>,local:W.Handle<A.Schema>) -> String:
  match invalid:
    case True{}: launch(world,Args{AD.Input{target,K.input(True{},False{})},local,retry,declared},mode)
    case False{}: launch(world,Args{AD.Input{target,Previous.replacement()},local,retry,declared},mode)
def selected(mode:Nat,missing:Bool,invalid:Bool,retry:Bool,declared:Bool,world:W.World<A.Schema,A.Store,A.Mail,U32>,+namespace:U32) -> String:
  match missing:
    case True{}: input_selected(mode,invalid,retry,declared,world,W.Handle{namespace,99},W.Handle{namespace,1})
    case False{}: input_selected(mode,invalid,retry,declared,world,W.Handle{namespace,1},W.Handle{namespace,1})
def local_named(mode:Nat,missing:Bool,invalid:Bool,retry:Bool,declared:Bool,named:W.World<A.Schema,A.Store,A.Mail,U32> & U32) -> String:
  match named:
    case (world,+namespace): selected(mode,missing,invalid,retry,declared,world,namespace)
def local(mode:Nat,missing:Bool,invalid:Bool,retry:Bool,declared:Bool,world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  local_named(mode,missing,invalid,retry,declared,W.namespace(~A.Schema,~A.Store,~A.Mail,~U32,world))

def foreign_named(mode:Nat,retry:Bool,target:W.Handle<A.Schema>,named:W.World<A.Schema,A.Store,A.Mail,U32> & U32) -> String:
  match named:
    case (world,namespace): input_selected(mode,False{},retry,True{},world,target,W.Handle{namespace,1})
def foreign(mode:Nat,retry:Bool,target:W.Handle<A.Schema>,world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  foreign_named(mode,retry,target,W.namespace(~A.Schema,~A.Store,~A.Mail,~U32,world))
