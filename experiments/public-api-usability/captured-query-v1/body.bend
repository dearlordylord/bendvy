import Base
import ./schema.bend as S
import ../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../src/ecs/ordinary-query-declaration.bend as D
import ../../../src/ecs/ordinary-query-observable.bend as O
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/transaction.bend as T

type Args is Data:Args{failAt:U32}
type Row is Data:Row{before:P.Tree,between:P.Tree,after:P.Tree}
type Error is Data:
  Deliberate{row:Row}
  Missing{}
type AuditError is Data:AuditMissing{}
def Frame(~Schema:Data) -> Type:Q.Frame<Schema,S.Store(~Schema),Unit,Unit>
def Ops(H:Type) -> Type:Cap.Write<H,Array<U32>,P.Tree> & Unit
def main(~H:Type,caps:Ops(H)) -> Cap.Write<H,Array<U32>,P.Tree>:
  match caps:
    case (write,_):write
def query(~Schema:Data) -> D.Declaration<Schema,Frame(~Schema),Ops(Frame(~Schema))>:
  D.pair(~Schema,~Frame(~Schema),~Cap.Write<Frame(~Schema),Array<U32>,P.Tree>,~Unit,~D.write(~Schema,~Array<U32>,~S.Store(~Schema),~Unit,~Unit,~Unit,~P.Tree,~S.Token,~S.identity(~Schema),~P.observe,~S.take(~Schema),~S.put(~Schema)),~D.changed(~Schema,~Array<U32>,~S.Store(~Schema),~Unit,~Unit,~Unit,~P.Tree,~S.Token,~S.identity(~Schema),~P.observe,~S.take(~Schema),~S.put(~Schema)))
def raised(+delta:U32,value:P.Tree) -> Array<U32>:
  match value:
    case P.Leaf{n}:ALeaf{U32.add(n,delta)}
    case P.Node{a,b}:ANode{raised(delta,a),raised(delta,b)}
def first(value:P.Tree) -> U32:
  match value:
    case P.Leaf{n}:n
    case P.Node{a,_}:first(a)
def decision(fail:Bool,row:Row) -> T.Outcome<Error>:
  match fail:
    case True{}:T.Failure{Deliberate{row}}
    case False{}:T.Success{}
def answer(~H:Type,capture:P.Pack,fail:Bool,+value:Row,owner:H) -> H & (P.Pack & (T.Outcome<Error> & Row)):
  (owner,(P.update(1,capture),(decision(fail,value),value)))
def completed(~H:Type,capture:P.Pack,args:Args,+before:P.Tree,between:P.Tree,result:H & C.Access<P.Tree>) -> H & (P.Pack & (T.Outcome<Error> & Row)):
  match args result:
    case Args{failAt},(owner,C.Found{after}):answer(~H,capture,U32.is_eq(first(before),failAt),Row{before,between,after},owner)
    case _,(owner,_):(owner,(capture,(T.Failure{Missing{}},Row{before,between,P.Leaf{0}})))
def second(~H:Type,~caps:Ops(H),capture:P.Pack,args:Args,+before:P.Tree,result:H & C.Access<P.Tree>) -> H & (P.Pack & (T.Outcome<Error> & Row)):
  match result:
    case (owner,C.Found{between}):completed(~H,capture,args,before,between,Cap.get(~H,~Array<U32>,~P.Tree,~main(~H,caps),Cap.set(~H,~Array<U32>,~P.Tree,~main(~H,caps),owner,raised(20,before))))
    case (owner,_):(owner,(capture,(T.Failure{Missing{}},Row{before,P.Leaf{0},P.Leaf{0}})))
def initial(~H:Type,~caps:Ops(H),capture:P.Pack,args:Args,result:H & C.Access<P.Tree>) -> H & (P.Pack & (T.Outcome<Error> & Row)):
  match result:
    case (owner,C.Found{+before}):second(~H,~caps,capture,args,before,Cap.get(~H,~Array<U32>,~P.Tree,~main(~H,caps),Cap.set(~H,~Array<U32>,~P.Tree,~main(~H,caps),owner,raised(10,before))))
    case (owner,_):(owner,(capture,(T.Failure{Missing{}},Row{P.Leaf{0},P.Leaf{0},P.Leaf{0}})))
def body(~H:Type,~caps:Ops(H),capture:P.Pack,args:Args,owner:H) -> H & (P.Pack & (T.Outcome<Error> & Row)):
  initial(~H,~caps,capture,args,Cap.get(~H,~Array<U32>,~P.Tree,~main(~H,caps),owner))
def audit_query(~Schema:Data) -> O.Declaration<Schema,Frame(~Schema),Cap.Read<Frame(~Schema),P.Tree>,I.Frame<Schema,S.Store(~Schema),Unit,Unit>,C.Access<P.Tree>>:
  O.read(~Schema,~S.Store(~Schema),~Unit,~Array<U32>,~P.Tree,~S.Token,~S.take(~Schema),~S.put(~Schema),~P.observe,~Unit,~Unit,~S.binding(~Schema))
def audit_result(~H:Type,result:H & C.Access<P.Tree>) -> H & (T.Outcome<AuditError> & P.Tree):
  match result:
    case (owner,C.Found{tree}):(owner,(T.Success{},tree))
    case (owner,_):(owner,(T.Failure{AuditMissing{}},P.Leaf{0}))
def audit(~H:Type,~caps:Cap.Read<H,P.Tree>,_:Unit,owner:H) -> H & (T.Outcome<AuditError> & P.Tree):audit_result(~H,Cap.read(~H,~P.Tree,~caps,owner))
def tree(value:P.Tree) -> String:
  match value:
    case P.Leaf{n}:"leaf:" ++ U32.show(n)
    case P.Node{a,b}:"node(" ++ tree(a) ++ "," ++ tree(b) ++ ")"
def render(value:C.Access<P.Tree>) -> String:
  match value:
    case C.Found{value}:tree(value)
    case C.ComponentAbsent{}:"Absent"
    case C.MissingEntity{}:"Missing"
def row(value:Row) -> String:
  match value:
    case Row{before,between,after}:"Row{" ++ tree(before) ++ ";" ++ tree(between) ++ ";" ++ tree(after) ++ "}"
