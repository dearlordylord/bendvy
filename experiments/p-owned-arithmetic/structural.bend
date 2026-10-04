import Base

def adc_zero(+n: Nat, +w: Word(n)) -> {Word.adc(n,w,Word.zero(n),False{},False{}) == w : Word(n)}:
  match n:
    case 0n:
      match w:
        case WNil{}: {==}
    case 1n+p:
      match w:
        case WCon{False{},t}:
          Equal.cong(Word(p),Word(1n+p), x => WCon{False{},x},Word.adc(p,t,Word.zero(p),False{},False{}),t,adc_zero(p,t))
        case WCon{True{},t}:
          Equal.cong(Word(p),Word(1n+p), x => WCon{True{},x},Word.adc(p,t,Word.zero(p),False{},False{}),t,adc_zero(p,t))

def adc_carry(+n: Nat, +w: Word(n)) -> {Word.adc(n,w,Word.zero(n),False{},True{}) == Word.inc(n,w) : Word(n)}:
  match n:
    case 0n: {==}
    case 1n+p:
      match w:
        case WCon{False{},t}:
          Equal.cong(Word(p),Word(1n+p), x => WCon{True{},x},Word.adc(p,t,Word.zero(p),False{},False{}),t,adc_zero(p,t))
        case WCon{True{},t}:
          Equal.cong(Word(p),Word(1n+p), x => WCon{False{},x},Word.adc(p,t,Word.zero(p),False{},True{}),Word.inc(p,t),adc_carry(p,t))

def zero_conversion(+n: Nat) -> {Word.to_nat(n,Word.zero(n)) == 0n : Nat}:
  match n:
    case 0n: {==}
    case 1n+p:
      %zero_conversion(p) : {Nat.double(Word.to_nat(p,Word.zero(p))) == Nat.double(_) : Nat}
      {==}

def clear_conversion(+n: Nat, +tail: Word(n)) -> {Word.to_nat(1n+n,Word.inc(1n+n,WCon{False{},tail})) == 1n+Word.to_nat(1n+n,WCon{False{},tail}) : Nat}:
  {==}

def carry_conversion(+n: Nat, +tail: Word(n), h: {Word.to_nat(n,Word.inc(n,tail)) == 1n+Word.to_nat(n,tail) : Nat}) -> {Word.to_nat(1n+n,Word.inc(1n+n,WCon{True{},tail})) == 1n+Word.to_nat(1n+n,WCon{True{},tail}) : Nat}:
  %h : {Nat.double(Word.to_nat(n,Word.inc(n,tail))) == Nat.double(_) : Nat}
  {==}

def cmp_self(+n: Nat, +w: Word(n)) -> {Word.cmp(n,w,w) == EQ{} : Cmp}:
  match n:
    case 0n: {==}
    case 1n+p:
      match w:
        case WCon{False{},t}:
          %cmp_self(p,t) : {Word.cmp.fin(False{},False{},Word.cmp(p,t,t)) == Word.cmp.fin(False{},False{},_) : Cmp}
          {==}
        case WCon{True{},t}:
          %cmp_self(p,t) : {Word.cmp.fin(True{},True{},Word.cmp(p,t,t)) == Word.cmp.fin(True{},True{},_) : Cmp}
          {==}

# Actual +1 uses Word.add, not Word.inc. This bridge includes wrapping words.
def add_one(+n: Nat, +w: Word(1n+n)) -> {Word.add(1n+n,w,WCon{True{},Word.zero(n)}) == Word.inc(1n+n,w) : Word(1n+n)}:
  match w:
    case WCon{False{},t}:
      Equal.cong(Word(n),Word(1n+n), x => WCon{True{},x},Word.adc(n,t,Word.zero(n),False{},False{}),t,adc_zero(n,t))
    case WCon{True{},t}:
      Equal.cong(Word(n),Word(1n+n), x => WCon{False{},x},Word.adc(n,t,Word.zero(n),False{},True{}),Word.inc(n,t),adc_carry(n,t))

def runtime_add_one(+value: U32) -> {U32.add(value,1) == U32.inc(value) : U32}:
  match value:
    case U32{w}:
      Equal.cong(Word(32n),U32,x => U32{x},Word.add(32n,w,WCon{True{},Word.zero(31n)}),Word.inc(32n,w),add_one(31n,w))
