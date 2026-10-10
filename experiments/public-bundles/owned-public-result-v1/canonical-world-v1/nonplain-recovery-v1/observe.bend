import Base
import /workspace/formal-proofs/bendvy/src/ecs/owner-handoff.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/bundle-component-install.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as P
import runtime.bend as R
import ../bundle.bend as B
import ../canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as BT

def count_join(~A:Type,head:A,result:List<A> & Nat) -> List<A> & Nat:
  match result:
    case (tail,n):(head <> tail,1n+n)
def counted(~A:Type,owners:List<A>) -> List<A> & Nat:
  match owners:
    case []:([],0n)
    case head <> tail:count_join(~A,head,counted(~A,tail))
def pair_tree(~A:Type,left:Array<A> & String,right:Array<A> & String) -> Array<A> & String:
  match left right:
    case (a,x),(b,y):(ANode{a,b},"[" ++ x ++ "," ++ y ++ "]")
def leaf_tree(~A:Type,result:A & String) -> Array<A> & String:
  match result:
    case (owner,view):(ALeaf{owner},view)
def tree(~A:Type,~view:A -> A & String,owner:Array<A>) -> Array<A> & String:
  match owner:
    case ALeaf{value}:leaf_tree(~A,view(value))
    case ANode{left,right}:pair_tree(~A,tree(~A,~view,left),tree(~A,~view,right))
def boolean(value:Bool) -> Bool & String:
  +copy=value
  (copy,Bool.show(copy))
def some_shown(~A:Type,result:A & String) -> Maybe<&1,A> & String:
  match result:
    case (owner,view):(Some{owner},view)
def optional(~A:Type,~view:A -> A & String,owner:Maybe<&1,A>) -> Maybe<&1,A> & String:
  match owner:
    case None{}:(None{},"null")
    case Some{value}:some_shown(~A,view(value))
def stamp(value:L.Entry) -> String:
  match value:
    case L.Entry{id,L.Stamp{added,changed}}:U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def column_join(~A:Type,+stamps:List<&2,L.Entry>,result:Array<Maybe<&1,A>> & String) -> Col.Column<K.SchemaA,A> & String:
  match result:
    case (values,view):(Col.Column{values,stamps},"{values:" ++ view ++ ",stamps:" ++ List.show(&2,L.Entry,stamp,stamps) ++ "}")
def row_join(~A:Type,+id:U32,owner:A & String,tail:H.PrototypeHandoffRows<K.SchemaA,A> & String) -> H.PrototypeHandoffRows<K.SchemaA,A> & String:
  match owner tail:
    case (owner,o),(tail,r):(H.HandoffCon{id,owner,tail},"{id:" ++ U32.show(id) ++ ",owner:" ++ o ++ "};" ++ r)
def rows(~A:Type,~view:A -> A & String,owners:H.PrototypeHandoffRows<K.SchemaA,A>) -> H.PrototypeHandoffRows<K.SchemaA,A> & String:
  match owners:
    case H.HandoffNil{}:(H.HandoffNil{},"end")
    case H.HandoffCon{id,owner,tail}:row_join(~A,id,view(owner),rows(~A,~view,tail))
def past_join(~A:Type,+id:U32,owner:Maybe<&1,A> & String,tail:Col.History<K.SchemaA,A> & String) -> Col.History<K.SchemaA,A> & String:
  match owner tail:
    case (owner,o),(tail,r):(Col.HistoryCon{id,owner,tail},"{id:" ++ U32.show(id) ++ ",owner:" ++ o ++ "};" ++ r)
def history(~A:Type,~view:A -> A & String,owners:Col.History<K.SchemaA,A>) -> Col.History<K.SchemaA,A> & String:
  match owners:
    case Col.HistoryNil{}:(Col.HistoryNil{},"end")
    case Col.HistoryCon{id,owner,tail}:past_join(~A,id,optional(~A,~view,owner),history(~A,~view,tail))
def state_join(~A:Type,+stamps:List<&2,L.Entry>,+capacity:U32,+current:U32,values:Array<Maybe<&1,A>> & String,owner:Maybe<&1,A> & String,remaining:H.PrototypeHandoffRows<K.SchemaA,A> & String,past:Col.History<K.SchemaA,A> & String) -> Col.State<K.SchemaA,A> & String:
  match values owner remaining past:
    case (values,v),(owner,o),(remaining,r),(past,p):(Col.State{values,stamps,capacity,current,owner,remaining,past},"{values:" ++ v ++ ",stamps:" ++ List.show(&2,L.Entry,stamp,stamps) ++ ",capacity:" ++ U32.show(capacity) ++ ",current:" ++ U32.show(current) ++ ",owner:" ++ o ++ ",remaining:" ++ r ++ ",past:" ++ p ++ "}")
