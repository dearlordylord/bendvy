import Base
import ../definition.bend as Meta
def bad(~S:Data,~Plan:Type,definition:Meta.Definition<S,Plan>) -> Meta.Definition<S,Plan> & Meta.Definition<S,Plan>:
  (definition,definition)
