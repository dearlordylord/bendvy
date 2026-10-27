import Base

type Grant is Data:
  NoStructural{}
  Structural{}
type Context is Data:
  Context{namespace:U32,id:U32,grant:Grant}
type Permit is Data:
  Authorized{namespace:U32,id:U32}
  Unauthorized{}

# The prepared framework boundary supplies Context from its actual owner and
# closed command declaration. Gameplay bodies quantify an abstract Permit.
def qualified(context:Context) -> Permit:
  match context:
    case Context{namespace,id,Structural{}}:Authorized{namespace,id}
    case Context{_,_,NoStructural{}}:Unauthorized{}
def member(+id:U32,ids:List<&2,U32>) -> Bool:
  match ids:
    case []:False{}
    case next <> rest:Bool.or(U32.is_eq(id,next),member(id,rest))
def authorized(permit:Permit,namespace:U32,ids:List<&2,U32>) -> Bool:
  match permit:
    case Unauthorized{}:False{}
    case Authorized{actual,id}:Bool.and(U32.is_eq(actual,namespace),member(id,ids))
def authorize_unit(context:Unit,permit:Permit,namespace:U32,ids:List<&2,U32>) -> Bool:
  authorized(permit,namespace,ids)
