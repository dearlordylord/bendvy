import Base
import ../retained-workshop.bend as A

def bad(~H:Type,~caps:A.Reads<H>,ctx:H) -> H & H:
  (ctx,ctx)
