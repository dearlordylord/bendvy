import Base
import ../guarded.bend as App
import ../guarded-nodes.bend as Nodes

def cross(owner:Nodes.RightNode(~App.SchemaA)) -> Nodes.RightNode(~App.SchemaB):owner
