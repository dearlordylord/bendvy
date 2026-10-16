import Base
# Typed operational uses; capture has no synthetic schema resource identity.
type Target is Data:
  Component{key:String}
  Resource{key:String}
  Capture{}
type Mode is Data:Write{}
type Use is Data:Use{target:Target,mode:Mode}
type Description is Data:Description{uses:List<&2,Use>,opaque:Bool}
def none() -> Description:Description{[],True{}}
def known(uses:List<&2,Use>) -> Description:Description{uses,False{}}
def pair(left:Description,right:Description) -> Description:
  match left right:
    case Description{a,oa} Description{b,ob}:Description{List.append(&2,Use,a,b),Bool.or(oa,ob)}
def complete(value:Description) -> Bool:
  match value:
    case Description{_,opaque}:Bool.not(opaque)
