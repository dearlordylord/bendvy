import Base
import ../../../../src/ecs/inspector-metadata.bend as Meta
import ../../../../src/ecs/world.bend as W
# Independently authored diagnostic formatting, outside metadata/Inspector body.
def resource(~S:Data,value:Meta.Resource<S>) -> String:
  match value:
    case Meta.Resource{id,name}:"resource:" ++ U32.show(id) ++ ":" ++ name
def text(value:String) -> String:
  value
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access)
def arrays(left:List<&2,U32>,right:List<&2,U32>,extra:List<&2,U32>) -> String:
  "left=" ++ List.show(&2,U32,U32.show,left) ++ "|right=" ++ List.show(&2,U32,U32.show,right) ++ "|extra=" ++ List.show(&2,U32,U32.show,extra)
def pending_join(~F:Type,head:F,result:List<F> & Nat) -> List<F> & Nat:
  (tail,count)=result
  (head <> tail,1n+count)
def pending(~F:Type,list:List<F>) -> List<F> & Nat:
  match list:
    case []:([],0n)
    case head <> tail:pending_join(~F,head,pending(~F,tail))
def cells(+base:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,Array.new(U32,2n,base),1,(base+1:U32)),2,(base+2:U32)),3,(base+3:U32))
