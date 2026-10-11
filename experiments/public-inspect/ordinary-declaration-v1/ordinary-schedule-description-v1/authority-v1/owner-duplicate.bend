import Base
import ../public-v1/state.bend as F
import ../public-v1/bindings.bend as B
import ../public-v1/application.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule-description.bend as Description
def duplicate(app:A.Scheduled()) -> (A.Scheduled() & Maybe<&2,Description.Description<F.S,B.Rows4()>>) & (A.Scheduled() & Maybe<&2,Description.Description<F.S,B.Rows4()>>):(Description.snapshot(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),app),Description.snapshot(~F.S,~F.Store,~F.Resources,~F.Events(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),app))
def main() -> Unit:Unit{}
