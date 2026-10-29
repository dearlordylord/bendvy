import Base
import ../guarded-nodes.bend as Nodes

def escape(~S:Data,~Permit:Data,~H:Type,cap:Nodes.RightOps(Permit,H),scope:H) -> Nodes.R(~S):scope
