import Base
import ./consumer-unrelate-public.bend as Consumer

type Schema is Data:
  Schema{}
def main() -> String:
  Consumer.scenario(~Schema)
