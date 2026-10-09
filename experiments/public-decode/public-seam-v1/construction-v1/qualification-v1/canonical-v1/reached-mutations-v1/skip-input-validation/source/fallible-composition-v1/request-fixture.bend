import ./business.bend as Business
import Base
import ../fixture.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/skip-input-validation/core/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/skip-input-validation/core/decode-fallible-constructed-requests.bend as Constructed
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-construction.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/decode-local.bend as Completion
import /workspace/formal-proofs/bendvy/src/ecs/decode-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/bundle-delivery.bend as Delivery
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

def Frame(~S:Data) -> Type:F.Frame<S,Unit,Input.Owner,Unit,Input.Owner,Unit,Input.identity(~S),Input.project>
def factory(~S:Data,~codec:D.Codec) -> Constructor.FallibleFactory<S,Input.Input,Input.Owner,Business.Error,Input.identity(~S),Input.project,Input.incoming,Business.build>:
  Constructor.fallible_factory(~S,~Input.Input,~Input.Owner,~Business.Error,~Input.identity(~S),~Input.project,~Input.incoming,~Business.build,Decl.constructed(~S,~Input.Owner,~Input.identity(~S),~Input.project,codec))
def grants(~S:Data,~codec:D.Codec) -> Cap.OwnedRequest<Frame(~S),Constructed.Input<S,Input.Input>,Constructed.Output<S,Input.Input,Input.Owner,Business.Error>>:
  Constructed.grant(~S,~Input.Input,~Input.Owner,~Business.Error,~Input.identity(~S),~Input.project,~Input.incoming,~Business.build,~factory(~S,~codec),~Frame(~S),~F.request_grant(~S,~Unit,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project))
def body(~S:Data,~H:Type,~cap:Cap.OwnedRequest<H,Constructed.Input<S,Input.Input>,Constructed.Output<S,Input.Input,Input.Owner,Business.Error>>,input:Constructed.Input<S,Input.Input>,ctx:H) -> H & Constructed.Output<S,Input.Input,Input.Owner,Business.Error>:
  Cap.owned_request(~H,~Constructed.Input<S,Input.Input>,~Constructed.Output<S,Input.Input,Input.Owner,Business.Error>,~cap,ctx,input)
type ResultView is Data:Accepted{namespace:U32,id:U32,spawned:Bool,canonical:D.Raw} Refused{owner:Maybe<&2,Input.InputView>,error:Constructed.Error<Business.Error>}
type Report is Data:Report{after:Input.Snapshot,prepared:Nat,result:ResultView,recovered:List<&2,Input.InputView>,completion:T.Outcome<Unit>} CreateRejected{}
def reversed_join(value:Input.Input & Input.InputView) -> Input.InputView:
  match value:
    case (_,view):view
def reversed(reverse:Input.Owner -> Input.Input,packet:Request.Packet<Input.Owner>) -> List<&2,Input.InputView>:
  match packet:
    case Request.Packet{None{},_,_}:[]
    case Request.Packet{Some{owner},_,_}:[reversed_join(Input.input_view(reverse(owner)))]
def recover(reverse:Input.Owner -> Input.Input,packets:List<Request.Packet<Input.Owner>>) -> List<&2,Input.InputView>:
  match packets:
    case []:[]
    case head <> rest:List.append(&2,Input.InputView,reversed(reverse,head),[])
# This route always aborts the accepted batch in the fixture; no delivery policy
# is selected. The explicit undo is consumed once after Batch returns its P.
def attempt(~S:Data,world:W.World<S,Unit,Input.Owner,Unit>,target:W.Handle<S>,packet:Request.Packet<Input.Owner>) -> Delivery.Delivery<W.World<S,Unit,Input.Owner,Unit>,Request.Packet<Input.Owner>>:
  Delivery.Undelivered{world,packet,W.MissingEntity{}}
def delivery_recover(~S:Data,world:W.World<S,Unit,Input.Owner,Unit>,packet:Request.Packet<Input.Owner>,error:W.WorldError) -> W.World<S,Unit,Input.Owner,Unit>:world
def refusal_view(error:Constructed.Error<Business.Error>,value:Input.Input & Input.InputView) -> ResultView:
  match value:
    case (_,view):Refused{Some{view},error}
def refusal(error:Constructed.Error<Business.Error>,owner:Maybe<&1,Input.Input>) -> ResultView:
  match owner:
    case None{}:Refused{None{},error}
    case Some{owner}:refusal_view(error,Input.input_view(owner))
def observed(~S:Data,prepared:Nat,result:ResultView,recovered:List<&2,Input.InputView>,completion:T.Outcome<Unit>,value:W.World<S,Unit,Input.Owner,Unit> & Input.Snapshot) -> Report:
  match value:
    case (_,after):Report{after,prepared,result,recovered,completion}
