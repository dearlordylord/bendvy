import Base
import ./normal-render.bend as Render
import ./normal-body-control.bend as Body
import ./normal-registered-observation.bend as Registered
import ./normal-duplicate-control.bend as Duplicate
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment

def cursor(value:Body.Cursor) -> String:
  match value:
    case Body.Fresh{}:Render.object([Render.field("kind",Render.quote("Fresh"))])
    case Body.Active{cursor,registeredAt}:Render.object([Render.field("kind",Render.quote("Active")),Render.field("cursor",U32.show(cursor)),Render.field("registeredAt",U32.show(registeredAt))])
def boolean(value:Bool) -> String:
  match value:
    case False{}:"false"
    case True{}:"true"
def result(value:Result<&2,&2,Unit,Bool>) -> String:
  match value:
    case Done{value}:Render.object([Render.field("kind",Render.quote("Done")),Render.field("value",boolean(value))])
    case Fail{Unit{}}:Render.object([Render.field("kind",Render.quote("Fail"))])
def registered(value:Registered.Observation) -> String:
  match value:
    case Registered.Observation{beforeWorld,afterWorld,beforeApp,afterApp,mark,vresult}:Render.object([Render.field("beforeWorld",Render.world(beforeWorld)),Render.field("afterWorld",Render.world(afterWorld)),Render.field("beforeApp",Render.app(beforeApp)),Render.field("afterApp",Render.app(afterApp)),Render.field("cursor",cursor(mark)),Render.field("result",result(vresult))])
def duplicate(value:Duplicate.Observation) -> String:
  match value:
    case Duplicate.Observation{Fragment.DuplicateKey{Fragment.Resource{},key},left,right}:Render.object([Render.field("error",Render.object([Render.field("kind",Render.quote("DuplicateKey")),Render.field("registryKind",Render.quote("Resource")),Render.field("key",Render.quote(key))])),Render.field("left",Render.quote(left)),Render.field("right",Render.quote(right))])
    case other:"unexpected-duplicate-error"
