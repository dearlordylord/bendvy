import Base
import ../consumer-public.bend as Consumer
type Schema is Data:Schema{}
type Other is Data:Other{}
def snapshot(app:Consumer.Application(~Other)) -> Consumer.Application(~Schema) & String:
  Consumer.snapshot(~Schema,True{},app)
def main() -> Unit:Unit{}
