import Base
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/declaration-read-v1/registered-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/declaration-read-v1/registered-v1/log.bend as Log
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/reader-domains.bend as Domains
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/system.bend as Ordinary

def World() -> Type: W.World<F.Schema,Unit,Log.Log<P.Payload>,U32>
def Registry() -> Type: Sys.Registry<F.Schema,Unit,Log.Log<P.Payload>,U32,Ev.Input<U32,F.Request>,F.ReadError,F.View,F.read_runner>
type Registration is Type: Registration{reader:Ev.Reader<F.Schema>,registry:Registry()}
def Owner() -> Type: Ordinary.Owner<F.Schema,Registration>
type Defined is Type:
  Defined{runtime:Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32>,owner:Owner()}
  DefineRefused{runtime:Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32>}
def defined(slot:String,result:Ev.Registered<F.Schema,Unit,Log.Log<P.Payload>,U32,F.Request,F.ReadError,F.View,F.read_runner>) -> Defined:
  match result:
    case Ev.RegisterFailed{runtime}: DefineRefused{runtime}
    case Ev.Registered{runtime,reader,registry}: Defined{runtime,Ordinary.Owner{Registration{reader,registry},slot,Query.clauses(~F.Schema,~P.Payload,~Cap.Request<P.Payload,U32,U32>,F.read_declaration())}}
def define(runtime:Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32>,name:String,slot:String) -> Defined:
  defined(slot,Ev.register(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,~F.Request,~F.ReadError,~F.View,~F.read_runner,runtime,name,F.read_access()))
type Returned is Type: Returned{events:Domains.Events<F.Schema,U32>,dispatch:Ordinary.ScheduleDispatch<F.Schema,World(),Registration,F.Request,F.ReadError,F.View>}
def detached(owner:Owner(),completion:Ev.Completion<F.ReadError,F.View,F.Request>,returned:Domains.Detached<F.Schema,Unit,Log.Log<P.Payload>,U32>) -> Returned:
  match completion returned:
    case Ev.Succeeded{view}, Domains.Detached{world,events}: Returned{events,Ordinary.Reached{owner,Sys.Succeeded{world,Unit{}},[view]}}
    case Ev.Failed{error}, Domains.Detached{world,events}: Returned{events,Ordinary.Reached{owner,Sys.Failed{world,error},[]}}
    case Ev.Rejected{args}, Domains.Detached{world,events}: Returned{events,Ordinary.RegistrationRefused{owner,world,args}}
def completed(slot:String,clauses:List<&2,Query.Clause<F.Schema>>,result:Ev.RunResult<F.Schema,Unit,Log.Log<P.Payload>,U32,F.Request,F.ReadError,F.View,F.read_runner>) -> Returned:
  match result:
    case Ev.Ran{runtime,reader,registry,completion}: detached(Ordinary.Owner{Registration{reader,registry},slot,clauses},completion,Domains.detach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,[]))
def run(events:Domains.Events<F.Schema,U32>,owner:Owner(),world:World(),args:F.Request) -> Returned:
  match owner:
    case Ordinary.Owner{Registration{reader,registry},slot,clauses}: completed(slot,clauses,Ev.run(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,~F.Request,~F.ReadError,~F.View,~F.read_runner,Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader,registry,args))
def skip_detached(owner:Owner(),result:Domains.Detached<F.Schema,Unit,Log.Log<P.Payload>,U32>) -> Domains.Events<F.Schema,U32> & (Owner() & World()):
  match result:
    case Domains.Detached{world,events}: (events,(owner,world))
def skipped(slot:String,clauses:List<&2,Query.Clause<F.Schema>>,registry:Registry(),result:Ev.Runtime<F.Schema,Unit,Log.Log<P.Payload>,U32> & Ev.Reader<F.Schema>) -> Domains.Events<F.Schema,U32> & (Owner() & World()):
  match result:
    case (runtime,reader): skip_detached(Ordinary.Owner{Registration{reader,registry},slot,clauses},Domains.detach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,runtime,[]))
def skip(events:Domains.Events<F.Schema,U32>,owner:Owner(),world:World()) -> Domains.Events<F.Schema,U32> & (Owner() & World()):
  match owner:
    case Ordinary.Owner{Registration{reader,registry},slot,clauses}: skipped(slot,clauses,registry,Ev.skip(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,Domains.attach(~F.Schema,~Unit,~Log.Log<P.Payload>,~U32,events,world),reader))
