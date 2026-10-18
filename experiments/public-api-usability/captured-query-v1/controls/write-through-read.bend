import Base
import ../schema.bend as S
import ../body.bend as B
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/ordinary-app-capture-query.bend as Captured
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/ordinary-query-declaration.bend as D
import ../../../../src/ecs/compose.bend as Q
def ReadOps(H:Type) -> Type:Cap.Read<H,P.Tree> & Unit
def read_query() -> D.Declaration<S.Workshop,B.Frame(~S.Workshop),ReadOps(B.Frame(~S.Workshop))>:
  D.pair(~S.Workshop,~B.Frame(~S.Workshop),~Cap.Read<B.Frame(~S.Workshop),P.Tree>,~Unit,~D.read(~S.Workshop,~Array<U32>,~S.Store(~S.Workshop),~Unit,~Unit,~Unit,~P.Tree,~S.Token,~S.identity(~S.Workshop),~P.observe,~S.take(~S.Workshop),~S.put(~S.Workshop)),~D.changed(~S.Workshop,~Array<U32>,~S.Store(~S.Workshop),~Unit,~Unit,~Unit,~P.Tree,~S.Token,~S.identity(~S.Workshop),~P.observe,~S.take(~S.Workshop),~S.put(~S.Workshop)))
def refused() -> Type:Captured.Owned(~S.Workshop,~S.Store(~S.Workshop),~Unit,~Unit,~P.Pack,~ReadOps,~B.Args,~B.Error,~B.Row,~read_query(),~B.body)
