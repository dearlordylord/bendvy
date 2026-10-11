import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-service-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
# Native service declaration remains operational; no query mode is fabricated.
type Owner<S:Data,C:Type,R:Type,E:Data,Payload:Type,Rest:Type,-take:R -> Rest & D.Slot<Payload>,-put:Rest -> D.Slot<Payload> -> R,-call:Payload -> Payload,-declaration:D.Declaration<S,R,Payload,Rest,take,put,call>,-scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>> is Type:
  Owner{registry:Sys.Registry<S,C,R,E,Unit,Unit,Unit,D.runner(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration)>,setup:D.Setup<S,C,R,E,scan>}
type View<S:Data> is Data:
  View{provided:List<&2,D.Status<S>>,required:List<&2,SP.Requirement<S>>}
def fields(~S:Data,~C:Type,~R:Type,~E:Data,~Payload:Type,~Rest:Type,~take:R -> Rest & D.Slot<Payload>,~put:Rest -> D.Slot<Payload> -> R,~call:Payload -> Payload,~declaration:D.Declaration<S,R,Payload,Rest,take,put,call>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,owner:Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan>) -> Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan> & List<&2,Records.Fields<S>>:
  match owner:
    case Owner{Sys.Registry{+namespace,+id,+name,+access,+cursor},setup}:(Owner{Sys.Registry{namespace,id,name,access,cursor},setup},[Records.Fields{namespace,id,name,access,cursor,D.key(~S,~R,~Payload,~Rest,~take,~put,~call,declaration),[],Records.ServiceKind{}}])
def required(~S:Data,~C:Type,~R:Type,~E:Data,~Payload:Type,~Rest:Type,~take:R -> Rest & D.Slot<Payload>,~put:Rest -> D.Slot<Payload> -> R,~call:Payload -> Payload,~declaration:D.Declaration<S,R,Payload,Rest,take,put,call>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>) -> SP.Requirement<S>:
  D.requirement(~S,~R,~Payload,~Rest,~take,~put,~call,declaration)
def provided_text(~S:Data,value:D.Status<S>) -> String:
  match value:
    case D.Status{id,key,ready}:key ++ ":" ++ U32.show(id) ++ ":" ++ Bool.show(ready)
def requirement_text(~S:Data,value:SP.Requirement<S>) -> String:
  match value:
    case SP.Service{id}:"Service:" ++ U32.show(id)
    case SP.Resource{id}:"Resource:" ++ U32.show(id)
    case SP.Component{id}:"Component:" ++ U32.show(id)
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~Payload:Type,~Rest:Type,~take:R -> Rest & D.Slot<Payload>,~put:Rest -> D.Slot<Payload> -> R,~call:Payload -> Payload,~declaration:D.Declaration<S,R,Payload,Rest,take,put,call>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,result:W.World<S,C,R,E> & List<&2,D.Status<S>>) -> W.World<S,C,R,E> & DTO.Observation<View<S>>:
  match result:
    case (world,+provided):(world,DTO.Observation{View{provided,[required(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan)]},["services=" ++ List.show(&2,D.Status<S>,provided_text(~S),provided),"requires=" ++ requirement_text(~S,required(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan))]})
