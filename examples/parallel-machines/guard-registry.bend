import Base
import ./declarations.bend as D
import ./conditions.bend as Cond
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog

def World(~S:Data) -> Type:W.World<S,D.Store(~S),Cond.Resources(~S),Unit>
def Owner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),Cond.Resources(~S),Unit,D.read_ops(~S),Cond.Local,String,Bool,Cond.declaration(~S),Cond.body(~S)>
def GuardPair(~S:Data) -> Type:Reg.Product<Owner(~S),Owner(~S)>
def Owners(~S:Data) -> Type:Reg.Product<GuardPair(~S),GuardPair(~S)>
def leaf_dispatch(~S:Data) -> Prog.Dispatch(~World(~S),~Owner(~S),~String,~Bool):
  Reg.leaf_dispatch(~S,~D.Store(~S),~Cond.Resources(~S),~Unit,~D.read_ops(~S),~Cond.Local,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S))
def pair_dispatch(~S:Data) -> Prog.Dispatch(~World(~S),~GuardPair(~S),~String,~Bool):
  Reg.paired_dispatch(~World(~S),~Owner(~S),~Owner(~S),~String,~Bool,~leaf_dispatch(~S),~leaf_dispatch(~S))
def dispatch(~S:Data) -> Prog.Dispatch(~World(~S),~Owners(~S),~String,~Bool):
  Reg.paired_dispatch(~World(~S),~GuardPair(~S),~GuardPair(~S),~String,~Bool,~pair_dispatch(~S),~pair_dispatch(~S))
def leaf_selection(~S:Data,~F:Prog.Family(~String,~Bool),~leaf:Prog.Leaf(~String,~Bool,~F),~pair:Prog.Join(~String,~Bool,~F),~partition:Prog.Partition(~String,~Bool,~F),~rootcut:Prog.Rootcut(~String,~Bool,~F),~empty:Prog.Vacant(~String,~Bool,~F),owners:Owner(~S)) -> F(World(~S),Owner(~S),leaf_dispatch(~S)):
  Prog.leaf(~S,~D.Store(~S),~Cond.Resources(~S),~Unit,~D.read_ops(~S),~Cond.Local,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S),~F,~leaf,~pair,~partition,~rootcut,~empty,owners)
def pair_selection(~S:Data,~F:Prog.Family(~String,~Bool),~leaf:Prog.Leaf(~String,~Bool,~F),~pair:Prog.Join(~String,~Bool,~F),~partition:Prog.Partition(~String,~Bool,~F),~rootcut:Prog.Rootcut(~String,~Bool,~F),~empty:Prog.Vacant(~String,~Bool,~F),owners:GuardPair(~S)) -> F(World(~S),GuardPair(~S),pair_dispatch(~S)):
  Prog.paired(~World(~S),~Owner(~S),~Owner(~S),~String,~Bool,~leaf_dispatch(~S),~leaf_dispatch(~S),~leaf_selection(~S),~leaf_selection(~S),~F,~leaf,~pair,~partition,~rootcut,~empty,owners)
def selection(~S:Data,~F:Prog.Family(~String,~Bool),~leaf:Prog.Leaf(~String,~Bool,~F),~pair:Prog.Join(~String,~Bool,~F),~partition:Prog.Partition(~String,~Bool,~F),~rootcut:Prog.Rootcut(~String,~Bool,~F),~empty:Prog.Vacant(~String,~Bool,~F),owners:Owners(~S)) -> F(World(~S),Owners(~S),dispatch(~S)):
  Prog.paired(~World(~S),~GuardPair(~S),~GuardPair(~S),~String,~Bool,~pair_dispatch(~S),~pair_dispatch(~S),~pair_selection(~S),~pair_selection(~S),~F,~leaf,~pair,~partition,~rootcut,~empty,owners)
def unpacked(~S:Data,result:Reg.Registry<World(~S),Owners(~S),String,Bool,dispatch(~S)>) -> Owners(~S):
  match result:
    case Reg.Registry{owners,_}:owners
def pack(~S:Data,exit:Owner(~S),transition:Owner(~S),enter:Owner(~S),running:Owner(~S)) -> Owners(~S):
  unpacked(~S,Reg.paired(~World(~S),~GuardPair(~S),~GuardPair(~S),~String,~Bool,~pair_dispatch(~S),~pair_dispatch(~S),Reg.paired(~World(~S),~Owner(~S),~Owner(~S),~String,~Bool,~leaf_dispatch(~S),~leaf_dispatch(~S),Reg.leaf(~S,~D.Store(~S),~Cond.Resources(~S),~Unit,~D.read_ops(~S),~Cond.Local,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S),exit),Reg.leaf(~S,~D.Store(~S),~Cond.Resources(~S),~Unit,~D.read_ops(~S),~Cond.Local,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S),transition)),Reg.paired(~World(~S),~Owner(~S),~Owner(~S),~String,~Bool,~leaf_dispatch(~S),~leaf_dispatch(~S),Reg.leaf(~S,~D.Store(~S),~Cond.Resources(~S),~Unit,~D.read_ops(~S),~Cond.Local,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S),enter),Reg.leaf(~S,~D.Store(~S),~Cond.Resources(~S),~Unit,~D.read_ops(~S),~Cond.Local,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S),running))))
