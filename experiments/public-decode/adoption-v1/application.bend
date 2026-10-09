import Base
import admission.bend as Gate
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-component-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C

def Store(~S:Data) -> Type: Col.Column<S,Input.Owner>
def World(~S:Data) -> Type: W.World<S,Store(~S),Input.Owner,Unit>
def identity(~S:Data) -> Identity.Declaration<S,Input.Owner>: Identity.component(~S,~Input.Owner,"decoded-value")
def resource_identity(~S:Data) -> Identity.Declaration<S,Input.Owner>: Identity.component(~S,~Input.Owner,"decoded-resource")
def take(~S:Data,column:Store(~S)) -> Unit & Col.Column<S,Input.Owner>: (Unit{},column)
def put(~S:Data,rest:Unit,column:Col.Column<S,Input.Owner>) -> Store(~S): column
def family(~S:Data) -> C.Family<S,Store(~S),Unit,Input.Owner,D.Raw,Unit,take(~S),put(~S),Input.project>:
  C.define(~S,~Store(~S),~Input.Owner,~Unit,~Unit,~Input.Owner,~D.Raw,~Unit,~take(~S),~put(~S),~Input.project,"decoded-value")
type Operation is Data: Insert{} Resource{} Spawn{}
type Output<-S:Data> is Type:
  Replaced{original:D.Raw,previous:Maybe<&1,Input.Owner>,handle:Maybe<&2,W.Handle<S>>}
  OperationRefused{original:D.Raw,incoming:Maybe<&1,Input.Owner>,error:W.WorldError}
def replacement(~S:Data,+original:D.Raw,handle:Maybe<&2,W.Handle<S>>,result:C.Replacement<World(~S),Input.Owner>) -> World(~S) & Output<S>:
  match result:
    case C.Replaced{world,previous}: (world,Replaced{original,previous,handle})
    case C.ReplaceRejected{world,incoming,error}: (world,OperationRefused{original,incoming,error})
# This witness explicitly constructs its concrete description-owning payload
# from canonical Raw while retaining the original affine sentinel.
def normalized(owner:Input.Owner,canonical:D.Raw) -> Input.Owner & D.Raw:
  match owner:
    case Input.Owner{raw,sentinel}: (Input.Owner{canonical,sentinel},raw)
def insert_normalized(~S:Data,world:World(~S),+handle:W.Handle<S>,result:Input.Owner & D.Raw) -> World(~S) & Output<S>:
  match result:
    case (owner,original): replacement(~S,original,Some{handle},C.replace(~S,~Store(~S),~Input.Owner,~Unit,~Unit,~Input.Owner,~D.Raw,~Unit,~take(~S),~put(~S),~Input.project,family(~S),world,handle,Some{owner}))
def insert(~S:Data,handle:W.Handle<S>,world:World(~S),owner:Input.Owner,canonical:D.Raw) -> World(~S) & Output<S>:
  insert_normalized(~S,world,handle,normalized(owner,canonical))
def resource_replaced(~S:Data,original:D.Raw,result:World(~S) & Input.Owner) -> World(~S) & Output<S>:
  match result:
    case (world,previous): (world,Replaced{original,Some{previous},None{}})
def resource_normalized(~S:Data,world:World(~S),result:Input.Owner & D.Raw) -> World(~S) & Output<S>:
  match result:
    case (owner,original): resource_replaced(~S,original,W.replace_resource(~S,~Store(~S),~Input.Owner,~Unit,world,owner))
def resource(~S:Data,world:World(~S),owner:Input.Owner,canonical:D.Raw) -> World(~S) & Output<S>:
  resource_normalized(~S,world,normalized(owner,canonical))
def refused_owner(~S:Data,world:World(~S),error:W.WorldError,owner:Input.Owner) -> World(~S) & Output<S>:
  match owner:
    case Input.Owner{+original,sentinel}: (world,OperationRefused{original,Some{Input.Owner{original,sentinel}},error})
def activated(~S:Data,handle:W.Handle<S>,owner:Input.Owner,canonical:D.Raw,result:World(~S) & W.Status) -> World(~S) & Output<S>:
  match result:
    case (world,W.Accepted{}): insert(~S,handle,world,owner,canonical)
    case (world,W.Rejected{error}): refused_owner(~S,world,error,owner)
def reserved(~S:Data,owner:Input.Owner,canonical:D.Raw,result:World(~S) & W.Reservation<S>) -> World(~S) & Output<S>:
  match result:
    case (world,W.Reserved{+handle}): activated(~S,handle,owner,canonical,W.activate(~S,~Store(~S),~Input.Owner,~Unit,world,handle))
    case (world,W.ReservationRejected{error}): refused_owner(~S,world,error,owner)
def spawn(~S:Data,world:World(~S),owner:Input.Owner,canonical:D.Raw) -> World(~S) & Output<S>:
  reserved(~S,owner,canonical,W.reserve_id(~S,~Store(~S),~Input.Owner,~Unit,world))
def context_done(~S:Data,h:W.Handle<S>,result:World(~S) & Output<S>) -> (World(~S) & W.Handle<S>) & Output<S>:
  match result:
    case (world,out): ((world,h),out)
def insert_context(~S:Data,context:World(~S) & W.Handle<S>,owner:Input.Owner,canonical:D.Raw) -> (World(~S) & W.Handle<S>) & Output<S>:
  match context:
    case (world,+h): context_done(~S,h,insert(~S,h,world,owner,canonical))
def resource_context(~S:Data,context:World(~S) & W.Handle<S>,owner:Input.Owner,canonical:D.Raw) -> (World(~S) & W.Handle<S>) & Output<S>:
  match context:
    case (world,h): context_done(~S,h,resource(~S,world,owner,canonical))
def spawn_context(~S:Data,context:World(~S) & W.Handle<S>,owner:Input.Owner,canonical:D.Raw) -> (World(~S) & W.Handle<S>) & Output<S>:
  match context:
    case (world,h): context_done(~S,h,spawn(~S,world,owner,canonical))
def request(~S:Data,h:W.Handle<S>,op:Operation,codec:D.Codec,world:World(~S),owner:Input.Owner) -> Gate.Returned<(World(~S) & W.Handle<S>),Input.Owner,Output<S>>:
  match op:
    case Insert{}: Gate.request(~S,~(World(~S) & W.Handle<S>),~Input.Owner,~Output<S>,~identity(~S),~Input.project,~insert_context(~S),Decl.constructed(~S,~Input.Owner,~identity(~S),~Input.project,codec),(world,h),owner)
    case Resource{}: Gate.request(~S,~(World(~S) & W.Handle<S>),~Input.Owner,~Output<S>,~resource_identity(~S),~Input.project,~resource_context(~S),Decl.constructed(~S,~Input.Owner,~resource_identity(~S),~Input.project,codec),(world,h),owner)
    case Spawn{}: Gate.request(~S,~(World(~S) & W.Handle<S>),~Input.Owner,~Output<S>,~identity(~S),~Input.project,~spawn_context(~S),Decl.constructed(~S,~Input.Owner,~identity(~S),~Input.project,codec),(world,h),owner)
