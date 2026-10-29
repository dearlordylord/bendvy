import Base
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-service.bend as Service
import ../../src/ecs/world.bend as W

def project(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def refresh(owner:Service.Slot<Array<U32>>) -> Service.Slot<Array<U32>> & Service.Status<U32>:Service.refresh(~Array<U32>,~U32,~project,owner)
def layout() -> Layout.Layout:Layout.LayoutLeaf{Service.Slot<Array<U32>>,Service.Status<U32>,refresh,"host",Policy.Ordinary{}}
def Resources() -> Type:Layout.resources(~Unit,layout())
def World() -> Type:W.World<Unit,Unit,Resources(),Unit>
def empty(_:Unit) -> Unit:Unit{}
def id(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def observed(incoming:Array<U32>,world:World()) -> String:
  match world:
    case W.World{_,_,_,Layout.ResourceSlot{Layout.Viewed{Service.Provided{owner},Service.Status{Some{cached}}},_},_,_,_,_,_,lifecycle}:"provided=" ++ id(Array.get(U32,owner,0)) ++ ";cache=" ++ U32.show(cached) ++ ";refused=" ++ id(Array.get(U32,incoming,0))
    case _:"unexpected-world"
def refused(result:Service.Provision<World(),Array<U32>>) -> String:
  match result:
    case Service.ProvisionRefused{world,incoming}:observed(incoming,world)
    case _:"unexpected-provision"
def first(result:Service.Provision<World(),Array<U32>>) -> String:
  match result:
    case Service.Provisioned{world}:refused(Service.provide(~Unit,~Unit,~Resources(),~Unit,~Array<U32>,~layout(),~Layout.AtLeaf{},~{==},~{==},~{==},world,ALeaf{202}))
    case _:"unexpected-first"
def created(result:W.Creation<Unit,Unit,Resources(),Unit>) -> String:
  match result:
    case W.Created{_,world}:first(Service.provide(~Unit,~Unit,~Resources(),~Unit,~Array<U32>,~layout(),~Layout.AtLeaf{},~{==},~{==},~{==},world,ALeaf{101}))
    case _:"unexpected-creation"
def main() -> IO(Unit):
  IO.print(created(W.create(~Unit,~Unit,~Resources(),~Unit,~empty,W.factory(),Layout.ResourceSlot{Layout.initialize(layout(),Layout.AtLeaf{},Service.Missing{}),Layout.unknown_stamp()})))
