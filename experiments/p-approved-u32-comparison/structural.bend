import Base

# Actual low-bit-first Nat interpretation and actual Word comparison finishing.
def cmp_ff(+left: Nat, +right: Nat)
  -> {Nat.cmp(Nat.double(left),Nat.double(right)) == Word.cmp.fin(False{},False{},Nat.cmp(left,right)) : Cmp}:
  match left right:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: cmp_ff(p,q)

def cmp_ft(+left: Nat, +right: Nat)
  -> {Nat.cmp(Nat.double(left),1n+Nat.double(right)) == Word.cmp.fin(False{},True{},Nat.cmp(left,right)) : Cmp}:
  match left right:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: cmp_ft(p,q)

def cmp_tf(+left: Nat, +right: Nat)
  -> {Nat.cmp(1n+Nat.double(left),Nat.double(right)) == Word.cmp.fin(True{},False{},Nat.cmp(left,right)) : Cmp}:
  match left right:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: cmp_tf(p,q)

def cmp_tt(+left: Nat, +right: Nat)
  -> {Nat.cmp(1n+Nat.double(left),1n+Nat.double(right)) == Word.cmp.fin(True{},True{},Nat.cmp(left,right)) : Cmp}:
  match left right:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: cmp_tt(p,q)

# Every width, every Word pair: no literal normalization or bounded value grid.
def word_cmp(+width: Nat, +left: Word(width), +right: Word(width))
  -> {Nat.cmp(Word.to_nat(width,left),Word.to_nat(width,right)) == Word.cmp(width,left,right) : Cmp}:
  match width:
    case 0n: {==}
    case 1n+p:
      match left right:
        case WCon{False{},+lt} WCon{False{},+rt}:
          %word_cmp(p,lt,rt) : {Nat.cmp(Nat.double(Word.to_nat(p,lt)),Nat.double(Word.to_nat(p,rt))) == Word.cmp.fin(False{},False{},_) : Cmp}
          cmp_ff(Word.to_nat(p,lt),Word.to_nat(p,rt))
        case WCon{False{},+lt} WCon{True{},+rt}:
          %word_cmp(p,lt,rt) : {Nat.cmp(Nat.double(Word.to_nat(p,lt)),1n+Nat.double(Word.to_nat(p,rt))) == Word.cmp.fin(False{},True{},_) : Cmp}
          cmp_ft(Word.to_nat(p,lt),Word.to_nat(p,rt))
        case WCon{True{},+lt} WCon{False{},+rt}:
          %word_cmp(p,lt,rt) : {Nat.cmp(1n+Nat.double(Word.to_nat(p,lt)),Nat.double(Word.to_nat(p,rt))) == Word.cmp.fin(True{},False{},_) : Cmp}
          cmp_tf(Word.to_nat(p,lt),Word.to_nat(p,rt))
        case WCon{True{},+lt} WCon{True{},+rt}:
          %word_cmp(p,lt,rt) : {Nat.cmp(1n+Nat.double(Word.to_nat(p,lt)),1n+Nat.double(Word.to_nat(p,rt))) == Word.cmp.fin(True{},True{},_) : Cmp}
          cmp_tt(Word.to_nat(p,lt),Word.to_nat(p,rt))
