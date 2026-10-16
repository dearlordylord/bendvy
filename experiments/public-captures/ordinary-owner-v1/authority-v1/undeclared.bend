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
def undeclared(~H:Type,~caps:Sys.Ops(H),pack:P.Pack,args:Sys.Args,owner:H) -> H & (P.Pack & (T.Outcome<Sys.Error> & Unit)):
  (Raw.tx_replace(~First,~Unit,~U32,~Unit,owner,99),(pack,(T.Success{},Unit{})))
