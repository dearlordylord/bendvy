import Base
import ../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../src/ecs/ordinary-capture-query.bend as O
import ../../../src/ecs/ordinary-query-declaration.bend as D
import ../../../src/ecs/ordinary-declaration.bend as I
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/local.bend as L
import ../../../src/ecs/lifecycle.bend as Life

type Token is Data:
  Token{}
type Args is Data:
  Args{delta:U32,failValue:U32}
type Error is Data:
  FailedAt{value:U32}
  Missing{}
def view(value:U32) -> U32 & U32:
  +copy=value
  (copy,copy)
def take(~S:Data,column:Col.Column<S,U32>) -> Unit & Col.Column<S,U32>:
  (Unit{},column)
def put(~S:Data,unit:Unit,column:Col.Column<S,U32>) -> Col.Column<S,U32>:
  column
def identity(~S:Data) -> I.Declaration<S,U32>:
  I.component(~S,~U32,"Value")
def Ops(H:Type) -> Type:
  Cap.Write<H,U32,U32> & Unit
def write(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,U32>,U32,Unit>,Cap.Write<Q.Frame<S,Col.Column<S,U32>,U32,Unit>,U32,U32>>:
  D.write(~S,~U32,~Col.Column<S,U32>,~U32,~Unit,~Unit,~U32,~Token,~identity(~S),~view,~take(~S),~put(~S))
def changed(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,U32>,U32,Unit>,Unit>:
  D.changed(~S,~U32,~Col.Column<S,U32>,~U32,~Unit,~Unit,~U32,~Token,~identity(~S),~view,~take(~S),~put(~S))
def query(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,U32>,U32,Unit>,Ops(Q.Frame<S,Col.Column<S,U32>,U32,Unit>)>:
  D.pair(~S,~Q.Frame<S,Col.Column<S,U32>,U32,Unit>,~Cap.Write<Q.Frame<S,Col.Column<S,U32>,U32,Unit>,U32,U32>,~Unit,~write(~S),~changed(~S))
def decision(fail:Bool,value:U32) -> T.Outcome<Error>:
  match fail:
    case True{}:T.Failure{FailedAt{value}}
    case False{}:T.Success{}
def got(~H:Type,~cap:Cap.Write<H,U32,U32>,capture:P.Pack,args:Args,result:H & C.Access<U32>) -> H & (P.Pack & (T.Outcome<Error> & U32)):
  match args result:
    case Args{+delta,+failValue}, (owner,C.Found{+value}):(Cap.set(~H,~U32,~U32,~cap,owner,(value + delta : U32)),(P.update(delta,capture),(decision(U32.is_eq(value,failValue),value),value)))
    case _, (owner,_):(owner,(capture,(T.Failure{Missing{}},0)))
def body(~H:Type,~caps:Ops(H),capture:P.Pack,args:Args,owner:H) -> H & (P.Pack & (T.Outcome<Error> & U32)):
  got(~H,~Pair.fst(Cap.Write<H,U32,U32>,Unit,caps),capture,args,Cap.get(~H,~U32,~U32,~Pair.fst(Cap.Write<H,U32,U32>,Unit,caps),owner))
def Owned(S:Data) -> Type:
  O.Owner<S,Col.Column<S,U32>,U32,Unit,P.Pack,Ops,Args,Error,U32,query(~S),body>
def run(~S:Data,owner:Owned(S),world:W.World<S,Col.Column<S,U32>,U32,Unit>,args:Args) -> O.Run<W.World<S,Col.Column<S,U32>,U32,Unit>,Owned(S),Args,Q.Error<Error>,U32>:
  O.run(~S,~Col.Column<S,U32>,~U32,~Unit,~P.Pack,~Ops,~Args,~Error,~U32,~query(~S),~body,owner,world,args)
def define(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>) -> O.Registration<W.World<S,Col.Column<S,U32>,U32,Unit>,Owned(S),P.Pack>:
  O.define(~S,~Col.Column<S,U32>,~U32,~Unit,~P.Pack,~Ops,~Args,~Error,~U32,~query(~S),~body,world,"captured-query",P.initial(1))
def empty(~S:Data,unit:Unit) -> Col.Column<S,U32>:
  Col.empty(~S,~U32)
def activated(~S:Data,result:W.World<S,Col.Column<S,U32>,U32,Unit> & W.Status) -> W.World<S,Col.Column<S,U32>,U32,Unit>:
  match result:
    case (world,_):world
def spawned(~S:Data,result:W.World<S,Col.Column<S,U32>,U32,Unit> & W.Reservation<S>) -> W.World<S,Col.Column<S,U32>,U32,Unit>:
  match result:
    case (world,W.Reserved{handle}): activated(~S,W.activate(~S,~Col.Column<S,U32>,~U32,~Unit,world,handle))
    case (world,_):world
def spawn(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>) -> W.World<S,Col.Column<S,U32>,U32,Unit>:
  spawned(~S,W.reserve_id(~S,~Col.Column<S,U32>,~U32,~Unit,world))
def replaced(~S:Data,result:C.Replacement<W.World<S,Col.Column<S,U32>,U32,Unit>,U32>) -> W.World<S,Col.Column<S,U32>,U32,Unit>:
  match result:
    case C.Replaced{world,_}:world
    case C.ReplaceRejected{world,_,_}:world
def populated(~S:Data,id:U32,value:U32,named:W.World<S,Col.Column<S,U32>,U32,Unit> & U32) -> W.World<S,Col.Column<S,U32>,U32,Unit>:
  (world,ns) = named
  replaced(~S,C.replace(~S,~Col.Column<S,U32>,~U32,~Unit,~Unit,~U32,~U32,~Token,~take(~S),~put(~S),~view,C.Family{"Value"},world,W.Handle{ns,id},Some{value}))
def populate(~S:Data,world:W.World<S,Col.Column<S,U32>,U32,Unit>,id:U32,value:U32) -> W.World<S,Col.Column<S,U32>,U32,Unit>:
  populated(~S,id,value,W.namespace(~S,~Col.Column<S,U32>,~U32,~Unit,world))
