import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/source/source-v1/experiments/public-bundles/prototype.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/bundle-pack.bend as BPack
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/bundle-component-install.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as L
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/source/source-v1/experiments/public-bundles/constructor-control.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as S
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/common20-timing-v1/current-ordinary-v1/owner-data-format-v1/current-classification-v1/source/source-v1/experiments/public-bundles/fallible-spawn.bend as Spawn

type Schema is Data:
  Schema{}
type Token is Data:
  Token{}
type Returned is Type:
  Original{raw:BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>}
  Unassembled{pack:BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>>,queued:List<Array<U32>>,undo:BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>> -> BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>}
type Packet is Type:
  Packet{cooked:BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>>,undo:BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>> -> BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>}
type Installed is Type:
  Installed{inverse:W.World<Schema,Store,Mail,U32> -> F.Restore<W.World<Schema,Store,Mail,U32>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>>>>,queued:List<Array<U32>>,undo:BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>> -> BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>}
type Quarantine is Type:
  Quarantine{recovery:F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>>>,queued:List<Array<U32>>,undo:BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>> -> BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>}
type Mail is Type:
  Mail{context:K.Context,returned:List<Returned>,installed:List<Installed>,quarantine:List<Quarantine>,errors:List<&2,Maybe<&2,String>>}
type Store is Type:
  Store{a:Col.Column<Schema,Array<U32>>,front:Col.Column<Schema,Array<U32>>,b:Col.Column<Schema,Array<U32>>,tag:Col.Column<Schema,K.Tag>,value:Col.Column<Schema,U32>}
