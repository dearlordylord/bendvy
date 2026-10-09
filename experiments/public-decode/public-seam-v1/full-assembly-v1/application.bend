import Base
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity
import ./request.bend as Deferred
import /workspace/formal-proofs/bendvy/experiments/public-decode/adoption-v1/application.bend as Legacy
import /workspace/formal-proofs/bendvy/experiments/public-decode/adoption-v1/admission.bend as Gate
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/experiments/public-decode/adoption-v1/observation.bend as O
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as Delivery
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

# Explicit application recovery destination; no library default or finalizer.
type Mail<S:Data> is Type:
  Mail{value:Input.Owner,retired:List<Input.Owner>,returned:List<Deferred.Packet<Input.Owner>>,errors:List<&2,W.WorldError>}
def initial(~S:Data,value:Input.Owner) -> Mail<S>:Mail{value,[],[],[]}
def Store(~S:Data) -> Type:Legacy.Store(~S)
def World(~S:Data) -> Type:W.World<S,Store(~S),Mail<S>,Unit>
def identity(~S:Data) -> Identity.Declaration<S,Input.Owner>:Legacy.identity(~S)
def resource_identity(~S:Data) -> Identity.Declaration<S,Input.Owner>:Legacy.resource_identity(~S)
def take(~S:Data,column:Store(~S)) -> Unit & Col.Column<S,Input.Owner>:Legacy.take(~S,column)
def put(~S:Data,rest:Unit,column:Col.Column<S,Input.Owner>) -> Store(~S):Legacy.put(~S,rest,column)
def family(~S:Data) -> C.Family<S,Store(~S),Unit,Input.Owner,D.Raw,Unit,take(~S),put(~S),Input.project>:
  C.Family{Identity.key(~S,~Input.Owner,identity(~S))}
type Operation is Data:Insert{} Resource{} Spawn{}
type Output<-S:Data> is Type:
  Replaced{original:D.Raw,previous:Maybe<&1,Input.Owner>,handle:Maybe<&2,W.Handle<S>>}
  OperationRefused{original:D.Raw,incoming:Maybe<&1,Input.Owner>,error:W.WorldError}
  TypedAborted{packets:List<Deferred.Packet<Input.Owner>>,error:Unit}
def retire(~S:Data,mail:Mail<S>,previous:Maybe<&1,Input.Owner>) -> Mail<S>:
  match mail previous:
    case Mail{value,retired,returned,errors} None{}:Mail{value,retired,returned,errors}
    case Mail{value,retired,returned,errors} Some{owner}:Mail{value,owner <> retired,returned,errors}
def retired(~S:Data,previous:Maybe<&1,Input.Owner>,world:World(~S)) -> World(~S):
  match world:
    case W.World{ns,next,high,live,cap,depth,store,mail,events,commands,regs,system,clock}:W.World{ns,next,high,live,cap,depth,store,retire(~S,mail,previous),events,commands,regs,system,clock}
def recover(~S:Data,world:World(~S),packet:Deferred.Packet<Input.Owner>,error:W.WorldError) -> World(~S):
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{value,retired,returned,errors},events,commands,regs,system,clock}:W.World{ns,next,high,live,cap,depth,store,Mail{value,retired,packet <> returned,error <> errors},events,commands,regs,system,clock}
def attempted(~S:Data,+original:D.Raw,+canonical:D.Raw,result:C.Replacement<World(~S),Input.Owner>) -> Delivery.Delivery<World(~S),Deferred.Packet<Input.Owner>>:
  match result:
    case C.Replaced{world,previous}:Delivery.Delivered{retired(~S,previous,world)}
    case C.ReplaceRejected{world,incoming,error}:Delivery.Undelivered{world,Deferred.Packet{Legacy.original_incoming(original,incoming),original,canonical},error}
def normalized_attempt(~S:Data,world:World(~S),+target:W.Handle<S>,+original:D.Raw,+canonical:D.Raw,owner:Maybe<&1,Input.Owner>) -> Delivery.Delivery<World(~S),Deferred.Packet<Input.Owner>>:
  match owner:
    case None{}:Delivery.Undelivered{world,Deferred.Packet{None{},original,canonical},W.CapacityExceeded{}}
    case Some{Input.Owner{_,sentinel}}:attempted(~S,original,canonical,C.replace(~S,~Store(~S),~Mail<S>,~Unit,~Unit,~Input.Owner,~D.Raw,~Unit,~take(~S),~put(~S),~Input.project,family(~S),world,target,Some{Input.Owner{canonical,sentinel}}))
def attempt(~S:Data,world:World(~S),target:W.Handle<S>,packet:Deferred.Packet<Input.Owner>) -> Delivery.Delivery<World(~S),Deferred.Packet<Input.Owner>>:
  match packet:
    case Deferred.Packet{owner,original,canonical}:normalized_attempt(~S,world,target,original,canonical,owner)
