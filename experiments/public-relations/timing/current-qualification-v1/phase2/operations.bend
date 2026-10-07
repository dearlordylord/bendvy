import Base
import ../trace-force.bend as Force
import ../trace-value.bend as J
import ../trace-rows.bend as Rows
import ../trace-public.bend as Public
import ../../../../../src/ecs/commands.bend as Cmd
import ../../../../../src/ecs/relation-types.bend as G
import ../../../../../src/ecs/relation-providers.bend as P
import ../../../../../src/ecs/relation-reorder.bend as R
import ../../../../../src/ecs/relation-commands.bend as A
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/transaction.bend as X
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/component.bend as Cmp
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../promotion-stage/application/next-version/v1/owned-world.bend as O
import ../../../../../src/ecs/relation-query.bend as RQ
import ../trace-query.bend as Q
import ../../../promotion-stage/application/next-version/v1/cleanup-client.bend as C
import ../trace-application.bend as App
import input.bend as I

type Args is Data:
  Args{phase:U32,input:I.Input}

def next_parent(chain:Bool,id:U32,parent:U32) -> U32:
  match chain:
    case True{}:id
    case False{}:parent

# Runtime span constructs actual registered hierarchy commands, not observer-only rows.
def extra_loop(~S:Data,n:Nat,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,+id:U32,+parent:U32,+chain:Bool) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  match n:
    case 0n:tx
    case 1n+rest:extra_loop(~S,rest,App.relate(~S,~R.descriptor(~S,App.hierarchy(~S)),tx,id,parent),U32.add(id,1),next_parent(chain,id,parent),chain)
def topology(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,input:I.Input) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  match input:
    case I.Input{I.Population{},_,_,_}:tx
    case I.Input{I.Fanout{},_,span,_}:extra_loop(~S,U32.to_nat(span),tx,6,1,False{})
    case I.Input{I.Depth{},_,span,_}:extra_loop(~S,U32.to_nat(span),tx,6,4,True{})
def reverse_children(~S:Data,n:Nat,+id:U32,children:List<&2,W.Handle<S>>) -> List<&2,W.Handle<S>>:
  match n:
    case 0n:children
    case 1n+rest:reverse_children(~S,rest,U32.add(id,1),W.Handle{1,id} <> children)
def fanout_reorder(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,span:U32) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  App.discard(~S,R.invoke(~S,~O.Components<S>,~U32,~U32,~App.hierarchy(~S),~A.QueueStatus,~App.reorder_body(~S),R.Args{W.Handle{1,1},W.Handle{1,3} <> W.Handle{1,2} <> reverse_children(~S,U32.to_nat(span),6,[])},tx))
def reorder(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,input:I.Input) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  match input:
    case I.Input{I.Fanout{},_,span,_}:fanout_reorder(~S,tx,span)
    case _:App.reorder(~S,tx)
def operations(~S:Data,tx:X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>,phase:U32,input:I.Input) -> X.Tx<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,A.Notice<S,U32>>:
  match phase:
    case 0:topology(~S,App.operations(~S,tx,0),input)
    case 2:reorder(~S,tx,input)
    case other:App.operations(~S,tx,other)

def write_runner(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,args:Args) -> Sys.Outcome<W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,U32,Unit>:
  match args:
    case Args{5,_}: Sys.Failed{O.commit(~S,App.failure_operations(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world)),X.Failure{903}),903}
    case Args{rest,input}: Sys.Succeeded{O.commit(~S,operations(~S,X.begin(~W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,~A.Notice<S,U32>,world),rest,input),X.Success{}),Unit{}}

def ran(~S:Data,result:Sys.RunResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,Args,U32,Unit,write_runner(~S)>) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Maybe<&2,U32>:
  match result:
    case Sys.Completed{_,Sys.Succeeded{world,_}}: (world,None{})
    case Sys.Completed{_,Sys.Failed{world,error}}: (world,Some{error})
    case Sys.RegistrationRejected{_,world,_}: (world,Some{999})

def registered(~S:Data,result:Sys.RegistrationResult<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>,Args,U32,Unit,write_runner(~S)>,args:Args) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Maybe<&2,U32>:
  match result:
    case Sys.Registered{world,registry}: ran(~S,Sys.run(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Args,~U32,~Unit,~write_runner(~S),registry,world,args))
    case Sys.RegistrationFailed{world}: (world,Some{999})

def write(~S:Data,world:W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>>,+args:Args) -> W.World<S,A.Store<S,O.Components<S>>,U32,A.Notice<S,U32>> & Maybe<&2,U32>:
  registered(~S,Sys.register(~S,~A.Store<S,O.Components<S>>,~U32,~A.Notice<S,U32>,~Args,~U32,~Unit,~write_runner(~S),world,"relation-write-phase2",["Link.write","OtherLink.write","Parent.write","Children.write","Payload.write"]),args)
