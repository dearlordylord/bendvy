import Base
import provider.bend as P
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine.bend as M
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/machine-stream.bend as St
import observe.bend as O
import followup/stream-opt/cleanup-controls-v1/public-cleanup-v1/current-core/ecs/event-runtime.bend as Ev

def retained(~S: Data,pair: St.Reader<S,P.FlowToken> & St.Stream<P.Flow>) -> String:
  match pair:
    case (St.Reader{ns,id},stream): U32.show(ns) ++ ":" ++ U32.show(id) ++ "|" ++ O.stream(~P.Flow,~O.flow,stream)

def after_failed(~S: Data,prefix: String,pair: St.Reader<S,P.FlowToken> & St.Stream<P.Flow>) -> String:
  match pair:
    case (reader,+stream): prefix ++ "|failed=" ++ O.stream(~P.Flow,~O.flow,stream) ++ "|completed=" ++ retained(~S,St.finish(~S,~P.FlowToken,~P.Flow,reader,stream,2n,True{}))

def opened(~S: Data,result: St.OpenResult<S,P.FlowToken,P.Flow>) -> String:
  match result:
    case St.ReaderRefused{reader,stream}: "refused|" ++ retained(~S,(reader,stream))
    case St.Opened{reader,stream,Ev.Reading{values,lagged}}:
      after_failed(~S,"opened|" ++ List.show(&2,M.Transition<P.Flow>,(value => O.transition(~P.Flow,~O.flow,value)),values) ++ "|lagged=" ++ O.bool(lagged),St.finish(~S,~P.FlowToken,~P.Flow,reader,stream,2n,False{}))

def scenario(~S: Data,namespace: U32) -> String:
  opened(~S,St.open(~S,~P.FlowToken,~P.Flow,St.Reader{7,1},St.publish(~P.Flow,St.empty(~P.Flow),1n,M.Transition{P.Boot{},P.Play{}}),namespace,2n))

def main() -> IO(Unit):
  IO.print("A=" ++ scenario(~P.SchemaA,7) ++ "\nB=" ++ scenario(~P.SchemaB,7) ++ "\nforeign=" ++ scenario(~P.SchemaA,8))