def command_body(~S:Data,-H:Type,cap:Cap.OwnedRequest<H,Deferred.Input<S,Input.Owner>,Deferred.Output<S,Input.Owner>>,input:Deferred.Input<S,Input.Owner>,ctx:H) -> H & Deferred.Output<S,Input.Owner>:
  match cap:
    case Cap.OwnedRequest{run}:run(ctx,input)
# This transport retains ALL finish branches without inventing an entity error
# for a transaction abort or synthesizing a missing affine payload.
type Executed<S:Data> is Type:
  Committed{world:World(~S),output:Deferred.Output<S,Input.Owner>}
  Aborted{world:World(~S),output:Deferred.Output<S,Input.Owner>,packets:List<Deferred.Packet<Input.Owner>>,error:Unit}
def finished(~S:Data,result:Batch.Finished<S,Store(~S),Mail<S>,Unit,Deferred.Packet<Input.Owner>,Unit>,output:Deferred.Output<S,Input.Owner>) -> Executed<S>:
  match result:
    case Batch.Committed{world}:Committed{world,output}
    case Batch.Failed{world,packets,error}:Aborted{world,output,packets,error}
def requested(~S:Data,completion:T.Outcome<Unit>,result:Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,identity(~S),Input.project> & Deferred.Output<S,Input.Owner>) -> Executed<S>:
  match result:
    case (owner,output):finished(~S,Deferred.finish(~S,~Store(~S),~Mail<S>,~Unit,~Input.Owner,~Unit,~identity(~S),~Input.project,~attempt(~S),~recover(~S),owner,completion),output)
def command(~S:Data,completion:T.Outcome<Unit>,operation:Commands.Operation<S>,codec:D.Codec,world:World(~S),owner:Input.Owner) -> Executed<S>:
  requested(~S,completion,Deferred.invoke(~S,~Store(~S),~Mail<S>,~Unit,~Input.Owner,~Deferred.Input<S,Input.Owner>,~Deferred.Output<S,Input.Owner>,~identity(~S),~Input.project,~(H => cap => input => ctx => command_body(~S,H,cap,input,ctx)),Deferred.Owner{Batch.begin(~S,~Store(~S),~Mail<S>,~Unit,~Deferred.Packet<Input.Owner>,T.begin(~World(~S),~Unit,world)),Decl.constructed(~S,~Input.Owner,~identity(~S),~Input.project,codec)},Deferred.Input{operation,owner}))

# Resource journal for the declared value preserves unrelated recovery owners.
# This follows Resource.tx_replace's old-owner undo/displaced-owner semantics.
def swap_value(~S:Data,world:World(~S),incoming:Input.Owner) -> World(~S) & Input.Owner:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,Mail{old,retired,returned,errors},events,commands,regs,system,clock}:(W.World{ns,next,high,live,cap,depth,store,Mail{incoming,retired,returned,errors},events,commands,regs,system,clock},old)
def restore_value_join(~S:Data,result:World(~S) & Input.Owner) -> World(~S):
  match result:
    case (world,displaced):world
def restore_value(~S:Data,world:World(~S),old:Input.Owner) -> World(~S):restore_value_join(~S,swap_value(~S,world,old))
def replaced_value(~S:Data,result:World(~S) & Input.Owner,undo:List<(World(~S) -> World(~S))>,commands:List<(World(~S) -> World(~S))>,events:List<&2,Unit>) -> T.Tx<World(~S),Unit>:
  match result:
    case (world,old):T.Tx{world,(w => restore_value(~S,w,old)) <> undo,commands,events}
def resource_replace(~S:Data,frame:Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project>,incoming:Input.Owner) -> Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project> & Unit:
  match frame:
    case Deferred.Owner{Batch.Batch{T.Tx{world,undo,commands,events},prepared},declaration}:(Deferred.Owner{Batch.Batch{replaced_value(~S,swap_value(~S,world,incoming),undo,commands,events),prepared},declaration},Unit{})
def resource_grant(~S:Data) -> Cap.OwnedRequest<Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project>,Input.Owner,Unit>:
  Cap.OwnedRequest{(frame => incoming => resource_replace(~S,frame,incoming))}

def resource_body(~S:Data,-H:Type,cap:Cap.OwnedRequest<H,Input.Owner,Unit>,replacement:Input.Owner,ctx:H) -> H & Unit:
  match cap:
    case Cap.OwnedRequest{run}:run(ctx,replacement)
def resource_mutated(~S:Data,target:W.Handle<S>,canonical:D.Raw,result:Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project> & Unit) -> Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project> & Deferred.Output<S,Input.Owner>:
  match result:
    case (owner,_):(owner,Deferred.Accepted{target,False{},canonical})
