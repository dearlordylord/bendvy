import Base
import consumer-order.bend as A
import ../marker-phases-v1/apply-retention-v1/consumer.bend as C
def main() -> String:A.main_trace(~C.SchemaA,A.create(~C.SchemaA))
