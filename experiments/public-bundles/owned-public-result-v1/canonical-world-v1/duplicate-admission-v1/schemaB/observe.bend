import Base
import runtime.bend as R
import bundle.bend as B
import ../../complete-families-v1/canonical.bend as K
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
def column_join(~A:Type,+stamps:List<&2,L.Entry>,result:Array<Maybe<&1,A>> & String) -> Col.Column<K.SchemaB,A> & String:
  match result:
    case (values,view):(Col.Column{values,stamps},"{values:" ++ view ++ ",stamps:" ++ List.show(&2,L.Entry,stamp,stamps) ++ "}")
def column(~A:Type,~view:A -> A & String,owner:Col.Column<K.SchemaB,A>) -> Col.Column<K.SchemaB,A> & String:
  match owner:
    case Col.Column{values,stamps}:column_join(~A,stamps,tree(~Maybe<&1,A>,~optional(~A,~view),values))
    case owner:(owner,"nonplain-column-unqualified")
def store_join(left:Col.Column<K.SchemaB,K.Payload> & String,right:Col.Column<K.SchemaB,K.Tail> & String,tags:Col.Column<K.SchemaB,K.Tag> & String,data:Col.Column<K.SchemaB,U32> & String) -> B.Store & String:
  match left right tags data:
    case (a,x),(b,y),(c,z),(d,w):(B.Store{a,b,c,d},"{heads:" ++ x ++ ",tails:" ++ y ++ ",tags:" ++ z ++ ",data:" ++ w ++ "}")
def store(owner:B.Store) -> B.Store & String:
  match owner:
    case B.Store{heads,tails,tags,data}:store_join(column(~K.Payload,~K.payload_observe,heads),column(~K.Tail,~K.tail_observe,tails),column(~K.Tag,~K.tag_observe,tags),column(~U32,~K.data_observe,data))
def raws_join(raw:B.Raw() & String,tail:List<B.Raw()> & String) -> List<B.Raw()> & String:
  match raw tail:
    case (raw,x),(tail,y):(raw <> tail,x ++ ";" ++ y)
def raws(owners:List<B.Raw()>) -> List<B.Raw()> & String:
  match owners:
    case []:([],"end")
    case owner <> tail:raws_join(K.raw_observe(owner),raws(tail))
def mail_join(+errors:List<&2,W.WorldError>,saved:List<R.Saved> & Nat,quarantine:List<R.Quarantine> & Nat,returned:List<B.Raw()> & String,spare:Array<U32> & String) -> R.Mail & String:
  match saved quarantine returned spare:
    case (saved,n),(quarantine,q),(returned,r),(spare,s):(R.Mail{returned,saved,quarantine,errors,spare},"{returned:" ++ r ++ ",saved:" ++ Nat.show(n) ++ ",quarantine:" ++ Nat.show(q) ++ ",errors:" ++ Nat.show(List.length(&2,W.WorldError,errors)) ++ ",spare:" ++ s ++ "}")
def mail(owner:R.Mail) -> R.Mail & String:
  match owner:
    case R.Mail{returned,saved,quarantine,errors,spare}:mail_join(errors,counted(~R.Saved,saved),counted(~R.Quarantine,quarantine),raws(returned),K.tree(spare))
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
type Session is Type:Session{registry:R.Registry(),world:R.World(),context:K.Context<K.SchemaB>}
def session_join(registry:R.Registry() & String,world:R.World() & String,context:K.Context<K.SchemaB> & String) -> Session & String:
  match registry world context:
    case (reg,g),(world,w),(ctx,c):(Session{reg,world,ctx},"registry=" ++ g ++ "|world=" ++ w ++ "|context=" ++ c)
def session(owner:Session) -> Session & String:
  match owner:
    case Session{reg,w,ctx}:session_join(registry(reg),world(w),K.context_observe(~K.SchemaB,ctx))
