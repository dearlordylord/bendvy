import Base
import ../consumer.bend as C
import ../../provider.bend as P
def main() -> String:C.main_trace(~P.SchemaB,C.create(~P.SchemaB))
