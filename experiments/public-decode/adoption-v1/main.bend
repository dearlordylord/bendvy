import Base
import admission.bend as Gate
import application.bend as App
import observation.bend as O
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col

type Schema is Data: Schema{}
type OtherSchema is Data: OtherSchema{}
type Outcome is Data:
  ValidationRefused{incoming:O.PayloadView,error:D.Error}
  Replaced{original:D.Raw,previous:Maybe<&2,O.PayloadView>,handle:Maybe<&2,U32>}
  OperationRefused{original:D.Raw,incoming:Maybe<&2,O.PayloadView>,error:W.WorldError}
type Trace is Data: Trace{before:O.Snapshot,after:O.Snapshot,flushed:O.Snapshot,outcome:Outcome,canonical:Maybe<&2,D.Raw>,seedPrevious:Maybe<&2,O.PayloadView>}
type Observation is Data:
  Observed{trace:Trace}
  SetupRefused{error:W.WorldError}
  CreateRefused{resource:O.PayloadView}
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
def output(~S:Data,value:App.Output<S>) -> Outcome:
  match value:
    case App.Replaced{original,previous,h}: Replaced{original,option(previous),handle(~S,h)}
    case App.OperationRefused{original,incoming,error}: OperationRefused{original,option(incoming),error}
def flushed(~S:Data,before:O.Snapshot,after:O.Snapshot,outcome:Outcome,canonical:Maybe<&2,D.Raw>,seed:Maybe<&2,O.PayloadView>,result:App.World(~S) & O.Snapshot) -> Observation:
  match result:
    case (_,flushed): Observed{Trace{before,after,flushed,outcome,canonical,seed}}
def observed_after(~S:Data,before:O.Snapshot,outcome:Outcome,canonical:Maybe<&2,D.Raw>,seed:Maybe<&2,O.PayloadView>,result:App.World(~S) & O.Snapshot) -> Observation:
  match result:
    case (world,after): flushed(~S,before,after,outcome,canonical,seed,O.snapshot(~S,W.barrier(~S,~App.Store(~S),~Input.Owner,~Unit,world)))
def admitted(~S:Data,before:O.Snapshot,seed:Maybe<&2,O.PayloadView>,result:Gate.Returned<(App.World(~S) & W.Handle<S>),Input.Owner,App.Output<S>>) -> Observation:
  match result:
    case Gate.ValidationRefused{(world,_),owner,error}: observed_after(~S,before,ValidationRefused{payload(owner),error},None{},seed,O.snapshot(~S,world))
    case Gate.Admitted{(world,_),value,canonical}: observed_after(~S,before,output(~S,value),Some{canonical},seed,O.snapshot(~S,world))
def observed_before(~S:Data,h:W.Handle<S>,op:App.Operation,codec:D.Codec,raw:D.Raw,seed:Maybe<&2,O.PayloadView>,result:App.World(~S) & O.Snapshot) -> Observation:
  match result:
    case (world,before): admitted(~S,before,seed,App.request(~S,h,op,codec,world,Input.Owner{raw,ANode{ALeaf{111},ALeaf{222}}}))
def mark(~S:Data,world:App.World(~S)) -> App.World(~S): W.event_publish(~S,~App.Store(~S),~Input.Owner,~Unit,world,[Unit{}])
def seeded(~S:Data,h:W.Handle<S>,op:App.Operation,codec:D.Codec,raw:D.Raw,result:C.Replacement<App.World(~S),Input.Owner>) -> Observation:
  match result:
    case C.Replaced{world,previous}: observed_before(~S,h,op,codec,raw,option(previous),O.snapshot(~S,W.enqueue(~S,~App.Store(~S),~Input.Owner,~Unit,mark(~S,world),mark(~S))))
    case C.ReplaceRejected{world,incoming,error}: SetupRefused{error}
def activated(~S:Data,+h:W.Handle<S>,op:App.Operation,codec:D.Codec,raw:D.Raw,result:App.World(~S) & W.Status) -> Observation:
  match result:
    case (world,W.Accepted{}): seeded(~S,h,op,codec,raw,C.replace(~S,~App.Store(~S),~Input.Owner,~Unit,~Unit,~Input.Owner,~D.Raw,~Unit,~App.take(~S),~App.put(~S),~Input.project,App.family(~S),world,h,Some{Input.Owner{D.Number{9},ANode{ALeaf{333},ALeaf{444}}}}))
    case (world,W.Rejected{error}): SetupRefused{error}
def reserved(~S:Data,op:App.Operation,codec:D.Codec,raw:D.Raw,result:App.World(~S) & W.Reservation<S>) -> Observation:
  match result:
    case (world,W.Reserved{+h}): activated(~S,h,op,codec,raw,W.activate(~S,~App.Store(~S),~Input.Owner,~Unit,world,h))
    case (world,W.ReservationRejected{error}): SetupRefused{error}
def empty(~S:Data,unit:Unit) -> App.Store(~S): Col.empty(~S,~Input.Owner)
def created(~S:Data,op:App.Operation,codec:D.Codec,raw:D.Raw,result:W.Creation<S,App.Store(~S),Input.Owner,Unit>) -> Observation:
  match result:
    case W.Created{factory,world}: reserved(~S,op,codec,raw,W.reserve_id(~S,~App.Store(~S),~Input.Owner,~Unit,world))
    case W.CreateRejected{factory,resource}: CreateRefused{payload(resource)}
