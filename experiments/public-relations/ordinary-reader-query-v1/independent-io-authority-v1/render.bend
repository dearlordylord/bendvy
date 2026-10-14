import Base
import ./consumer.bend as C
import ../mutation-composition-v1/consumer.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as E
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/domains.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/queue.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/readings.bend as R

def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{ns,id}:"Handle{" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "}"
def world_error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def status(value:W.Status) -> String:
  match value:
    case W.Accepted{}:"Accepted"
    case W.Rejected{error}:"Rejected{" ++ world_error(error) ++ "}"
def queued(value:A.QueueStatus) -> String:
  match value:
    case A.Queued{}:"Queued"
    case A.MissingEntity{}:"MissingEntity"
def kind(value:G.RelationKind) -> String:
  match value:
    case G.Ordinary{}:"Ordinary"
    case G.Hierarchy{}:"Hierarchy"
def descriptor(~S:Data,value:G.Descriptor<S>) -> String:
  match value:
    case G.Descriptor{id,name,inverse,k}:"Descriptor{" ++ U32.show(id) ++ "," ++ name ++ "," ++ inverse ++ "," ++ kind(k) ++ "}"
def operation(value:G.Operation) -> String:
  match value:
    case G.Relate{}:"Relate"
    case G.ReorderChildren{}:"ReorderChildren"
def error(value:G.Error) -> String:
  match value:
    case G.MissingEntity{id}:"MissingEntity{" ++ U32.show(id) ++ "}"
    case G.MissingTargetEntity{a,b,r}:"MissingTargetEntity{" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ r ++ "}"
    case G.SelfRelationNotAllowed{a,r}:"SelfRelationNotAllowed{" ++ U32.show(a) ++ "," ++ r ++ "}"
    case G.HierarchyCycle{a,b,r}:"HierarchyCycle{" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ r ++ "}"
    case G.MissingChildEntity{a,b,r}:"MissingChildEntity{" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ r ++ "}"
    case G.DuplicateChild{a,b,r}:"DuplicateChild{" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ r ++ "}"
    case G.ChildNotRelatedToParent{a,b,r}:"ChildNotRelatedToParent{" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ r ++ "}"
    case G.ChildSetMismatch{a,r}:"ChildSetMismatch{" ++ U32.show(a) ++ "," ++ r ++ "}"
def failure(~S:Data,value:G.Failure<S>) -> String:
  match value:
    case G.Failure{d,o,a,b,e}:"Failure{" ++ descriptor(~S,d) ++ "," ++ operation(o) ++ "," ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ error(e) ++ "}"
def frame(~S:Data,value:G.CleanupFrame<S>) -> String:
  match value:
    case G.CleanupEnter{id}:"Enter{" ++ U32.show(id) ++ "}"
    case G.CleanupDescriptors{id,ds}:"Descriptors{" ++ U32.show(id) ++ "," ++ List.show(&2,G.Descriptor<S>,descriptor(~S),ds) ++ "}"
    case G.CleanupChildren{id,d,ds,cs}:"Children{" ++ U32.show(id) ++ "," ++ descriptor(~S,d) ++ "," ++ List.show(&2,G.Descriptor<S>,descriptor(~S),ds) ++ "," ++ List.show(&2,U32,U32.show,cs) ++ "}"
    case G.CleanupFinish{id}:"Finish{" ++ U32.show(id) ++ "}"
def notice(~S:Data,value:A.Notice<S,U32>) -> String:
  match value:
    case A.Original{x}:"Original{" ++ U32.show(x) ++ "}"
    case A.RelationFailed{x}:"RelationFailed{" ++ failure(~S,x) ++ "}"
    case A.ComponentRemoved{x}:"Removed{" ++ U32.show(x) ++ "}"
    case A.CleanupPaused{xs}:"Paused{" ++ List.show(&2,G.CleanupFrame<S>,frame(~S),xs) ++ "}"
def key(~S:Data,value:D.DescriptorKey<S>) -> String:
  match value:
    case D.DeclaredKey{id}:"Key{" ++ U32.show(id) ++ "}"
def batch(~S:Data,value:Q.Batch<A.Notice<S,U32>>) -> String:
  match value:
    case Q.Batch{tick,count,values}:"Batch{" ++ Nat.show(tick) ++ "," ++ Nat.show(count) ++ "," ++ List.show(&2,A.Notice<S,U32>,notice(~S),values) ++ "}"
