import Base
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import ./request.bend as Deferred
import ./application.bend as App
import ./registered.bend as Registered
import ./public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as Local
import ./observation.bend as O
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col

type Schema is Data: Schema{}
type OtherSchema is Data: OtherSchema{}
type Outcome is Data:
  ValidationRefused{incoming:Maybe<&2,O.PayloadView>,error:D.Error}
  Replaced{original:D.Raw,previous:Maybe<&2,O.PayloadView>,handle:Maybe<&2,U32>}
  OperationRefused{original:D.Raw,incoming:Maybe<&2,O.PayloadView>,error:W.WorldError}
type Trace is Data: Trace{before:O.Snapshot,after:O.Snapshot,flushed:O.Snapshot,outcome:Outcome,canonical:Maybe<&2,D.Raw>,seedPrevious:Maybe<&2,O.PayloadView>}
type Observation is Data:
  Observed{trace:Trace}
  SetupRefused{error:W.WorldError}
  RegistrationRefused{}
  RegistrationRunRefused{incoming:O.PayloadView}
  RegisteredObserved{instance:Registered.InstanceView,result:Observation}
  SystemFailedObserved{before:O.Snapshot,after:O.Snapshot,instance:Registered.InstanceView,error:Unit}
  CreateRefused{resource:O.MailView}
  AbortObserved{before:O.Snapshot,after:O.Snapshot,output:Maybe<&2,Registered.OutputView>,packets:List<&2,O.PacketView>}
def payload(owner:Input.Owner) -> O.PayloadView:
  match owner:
    case Input.Owner{raw,sentinel}: O.PayloadView{raw,Input.sentinel(sentinel)}
def option(owner:Maybe<&1,Input.Owner>) -> Maybe<&2,O.PayloadView>:
  match owner:
    case None{}: None{}
    case Some{owner}: Some{payload(owner)}
def handle(~S:Data,value:Maybe<&2,W.Handle<S>>) -> Maybe<&2,U32>:
  match value:
    case None{}: None{}
    case Some{W.Handle{_,id}}: Some{id}
def flushed(~S:Data,before:O.Snapshot,after:O.Snapshot,outcome:Outcome,canonical:Maybe<&2,D.Raw>,seed:Maybe<&2,O.PayloadView>,result:App.World(~S) & O.Snapshot) -> Observation:
  match result:
    case (_,flushed): Observed{Trace{before,after,flushed,outcome,canonical,seed}}
def observed_after(~S:Data,before:O.Snapshot,outcome:Outcome,canonical:Maybe<&2,D.Raw>,seed:Maybe<&2,O.PayloadView>,result:App.World(~S) & O.Snapshot) -> Observation:
  match result:
    case (world,after): flushed(~S,before,after,outcome,canonical,seed,O.snapshot(~S,W.barrier(~S,~App.Store(~S),~App.Mail<S>,~Unit,world)))
def selected_handle(~S:Data,operation:App.Operation,target:W.Handle<S>) -> Maybe<&2,U32>:
  match operation target:
    case App.Resource{} _:None{}
    case _ W.Handle{_,id}:Some{id}
def operation_observed(~S:Data,before:O.Snapshot,seed:Maybe<&2,O.PayloadView>,raw:D.Raw,operation:App.Operation,world:App.World(~S),output:Deferred.Output<S,Input.Owner>) -> Observation:
  match output:
    case Deferred.Accepted{target,spawned,+canonical}:observed_after(~S,before,Replaced{raw,None{},selected_handle(~S,operation,target)},Some{canonical},seed,O.snapshot(~S,world))
    case Deferred.Refused{incoming,Deferred.Validation{error}}:observed_after(~S,before,ValidationRefused{option(incoming),error},None{},seed,O.snapshot(~S,world))
    case Deferred.Refused{incoming,Deferred.Entity{error}}:observed_after(~S,before,OperationRefused{raw,option(incoming),error},None{},seed,O.snapshot(~S,world))
def abort_observed(~S:Data,before:O.Snapshot,packets:List<&2,O.PacketView>,result:App.World(~S) & O.Snapshot) -> Observation:
  match result:
    case (world,after):AbortObserved{before,after,None{},packets}
