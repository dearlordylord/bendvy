import Base
# Reject an incorrect low-bit carry transition without large Nat normalization.
def bad_carry() -> {Word.inc(2n,WCon{True{},WCon{False{},WNil{}}}) == WCon{False{},WCon{False{},WNil{}}} : Word(2n)}:
  {==}
