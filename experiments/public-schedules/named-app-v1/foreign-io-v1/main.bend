import Base
import ../../../../src/ecs/ordinary-app-resource-declaration.bend as D
import ../fixture.bend as F
import ../observer.bend as O
import ../../../../src/ecs/ordinary-app-local-fields.bend as LF
import ../../../../src/ecs/local.bend as Local
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/capabilities.bend as Cap

type Args is Type:
  Args{values:Array<U32>}
def body_returned(~H:Type,local:F.Memory,args:Args,result:H & U32) -> H & (F.Memory & (T.Outcome<String> & Args)):
  match result:
    case (ctx,_):(ctx,(F.local_step(local),(T.Success{},args)))
def body(~H:Type,~caps:Cap.ValueRead<H,U32>,local:F.Memory,args:Args,ctx:H) -> H & (F.Memory & (T.Outcome<String> & Args)):
  body_returned(~H,local,args,Cap.value_read(~H,~U32,~caps,ctx))
def Owner() -> Type:
  LF.Owner<F.Workshop,F.Store,F.Resources,Unit,F.Memory,Args,String,Args,D.read_ops(~U32),F.raw(~F.Workshop),body>
type State is Type:
  State{home:W.World<F.Workshop,F.Store,F.Resources,Unit>,peer:W.World<F.Workshop,F.Store,F.Resources,Unit>,homeOwner:Owner(),peerOwner:Owner(),args:Args,trace:String}
def args_observed(result:Array<U32> & String) -> Args & String:
  match result:
    case (values,text):(Args{values},"args("++text++")")
def args(value:Args) -> Args & String:
  match value:
    case Args{values}:args_observed(O.array(values))
def owner_observed(+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,result:F.Memory & String) -> Owner() & String:
  match result:
    case (memory,text):(LF.Owner{Local.Instance{namespace,id,name,access,memory}},"local("++U32.show(namespace)++","++U32.show(id)++","++O.quoted(name)++","++O.strings(access)++","++text++")")
def owner(value:Owner()) -> Owner() & String:
  match value:
    case LF.Owner{Local.Instance{namespace,id,name,access,memory}}:owner_observed(namespace,id,name,access,O.memory(memory))
def observed(label:String,trace:String,result:((W.World<F.Workshop,F.Store,F.Resources,Unit> & W.World<F.Workshop,F.Store,F.Resources,Unit>) & ((Owner() & Owner()) & Args)) & String) -> State:
  match result:
    case (((home,peer),((homeOwner,peerOwner),args)),text):State{home,peer,homeOwner,peerOwner,args,trace++label++"|"++text++"\n"}
def observe(label:String,state:State) -> State:
  match state:
    case State{home,peer,homeOwner,peerOwner,argOwner,trace}:observed(label,trace,O.pair(~(W.World<F.Workshop,F.Store,F.Resources,Unit> & W.World<F.Workshop,F.Store,F.Resources,Unit>),~((Owner() & Owner()) & Args),~O.pair(~W.World<F.Workshop,F.Store,F.Resources,Unit>,~W.World<F.Workshop,F.Store,F.Resources,Unit>,~O.world(~F.Workshop),~O.world(~F.Workshop)),~O.pair(~(Owner() & Owner()),~Args,~O.pair(~Owner(),~Owner(),~owner,~owner),~args),((home,peer),((homeOwner,peerOwner),argOwner))))
def refused(home:W.World<F.Workshop,F.Store,F.Resources,Unit>,peerOwner:Owner(),trace:String,result:Local.Run<F.Workshop,F.Store,F.Resources,Unit,F.Memory,Args,String,Args,LF.runner(~F.Workshop,~F.Store,~F.Resources,~Unit,~F.Memory,~Args,~String,~Args,~D.read_ops(~U32),~F.raw(~F.Workshop),~body)>) -> State:
  match result:
    case Local.Refused{peer,homeOwner,args}:State{home,peer,LF.Owner{homeOwner},peerOwner,args,trace++"foreign=refused\n"}
    case Local.Completed{peer,homeOwner,Done{args}}:State{home,peer,LF.Owner{homeOwner},peerOwner,args,trace++"foreign=unexpected-completed\n"}
    case Local.Completed{peer,homeOwner,Fail{error}}:State{home,peer,LF.Owner{homeOwner},peerOwner,Args{ALeaf{0}},trace++"foreign=unexpected-failed:"++error++"\n"}
