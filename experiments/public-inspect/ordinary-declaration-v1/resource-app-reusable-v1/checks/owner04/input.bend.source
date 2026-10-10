import Base
# Test-only opaque reconstruction and actual-owner observation. Each callback is consumed once.
def world_joined(~World:Type,~H:Type,~A:Type,restore:World -> H -> Bool -> A,owners:H,enabled:Bool,label:String,result:World & String) -> A & String:
  match result:
    case (world,text):(restore(world,owners,enabled),label ++ "|world{" ++ text ++ "}")
def owners_joined(~World:Type,~H:Type,~A:Type,restore:World -> H -> Bool -> A,view:World -> World & String,world:World,enabled:Bool,label:String,result:H & String) -> A & String:
  match result:
    case (owners,text):world_joined(~World,~H,~A,restore,owners,enabled,label ++ "|owners=" ++ text,view(world))
def observed(~World:Type,~H:Type,~A:Type,restore:World -> H -> Bool -> A,view:World -> World & String,describe:H -> H & String,world:World,owners:H,enabled:Bool,label:String) -> A & String:
  owners_joined(~World,~H,~A,restore,view,world,enabled,label,describe(owners))
