import Base
import ./observation.bend as O
import ./main.bend as B
import ./application.bend as App
import ./registered.bend as Registered
import ./public.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as Input
# The governing failure outcome passes through the SAME registered provider;
# accepted prepared packets/output survive in explicit Local, World rolls back.
def reserved(+operation:App.Operation,+raw:D.Raw,result:App.World(~B.Schema) & W.Reservation<B.Schema>) -> B.Observation:
  match result:
    case (world,W.Reserved{target}):B.provisioned(~B.Schema,target,operation,raw,None{},Registered.define(~B.Schema,world,Public.Declaration{operation,D.Integer{},T.Failure{Unit{}}}))
    case (world,W.ReservationRejected{error}):B.SetupRefused{error}
def created(operation:App.Operation,raw:D.Raw,result:W.Creation<B.Schema,App.Store(~B.Schema),App.Mail<B.Schema>,Unit>) -> B.Observation:
  match result:
    case W.Created{factory,world}:reserved(operation,raw,W.reserve_id(~B.Schema,~App.Store(~B.Schema),~App.Mail<B.Schema>,~Unit,world))
    case W.CreateRejected{factory,mail}:B.create_refused(~B.Schema,O.mail(~B.Schema,mail))
def run(operation:App.Operation,raw:D.Raw) -> B.Observation:
  created(operation,raw,W.create(~B.Schema,~App.Store(~B.Schema),~App.Mail<B.Schema>,~Unit,~B.empty(~B.Schema),W.factory(),App.initial(~B.Schema,Input.Owner{D.Text{"initial-resource"},ANode{ALeaf{555},ALeaf{666}}})))
type Report is Data:Report{resourceAccepted:B.Observation,resourceRefused:B.Observation,spawnAccepted:B.Observation,spawnRefused:B.Observation}
def main() -> Report:Report{run(App.Resource{},D.Number{7}),run(App.Resource{},D.Boolean{False{}}),run(App.Spawn{},D.Number{7}),run(App.Spawn{},D.Boolean{False{}})}
