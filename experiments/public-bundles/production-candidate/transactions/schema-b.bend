import Base
import batch.bend as BT
import drain-recovery.bend as Drain
import ../../../public-bundles/component-install.bend as I
import ../../../public-bundles/fallible-install.bend as F
import ../../../../src/ecs/lifecycle.bend as L
import ../../../public-bundles/combined-other.bend as A
import ../../../public-bundles/prototype.bend as B
import ../../../public-bundles/constructor-control.bend as K
import ../../../public-bundles/constructor-stage.bend as S
import ../../../public-bundles/public.bend as Public
import ../schema-b.bend as Previous
import ../../../public-bundles/public-client/declared-other.bend as Declared
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as Creator
import ../../../../src/ecs/component.bend as C
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/schema-fragments.bend as SF
import ../../../../src/ecs/system.bend as Sys

type Action is Data:
  Insert{target:W.Handle<A.Schema>}
  Spawn{}
type Input is Type:
  Input{action:Action,raw:B.Pack<K.Raw<Array<U32>>,B.Pack<K.Raw<U32>,B.Pack<K.Raw<K.Tag>,B.Pack<K.Raw<K.QueueOwner>,Unit>>>>}
type Observation is Data:
  Observation{accepted:Bool}
  Created{target:W.Handle<A.Schema>}
def recovered(result:BT.Inserted<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Observation:
  match result:
    case BT.Inserted{batch}: (batch,Observation{True{}})
    case BT.Refused{BT.Batch{T.Tx{world,undo,commands,events},prepared},A.Packet{cooked,inverse},error}: (BT.Batch{T.Tx{A.returned(world,A.Original{inverse(cooked)},"immediate-refusal"),undo,commands,events},prepared},Observation{False{}})
def spawn_recovered(result:BT.Spawned<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Observation:
  match result:
    case BT.Spawned{batch,target}: (batch,Created{target})
    case BT.SpawnRefused{BT.Batch{T.Tx{world,undo,commands,events},prepared},A.Packet{cooked,inverse},error}: (BT.Batch{T.Tx{A.returned(world,A.Original{inverse(cooked)},"spawn-refusal"),undo,commands,events},prepared},Observation{False{}})
def dispatch(action:Action,batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,packet:A.Packet) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Observation:
  match action:
    case Insert{target}: recovered(BT.insert(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,batch,target,packet))
    case Spawn{}: spawn_recovered(BT.spawn(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,batch,packet))
def constructed(action:Action,prepared:List<BT.Prepared<A.Schema,A.Packet>>,undo:List<(W.World<A.Schema,A.Store,A.Mail,U32> -> W.World<A.Schema,A.Store,A.Mail,U32>)>,commands:List<(W.World<A.Schema,A.Store,A.Mail,U32> -> W.World<A.Schema,A.Store,A.Mail,U32>)>,events:List<&2,U32>,world:W.World<A.Schema,A.Store,A.Mail,U32>,result:S.Staged<K.Context,B.Pack<K.Raw<Array<U32>>,B.Pack<K.Raw<U32>,B.Pack<K.Raw<K.Tag>,B.Pack<K.Raw<K.QueueOwner>,Unit>>>>,B.Pack<K.Cooked<Array<U32>>,B.Pack<K.Cooked<U32>,B.Pack<K.Cooked<K.Tag>,B.Pack<K.Cooked<K.QueueOwner>,Unit>>>>,String>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Observation:
  match world result:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{old,items,installed,quarantine,oldErrors},published,pending,regs,system,clock} S.Failed{context,raw,errors}: (BT.Batch{T.Tx{W.World{ns,next,high,live,cap,depth,store,A.Mail{context,A.Original{raw} <> items,installed,quarantine,errors},published,pending,regs,system,clock},undo,commands,events},prepared},Observation{False{}})
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{old,items,installed,quarantine,oldErrors},published,pending,regs,system,clock} S.Valid{context,cooked,inverse,errors}: dispatch(action,BT.Batch{T.Tx{W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},published,pending,regs,system,clock},undo,commands,events},prepared},A.Packet{cooked,inverse})
def request(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,input:Input) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Observation:
  match batch input:
    case BT.Batch{T.Tx{W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},published,pending,regs,system,clock},undo,commands,events},prepared} Input{action,raw}: constructed(action,prepared,undo,commands,events,W.World{ns,next,high,live,cap,depth,store,A.Mail{K.context(),items,installed,quarantine,errors},published,pending,regs,system,clock},K.stage_0(context,raw))