def queue(~S:Data,value:Q.Queue<A.Notice<S,U32>>) -> String:
  match value:
    case Q.Queue{front,back,size,dropped}:"Queue{" ++ List.show(&2,Q.Batch<A.Notice<S,U32>>,batch(~S),front) ++ "," ++ List.show(&2,Q.Batch<A.Notice<S,U32>>,batch(~S),back) ++ "," ++ Nat.show(size) ++ "," ++ Nat.show(dropped) ++ "}"
def domain(~S:Data,value:D.Domain<S,A.Notice<S,U32>>) -> String:
  match value:
    case D.Domain{k,q,readers}:"Domain{" ++ key(~S,k) ++ "," ++ queue(~S,q) ++ "," ++ List.show(&2,U32,U32.show,readers) ++ "}"
def position(value:E.Position) -> String:
  match value:
    case E.Position{id,cursor,registered}:"Position{" ++ U32.show(id) ++ "," ++ Nat.show(cursor) ++ "," ++ Nat.show(registered) ++ "}"
def registry(value:M.RegistryView) -> String:
  match value:
    case M.RegistryView{ns,id,name,access,cursor}:"Registry{" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ name ++ "," ++ List.show(&2,String,x => x,access) ++ "," ++ U32.show(cursor) ++ "}"
def snapshot(~S:Data,value:M.Snapshot<S>) -> String:
  match value:
    case M.Snapshot{world,events,domains,positions,tick,start,boundary,capacity,w,i,f,args}:"Snapshot{" ++ world ++ "," ++ List.show(&2,A.Notice<S,U32>,notice(~S),events) ++ "," ++ List.show(&2,D.Domain<S,A.Notice<S,U32>>,domain(~S),domains) ++ "," ++ List.show(&2,E.Position,position,positions) ++ "," ++ Nat.show(tick) ++ "," ++ Nat.show(start) ++ "," ++ Nat.show(boundary) ++ "," ++ Nat.show(capacity) ++ "," ++ registry(w) ++ "," ++ registry(i) ++ "," ++ registry(f) ++ "," ++ List.show(&2,U32,U32.show,args) ++ "}"
def reading(~S:Data,value:R.KeyReading<S,A.Notice<S,U32>>) -> String:
  match value:
    case R.KeyReading{k,values,lagged}:"Reading{" ++ key(~S,k) ++ "," ++ List.show(&2,A.Notice<S,U32>,notice(~S),values) ++ "," ++ Bool.show(lagged) ++ "}"
def report_body(~S:Data,value:M.Report<S>) -> String:
  match value:
    case M.Report{snapshots,writes,queries,deliveries}:"Receiver{" ++ List.show(&2,M.Snapshot<S>,snapshot(~S),snapshots) ++ "," ++ List.show(&2,A.QueueStatus,queued,writes) ++ "," ++ List.show(&2,Maybe<&2,List<&2,W.Handle<S>>>,x => Maybe.show(&2,List<&2,W.Handle<S>>,y => List.show(&2,W.Handle<S>,handle(~S),y),x),queries) ++ "," ++ List.show(&2,List<&2,R.KeyReading<S,A.Notice<S,U32>>>,x => List.show(&2,R.KeyReading<S,A.Notice<S,U32>>,reading(~S),x),deliveries) ++ "}"
def report(~S:Data,value:C.Report<S>) -> String:
  match value:
    case C.Report{receiver,foreign,local,target,alien,lookup,receiverStatus,foreignStatus}:"Report{" ++ report_body(~S,receiver) ++ "," ++ List.show(&2,String,x => x,foreign) ++ "," ++ handle(~S,local) ++ "," ++ handle(~S,target) ++ "," ++ handle(~S,alien) ++ "," ++ Maybe.show(&2,List<&2,U32>,x => List.show(&2,U32,U32.show,x),lookup) ++ "," ++ List.show(&2,W.Status,status,receiverStatus) ++ "," ++ List.show(&2,W.Status,status,foreignStatus) ++ "}"
def completed(~S:Data,value:Maybe<C.Report<S>>) -> IO(Unit):
  IO.print(Maybe.show(&1,C.Report<S>,report(~S),value))
