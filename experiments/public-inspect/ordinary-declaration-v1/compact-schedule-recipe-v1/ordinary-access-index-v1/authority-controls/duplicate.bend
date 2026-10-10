import Base
import ../consumer-public.bend as Consumer
type Schema is Data:Schema{}
def duplicate(app:Consumer.Application(~Schema)) -> Consumer.Application(~Schema) & Consumer.Application(~Schema):(app,app)
def main() -> Unit:Unit{}
