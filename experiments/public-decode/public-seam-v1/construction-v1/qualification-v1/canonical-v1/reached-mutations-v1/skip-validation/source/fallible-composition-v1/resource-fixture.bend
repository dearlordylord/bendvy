import ./business.bend as Business
import Base
import ../fixture.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/skip-validation/core/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/skip-validation/core/decode-validated-resource.bend as Resource
import /workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/canonical-v1/reached-mutations-v1/skip-validation/core/decode-fallible-constructed-resource.bend as Constructed
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/decode-frame.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/decode-local.bend as Completion
import /workspace/formal-proofs/bendvy/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/bundle-batch.bend as Batch
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T

def Frame(~S:Data) -> Type:F.Frame<S,Unit,Input.Owner,Unit,Input.Owner,Unit,Input.identity(~S),Input.project>
def factory(~S:Data) -> Constructor.FallibleFactory<S,Input.Input,Input.Owner,Business.Error,Input.resource_identity(~S),Input.project,Input.incoming,Business.build>:
  Constructor.fallible_factory(~S,~Input.Input,~Input.Owner,~Business.Error,~Input.resource_identity(~S),~Input.project,~Input.incoming,~Business.build,Decl.constructed(~S,~Input.Owner,~Input.resource_identity(~S),~Input.project,D.Integer{}))
def lower(~S:Data) -> Cap.OwnedRequest<Frame(~S),Input.Owner,Resource.Output<Input.Owner>>:
  Resource.grant(~S,~Unit,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,~Input.resource_identity(~S),~Input.project,~Decl.constructed(~S,~Input.Owner,~Input.resource_identity(~S),~Input.project,D.Integer{}))
def grants(~S:Data) -> Cap.OwnedRequest<Frame(~S),Input.Input,Constructed.Output<Input.Input,Input.Owner,Business.Error>>:
  Constructed.grant(~S,~Input.Input,~Input.Owner,~Business.Error,~Input.resource_identity(~S),~Input.project,~Input.incoming,~Business.build,~factory(~S),~Frame(~S),~lower(~S))
def body(~H:Type,~cap:Cap.OwnedRequest<H,Input.Input,Constructed.Output<Input.Input,Input.Owner,Business.Error>>,input:Input.Input,ctx:H) -> H & Constructed.Output<Input.Input,Input.Owner,Business.Error>:
  Cap.owned_request(~H,~Input.Input,~Constructed.Output<Input.Input,Input.Owner,Business.Error>,~cap,ctx,input)
type ResultView is Data:Replaced{canonical:D.Raw,undoAvailable:Bool} Refused{owner:Input.InputView,error:Constructed.Error<Business.Error>}
def refused(error:Constructed.Error<Business.Error>,input:Input.Input & Input.InputView) -> ResultView:
  match input:
    case (_,view):Refused{view,error}
def result(value:Constructed.Output<Input.Input,Input.Owner,Business.Error>) -> ResultView:
  match value:
    case Constructed.Replaced{canonical,undo}:Replaced{canonical,True{}}
    case Constructed.Refused{owner,error}:refused(error,Input.input_view(owner))
type Report is Data:Report{before:Input.Snapshot,after:Input.Snapshot,result:ResultView,completion:T.Outcome<Unit>} CreateRefused{}
def report(~S:Data,before:Input.Snapshot,result:ResultView,completion:T.Outcome<Unit>,value:W.World<S,Unit,Input.Owner,Unit> & Input.Snapshot) -> Report:
  match value:
    case (_,after):Report{before,after,result,completion}
def completed(~S:Data,before:Input.Snapshot,result:ResultView,value:T.Returned<W.World<S,Unit,Input.Owner,Unit>,Unit>) -> Report:
  match value:
    case T.Returned{world,outcome}:report(~S,before,result,outcome,Input.snapshot(~S,world))
def invoked(~S:Data,before:Input.Snapshot,fail:Bool,value:Frame(~S) & Constructed.Output<Input.Input,Input.Owner,Business.Error>) -> Report:
  match value:
    case (F.Frame{Request.Owner{Batch.Batch{tx,[]},_},_,_,_,[],[]},output):completed(~S,before,result(output),Commands.tx_finish(~S,~Unit,~Input.Owner,~Unit,~Unit,tx,Input.outcome(fail)))
    case (_,output):CreateRefused{}
def observed(~S:Data,input:Input.Input,fail:Bool,value:W.World<S,Unit,Input.Owner,Unit> & Input.Snapshot) -> Report:
  match value:
    case (world,before):invoked(~S,before,fail,Cap.invoke_owned(~(H => Cap.OwnedRequest<H,Input.Input,Constructed.Output<Input.Input,Input.Owner,Business.Error>>),~Input.Input,~Constructed.Output<Input.Input,Input.Owner,Business.Error>,~(H => cap => input => ctx => body(~H,~cap,input,ctx)),~Frame(~S),~grants(~S),input,Completion.begin_frame(~S,~Unit,~Input.Owner,~Unit,~Input.Owner,~Unit,~Input.identity(~S),~Input.project,world,Decl.constructed(~S,~Input.Owner,~Input.identity(~S),~Input.project,D.Integer{}))))
def created(~S:Data,raw:D.Raw,fail:Bool,value:W.Creation<S,Unit,Input.Owner,Unit>) -> Report:
  match value:
    case W.CreateRejected{_,_}:CreateRefused{}
    case W.Created{_,world}:observed(~S,Input.input(raw),fail,Input.snapshot(~S,world))
def run(~S:Data,raw:D.Raw,fail:Bool) -> Report:created(~S,raw,fail,W.create(~S,~Unit,~Input.Owner,~Unit,~(u => Unit{}),W.factory(),Input.owned(D.Number{100})))
type Cases is Data:Cases{success:Report,denied:Report,refused:Report,abort:Report}
def cases(~S:Data) -> Cases:Cases{run(~S,D.Number{7},False{}),run(~S,D.Number{403},False{}),run(~S,D.Text{"wrong"},False{}),run(~S,D.Number{7},True{})}
type Candidate is Data:Candidate{first:Cases,second:Cases}
def main() -> Candidate:Candidate{cases(~Input.First),cases(~Input.Second)}
