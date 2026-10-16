import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-access.bend as Access
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-capture-query-fields.bend as PriorApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-capture-query.bend as PriorOwner
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
import /workspace/formal-proofs/bendvy/src/ecs/resource-field-binding.bend as Binding
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-component.bend as RC
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-array.bend as RA
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recoverable-array-resource.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recoverable-component-capture.bend as Existing
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-component.bend as Component
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-capture.bend as Capture
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-resource-field.bend as Resource
import ./ordinary-app-recovery.bend as Bridge
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Pair
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
def Siblings() -> Type:Product.Owner<Array<Array<U32>>,Array<U32>>
def Resources() -> Type:Product.Owner<Array<Array<U32>>,Siblings()>
def Store(~S:Data) -> Type:Col.Column<S,Array<Array<U32>>>
def World(~S:Data) -> Type:W.World<S,Store(~S),Resources(),Unit>
def State(~S:Data) -> Type:Product.Owner<World(~S),Array<Array<U32>>>
def identity(~S:Data) -> Schema.Resource<S,Array<Array<U32>>>:Schema.resource(~S,~Array<Array<U32>>,"Target")
def sibling_identity(~S:Data) -> Schema.Resource<S,Array<Array<U32>>>:Schema.resource(~S,~Array<Array<U32>>,"SamePayloadSibling")
def other_identity(~S:Data) -> Schema.Resource<S,Array<U32>>:Schema.resource(~S,~Array<U32>,"OtherAffine")
def LeafIndex(~S:Data) -> Data:Binding.Built<S,Array<Array<U32>>,Schema.Resource<S,Array<Array<U32>>>>
def OtherIndex(~S:Data) -> Data:Binding.Built<S,Array<U32>,Schema.Resource<S,Array<U32>>>
def SiblingIndex(~S:Data) -> Data:Binding.Branch<LeafIndex(~S),OtherIndex(~S)>
def Index(~S:Data) -> Data:Binding.Branch<LeafIndex(~S),Binding.Built<S,Siblings(),SiblingIndex(~S)>>
def schema(~S:Data) -> Binding.Built<S,Resources(),Index(~S)>:
  Binding.joined(~S,~Array<Array<U32>>,~Siblings(),~Schema.Resource<S,Array<Array<U32>>>,~SiblingIndex(~S),Binding.leaf(~S,~Array<Array<U32>>,identity(~S)),Binding.joined(~S,~Array<Array<U32>>,~Array<U32>,~Schema.Resource<S,Array<Array<U32>>>,~Schema.Resource<S,Array<U32>>,Binding.leaf(~S,~Array<Array<U32>>,sibling_identity(~S)),Binding.leaf(~S,~Array<U32>,other_identity(~S))))
def lens() -> Product.Lens<Resources(),Array<Array<U32>>,Unit & Siblings()>:
  Binding.left_lens(~Resources(),~Array<Array<U32>>,~Siblings(),~Unit,~Binding.whole(~Resources()))
def cursor(~S:Data) -> Binding.Cursor<S,Resources(),Array<Array<U32>>,Unit & Siblings(),Schema.Resource<S,Array<Array<U32>>>,lens()>:
  Binding.left(~S,~Resources(),~Array<Array<U32>>,~Siblings(),~Unit,~Schema.Resource<S,Array<Array<U32>>>,~SiblingIndex(~S),~Binding.whole(~Resources()),Binding.root(~S,~Resources(),~Index(~S),schema(~S)))
def binding(~S:Data) -> Binding.Binding<S,Resources(),Array<Array<U32>>,Unit & Siblings(),lens(),identity(~S)>:
  Binding.bind(~S,~Resources(),~Array<Array<U32>>,~(Unit & Siblings()),~lens(),~cursor(~S))
def component_identity(~S:Data) -> Identity.Declaration<S,Array<Array<U32>>>:Identity.component(~S,~Array<Array<U32>>,"Payload")
def component_binding(~S:Data) -> B.Binding<S,Store(~S),Unit,Array<Array<U32>>,Unit,RC.Tag,RC.take(~S,~Array<Array<U32>>),RC.put(~S,~Array<Array<U32>>),RC.project(~Array<Array<U32>>)>:
  B.bind(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),component_identity(~S))
