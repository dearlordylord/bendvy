import Base
import ../consumer-public.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
type Schema is Data:Schema{}
type Other is Data:Other{}
def foreign(value:Filter.Component<Schema>,app:Consumer.Application(~Other)) -> Consumer.Application(~Other) & String:
  Consumer.filtered(~Other,Filter.Filter{None{},[value],None{}},True{},app)
def main() -> Unit:Unit{}
