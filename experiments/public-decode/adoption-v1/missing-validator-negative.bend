import Base
import main.bend as Main
import application.bend as App
import admission.bend as Gate
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input

def wrong(world:App.World(~Main.Schema),owner:Input.Owner) -> Gate.Returned<App.World(~Main.Schema),Input.Owner,App.Output<Main.Schema>>:
  Gate.request(~Main.Schema,~App.World(~Main.Schema),~Input.Owner,~App.Output<Main.Schema>,~App.identity(~Main.Schema),~Input.project,~App.resource(~Main.Schema),Unit{},world,owner)
