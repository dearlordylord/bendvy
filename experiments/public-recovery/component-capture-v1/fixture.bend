import Base
import ../../../src/ecs/ordinary-recoverable-component-capture.bend as O
import ../../../src/ecs/ordinary-recoverable-array-resource.bend as A
import ../../../src/ecs/ordinary-declaration.bend as D
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T
type Args<S:Data> is Type:
  Args{target:W.Handle<S>,foreign:W.Handle<S>,first:Array<Array<U32>>,second:Array<Array<U32>>,captureFirst:Array<Array<U32>>,captureElement:Array<U32>,captureSecond:Array<Array<U32>>,rejected:Array<Array<U32>>,fail:Bool}
type Error is Data: Failed{}
type Output is Type:
  Output{components:List<Maybe<Array<Array<U32>>>>,arrays:List<Array<Array<U32>>>,elements:List<Array<U32>>,errors:List<W.WorldError>}
def World(~S:Data) -> Type: W.World<S,Col.Column<S,Array<Array<U32>>>,Unit,Unit>
def identity(~S:Data) -> D.Declaration<S,Array<Array<U32>>>:D.component(~S,~Array<Array<U32>>,"Payload")
def Ops(~S:Data,H:Type) -> Type:O.Ops(~S,~Array<Array<U32>>,~Array<U32>,~identity(~S),H)
def component(~S:Data,~H:Type,~caps:Ops(~S,H)) -> O.ComponentWrite<S,Array<Array<U32>>,identity(~S),H>:Cap.first(~O.ComponentWrite<S,Array<Array<U32>>,identity(~S),H>,~O.CaptureWrite<Array<U32>,H>,caps)
def capture(~S:Data,~H:Type,~caps:Ops(~S,H)) -> O.CaptureWrite<Array<U32>,H>:Cap.second(~O.ComponentWrite<S,Array<Array<U32>>,identity(~S),H>,~O.CaptureWrite<Array<U32>,H>,caps)
def outcome(fail:Bool) -> T.Outcome<Error>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Failed{}}
def foreign_result(~H:Type,fail:Bool,result:O.ComponentAttempt<H,Array<Array<U32>>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case O.ComponentRefused{owner,incoming,error}:(owner,(outcome(fail),Output{[incoming],[],[],[error]}))
    case O.ComponentApplied{owner}:(owner,(T.Failure{Failed{}},Output{[],[],[],[]}))
def second_result(~S:Data,~H:Type,~caps:Ops(~S,H),foreign:W.Handle<S>,captureSecond:Array<Array<U32>>,rejected:Array<Array<U32>>,fail:Bool,result:O.ComponentAttempt<H,Array<Array<U32>>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case O.ComponentApplied{owner}:foreign_result(~H,fail,O.component_replace(~S,~Array<Array<U32>>,~identity(~S),~H,~component(~S,~H,~caps),O.capture_replace(~Array<U32>,~H,~capture(~S,~H,~caps),owner,captureSecond),foreign,Some{rejected}))
    case O.ComponentRefused{owner,incoming,error}:(owner,(T.Failure{Failed{}},Output{[incoming,Some{rejected}],[captureSecond],[],[error]}))
def swapped(~S:Data,~H:Type,~caps:Ops(~S,H),target:W.Handle<S>,foreign:W.Handle<S>,second:Array<Array<U32>>,captureSecond:Array<Array<U32>>,rejected:Array<Array<U32>>,fail:Bool,result:A.Attempt<H,Array<U32>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case A.Applied{owner}:second_result(~S,~H,~caps,foreign,captureSecond,rejected,fail,O.component_replace(~S,~Array<Array<U32>>,~identity(~S),~H,~component(~S,~H,~caps),owner,target,Some{second}))
    case A.Refused{owner,element}:(owner,(T.Failure{Failed{}},Output{[Some{second},Some{rejected}],[captureSecond],[element],[]}))
def first_result(~S:Data,~H:Type,~caps:Ops(~S,H),target:W.Handle<S>,foreign:W.Handle<S>,second:Array<Array<U32>>,captureFirst:Array<Array<U32>>,captureElement:Array<U32>,captureSecond:Array<Array<U32>>,rejected:Array<Array<U32>>,fail:Bool,result:O.ComponentAttempt<H,Array<Array<U32>>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case O.ComponentApplied{owner}:swapped(~S,~H,~caps,target,foreign,second,captureSecond,rejected,fail,O.capture_swap(~Array<U32>,~H,~capture(~S,~H,~caps),O.capture_replace(~Array<U32>,~H,~capture(~S,~H,~caps),owner,captureFirst),1,captureElement))
    case O.ComponentRefused{owner,incoming,error}:(owner,(T.Failure{Failed{}},Output{[incoming,Some{second},Some{rejected}],[captureFirst,captureSecond],[captureElement],[error]}))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),args:Args<S>,owner:H) -> H & (T.Outcome<Error> & Output):
  match args:
    case Args{+target,foreign,first,second,cf,ce,cs,rejected,fail}:first_result(~S,~H,~caps,target,foreign,second,cf,ce,cs,rejected,fail,O.component_replace(~S,~Array<Array<U32>>,~identity(~S),~H,~component(~S,~H,~caps),owner,target,Some{first}))
def Instance(~S:Data) -> Type:O.Owned(~S,~Array<Array<U32>>,~Array<U32>,~Unit,~Unit,~identity(~S),~Args<S>,~Error,~Output,~body(~S))
def define(~S:Data,world:World(~S),capture:Array<Array<U32>>) -> O.Defined<World(~S),Instance(~S),Array<U32>>:O.define(~S,~Array<Array<U32>>,~Array<U32>,~Unit,~Unit,~identity(~S),~Args<S>,~Error,~Output,~body(~S),world,"recoverable-component-capture",capture)
def Run(~S:Data) -> Type:O.Run<World(~S),Instance(~S),Args<S>,Error,Output,O.Recovery(~S,~Array<Array<U32>>,~Array<U32>)>
def run(~S:Data,owner:Instance(~S),world:World(~S),args:Args<S>) -> Run(~S):O.run(~S,~Array<Array<U32>>,~Array<U32>,~Unit,~Unit,~identity(~S),~Args<S>,~Error,~Output,~body(~S),owner,world,args)
def pair(+value:U32) -> Array<U32>:ANode{ALeaf{value},ALeaf{(value + 1 : U32)}}
def array(+value:U32) -> Array<Array<U32>>:ANode{ALeaf{pair(value)},ALeaf{pair((value + 2 : U32))}}
def args(~S:Data,target:W.Handle<S>,foreign:W.Handle<S>,+seed:U32,fail:Bool) -> Args<S>:Args{target,foreign,array(seed),array((seed + 20 : U32)),array((seed + 40 : U32)),pair((seed + 50 : U32)),array((seed + 60 : U32)),array((seed + 80 : U32)),fail}
