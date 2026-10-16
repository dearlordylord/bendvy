import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-composition.bend as Old
import ./ordinary-check-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K

type Shape is Data:
  Existing{description:Old.Description}
  Check{name:String}
  Constant{value:Bool}
  Not{inner:Shape}
  And{left:Shape,right:Shape}
  Or{left:Shape,right:Shape}
type Description is Data:Description{shape:Shape,uses:List<&2,D.Use>}
type Error is Data:
  CheckError{error:K.Error}
  NoValue{}
  InvalidRegistration{}
  NoBinding{}
type Evaluation<World:Type,Owner:Type> is Type:
  Evaluation{world:World,owner:Owner,result:Result<&2,&2,Error,Bool>}
type Condition<World:Type,Owner:Type,-evaluate:Owner -> World -> Evaluation<World,Owner>> is Type:
  Condition{owner:Owner,description:Description}
type Returned<World:Type,Owner:Type,-evaluate:Owner -> World -> Evaluation<World,Owner>> is Type:
  Returned{world:World,condition:Condition<World,Owner,evaluate>,result:Result<&2,&2,Error,Bool>}
def check_result(value:Result<&2,&2,K.Error,Bool>) -> Result<&2,&2,Error,Bool>:
  match value:
    case Done{value}:Done{value}
    case Fail{error}:Fail{CheckError{error}}
def lifted_returned(~World:Type,~Owner:Type,value:Old.Evaluation<World,Owner>) -> Evaluation<World,Owner>:
  match value:
    case Old.Value{world,owner,value}:Evaluation{world,owner,Done{value}}
    case Old.NoValue{world,owner}:Evaluation{world,owner,Fail{NoValue{}}}
    case Old.InvalidRegistration{world,owner}:Evaluation{world,owner,Fail{InvalidRegistration{}}}
    case Old.NoBinding{world,owner}:Evaluation{world,owner,Fail{NoBinding{}}}
def lift_run(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Old.Evaluation<World,Owner>,owner:Owner,world:World) -> Evaluation<World,Owner>:lifted_returned(~World,~Owner,evaluate(owner,world))
def lift(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Old.Evaluation<World,Owner>,value:Old.Condition<World,Owner,evaluate>) -> Condition<World,Owner,lift_run(~World,~Owner,~evaluate)>:
  match value:
    case Old.Condition{owner,description}:Condition{owner,Description{Existing{description},[]}}
def check_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Args:Data,args:Args,value:K.Checked<S,C,R,E>) -> Evaluation<W.World<S,C,R,E>,Args>:
  match value:
    case K.Checked{world,result}:Evaluation{world,args,check_result(result)}
def check_shared(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Data,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & Bool,~declaration:D.Declaration<S,C,R,E,Ops>,+args:Args,world:W.World<S,C,R,E>) -> Evaluation<W.World<S,C,R,E>,Args>:
  check_returned(~S,~C,~R,~E,~Args,args,K.run(~S,~C,~R,~E,~Ops,~Args,~body,~D.plan(~S,~C,~R,~E,~Ops,declaration),args,world))
def check_run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Data,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & Bool,~declaration:D.Declaration<S,C,R,E,Ops>,args:Args,world:W.World<S,C,R,E>) -> Evaluation<W.World<S,C,R,E>,Args>:
  check_shared(~S,~C,~R,~E,~Ops,~Args,~body,~declaration,args,world)
def check(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Args:Data,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & Bool,~declaration:D.Declaration<S,C,R,E,Ops>,name:String,args:Args) -> Condition<W.World<S,C,R,E>,Args,check_run(~S,~C,~R,~E,~Ops,~Args,~body,~declaration)>:
  Condition{args,Description{Check{name},D.uses(~S,~C,~R,~E,~Ops,declaration)}}
def constant_shared(~World:Type,+value:Bool,world:World) -> Evaluation<World,Bool>:Evaluation{world,value,Done{value}}
def constant_run(~World:Type,value:Bool,world:World) -> Evaluation<World,Bool>:constant_shared(~World,value,world)
def constant(~World:Type,+value:Bool) -> Condition<World,Bool,constant_run(~World)>:Condition{value,Description{Constant{value},[]}}
def returned(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,description:Description,value:Evaluation<World,Owner>) -> Returned<World,Owner,evaluate>:
  match value:
    case Evaluation{world,owner,result}:Returned{world,Condition{owner,description},result}
