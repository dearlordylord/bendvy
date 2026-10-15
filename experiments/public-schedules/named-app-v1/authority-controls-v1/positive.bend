import Base
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ./common.bend as C
import ../../../../src/ecs/ordinary-app-local-fields.bend as LF
import ../../../../src/ecs/world.bend as W
# C/R/Local/Args/Out are all affine Type owners, not Data.
def instantiate(world:W.World<C.Workshop,C.Cell,C.Cell,Unit>,local:C.Cell) -> LF.Registration<W.World<C.Workshop,C.Cell,C.Cell,Unit>,C.Owner(~C.Workshop),C.Cell>:
  LF.define(~C.Workshop,~C.Cell,~C.Cell,~Unit,~C.Cell,~C.Cell,~String,~C.Cell,~C.Ops,~C.declaration(~C.Workshop,"Counter"),~C.body,world,"Ordinary",local)
def fields(owner:C.Owner(~C.Workshop)) -> C.Owner(~C.Workshop) & Fields.Fields<C.Workshop>:
  LF.fields(~C.Workshop,~C.Cell,~C.Cell,~Unit,~C.Cell,~C.Cell,~String,~C.Cell,~C.Ops,~C.declaration(~C.Workshop,"Counter"),~C.body,owner)
def run(owner:C.Owner(~C.Workshop),world:W.World<C.Workshop,C.Cell,C.Cell,Unit>,args:C.Cell) -> Local.Run<C.Workshop,C.Cell,C.Cell,Unit,C.Cell,C.Cell,String,C.Cell,LF.runner(~C.Workshop,~C.Cell,~C.Cell,~Unit,~C.Cell,~C.Cell,~String,~C.Cell,~C.Ops,~C.declaration(~C.Workshop,"Counter"),~C.body)>:
  LF.run(~C.Workshop,~C.Cell,~C.Cell,~Unit,~C.Cell,~C.Cell,~String,~C.Cell,~C.Ops,~C.declaration(~C.Workshop,"Counter"),~C.body,owner,world,args)