def ComponentOps(~S:Data) -> Type -> Type:Component.Ops(~S,~Array<Array<U32>>,~component_identity(~S))
def ResourceOps(~S:Data) -> Type -> Type:Resource.Ops(~S,~Array<U32>,~identity(~S))
def CaptureOps() -> Type -> Type:Capture.Ops(~Array<U32>)
def TailOps(~S:Data) -> Type -> Type:D.PairOps(~ResourceOps(~S),~CaptureOps())
def Ops(~S:Data) -> Type -> Type:D.PairOps(~ComponentOps(~S),~TailOps(~S))
def TailRecovery() -> Type:Product.Owner<List<RA.Record<Array<U32>>>,List<RA.Record<Array<U32>>>>
def Recovery(~S:Data) -> Type:Product.Owner<List<RC.Record<S,Array<Array<U32>>>>,TailRecovery()>
def component_declaration(~S:Data) -> D.Declaration<S,State(~S),List<RC.Record<S,Array<Array<U32>>>>,ComponentOps(~S),Component.grant(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S))>:Component.declaration(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S))
def resource_declaration(~S:Data) -> D.Declaration<S,State(~S),List<RA.Record<Array<U32>>>,ResourceOps(~S),Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S))>:Resource.declaration(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S),~binding(~S))
def capture_declaration(~S:Data) -> D.Declaration<S,State(~S),List<RA.Record<Array<U32>>>,CaptureOps(),Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>)>:Capture.declaration(~S,~Store(~S),~Resources(),~Unit,~Array<U32>)
def tail_declaration(~S:Data) -> D.Declaration<S,State(~S),TailRecovery(),TailOps(~S),D.pair_grant(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>))>:
  D.both(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>),~resource_declaration(~S),~capture_declaration(~S))
def declaration(~S:Data) -> D.Declaration<S,State(~S),Recovery(~S),Ops(~S),D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~TailRecovery(),~ComponentOps(~S),~TailOps(~S),~Component.grant(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>)))>:
  D.both(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~TailRecovery(),~ComponentOps(~S),~TailOps(~S),~Component.grant(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>)),~component_declaration(~S),~tail_declaration(~S))
