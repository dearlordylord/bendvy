import Base
import ./schema.bend as Schema
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/ordinary-recovery-declaration.bend as D
import ../../../src/ecs/ordinary-recovery-system.bend as System
import ../../../src/ecs/ordinary-recovery-component.bend as Component
import ../../../src/ecs/ordinary-recovery-capture.bend as Capture
import ../../../src/ecs/ordinary-recoverable-component-capture.bend as Existing
import ../../../src/ecs/ordinary-recoverable-array-resource.bend as ArrayEntry
import ../../../src/ecs/recoverable-component.bend as RC
import ../../../src/ecs/recoverable-array.bend as RA
import ../../../src/ecs/transaction.bend as T
def World(~S:Data) -> Type:W.World<S,Schema.Store(~S),Unit,Unit>
def State(~S:Data) -> Type:Product.Owner<W.World<S,Schema.Store(~S),Unit,Unit>,Array<Array<U32>>>
def FirstOps(~S:Data) -> Type -> Type:Component.Ops(~S,~Array<Array<U32>>,~Schema.first_identity(~S))
def SecondOps(~S:Data) -> Type -> Type:Component.Ops(~S,~Array<U32>,~Schema.second_identity(~S))
def CaptureOps() -> Type -> Type:Capture.Ops(~Array<U32>)
def TailOps(~S:Data) -> Type -> Type:D.PairOps(~SecondOps(~S),~CaptureOps())
def Ops(~S:Data) -> Type -> Type:D.PairOps(~FirstOps(~S),~TailOps(~S))
def Recovery(~S:Data) -> Type:Product.Owner<List<RC.Record<S,Array<Array<U32>>>>,Product.Owner<List<RC.Record<S,Array<U32>>>,List<RA.Record<Array<U32>>>>>
def first_declaration(~S:Data) -> D.Declaration<S,State(~S),List<RC.Record<S,Array<Array<U32>>>>,FirstOps(~S),Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<U32>>,~Array<Array<U32>>,~Unit,~Schema.FirstToken,~Schema.first_take(~S),~Schema.first_put(~S),~Schema.first_view,~Schema.first_binding(~S))>:Component.declaration(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<U32>>,~Array<Array<U32>>,~Unit,~Schema.FirstToken,~Schema.first_take(~S),~Schema.first_put(~S),~Schema.first_view,~Schema.first_binding(~S))
def second_declaration(~S:Data) -> D.Declaration<S,State(~S),List<RC.Record<S,Array<U32>>>,SecondOps(~S),Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,~Schema.second_binding(~S))>:Component.declaration(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,~Schema.second_binding(~S))
def capture_declaration(~S:Data) -> D.Declaration<S,State(~S),List<RA.Record<Array<U32>>>,CaptureOps(),Capture.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<U32>)>:Capture.declaration(~S,~Schema.Store(~S),~Unit,~Unit,~Array<U32>)
def tail_declaration(~S:Data) -> D.Declaration<S,State(~S),Product.Owner<List<RC.Record<S,Array<U32>>>,List<RA.Record<Array<U32>>>>,TailOps(~S),D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<U32>>>,~List<RA.Record<Array<U32>>>,~SecondOps(~S),~CaptureOps(),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,~Schema.second_binding(~S)),~Capture.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<U32>))>:D.both(~S,~State(~S),~List<RC.Record<S,Array<U32>>>,~List<RA.Record<Array<U32>>>,~SecondOps(~S),~CaptureOps(),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,~Schema.second_binding(~S)),~Capture.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<U32>),~second_declaration(~S),~capture_declaration(~S))
def declaration(~S:Data) -> D.Declaration<S,State(~S),Recovery(~S),Ops(~S),D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~Product.Owner<List<RC.Record<S,Array<U32>>>,List<RA.Record<Array<U32>>>>,~FirstOps(~S),~TailOps(~S),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<U32>>,~Array<Array<U32>>,~Unit,~Schema.FirstToken,~Schema.first_take(~S),~Schema.first_put(~S),~Schema.first_view,~Schema.first_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<U32>>>,~List<RA.Record<Array<U32>>>,~SecondOps(~S),~CaptureOps(),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,~Schema.second_binding(~S)),~Capture.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<U32>)))>:D.both(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~Product.Owner<List<RC.Record<S,Array<U32>>>,List<RA.Record<Array<U32>>>>,~FirstOps(~S),~TailOps(~S),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<U32>>,~Array<Array<U32>>,~Unit,~Schema.FirstToken,~Schema.first_take(~S),~Schema.first_put(~S),~Schema.first_view,~Schema.first_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<U32>>>,~List<RA.Record<Array<U32>>>,~SecondOps(~S),~CaptureOps(),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,~Schema.second_binding(~S)),~Capture.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<U32>)),~first_declaration(~S),~tail_declaration(~S))
def first_cap(~S:Data,~H:Type,~caps:Ops(~S)(H)) -> FirstOps(~S)(H):Cap.first(~FirstOps(~S)(H),~TailOps(~S)(H),caps)
def tail_cap(~S:Data,~H:Type,~caps:Ops(~S)(H)) -> TailOps(~S)(H):Cap.second(~FirstOps(~S)(H),~TailOps(~S)(H),caps)
def second_cap(~S:Data,~H:Type,~caps:Ops(~S)(H)) -> SecondOps(~S)(H):Cap.first(~SecondOps(~S)(H),~CaptureOps()(H),tail_cap(~S,~H,~caps))
def capture_cap(~S:Data,~H:Type,~caps:Ops(~S)(H)) -> CaptureOps()(H):Cap.second(~SecondOps(~S)(H),~CaptureOps()(H),tail_cap(~S,~H,~caps))
type Args<S:Data> is Type:Args{target:W.Handle<S>,a:Array<Array<U32>>,b:Array<U32>,a2:Array<Array<U32>>,b2:Array<U32>,capture:Array<Array<U32>>,element:Array<U32>,fail:Bool}
type Error is Data:Failed{}
type Output is Type:Output{first:List<Maybe<Array<Array<U32>>>>,second:List<Maybe<Array<U32>>>,arrays:List<Array<Array<U32>>>,elements:List<Array<U32>>,errors:List<W.WorldError>}
def outcome(fail:Bool) -> T.Outcome<Error>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Failed{}}
def final_swap(~H:Type,fail:Bool,result:ArrayEntry.Attempt<H,Array<U32>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case ArrayEntry.Applied{owner}:(owner,(outcome(fail),Output{[],[],[],[],[]}))
    case ArrayEntry.Refused{owner,element}:(owner,(T.Failure{Failed{}},Output{[],[],[],[element],[]}))
def fourth(~S:Data,~H:Type,~caps:Ops(~S)(H),element:Array<U32>,fail:Bool,result:Existing.ComponentAttempt<H,Array<U32>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case Existing.ComponentApplied{owner}:final_swap(~H,fail,Existing.capture_swap(~Array<U32>,~H,~capture_cap(~S,~H,~caps),owner,1,element))
    case Existing.ComponentRefused{owner,incoming,error}:(owner,(T.Failure{Failed{}},Output{[],[incoming],[],[element],[error]}))
def third(~S:Data,~H:Type,~caps:Ops(~S)(H),target:W.Handle<S>,b2:Array<U32>,element:Array<U32>,fail:Bool,result:Existing.ComponentAttempt<H,Array<Array<U32>>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case Existing.ComponentApplied{owner}:fourth(~S,~H,~caps,element,fail,Existing.component_replace(~S,~Array<U32>,~Schema.second_identity(~S),~H,~second_cap(~S,~H,~caps),owner,target,Some{b2}))
    case Existing.ComponentRefused{owner,incoming,error}:(owner,(T.Failure{Failed{}},Output{[incoming],[Some{b2}],[],[element],[error]}))
def second(~S:Data,~H:Type,~caps:Ops(~S)(H),+target:W.Handle<S>,a2:Array<Array<U32>>,b2:Array<U32>,capture:Array<Array<U32>>,element:Array<U32>,fail:Bool,result:Existing.ComponentAttempt<H,Array<U32>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case Existing.ComponentApplied{owner}:third(~S,~H,~caps,target,b2,element,fail,Existing.component_replace(~S,~Array<Array<U32>>,~Schema.first_identity(~S),~H,~first_cap(~S,~H,~caps),Existing.capture_replace(~Array<U32>,~H,~capture_cap(~S,~H,~caps),owner,capture),target,Some{a2}))
    case Existing.ComponentRefused{owner,incoming,error}:(owner,(T.Failure{Failed{}},Output{[Some{a2}],[incoming,Some{b2}],[capture],[element],[error]}))
def first(~S:Data,~H:Type,~caps:Ops(~S)(H),+target:W.Handle<S>,b:Array<U32>,a2:Array<Array<U32>>,b2:Array<U32>,capture:Array<Array<U32>>,element:Array<U32>,fail:Bool,result:Existing.ComponentAttempt<H,Array<Array<U32>>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case Existing.ComponentApplied{owner}:second(~S,~H,~caps,target,a2,b2,capture,element,fail,Existing.component_replace(~S,~Array<U32>,~Schema.second_identity(~S),~H,~second_cap(~S,~H,~caps),owner,target,Some{b}))
    case Existing.ComponentRefused{owner,incoming,error}:(owner,(T.Failure{Failed{}},Output{[incoming,Some{a2}],[Some{b},Some{b2}],[capture],[element],[error]}))
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),args:Args<S>,owner:H) -> H & (T.Outcome<Error> & Output):
  match args:
    case Args{+target,a,b,a2,b2,capture,element,fail}:first(~S,~H,~caps,target,b,a2,b2,capture,element,fail,Existing.component_replace(~S,~Array<Array<U32>>,~Schema.first_identity(~S),~H,~first_cap(~S,~H,~caps),owner,target,Some{a}))
def Instance(~S:Data) -> Type:System.Owned(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Recovery(~S),~Ops(~S),~Args<S>,~Error,~Output,~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~Product.Owner<List<RC.Record<S,Array<U32>>>,List<RA.Record<Array<U32>>>>,~FirstOps(~S),~TailOps(~S),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<U32>>,~Array<Array<U32>>,~Unit,~Schema.FirstToken,~Schema.first_take(~S),~Schema.first_put(~S),~Schema.first_view,~Schema.first_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<U32>>>,~List<RA.Record<Array<U32>>>,~SecondOps(~S),~CaptureOps(),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,~Schema.second_binding(~S)),~Capture.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<U32>))),~declaration(~S),~body(~S))
def define(~S:Data,world:World(~S),capture:Array<Array<U32>>) -> System.Defined<World(~S),Instance(~S),Array<Array<U32>>>:System.define(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Recovery(~S),~Ops(~S),~Args<S>,~Error,~Output,~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~Product.Owner<List<RC.Record<S,Array<U32>>>,List<RA.Record<Array<U32>>>>,~FirstOps(~S),~TailOps(~S),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<U32>>,~Array<Array<U32>>,~Unit,~Schema.FirstToken,~Schema.first_take(~S),~Schema.first_put(~S),~Schema.first_view,~Schema.first_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<U32>>>,~List<RA.Record<Array<U32>>>,~SecondOps(~S),~CaptureOps(),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,~Schema.second_binding(~S)),~Capture.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<U32>))),~declaration(~S),~body(~S),world,"recoverable-heterogeneous",capture)
def Run(~S:Data) -> Type:System.Run<World(~S),Instance(~S),Args<S>,Error,Output,Recovery(~S)>
def run(~S:Data,owner:Instance(~S),world:World(~S),args:Args<S>) -> Run(~S):System.run(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Recovery(~S),~Ops(~S),~Args<S>,~Error,~Output,~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<Array<U32>>>>,~Product.Owner<List<RC.Record<S,Array<U32>>>,List<RA.Record<Array<U32>>>>,~FirstOps(~S),~TailOps(~S),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<U32>>,~Array<Array<U32>>,~Unit,~Schema.FirstToken,~Schema.first_take(~S),~Schema.first_put(~S),~Schema.first_view,~Schema.first_binding(~S)),~D.pair_grant(~S,~State(~S),~List<RC.Record<S,Array<U32>>>,~List<RA.Record<Array<U32>>>,~SecondOps(~S),~CaptureOps(),~Component.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<Array<U32>>,~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,~Schema.second_binding(~S)),~Capture.grant(~S,~Schema.Store(~S),~Unit,~Unit,~Array<U32>))),~declaration(~S),~body(~S),owner,world,args)
def pair(+value:U32) -> Array<U32>:ANode{ALeaf{value},ALeaf{(value + 1 : U32)}}
def array(+value:U32) -> Array<Array<U32>>:ANode{ALeaf{pair(value)},ALeaf{pair((value + 2 : U32))}}
def args(~S:Data,target:W.Handle<S>,+seed:U32,fail:Bool) -> Args<S>:Args{target,array(seed),pair((seed + 10 : U32)),array((seed + 20 : U32)),pair((seed + 30 : U32)),array((seed + 40 : U32)),pair((seed + 50 : U32)),fail}
