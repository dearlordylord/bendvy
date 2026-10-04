import Base
import ./types.bend as T
import ./storage.bend as S

def quad(a:U32,b:U32,c:U32,d:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[a:U32^2n],1,b),2,c),3,d)

def motion_main(+j:U32,present:Bool) -> Maybe<T.Position>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Position{quad(j,U32.add(j,1),U32.add(j,2),U32.add(j,3)),7}}

def motion_aux(present:Bool) -> Maybe<T.Velocity>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Velocity{quad(1,2,3,4),True{}}}

def motion_flag(present:Bool) -> Maybe<&2,T.Selected>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Selected{8}}

def motion_bundle(+j:U32,sparse:Bool) -> S.Bundle<T.Position,T.Velocity,T.Selected>:
  S.Bundle{motion_main(j,Bool.or(Bool.not(sparse),U32.is_eq(U32.mod(j,8),0))),motion_aux(U32.is_eq(U32.mod(j,3),0)),motion_flag(U32.is_eq(U32.mod(j,3),1))}

def motion_ledger(unit:Unit) -> T.MotionLedger: T.MotionLedger{quad(0,101,102,103),4}

def health_main(+j:U32,present:Bool) -> Maybe<T.Vitals>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Vitals{quad(j,U32.add(j,1),U32.add(j,2),U32.add(j,3)),9,2}}

def health_aux(present:Bool) -> Maybe<T.Armor>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Armor{quad(1,2,3,4),3}}

def health_flag(present:Bool) -> Maybe<&2,T.Tracked>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Tracked{8}}

def health_bundle(+j:U32,sparse:Bool) -> S.Bundle<T.Vitals,T.Armor,T.Tracked>:
  S.Bundle{health_main(j,Bool.or(Bool.not(sparse),U32.is_eq(U32.mod(j,8),0))),health_aux(U32.is_eq(U32.mod(j,3),0)),health_flag(U32.is_eq(U32.mod(j,3),1))}

def health_ledger(unit:Unit) -> T.HealthLedger: T.HealthLedger{quad(0,101,102,103),4}
