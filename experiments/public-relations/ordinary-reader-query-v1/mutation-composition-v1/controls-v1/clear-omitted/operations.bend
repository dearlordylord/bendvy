import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/relation-providers.bend as P
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy

type Input<S:Data> is Data: Replace{targets:P.Targets<S>} Clear{source:W.Handle<S>}
# Gameplay receives an abstract transaction owner and a single declared grant.
def write_body(~S:Data,-H:Type,caps:P.Writable<H,S>,args:P.Targets<S>,owner:H) -> H & A.QueueStatus:
  P.relate_live(H,S,caps,owner,args)
# Abstract H is a live rank-two binder, so consume the live clear Request as
# relate_live/read_live do; Cap.request and clear_field require erased H.
def clear_live(-H:Type,-S:Data,caps:P.Writable<H,S>,owner:H,source:W.Handle<S>) -> H & A.QueueStatus:
  match caps:
    case P.Writable{_,_,Cap.Request{_}}:(owner,A.Queued{})
def clear_body(~S:Data,-H:Type,caps:P.Writable<H,S>,args:P.Targets<S>,owner:H) -> H & A.QueueStatus:
  match args:
    case P.Targets{source,_}:clear_live(H,S,caps,owner,source)
def read_body(~S:Data,-H:Type,caps:P.ReadOnly<H,S>,target:W.Handle<S>,owner:H) -> H & Maybe<&2,List<&2,W.Handle<S>>>:
  P.read_live(H,S,caps,owner,target)

def committed(~S:Data,~C:Type,~R:Type,~E:Data,result:X.Returned<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,Unit>,status:A.QueueStatus) -> Sy.Outcome<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,Unit,A.QueueStatus>:
  match result:
    case X.Returned{world,_}:Sy.Succeeded{world,status}
def staged(~S:Data,~C:Type,~R:Type,~E:Data,observed:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus) -> Sy.Outcome<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,Unit,A.QueueStatus>:
  (tx,status)=observed
  committed(~S,~C,~R,~E,Cmd.tx_finish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Unit,tx,X.Success{}),status)
def writer(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.Descriptor<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,args:Input<S>) -> Sy.Outcome<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,Unit,A.QueueStatus>:
  match args:
    case Replace{targets}:staged(~S,~C,~R,~E,P.invoke_write(~S,~C,~R,~E,~descriptor,~A.QueueStatus,~write_body(~S),targets,X.begin(~W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,~A.Notice<S,E>,world)))
    case Clear{+source}:staged(~S,~C,~R,~E,P.invoke_write(~S,~C,~R,~E,~descriptor,~A.QueueStatus,~clear_body(~S),P.Targets{source,source},X.begin(~W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,~A.Notice<S,E>,world)))

def read_committed(~S:Data,~C:Type,~R:Type,~E:Data,result:X.Returned<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,Unit>,value:Maybe<&2,List<&2,W.Handle<S>>>) -> Sy.Outcome<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,Unit,Maybe<&2,List<&2,W.Handle<S>>>>:
  match result:
    case X.Returned{world,_}:Sy.Succeeded{world,value}
def read_staged(~S:Data,~C:Type,~R:Type,~E:Data,observed:X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & Maybe<&2,List<&2,W.Handle<S>>>) -> Sy.Outcome<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,Unit,Maybe<&2,List<&2,W.Handle<S>>>>:
  (tx,value)=observed
  read_committed(~S,~C,~R,~E,Cmd.tx_finish(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Unit,tx,X.Success{}),value)
def reader(~S:Data,~C:Type,~R:Type,~E:Data,~descriptor:G.Descriptor<S>,world:W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,target:W.Handle<S>) -> Sy.Outcome<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,Unit,Maybe<&2,List<&2,W.Handle<S>>>>:
  read_staged(~S,~C,~R,~E,P.invoke_read(~S,~C,~R,~E,~descriptor,~Maybe<&2,List<&2,W.Handle<S>>>,~read_body(~S),target,X.begin(~W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,~A.Notice<S,E>,world)))
