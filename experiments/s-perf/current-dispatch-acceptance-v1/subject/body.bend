import Base
import ../../canonical-api-v1/dense-runtime-v1/motion.bend as F
import ../../canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../canonical-api-v1/dense-runtime-v1/payload.bend as Payload
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/ordinary-query-declaration.bend as D
import ../../../../src/ecs/ordinary-capture-query.bend as O
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/component.bend as C
import ../../../../src/ecs/transaction.bend as Tx

type Args is Data:
  Args{failAt:U32}
def Ops(H:Type) -> Type:Cap.Write<H,T.Position,T.PositionView>
def query() -> D.Declaration<T.MotionSchema,Q.Frame<T.MotionSchema,F.Store(),F.Resources(),Nat>,Ops(Q.Frame<T.MotionSchema,F.Store(),F.Resources(),Nat>)>:
  D.write(~T.MotionSchema,~T.Position,~F.Store(),~F.Resources(),~Nat,~F.Rest(),~T.PositionView,~T.PositionToken,~F.main_identity(),~Payload.position_get,~F.take_main,~F.put_main)
def outcome(fail:Bool) -> Tx.Outcome<Unit>:
  match fail:
    case True{}:Tx.Failure{Unit{}}
    case False{}:Tx.Success{}
def write_twice(~H:Type,~caps:Ops(H),capture:P.Pack,args:Args,+a:U32,+b:U32,+c:U32,+d:U32,+frame:U32,owner:H) -> H & (P.Pack & (Tx.Outcome<Unit> & U32)):
  match args:
    case Args{failAt}:(Cap.set(~H,~T.Position,~T.PositionView,~caps,Cap.set(~H,~T.Position,~T.PositionView,~caps,owner,T.Position{F.quad(U32.add(a,10),b,c,d),frame}),T.Position{F.quad(U32.add(a,20),b,c,d),frame}),(P.update(1,capture),(outcome(U32.is_eq(a,failAt)),a)))
def read(~H:Type,~caps:Ops(H),capture:P.Pack,args:Args,result:H & C.Access<T.PositionView>) -> H & (P.Pack & (Tx.Outcome<Unit> & U32)):
  match result:
    case (owner,C.Found{T.PositionView{T.Four{a,b,c,d},frame}}):write_twice(~H,~caps,capture,args,a,b,c,d,frame,owner)
    case (owner,_):(owner,(capture,(Tx.Failure{Unit{}},0)))
def body(~H:Type,~caps:Ops(H),capture:P.Pack,args:Args,owner:H) -> H & (P.Pack & (Tx.Outcome<Unit> & U32)):
  read(~H,~caps,capture,args,Cap.get(~H,~T.Position,~T.PositionView,~caps,owner))
def Owned() -> Type:O.Owner<T.MotionSchema,F.Store(),F.Resources(),Nat,P.Pack,Ops,Args,Unit,U32,query(),body>
def define(world:F.World()) -> O.Registration<F.World(),Owned(),P.Pack>:
  O.define(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~P.Pack,~Ops,~Args,~Unit,~U32,~query(),~body,world,"current-dispatch",P.initial(1))
def run(owner:Owned(),world:F.World(),args:Args) -> O.Run<F.World(),Owned(),Args,Q.Error<Unit>,U32>:
  O.run(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~P.Pack,~Ops,~Args,~Unit,~U32,~query(),~body,owner,world,args)
