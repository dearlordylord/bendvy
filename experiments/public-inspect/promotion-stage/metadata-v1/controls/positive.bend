import Base
import ../definition.bend as Meta
# All affine owner movement is explicit and uses the actual metadata API.
def same_schema(~S:Data,~Plan:Type,name:String,requirements:List<&2,Meta.Resource<S>>,plan:Plan) -> Meta.Definition<S,Plan>:
  Meta.make(~S,~Plan,name,requirements,plan)
def owner(~S:Data,~Plan:Type,definition:Meta.Definition<S,Plan>) -> Plan:
  Meta.into_plan(~S,~Plan,definition)