def resource_validated(~S:Data,+target:W.Handle<S>,frame:Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project>,receipt:D.Receipt<Input.Owner>) -> Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project> & Deferred.Output<S,Input.Owner>:
  match receipt:
    case D.Receipt{owner,D.Rejected{error}}:(frame,Deferred.Refused{Some{owner},Deferred.Validation{error}})
    case D.Receipt{Input.Owner{original,sentinel},D.Accepted{+canonical}}:resource_mutated(~S,target,canonical,Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Input.Owner,Unit>),~Input.Owner,~Unit,~(H => cap => replacement => ctx => resource_body(~S,H,cap,replacement,ctx)),~Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project>,~resource_grant(~S),Input.Owner{canonical,sentinel},frame))
def resource_request(~S:Data,target:W.Handle<S>,frame:Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project>,incoming:Input.Owner) -> Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project> & Deferred.Output<S,Input.Owner>:
  match frame:
    case Deferred.Owner{batch,+declaration}:resource_validated(~S,target,Deferred.Owner{batch,declaration},Decl.validate(~S,~Input.Owner,~resource_identity(~S),~Input.project,declaration,incoming))
def resource_finished(~S:Data,completion:T.Outcome<Unit>,result:Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project> & Deferred.Output<S,Input.Owner>) -> Executed<S>:
  match result:
    case (owner,output):finished(~S,Deferred.finish(~S,~Store(~S),~Mail<S>,~Unit,~Input.Owner,~Unit,~resource_identity(~S),~Input.project,~attempt(~S),~recover(~S),owner,completion),output)
def resource(~S:Data,completion:T.Outcome<Unit>,target:W.Handle<S>,codec:D.Codec,world:World(~S),incoming:Input.Owner) -> Executed<S>:
  resource_finished(~S,completion,resource_request(~S,target,Deferred.Owner{Batch.begin(~S,~Store(~S),~Mail<S>,~Unit,~Deferred.Packet<Input.Owner>,T.begin(~World(~S),~Unit,world)),Decl.constructed(~S,~Input.Owner,~resource_identity(~S),~Input.project,codec)},incoming))
def request_with_completion(~S:Data,completion:T.Outcome<Unit>,target:W.Handle<S>,operation:Operation,codec:D.Codec,world:World(~S),incoming:Input.Owner) -> Executed<S>:
  match operation:
    case Insert{}:command(~S,completion,Commands.Insert{target},codec,world,incoming)
    case Spawn{}:command(~S,completion,Commands.Spawn{},codec,world,incoming)
    case Resource{}:resource(~S,completion,target,codec,world,incoming)

def request(~S:Data,target:W.Handle<S>,operation:Operation,codec:D.Codec,world:World(~S),incoming:Input.Owner) -> Executed<S>:
  request_with_completion(~S,T.Success{},target,operation,codec,world,incoming)

# Already-typed Plain/Transient and the explicit constructor-result selector use
# the SAME actual resource grant after their own agreed validation/precedence.
def typed_finished(~S:Data,+original:D.Raw,result:Batch.Finished<S,Store(~S),Mail<S>,Unit,Deferred.Packet<Input.Owner>,Unit>) -> World(~S) & Output<S>:
  match result:
    case Batch.Committed{world}:(world,Replaced{original,None{},None{}})
    case Batch.Failed{world,packets,error}:(world,TypedAborted{packets,error})
def typed_requested(~S:Data,original:D.Raw,result:Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project> & Unit) -> World(~S) & Output<S>:
  match result:
    case (owner,_):typed_finished(~S,original,Deferred.finish(~S,~Store(~S),~Mail<S>,~Unit,~Input.Owner,~Unit,~resource_identity(~S),~Input.project,~attempt(~S),~recover(~S),owner,T.Success{}))
def typed_normalized(~S:Data,world:World(~S),+canonical:D.Raw,owner:Input.Owner) -> World(~S) & Output<S>:
  match owner:
    case Input.Owner{original,sentinel}:typed_requested(~S,original,Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Input.Owner,Unit>),~Input.Owner,~Unit,~(H => cap => replacement => ctx => resource_body(~S,H,cap,replacement,ctx)),~Deferred.Owner<S,Store(~S),Mail<S>,Unit,Input.Owner,resource_identity(~S),Input.project>,~resource_grant(~S),Input.Owner{canonical,sentinel},Deferred.Owner{Batch.begin(~S,~Store(~S),~Mail<S>,~Unit,~Deferred.Packet<Input.Owner>,T.begin(~World(~S),~Unit,world)),Decl.constructed(~S,~Input.Owner,~resource_identity(~S),~Input.project,D.Literal{canonical})}))
def resource_typed(~S:Data,world:World(~S),owner:Input.Owner,canonical:D.Raw) -> World(~S) & Output<S>:
  typed_normalized(~S,world,canonical,owner)