def state(~A:Type,~view:A -> A & String,owned:Col.State<K.SchemaA,A>) -> Col.State<K.SchemaA,A> & String:
  match owned:
    case Col.State{values,stamps,capacity,current,owner,remaining,past}:state_join(~A,stamps,capacity,current,tree(~Maybe<&1,A>,~optional(~A,~view),values),optional(~A,~view,owner),rows(~A,~view,remaining),history(~A,~view,past))
def owned_join(~A:Type,result:Col.State<K.SchemaA,A> & String) -> Col.Carrier<K.SchemaA,A> & String:
  match result:
    case (state,text):(Col.Owned{state},"Owned(" ++ text ++ ")")
def wrapped_join(~A:Type,result:Col.Carrier<K.SchemaA,A> & String) -> Col.Carrier<K.SchemaA,A> & String:
  match result:
    case (carrier,text):(Col.Wrapped{carrier},"Wrapped(" ++ text ++ ")")
def carrier(~A:Type,~view:A -> A & String,owner:Col.Carrier<K.SchemaA,A>) -> Col.Carrier<K.SchemaA,A> & String:
  match owner:
    case Col.Owned{owned}:owned_join(~A,state(~A,~view,owned))
    case Col.Wrapped{inner}:wrapped_join(~A,carrier(~A,~view,inner))
def prepared_join(~A:Type,result:Col.Carrier<K.SchemaA,A> & String) -> Col.Column<K.SchemaA,A> & String:
  match result:
    case (carrier,text):(Col.Prepared{carrier},"Prepared(" ++ text ++ ")")
def column(~A:Type,~view:A -> A & String,owner:Col.Column<K.SchemaA,A>) -> Col.Column<K.SchemaA,A> & String:
  match owner:
    case Col.Column{values,stamps}:column_join(~A,stamps,tree(~Maybe<&1,A>,~optional(~A,~view),values))
    case Col.Prepared{owned}:prepared_join(~A,carrier(~A,~view,owned))
    case owner:(owner,"indexed-column-unqualified")
def store_join(left:Col.Column<K.SchemaA,K.Payload> & String,right:Col.Column<K.SchemaA,K.Tail> & String) -> B.Store & String:
  match left right:
    case (a,x),(b,y):(B.Store{a,b},"{heads:" ++ x ++ ",tails:" ++ y ++ "}")
def store(owner:B.Store) -> B.Store & String:
  match owner:
    case B.Store{heads,tails}:store_join(column(~K.Payload,~K.payload_observe,heads),column(~K.Tail,~K.tail_observe,tails))
def raws_join(raw:B.Raw() & String,tail:List<B.Raw()> & String) -> List<B.Raw()> & String:
  match raw tail:
    case (raw,x),(tail,y):(raw <> tail,x ++ ";" ++ y)
def raws(owners:List<B.Raw()>) -> List<B.Raw()> & String:
  match owners:
    case []:([],"end")
    case owner <> tail:raws_join(K.raw_observe(owner),raws(tail))
def head_entry_join(+handle:W.Handle<K.SchemaA>,result:Maybe<&1,K.Payload> & String) -> I.Entry<K.SchemaA,K.Payload> & String:
  match handle result:
    case W.Handle{+ns,+id},(owner,text):(I.Entry{W.Handle{ns,id},owner},"{handle:" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ",owner:" ++ text ++ "}")
def head_entry(entry:I.Entry<K.SchemaA,K.Payload>) -> I.Entry<K.SchemaA,K.Payload> & String:
  match entry:
    case I.Entry{handle,owner}:head_entry_join(handle,optional(~K.Payload,~K.payload_observe,owner))
def head_recovery_join(+stamp:L.Stamp,result:I.Entry<K.SchemaA,K.Payload> & String) -> I.Recovery<K.SchemaA,K.Payload> & String:
  match stamp result:
    case L.Stamp{+added,+changed},(entry,text):(I.Recovery{entry,L.Stamp{added,changed}},"{previous:" ++ text ++ ",stamp:" ++ U32.show(added) ++ ":" ++ U32.show(changed) ++ "}")
def head_recovery(recovery:I.Recovery<K.SchemaA,K.Payload>) -> I.Recovery<K.SchemaA,K.Payload> & String:
  match recovery:
    case I.Recovery{previous,stamp}:head_recovery_join(stamp,head_entry(previous))