def array_join(left:Array<U32> & List<&2,U32>,right:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  (left,a)=left
  (right,b)=right
  (ANode{left,right},List.append(&2,U32,a,b))
def project_array(owner:Array<U32>) -> Array<U32> & List<&2,U32>:
  match owner:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: array_join(project_array(left),project_array(right))
def project_tag(owner:K.Tag) -> K.Tag & Unit:
  (owner,Unit{})
def project_value(value:U32) -> U32 & U32:
  +copy=value
  (copy,copy)
def identity_a() -> Identity.Declaration<Schema,Array<U32>>:Identity.component(~Schema,~Array<U32>,"a")
def identity_front() -> Identity.Declaration<Schema,Array<U32>>:Identity.component(~Schema,~Array<U32>,"front")
def identity_b() -> Identity.Declaration<Schema,Array<U32>>:Identity.component(~Schema,~Array<U32>,"b")
def identity_tag() -> Identity.Declaration<Schema,K.Tag>:Identity.component(~Schema,~K.Tag,"tag")
def identity_value() -> Identity.Declaration<Schema,U32>:Identity.component(~Schema,~U32,"value")
type Rest_front is Type:
  Rest_front{a:Col.Column<Schema,Array<U32>>,b:Col.Column<Schema,Array<U32>>,tag:Col.Column<Schema,K.Tag>,value:Col.Column<Schema,U32>}
def take_front(store:Store) -> Rest_front & Col.Column<Schema,Array<U32>>:
  match store:
    case Store{a,front,b,tag,value}:(Rest_front{a,b,tag,value},front)
def put_front(rest:Rest_front,column:Col.Column<Schema,Array<U32>>) -> Store:
  match rest:
    case Rest_front{a,b,tag,value}:Store{a,column,b,tag,value}
def family_front() -> C.Family<Schema,Store,Rest_front,Array<U32>,List<&2,U32>,Token,take_front,put_front,project_array>:C.Family{Identity.key(~Schema,~Array<U32>,identity_front())}
def install_front(world:W.World<Schema,Store,Mail,U32>,entry:I.Entry<Schema,Array<U32>>) -> F.Attempt<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>>:
  I.install(~Schema,~Store,~Mail,~U32,~Rest_front,~Array<U32>,~List<&2,U32>,~Token,~take_front,~put_front,~project_array,family_front(),world,entry)
type Rest_a is Type:
  Rest_a{front:Col.Column<Schema,Array<U32>>,b:Col.Column<Schema,Array<U32>>,tag:Col.Column<Schema,K.Tag>,value:Col.Column<Schema,U32>}
def take_a(store:Store) -> Rest_a & Col.Column<Schema,Array<U32>>:
  match store:
    case Store{a,front,b,tag,value}: (Rest_a{front,b,tag,value},a)
def put_a(rest:Rest_a,column:Col.Column<Schema,Array<U32>>) -> Store:
  match rest:
    case Rest_a{front,b,tag,value}: Store{column,front,b,tag,value}
def family_a() -> C.Family<Schema,Store,Rest_a,Array<U32>,List<&2,U32>,Token,take_a,put_a,project_array>:
  C.Family{Identity.key(~Schema,~Array<U32>,identity_a())}
def install_a(world:W.World<Schema,Store,Mail,U32>,entry:I.Entry<Schema,Array<U32>>) -> F.Attempt<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>>:
  I.install(~Schema,~Store,~Mail,~U32,~Rest_a,~Array<U32>,~List<&2,U32>,~Token,~take_a,~put_a,~project_array,family_a(),world,entry)
type Rest_b is Type:
  Rest_b{a:Col.Column<Schema,Array<U32>>,front:Col.Column<Schema,Array<U32>>,tag:Col.Column<Schema,K.Tag>,value:Col.Column<Schema,U32>}
def take_b(store:Store) -> Rest_b & Col.Column<Schema,Array<U32>>:
  match store:
    case Store{a,front,b,tag,value}: (Rest_b{a,front,tag,value},b)
def put_b(rest:Rest_b,column:Col.Column<Schema,Array<U32>>) -> Store:
  match rest:
    case Rest_b{a,front,tag,value}: Store{a,front,column,tag,value}
def family_b() -> C.Family<Schema,Store,Rest_b,Array<U32>,List<&2,U32>,Token,take_b,put_b,project_array>:
  C.Family{Identity.key(~Schema,~Array<U32>,identity_b())}
def install_b(world:W.World<Schema,Store,Mail,U32>,entry:I.Entry<Schema,Array<U32>>) -> F.Attempt<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>>:
  I.install(~Schema,~Store,~Mail,~U32,~Rest_b,~Array<U32>,~List<&2,U32>,~Token,~take_b,~put_b,~project_array,family_b(),world,entry)
type Rest_tag is Type:
  Rest_tag{a:Col.Column<Schema,Array<U32>>,front:Col.Column<Schema,Array<U32>>,b:Col.Column<Schema,Array<U32>>,value:Col.Column<Schema,U32>}
def take_tag(store:Store) -> Rest_tag & Col.Column<Schema,K.Tag>:
  match store:
    case Store{a,front,b,tag,value}: (Rest_tag{a,front,b,value},tag)
def put_tag(rest:Rest_tag,column:Col.Column<Schema,K.Tag>) -> Store:
  match rest:
    case Rest_tag{a,front,b,value}: Store{a,front,b,column,value}
def family_tag() -> C.Family<Schema,Store,Rest_tag,K.Tag,Unit,Token,take_tag,put_tag,project_tag>:
  C.Family{Identity.key(~Schema,~K.Tag,identity_tag())}
def install_tag(world:W.World<Schema,Store,Mail,U32>,entry:I.Entry<Schema,K.Tag>) -> F.Attempt<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>>:
  I.install(~Schema,~Store,~Mail,~U32,~Rest_tag,~K.Tag,~Unit,~Token,~take_tag,~put_tag,~project_tag,family_tag(),world,entry)
type Rest_value is Type:
  Rest_value{a:Col.Column<Schema,Array<U32>>,front:Col.Column<Schema,Array<U32>>,b:Col.Column<Schema,Array<U32>>,tag:Col.Column<Schema,K.Tag>}
def take_value(store:Store) -> Rest_value & Col.Column<Schema,U32>:
  match store:
    case Store{a,front,b,tag,value}: (Rest_value{a,front,b,tag},value)
def put_value(rest:Rest_value,column:Col.Column<Schema,U32>) -> Store:
  match rest:
    case Rest_value{a,front,b,tag}: Store{a,front,b,tag,column}
def family_value() -> C.Family<Schema,Store,Rest_value,U32,U32,Token,take_value,put_value,project_value>:
  C.Family{Identity.key(~Schema,~U32,identity_value())}
def install_value(world:W.World<Schema,Store,Mail,U32>,entry:I.Entry<Schema,U32>) -> F.Attempt<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>>:
  I.install(~Schema,~Store,~Mail,~U32,~Rest_value,~U32,~U32,~Token,~take_value,~put_value,~project_value,family_value(),world,entry)
def install_5(world:W.World<Schema,Store,Mail,U32>,tail:Unit) -> F.Attempt<W.World<Schema,Store,Mail,U32>,Unit,Unit>:
  F.terminal(~W.World<Schema,Store,Mail,U32>,world,tail)
def install_4(world:W.World<Schema,Store,Mail,U32>,tail:BPack.Pack<I.Entry<Schema,U32>,Unit>) -> F.Attempt<W.World<Schema,Store,Mail,U32>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>:
  F.install(~W.World<Schema,Store,Mail,U32>,~I.Entry<Schema,U32>,~I.Recovery<Schema,U32>,~Unit,~Unit,~install_value,~install_5,world,tail)
def install_3(world:W.World<Schema,Store,Mail,U32>,tail:BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>) -> F.Attempt<W.World<Schema,Store,Mail,U32>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>:
  F.install(~W.World<Schema,Store,Mail,U32>,~I.Entry<Schema,K.Tag>,~I.Recovery<Schema,K.Tag>,~BPack.Pack<I.Entry<Schema,U32>,Unit>,~F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>,~install_tag,~install_4,world,tail)
def install_2(world:W.World<Schema,Store,Mail,U32>,tail:BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>) -> F.Attempt<W.World<Schema,Store,Mail,U32>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>>:
  F.install(~W.World<Schema,Store,Mail,U32>,~I.Entry<Schema,Array<U32>>,~I.Recovery<Schema,Array<U32>>,~BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,~F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>,~install_b,~install_3,world,tail)
def install_1(world:W.World<Schema,Store,Mail,U32>,tail:BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>) -> F.Attempt<W.World<Schema,Store,Mail,U32>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>>>:
  F.install(~W.World<Schema,Store,Mail,U32>,~I.Entry<Schema,Array<U32>>,~I.Recovery<Schema,Array<U32>>,~BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,~F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>,~install_front,~install_2,world,tail)
def install_0(world:W.World<Schema,Store,Mail,U32>,tail:BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>>) -> F.Attempt<W.World<Schema,Store,Mail,U32>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>>>>:
  F.install(~W.World<Schema,Store,Mail,U32>,~I.Entry<Schema,Array<U32>>,~I.Recovery<Schema,Array<U32>>,~BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>,~F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>>,~install_a,~install_1,world,tail)
def rebuild(pack:BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>>,queued:List<Array<U32>>,undo:BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>> -> BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> Returned:
  match pack:
    case BPack.Pack{I.Entry{_,Some{a}},BPack.Pack{I.Entry{_,Some{front}},BPack.Pack{I.Entry{_,Some{back}},BPack.Pack{I.Entry{_,Some{tag}},BPack.Pack{I.Entry{_,Some{value}},Unit{}}}}}}: Original{undo(BPack.Pack{K.Cooked{a},BPack.Pack{K.Cooked{value},BPack.Pack{K.Cooked{tag},BPack.Pack{K.Cooked{K.QueueOwner{front,back,queued}},Unit{}}}}})}
    case pack: Unassembled{pack,queued,undo}
def returned(world:W.World<Schema,Store,Mail,U32>,result:Returned,error:String) -> W.World<Schema,Store,Mail,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{context,items,installed,quarantine,errors},events,commands,regs,system,clock}: W.World{ns,next,high,live,cap,depth,store,Mail{context,result <> items,installed,quarantine,[Some{error}]},events,commands,regs,system,clock}
def recorded(world:W.World<Schema,Store,Mail,U32>,inverse:W.World<Schema,Store,Mail,U32> -> F.Restore<W.World<Schema,Store,Mail,U32>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>>>>,queued:List<Array<U32>>,undo:BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>> -> BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> W.World<Schema,Store,Mail,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{context,items,installed,quarantine,errors},events,commands,regs,system,clock}: W.World{ns,next,high,live,cap,depth,store,Mail{context,items,Installed{inverse,queued,undo} <> installed,quarantine,errors},events,commands,regs,system,clock}
def quarantined(world:W.World<Schema,Store,Mail,U32>,recovery:F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>>>,queued:List<Array<U32>>,undo:BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>> -> BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> W.World<Schema,Store,Mail,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{context,items,installed,pending,errors},events,commands,regs,system,clock}: W.World{ns,next,high,live,cap,depth,store,Mail{context,items,installed,Quarantine{recovery,queued,undo} <> pending,[Some{"quarantined"}]},events,commands,regs,system,clock}
def installed(queued:List<Array<U32>>,undo:BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>> -> BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,observed:F.Attempt<W.World<Schema,Store,Mail,U32>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>>>>) -> W.World<Schema,Store,Mail,U32>:
  match observed:
    case F.Installed{world,inverse}: recorded(world,inverse,queued,undo)
    case F.Refused{world,pack,error}: returned(world,rebuild(pack,queued,undo),"column-refusal")
    case F.Quarantined{world,recovery,error}: quarantined(world,recovery,queued,undo)
def populate(world:W.World<Schema,Store,Mail,U32>,handle:W.Handle<Schema>,packet:Packet) -> Spawn.Population<W.World<Schema,Store,Mail,U32>,Packet,String>:
  match packet:
    case Packet{BPack.Pack{K.Cooked{a},BPack.Pack{K.Cooked{value},BPack.Pack{K.Cooked{tag},BPack.Pack{K.Cooked{K.QueueOwner{front,back,queued}},Unit{}}}}},undo}:
      +target=handle
      Spawn.Populated{installed(queued,undo,install_0(world,BPack.Pack{I.Entry{target,Some{a}},BPack.Pack{I.Entry{target,Some{front}},BPack.Pack{I.Entry{target,Some{back}},BPack.Pack{I.Entry{target,Some{tag}},BPack.Pack{I.Entry{target,Some{value}},Unit{}}}}}}))}
def recover(world:W.World<Schema,Store,Mail,U32>,handle:W.Handle<Schema>,packet:Packet,error:Spawn.Failure<String>) -> W.World<Schema,Store,Mail,U32>:
  match packet:
    case Packet{cooked,undo}: returned(world,Original{undo(cooked)},"activation-refusal")
def committed(observed:T.Returned<W.World<Schema,Store,Mail,U32>,Unit>) -> W.World<Schema,Store,Mail,U32>:
  match observed:
    case T.Returned{world,_}: W.barrier(~Schema,~Store,~Mail,~U32,world)
def spawned(observed:B.SpawnResult<Schema,Store,Mail,U32,Packet>) -> W.World<Schema,Store,Mail,U32>:
  match observed:
    case B.SpawnQueued{tx,handle}: committed(Cmd.tx_finish(~Schema,~Store,~Mail,~U32,~Unit,tx,T.Success{}))
    case B.SpawnRefused{T.Tx{world,undo,commands,events},packet,error}: recover(world,W.Handle{1,0},packet,Spawn.ActivationFailure{error})
def staged(ns:U32,next:U32,high:U32,live:Array<Bool>,cap:U32,depth:Nat,store:Store,events:List<&2,U32>,commands:List<(W.World<Schema,Store,Mail,U32> -> W.World<Schema,Store,Mail,U32>)>,regs:List<&2,W.RegistrationMeta>,system:U32,clock:U32,observed:S.Staged<K.Context,BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>>,String>) -> W.World<Schema,Store,Mail,U32>:
  match observed:
    case S.Failed{context,raw,errors}: W.World{ns,next,high,live,cap,depth,store,Mail{context,[Original{raw}],[],[],errors},events,commands,regs,system,clock}
    case S.Valid{context,cooked,undo,errors}: spawned(Spawn.spawn(~Schema,~Store,~Mail,~U32,~Packet,~String,~populate,~recover,T.begin(~W.World<Schema,Store,Mail,U32>,~U32,W.World{ns,next,high,live,cap,depth,store,Mail{context,[],[],[],errors},events,commands,regs,system,clock}),Packet{cooked,undo}))
def staged_existing(ns:U32,next:U32,high:U32,live:Array<Bool>,cap:U32,depth:Nat,store:Store,events:List<&2,U32>,commands:List<(W.World<Schema,Store,Mail,U32> -> W.World<Schema,Store,Mail,U32>)>,regs:List<&2,W.RegistrationMeta>,system:U32,clock:U32,observed:S.Staged<K.Context,BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>>,String>) -> W.World<Schema,Store,Mail,U32>:
  match observed:
    case S.Failed{context,raw,errors}: W.World{ns,next,high,live,cap,depth,store,Mail{context,[Original{raw}],[],[],errors},events,commands,regs,system,clock}
    case S.Valid{context,cooked,undo,errors}: Spawn.deliver(~W.World<Schema,Store,Mail,U32>,~Schema,~Packet,~String,~recover,W.Handle{1,1},populate(W.World{ns,next,high,live,cap,depth,store,Mail{context,[],[],[],errors},events,commands,regs,system,clock},W.Handle{1,1},Packet{cooked,undo}))
def eager_existing(world:W.World<Schema,Store,Mail,U32>,raw:BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> W.World<Schema,Store,Mail,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{context,returned,installed,quarantine,errors},events,commands,regs,system,clock}: staged_existing(ns,next,high,live,cap,depth,store,events,commands,regs,system,clock,K.stage_0(context,raw))
def eager(world:W.World<Schema,Store,Mail,U32>,raw:BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> W.World<Schema,Store,Mail,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{context,returned,installed,quarantine,errors},events,commands,regs,system,clock}: staged(ns,next,high,live,cap,depth,store,events,commands,regs,system,clock,K.stage_0(context,raw))
def raw_fresh(clock:U32) -> W.World<Schema,Store,Mail,U32>:
  W.World{1,2,1,ANode{ALeaf{False{}},ALeaf{True{}}},2,1n+0n,Store{Col.Column{ALeaf{Some{ANode{ALeaf{1},ALeaf{2}}}},[L.Entry{1,L.Stamp{3,4}}]},Col.Column{ALeaf{None{}},[]},Col.Column{ALeaf{Some{ANode{ALeaf{5},ALeaf{6}}}},[L.Entry{1,L.Stamp{7,8}}]},Col.Column{ALeaf{None{}},[L.Entry{1,L.Stamp{0,0}}]},Col.Column{ALeaf{Some{9}},[L.Entry{1,L.Stamp{10,11}}]}},Mail{K.context(),[],[],[],[]},[],[],[],1,clock}
def fresh(clock:U32) -> W.World<Schema,Store,Mail,U32>:
  W.enqueue(~Schema,~Store,~Mail,~U32,raw_fresh(clock),w => W.event_publish(~Schema,~Store,~Mail,~U32,w,[77]))
def array_cells(owner:Array<U32>) -> List<&2,U32>:
  match owner:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,U32,array_cells(left),array_cells(right))