def finished(~S:Data,prepared:Nat,result:ResultView,reverse:Maybe<&1,(Input.Owner -> Input.Input)>,value:Batch.Finished<S,Unit,Input.Owner,Unit,Request.Packet<Input.Owner>,Unit>) -> Report:
  match reverse value:
    case Some{reverse},Batch.Failed{world,packets,error}:observed(~S,prepared,result,recover(reverse,packets),T.Failure{error},Input.snapshot(~S,world))
    case None{},Batch.Failed{world,_,error}:observed(~S,prepared,result,[],T.Failure{error},Input.snapshot(~S,world))
    case _,Batch.Committed{world}:observed(~S,prepared,result,[],T.Success{},Input.snapshot(~S,world))
def returned(~S:Data,result:Frame(~S) & Constructed.Output<S,Input.Input,Input.Owner,Business.Error>) -> Report:
  match result:
    case (F.Frame{owner,_,_,_,_,_},Constructed.Accepted{W.Handle{namespace,id},spawned,canonical,undo}):finished(~S,1n,Accepted{namespace,id,spawned,canonical},Some{undo},Request.finish(~S,~Unit,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,~attempt(~S),~delivery_recover(~S),owner,T.Failure{Unit{}}))
    case (F.Frame{owner,_,_,_,_,_},Constructed.Refused{raw,error}):finished(~S,0n,refusal(error,raw),None{},Request.finish(~S,~Unit,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,~attempt(~S),~delivery_recover(~S),owner,T.Failure{Unit{}}))
def in_world(~S:Data,~codec:D.Codec,operation:Commands.Operation<S>,raw:D.Raw,world:W.World<S,Unit,Input.Owner,Unit>) -> Report:
  returned(~S,Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Constructed.Input<S,Input.Input>,Constructed.Output<S,Input.Input,Input.Owner,Business.Error>>),~Constructed.Input<S,Input.Input>,~Constructed.Output<S,Input.Input,Input.Owner,Business.Error>,~(H => cap => input => ctx => body(~S,~H,~cap,input,ctx)),~Frame(~S),~grants(~S,~codec),Constructed.Input{operation,Input.input(raw)},Completion.begin_frame(~S,~Unit,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,world,Decl.constructed(~S,~Input.Owner,~Input.identity(~S),~Input.project,codec))))
def created(~S:Data,~codec:D.Codec,operation:Commands.Operation<S>,raw:D.Raw,value:W.Creation<S,Unit,Input.Owner,Unit>) -> Report:
  match value:
    case W.CreateRejected{_,_}:CreateRejected{}
    case W.Created{_,world}:in_world(~S,~codec,operation,raw,world)
def run(~S:Data,~codec:D.Codec,operation:Commands.Operation<S>,raw:D.Raw) -> Report:created(~S,~codec,operation,raw,W.create(~S,~Unit,~Input.Owner,~Unit,~(u => Unit{}),W.factory(),Input.owned(D.Number{100})))
def foreign_active(~S:Data,world:W.World<S,Unit,Input.Owner,Unit>,target:W.Handle<S>,other:W.World<S,Unit,Input.Owner,Unit> & W.Status) -> Report:
  match other:
    case (_,W.Rejected{_}):CreateRejected{}
    case (_,W.Accepted{}):in_world(~S,~D.Integer{},Commands.Insert{target},D.Number{11},world)
def foreign_reserved(~S:Data,world:W.World<S,Unit,Input.Owner,Unit>,other:W.World<S,Unit,Input.Owner,Unit> & W.Reservation<S>) -> Report:
  match other:
    case (_,W.ReservationRejected{_}):CreateRejected{}
    case (other,W.Reserved{+target}):foreign_active(~S,world,target,W.activate(~S,~Unit,~Input.Owner,~Unit,other,target))
def foreign_created(~S:Data,world:W.World<S,Unit,Input.Owner,Unit>,other:W.Creation<S,Unit,Input.Owner,Unit>) -> Report:
  match other:
    case W.CreateRejected{_,_}:CreateRejected{}
    case W.Created{_,other}:foreign_reserved(~S,world,W.reserve_id(~S,~Unit,~Input.Owner,~Unit,other))
def foreign_primary(~S:Data,value:W.Creation<S,Unit,Input.Owner,Unit>) -> Report:
  match value:
    case W.CreateRejected{_,_}:CreateRejected{}
    case W.Created{factory,world}:foreign_created(~S,world,W.create(~S,~Unit,~Input.Owner,~Unit,~(u => Unit{}),factory,Input.owned(D.Number{200})))
def foreign(~S:Data) -> Report:foreign_primary(~S,W.create(~S,~Unit,~Input.Owner,~Unit,~(u => Unit{}),W.factory(),Input.owned(D.Number{100})))
type Cases is Data:Cases{spawnAbort:Report,constructorDenied:Report,foreignInsert:Report,invalidSpawn:Report}
def cases(~S:Data) -> Cases:Cases{run(~S,~D.Integer{},Commands.Spawn{},D.Number{7}),run(~S,~D.Integer{},Commands.Spawn{},D.Number{403}),foreign(~S),run(~S,~D.Integer{},Commands.Spawn{},D.Text{"wrong"})}
type Candidate is Data:Candidate{first:Cases,second:Cases}
def main() -> Candidate:Candidate{cases(~Input.First),cases(~Input.Second)}