def run(~S:Data,op:App.Operation,codec:D.Codec,raw:D.Raw) -> Observation:
  created(~S,op,codec,raw,W.create(~S,~App.Store(~S),~Input.Owner,~Unit,~empty(~S),W.factory(),Input.Owner{D.Text{"initial-resource"},ANode{ALeaf{555},ALeaf{666}}}))
type Cases is Data: Cases{array3:Observation,array128:Observation,array256:Observation,lateInvalid:Observation,struct64:Observation,nullableNull:Observation,nestedValid:Observation,nestedMissing:Observation}
def cases(~S:Data,+op:App.Operation) -> Cases:
  Cases{run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(3n,[])}),run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(128n,[])}),run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(256n,[])}),run(~S,op,D.ArrayValue{D.Integer{}},D.Array{Input.items(127n,[D.Text{"late-invalid"}])}),run(~S,op,D.Struct{Input.codecs(64n,0)},D.Object{Input.fields(64n,0,[D.Field{"extra",D.Text{"drop-me"}}])}),run(~S,op,Input.nested_codec(),D.Object{[D.Field{"items",D.Null{}}]}),run(~S,op,Input.nested_codec(),D.Object{[D.Field{"items",D.Array{[D.Object{[D.Field{"value",D.Number{1}}]},D.Object{[D.Field{"value",D.Number{2}}]}]}}]}),run(~S,op,Input.nested_codec(),D.Object{[D.Field{"items",D.Array{[D.Object{[D.Field{"value",D.Number{1}}]},D.Object{[]}]}}]})}
type Foreign is Data: Foreign{first:O.Snapshot,result:Observation} ForeignSetupRefused{}
def foreign_ready(first:O.Snapshot,+foreign:W.Handle<Schema>,result:C.Replacement<App.World(~Schema),Input.Owner>) -> Foreign:
  match result:
    case C.Replaced{world,previous}: Foreign{first,observed_before(~Schema,foreign,App.Insert{},D.ArrayValue{D.Integer{}},D.Array{Input.items(3n,[])},option(previous),O.snapshot(~Schema,W.enqueue(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,mark(~Schema,world),mark(~Schema))))}
    case C.ReplaceRejected{world,incoming,error}: ForeignSetupRefused{}
def foreign_activated(first:O.Snapshot,foreign:W.Handle<Schema>,+local:W.Handle<Schema>,result:App.World(~Schema) & W.Status) -> Foreign:
  match result:
    case (world,W.Accepted{}): foreign_ready(first,foreign,C.replace(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,~Unit,~Input.Owner,~D.Raw,~Unit,~App.take(~Schema),~App.put(~Schema),~Input.project,App.family(~Schema),world,local,Some{Input.Owner{D.Number{9},ANode{ALeaf{333},ALeaf{444}}}}))
    case _: ForeignSetupRefused{}
def foreign_reserved(first:O.Snapshot,foreign:W.Handle<Schema>,result:App.World(~Schema) & W.Reservation<Schema>) -> Foreign:
  match result:
    case (world,W.Reserved{+local}): foreign_activated(first,foreign,local,W.activate(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,world,local))
    case _: ForeignSetupRefused{}
def second_created(first:O.Snapshot,foreign:W.Handle<Schema>,result:W.Creation<Schema,App.Store(~Schema),Input.Owner,Unit>) -> Foreign:
  match result:
    case W.Created{factory,world}: foreign_reserved(first,foreign,W.reserve_id(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,world))
    case _: ForeignSetupRefused{}
def first_observed(factory:W.Factory,foreign:W.Handle<Schema>,result:App.World(~Schema) & O.Snapshot) -> Foreign:
  match result:
    case (_,first): second_created(first,foreign,W.create(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,~empty(~Schema),factory,Input.Owner{D.Text{"second-resource"},ANode{ALeaf{555},ALeaf{666}}}))
def first_activated(factory:W.Factory,foreign:W.Handle<Schema>,result:App.World(~Schema) & W.Status) -> Foreign:
  match result:
    case (world,W.Accepted{}): first_observed(factory,foreign,O.snapshot(~Schema,world))
    case _: ForeignSetupRefused{}
def first_reserved(factory:W.Factory,result:App.World(~Schema) & W.Reservation<Schema>) -> Foreign:
  match result:
    case (world,W.Reserved{+foreign}): first_activated(factory,foreign,W.activate(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,world,foreign))
    case _: ForeignSetupRefused{}
def first_created(result:W.Creation<Schema,App.Store(~Schema),Input.Owner,Unit>) -> Foreign:
  match result:
    case W.Created{factory,world}: first_reserved(factory,W.reserve_id(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,world))
    case _: ForeignSetupRefused{}
def foreign_world() -> Foreign:
  first_created(W.create(~Schema,~App.Store(~Schema),~Input.Owner,~Unit,~empty(~Schema),W.factory(),Input.Owner{D.Text{"first-resource"},ANode{ALeaf{777},ALeaf{888}}}))
type Report is Data: Report{insert:Cases,spawn:Cases,resource:Cases,otherSchema:Cases,foreign:Foreign}
def main() -> Report: Report{cases(~Schema,App.Insert{}),cases(~Schema,App.Spawn{}),cases(~Schema,App.Resource{}),cases(~OtherSchema,App.Insert{}),foreign_world()}
