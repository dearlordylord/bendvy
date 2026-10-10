import Base
import ./mismatched-id-consumer.bend as Consumer
type Schema is Data:Schema{}
def main() -> String:Consumer.scenario(~Schema)
