import Base
import ./world.bend as W

# Framework storage for one declared component family. Payloads remain affine
# until a whole-World barrier applies them or returns them in a refusal receipt.
type Entry<-S:Data,-P:Type> is Type:
  Entry{handle:W.Handle<S>,incoming:Maybe<&1,P>}
type Receipt<-S:Data,-P:Type> is Type:
  Applied{handle:W.Handle<S>,previous:Maybe<&1,P>}
  Refused{handle:W.Handle<S>,incoming:Maybe<&1,P>}
type Buffer<-S:Data,-P:Type> is Type:
  Buffer{pending:List<Entry<S,P>>,receipts:List<Receipt<S,P>>}
# Bevy ad678262, schedule/executor/single_threaded.rs: run_without_applying_deferred
# keeps the system's authored buffer, including after a handled RunSystemError.
# Enqueue here only transfers ownership; no component storage is available.
def empty(~S:Data,~P:Type) -> Buffer<S,P>:Buffer{[],[]}
def insert(~S:Data,~P:Type,buffer:Buffer<S,P>,handle:W.Handle<S>,incoming:P) -> Buffer<S,P>:
  match buffer:
    case Buffer{pending,receipts}:Buffer{Entry{handle,Some{incoming}} <> pending,receipts}
def remove(~S:Data,~P:Type,buffer:Buffer<S,P>,handle:W.Handle<S>) -> Buffer<S,P>:
  match buffer:
    case Buffer{pending,receipts}:Buffer{Entry{handle,None{}} <> pending,receipts}
# Partitioning transfers the existing queue to one worker and gives the other
# a fresh owner. Joining transfers both queues; no command payload is copied.
def split(~S:Data,~P:Type,buffer:Buffer<S,P>) -> Buffer<S,P> & Buffer<S,P>:
  (buffer,empty(~S,~P))
def merge(~S:Data,~P:Type,left:Buffer<S,P>,right:Buffer<S,P>) -> Buffer<S,P>:
  match left right:
    case Buffer{leftPending,leftReceipts} Buffer{rightPending,rightReceipts}:Buffer{List.append(&1,Entry<S,P>,rightPending,leftPending),List.append(&1,Receipt<S,P>,rightReceipts,leftReceipts)}
def pending(~S:Data,~P:Type,buffer:Buffer<S,P>) -> Buffer<S,P> & Bool:
  match buffer:
    case Buffer{[],receipts}:(Buffer{[],receipts},False{})
    case Buffer{head <> rest,receipts}:(Buffer{head <> rest,receipts},True{})
def take_receipts(~S:Data,~P:Type,buffer:Buffer<S,P>) -> Buffer<S,P> & List<Receipt<S,P>>:
  match buffer:
    case Buffer{pending,receipts}:(Buffer{pending,[]},List.reverse(&1,Receipt<S,P>,receipts))
