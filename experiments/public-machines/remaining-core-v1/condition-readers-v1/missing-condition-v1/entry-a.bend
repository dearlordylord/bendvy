import Base
import consumer.bend as C
import ../provider.bend as P
def main() -> String:C.main_trace(~P.SchemaA,C.create(~P.SchemaA))
