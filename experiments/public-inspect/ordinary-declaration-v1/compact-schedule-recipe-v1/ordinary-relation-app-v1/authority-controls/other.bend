import Base
import ../consumer.bend as Consumer
type Other is Data:
  Other{}
def main() -> String:
  Consumer.scenario(~Other)
