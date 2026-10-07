import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../public-schedule-readers/schema.bend as S
def write(~H:Type,~cap:Cap.Read<H,S.StockView>,ctx:H,owner:S.Stock) -> H:
  Cap.set(~H,~S.Stock,~S.StockView,~cap,ctx,owner)
