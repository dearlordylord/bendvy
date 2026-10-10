import Base
import ../consumer-public.bend as Consumer
type Schema is Data:Schema{}
def duplicate(value:Consumer.Application(~Schema)) -> Consumer.Application(~Schema) & Consumer.Application(~Schema):(value,value)
def main() -> Unit:Unit{}
