import Base
import selector.bend as Select
import ../application.bend as App
import ../main.bend as Baseline
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/declaration.bend as Decl

def wrong(owner:Input.Owner) -> D.Receipt<Input.Owner>:
  Select.load(~Baseline.Schema,~Input.Owner,~App.resource_identity(~Baseline.Schema),~Input.project,Decl.plain(~Baseline.Schema,~Input.Owner,~App.resource_identity(~Baseline.Schema)),None{},owner)
