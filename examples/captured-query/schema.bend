import Base
import ./payload.bend as P
import ../../src/ecs/column.bend as Col
import ../../src/ecs/component.bend as C
import ../../src/ecs/ordinary-declaration.bend as Identity
import ../../src/ecs/ordinary-component-binding.bend as Binding
import ../../src/ecs/ordinary-schema.bend as Schema
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as Tx
import ../../src/ecs/commands.bend as Cmd

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
type Token is Data:Token{}
def Store(~S:Data) -> Type:Col.Column<S,Array<U32>>
def World(~S:Data) -> Type:W.World<S,Store(~S),Unit,Unit>
def empty(~S:Data,_:Unit) -> Store(~S):Col.empty(~S,~Array<U32>)
def take(~S:Data,value:Store(~S)) -> Unit & Store(~S):(Unit{},value)
def put(~S:Data,_:Unit,value:Store(~S)) -> Store(~S):value
def identity(~S:Data) -> Identity.Declaration<S,Array<U32>>:Identity.component(~S,~Array<U32>,"Cells")
def binding(~S:Data) -> Binding.Binding<S,Store(~S),Unit,Array<U32>,P.Tree,Token,take(~S),put(~S),P.observe>:Binding.bind(~S,~Store(~S),~Unit,~Array<U32>,~P.Tree,~Token,~take(~S),~put(~S),~P.observe,identity(~S))
def family(~S:Data) -> C.Family<S,Store(~S),Unit,Array<U32>,P.Tree,Token,take(~S),put(~S),P.observe>:C.Family{Identity.key(~S,~Array<U32>,identity(~S))}
def schema(~S:Data) -> Schema.Schema<S,Store(~S),Unit>:Schema.component(~S,~Array<U32>,identity(~S))
def cells(+start:U32) -> Array<U32>:ANode{ANode{ALeaf{start},ALeaf{U32.add(start,1)}},ANode{ALeaf{U32.add(start,2)},ALeaf{U32.add(start,3)}}}
def populated(~S:Data,result:C.Replacement<World(~S),Array<U32>>) -> World(~S):
  match result:
    case C.Replaced{world,_}:world
    case C.ReplaceRejected{world,_,_}:world
def populate(~S:Data,world:World(~S),handle:W.Handle<S>,value:Array<U32>) -> World(~S):populated(~S,C.replace(~S,~Store(~S),~Unit,~Unit,~Unit,~Array<U32>,~P.Tree,~Token,~take(~S),~put(~S),~P.observe,family(~S),world,handle,Some{value}))
def finished(~S:Data,result:Tx.Returned<World(~S),Unit>) -> World(~S):
  match result:
    case Tx.Returned{world,_}:W.barrier(~S,~Store(~S),~Unit,~Unit,world)
def second(~S:Data,result:Tx.Tx<World(~S),Unit> & W.Reservation<S>) -> World(~S):
  match result:
    case (tx,_):finished(~S,Cmd.tx_finish(~S,~Store(~S),~Unit,~Unit,~Unit,tx,Tx.Success{}))
def first(~S:Data,result:Tx.Tx<World(~S),Unit> & W.Reservation<S>) -> World(~S):
  match result:
    case (tx,_):second(~S,Cmd.tx_spawn(~S,~Store(~S),~Unit,~Unit,~Array<U32>,~populate(~S),tx,cells(1)))
def seed(~S:Data,world:World(~S)) -> World(~S):first(~S,Cmd.tx_spawn(~S,~Store(~S),~Unit,~Unit,~Array<U32>,~populate(~S),Tx.begin(~World(~S),~Unit,world),cells(0)))
def access(value:C.Access<P.Tree>) -> String:
  match value:
    case C.Found{value}:P.text(value)
    case C.ComponentAbsent{}:"Absent"
    case C.MissingEntity{}:"Missing"
def collected(~S:Data,next:World(~S) -> List<&2,String> -> World(~S) & List<&2,String>,texts:List<&2,String>,result:World(~S) & C.Access<P.Tree>) -> World(~S) & List<&2,String>:
  match result:
    case (world,value):next(world,List.append(&2,String,texts,[access(value)]))
def collect(~S:Data,handles:List<&2,W.Handle<S>>,world:World(~S),texts:List<&2,String>) -> World(~S) & List<&2,String>:
  match handles:
    case []:(world,texts)
    case handle <> rest:collected(~S,world=>texts=>collect(~S,rest,world,texts),texts,C.get(~S,~Store(~S),~Unit,~Unit,~Unit,~Array<U32>,~P.Tree,~Token,~take(~S),~put(~S),~P.observe,family(~S),world,handle))
def listed(~S:Data,result:World(~S) & List<&2,String>) -> World(~S) & String:
  match result:
    case (world,values):(world,"cells=" ++ List.show(&2,String,x=>x,values))
def handles(~S:Data,result:World(~S) & List<&2,W.Handle<S>>) -> World(~S) & String:
  match result:
    case (world,values):listed(~S,collect(~S,values,world,[]))
def observe(~S:Data,world:World(~S)) -> World(~S) & String:handles(~S,W.handles(~S,~Store(~S),~Unit,~Unit,world))
