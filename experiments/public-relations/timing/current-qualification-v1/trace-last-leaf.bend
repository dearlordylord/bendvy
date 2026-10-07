import Base
import trace-value.bend as J
# Boundary falsifier: only the last complete trace leaf changes (last systemResult).
def items(values:List<&2,J.Value>,next:J.Value -> J.Value) -> List<&2,J.Value>:
  match values:
    case []:[]
    case value <> []:[next(value)]
    case value <> head <> tail:value <> items(head <> tail,next)
def fields(values:List<&2,J.Field>,next:J.Value -> J.Value) -> List<&2,J.Field>:
  match values:
    case []:[]
    case J.Field{key,value} <> []:[J.Field{key,next(value)}]
    case field <> head <> tail:field <> fields(head <> tail,next)
def step(value:J.Value,next:J.Value -> J.Value) -> J.Value:
  match value:
    case J.Items{values}:J.Items{items(values,next)}
    case J.Object{values}:J.Object{fields(values,next)}
    case _:J.Number{1}
def mutate(fuel:Nat,value:J.Value) -> J.Value:
  match fuel:
    case 0n:J.Text{"INCOMPLETE_MUTANT"}
    case 1n+rest:step(value,value => mutate(rest,value))
