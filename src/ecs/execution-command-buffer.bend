import Base
import ./world.bend as W

# Framework storage for one declared component family. Payloads remain affine
# until a whole-World barrier applies them or returns them in a refusal receipt.
type Entry<-S:Data,-P:Type> is Type:
  Entry{handle:W.Handle<S>,incoming:Maybe<&1,P>}
  Despawn{handle:W.Handle<S>}
type Receipt<-S:Data,-P:Type,-D:Type> is Type:
  Applied{handle:W.Handle<S>,previous:Maybe<&1,P>}
  Refused{handle:W.Handle<S>,incoming:Maybe<&1,P>}
  Despawned{handle:W.Handle<S>,removed:D}
  DespawnRefused{handle:W.Handle<S>}
type Buffer<-S:Data,-P:Type,-D:Type> is Type:
  Buffer{pending:List<Entry<S,P>>,receipts:List<Receipt<S,P,D>>}
# Bevy ad678262, schedule/executor/single_threaded.rs: run_without_applying_deferred
# keeps the system's authored buffer, including after a handled RunSystemError.
# Enqueue here only transfers ownership; no component storage is available.
def empty(~S:Data,~P:Type,~D:Type) -> Buffer<S,P,D>:Buffer{[],[]}
def insert(~S:Data,~P:Type,~D:Type,buffer:Buffer<S,P,D>,handle:W.Handle<S>,incoming:P) -> Buffer<S,P,D>:
  match buffer:
    case Buffer{pending,receipts}:Buffer{Entry{handle,Some{incoming}} <> pending,receipts}
def remove(~S:Data,~P:Type,~D:Type,buffer:Buffer<S,P,D>,handle:W.Handle<S>) -> Buffer<S,P,D>:
  match buffer:
    case Buffer{pending,receipts}:Buffer{Entry{handle,None{}} <> pending,receipts}
def despawn(~S:Data,~P:Type,~D:Type,buffer:Buffer<S,P,D>,handle:W.Handle<S>) -> Buffer<S,P,D>:
  match buffer:
    case Buffer{pending,receipts}:Buffer{Despawn{handle} <> pending,receipts}
# Partitioning transfers the existing queue to one worker and gives the other
# a fresh owner. Joining transfers both queues; no command payload is copied.
def split(~S:Data,~P:Type,~D:Type,buffer:Buffer<S,P,D>) -> Buffer<S,P,D> & Buffer<S,P,D>:
  (buffer,empty(~S,~P,~D))
def merge(~S:Data,~P:Type,~D:Type,left:Buffer<S,P,D>,right:Buffer<S,P,D>) -> Buffer<S,P,D>:
  match left right:
    case Buffer{leftPending,leftReceipts} Buffer{rightPending,rightReceipts}:Buffer{List.append(&1,Entry<S,P>,rightPending,leftPending),List.append(&1,Receipt<S,P,D>,rightReceipts,leftReceipts)}
def pending(~S:Data,~P:Type,~D:Type,buffer:Buffer<S,P,D>) -> Buffer<S,P,D> & Bool:
  match buffer:
    case Buffer{[],receipts}:(Buffer{[],receipts},False{})
    case Buffer{head <> rest,receipts}:(Buffer{head <> rest,receipts},True{})
def take_receipts(~S:Data,~P:Type,~D:Type,buffer:Buffer<S,P,D>) -> Buffer<S,P,D> & List<Receipt<S,P,D>>:
  match buffer:
    case Buffer{pending,receipts}:(Buffer{pending,[]},List.reverse(&1,Receipt<S,P,D>,receipts))