def abort_packets(~S:Data,before:O.Snapshot,world:App.World(~S),result:List<Deferred.Packet<Input.Owner>> & List<&2,O.PacketView>) -> Observation:
  match result:
    case (owners,views):abort_observed(~S,before,views,O.snapshot(~S,world))
def aborted_complete(~S:Data,before:O.Snapshot,world:App.World(~S) & O.Snapshot,output:Deferred.Output<S,Input.Owner> & Registered.OutputView,packets:List<Deferred.Packet<Input.Owner>> & List<&2,O.PacketView>) -> Observation:
  match world output packets:
    case (world,after), (output,view), (packets,views):AbortObserved{before,after,Some{view},views}
def aborted_output(~S:Data,before:O.Snapshot,world:App.World(~S),output:Deferred.Output<S,Input.Owner>,packets:List<Deferred.Packet<Input.Owner>>) -> Observation:
  aborted_complete(~S,before,O.snapshot(~S,world),Registered.output_view(~S,output),O.packets(packets))
def admitted(~S:Data,before:O.Snapshot,seed:Maybe<&2,O.PayloadView>,raw:D.Raw,operation:App.Operation,result:App.Executed<S>) -> Observation:
  match result:
    case App.Committed{world,output}:operation_observed(~S,before,seed,raw,operation,world,output)
    case App.Aborted{world,output,packets,error}:aborted_output(~S,before,world,output,packets)
def registered_success(~S:Data,before:O.Snapshot,seed:Maybe<&2,O.PayloadView>,raw:D.Raw,op:App.Operation,world:App.World(~S),output:Deferred.Output<S,Input.Owner>,instance:Registered.Instance(~S) & Registered.InstanceView) -> Observation:
  match instance:
    case (owner,view):RegisteredObserved{view,operation_observed(~S,before,seed,raw,op,world,output)}
def registered_failure(~S:Data,before:O.Snapshot,error:Unit,world:App.World(~S) & O.Snapshot,instance:Registered.Instance(~S) & Registered.InstanceView) -> Observation:
  match world instance:
    case (owner,after), (instance,view):SystemFailedObserved{before,after,view,error}
def registration_ran(~S:Data,before:O.Snapshot,seed:Maybe<&2,O.PayloadView>,raw:D.Raw,op:App.Operation,result:Local.Run<S,App.Store(~S),App.Mail<S>,Unit,Registered.State<S>,Public.Args<S>,Unit,Deferred.Output<S,Input.Owner>,Registered.runner(~S)>) -> Observation:
  match result:
    case Local.Completed{world,instance,Done{output}}:registered_success(~S,before,seed,raw,op,world,output,Registered.instance_view(~S,instance))
    case Local.Completed{world,instance,Fail{error}}:registered_failure(~S,before,error,O.snapshot(~S,world),Registered.instance_view(~S,instance))
    case Local.Refused{world,instance,Public.Args{target,incoming}}:RegistrationRunRefused{payload(incoming)}
def registration_before(~S:Data,h:W.Handle<S>,op:App.Operation,+raw:D.Raw,seed:Maybe<&2,O.PayloadView>,instance:Registered.Instance(~S),result:App.World(~S) & O.Snapshot) -> Observation:
  match result:
    case (world,before):registration_ran(~S,before,seed,raw,op,Registered.run(~S,instance,world,Public.Args{h,Input.Owner{raw,ANode{ALeaf{111},ALeaf{222}}}}))
def provisioned(~S:Data,h:W.Handle<S>,op:App.Operation,raw:D.Raw,seed:Maybe<&2,O.PayloadView>,result:Local.Registered<S,App.Store(~S),App.Mail<S>,Unit,Registered.State<S>,Public.Args<S>,Unit,Deferred.Output<S,Input.Owner>,Registered.runner(~S)>) -> Observation:
  match result:
    case Local.Registered{world,instance}:registration_before(~S,h,op,raw,seed,instance,O.snapshot(~S,world))
    case Local.RegistrationRejected{world,state}:RegistrationRefused{}
def observed_before(~S:Data,h:W.Handle<S>,+op:App.Operation,codec:D.Codec,+raw:D.Raw,seed:Maybe<&2,O.PayloadView>,result:App.World(~S) & O.Snapshot) -> Observation:
  match result:
    case (world,before):provisioned(~S,h,op,raw,seed,Registered.define(~S,world,Public.Declaration{op,codec,T.Success{}}))