def array_text(owner:Array<U32>) -> String:
  List.show(&2,U32,U32.show,array_cells(owner))
def tag_text(tag:K.Tag) -> String:
  "tag"
def maybe_text(~Owner:Type,~show:Owner -> String,owner:Maybe<&1,Owner>) -> String:
  match owner:
    case None{}: "absent"
    case Some{owner}: show(owner)
def stamp_text(stamp:L.Entry) -> String:
  match stamp:
    case L.Entry{id,L.Stamp{added,changed}}: U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed)
def text_identity(text:String) -> String:
  text
def physical(~Owner:Type,~show:Owner -> String,values:Array<Maybe<&1,Owner>>) -> List<&2,String>:
  match values:
    case ALeaf{owner}: [maybe_text(~Owner,~show,owner)]
    case ANode{left,right}: List.append(&2,String,physical(~Owner,~show,left),physical(~Owner,~show,right))
def column_text(~Owner:Type,~show:Owner -> String,column:Col.Column<Schema,Owner>) -> String:
  match column:
    case Col.Column{values,stamps}: List.show(&2,String,text_identity,physical(~Owner,~show,values)) ++ "@" ++ List.show(&2,L.Entry,stamp_text,stamps)
    case _: "unexpected representation"
def bool_cells(values:Array<Bool>) -> List<&2,Bool>:
  match values:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,Bool,bool_cells(left),bool_cells(right))