def run(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,value:Condition<World,Owner,evaluate>,world:World) -> Returned<World,Owner,evaluate>:
  match value:
    case Condition{owner,description}:returned(~World,~Owner,~evaluate,description,evaluate(owner,world))
def negate(value:Result<&2,&2,Error,Bool>) -> Result<&2,&2,Error,Bool>:
  match value:
    case Done{value}:Done{Bool.not(value)}
    case Fail{error}:Fail{error}
def negated(~World:Type,~Owner:Type,value:Evaluation<World,Owner>) -> Evaluation<World,Owner>:
  match value:
    case Evaluation{world,owner,result}:Evaluation{world,owner,negate(result)}
def not_run(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,owner:Owner,world:World) -> Evaluation<World,Owner>:negated(~World,~Owner,evaluate(owner,world))
def not(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Evaluation<World,Owner>,value:Condition<World,Owner,evaluate>) -> Condition<World,Owner,not_run(~World,~Owner,~evaluate)>:
  match value:
    case Condition{owner,Description{shape,uses}}:Condition{owner,Description{Not{shape},uses}}
def right_returned(~World:Type,~Left:Type,~Right:Type,left:Left,value:Evaluation<World,Right>) -> Evaluation<World,Left & Right>:
  match value:
    case Evaluation{world,right,result}:Evaluation{world,(left,right),result}
def selected(~World:Type,~Left:Type,~Right:Type,~right_run:Right -> World -> Evaluation<World,Right>,allowed:Bool,left:Left,right:Right,world:World,+value:Bool) -> Evaluation<World,Left & Right>:
  match allowed:
    case False{}:Evaluation{world,(left,right),Done{value}}
    case True{}:right_returned(~World,~Left,~Right,left,right_run(right,world))
def same_bool(a:Bool,b:Bool) -> Bool:
  match a b:
    case True{} True{}:True{}
    case False{} False{}:True{}
    case _ _:False{}
def left_returned(~World:Type,~Left:Type,~Right:Type,~right_run:Right -> World -> Evaluation<World,Right>,on:Bool,right:Right,value:Evaluation<World,Left>) -> Evaluation<World,Left & Right>:
  match value:
    case Evaluation{world,left,Fail{error}}:Evaluation{world,(left,right),Fail{error}}
    case Evaluation{world,left,Done{+value}}:selected(~World,~Left,~Right,~right_run,same_bool(on,value),left,right,world,value)
def combined_run(~World:Type,~Left:Type,~Right:Type,~left_run:Left -> World -> Evaluation<World,Left>,~right_run:Right -> World -> Evaluation<World,Right>,~on:Bool,owners:Left & Right,world:World) -> Evaluation<World,Left & Right>:
  match owners:
    case (left,right):left_returned(~World,~Left,~Right,~right_run,on,right,left_run(left,world))
def and_then(~World:Type,~Left:Type,~Right:Type,~left_run:Left -> World -> Evaluation<World,Left>,~right_run:Right -> World -> Evaluation<World,Right>,left:Condition<World,Left,left_run>,right:Condition<World,Right,right_run>) -> Condition<World,Left & Right,combined_run(~World,~Left,~Right,~left_run,~right_run,~True{})>:
  match left right:
    case Condition{left,Description{ls,lu}} Condition{right,Description{rs,ru}}:Condition{(left,right),Description{And{ls,rs},List.append(&2,D.Use,lu,ru)}}
def or_else(~World:Type,~Left:Type,~Right:Type,~left_run:Left -> World -> Evaluation<World,Left>,~right_run:Right -> World -> Evaluation<World,Right>,left:Condition<World,Left,left_run>,right:Condition<World,Right,right_run>) -> Condition<World,Left & Right,combined_run(~World,~Left,~Right,~left_run,~right_run,~False{})>:
  match left right:
    case Condition{left,Description{ls,lu}} Condition{right,Description{rs,ru}}:Condition{(left,right),Description{Or{ls,rs},List.append(&2,D.Use,lu,ru)}}