def tail_entry_join(+handle:W.Handle<K.SchemaA>,result:Maybe<&1,K.Tail> & String) -> I.Entry<K.SchemaA,K.Tail> & String:
  match handle result:
    case W.Handle{+ns,+id},(owner,text):(I.Entry{W.Handle{ns,id},owner},"{handle:" ++ U32.show(ns) ++ ":" ++ U32.show(id) ++ ",owner:" ++ text ++ "}")
def tail_entry(entry:I.Entry<K.SchemaA,K.Tail>) -> I.Entry<K.SchemaA,K.Tail> & String:
  match entry:
    case I.Entry{handle,owner}:tail_entry_join(handle,optional(~K.Tail,~K.tail_observe,owner))
def tail_recovery_join(+stamp:L.Stamp,result:I.Entry<K.SchemaA,K.Tail> & String) -> I.Recovery<K.SchemaA,K.Tail> & String:
  match stamp result:
    case L.Stamp{+added,+changed},(entry,text):(I.Recovery{entry,L.Stamp{added,changed}},"{previous:" ++ text ++ ",stamp:" ++ U32.show(added) ++ ":" ++ U32.show(changed) ++ "}")
def tail_recovery(recovery:I.Recovery<K.SchemaA,K.Tail>) -> I.Recovery<K.SchemaA,K.Tail> & String:
  match recovery:
    case I.Recovery{previous,stamp}:tail_recovery_join(stamp,tail_entry(previous))
def tail_pending_join(unit:Unit,result:I.Recovery<K.SchemaA,K.Tail> & String) -> B.TailRecovery(R.Mail) & String:
  match result:
    case (recovery,text):(F.HeadPending{recovery,unit},"head-pending:" ++ text ++ "/terminal=unit")
def tail_receipt(recovery:B.TailRecovery(R.Mail)) -> B.TailRecovery(R.Mail) & String:
  match recovery:
    case F.HeadPending{head,unit}:tail_pending_join(unit,tail_recovery(head))
    case F.TailPending{undoHead,unit}:(F.TailPending{undoHead,unit},"tail-pending:terminal=unit/undoHead=retained-for-execution")
def outer_tail_join(undoHead:R.World() -> F.Restore<R.World(),I.Entry<K.SchemaA,K.Payload>,I.Recovery<K.SchemaA,K.Payload>>,result:B.TailRecovery(R.Mail) & String) -> B.Recovery(R.Mail) & String:
  match result:
    case (tail,text):(F.TailPending{undoHead,tail},"tail-pending:" ++ text ++ "/undoHead=retained-for-execution")
def entries_join(head:I.Entry<K.SchemaA,K.Payload> & String,tail:I.Entry<K.SchemaA,K.Tail> & String) -> B.Entries() & String:
  match head tail:
    case (head,h),(tail,t):(P.Pack{head,P.Pack{tail,Unit{}}},"[" ++ h ++ "," ++ t ++ "]")
def entries(owner:B.Entries()) -> B.Entries() & String:
  match owner:
    case P.Pack{head,P.Pack{tail,unit}}:entries_join(head_entry(head),tail_entry(tail))
def outer_head_join(head:I.Recovery<K.SchemaA,K.Payload> & String,tail:B.TailEntries() & String) -> B.Recovery(R.Mail) & String:
  match head tail:
    case (head,h),(tail,t):(F.HeadPending{head,tail},"head-pending:" ++ h ++ "/tail=" ++ t)
def tail_entries_join(result:I.Entry<K.SchemaA,K.Tail> & String) -> B.TailEntries() & String:
  match result:
    case (tail,t):(P.Pack{tail,Unit{}},t)
def tail_entries(owner:B.TailEntries()) -> B.TailEntries() & String:
  match owner:
    case P.Pack{tail,unit}:tail_entries_join(tail_entry(tail))
def recovery(owner:B.Recovery(R.Mail)) -> B.Recovery(R.Mail) & String:
  match owner:
    case F.TailPending{undoHead,tail}:outer_tail_join(undoHead,tail_receipt(tail))
    case F.HeadPending{head,tail}:outer_head_join(head_recovery(head),tail_entries(tail))
