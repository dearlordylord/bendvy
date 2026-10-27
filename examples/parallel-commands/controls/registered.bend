import Base
import ../../../src/ecs/execution-prepared.bend as Prep
import ../../../src/ecs/execution-command-permission.bend as Permission
import ../../../src/ecs/execution-command-removed.bend as Removed
import ./positive.bend as P
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-command-system.bend as Cmd
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../../src/ecs/execution-state.bend as State
import ../../../src/ecs/execution-command-local.bend as Local

def observed(result:Array<U32> & U32) -> P.Token & U32:
  match result:
    case (owner,value):(P.Token{owner},value)
def refresh(owner:P.Token) -> P.Token & U32:
  match owner:
    case P.Token{owner}:observed(Array.get(U32,owner,0))
def layout() -> Layout.Layout:Layout.LayoutLeaf{P.Token,U32,refresh,"token"}
def Ops(Permit:Data,H:Type,Q:Type) -> Type:Unit
def declaration(~S:Data,~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,P.Token>,~B:Type,~builder:Build.Builder(~S,~(Layout.columns(~S,layout())),~(Layout.columns(~S,layout())),~Unit,~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~S,~layout(),~Permit,~Q,~K),book:B,permission:K) -> B & (K & Unit):
  (book,(permission,Unit{}))
def Owner(~S:Data) -> Type:
  Cmd.Owner<S,Layout.columns(~S,layout()),Unit,Unit,layout(),Layout.AtLeaf{},Ops,P.Capture<S>,String,Unit,declaration(~S),P.body(~S)>
def selection(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~(Layout.columns(~S,layout())),~(Layout.columns(~S,layout())),~Unit,~Unit,~String,~Unit,~F),~command:Tree.CommandLeaf(~S,~(Layout.columns(~S,layout())),~(Layout.columns(~S,layout())),~Unit,~Unit,~String,~Unit,~F),~join:Tree.Join(~F),owner:Owner(~S)) -> F(Owner(~S)):
  command(layout(),Layout.AtLeaf{},{==},{==},Ops,P.Capture<S>,declaration(~S),P.body(~S),owner)
def registered(~S:Data,owner:Owner(~S)) -> Tree.Runtime<S,W.World<S,Layout.columns(~S,layout()),Unit,Unit>,Prep.Permit<S,Layout.columns(~S,layout())>,State.Scope<S,Layout.columns(~S,layout()),Unit>,Owner(~S),String,Unit>:
  Tree.compile(~S,~(Layout.columns(~S,layout())),~Unit,~Unit,~String,~Unit,~(Layout.columns(~S,layout())),~Unit,~Owner(~S),~selection(~S),owner)