def component_cap(~S:Data,~H:Type,~caps:Ops(~S)(H)) -> ComponentOps(~S)(H):Cap.first(~ComponentOps(~S)(H),~TailOps(~S)(H),caps)
def tail_cap(~S:Data,~H:Type,~caps:Ops(~S)(H)) -> TailOps(~S)(H):Cap.second(~ComponentOps(~S)(H),~TailOps(~S)(H),caps)
def resource_cap(~S:Data,~H:Type,~caps:Ops(~S)(H)) -> ResourceOps(~S)(H):Cap.first(~ResourceOps(~S)(H),~CaptureOps()(H),tail_cap(~S,~H,~caps))
def capture_cap(~S:Data,~H:Type,~caps:Ops(~S)(H)) -> CaptureOps()(H):Cap.second(~ResourceOps(~S)(H),~CaptureOps()(H),tail_cap(~S,~H,~caps))
type Args<S:Data> is Type:Args{target:W.Handle<S>,component:Array<Array<U32>>,resource:Array<Array<U32>>,resourceElement:Array<U32>,capture:Array<Array<U32>>,captureElement:Array<U32>,fail:Bool}
type Error is Data:Failed{}
type Output is Type:Output{components:List<Maybe<Array<Array<U32>>>>,arrays:List<Array<Array<U32>>>,elements:List<Array<U32>>,errors:List<W.WorldError>}
def outcome(fail:Bool) -> T.Outcome<Error>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Failed{}}
def capture_swapped(~H:Type,fail:Bool,result:A.Attempt<H,Array<U32>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case A.Applied{owner}:(owner,(outcome(fail),Output{[],[],[],[]}))
    case A.Refused{owner,element}:(owner,(T.Failure{Failed{}},Output{[],[],[element],[]}))
def resource_swapped(~S:Data,~H:Type,~caps:Ops(~S)(H),capture:Array<Array<U32>>,captureElement:Array<U32>,fail:Bool,result:A.Attempt<H,Array<U32>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case A.Applied{owner}:capture_swapped(~H,fail,Existing.capture_swap(~Array<U32>,~H,~capture_cap(~S,~H,~caps),Existing.capture_replace(~Array<U32>,~H,~capture_cap(~S,~H,~caps),owner,capture),1,captureElement))
    case A.Refused{owner,element}:(owner,(T.Failure{Failed{}},Output{[],[capture],[element,captureElement],[]}))
def component_replaced(~S:Data,~H:Type,~caps:Ops(~S)(H),resource:Array<Array<U32>>,resourceElement:Array<U32>,capture:Array<Array<U32>>,captureElement:Array<U32>,fail:Bool,result:Existing.ComponentAttempt<H,Array<Array<U32>>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case Existing.ComponentApplied{owner}:resource_swapped(~S,~H,~caps,capture,captureElement,fail,A.swap(~S,~Array<U32>,~identity(~S),~H,~resource_cap(~S,~H,~caps),A.replace(~S,~Array<U32>,~identity(~S),~H,~resource_cap(~S,~H,~caps),owner,resource),1,resourceElement))
    case Existing.ComponentRefused{owner,incoming,error}:(owner,(T.Failure{Failed{}},Output{[incoming],[resource,capture],[resourceElement,captureElement],[error]}))
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),args:Args<S>,owner:H) -> H & (T.Outcome<Error> & Output):
  match args:
    case Args{target,component,resource,re,capture,ce,fail}:component_replaced(~S,~H,~caps,resource,re,capture,ce,fail,Existing.component_replace(~S,~Array<Array<U32>>,~component_identity(~S),~H,~component_cap(~S,~H,~caps),owner,target,Some{component}))
def PriorOps(H:Type) -> Type:Cap.Read<H,Unit>
def prior_query(~S:Data) -> Query.Declaration<S,Q.Frame<S,Store(~S),Resources(),Unit>,PriorOps(Q.Frame<S,Store(~S),Resources(),Unit>)>:
  Query.read(~S,~Array<Array<U32>>,~Store(~S),~Resources(),~Unit,~Unit,~Unit,~RC.Tag,~component_identity(~S),~RC.project(~Array<Array<U32>>),~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>))
def prior_body(~H:Type,~caps:PriorOps(H),capture:Array<U32>,args:Unit,owner:H) -> H & (Array<U32> & (T.Outcome<Unit> & Unit)):
  (owner,(capture,(T.Success{},args)))
def PriorOwned(~S:Data) -> Type:PriorOwner.Owner<S,Store(~S),Resources(),Unit,Array<U32>,PriorOps,Unit,Unit,Unit,prior_query(~S),prior_body>
def Previous(~S:Data) -> Type:Unit & PriorOwned(~S)
def Initial(~S:Data) -> Type:Build.Registered<S,World(~S),Unit,Unit,Build.empty_observe(~World(~S)),Pair.empty(~S)>
def previous_register(~S:Data,app:Initial(~S),capture:Array<U32>) -> PriorApp.Appended<Initial(~S),Build.Registered<S,World(~S),Previous(~S),Unit,Build.empty_observe(~World(~S)),Pair.fold_pair(~S,~Unit,~PriorOwner.Owner<S,Store(~S),Resources(),Unit,Array<U32>,PriorOps,Unit,Unit,Unit,prior_query(~S),prior_body>,~Pair.empty(~S),~PriorApp.fold(~S,~Store(~S),~Resources(),~Unit,~Array<U32>,~PriorOps,~Unit,~Unit,~Unit,~prior_query(~S),~prior_body))>,Array<U32>>:
  PriorApp.register(~S,~Store(~S),~Resources(),~Unit,~Array<U32>,~PriorOps,~Unit,~Unit,~Unit,~prior_query(~S),~prior_body,~Unit,~Unit,~Build.empty_observe(~World(~S)),~Pair.empty(~S),app,"prior-readonly-capture",capture)