def done(-H:Type,result:H & Observation) -> H & Unit:
  match result:
    case (ctx,observation): (ctx,Unit{})
def gameplay(-H:Type,cap:Cap.Request<H,Input,Observation>,input:Input,ctx:H) -> H & Unit:
  done(H,Public.apply(H,Input,Observation,cap,input,ctx))
def second() -> B.Pack<K.Raw<Array<U32>>,B.Pack<K.Raw<U32>,B.Pack<K.Raw<K.Tag>,B.Pack<K.Raw<K.QueueOwner>,Unit>>>>:
  B.Pack{K.Raw{True{},ANode{ALeaf{171},ALeaf{172}}},B.Pack{K.Raw{True{},37},B.Pack{K.Raw{True{},K.Tag{}},B.Pack{K.Raw{True{},K.QueueOwner{ANode{ALeaf{191},ALeaf{192}},ANode{ALeaf{201},ALeaf{202}},[ANode{ALeaf{211},ALeaf{212}}]}},Unit{}}}}}
def pending_observed(~H:Type,~cap:Cap.Request<H,Input,Observation>,result:H & Observation) -> H & Unit:
  match result:
    case (ctx,Created{target}): done(H,Cap.request(~H,~Input,~Observation,~cap,ctx,Input{Insert{target},second()}))
    case (ctx,Observation{accepted}): (ctx,Unit{})
def pending_gameplay(~H:Type,~cap:Cap.Request<H,Input,Observation>,input:Input,ctx:H) -> H & Unit:
  pending_observed(~H,~cap,Cap.request(~H,~Input,~Observation,~cap,ctx,input))
def requested(result:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Unit) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match result:
    case (batch,unit): batch
def invoke(owners:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Input) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match owners:
    case (batch,input): requested(Public.provide(~BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,~Input,~Observation,~request,~gameplay,input,batch))
def invoke_pending(owners:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Input) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match owners:
    case (batch,input): requested(Public.provide_repeatable(~BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,~Input,~Observation,~request,~pending_gameplay,input,batch))
