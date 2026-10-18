import Base
import schema.bend as S
import ../private/src/ecs/capabilities.bend as Cap
import ../private/src/ecs/bundle-requests.bend as Request
import ../private/src/ecs/transaction.bend as T

type BodyResult is Type:BodyResult{outcome:T.Outcome<Unit>,returned:List<Array<U32>>}
def outcome(fail:Bool) -> T.Outcome<Unit>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Unit{}}
def inserted(~H:Type,fail:Bool,observed:H & S.Output()) -> H & BodyResult:
  match observed:
    case (owner,Request.Accepted{_,_}):(owner,BodyResult{outcome(fail),[]})
    case (owner,Request.Refused{raw,_}):(owner,BodyResult{T.Failure{Unit{}},[raw]})
def spawned(~H:Type,~caps:S.Ops(H),fail:Bool,observed:H & S.Output()) -> H & BodyResult:
  match observed:
    case (owner,Request.Accepted{handle,_}):inserted(~H,fail,Cap.owned_request(~H,~S.Input(),~S.Output(),~S.request_cap(~H,caps),Cap.send(~H,~U32,~S.send_cap(~H,caps),Cap.send(~H,~U32,~S.send_cap(~H,caps),Cap.value_set(~H,~Array<U32>,~List<&2,U32>,~S.resource_cap(~H,caps),owner,ALeaf{30}),7),9),Request.Input{Request.Insert{handle},ALeaf{200}}))
    case (owner,Request.Refused{raw,_}):(owner,BodyResult{T.Failure{Unit{}},[raw]})
def run(~H:Type,~caps:S.Ops(H),fail:Bool,owner:H) -> H & BodyResult:spawned(~H,~caps,fail,Cap.owned_request(~H,~S.Input(),~S.Output(),~S.request_cap(~H,caps),Cap.send(~H,~U32,~S.send_cap(~H,caps),Cap.value_set(~H,~Array<U32>,~List<&2,U32>,~S.resource_cap(~H,caps),owner,ALeaf{20}),7),Request.Input{Request.Spawn{},ALeaf{100}}))
