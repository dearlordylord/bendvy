import Base
import ./consumer-public.bend as Consumer
type Schema is Data:Schema{}
def main() -> Consumer.Report:Consumer.report(~Schema)
