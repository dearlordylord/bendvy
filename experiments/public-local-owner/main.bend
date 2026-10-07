import Base
import ./schema.bend as S
import ../../src/ecs/world.bend as W
import ../../src/ecs/local.bend as L

type State is Type:
  State{world: W.World<S.Schema,Unit,U32,Unit>,foreign: W.World<S.Schema,Unit,U32,Unit>,one: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,two: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,trace: String}

def snapshot_two(label: String,world: W.World<S.Schema,Unit,U32,Unit>,foreign: W.World<S.Schema,Unit,U32,Unit>,one: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,as: List<&2,U32>,trace: String,observed: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner> & List<&2,U32>) -> State:
  match world observed:
    case W.World{ns,next,high,live,cap,dep,store,+counter,events,pending,regs,sid,clock}, (two,bs): State{W.World{ns,next,high,live,cap,dep,store,counter,events,pending,regs,sid,clock},foreign,one,two,trace ++ label ++ ":w=" ++ U32.show(counter) ++ ";a=[" ++ S.shown(as) ++ "];b=[" ++ S.shown(bs) ++ "]\n"}
def snapshot_one(label: String,world: W.World<S.Schema,Unit,U32,Unit>,foreign: W.World<S.Schema,Unit,U32,Unit>,two: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,trace: String,observed: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner> & List<&2,U32>) -> State:
  (one,as) = observed
  snapshot_two(label,world,foreign,one,as,trace,L.observe(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,~List<&2,U32>,~S.project,two))
def snapshot(label: String,state: State) -> State:
  match state:
    case State{world,foreign,one,two,trace}: snapshot_one(label,world,foreign,two,trace,L.observe(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,~List<&2,U32>,~S.project,one))
def ran(foreign: W.World<S.Schema,Unit,U32,Unit>,two: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,trace: String,result: L.Run<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>) -> State:
  match result:
    case L.Completed{world,one,Done{S.Output{ticket}}}: State{world,foreign,one,two,trace ++ "OK(" ++ S.shown(ticket) ++ ")\n"}
    case L.Completed{world,one,Fail{_}}: State{world,foreign,one,two,trace ++ "FAIL\n"}
    case L.Refused{world,one,args}: State{world,foreign,one,two,trace ++ "UNEXPECTED_REFUSAL\n"}
def run_one(state: State,delta: U32,fail: Bool) -> State:
  match state:
    case State{world,foreign,one,two,trace}: ran(foreign,two,trace,L.run(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,one,world,S.Args{delta,fail,ANode{ALeaf{0},ALeaf{0}}}))
def swap(state: State) -> State:
  match state:
    case State{world,foreign,one,two,trace}: State{world,foreign,two,one,trace}
def skip(state: State) -> State:
  match state:
    case State{world,foreign,one,two,trace}: State{world,foreign,L.skip(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,one),two,trace}

def foreign_args(world: W.World<S.Schema,Unit,U32,Unit>,foreign: W.World<S.Schema,Unit,U32,Unit>,one: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,two: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,trace: String,delta: U32,fail: Bool,result: Array<U32> & List<&2,U32>) -> State:
  (ticket,values) = result
  ran(foreign,two,trace ++ "FOREIGN_REFUSAL(" ++ S.shown(values) ++ ")\n",L.run(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,one,world,S.Args{delta,fail,ticket}))
def refused(world: W.World<S.Schema,Unit,U32,Unit>,two: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,trace: String,result: L.Run<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>) -> State:
  match result:
    case L.Refused{foreign,one,S.Args{delta,fail,ticket}}: foreign_args(world,foreign,one,two,trace,delta,fail,S.collect2(ticket))
    case L.Completed{foreign,one,_}: State{world,foreign,one,two,trace ++ "FOREIGN_RUN_BUG\n"}
def foreign_run(state: State) -> State:
  match state:
    case State{world,foreign,one,two,trace}: refused(world,two,trace,L.run(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,one,foreign,S.Args{7,False{},ANode{ALeaf{99},ALeaf{98}}}))

def disposed_owner(result: S.Owner & List<&2,U32>) -> String:
  (owner,values) = result
  S.shown(values)
def release(owner: S.Owner) -> String:
  disposed_owner(S.project(owner))
def registration_ids(entries: List<&2,W.RegistrationMeta>) -> String:
  match entries:
    case []: ""
    case W.RegistrationMeta{id,_,_} <> rest: U32.show(id) ++ "," ++ registration_ids(rest)
