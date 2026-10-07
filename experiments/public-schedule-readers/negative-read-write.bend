import Base
import ../../src/ecs/capabilities.bend as Cap
import schema.bend as S

def write_read(~H: Type,~cap: Cap.Read<H,S.StockView>,ctx: H,value: S.Stock) -> H:
  Cap.set(~H,~S.Stock,~S.StockView,~cap,ctx,value)
