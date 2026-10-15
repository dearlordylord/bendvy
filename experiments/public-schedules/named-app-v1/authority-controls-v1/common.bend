import Base
import ../../../../src/ecs/ordinary-app-local-fields.bend as LF
import ../../../../src/ecs/ordinary-app-schedules.bend as Named
import ../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../src/ecs/ordinary-resource-system.bend as Resource
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/capabilities.bend as Cap

type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type Cell is Type:
  Cell{values:Array<U32>}
def projected(result:Array<U32> & U32) -> Cell & U32:
  match result:
    case (values,value):(Cell{values},value)
def project(cell:Cell) -> Cell & U32:
  match cell:
    case Cell{values}:projected(Array.get(U32,values,0))
def declaration(~S:Data,+key:String) -> Resource.Declaration<S,Cell,T.Tx<W.World<S,Cell,Cell,Unit>,Unit>,Cap.ValueRead<T.Tx<W.World<S,Cell,Cell,Unit>,Unit>,U32>>:
  Resource.read(~S,~Cell,~Cell,~Unit,~U32,~project,Schema.resource(~S,~Cell,key))
def body_returned(~H:Type,local:Cell,args:Cell,result:H & U32) -> H & (Cell & (T.Outcome<String> & Cell)):
  match result:
    case (ctx,_):(ctx,(local,(T.Success{},args)))
def body(~H:Type,~caps:Cap.ValueRead<H,U32>,local:Cell,args:Cell,ctx:H) -> H & (Cell & (T.Outcome<String> & Cell)):
  body_returned(~H,local,args,Cap.value_read(~H,~U32,~caps,ctx))
def Ops(H:Type) -> Type:
  Cap.ValueRead<H,U32>
def Owner(~S:Data) -> Type:
  LF.Owner<S,Cell,Cell,Unit,Cell,Cell,String,Cell,Ops,declaration(~S,"Counter"),body>
