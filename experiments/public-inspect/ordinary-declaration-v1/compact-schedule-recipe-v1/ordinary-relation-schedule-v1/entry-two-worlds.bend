import Base
import ./two-worlds.bend as Consumer
type Schema is Data:
  Schema{}
def main() -> String:
  Consumer.scenario(~Schema)
