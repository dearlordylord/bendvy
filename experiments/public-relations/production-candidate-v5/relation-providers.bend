import Base
import relation-types.bend as G
import relation-commands.bend as A
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as X
import ../../../src/ecs/capabilities.bend as Cap

# Descriptor is closed by schema provisioning; gameplay has no descriptor argument.
# Inverse capability exposes only a snapshot query, never a setter for the table.
type Targets<S: Data> is Data:
  Targets{source: W.Handle<S>,target: W.Handle<S>}
type ReadOnly<-H: Type,S: Data> is Type:
  ReadOnly{inverse: Cap.Request<H,W.Handle<S>,Maybe<&2,List<&2,W.Handle<S>>>>}
type Writable<-H: Type,S: Data> is Type:
  Writable{inverse: Cap.Request<H,W.Handle<S>,Maybe<&2,List<&2,W.Handle<S>>>>,relate: Cap.Request<H,Targets<S>,A.QueueStatus>,unrelate: Cap.Request<H,W.Handle<S>,A.QueueStatus>}
def read_field(~H: Type,~S: Data,caps: ReadOnly<H,S>) -> Cap.Request<H,W.Handle<S>,Maybe<&2,List<&2,W.Handle<S>>>>:
  match caps:
    case ReadOnly{inverse}: inverse
def write_inverse_field(~H: Type,~S: Data,caps: Writable<H,S>) -> Cap.Request<H,W.Handle<S>,Maybe<&2,List<&2,W.Handle<S>>>>:
  match caps:
    case Writable{inverse,_,_}: inverse
def relate_field(~H: Type,~S: Data,caps: Writable<H,S>) -> Cap.Request<H,Targets<S>,A.QueueStatus>:
  match caps:
    case Writable{_,relate,_}: relate
def clear_field(~H: Type,~S: Data,caps: Writable<H,S>) -> Cap.Request<H,W.Handle<S>,A.QueueStatus>:
  match caps:
    case Writable{_,_,clear}: clear
def read(~H: Type,~S: Data,~caps: ReadOnly<H,S>,owner: H,target: W.Handle<S>) -> H & Maybe<&2,List<&2,W.Handle<S>>>:
  Cap.request(~H,~W.Handle<S>,~Maybe<&2,List<&2,W.Handle<S>>>,~read_field(~H,~S,caps),owner,target)
def inverse(~H: Type,~S: Data,~caps: Writable<H,S>,owner: H,target: W.Handle<S>) -> H & Maybe<&2,List<&2,W.Handle<S>>>:
  Cap.request(~H,~W.Handle<S>,~Maybe<&2,List<&2,W.Handle<S>>>,~write_inverse_field(~H,~S,caps),owner,target)
def relate(~H: Type,~S: Data,~caps: Writable<H,S>,owner: H,targets: Targets<S>) -> H & A.QueueStatus:
  Cap.request(~H,~Targets<S>,~A.QueueStatus,~relate_field(~H,~S,caps),owner,targets)
def unrelate(~H: Type,~S: Data,~caps: Writable<H,S>,owner: H,source: W.Handle<S>) -> H & A.QueueStatus:
  Cap.request(~H,~W.Handle<S>,~A.QueueStatus,~clear_field(~H,~S,caps),owner,source)
def handle_ids(~S: Data,ids: List<&2,U32>,+namespace: U32) -> List<&2,W.Handle<S>>:
  match ids:
    case []: []
    case id <> rest: W.Handle{namespace,id} <> handle_ids(~S,rest,namespace)
def handle_snapshot(~S: Data,value: Maybe<&2,List<&2,U32>>,namespace: U32) -> Maybe<&2,List<&2,W.Handle<S>>>:
  match value:
    case None{}: None{}
    case Some{ids}: Some{handle_ids(~S,ids,namespace)}
def inverse_handles(~S: Data,~C: Type,~R: Type,~E: Data,result: W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,List<&2,U32>>,target: W.Handle<S>) -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,List<&2,W.Handle<S>>>:
  match result target:
    case (world,value) W.Handle{ns,_}: (world,handle_snapshot(~S,value,ns))