def Owned(~S:Data) -> Type:System.Owned(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Recovery(~S),~Ops(~S),~Args<S>,~Error,~Output,~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~TailRecovery(),~ComponentOps(~S),~TailOps(~S),~Component.grant(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>))),~declaration(~S),~body(~S))
def Before(~S:Data) -> Type:Build.Registered<S,World(~S),Previous(~S),Unit,Build.empty_observe(~World(~S)),Pair.fold_pair(~S,~Unit,~PriorOwner.Owner<S,Store(~S),Resources(),Unit,Array<U32>,PriorOps,Unit,Unit,Unit,prior_query(~S),prior_body>,~Pair.empty(~S),~PriorApp.fold(~S,~Store(~S),~Resources(),~Unit,~Array<U32>,~PriorOps,~Unit,~Unit,~Unit,~prior_query(~S),~prior_body))>
def Application(~S:Data) -> Type:Bridge.After(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Recovery(~S),~Ops(~S),~Args<S>,~Error,~Output,~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~TailRecovery(),~ComponentOps(~S),~TailOps(~S),~Component.grant(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>))),~declaration(~S),~body(~S),~Previous(~S),~Unit,~Build.empty_observe(~World(~S)),~Pair.fold_pair(~S,~Unit,~PriorOwner.Owner<S,Store(~S),Resources(),Unit,Array<U32>,PriorOps,Unit,Unit,Unit,prior_query(~S),prior_body>,~Pair.empty(~S),~PriorApp.fold(~S,~Store(~S),~Resources(),~Unit,~Array<U32>,~PriorOps,~Unit,~Unit,~Unit,~prior_query(~S),~prior_body)))
def define(~S:Data,app:Before(~S),capture:Array<Array<U32>>) -> Bridge.Appended<Before(~S),Application(~S),Array<Array<U32>>>:
  Bridge.register(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Recovery(~S),~Ops(~S),~Args<S>,~Error,~Output,~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~TailRecovery(),~ComponentOps(~S),~TailOps(~S),~Component.grant(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>))),~declaration(~S),~body(~S),~Previous(~S),~Unit,~Build.empty_observe(~World(~S)),~Pair.fold_pair(~S,~Unit,~PriorOwner.Owner<S,Store(~S),Resources(),Unit,Array<U32>,PriorOps,Unit,Unit,Unit,prior_query(~S),prior_body>,~Pair.empty(~S),~PriorApp.fold(~S,~Store(~S),~Resources(),~Unit,~Array<U32>,~PriorOps,~Unit,~Unit,~Unit,~prior_query(~S),~prior_body)),app,"recoverable-ordinary-app",capture)
def Run(~S:Data) -> Type:Bridge.Run<Before(~S),Application(~S),Args<S>,Error,Output,Recovery(~S)>
def run(~S:Data,app:Application(~S),args:Args<S>) -> Run(~S):
  Bridge.run(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Recovery(~S),~Ops(~S),~Args<S>,~Error,~Output,~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~TailRecovery(),~ComponentOps(~S),~TailOps(~S),~Component.grant(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>))),~declaration(~S),~body(~S),~Previous(~S),~Unit,~Build.empty_observe(~World(~S)),~Pair.fold_pair(~S,~Unit,~PriorOwner.Owner<S,Store(~S),Resources(),Unit,Array<U32>,PriorOps,Unit,Unit,Unit,prior_query(~S),prior_body>,~Pair.empty(~S),~PriorApp.fold(~S,~Store(~S),~Resources(),~Unit,~Array<U32>,~PriorOps,~Unit,~Unit,~Unit,~prior_query(~S),~prior_body)),app,args)