def world_text(world:W.World<Schema,Store,Mail,U32>) -> String:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,Store{a,front,b,tag,value},resource,+events,pending,+regs,+system,+clock}: column_text(~Array<U32>,~array_text,a) ++ "|front=" ++ column_text(~Array<U32>,~array_text,front) ++ "|" ++ column_text(~Array<U32>,~array_text,b) ++ "|" ++ column_text(~K.Tag,~tag_text,tag) ++ "|" ++ column_text(~U32,~U32.show,value) ++ "|clock=" ++ U32.show(clock) ++ "|live=" ++ List.show(&2,Bool,Bool.show,bool_cells(live)) ++ "|ns=" ++ U32.show(ns) ++ "|next=" ++ U32.show(next) ++ "|high=" ++ U32.show(high) ++ "|capacity=" ++ U32.show(cap) ++ "|events=" ++ List.show(&2,U32,U32.show,events)
def restored(queued:List<Array<U32>>,undo:BPack.Pack<K.Cooked<Array<U32>>,BPack.Pack<K.Cooked<U32>,BPack.Pack<K.Cooked<K.Tag>,BPack.Pack<K.Cooked<K.QueueOwner>,Unit>>>> -> BPack.Pack<K.Raw<Array<U32>>,BPack.Pack<K.Raw<U32>,BPack.Pack<K.Raw<K.Tag>,BPack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,result:F.Restore<W.World<Schema,Store,Mail,U32>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,Array<U32>>,I.Recovery<Schema,Array<U32>>,BPack.Pack<I.Entry<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,K.Tag>,I.Recovery<Schema,K.Tag>,BPack.Pack<I.Entry<Schema,U32>,Unit>,F.Recovery<W.World<Schema,Store,Mail,U32>,I.Entry<Schema,U32>,I.Recovery<Schema,U32>,Unit,Unit>>>>>>) -> W.World<Schema,Store,Mail,U32>:
  match result:
    case F.Restored{world,pack}: returned(world,rebuild(pack,queued,undo),"unwound")
    case F.Pending{world,recovery,error}: quarantined(world,recovery,queued,undo)
