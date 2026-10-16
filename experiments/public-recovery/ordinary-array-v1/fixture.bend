import Base
import ../../../src/ecs/ordinary-recoverable-array-resource.bend as O
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
type Args is Type:
  Args{first:Array<Array<U32>>,element:Array<U32>,second:Array<Array<U32>>,rejected:Array<U32>,fail:Bool}
type Error is Data:
  Failed{}
type Output is Type:
  Output{arrays:List<Array<Array<U32>>>,elements:List<Array<U32>>}
def identity(~S:Data) -> Schema.Resource<S,Array<Array<U32>>>:
  Schema.resource(~S,~Array<Array<U32>>,"Payload")
def Ops(~S:Data,H:Type) -> Type:
  O.Write<S,Array<U32>,identity(~S),H>
def outcome(fail:Bool) -> T.Outcome<Error>:
  match fail:
    case False{}:T.Success{}
    case True{}:T.Failure{Failed{}}
def refused(~H:Type,fail:Bool,result:O.Attempt<H,Array<U32>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case O.Refused{owner,rejected}:(owner,(outcome(fail),Output{[],[rejected]}))
    case O.Applied{owner}:(owner,(T.Failure{Failed{}},Output{[],[]}))
def swapped(~S:Data,~H:Type,~caps:Ops(~S,H),second:Array<Array<U32>>,rejected:Array<U32>,fail:Bool,result:O.Attempt<H,Array<U32>>) -> H & (T.Outcome<Error> & Output):
  match result:
    case O.Applied{owner}:refused(~H,fail,O.swap(~S,~Array<U32>,~identity(~S),~H,~caps,O.replace(~S,~Array<U32>,~identity(~S),~H,~caps,owner,second),99,rejected))
    case O.Refused{owner,element}:(owner,(T.Failure{Failed{}},Output{[second],[element,rejected]}))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),args:Args,owner:H) -> H & (T.Outcome<Error> & Output):
  match args:
    case Args{first,element,second,rejected,fail}:swapped(~S,~H,~caps,second,rejected,fail,O.swap(~S,~Array<U32>,~identity(~S),~H,~caps,O.replace(~S,~Array<U32>,~identity(~S),~H,~caps,owner,first),1,element))
def Registry(~S:Data) -> Type:
  O.Registry(~S,~Unit,~Array<U32>,~Unit,~identity(~S),~Args,~Error,~Output,~body(~S))
def define(~S:Data,world:W.World<S,Unit,Array<Array<U32>>,Unit>) -> Sys.RegistrationResult<S,Unit,Array<Array<U32>>,Unit,Args,Unit,O.Reply<Error,Output,Array<U32>>,O.runner(~S,~Unit,~Array<U32>,~Unit,~identity(~S),~Args,~Error,~Output,~body(~S))>:
  O.define(~S,~Unit,~Array<U32>,~Unit,~identity(~S),~Args,~Error,~Output,~body(~S),world,"recoverable-array")
def pair(+value:U32) -> Array<U32>:
  ANode{ALeaf{value},ALeaf{(value + 1 : U32)}}
def array(+value:U32) -> Array<Array<U32>>:
  ANode{ALeaf{pair(value)},ALeaf{pair((value + 2 : U32))}}
def args(+seed:U32,fail:Bool) -> Args:
  Args{array(seed),pair((seed + 10 : U32)),array((seed + 20 : U32)),pair((seed + 30 : U32)),fail}
def run(~S:Data,registry:Registry(~S),world:W.World<S,Unit,Array<Array<U32>>,Unit>,args:Args) -> O.Run<W.World<S,Unit,Array<Array<U32>>,Unit>,Registry(~S),Args,Error,Output,Array<U32>>:
  O.run(~S,~Unit,~Array<U32>,~Unit,~identity(~S),~Args,~Error,~Output,~body(~S),registry,world,args)