def Owners(~S:Data) -> Type:Previous(~S) & Owned(~S)
def enabled(~S:Data,app:Application(~S),flag:Bool) -> Application(~S):
  Build.enabled(~S,~World(~S),~Owners(~S),~Unit,~Build.empty_observe(~World(~S)),~Pair.fold_pair(~S,~Previous(~S),~Owned(~S),~Pair.fold_pair(~S,~Unit,~PriorOwner.Owner<S,Store(~S),Resources(),Unit,Array<U32>,PriorOps,Unit,Unit,Unit,prior_query(~S),prior_body>,~Pair.empty(~S),~PriorApp.fold(~S,~Store(~S),~Resources(),~Unit,~Array<U32>,~PriorOps,~Unit,~Unit,~Unit,~prior_query(~S),~prior_body)),~Bridge.fold(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Recovery(~S),~Ops(~S),~Args<S>,~Error,~Output,~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~TailRecovery(),~ComponentOps(~S),~TailOps(~S),~Component.grant(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>))),~declaration(~S),~body(~S))),app,flag)
def snapshot(~S:Data,app:Application(~S)) -> Application(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Unit>>>:
  Build.snapshot(~S,~World(~S),~Owners(~S),~Unit,~Build.empty_observe(~World(~S)),~Pair.fold_pair(~S,~Previous(~S),~Owned(~S),~Pair.fold_pair(~S,~Unit,~PriorOwner.Owner<S,Store(~S),Resources(),Unit,Array<U32>,PriorOps,Unit,Unit,Unit,prior_query(~S),prior_body>,~Pair.empty(~S),~PriorApp.fold(~S,~Store(~S),~Resources(),~Unit,~Array<U32>,~PriorOps,~Unit,~Unit,~Unit,~prior_query(~S),~prior_body)),~Bridge.fold(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Recovery(~S),~Ops(~S),~Args<S>,~Error,~Output,~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~TailRecovery(),~ComponentOps(~S),~TailOps(~S),~Component.grant(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>))),~declaration(~S),~body(~S))),app)
def access_index(~S:Data,app:Application(~S)) -> Application(~S) & Maybe<&2,List<&2,Access.Entry>>:
  Access.index(~S,~World(~S),~Owners(~S),~Unit,~Build.empty_observe(~World(~S)),~Pair.fold_pair(~S,~Previous(~S),~Owned(~S),~Pair.fold_pair(~S,~Unit,~PriorOwner.Owner<S,Store(~S),Resources(),Unit,Array<U32>,PriorOps,Unit,Unit,Unit,prior_query(~S),prior_body>,~Pair.empty(~S),~PriorApp.fold(~S,~Store(~S),~Resources(),~Unit,~Array<U32>,~PriorOps,~Unit,~Unit,~Unit,~prior_query(~S),~prior_body)),~Bridge.fold(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Recovery(~S),~Ops(~S),~Args<S>,~Error,~Output,~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~TailRecovery(),~ComponentOps(~S),~TailOps(~S),~Component.grant(~S,~Store(~S),~Resources(),~Unit,~Array<Array<U32>>,~Unit,~Array<Array<U32>>,~Unit,~RC.Tag,~RC.take(~S,~Array<Array<U32>>),~RC.put(~S,~Array<Array<U32>>),~RC.project(~Array<Array<U32>>),~component_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RA.Record<Array<U32>>>,~List<RA.Record<Array<U32>>>,~ResourceOps(~S),~CaptureOps(),~Resource.grant(~S,~Store(~S),~Unit,~Array<Array<U32>>,~Resources(),~Array<U32>,~(Unit & Siblings()),~lens(),~identity(~S)),~Capture.grant(~S,~Store(~S),~Resources(),~Unit,~Array<U32>))),~declaration(~S),~body(~S))),app)
def pair(+value:U32) -> Array<U32>:ANode{ALeaf{value},ALeaf{(value + 1 : U32)}}
def array(+value:U32) -> Array<Array<U32>>:ANode{ALeaf{pair(value)},ALeaf{pair((value + 2 : U32))}}
def resources(seed:U32) -> Resources():Product.Owner{array(seed),Product.Owner{array(800),pair(900)}}
def args(~S:Data,target:W.Handle<S>,+seed:U32,fail:Bool) -> Args<S>:
  Args{target,array(seed),array((seed + 20 : U32)),pair((seed + 30 : U32)),array((seed + 40 : U32)),pair((seed + 50 : U32)),fail}
