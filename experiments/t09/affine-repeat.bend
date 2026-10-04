import Base
import ./api.bend as A
import ./system.bend as S

def bad(callback: Unit -> Unit) -> Unit:
  _ = callback(Unit{})
  callback(Unit{})
