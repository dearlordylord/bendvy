import Base
import ../definition.bend as Meta
def bad(~S:Data,~Plan:Type,definition:Meta.Definition<S,Plan>) -> String:
  Meta.into_plan(~S,~Plan,definition)