def unwind(world:W.World<Schema,Store,Mail,U32>) -> W.World<Schema,Store,Mail,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{context,items,Installed{inverse,queued,undo} <> rest,quarantine,errors},events,commands,regs,system,clock}: restored(queued,undo,inverse(W.World{ns,next,high,live,cap,depth,store,Mail{context,items,rest,quarantine,errors},events,commands,regs,system,clock}))
    case world: world
def retry(world:W.World<Schema,Store,Mail,U32>) -> W.World<Schema,Store,Mail,U32>:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{context,Original{raw} <> rest,installed,quarantine,errors},events,commands,regs,system,clock}: eager_existing(W.World{ns,next,high,live,cap,depth,store,Mail{context,rest,installed,quarantine,errors},events,commands,regs,system,clock},raw)
    case world: world
def context_text(context:K.Context) -> String:
  match context:
    case K.Context{calls,order}: List.show(&2,U32,U32.show,K.cells(calls)) ++ "/" ++ List.show(&2,U32,U32.show,order)
def returned_text(items:List<Returned>) -> String:
  match items:
    case []: "[]"
    case Original{raw} <> rest: "[" ++ K.raw_0(raw) ++ "]" ++ returned_text(rest)
    case Unassembled{pack,queued,undo} <> rest: "UNASSEMBLED"