def error_text(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def quarantine_recovery_join(undo:B.Cooked() -> B.Raw(),+error:W.WorldError,result:B.Recovery(R.Mail) & String) -> R.Quarantine & String:
  match result:
    case (owner,text):(R.Recovery{owner,undo,error},"recovery:" ++ text ++ "/error=" ++ error_text(error) ++ "/rawUndo=retained-for-execution")
def quarantine_entries_join(undo:B.Cooked() -> B.Raw(),+error:W.WorldError,result:B.Entries() & String) -> R.Quarantine & String:
  match result:
    case (owner,text):(R.Entries{owner,undo,error},"entries:" ++ text ++ "/error=" ++ error_text(error))
def quarantine_one(owner:R.Quarantine) -> R.Quarantine & String:
  match owner:
    case R.Recovery{owner,undo,error}:quarantine_recovery_join(undo,error,recovery(owner))
    case R.Entries{owner,undo,error}:quarantine_entries_join(undo,error,entries(owner))
def quarantine_join(head:R.Quarantine & String,tail:List<R.Quarantine> & String) -> List<R.Quarantine> & String:
  match head tail:
    case (head,h),(tail,t):(head <> tail,h ++ ";" ++ t)
def quarantines(owners:List<R.Quarantine>) -> List<R.Quarantine> & String:
  match owners:
    case []:([],"end")
    case head <> tail:quarantine_join(quarantine_one(head),quarantines(tail))
def mail_join(+errors:List<&2,W.WorldError>,saved:List<R.Saved> & Nat,quarantine:List<R.Quarantine> & String,returned:List<B.Raw()> & String,spare:Array<U32> & String) -> R.Mail & String:
  match saved quarantine returned spare:
    case (saved,n),(quarantine,q),(returned,r),(spare,s):(R.Mail{returned,saved,quarantine,errors,spare},"{returned:" ++ r ++ ",saved:" ++ Nat.show(n) ++ ",quarantine:" ++ q ++ ",errors:" ++ List.show(&2,W.WorldError,error_text,errors) ++ ",spare:" ++ s ++ "}")
def mail(owner:R.Mail) -> R.Mail & String:
  match owner:
    case R.Mail{returned,saved,quarantine,errors,spare}:mail_join(errors,counted(~R.Saved,saved),quarantines(quarantine),raws(returned),K.tree(spare))
def meta(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)
def world_join(+ns:U32,+next:U32,+high:U32,+cap:U32,+depth:Nat,+events:List<&2,U32>,+regs:List<&2,W.RegistrationMeta>,+system:U32,+clock:U32,live:Array<Bool> & String,store:B.Store & String,resource:R.Mail & String,pending:List<(R.World() -> R.World())> & Nat) -> R.World() & String:
  match live store resource pending:
    case (live,l),(store,s),(resource,r),(pending,p):(W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},"{ns:" ++ U32.show(ns) ++ ",next:" ++ U32.show(next) ++ ",high:" ++ U32.show(high) ++ ",cap:" ++ U32.show(cap) ++ ",depth:" ++ Nat.show(depth) ++ ",live:" ++ l ++ ",store:" ++ s ++ ",resource:" ++ r ++ ",events:" ++ List.show(&2,U32,U32.show,events) ++ ",pending:" ++ Nat.show(p) ++ ",regs:" ++ List.show(&2,W.RegistrationMeta,meta,regs) ++ ",system:" ++ U32.show(system) ++ ",clock:" ++ U32.show(clock) ++ "}")
def world(owner:R.World()) -> R.World() & String:
  match owner:
    case W.World{ns,next,high,live,cap,depth,columns,resource,events,pending,regs,system,clock}:world_join(ns,next,high,cap,depth,events,regs,system,clock,tree(~Bool,~boolean,live),store(columns),mail(resource),counted(~(R.World() -> R.World()),pending))
def registry(owner:R.Registry()) -> R.Registry() & String:
  match owner:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"{ns:" ++ U32.show(ns) ++ ",id:" ++ U32.show(id) ++ ",name:" ++ name ++ ",access:" ++ List.show(&2,String,x => x,access) ++ ",cursor:" ++ U32.show(cursor) ++ "}")
type Session is Type:Session{registry:R.Registry(),world:R.World(),context:K.Context<K.SchemaA>}
def session_join(registry:R.Registry() & String,world:R.World() & String,context:K.Context<K.SchemaA> & String) -> Session & String:
  match registry world context:
    case (reg,g),(world,w),(ctx,c):(Session{reg,world,ctx},"registry=" ++ g ++ "|world=" ++ w ++ "|context=" ++ c)
def session(owner:Session) -> Session & String:
  match owner:
    case Session{reg,w,ctx}:session_join(registry(reg),world(w),K.context_observe(~K.SchemaA,ctx))