def mark(~S:Data,world:App.World(~S)) -> App.World(~S): W.event_publish(~S,~App.Store(~S),~App.Mail<S>,~Unit,world,[Unit{}])
def seeded(~S:Data,h:W.Handle<S>,op:App.Operation,codec:D.Codec,raw:D.Raw,result:C.Replacement<App.World(~S),Input.Owner>) -> Observation:
  match result:
    case C.Replaced{world,previous}: observed_before(~S,h,op,codec,raw,option(previous),O.snapshot(~S,W.enqueue(~S,~App.Store(~S),~App.Mail<S>,~Unit,mark(~S,world),mark(~S))))
    case C.ReplaceRejected{world,incoming,error}: SetupRefused{error}
def activated(~S:Data,+h:W.Handle<S>,op:App.Operation,codec:D.Codec,raw:D.Raw,result:App.World(~S) & W.Status) -> Observation:
  match result:
    case (world,W.Accepted{}): seeded(~S,h,op,codec,raw,C.replace(~S,~App.Store(~S),~App.Mail<S>,~Unit,~Unit,~Input.Owner,~D.Raw,~Unit,~App.take(~S),~App.put(~S),~Input.project,App.family(~S),world,h,Some{Input.Owner{D.Number{9},ANode{ALeaf{333},ALeaf{444}}}}))
    case (world,W.Rejected{error}): SetupRefused{error}
def reserved(~S:Data,op:App.Operation,codec:D.Codec,raw:D.Raw,result:App.World(~S) & W.Reservation<S>) -> Observation:
  match result:
    case (world,W.Reserved{+h}): activated(~S,h,op,codec,raw,W.activate(~S,~App.Store(~S),~App.Mail<S>,~Unit,world,h))
    case (world,W.ReservationRejected{error}): SetupRefused{error}
def empty(~S:Data,unit:Unit) -> App.Store(~S): Col.empty(~S,~Input.Owner)
def create_refused(~S:Data,result:App.Mail<S> & O.MailView) -> Observation:
  match result:
    case (owner,view):CreateRefused{view}
def created(~S:Data,op:App.Operation,codec:D.Codec,raw:D.Raw,result:W.Creation<S,App.Store(~S),App.Mail<S>,Unit>) -> Observation:
  match result:
    case W.Created{factory,world}: reserved(~S,op,codec,raw,W.reserve_id(~S,~App.Store(~S),~App.Mail<S>,~Unit,world))
    case W.CreateRejected{factory,resource}: create_refused(~S,O.mail(~S,resource))
def run(~S:Data,op:App.Operation,codec:D.Codec,raw:D.Raw) -> Observation:
  created(~S,op,codec,raw,W.create(~S,~App.Store(~S),~App.Mail<S>,~Unit,~empty(~S),W.factory(),App.initial(~S,Input.Owner{D.Text{"initial-resource"},ANode{ALeaf{555},ALeaf{666}}})))
type Cases is Data: Cases{array3:Observation,array128:Observation,array256:Observation,lateInvalid:Observation,struct64:Observation,nullableNull:Observation,nestedValid:Observation,nestedMissing:Observation}
def cases(~S:Data,+op:App.Operation) -> Cases:
  Cases{run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(3n,[])}),run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(128n,[])}),run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(256n,[])}),run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(127n,[D.Text{"late-invalid"}])}),run(~S,op,D.Struct{Input.codecs(64n,0)},D.Object{Input.fields(64n,0,[D.Field{"extra",D.Text{"drop-me"}}])}),run(~S,op,Input.nested_codec(),D.Object{[D.Field{"items",D.Null{}}]}),run(~S,op,Input.nested_codec(),D.Object{[D.Field{"items",D.Array{[D.Object{[D.Field{"value",D.Number{1}}]},D.Object{[D.Field{"value",D.Number{2}}]}]}}]}),run(~S,op,Input.nested_codec(),D.Object{[D.Field{"items",D.Array{[D.Object{[D.Field{"value",D.Number{1}}]},D.Object{[]}]}}]})}
