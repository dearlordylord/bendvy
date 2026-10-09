import Base
import main.bend as Main
import application.bend as App
import admission.bend as Gate
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def wrong(world:App.World(~Main.Schema),handle:W.Handle<Main.OtherSchema>,owner:Input.Owner) -> Gate.Returned<(App.World(~Main.Schema) & W.Handle<Main.Schema>),Input.Owner,App.Output<Main.Schema>>:
  App.request(~Main.Schema,handle,App.Insert{},D.BoolValue{},world,owner)
