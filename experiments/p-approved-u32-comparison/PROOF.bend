import Base
import ./LAWS.bend as Laws
import ./structural.bend as W

# Exact approved bridge: actual B.less dispatch remains in the original subject.
def Laws.u32_comparison_agrees_nat(left,right):
  match left right:
    case U32{+x} U32{+y}:
      %W.word_cmp(32n,x,y) : {Cmp.is_lt(_) == Nat.is_lt(Word.to_nat(32n,x),Word.to_nat(32n,y)) : Bool}
      {==}
