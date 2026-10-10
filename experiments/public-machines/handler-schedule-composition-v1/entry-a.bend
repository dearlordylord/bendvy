import Base
import ./consumer.bend as Consumer
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as Types
def main() -> Consumer.Report:Consumer.report(~Types.SchemaA)
