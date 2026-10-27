import Base
import ./declarations.bend as D
import ./conditions.bend as Cond
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-condition-registry.bend as Conditions

def World(~S:Data) -> Type:W.World<S,D.Store(~S),Cond.Resources(~S),Unit>
def program(~S:Data,~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~Cond.Resources(~S),~Permit,~H,~B),book:B) -> B & D.read_ops(~S)(Permit,H):
  Cond.declaration(~S,~Permit,~H,~B,~builder,book)
def System(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),Cond.Resources(~S),Unit,D.read_ops(~S),Cond.Local,String,Bool,program(~S),Cond.body(~S)>
def Compilation(~S:Data) -> Type:Decl.Compilation<S,D.Store(~S),D.Store(~S),Cond.Resources(~S),D.read_ops(~S)>
def construction(~S:Data) -> Compilation(~S):Build.compile_framework(~S,~D.Store(~S),~D.Store(~S),~Cond.Resources(~S),~D.read_ops(~S),~program(~S))
def Owner(~S:Data) -> Type:Conditions.RetainedSystem(~S,~D.Store(~S),~Cond.Resources(~S),~Unit,~D.read_ops(~S),~Cond.Local,~String,~program(~S),~Cond.body(~S))
def define(~S:Data,world:World(~S),name:String,local:Cond.Local) -> Compilation(~S) & Sys.Defined<World(~S),System(~S),Cond.Local>:
  Task.define_with_compilation(~S,~D.Store(~S),~D.Store(~S),~Cond.Resources(~S),~Unit,~D.read_ops(~S),~Cond.Local,~String,~Bool,~program(~S),~Cond.body(~S),~Cond.Resources(~S),construction(~S),world,name,local)
def GuardPair(~S:Data) -> Type:Reg.Product<Owner(~S),Owner(~S)>
def Owners(~S:Data) -> Type:Reg.Product<GuardPair(~S),GuardPair(~S)>
def leaf_dispatch(~S:Data) -> Conditions.Dispatch(~World(~S),~Owner(~S),~String):
  Conditions.retained_leaf_dispatch(~S,~D.Store(~S),~Cond.Resources(~S),~Unit,~D.read_ops(~S),~Cond.Local,~String,~program(~S),~Cond.body(~S),~construction(~S))
def pair_dispatch(~S:Data) -> Conditions.Dispatch(~World(~S),~GuardPair(~S),~String):
  Conditions.paired_dispatch(~World(~S),~Owner(~S),~Owner(~S),~String,~leaf_dispatch(~S),~leaf_dispatch(~S))
def dispatch(~S:Data) -> Conditions.Dispatch(~World(~S),~Owners(~S),~String):
  Conditions.paired_dispatch(~World(~S),~GuardPair(~S),~GuardPair(~S),~String,~pair_dispatch(~S),~pair_dispatch(~S))
def leaf_selection(~S:Data,~F:Conditions.Family(~String),~leaf:Conditions.RetainedLeaf(~String,~F),~pair:Conditions.Join(~String,~F),~empty:Conditions.Vacant(~String,~F),owner:Owner(~S)) -> F(World(~S),Owner(~S),leaf_dispatch(~S)):
  leaf(S,D.Store(~S),Cond.Resources(~S),Unit,D.read_ops(~S),Cond.Local,program(~S),Cond.body(~S),construction(~S),owner)
def pair_selection(~S:Data,~F:Conditions.Family(~String),~leaf:Conditions.RetainedLeaf(~String,~F),~pair:Conditions.Join(~String,~F),~empty:Conditions.Vacant(~String,~F),owners:GuardPair(~S)) -> F(World(~S),GuardPair(~S),pair_dispatch(~S)):
  match owners:
    case Reg.Product{left,right,_}:pair(World(~S),Owner(~S),Owner(~S),leaf_dispatch(~S),leaf_dispatch(~S),leaf_selection(~S,~F,~leaf,~pair,~empty,left),leaf_selection(~S,~F,~leaf,~pair,~empty,right))
def selection(~S:Data,~F:Conditions.Family(~String),~leaf:Conditions.RetainedLeaf(~String,~F),~pair:Conditions.Join(~String,~F),~empty:Conditions.Vacant(~String,~F),owners:Owners(~S)) -> F(World(~S),Owners(~S),dispatch(~S)):
  match owners:
    case Reg.Product{left,right,_}:pair(World(~S),GuardPair(~S),GuardPair(~S),pair_dispatch(~S),pair_dispatch(~S),pair_selection(~S,~F,~leaf,~pair,~empty,left),pair_selection(~S,~F,~leaf,~pair,~empty,right))
def leaf_registry(~S:Data,owner:Owner(~S)) -> Conditions.Registry<World(~S),Owner(~S),String,leaf_dispatch(~S)>:
  Conditions.compile_retained_leaf(~String,~S,~D.Store(~S),~Cond.Resources(~S),~Unit,~D.read_ops(~S),~Cond.Local,~program(~S),~Cond.body(~S),~construction(~S),owner)
def unpacked(~S:Data,result:Conditions.Registry<World(~S),Owners(~S),String,dispatch(~S)>) -> Owners(~S):
  match result:
    case Conditions.Registry{owners,_,_}:owners
def pack(~S:Data,exit:Owner(~S),transition:Owner(~S),enter:Owner(~S),running:Owner(~S)) -> Owners(~S):
  unpacked(~S,Conditions.compile_join(~String,~World(~S),~GuardPair(~S),~GuardPair(~S),~pair_dispatch(~S),~pair_dispatch(~S),Conditions.compile_join(~String,~World(~S),~Owner(~S),~Owner(~S),~leaf_dispatch(~S),~leaf_dispatch(~S),leaf_registry(~S,exit),leaf_registry(~S,transition)),Conditions.compile_join(~String,~World(~S),~Owner(~S),~Owner(~S),~leaf_dispatch(~S),~leaf_dispatch(~S),leaf_registry(~S,enter),leaf_registry(~S,running))))
