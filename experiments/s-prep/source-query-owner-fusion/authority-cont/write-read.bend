import Base
import ./query.bend as Q
import ./owners.bend as A

def bad(~P:Type,~U:Type,~get:P -> Unit -> P & String,~ag:U -> U & Maybe<&2,String>,~C0:Data,~C1:Type,~C2:Type,~C3:Type,~C4:Type,~C5:Type,~C6:Type,~C7:Type,~Out:Type,~done:@+_:C0 -> C1 -> C2 -> C3 -> C4 -> C5 -> C6 -> C7 -> P -> U -> String -> Out,c0:C0,c1:C1,c2:C2,c3:C3,c4:C4,c5:C5,c6:C6,c7:C7,p:P,u:U) -> Out:
  done(c0,c1,c2,c3,c4,c5,c6,c7,A.motion_set(p,1),u,"forged-write")