def observe(~S:Data,~C:Type,~R:Type,~E:Data,~Payload:Type,~Rest:Type,~take:R -> Rest & D.Slot<Payload>,~put:Rest -> D.Slot<Payload> -> R,~call:Payload -> Payload,~declaration:D.Declaration<S,R,Payload,Rest,take,put,call>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & DTO.Observation<View<S>>:
  observed(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan,scan(world))
def dispatched(~S:Data,~C:Type,~R:Type,~E:Data,~Payload:Type,~Rest:Type,~take:R -> Rest & D.Slot<Payload>,~put:Rest -> D.Slot<Payload> -> R,~call:Payload -> Payload,~declaration:D.Declaration<S,R,Payload,Rest,take,put,call>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,setup:D.Setup<S,C,R,E,scan>,result:Sys.RunResult<S,C,R,E,Unit,Unit,Unit,D.runner(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration)>) -> Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan> & Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>:
  match result:
    case Sys.Completed{registry,outcome}:(Owner{registry,setup},outcome)
    case Sys.RegistrationRejected{registry,world,_}:(Owner{registry,setup},Sys.Failed{world,Unit{}})
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Payload:Type,~Rest:Type,~take:R -> Rest & D.Slot<Payload>,~put:Rest -> D.Slot<Payload> -> R,~call:Payload -> Payload,~declaration:D.Declaration<S,R,Payload,Rest,take,put,call>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,owner:Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan>,world:W.World<S,C,R,E>) -> Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan> & Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>:
  match owner:
    case Owner{registry,setup}:dispatched(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan,setup,Sys.run_tracked(~S,~C,~R,~E,~Unit,~Unit,~Unit,~D.runner(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration),registry,world,Unit{}))
def Application(~S:Data,~C:Type,~R:Type,~E:Data,~Payload:Type,~Rest:Type,~take:R -> Rest & D.Slot<Payload>,~put:Rest -> D.Slot<Payload> -> R,~call:Payload -> Payload,~declaration:D.Declaration<S,R,Payload,Rest,take,put,call>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>) -> Type:
  Build.Registered<S,W.World<S,C,R,E>,Owners & Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan>,DTO.Product<Rows,View<S>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan)),Leaf.fold_pair(~S,~Owners,~Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan>,~fold,~fields(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan))>
def defined(~S:Data,~C:Type,~R:Type,~E:Data,~Payload:Type,~Rest:Type,~take:R -> Rest & D.Slot<Payload>,~put:Rest -> D.Slot<Payload> -> R,~call:Payload -> Payload,~declaration:D.Declaration<S,R,Payload,Rest,take,put,call>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~Output:Type,done:Build.Registered<S,W.World<S,C,R,E>,Owners & Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan>,DTO.Product<Rows,View<S>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan)),Leaf.fold_pair(~S,~Owners,~Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan>,~fold,~fields(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan))> -> Output,failed:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold> -> Output,setup:D.Setup<S,C,R,E,scan>,owners:Owners,recipe:Tree.Recipe<W.World<S,C,R,E>,Rows,prior>,debug:Bool,result:Sys.RegistrationResult<S,C,R,E,Unit,Unit,Unit,D.runner(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration)>) -> Output:
  match result:
    case Sys.RegistrationFailed{world}:failed(Build.Registered{world,owners,recipe,debug})
    case Sys.Registered{world,registry}:done(Build.appended(~S,~W.World<S,C,R,E>,~Owners,~Rows,~prior,~fold,~Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan>,~View<S>,~observe(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan),~fields(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan),world,owners,Owner{registry,setup},debug))
def install(~S:Data,~C:Type,~R:Type,~E:Data,~Payload:Type,~Rest:Type,~take:R -> Rest & D.Slot<Payload>,~put:Rest -> D.Slot<Payload> -> R,~call:Payload -> Payload,~declaration:D.Declaration<S,R,Payload,Rest,take,put,call>,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,D.Status<S>>,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Records.Fields<S>>,~Output:Type,done:Build.Registered<S,W.World<S,C,R,E>,Owners & Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan>,DTO.Product<Rows,View<S>>,Tree.observe_pair(~W.World<S,C,R,E>,~Rows,~View<S>,~prior,~observe(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan)),Leaf.fold_pair(~S,~Owners,~Owner<S,C,R,E,Payload,Rest,take,put,call,declaration,scan>,~fold,~fields(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan))> -> Output,failed:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold> -> Output,setup:D.Setup<S,C,R,E,scan>,name:String,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,prior,fold>) -> Output:
  match app:
    case Build.Registered{world,owners,recipe,debug}:defined(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,~scan,~Owners,~Rows,~prior,~fold,~Output,done,failed,setup,owners,recipe,debug,D.define(~S,~C,~R,~E,~Payload,~Rest,~take,~put,~call,~declaration,world,name))
