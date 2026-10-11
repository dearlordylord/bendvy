import Base
import ./consumer.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-machines/remaining-core-v1/condition-readers-v1/provider.bend as P
def main() -> String:C.main_trace(~P.SchemaA,C.create(~P.SchemaA))
