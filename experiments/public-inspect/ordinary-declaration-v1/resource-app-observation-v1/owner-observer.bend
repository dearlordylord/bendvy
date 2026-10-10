import Base
import ../automatic-app-observation-v1/app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def world_joined(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~A:Type,~restore:W.World<S,C,R,E> -> H -> Bool -> A,owners:H,enabled:Bool,label:String,result:W.World<S,C,R,E> & String) -> A & String:
  match result:
    case (world,text):(restore(world,owners,enabled),label ++ "|world{" ++ text ++ "}")
def owners_joined(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~A:Type,~restore:W.World<S,C,R,E> -> H -> Bool -> A,~view:W.World<S,C,R,E> -> W.World<S,C,R,E> & String,~show:App.Binding<S> -> String,world:W.World<S,C,R,E>,enabled:Bool,label:String,result:H & List<&2,App.Binding<S>>) -> A & String:
  match result:
    case (owners,values):world_joined(~S,~C,~R,~E,~H,~A,~restore,owners,enabled,label ++ "|owners=" ++ List.show(&2,App.Binding<S>,show,values),view(world))
def observed(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~A:Type,~restore:W.World<S,C,R,E> -> H -> Bool -> A,~view:W.World<S,C,R,E> -> W.World<S,C,R,E> & String,~show:App.Binding<S> -> String,~describe:H -> H & List<&2,App.Binding<S>>,world:W.World<S,C,R,E>,owners:H,enabled:Bool,label:String) -> A & String:
  owners_joined(~S,~C,~R,~E,~H,~A,~restore,~view,~show,world,enabled,label,describe(owners))