def foreign(state:State) -> State:
  match state:
    case State{home,peer,homeOwner,peerOwner,args,trace}:refused(home,peerOwner,trace,LF.run(~F.Workshop,~F.Store,~F.Resources,~Unit,~F.Memory,~Args,~String,~Args,~D.read_ops(~U32),~F.raw(~F.Workshop),~body,homeOwner,peer,args))
def retried(peer:W.World<F.Workshop,F.Store,F.Resources,Unit>,peerOwner:Owner(),trace:String,result:Local.Run<F.Workshop,F.Store,F.Resources,Unit,F.Memory,Args,String,Args,LF.runner(~F.Workshop,~F.Store,~F.Resources,~Unit,~F.Memory,~Args,~String,~Args,~D.read_ops(~U32),~F.raw(~F.Workshop),~body)>) -> State:
  match result:
    case Local.Completed{home,homeOwner,Done{args}}:State{home,peer,LF.Owner{homeOwner},peerOwner,args,trace++"home=completed\n"}
    case Local.Refused{home,homeOwner,args}:State{home,peer,LF.Owner{homeOwner},peerOwner,args,trace++"home=unexpected-refused\n"}
    case Local.Completed{home,homeOwner,Fail{error}}:State{home,peer,LF.Owner{homeOwner},peerOwner,Args{ALeaf{0}},trace++"home=unexpected-failed:"++error++"\n"}
def retry(state:State) -> State:
  match state:
    case State{home,peer,homeOwner,peerOwner,args,trace}:retried(peer,peerOwner,trace,LF.run(~F.Workshop,~F.Store,~F.Resources,~Unit,~F.Memory,~Args,~String,~Args,~D.read_ops(~U32),~F.raw(~F.Workshop),~body,homeOwner,home,args))
def printed(state:State) -> IO(Unit):
  match state:
    case State{_,_,_,_,_,trace}:IO.print(trace)
def scenario(state:State) -> IO(Unit):
  printed(observe("retried",retry(observe("foreign-returned",foreign(observe("initial",state))))))
def peer_registered(home:W.World<F.Workshop,F.Store,F.Resources,Unit>,homeOwner:Owner(),result:LF.Registration<W.World<F.Workshop,F.Store,F.Resources,Unit>,Owner(),F.Memory>) -> IO(Unit):
  match result:
    case LF.Rejected{_,_}:IO.print("unexpected-peer-registration-refusal")
    case LF.Registered{peer,peerOwner}:scenario(State{home,peer,homeOwner,peerOwner,Args{ANode{ALeaf{99},ALeaf{98}}},""})
def home_registered(peer:W.World<F.Workshop,F.Store,F.Resources,Unit>,result:LF.Registration<W.World<F.Workshop,F.Store,F.Resources,Unit>,Owner(),F.Memory>) -> IO(Unit):
  match result:
    case LF.Rejected{_,_}:IO.print("unexpected-home-registration-refusal")
    case LF.Registered{home,homeOwner}:peer_registered(home,homeOwner,LF.define(~F.Workshop,~F.Store,~F.Resources,~Unit,~F.Memory,~Args,~String,~Args,~D.read_ops(~U32),~F.raw(~F.Workshop),~body,peer,"Shared",F.Memory{ALeaf{40},40}))
def peer_created(home:W.World<F.Workshop,F.Store,F.Resources,Unit>,result:WI.Creation<F.Workshop,F.Store,F.Resources,Unit>) -> IO(Unit):
  match result:
    case WI.Refused{_}:IO.print("unexpected-peer-creation-refusal")
    case WI.Created{peer}:home_registered(peer,LF.define(~F.Workshop,~F.Store,~F.Resources,~Unit,~F.Memory,~Args,~String,~Args,~D.read_ops(~U32),~F.raw(~F.Workshop),~body,home,"Shared",F.Memory{ALeaf{3},3}))
def home_created(result:WI.Creation<F.Workshop,F.Store,F.Resources,Unit>) -> IO(Unit):
  match result:
    case WI.Refused{_}:IO.print("unexpected-home-creation-refusal")
    case WI.Created{home}:IO.bind(WI.Creation<F.Workshop,F.Store,F.Resources,Unit>,Unit,WI.create(~F.Workshop,~F.Store,~F.Resources,~Unit,~F.empty,F.Resources{ALeaf{66},22}),result => peer_created(home,result))
def main() -> IO(Unit):
  IO.bind(WI.Creation<F.Workshop,F.Store,F.Resources,Unit>,Unit,WI.create(~F.Workshop,~F.Store,~F.Resources,~Unit,~F.empty,F.Resources{ALeaf{55},11}),home_created)
