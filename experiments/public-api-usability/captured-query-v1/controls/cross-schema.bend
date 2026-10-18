import Base
import ../schema.bend as S
import ../body.bend as B
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../../src/ecs/ordinary-app-capture-query.bend as Captured
def refused(value:Captured.Invocation(~S.Workshop,~S.Store(~S.Workshop),~Unit,~Unit,~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~S.Workshop),~B.body)) -> Captured.Invocation(~S.Garden,~S.Store(~S.Garden),~Unit,~Unit,~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~S.Garden),~B.body):value