def disposed_two(trace: String,result: L.Disposal<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner,String>) -> IO(Unit):
  match result:
    case L.Disposed{W.World{_,_,_,_,_,_,_,counter,_,_,regs,_,_},values}: IO.print(trace ++ "dispose-b=[" ++ values ++ "];w=" ++ U32.show(counter) ++ ";registered=" ++ registration_ids(regs))
    case _: IO.print("DISPOSE_TWO_BUG")
def disposed_one(two: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,trace: String,result: L.Disposal<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner,String>) -> IO(Unit):
  match result:
    case L.Disposed{W.World{ns,next,high,live,cap,dep,store,+counter,events,pending,+regs,sid,clock},values}: disposed_two(trace ++ "dispose-a=[" ++ values ++ "];w=" ++ U32.show(counter) ++ ";registered=" ++ registration_ids(regs) ++ "\n",L.dispose(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,~String,~release,two,W.World{ns,next,high,live,cap,dep,store,counter,events,pending,regs,sid,clock}))
    case _: IO.print("DISPOSE_ONE_BUG")
def finish(state: State) -> IO(Unit):
  match state:
    case State{world,foreign,one,two,trace}: disposed_one(two,trace,L.dispose(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,~String,~release,one,world))
def disposal_refused(world: W.World<S.Schema,Unit,U32,Unit>,two: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,trace: String,result: L.Disposal<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner,String>) -> IO(Unit):
  match result:
    case L.DisposalRejected{foreign,one}: finish(snapshot("foreign-disposal-refused",State{world,foreign,one,two,trace ++ "FOREIGN_DISPOSAL_REFUSAL\n"}))
    case L.Disposed{foreign,_}: IO.print(trace ++ "FOREIGN_DISPOSAL_BUG")
def foreign_dispose(state: State) -> IO(Unit):
  match state:
    case State{world,foreign,one,two,trace}: disposal_refused(world,two,trace,L.dispose(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,~String,~release,one,foreign))
def scenario(state: State) -> IO(Unit):
  state = snapshot("seed",state)
  state = snapshot("a-first",run_one(state,1,False{}))
  state = swap(state)
  state = run_one(state,10,False{})
  state = snapshot("b-first",swap(state))
  state = snapshot("a-skipped",skip(state))
  state = snapshot("a-failed",run_one(state,2,True{}))
  state = snapshot("a-retry",run_one(state,3,False{}))
  state = swap(state)
  state = run_one(state,20,False{})
  state = snapshot("b-repeat",swap(state))
  state = snapshot("foreign-returned-args-retry",foreign_run(state))
  foreign_dispose(state)
def registered_two(foreign: W.World<S.Schema,Unit,U32,Unit>,one: L.Instance<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>,registered: L.Registered<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>) -> IO(Unit):
  match registered:
    case L.Registered{world,two}: scenario(State{world,foreign,one,two,""})
    case _: IO.print("REGISTER_TWO_ERROR")
def registered_one(foreign: W.World<S.Schema,Unit,U32,Unit>,registered: L.Registered<S.Schema,Unit,U32,Unit,S.Owner,S.Args,Unit,S.Output,S.runner>) -> IO(Unit):
  match registered:
    case L.Registered{world,one}: registered_two(foreign,one,L.register(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,world,"b",["local","counter"],S.owned(100,200,300,400)))
    case _: IO.print("REGISTER_ONE_ERROR")
def foreign_bound(world: W.World<S.Schema,Unit,U32,Unit>,registered: W.World<S.Schema,Unit,U32,Unit> & W.Registration) -> IO(Unit):
  match registered:
    case (foreign,W.Registered{1}): registered_one(foreign,L.register(~S.Schema,~Unit,~U32,~Unit,~S.Owner,~S.Args,~Unit,~S.Output,~S.runner,world,"a",["local","counter"],S.owned(10,20,30,40)))
    case _: IO.print("FOREIGN_COLLISION_SETUP_ERROR")
def created_two(world: W.World<S.Schema,Unit,U32,Unit>,created: W.Creation<S.Schema,Unit,U32,Unit>) -> IO(Unit):
  match created:
    case W.Created{_,foreign}: foreign_bound(world,W.register(~S.Schema,~Unit,~U32,~Unit,foreign,"a",["local","counter"]))
    case _: IO.print("CREATE_TWO_ERROR")
def created_one(created: W.Creation<S.Schema,Unit,U32,Unit>) -> IO(Unit):
  match created:
    case W.Created{factory,world}: created_two(world,W.create(~S.Schema,~Unit,~U32,~Unit,~S.empty,factory,77))
    case _: IO.print("CREATE_ONE_ERROR")
def main() -> IO(Unit):
  created_one(W.create(~S.Schema,~Unit,~U32,~Unit,~S.empty,W.factory(),0))
