import Base
import ../bend-candidate/query-consumer.bend as A
import check-state-garden.bend as R
import ../bend-candidate/full-v2/optional-resource.bend as Slot
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/lifecycle.bend as L

# Exact owner-preserving whole-world serialization for the closed fixture:
# plain Column, arbitrary complete payload/resource Array trees, and no pending
# closures. A non-plain column or nonempty pending list emits a rejection marker
# that cannot match the full independent oracle. No owner is cloned or dropped.
def leaf(~T:Type,result:T & String) -> Array<T> & String:
  (owner,text)=result
  (ALeaf{owner},"L(" ++ text ++ ")")
def joined_right(~T:Type,left:Array<T>,text:String,result:Array<T> & String) -> Array<T> & String:
  (right,rest)=result
  (ANode{left,right},"N(" ++ text ++ "," ++ rest ++ ")")
def joined_left(~T:Type,right:Array<T> & String,result:Array<T> & String) -> Array<T> & String:
  (left,text)=result
  joined_right(~T,left,text,right)
def tree(~T:Type,~project:T -> T & String,owner:Array<T>) -> Array<T> & String:
  match owner:
    case ALeaf{value}:leaf(~T,project(value))
    case ANode{a,b}:joined_left(~T,tree(~T,~project,b),tree(~T,~project,a))
def u32(value:U32) -> U32 & String:
  match value:
    case +value:(value,U32.show(value))
def boolean(value:Bool) -> Bool & String:
  match value:
    case True{}:(True{},"true")
    case False{}:(False{},"false")
def payload_done(result:Array<U32> & String) -> A.Payload & String:
  (cells,text)=result
  (A.Payload{cells},text)
def payload(value:A.Payload) -> A.Payload & String:
  match value:
    case A.Payload{cells}:payload_done(tree(~U32,~u32,cells))
def optional_done(result:A.Payload & String) -> Maybe<&1,A.Payload> & String:
  (owner,text)=result
  (Some{owner},"Some(" ++ text ++ ")")
def optional(value:Maybe<&1,A.Payload>) -> Maybe<&1,A.Payload> & String:
  match value:
    case None{}:(None{},"None")
    case Some{owner}:optional_done(payload(owner))
def entry(value:L.Entry) -> String:
  match value:
    case L.Entry{id,L.Stamp{added,changed}}:U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def store_done(+stamps:List<&2,L.Entry>,result:Array<Maybe<&1,A.Payload>> & String) -> A.Store & String:
  (values,text)=result
  (A.Store{Col.Column{values,stamps}},"Column(" ++ text ++ ";stamps=" ++ List.show(&2,L.Entry,entry,stamps) ++ ")")
def project_store(value:A.Store) -> A.Store & String:
  match value:
    case A.Store{Col.Column{values,stamps}}:store_done(stamps,tree(~Maybe<&1,A.Payload>,~optional,values))
    case A.Store{column}:(A.Store{column},"REJECT_NON_PLAIN_COLUMN")
def slot_done(result:Array<U32> & String) -> Slot.Slot<A.Resource> & String:
  (cells,text)=result
  (Slot.Present{A.Resource{cells}},"Present(" ++ text ++ ")")
def slot(value:Slot.Slot<A.Resource>) -> Slot.Slot<A.Resource> & String:
  match value:
    case Slot.Absent{}:(Slot.Absent{},"Absent")
    case Slot.Present{A.Resource{cells}}:slot_done(tree(~U32,~u32,cells))
def shown_diagnostic(value:R.Diagnostic) -> String:
  match value:
    case R.Diagnostic{snapshot,before,after,same,allowed,ran,checks}:"snapshot={" ++ snapshot ++ "};before={" ++ before ++ "};after={" ++ after ++ "};same=" ++ Bool.show(same) ++ ";allowed=" ++ Bool.show(allowed) ++ ";ran=" ++ U32.show(ran) ++ ";checks=" ++ U32.show(checks)
def resource_done(+diagnostic:R.Diagnostic,result:Slot.Slot<A.Resource> & String) -> R.Resources & String:
  (score,text)=result
  (R.Resources{score,diagnostic},"score=" ++ text ++ ";diagnostic=(" ++ shown_diagnostic(diagnostic) ++ ")")
def project_resource(value:R.Resources) -> R.Resources & String:
  match value:
    case R.Resources{score,diagnostic}:resource_done(diagnostic,slot(score))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x => x,access)
def finished(+namespace:U32,+nextId:U32,+highWater:U32,live:Array<Bool>,liveText:String,+capacity:U32,+depth:Nat,store:A.Store,storeText:String,+events:List<&2,U32>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,result:R.Resources & String) -> W.World<A.Schema,A.Store,R.Resources,U32> & String:
  (resource,resourceText)=result
  (W.World{namespace,nextId,highWater,live,capacity,depth,store,resource,events,[],registrations,nextSystemId,clock},"ns=" ++ U32.show(namespace) ++ ";next=" ++ U32.show(nextId) ++ ";high=" ++ U32.show(highWater) ++ ";live=" ++ liveText ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";store=" ++ storeText ++ ";resource=(" ++ resourceText ++ ");events=" ++ List.show(&2,U32,U32.show,events) ++ ";pending=[];registrations=" ++ List.show(&2,W.RegistrationMeta,registration,registrations) ++ ";nextSystem=" ++ U32.show(nextSystemId) ++ ";clock=" ++ U32.show(clock))
def stored(+namespace:U32,+nextId:U32,+highWater:U32,live:Array<Bool>,liveText:String,+capacity:U32,+depth:Nat,resource:R.Resources,+events:List<&2,U32>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,result:A.Store & String) -> W.World<A.Schema,A.Store,R.Resources,U32> & String:
  (store,storeText)=result
  finished(namespace,nextId,highWater,live,liveText,capacity,depth,store,storeText,events,registrations,nextSystemId,clock,project_resource(resource))
def lived(+namespace:U32,+nextId:U32,+highWater:U32,+capacity:U32,+depth:Nat,store:A.Store,resource:R.Resources,+events:List<&2,U32>,+registrations:List<&2,W.RegistrationMeta>,+nextSystemId:U32,+clock:U32,result:Array<Bool> & String) -> W.World<A.Schema,A.Store,R.Resources,U32> & String:
  (live,liveText)=result
  stored(namespace,nextId,highWater,live,liveText,capacity,depth,resource,events,registrations,nextSystemId,clock,project_store(store))
def world(value:W.World<A.Schema,A.Store,R.Resources,U32>) -> W.World<A.Schema,A.Store,R.Resources,U32> & String:
  match value:
    case W.World{+namespace,+nextId,+highWater,live,+capacity,+depth,store,resource,+events,[],+registrations,+nextSystemId,+clock}:lived(namespace,nextId,highWater,capacity,depth,store,resource,events,registrations,nextSystemId,clock,tree(~Bool,~boolean,live))
    case world:(world,"REJECT_NONEMPTY_PENDING")
