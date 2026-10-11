import Base
import ./consumer.bend as F
import ../../consumer-public.bend as C
def main() -> String:"A=" ++ F.run(~C.A,F.setup_first(~C.A,C.setup(~C.A,True{}))) ++ "\nOther=" ++ F.run(~C.Other,F.setup_first(~C.Other,C.setup(~C.Other,False{})))
