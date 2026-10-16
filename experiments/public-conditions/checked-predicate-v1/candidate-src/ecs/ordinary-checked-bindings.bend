import Base
import ./ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch

type Description is Data:Description{systemId:U32,condition:Cond.Description}
type Selection<World:Type,Owner:Type> is Type:
  Selected{world:World,owner:Owner,result:Result<&2,&2,Cond.Error,Bool>}
  Unbound{world:World,owner:Owner}
type BoundOwner<Owner:Type> is Type:BoundOwner{systemId:U32,owner:Owner}
type Bindings<World:Type,Owner:Type,-select:Owner -> World -> U32 -> Selection<World,Owner>> is Type:
  Bindings{owner:Owner,descriptions:List<&2,Description>}
def selected_returned(~World:Type,~Owner:Type,id:U32,value:Cond.Evaluation<World,Owner>) -> Selection<World,BoundOwner<Owner>>:
  match value:
    case Cond.Evaluation{world,owner,Fail{Cond.NoBinding{}}}:Unbound{world,BoundOwner{id,owner}}
    case Cond.Evaluation{world,owner,result}:Selected{world,BoundOwner{id,owner},result}
def selected(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Cond.Evaluation<World,Owner>,allowed:Bool,id:U32,owner:Owner,world:World) -> Selection<World,BoundOwner<Owner>>:
  match allowed:
    case False{}:Unbound{world,BoundOwner{id,owner}}
    case True{}:selected_returned(~World,~Owner,id,evaluate(owner,world))
def select(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Cond.Evaluation<World,Owner>,value:BoundOwner<Owner>,world:World,target:U32) -> Selection<World,BoundOwner<Owner>>:
  match value:
    case BoundOwner{+id,owner}:selected(~World,~Owner,~evaluate,U32.is_eq(id,target),id,owner,world)
def bind(~World:Type,~Owner:Type,~evaluate:Owner -> World -> Cond.Evaluation<World,Owner>,+id:U32,value:Cond.Condition<World,Owner,evaluate>) -> Bindings<World,BoundOwner<Owner>,select(~World,~Owner,~evaluate)>:
  match value:
    case Cond.Condition{owner,description}:Bindings{BoundOwner{id,owner},[Description{id,description}]}
def includes(values:List<&2,Description>,+id:U32) -> Bool:
  match values:
    case []:False{}
    case Description{other,_} <> rest:Bool.or(U32.is_eq(id,other),includes(rest,id))
def with_right(~World:Type,~Left:Type,~Right:Type,right:Right,value:Selection<World,Left>) -> Selection<World,Left & Right>:
  match value:
    case Selected{world,left,result}:Selected{world,(left,right),result}
    case Unbound{world,left}:Unbound{world,(left,right)}
def with_left(~World:Type,~Left:Type,~Right:Type,left:Left,value:Selection<World,Right>) -> Selection<World,Left & Right>:
  match value:
    case Selected{world,right,result}:Selected{world,(left,right),result}
    case Unbound{world,right}:Unbound{world,(left,right)}
def pair_left_returned(~World:Type,~Left:Type,~Right:Type,~right_select:Right -> World -> U32 -> Selection<World,Right>,right:Right,id:U32,value:Selection<World,Left>) -> Selection<World,Left & Right>:
  match value:
    case Selected{world,left,result}:Selected{world,(left,right),result}
    case Unbound{world,left}:with_left(~World,~Left,~Right,left,right_select(right,world,id))
def pair_shared(~World:Type,~Left:Type,~Right:Type,~left_select:Left -> World -> U32 -> Selection<World,Left>,~right_select:Right -> World -> U32 -> Selection<World,Right>,owners:Left & Right,world:World,+id:U32) -> Selection<World,Left & Right>:
  match owners:
    case (left,right):pair_left_returned(~World,~Left,~Right,~right_select,right,id,left_select(left,world,id))
def pair_select(~World:Type,~Left:Type,~Right:Type,~left_select:Left -> World -> U32 -> Selection<World,Left>,~right_select:Right -> World -> U32 -> Selection<World,Right>,owners:Left & Right,world:World,id:U32) -> Selection<World,Left & Right>:
  pair_shared(~World,~Left,~Right,~left_select,~right_select,owners,world,id)
def pair(~World:Type,~Left:Type,~Right:Type,~left_select:Left -> World -> U32 -> Selection<World,Left>,~right_select:Right -> World -> U32 -> Selection<World,Right>,left:Bindings<World,Left,left_select>,right:Bindings<World,Right,right_select>) -> Bindings<World,Left & Right,pair_select(~World,~Left,~Right,~left_select,~right_select)>:
  match left right:
    case Bindings{left,ld} Bindings{right,rd}:Bindings{(left,right),List.append(&2,Description,ld,rd)}
def contains(ids:List<&2,U32>,+id:U32) -> Bool:
  match ids:
    case []:False{}
    case head <> rest:Bool.or(U32.is_eq(id,head),contains(rest,id))
def unique(values:List<&2,Description>,+seen:List<&2,U32>) -> Bool:
  match values:
    case []:True{}
    case Description{+id,_} <> rest:Bool.and(Bool.not(contains(seen,id)),unique(rest,id <> seen))
def has_system(steps:List<&2,Sch.Step>,+id:U32) -> Bool:
  match steps:
    case []:False{}
    case Sch.System{other,_} <> rest:Bool.or(U32.is_eq(other,id),has_system(rest,id))
    case _ <> rest:has_system(rest,id)
def targets(values:List<&2,Description>,+steps:List<&2,Sch.Step>) -> Bool:
  match values:
    case []:True{}
    case Description{id,_} <> rest:Bool.and(has_system(steps,id),targets(rest,steps))
