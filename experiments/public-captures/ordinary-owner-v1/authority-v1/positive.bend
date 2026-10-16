import Base
import ../payload.bend as P
import ../system.bend as Sys
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/local.bend as L
import ../../../../src/ecs/ordinary-app-local-fields.bend as Ord
import ../../../../src/ecs/ordinary-captures.bend as Entry
import ../../../../src/ecs/ordinary-resource-system.bend as Resource
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/resource.bend as Raw
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/capabilities.bend as Cap
type First is Data:
  First{}
type Other is Data:
  Other{}
def positive(world:W.World<First,Unit,U32,Unit>,pack:P.Pack) -> L.Registered<First,Unit,U32,Unit,P.Pack,Sys.Args,Sys.Error,Unit,Ord.runner(~First,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~First),~Sys.body)>:
  Entry.define(~First,~Unit,~U32,~Unit,~P.Pack,~Sys.Args,~Sys.Error,~Unit,~Sys.Ops,~Sys.declaration(~First),~Sys.body,world,"capture",pack)
