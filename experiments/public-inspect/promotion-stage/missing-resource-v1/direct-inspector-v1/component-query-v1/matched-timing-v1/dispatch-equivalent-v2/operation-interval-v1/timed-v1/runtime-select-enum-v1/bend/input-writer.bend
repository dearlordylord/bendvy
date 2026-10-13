import Base
import schema-families.bend as D
import runtime-owners.bend as Owners
import check-inputs.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
def World(~S:Data) -> Type:W.World<S,D.Store<S>,Owners.Resource(~S),U32>
def Ops(~S:Data,H:Type) -> Type:Ord.Write<S,Owners.CheckInputs<S>,Input.identity(~S),H,Owners.CheckInputs<S>>
def declaration(~S:Data) -> Ord.Declaration<S,T.Tx<World(~S),U32>,Ops(~S,T.Tx<World(~S),U32>)>:
  Ord.write(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Owners.CheckInputs<S>,~(Unit & Owners.Physical<S>),~Owners.CheckInputs<S>,~Input.lens(~S),~Input.identity(~S),~Input.binding(~S),~Input.view(~S))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),value:Owners.CheckInputs<S>,owner:H) -> H & (T.Outcome<Unit> & Unit):
  (Ord.set(~S,~Owners.CheckInputs<S>,~Input.identity(~S),~H,~Owners.CheckInputs<S>,~caps,owner,value),(T.Success{},Unit{}))
def set_world(~S:Data,world:World(~S),value:Owners.CheckInputs<S>) -> Sys.Outcome<World(~S),Unit,Unit>:
  Ord.runner(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Ops(~S),~Owners.CheckInputs<S>,~Unit,~Unit,~declaration(~S),~body(~S))(world,value)
def Registry(~S:Data) -> Type:Sys.Registry<S,D.Store<S>,Owners.Resource(~S),U32,Owners.CheckInputs<S>,Unit,Unit,set_world(~S)>
def start(~S:Data,world:World(~S)) -> Sys.RegistrationResult<S,D.Store<S>,Owners.Resource(~S),U32,Owners.CheckInputs<S>,Unit,Unit,set_world(~S)>:
  Sys.register(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Owners.CheckInputs<S>,~Unit,~Unit,~set_world(~S),world,"SetCheckInputs",Ord.access(~S,Ord.clauses(~S,~T.Tx<World(~S),U32>,~Ops(~S,T.Tx<World(~S),U32>),declaration(~S))))
def returned(~S:Data,result:Sys.RunResult<S,D.Store<S>,Owners.Resource(~S),U32,Owners.CheckInputs<S>,Unit,Unit,set_world(~S)>) -> Registry(~S) & Sys.Outcome<World(~S),Unit,Unit>:
  match result:
    case Sys.Completed{registry,outcome}:(registry,outcome)
    case Sys.RegistrationRejected{registry,world,_}:(registry,Sys.Failed{world,Unit{}})
def run(~S:Data,registry:Registry(~S),world:World(~S),value:Owners.CheckInputs<S>) -> Registry(~S) & Sys.Outcome<World(~S),Unit,Unit>:
  returned(~S,Sys.run_tracked(~S,~D.Store<S>,~Owners.Resource(~S),~U32,~Owners.CheckInputs<S>,~Unit,~Unit,~set_world(~S),registry,world,value))
