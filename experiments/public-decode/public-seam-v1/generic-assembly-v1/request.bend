import Base
import /workspace/formal-proofs/bendvy/src/ecs/resource.bend as Resource
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as Delivery
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-declaration.bend as Identity

# The packet owns original P plus detached canonical input. Typed schema delivery
# constructs its actual component; no generic Raw -> arbitrary Type inverse.
type Packet<P:Type> is Type:
  Packet{owner:Maybe<&1,P>,original:D.Raw,canonical:D.Raw}
type Input<S:Data,P:Type> is Type:
  Input{operation:Commands.Operation<S>,owner:P}
type Error is Data:
  Validation{error:D.Error}
  Entity{error:W.WorldError}
type Output<S:Data,P:Type> is Type:
  Accepted{target:W.Handle<S>,spawned:Bool,canonical:D.Raw}
  Refused{owner:Maybe<&1,P>,error:Error}
type Owner<S:Data,C:Type,R:Type,E:Data,P:Type,-identity:Identity.Declaration<S,P>,-project:P -> P & D.Raw> is Type:
  Owner{batch:Batch.Batch<S,C,R,E,Packet<P>>,declaration:Decl.Constructed<S,P,identity,project>}

def inserted(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,target:W.Handle<S>,canonical:D.Raw,result:Batch.Inserted<S,C,R,E,Packet<P>>) -> Owner<S,C,R,E,P,identity,project> & Output<S,P>:
  match result:
    case Batch.Inserted{batch}:(Owner{batch,declaration},Accepted{target,False{},canonical})
    case Batch.Refused{batch,Packet{owner,_,_},error}:(Owner{batch,declaration},Refused{owner,Entity{error}})
def spawned(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,canonical:D.Raw,result:Batch.Spawned<S,C,R,E,Packet<P>>) -> Owner<S,C,R,E,P,identity,project> & Output<S,P>:
  match result:
    case Batch.Spawned{batch,target}:(Owner{batch,declaration},Accepted{target,True{},canonical})
    case Batch.SpawnRefused{batch,Packet{owner,_,_},error}:(Owner{batch,declaration},Refused{owner,Entity{error}})
def enqueue_packet(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,batch:Batch.Batch<S,C,R,E,Packet<P>>,operation:Commands.Operation<S>,owner:P,original:D.Raw,+canonical:D.Raw) -> Owner<S,C,R,E,P,identity,project> & Output<S,P>:
  match operation:
    case Commands.Insert{+target}:inserted(~S,~C,~R,~E,~P,~identity,~project,declaration,target,canonical,Batch.insert(~S,~C,~R,~E,~Packet<P>,batch,target,Packet{Some{owner},original,canonical}))
    case Commands.Spawn{}:spawned(~S,~C,~R,~E,~P,~identity,~project,declaration,canonical,Batch.spawn(~S,~C,~R,~E,~Packet<P>,batch,Packet{Some{owner},original,canonical}))
def enqueue(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,batch:Batch.Batch<S,C,R,E,Packet<P>>,operation:Commands.Operation<S>,canonical:D.Raw,projected:P & D.Raw) -> Owner<S,C,R,E,P,identity,project> & Output<S,P>:
  match projected:
    case (owner,original):enqueue_packet(~S,~C,~R,~E,~P,~identity,~project,declaration,batch,operation,owner,original,canonical)
def validated(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,batch:Batch.Batch<S,C,R,E,Packet<P>>,operation:Commands.Operation<S>,receipt:D.Receipt<P>) -> Owner<S,C,R,E,P,identity,project> & Output<S,P>:
  match receipt:
    case D.Receipt{owner,D.Rejected{error}}:(Owner{batch,declaration},Refused{Some{owner},Validation{error}})
    case D.Receipt{owner,D.Accepted{canonical}}:enqueue(~S,~C,~R,~E,~P,~identity,~project,declaration,batch,operation,canonical,project(owner))
def request(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,frame:Owner<S,C,R,E,P,identity,project>,input:Input<S,P>) -> Owner<S,C,R,E,P,identity,project> & Output<S,P>:
  match frame input:
    case Owner{batch,+declaration} Input{operation,owner}:validated(~S,~C,~R,~E,~P,~identity,~project,declaration,batch,operation,Decl.validate(~S,~P,~identity,~project,declaration,owner))
def grant(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw) -> Cap.OwnedRequest<Owner<S,C,R,E,P,identity,project>,Input<S,P>,Output<S,P>>:
  Cap.OwnedRequest{frame => input => request(~S,~C,~R,~E,~P,~identity,~project,frame,input)}
def invoke(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~A:Type,~U:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~body:@-H:Type -> @-cap:Cap.OwnedRequest<H,Input<S,P>,Output<S,P>> -> A -> H -> H & U,owner:Owner<S,C,R,E,P,identity,project>,args:A) -> Owner<S,C,R,E,P,identity,project> & U:
  Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Input<S,P>,Output<S,P>>),~A,~U,~body,~Owner<S,C,R,E,P,identity,project>,~grant(~S,~C,~R,~E,~P,~identity,~project),args,owner)
def finish(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Error:Data,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,~attempt:W.World<S,C,R,E> -> W.Handle<S> -> Packet<P> -> Delivery.Delivery<W.World<S,C,R,E>,Packet<P>>,~recover:W.World<S,C,R,E> -> Packet<P> -> W.WorldError -> W.World<S,C,R,E>,owner:Owner<S,C,R,E,P,identity,project>,outcome:T.Outcome<Error>) -> Batch.Finished<S,C,R,E,Packet<P>,Error>:
  match owner:
    case Owner{batch,_}:Batch.finish(~S,~C,~R,~E,~Packet<P>,~Error,~attempt,~recover,batch,outcome)

# Additive trusted resource provider over the SAME transaction; gameplay can use
# it only when provisioning explicitly includes this owned grant in its Ops.
def resource_replaced(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,declaration:Decl.Constructed<S,P,identity,project>,prepared:List<Batch.Prepared<S,Packet<P>>>,tx:T.Tx<W.World<S,C,R,E>,E>) -> Owner<S,C,R,E,P,identity,project> & Unit:
  (Owner{Batch.Batch{tx,prepared},declaration},Unit{})
def replace_resource(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw,owner:Owner<S,C,R,E,P,identity,project>,replacement:R) -> Owner<S,C,R,E,P,identity,project> & Unit:
  match owner:
    case Owner{Batch.Batch{tx,prepared},declaration}:resource_replaced(~S,~C,~R,~E,~P,~identity,~project,declaration,prepared,Resource.tx_replace(~S,~C,~R,~E,tx,replacement))
def resource_grant(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~identity:Identity.Declaration<S,P>,~project:P -> P & D.Raw) -> Cap.OwnedRequest<Owner<S,C,R,E,P,identity,project>,R,Unit>:
  Cap.OwnedRequest{owner => replacement => replace_resource(~S,~C,~R,~E,~P,~identity,~project,owner,replacement)}