def bound(result:SF.Bound<A.Schema,BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Input,BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match result:
    case SF.Built{batch}: batch
    case SF.BindRejected{error,SF.Fragment{entries,(BT.Batch{T.Tx{world,undo,commands,events},prepared},Input{action,raw})}}: BT.Batch{T.Tx{A.returned(world,A.Original{raw},"undeclared-refusal"),undo,commands,events},prepared}
def required() -> List<&2,SF.Entry<A.Schema>>:
  [Declared.a_entry(),Declared.a_entry(),Declared.b_entry(),Declared.tag_entry(),Declared.value_entry(),SF.Entry{SF.Service{},"bundle.insert","bundle.insert"},SF.Entry{SF.Service{},"bundle.spawn","bundle.spawn"}]
def available() -> List<&2,SF.Entry<A.Schema>>:
  [Declared.a_entry(),Declared.b_entry(),Declared.tag_entry(),Declared.value_entry(),SF.Entry{SF.Service{},"bundle.insert","bundle.insert"},SF.Entry{SF.Service{},"bundle.spawn","bundle.spawn"}]
def call(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,target:W.Handle<A.Schema>,raw:B.Pack<K.Raw<Array<U32>>,B.Pack<K.Raw<U32>,B.Pack<K.Raw<K.Tag>,B.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  bound(Public.provision_declared(~A.Schema,~(BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Input),~BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,~invoke,SF.Fragment{available(),(batch,Input{Insert{target},raw})},required()))
def call_input(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,input:Input) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  bound(Public.provision_declared(~A.Schema,~(BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Input),~BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,~invoke,SF.Fragment{available(),(batch,input)},required()))
def pending_call(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,input:Input) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  bound(Public.provision_declared(~A.Schema,~(BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet> & Input),~BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,~invoke_pending,SF.Fragment{available(),(batch,input)},required()))
def body_call(pending:Bool,batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,input:Input) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match pending:
    case False{}: call_input(batch,input)
    case True{}: pending_call(batch,input)
def returns(packets:List<A.Packet>,world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match packets:
    case []: world
    case A.Packet{cooked,inverse} <> rest: returns(rest,A.returned(world,A.Original{inverse(cooked)},"body-failed"))
def finished(result:BT.Finished<A.Schema,A.Store,A.Mail,U32,A.Packet,Unit>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match result:
    case BT.Committed{world}: world
    case BT.Failed{world,packets,error}: returns(packets,world)
def finish(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>,outcome:T.Outcome<Unit>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  finished(BT.finish(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,~Unit,~Previous.attempt,~Previous.recover,batch,outcome))
def published(world:W.World<A.Schema,A.Store,A.Mail,U32>,values:Array<U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  W.event_publish(~A.Schema,~A.Store,~A.Mail,~U32,world,K.cells(values))
def journaled(result:C.SetResult<T.Tx<W.World<A.Schema,A.Store,A.Mail,U32>,U32>,Array<U32>>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match result:
    case C.Written{tx}: BT.begin(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,T.emit(~W.World<A.Schema,A.Store,A.Mail,U32>,~U32,T.stage(~W.World<A.Schema,A.Store,A.Mail,U32>,~U32,tx,w => published(w,ANode{ALeaf{901},ALeaf{902}})),43))
    case C.WriteRejected{tx,incoming,error}: BT.begin(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,tx)
    case C.WriteFailure{tx,error}: BT.begin(~A.Schema,~A.Store,~A.Mail,~U32,~A.Packet,tx)
def begin(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}: journaled(C.tx_set(~A.Schema,~A.Store,~A.Mail,~U32,~A.Rest_a,~Array<U32>,~List<&2,U32>,~A.Token,~A.take_a,~A.put_a,~A.project_array,A.family_a(),T.begin(~W.World<A.Schema,A.Store,A.Mail,U32>,~U32,W.enqueue(~A.Schema,~A.Store,~A.Mail,~U32,W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},w => published(w,ANode{ALeaf{801},ALeaf{802}}))),W.Handle{ns,1},ANode{ALeaf{501},ALeaf{502}}))
def local(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match batch:
    case BT.Batch{T.Tx{W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},undo,commands,emitted},prepared}: call(BT.Batch{T.Tx{W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},undo,commands,emitted},prepared},W.Handle{ns,1},Previous.replacement())
def packet_text(packet:A.Packet) -> String:
  match packet:
    case A.Packet{cooked,inverse}: K.raw_0(inverse(cooked))
def prepared_text(prepared:List<BT.Prepared<A.Schema,A.Packet>>) -> String:
  match prepared:
    case []: "[]"
    case BT.ReservationReceipt{W.Handle{ns,id}} <> rest: "[receipt:" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ "]" ++ prepared_text(rest)
    case BT.Prepared{W.Handle{ns,id},packet,position} <> rest: "[" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ packet_text(packet) ++ "]" ++ prepared_text(rest)
def snapshot(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> String:
  match batch:
    case BT.Batch{T.Tx{world,undo,commands,+events},prepared}: A.snapshot(world) ++ "|undo=" ++ U32.show(A.count(~(W.World<A.Schema,A.Store,A.Mail,U32> -> W.World<A.Schema,A.Store,A.Mail,U32>),undo)) ++ "|txcommands=" ++ U32.show(A.count(~(W.World<A.Schema,A.Store,A.Mail,U32> -> W.World<A.Schema,A.Store,A.Mail,U32>),commands)) ++ "|txevents=" ++ List.show(&2,U32,U32.show,events) ++ "|prepared=" ++ prepared_text(prepared)
def entry_0(entry:I.Entry<A.Schema,Array<U32>>) -> String:
  match entry:
    case I.Entry{W.Handle{ns,id},owner}: U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ A.maybe_text(~Array<U32>,~A.array_text,owner)
def cold_0(cold:I.Recovery<A.Schema,Array<U32>>) -> String:
  match cold:
    case I.Recovery{entry,L.Stamp{added,changed}}: entry_0(entry) ++ "@" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def entry_1(entry:I.Entry<A.Schema,Array<U32>>) -> String:
  match entry:
    case I.Entry{W.Handle{ns,id},owner}: U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ A.maybe_text(~Array<U32>,~A.array_text,owner)
def cold_1(cold:I.Recovery<A.Schema,Array<U32>>) -> String:
  match cold:
    case I.Recovery{entry,L.Stamp{added,changed}}: entry_1(entry) ++ "@" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def entry_2(entry:I.Entry<A.Schema,Array<U32>>) -> String:
  match entry:
    case I.Entry{W.Handle{ns,id},owner}: U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ A.maybe_text(~Array<U32>,~A.array_text,owner)
def cold_2(cold:I.Recovery<A.Schema,Array<U32>>) -> String:
  match cold:
    case I.Recovery{entry,L.Stamp{added,changed}}: entry_2(entry) ++ "@" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def entry_3(entry:I.Entry<A.Schema,K.Tag>) -> String:
  match entry:
    case I.Entry{W.Handle{ns,id},owner}: U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ A.maybe_text(~K.Tag,~A.tag_text,owner)
def cold_3(cold:I.Recovery<A.Schema,K.Tag>) -> String:
  match cold:
    case I.Recovery{entry,L.Stamp{added,changed}}: entry_3(entry) ++ "@" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def entry_4(entry:I.Entry<A.Schema,U32>) -> String:
  match entry:
    case I.Entry{W.Handle{ns,id},owner}: U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ A.maybe_text(~U32,~U32.show,owner)
def cold_4(cold:I.Recovery<A.Schema,U32>) -> String:
  match cold:
    case I.Recovery{entry,L.Stamp{added,changed}}: entry_4(entry) ++ "@" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def payload_5(unit:Unit) -> String:
  "end"
def payload_4(payload:B.Pack<I.Entry<A.Schema,U32>,Unit>) -> String:
  match payload:
    case B.Pack{head,tail}: entry_4(head) ++ "|" ++ payload_5(tail)
def payload_3(payload:B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>) -> String:
  match payload:
    case B.Pack{head,tail}: entry_3(head) ++ "|" ++ payload_4(tail)
def payload_2(payload:B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>>) -> String:
  match payload:
    case B.Pack{head,tail}: entry_2(head) ++ "|" ++ payload_3(tail)
def payload_1(payload:B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>>>) -> String:
  match payload:
    case B.Pack{head,tail}: entry_1(head) ++ "|" ++ payload_2(tail)
def payload_0(payload:B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>>>>) -> String:
  match payload:
    case B.Pack{head,tail}: entry_0(head) ++ "|" ++ payload_1(tail)
def drain_5(world:W.World<A.Schema,A.Store,A.Mail,U32>,unit:Unit) -> W.World<A.Schema,A.Store,A.Mail,U32> & String:
  (world,"end")
def drain_4(world:W.World<A.Schema,A.Store,A.Mail,U32>,recovery:F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,U32>,I.Recovery<A.Schema,U32>,Unit,Unit>) -> W.World<A.Schema,A.Store,A.Mail,U32> & String:
  Drain.collect(~W.World<A.Schema,A.Store,A.Mail,U32>,~I.Entry<A.Schema,U32>,~I.Recovery<A.Schema,U32>,~Unit,~Unit,~entry_4,~cold_4,~payload_5,~drain_5,world,recovery)
def drain_3(world:W.World<A.Schema,A.Store,A.Mail,U32>,recovery:F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,K.Tag>,I.Recovery<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,U32>,I.Recovery<A.Schema,U32>,Unit,Unit>>) -> W.World<A.Schema,A.Store,A.Mail,U32> & String:
  Drain.collect(~W.World<A.Schema,A.Store,A.Mail,U32>,~I.Entry<A.Schema,K.Tag>,~I.Recovery<A.Schema,K.Tag>,~B.Pack<I.Entry<A.Schema,U32>,Unit>,~F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,U32>,I.Recovery<A.Schema,U32>,Unit,Unit>,~entry_3,~cold_3,~payload_4,~drain_4,world,recovery)
def drain_2(world:W.World<A.Schema,A.Store,A.Mail,U32>,recovery:F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,Array<U32>>,I.Recovery<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,K.Tag>,I.Recovery<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,U32>,I.Recovery<A.Schema,U32>,Unit,Unit>>>) -> W.World<A.Schema,A.Store,A.Mail,U32> & String:
  Drain.collect(~W.World<A.Schema,A.Store,A.Mail,U32>,~I.Entry<A.Schema,Array<U32>>,~I.Recovery<A.Schema,Array<U32>>,~B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>,~F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,K.Tag>,I.Recovery<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,U32>,I.Recovery<A.Schema,U32>,Unit,Unit>>,~entry_2,~cold_2,~payload_3,~drain_3,world,recovery)
def drain_1(world:W.World<A.Schema,A.Store,A.Mail,U32>,recovery:F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,Array<U32>>,I.Recovery<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,Array<U32>>,I.Recovery<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,K.Tag>,I.Recovery<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,U32>,I.Recovery<A.Schema,U32>,Unit,Unit>>>>) -> W.World<A.Schema,A.Store,A.Mail,U32> & String:
  Drain.collect(~W.World<A.Schema,A.Store,A.Mail,U32>,~I.Entry<A.Schema,Array<U32>>,~I.Recovery<A.Schema,Array<U32>>,~B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>>,~F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,Array<U32>>,I.Recovery<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,K.Tag>,I.Recovery<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,U32>,I.Recovery<A.Schema,U32>,Unit,Unit>>>,~entry_1,~cold_1,~payload_2,~drain_2,world,recovery)
def drain_0(world:W.World<A.Schema,A.Store,A.Mail,U32>,recovery:F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,Array<U32>>,I.Recovery<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>>>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,Array<U32>>,I.Recovery<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,Array<U32>>,I.Recovery<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,K.Tag>,I.Recovery<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,U32>,I.Recovery<A.Schema,U32>,Unit,Unit>>>>>) -> W.World<A.Schema,A.Store,A.Mail,U32> & String:
  Drain.collect(~W.World<A.Schema,A.Store,A.Mail,U32>,~I.Entry<A.Schema,Array<U32>>,~I.Recovery<A.Schema,Array<U32>>,~B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>>>,~F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,Array<U32>>,I.Recovery<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,Array<U32>>,I.Recovery<A.Schema,Array<U32>>,B.Pack<I.Entry<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,K.Tag>,I.Recovery<A.Schema,K.Tag>,B.Pack<I.Entry<A.Schema,U32>,Unit>,F.Recovery<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,U32>,I.Recovery<A.Schema,U32>,Unit,Unit>>>>,~entry_0,~cold_0,~payload_1,~drain_1,world,recovery)
def drained(queued:List<Array<U32>>,result:W.World<A.Schema,A.Store,A.Mail,U32> & String) -> String:
  match result:
    case (world,text): A.snapshot(world) ++ "|cold=" ++ text ++ "|queued=" ++ List.show(&1,Array<U32>,A.array_text,queued) ++ "|constructor-inverse=consumed-terminally-unapplied"
def quarantine(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,A.Quarantine{recovery,queued,inverse} <> rest,errors},events,commands,regs,system,clock}: drained(queued,drain_0(W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,rest,errors},events,commands,regs,system,clock},recovery))
    case world: "UNEXPECTED_NO_QUARANTINE|" ++ A.snapshot(world)
def hostile(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,resource,events,commands,regs,system,clock}: quarantine(A.unwind(Cmd.despawn_apply(~A.Schema,~A.Store,~A.Mail,~U32,W.World{ns,next,high,live,cap,depth,store,resource,events,commands,regs,system,clock},W.Handle{ns,1})))
type Args is Type:
  Args{input:Input,fail:Bool,pending:Bool}
def body_result(fail:Bool,batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> Sys.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Unit>:
  match fail:
    case False{}: Sys.Succeeded{finish(batch,T.Success{}),Unit{}}
    case True{}: Sys.Failed{finish(batch,T.Failure{Unit{}}),Unit{}}
def runner(world:W.World<A.Schema,A.Store,A.Mail,U32>,args:Args) -> Sys.Outcome<W.World<A.Schema,A.Store,A.Mail,U32>,Unit,Unit>:
  match args:
    case Args{input,fail,pending}: body_result(fail,body_call(pending,begin(world),input))
def registry_observe(registry:Sys.Registry<A.Schema,A.Store,A.Mail,U32,Args,Unit,Unit,runner>) -> Sys.Registry<A.Schema,A.Store,A.Mail,U32,Args,Unit,Unit,runner> & String:
  match registry:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}: (Sys.Registry{ns,id,name,access,cursor},U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,A.text_identity,access) ++ ":" ++ U32.show(cursor))
def world_summary(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,resource,events,pending,+regs,+system,clock}: "next-system=" ++ U32.show(system) ++ "|registrations=" ++ Nat.show(List.length(&2,W.RegistrationMeta,regs)) ++ "|" ++ A.snapshot(W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock})
def disposed(label:String,registry:String,result:Sys.Disposal<A.Schema,A.Store,A.Mail,U32,Args,Unit,Unit,runner>) -> String:
  match result:
    case Sys.Disposed{world}: label ++ "|disposed=True|registry=" ++ registry ++ "|" ++ world_summary(world)
    case Sys.DisposalRejected{world,registration}: label ++ "|disposed=False|registry=" ++ registry ++ "|" ++ world_summary(world)
def post(after:Bool,world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match after:
    case False{}: world
    case True{}: Previous.barrier(world)
def dispose(label:String,after:Bool,world:W.World<A.Schema,A.Store,A.Mail,U32>,observed:Sys.Registry<A.Schema,A.Store,A.Mail,U32,Args,Unit,Unit,runner> & String) -> String:
  match observed:
    case (registry,text): disposed(label,text,Sys.dispose(~A.Schema,~A.Store,~A.Mail,~U32,~Args,~Unit,~Unit,~runner,registry,post(after,world)))
def registration_payload(world:W.World<A.Schema,A.Store,A.Mail,U32>,args:Args) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match args:
    case Args{Input{action,raw},fail,pending}: A.returned(world,A.Original{raw},"registration-refusal")
def ran(after:Bool,result:Sys.RunResult<A.Schema,A.Store,A.Mail,U32,Args,Unit,Unit,runner>) -> String:
  match result:
    case Sys.Completed{registry,Sys.Succeeded{world,Unit{}}}: dispose("Succeeded",after,world,registry_observe(registry))
    case Sys.Completed{registry,Sys.Failed{world,Unit{}}}: dispose("Failed",after,world,registry_observe(registry))
    case Sys.RegistrationRejected{registry,world,args}: dispose("RegistrationRejected",after,registration_payload(world,args),registry_observe(registry))
def registered(after:Bool,args:Args,result:Sys.RegistrationResult<A.Schema,A.Store,A.Mail,U32,Args,Unit,Unit,runner>) -> String:
  match result:
    case Sys.Registered{world,registry}: ran(after,Sys.run(~A.Schema,~A.Store,~A.Mail,~U32,~Args,~Unit,~Unit,~runner,registry,world,args))
    case Sys.RegistrationFailed{world}: "RegistrationFailed|" ++ world_summary(registration_payload(world,args))
def system(after:Bool,fail:Bool,world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  match world:
    case W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock}: registered(after,Args{Input{Insert{W.Handle{ns,1}},Previous.replacement()},fail,False{}},Sys.register(~A.Schema,~A.Store,~A.Mail,~U32,~Args,~Unit,~Unit,~runner,W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},"bundle.tx",["write:a","write:b","write:tag","write:value","bundle.insert","bundle.spawn"]))

# An ordinary deferred component write is deliberately interleaved between two
# opaque public bundle requests. Its read records which insertion precedes it.
def ordinary_written(result:F.Attempt<W.World<A.Schema,A.Store,A.Mail,U32>,I.Entry<A.Schema,U32>,I.Recovery<A.Schema,U32>>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match result:
    case F.Installed{world,inverse}: world
    case F.Refused{world,payload,error}: world
    case F.Quarantined{world,recovery,error}: world
def ordinary_observed(+target:W.Handle<A.Schema>,result:W.World<A.Schema,A.Store,A.Mail,U32> & C.Access<U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match result:
    case (world,C.Found{value}): ordinary_written(A.install_value(W.event_publish(~A.Schema,~A.Store,~A.Mail,~U32,world,[value]),I.Entry{target,Some{99}}))
    case (world,access): world
def ordinary(world:W.World<A.Schema,A.Store,A.Mail,U32>,+target:W.Handle<A.Schema>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  ordinary_observed(target,C.get(~A.Schema,~A.Store,~A.Mail,~U32,~A.Rest_value,~U32,~U32,~A.Token,~A.take_value,~A.put_value,~A.project_value,A.family_value(),world,target))
def interleaved(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match batch:
    case BT.Batch{T.Tx{W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},undo,commands,emitted},prepared}:
      call(BT.Batch{T.stage(~W.World<A.Schema,A.Store,A.Mail,U32>,~U32,T.Tx{W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},undo,commands,emitted},w => ordinary(w,W.Handle{ns,1})),prepared},W.Handle{ns,1},second())
def fifo(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  A.snapshot(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,finish(interleaved(local(begin(world))),T.Success{})))

# Preserve the earlier public successful same-Tx pending spawn -> installer FIFO.
# No failure/cancellation branch is selected by these observations.
def pending_before(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  A.snapshot(Previous.call(world,Previous.PendingSpawn{},K.input(True{},True{})))
def pending_after(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  A.snapshot(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,Previous.call(world,Previous.PendingSpawn{},K.input(True{},True{}))))
def cleared(~Owner:Type,result:Col.SwapOutcome<A.Schema,Owner>) -> Col.Column<A.Schema,Owner>:
  match result:
    case Col.Accepted{column,previous}: column
    case Col.Rejected{column,incoming}: column
# Gameplay cleanup releases the four actual heterogeneous column owners through
# public Col.clear. This never replaces the entire generic Store with a zero.
def clear(store:A.Store,handle:W.Handle<A.Schema>) -> A.Store:
  match store handle:
    case A.Store{a,b,tag,value} W.Handle{ns,+id}: A.Store{cleared(~Array<U32>,Col.clear(~A.Schema,~Array<U32>,a,id)),cleared(~Array<U32>,Col.clear(~A.Schema,~Array<U32>,b,id)),cleared(~K.Tag,Col.clear(~A.Schema,~K.Tag,tag,id)),cleared(~U32,Col.clear(~A.Schema,~U32,value,id))}
def cleanup_queued(prepared:List<BT.Prepared<A.Schema,A.Packet>>,result:T.Tx<W.World<A.Schema,A.Store,A.Mail,U32>,U32> & W.Status) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match result:
    case (tx,status): local(BT.Batch{tx,prepared})
def cleanup_batch(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match batch:
    case BT.Batch{T.Tx{W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},undo,commands,emitted},prepared}:
      cleanup_queued(prepared,Cmd.tx_despawn_with(~A.Schema,~A.Store,~A.Mail,~U32,~clear,T.Tx{W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},undo,commands,emitted},W.Handle{ns,1}))
def cleaned(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,finish(cleanup_batch(begin(world)),T.Success{}))
def cleanup(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  A.snapshot(cleaned(world))
def retry_spawn(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{context,A.Original{raw} <> rest,installed,quarantine,errors},events,pending,regs,system,clock}:
      Previous.call(W.World{ns,next,high,live,cap,depth,store,A.Mail{context,rest,installed,quarantine,errors},events,pending,regs,system,clock},Previous.Spawn{},raw)
    case world: world
def cleanup_retry(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  A.snapshot(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,retry_spawn(cleaned(world))))

def unified_pending(after:Bool,fail:Bool,world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  registered(after,Args{Input{Spawn{},K.input(True{},True{})},fail,True{}},Sys.register(~A.Schema,~A.Store,~A.Mail,~U32,~Args,~Unit,~Unit,~runner,world,"bundle.tx",["write:a","write:b","write:tag","write:value","bundle.insert","bundle.spawn"]))

def unified_pending_before(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  unified_pending(False{},False{},world)
def unified_pending_after(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  unified_pending(True{},False{},world)
def unified_pending_failed(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  unified_pending(True{},True{},world)
def pending_foreign(world:W.World<A.Schema,A.Store,A.Mail,U32>,target:W.Handle<A.Schema>) -> String:
  A.snapshot(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,finish(call(call_input(begin(world),Input{Spawn{},K.input(True{},True{})}),target,Previous.replacement()),T.Success{})))