def inverse_tx_done(~S: Data,~C: Type,~R: Type,~E: Data,result: W.World<S,A.Store<S,C>,R,A.Notice<S,E>> & Maybe<&2,List<&2,W.Handle<S>>>,undo: List<(W.World<S,A.Store<S,C>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>)>,commands: List<(W.World<S,A.Store<S,C>,R,A.Notice<S,E>> -> W.World<S,A.Store<S,C>,R,A.Notice<S,E>>)>,events: List<&2,A.Notice<S,E>>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & Maybe<&2,List<&2,W.Handle<S>>>:
  (world,value) = result
  (X.Tx{world,undo,commands,events},value)
def inverse_tx(~S: Data,~C: Type,~R: Type,~E: Data,~descriptor: G.Descriptor<S>,tx: X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,target: W.Handle<S>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & Maybe<&2,List<&2,W.Handle<S>>>:
  match tx target:
    case X.Tx{world,undo,commands,events} W.Handle{+ns,+id}: inverse_tx_done(~S,~C,~R,~E,inverse_handles(~S,~C,~R,~E,A.inverse(~S,~C,~R,~E,world,descriptor,W.Handle{ns,id}),W.Handle{ns,id}),undo,commands,events)
def relate_tx(~S: Data,~C: Type,~R: Type,~E: Data,~descriptor: G.Descriptor<S>,tx: X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,targets: Targets<S>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  match targets:
    case Targets{source,target}: A.queue_relate(~S,~C,~R,~E,tx,descriptor,source,target)
def clear_tx(~S: Data,~C: Type,~R: Type,~E: Data,~descriptor: G.Descriptor<S>,tx: X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,source: W.Handle<S>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & A.QueueStatus:
  A.queue_unrelate(~S,~C,~R,~E,tx,descriptor,source)
def provide_read(~S: Data,~C: Type,~R: Type,~E: Data,~descriptor: G.Descriptor<S>) -> ReadOnly<X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,S>:
  ReadOnly{Cap.Request{inverse_tx(~S,~C,~R,~E,~descriptor)}}
def provide_write(~S: Data,~C: Type,~R: Type,~E: Data,~descriptor: G.Descriptor<S>) -> Writable<X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,S>:
  Writable{Cap.Request{inverse_tx(~S,~C,~R,~E,~descriptor)},Cap.Request{relate_tx(~S,~C,~R,~E,~descriptor)},Cap.Request{clear_tx(~S,~C,~R,~E,~descriptor)}}
# Rank-two abstract owners with live affine capability bundles. Erased bundles
# cannot be scrutinized in live code; the prior rejected sketches are retained.
def relate_live(-H: Type,-S: Data,caps: Writable<H,S>,owner: H,args: Targets<S>) -> H & A.QueueStatus:
  match caps:
    case Writable{_,Cap.Request{relate},_}: relate(owner,args)
def read_live(-H: Type,-S: Data,caps: ReadOnly<H,S>,owner: H,target: W.Handle<S>) -> H & Maybe<&2,List<&2,W.Handle<S>>>:
  match caps:
    case ReadOnly{Cap.Request{get}}: get(owner,target)
def invoke_write(~S: Data,~C: Type,~R: Type,~E: Data,~descriptor: G.Descriptor<S>,~Out: Type,~body: @-H: Type -> Writable<H,S> -> Targets<S> -> H -> H & Out,args: Targets<S>,tx: X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & Out:
  body(X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,provide_write(~S,~C,~R,~E,~descriptor),args,tx)
def invoke_read(~S: Data,~C: Type,~R: Type,~E: Data,~descriptor: G.Descriptor<S>,~Out: Type,~body: @-H: Type -> ReadOnly<H,S> -> W.Handle<S> -> H -> H & Out,target: W.Handle<S>,tx: X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>) -> X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>> & Out:
  body(X.Tx<W.World<S,A.Store<S,C>,R,A.Notice<S,E>>,A.Notice<S,E>>,provide_read(~S,~C,~R,~E,~descriptor),target,tx)
