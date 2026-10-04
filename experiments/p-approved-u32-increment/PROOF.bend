import Base
import ./LAWS.bend as L
import ../t11-replacement/spec.bend as S
import ../t11-replacement/bridge.bend as B
import ../p-owned-arithmetic/structural.bend as A

def ones(+n: Nat) -> Word(n):
  match n:
    case 0n: WNil{}
    case 1n+p: WCon{True{},ones(p)}

def conditional(+condition: Bool, -claim: Type, proof: claim) -> S.When(condition,claim):
  match condition:
    case False{}: Unit{}
    case True{}: proof

def carry_when(+n: Nat, +tail: Word(n), +tag: Cmp, h: S.When(Cmp.is_lt(tag),{Word.to_nat(n,Word.inc(n,tail)) == 1n+Word.to_nat(n,tail) : Nat})) -> S.When(Cmp.is_lt(Word.cmp.fin(True{},True{},tag)),{Word.to_nat(1n+n,Word.inc(1n+n,WCon{True{},tail})) == 1n+Word.to_nat(1n+n,WCon{True{},tail}) : Nat}):
  match tag:
    case LT{}: A.carry_conversion(n,tail,h)
    case EQ{}: Unit{}
    case GT{}: Unit{}

def guarded_word(+n: Nat, +w: Word(n)) -> S.When(Cmp.is_lt(Word.cmp(n,w,ones(n))),{Word.to_nat(n,Word.inc(n,w)) == 1n+Word.to_nat(n,w) : Nat}):
  match n:
    case 0n: Unit{}
    case 1n+p:
      match w:
        case WCon{False{},tail}:
          conditional(Cmp.is_lt(Word.cmp(1n+p,WCon{False{},tail},ones(1n+p))),{Word.to_nat(1n+p,Word.inc(1n+p,WCon{False{},tail})) == 1n+Word.to_nat(1n+p,WCon{False{},tail}) : Nat},A.clear_conversion(p,tail))
        case WCon{True{},tail}:
          carry_when(p,tail,Word.cmp(p,tail,ones(p)),guarded_word(p,tail))

def L.u32_increment_no_wrap(value):
  match value:
    case U32{+w}:
      %Equal.sym(U32,B.increment(U32{w}),U32.inc(U32{w}),A.runtime_add_one(U32{w})) : S.When(U32.is_lt(U32{w},4294967295),{U32.to_nat(_) == 1n+U32.to_nat(U32{w}) : Nat})
      guarded_word(32n,w)
