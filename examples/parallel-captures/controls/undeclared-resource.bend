import Base
import ../payloads.bend as P
import ../../../src/ecs/execution-resource-access.bend as Access
import ../../../src/ecs/execution-resource-store.bend as Store

def write(~H:Type,cap:Access.Writer<H,P.Counter,String>,scope:H) -> H & Store.Edit<P.Counter,String>:
  match cap:
    case Access.Writer{_,own,_}:own(String,scope,P.update_score)
    case Access.UnsupportedWriter{}:(scope,Store.Unchanged{P.update_counter})
