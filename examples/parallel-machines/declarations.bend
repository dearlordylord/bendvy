import Base
import ./payloads.bend as P
import ../../src/ecs/execution-machine-access.bend as Machine
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product

type Key is Data:
  Mode{}
type Mode is Data:
  Waiting{}
  Running{}
def same(left:Mode,right:Mode) -> Bool:
  match left right:
    case Waiting{} Waiting{}:True{}
    case Running{} Running{}:True{}
    case _ _:False{}
def layout(~S:Data) -> Layout.Layout:Machine.leaf(~S,~Key,~Mode,"mode")
def payload_proof(~S:Data) -> {Layout.payload(layout(~S),Layout.AtLeaf{}) == State.Cell<S,Key,Mode> : Type}:{==}
def view_proof(~S:Data) -> {Layout.view(layout(~S),Layout.AtLeaf{}) == State.View<S,Key,Mode> : Data}:{==}
def Resources(~S:Data) -> Type:Layout.resources(~S,layout(~S))
def actor_layout(~S:Data) -> Layout.Layout:Layout.LayoutLeaf{P.Actor<S,Mode>,Mode,P.actor(~S,~Mode),"actor-state"}
def peer_layout(~S:Data) -> Layout.Layout:Layout.LayoutLeaf{P.PeerActor<S,Mode>,Mode,P.peer(~S,~Mode),"peer-state"}
def component_layout(~S:Data) -> Layout.Layout:Layout.LayoutPair{actor_layout(~S),peer_layout(~S)}
def LeftStore(~S:Data) -> Type:Layout.columns(~S,actor_layout(~S))
def RightStore(~S:Data) -> Type:Layout.columns(~S,peer_layout(~S))
def Store(~S:Data) -> Type:Layout.columns(~S,component_layout(~S))
def read_ops(~S:Data) -> Type -> Type:Machine.Reads(~S,~Key,~Mode)
def read_selection(~S:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~LeftStore(~S),~Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~LeftStore(~S),~Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~LeftStore(~S),~Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~LeftStore(~S),~Resources(~S),~H,~B),~q:Build.Query(~S,~Store(~S),~LeftStore(~S),~Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~LeftStore(~S),~Resources(~S),~H,~B),book:B) -> B & read_ops(~S)(H):
  Machine.select_read(~S,~Key,~Mode,~LeftStore(~S),~Resources(~S),~H,~B,~layout(~S),~Layout.AtLeaf{},~{==},~{==},~view_proof(~S),~rr,book)
def read(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~LeftStore(~S),~Resources(~S),~H,~B),book:B) -> B & read_ops(~S)(H):
  builder(read_ops(~S),read_selection(~S,~H,~B),book)
def request_ops(~S:Data) -> Type -> Type:Machine.Writes(~S,~Key,~Mode)
def request_selection(~S:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~LeftStore(~S),~Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~LeftStore(~S),~Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~LeftStore(~S),~Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~LeftStore(~S),~Resources(~S),~H,~B),~q:Build.Query(~S,~Store(~S),~LeftStore(~S),~Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~LeftStore(~S),~Resources(~S),~H,~B),book:B) -> B & request_ops(~S)(H):
  Machine.select_write(~S,~Key,~Mode,~LeftStore(~S),~Resources(~S),~H,~B,~layout(~S),~Layout.AtLeaf{},~{==},~{==},~payload_proof(~S),~view_proof(~S),~same,~rw,book)
def request(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~LeftStore(~S),~Resources(~S),~H,~B),book:B) -> B & request_ops(~S)(H):
  builder(request_ops(~S),request_selection(~S,~H,~B),book)
def apply_ops(~S:Data) -> Type -> Type:Machine.Applies(~S,~Key,~Mode)
def apply_selection(~S:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~LeftStore(~S),~Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~LeftStore(~S),~Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~LeftStore(~S),~Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~LeftStore(~S),~Resources(~S),~H,~B),~q:Build.Query(~S,~Store(~S),~LeftStore(~S),~Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~LeftStore(~S),~Resources(~S),~H,~B),book:B) -> B & apply_ops(~S)(H):
  Machine.select_apply(~S,~Key,~Mode,~LeftStore(~S),~Resources(~S),~H,~B,~layout(~S),~Layout.AtLeaf{},~{==},~{==},~payload_proof(~S),~view_proof(~S),~same,~rw,book)
def apply(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~LeftStore(~S),~Resources(~S),~H,~B),book:B) -> B & apply_ops(~S)(H):
  builder(apply_ops(~S),apply_selection(~S,~H,~B),book)
