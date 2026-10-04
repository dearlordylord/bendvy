import Base
import ./helpers.bend as H
import ./invariants.bend as I

# Contextual Nat-key order and interval arithmetic only.
def reverse_cmp(order: Cmp) -> Cmp:
  match order:
    case EQ{}: EQ{}
    case LT{}: GT{}
    case GT{}: LT{}

def cmp_reverse(+a: Nat, +b: Nat) -> {reverse_cmp(Nat.cmp(a,b)) == Nat.cmp(b,a) : Cmp}:
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: {==}
    case 1n+p 1n+q: cmp_reverse(p,q)

def add_succ_right(+a: Nat, +b: Nat) -> {Nat.add(1n+a,b) == Nat.add(a,1n+b) : Nat}:
  match a:
    case 0n: {==}
    case 1n+p:
      %add_succ_right(p,b) : {1n+Nat.add(1n+p,b) == 1n+_ : Nat}
      {==}

def lt_succ_le(+a: Nat, +b: Nat, h: {True{} == Nat.is_lt(a,b) : Bool}) -> {True{} == Nat.is_le(1n+a,b) : Bool}:
  match a b:
    case 0n 0n: h
    case 0n 1n+q: I.zero_le(q)
    case 1n+p 0n: h
    case 1n+p 1n+q: lt_succ_le(p,q,h)

# Swap strict comparisons to false < in the reverse direction.
def opposite_lt(+a: Nat, +b: Nat, h: {True{} == Nat.is_lt(a,b) : Bool}) -> {False{} == Nat.is_lt(b,a) : Bool}:
  match a b:
    case 0n 0n: {==}
    case 0n 1n+q: {==}
    case 1n+p 0n: Equal.sym(Bool,True{},False{},h)
    case 1n+p 1n+q: opposite_lt(p,q,h)

def lt_self_succ(+n: Nat) -> {True{} == Nat.is_lt(n,1n+n) : Bool}:
  match n:
    case 0n: {==}
    case 1n+p: lt_self_succ(p)