def count(~Owner:Type,items:List<Owner>) -> U32:
  match items:
    case []: 0
    case head <> tail: (1 + count(~Owner,tail):U32)
def snapshot(world:W.World<Schema,Store,Mail,U32>) -> String:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,Mail{context,items,installed,quarantine,+errors},+events,commands,+regs,+system,+clock}: world_text(W.World{ns,next,high,live,cap,depth,store,Mail{K.context(),[],[],[],[]},events,[],regs,system,clock}) ++ "|context=" ++ context_text(context) ++ "|raw=" ++ returned_text(items) ++ "|installed=" ++ U32.show(count(~Installed,installed)) ++ "|quarantine=" ++ U32.show(count(~Quarantine,quarantine)) ++ "|pending=" ++ U32.show(count(~(W.World<Schema,Store,Mail,U32> -> W.World<Schema,Store,Mail,U32>),commands)) ++ "|errors=" ++ List.show(&2,Maybe<&2,String>,K.error_view,errors)
def main() -> IO(Unit):
  IO.print("invalid=" ++ snapshot(eager(fresh(20),K.input(False{},False{}))) ++ "\ninvalid-after=" ++ snapshot(W.barrier(~Schema,~Store,~Mail,~U32,eager(fresh(20),K.input(False{},False{})))) ++ "\ninstalled=" ++ snapshot(eager(fresh(20),K.input(True{},True{}))) ++ "\nunwind=" ++ snapshot(unwind(eager(fresh(20),K.input(True{},True{})))) ++ "\nrefused=" ++ snapshot(eager(fresh(4294967293),K.input(True{},True{}))))
