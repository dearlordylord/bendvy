import Base
import ../t11-replacement/spec.bend as S
import ../t11-replacement/bridge.bend as B
import ../p-approved-u32-comparison/structural.bend as C
import ../p-approved-u32-increment/PROOF.bend as I
import ../p-approved-u32-increment/LAWS.bend as L

# Local impossible Bool equality elimination, not a catalogue subject.
def impossible(h: {True{} == False{} : Bool}) -> Empty:
  %h : Bool.pick(Type,_,Unit,Empty)
  Unit{}

def require(+condition: Bool, -claim: Type, h: {True{} == condition : Bool}, proof: S.When(condition,claim)) -> claim:
  match condition:
    case False{}: Empty.absurd(claim,impossible(h))
    case True{}: proof

def equality(+left: U32, +right: U32) -> {U32.is_eq(left,right) == Nat.is_eq(U32.to_nat(left),U32.to_nat(right)) : Bool}:
  match left right:
    case U32{+x} U32{+y}:
      %C.word_cmp(32n,x,y) : {Cmp.is_eq(_) == Nat.is_eq(Word.to_nat(32n,x),Word.to_nat(32n,y)) : Bool}
      {==}

def lift_lt(+head: Bool, +tag: Cmp, h: {True{} == Cmp.is_lt(tag) : Bool}) -> {True{} == Cmp.is_lt(Word.cmp.fin(head,True{},tag)) : Bool}:
  match tag:
    case LT{}: {==}
    case EQ{}: Empty.absurd({True{} == Cmp.is_lt(Word.cmp.fin(head,True{},EQ{})) : Bool},impossible(h))
    case GT{}: Empty.absurd({True{} == Cmp.is_lt(Word.cmp.fin(head,True{},GT{})) : Bool},impossible(h))

def max_equal_head(+head: Bool) -> {True{} == Bool.not(Cmp.is_gt(Bool.cmp(head,True{}))) : Bool}:
  match head:
    case False{}: {==}
    case True{}: {==}

def max_finish(+head: Bool, +tag: Cmp, h: {True{} == Bool.not(Cmp.is_gt(tag)) : Bool}) -> {True{} == Bool.not(Cmp.is_gt(Word.cmp.fin(head,True{},tag))) : Bool}:
  match tag:
    case LT{}: {==}
    case EQ{}: max_equal_head(head)
    case GT{}: Empty.absurd({True{} == Bool.not(Cmp.is_gt(Word.cmp.fin(head,True{},GT{}))) : Bool},impossible(h))

def max_bound(+width: Nat, +word: Word(width)) -> {True{} == Bool.not(Cmp.is_gt(Word.cmp(width,word,I.ones(width)))) : Bool}:
  match width:
    case 0n: {==}
    case 1n+p:
      match word:
        case WCon{+head,+tail}: max_finish(head,Word.cmp(p,tail,I.ones(p)),max_bound(p,tail))

def clear_lt(+tag: Cmp, h: {True{} == Bool.not(Cmp.is_gt(tag)) : Bool}) -> {True{} == Cmp.is_lt(Word.cmp.fin(False{},True{},tag)) : Bool}:
  match tag:
    case LT{}: {==}
    case EQ{}: {==}
    case GT{}: Empty.absurd({True{} == Cmp.is_lt(Word.cmp.fin(False{},True{},GT{})) : Bool},impossible(h))

def reserve_equal(+width: Nat, +tail: Word(width), +lb: Bool, +rb: Bool, bound: {True{} == Bool.not(Cmp.is_gt(Word.cmp(width,tail,I.ones(width)))) : Bool}) -> S.When(Cmp.is_lt(Bool.cmp(lb,rb)),{True{} == Cmp.is_lt(Word.cmp.fin(lb,True{},Word.cmp(width,tail,I.ones(width)))) : Bool}):
  match lb rb:
    case False{} False{}: Unit{}
    case False{} True{}: clear_lt(Word.cmp(width,tail,I.ones(width)),bound)
    case True{} False{}: Unit{}
    case True{} True{}: Unit{}

def reserve_finish(+width: Nat, +tail: Word(width), +leftBit: Bool, +rightBit: Bool, +tag: Cmp, rec: S.When(Cmp.is_lt(tag),{True{} == Cmp.is_lt(Word.cmp(width,tail,I.ones(width))) : Bool}), bound: {True{} == Bool.not(Cmp.is_gt(Word.cmp(width,tail,I.ones(width)))) : Bool}) -> S.When(Cmp.is_lt(Word.cmp.fin(leftBit,rightBit,tag)),{True{} == Cmp.is_lt(Word.cmp.fin(leftBit,True{},Word.cmp(width,tail,I.ones(width)))) : Bool}):
  match tag:
    case LT{}: lift_lt(leftBit,Word.cmp(width,tail,I.ones(width)),rec)
    case GT{}: Unit{}
    case EQ{}: reserve_equal(width,tail,leftBit,rightBit,bound)

def reserve_word(+width: Nat, +left: Word(width), +right: Word(width)) -> S.When(Cmp.is_lt(Word.cmp(width,left,right)),{True{} == Cmp.is_lt(Word.cmp(width,left,I.ones(width))) : Bool}):
  match width:
    case 0n: Unit{}
    case 1n+p:
      match left right:
        case WCon{+lb,+lt} WCon{+rb,+rt}:
          reserve_finish(p,lt,lb,rb,Word.cmp(p,lt,rt),reserve_word(p,lt,rt),max_bound(p,lt))

def reserve_below_max(+next: U32, +limit: U32, h: {True{} == U32.is_lt(next,limit) : Bool}) -> {True{} == U32.is_lt(next,4294967295) : Bool}:
  match next limit:
    case U32{+x} U32{+y}:
      require(Cmp.is_lt(Word.cmp(32n,x,y)),{True{} == U32.is_lt(U32{x},4294967295) : Bool},h,reserve_word(32n,x,y))

def not_ge_lt(+tag: Cmp) -> {Bool.not(Cmp.is_ge(tag)) == Cmp.is_lt(tag) : Bool}:
  match tag:
    case LT{}: {==}
    case EQ{}: {==}
    case GT{}: {==}

def not_ge_agrees(+left: U32, +right: U32) -> {Bool.not(Nat.is_ge(U32.to_nat(left),U32.to_nat(right))) == U32.is_lt(left,right) : Bool}:
  match left right:
    case U32{+x} U32{+y}:
      %C.word_cmp(32n,x,y) : {Bool.not(Nat.is_ge(Word.to_nat(32n,x),Word.to_nat(32n,y))) == Cmp.is_lt(_) : Bool}
      not_ge_lt(Nat.cmp(Word.to_nat(32n,x),Word.to_nat(32n,y)))

def bump_guard_agrees(+value: U32) -> {Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))) == U32.is_lt(value,4294967295) : Bool}:
  not_ge_agrees(value,4294967295)

def bump_below_max(+value: U32, h: {True{} == Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))) : Bool}) -> {True{} == U32.is_lt(value,4294967295) : Bool}:
  Equal.trans(Bool,True{},Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))),U32.is_lt(value,4294967295),h,bump_guard_agrees(value))

def bump_increment(+value: U32, h: {True{} == Bool.not(Nat.is_ge(U32.to_nat(value),U32.to_nat(4294967295))) : Bool}) -> {U32.to_nat(U32.add(value,1)) == 1n+U32.to_nat(value) : Nat}:
  require(U32.is_lt(value,4294967295),{U32.to_nat(U32.add(value,1)) == 1n+U32.to_nat(value) : Nat},bump_below_max(value,h),L.u32_increment_no_wrap(value))
