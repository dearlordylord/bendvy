import Base

# Experimental exact codepoint equality. No ordering or reconstructed input pair.
def equal_walk(a: String,b: String,same: Bool) -> Bool:
  match a b:
    case SNil{} SNil{}: same
    case SNil{} SCon{_,_}: False{}
    case SCon{_,_} SNil{}: False{}
    case SCon{a,as} SCon{b,bs}: equal_walk(as,bs,Bool.and(same,Char.is_eq(a,b)))

def equal(a: String,b: String) -> Bool:
  equal_walk(a,b,True{})

def access_equal(xs: List<&2,String>,ys: List<&2,String>) -> Bool:
  match xs ys:
    case Nil{} Nil{}: True{}
    case Nil{} Con{_,_}: False{}
    case Con{_,_} Nil{}: False{}
    case Con{x,xs} Con{y,ys}: Bool.and(equal(x,y),access_equal(xs,ys))

def registration_equal(id: U32,name: String,access: List<&2,String>,otherId: U32,otherName: String,otherAccess: List<&2,String>) -> Bool:
  Bool.and(U32.is_eq(id,otherId),Bool.and(equal(name,otherName),access_equal(access,otherAccess)))
