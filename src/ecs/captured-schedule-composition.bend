import Base
import ./world.bend as W
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
# Closed typed composition carries independently authored owners, never a copied
# closure or a caller-maintained dispatcher enumeration.
# Detached actual registration identity used by heterogeneous composition.
# Includes namespace/ID/name/access for validation; not a substitute for the
# affine owner or an authorization token on its own.
type Identity is Data:
  Identity{namespace:U32,id:U32,name:String,access:List<&2,String>}
# Dispatch result retaining World and heterogeneous owner on completion,
# skip, failure or refusal. Error values are detached; owner restoration and
# transaction behavior belong to the selected registered runner.
type Outcome<World:Type,Owner:Type,Error:Data> is Type:
  Completed{world:World,owner:Owner}
  Skipped{world:World,owner:Owner}
  Failed{world:World,owner:Owner,error:Error}
  Refused{world:World,owner:Owner}
# Detached heterogeneous error sum used when composing registered systems.
# LeftError and RightError identify the originating error branch; it carries
# neither the World nor affine system owners, which return separately.
type Choice<L:Data,R:Data> is Data:
  LeftError{error:L}
  RightError{error:R}
def ids(items:List<&2,Identity>) -> List<&2,U32>:
  match items:
    case []:[]
    case Identity{_,id,_,_} <> rest:id <> ids(rest)
def member(items:List<&2,Identity>,+wanted:U32) -> Bool:
  match items:
    case []:False{}
    case Identity{_,id,_,_} <> rest:Bool.or(U32.is_eq(id,wanted),member(rest,wanted))
def identities_valid(+namespace:U32,+registered:List<&2,W.RegistrationMeta>,items:List<&2,Identity>,+seen:List<&2,U32>) -> Bool:
  match items:
    case []:True{}
    case Identity{ns,+id,name,access} <> rest:Bool.and(U32.is_eq(namespace,ns),Bool.and(W.registration_list_matches(registered,id,name,access),Bool.and(Bool.not(Sch.contains(seen,id)),identities_valid(namespace,registered,rest,id <> seen))))
def pair_catalog_done(~L:Type,~R:Type,left:L,entries:List<&2,Identity>,result:R & List<&2,Identity>) -> (L & R) & List<&2,Identity>:
  match result:
    case (right,more):((left,right),List.append(&2,Identity,entries,more))
def pair_catalog_left(~L:Type,~R:Type,~right:R -> R & List<&2,Identity>,other:R,result:L & List<&2,Identity>) -> (L & R) & List<&2,Identity>:
  match result:
    case (owner,entries):pair_catalog_done(~L,~R,owner,entries,right(other))
# Advanced owner-threading catalog composition in left/right order.
# Returns both affine owners and appended identities without executing bodies.
# Supplied catalog callbacks must preserve actual registration correspondence.
def pair_catalog(~L:Type,~R:Type,~left:L -> L & List<&2,Identity>,~right:R -> R & List<&2,Identity>,owners:L & R) -> (L & R) & List<&2,Identity>:
  match owners:
    case (a,b):pair_catalog_left(~L,~R,~right,b,left(a))
def left_returned(~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,right:R,result:Outcome<World,L,LE>) -> Outcome<World,L & R,Choice<LE,RE>>:
  match result:
    case Completed{world,left}:Completed{world,(left,right)}
    case Skipped{world,left}:Skipped{world,(left,right)}
    case Failed{world,left,error}:Failed{world,(left,right),LeftError{error}}
    case Refused{world,left}:Refused{world,(left,right)}
def right_returned(~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,left:L,result:Outcome<World,R,RE>) -> Outcome<World,L & R,Choice<LE,RE>>:
  match result:
    case Completed{world,right}:Completed{world,(left,right)}
    case Skipped{world,right}:Skipped{world,(left,right)}
    case Failed{world,right,error}:Failed{world,(left,right),RightError{error}}
    case Refused{world,right}:Refused{world,(left,right)}
def pair_selected(~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,~left:L -> World -> U32 -> Outcome<World,L,LE>,~right:R -> World -> U32 -> Outcome<World,R,RE>,found:Bool,a:L,b:R,world:World,id:U32) -> Outcome<World,L & R,Choice<LE,RE>>:
  match found:
    case True{}:left_returned(~World,~L,~R,~LE,~RE,b,left(a,world,id))
    case False{}:right_returned(~World,~L,~R,~LE,~RE,a,right(b,world,id))
def pair_cataloged(~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,~left:L -> World -> U32 -> Outcome<World,L,LE>,~right:R -> World -> U32 -> Outcome<World,R,RE>,b:R,world:World,+id:U32,result:L & List<&2,Identity>) -> Outcome<World,L & R,Choice<LE,RE>>:
  match result:
    case (a,entries):pair_selected(~World,~L,~R,~LE,~RE,~left,~right,member(entries,id),a,b,world,id)
# Advanced heterogeneous dispatch using the left catalog to choose a branch.
# Retains both owners, wraps errors as LeftError/RightError and preserves skip/
# refusal outcomes. The selected dispatcher performs registration validation;
# metadata membership alone confers no authority and adds no rollback.
def pair_dispatch(~World:Type,~L:Type,~R:Type,~LE:Data,~RE:Data,~catalog:L -> L & List<&2,Identity>,~left:L -> World -> U32 -> Outcome<World,L,LE>,~right:R -> World -> U32 -> Outcome<World,R,RE>,owners:L & R,world:World,id:U32) -> Outcome<World,L & R,Choice<LE,RE>>:
  match owners:
    case (a,b):pair_cataloged(~World,~L,~R,~LE,~RE,~left,~right,b,world,id,catalog(a))
