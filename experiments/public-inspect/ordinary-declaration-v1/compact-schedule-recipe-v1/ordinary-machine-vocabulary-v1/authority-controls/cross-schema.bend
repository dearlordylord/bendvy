import Base
import ../consumer-public.bend as Consumer
type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
def invalid(app:Consumer.Application(~Schema)) -> Consumer.Application(~Other) & String:Consumer.snapshot(~Other,True{},app)
def main() -> Unit:Unit{}