type Foreign is Data: Foreign{first:O.Snapshot,result:Observation} ForeignSetupRefused{}
def foreign_ready(first:O.Snapshot,+foreign:W.Handle<Schema>,result:C.Replacement<App.World(~Schema),Input.Owner>) -> Foreign:
  match result:
    case C.Replaced{world,previous}: Foreign{first,observed_before(~Schema,foreign,App.Insert{},D.Struct{Input.codecs(64n,0)},D.Object{Input.fields(64n,0,[D.Field{"extra",D.Text{"drop-me"}}])},option(previous),O.snapshot(~Schema,W.enqueue(~Schema,~App.Store(~Schema),~App.Mail<Schema>,~Unit,mark(~Schema,world),mark(~Schema))))}
    case C.ReplaceRejected{world,incoming,error}: ForeignSetupRefused{}
def foreign_activated(first:O.Snapshot,foreign:W.Handle<Schema>,+local:W.Handle<Schema>,result:App.World(~Schema) & W.Status) -> Foreign:
  match result:
    case (world,W.Accepted{}): foreign_ready(first,foreign,C.replace(~Schema,~App.Store(~Schema),~App.Mail<Schema>,~Unit,~Unit,~Input.Owner,~D.Raw,~Unit,~App.take(~Schema),~App.put(~Schema),~Input.project,App.family(~Schema),world,local,Some{Input.Owner{D.Number{9},ANode{ALeaf{333},ALeaf{444}}}}))
    case _: ForeignSetupRefused{}
def foreign_reserved(first:O.Snapshot,foreign:W.Handle<Schema>,result:App.World(~Schema) & W.Reservation<Schema>) -> Foreign:
  match result:
    case (world,W.Reserved{+local}): foreign_activated(first,foreign,local,W.activate(~Schema,~App.Store(~Schema),~App.Mail<Schema>,~Unit,world,local))
    case _: ForeignSetupRefused{}
def second_created(first:O.Snapshot,foreign:W.Handle<Schema>,result:W.Creation<Schema,App.Store(~Schema),App.Mail<Schema>,Unit>) -> Foreign:
  match result:
    case W.Created{factory,world}: foreign_reserved(first,foreign,W.reserve_id(~Schema,~App.Store(~Schema),~App.Mail<Schema>,~Unit,world))
    case _: ForeignSetupRefused{}
def first_observed(factory:W.Factory,foreign:W.Handle<Schema>,result:App.World(~Schema) & O.Snapshot) -> Foreign:
  match result:
    case (_,first): second_created(first,foreign,W.create(~Schema,~App.Store(~Schema),~App.Mail<Schema>,~Unit,~empty(~Schema),factory,App.initial(~Schema,Input.Owner{D.Text{"second-resource"},ANode{ALeaf{555},ALeaf{666}}})))
def first_activated(factory:W.Factory,foreign:W.Handle<Schema>,result:App.World(~Schema) & W.Status) -> Foreign:
  match result:
    case (world,W.Accepted{}): first_observed(factory,foreign,O.snapshot(~Schema,world))
    case _: ForeignSetupRefused{}
def first_reserved(factory:W.Factory,result:App.World(~Schema) & W.Reservation<Schema>) -> Foreign:
  match result:
    case (world,W.Reserved{+foreign}): first_activated(factory,foreign,W.activate(~Schema,~App.Store(~Schema),~App.Mail<Schema>,~Unit,world,foreign))
    case _: ForeignSetupRefused{}
def first_created(result:W.Creation<Schema,App.Store(~Schema),App.Mail<Schema>,Unit>) -> Foreign:
  match result:
    case W.Created{factory,world}: first_reserved(factory,W.reserve_id(~Schema,~App.Store(~Schema),~App.Mail<Schema>,~Unit,world))
    case _: ForeignSetupRefused{}
def foreign_world() -> Foreign:
  first_created(W.create(~Schema,~App.Store(~Schema),~App.Mail<Schema>,~Unit,~empty(~Schema),W.factory(),App.initial(~Schema,Input.Owner{D.Text{"first-resource"},ANode{ALeaf{777},ALeaf{888}}})))
type Report is Data: Report{insert:Cases,spawn:Cases,resource:Cases,otherSchema:Cases,foreign:Foreign}
def main() -> Report: Report{cases(~Schema,App.Insert{}),cases(~Schema,App.Spawn{}),cases(~Schema,App.Resource{}),cases(~OtherSchema,App.Insert{}),foreign_world()}
