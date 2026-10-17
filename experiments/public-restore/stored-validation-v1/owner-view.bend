import Base
import schema.bend as F
import ../basic-world-statefree-v1/observe.bend as O
import ../../../src/ecs/restore-schema.bend as Schema
import ../../../src/ecs/restore-public.bend as Public
import ../../../src/ecs/ordinary-schema.bend as Ordinary
import ../../../src/ecs/schema-fragments.bend as Fragment

def schema_text(~S:Data,value:F.FullSchema(~S)) -> String:
  match value:
    case Schema.Schema{Ordinary.Schema{entries}}:List.show(&2,Fragment.Entry<S>,O.schema_entry(~S),entries)
def joined(~S:Data,+schema:F.FullSchema(~S),observed:F.FullState(~S) & String) -> F.Owned(~S) & String:
  match observed:
    case (state,text):(Public.Owner{schema,state},"owner{schema=" ++ schema_text(~S,schema) ++ ";state=" ++ text ++ "}")
def owner(~S:Data,value:F.Owned(~S)) -> F.Owned(~S) & String:
  match value:
    case Public.Owner{schema,state}:joined(~S,schema,O.state(~S,state))
